import "dapple/debug.sol";
import "dapple/test.sol";
// TODO - do I need the ID?
contract Org is Test {

  // Atomic Terminals
  // 0x01 - bool
  // 0x02 - uint256
  // 0x03 - string256

  // Nonatomic Terminals
  // Has to be explicitly linked
  // 0x40+

  // TODO - a delegation set is List[ Address x Address ]
  //        an optimisation could be refering to addresses
  //        saved in an global ownership table, but what if they change?
  struct OptionSet {
    byte _type;
    uint _id;

    mapping (address => address[]) delegations;
    mapping (address => uint) votes;

    mapping (byte => OptionSet) optionFor;
    byte[] children;
    // todo refactor
    OptionSet[] option;
    bytes data;
    uint maxPerformance;
    // unfortnutately this has to be computed in storage
    // untill memory struct or mapping are possible
    // or someone comes up with a better solution
    mapping (byte => mapping (address => uint)) performance;
  }

  address[] owners;
  mapping (address => uint) shares;

  // N == 0x01 => Start rule
  // N == 0xff => Finish rule
  mapping (byte => OptionSet) optionSetMapping;
  OptionSet start;

  // Organisation Language
  mapping (byte => mapping (byte => byte)) R;
  mapping (byte => bool) accepted; // accepted rules

  // Gets an byte array where each byte is (N -> t N)
  // i%3=0 is current rule
  // i%3=1 is terminal
  // i%3=2 is next rule
  function Org( bytes grammar ) {
    // grammar has to be in right linear form
    if( grammar.length % 3 != 0 )
      throw;

    start._type = byte(0x01);

    // create start option set:
    // optionSetMapping[byte(0x01)].id = byte(0x01);
    for(var i=0; i < grammar.length; i+=3 ) {
      if( grammar[i+1] == byte(0xff) ) { // end
        accepted[grammar[i]] = true;
      } else {
        R[grammar[i]][grammar[i+1]]=grammar[i+2];
      }
    }
  }

  uint idc = 0;
  function propose(bytes data, bytes proof) {
    // assert atoicity
    if( !isValide(proof) ) throw;

    OptionSet oS = start;
    for (var i=0; i<proof.length; i++) {
      // TODO - include data in option map selection
      // maybe with sha3
      // set 
      if (oS.optionFor[proof[i]]._type == byte(0x00)) {
        oS.children.length++;
        oS.children[oS.children.length -1] = proof[i];
        // oS.children.push(proof[i]);
        // log_uint(oS.children.length);
        oS.optionFor[proof[i]]._type = proof[i];
        oS.optionFor[proof[i]]._id = idc++;
      }
      oS = oS.optionFor[proof[i]];
    }
    // mark last option as proof ending;
    oS.children.length++;
    oS.children[ oS.children.length - 1 ] = byte(0xff);
    // oS.children.push(byte(0xff));
    oS.optionFor[byte(0xff)]._type = byte(0xff);
    oS.optionFor[byte(0xff)]._id = idc++;
  }

  // TODO rewrite validation - simplify
  function isValide(bytes word) returns (bool) {
    byte rule = byte(0x01);
    for( var i=0; i<word.length; i++) {
      rule = R[rule][word[i]];
      if( rule == byte(0x00) && i<word.length-1 )
        return false;
    }
    return ((rule >= byte(0xff))||(accepted[rule]));
  }

  // Variable size data returning is not supported yet
  // http://solidity.readthedocs.org/en/latest/frequently-asked-questions.html#can-you-return-an-array-or-a-string-from-a-solidity-function-call
  // This should be reimplemented as soon as there is support
  function getConsens() returns( byte[32] consens ) {
    OptionSet os = start;
    uint index = 0;
    while ( os.children.length != 0 ) {
      consens[index] = os.optionFor[os.children[0]]._type;
      index++;
      os = os.optionFor[os.children[0]];
    }
    return consens;
  }

  function getNewConsens() returns( byte[32] consens ) {
    log_bytes("---");
    var (os, perf, cs, ci) = _computePerformance( start );
    return cs;
  }
  // function _getConsens(OptionSet storage os) internal returns(byte[32] consens ) {
  //   // compute the best performing option in the opton set
  //   // each option
  //   for ( var i=0; i<os.os.length; i++ ) {
  //     Option current = os.o[os.os[i]];
  //     uint performance = 0;
  //     for( var j=0; j<owners.length; j++ ) {
  //     }
  //   }
  // }

  function _computePerformance( OptionSet storage os ) internal returns(
    OptionSet storage bestChild,
    uint performance,
    byte[32] cs,
    uint ci
  ){
    performance = 0;
    byte[32] memory _cs;
    uint _ci = 0;
    if( os._type != byte(0xff) ) { // if the OptionSet has children
      // OptionSet storage bestChild;
      (bestChild, performance, cs, ci) = _getBestChild( os );
      // compute performance on the basis of best child
      // log_uint(ci);
      _cs = cs;
      _ci = ci;
    } else {
      // log_uint(os._id);
      for (var i=0; i<owners.length; i++) {
        // TODO - watch for overflow
        performance += shares[owners[i]]*os.votes[owners[i]];
      }
      bestChild = os;
    }
    // log_bytes("111");
    // log_uint(os._id);
    // log_uint(bestChild._id);
    return (bestChild, performance, _cs, _ci);
  }

  // given an option set, traverse all children and 
  // return best performing child
  function _getBestChild( OptionSet storage os ) internal returns(
    OptionSet storage o,
    uint maxPerformance,
    byte[32] cs,
    uint ci
  ) {
    uint index = 0;
    byte[32] memory _cs;
    uint _ci;
    for (var i =0; i<os.children.length; i++) {
      OptionSet c = os.optionFor[os.children[i]];
      (,,_cs, _ci) = _computePerformance (c);
      if (c.maxPerformance > maxPerformance) {
        log_uint(11);
        index = i;
        maxPerformance = c.maxPerformance;
        cs = _cs;
        ci = _ci;
      }
    }
    _cs[_ci] = os._type;
    _ci++;
    return (os.optionFor[os.children[index]], maxPerformance, _cs, _ci);
  }

}
