import "dapple/debug.sol";
// TODO - do I need the ID?
contract Org is Debug {

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
  struct Option {
    OptionSet os;
    byte _type; // Terminal
    bytes data;
    bool last;
    mapping (address => uint) votes;
    // unfortnutately this has to be computed in storage
    // untill memory struct or mapping are possible
    // or someone comes up with a better solution
    mapping (address => uint) performance;
    uint maxPerformance;
  }

  struct OptionSet {
    byte id;
    mapping (address => address[]) delegations;
    mapping (byte => Option) o;
    byte[] os;
    // unfortnutately this has to be computed in storage
    // untill memory struct or mapping are possible
    // or someone comes up with a better solution
    // mapping (byte => mapping (address => uint)) performance;
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

  function propose(bytes data, bytes proof) {
    // assert atoicity
    if( !isValide(proof) ) throw;

    OptionSet oS = start;
    for (var i=0; i<proof.length; i++) {
      // TODO - data in option map selection
      // maybe with sha3
      // set 
      if (oS.o[proof[i]]._type == byte(0x00)) {
        oS.os.push(proof[i]);
      }
      oS.o[proof[i]]._type = proof[i];
      oS = oS.o[proof[i]].os;
    }
    // mark last option as proof ending;
    oS.os.push(byte(0xff));
    oS.o[byte(0xff)]._type = byte(0xff);
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
  // function getConsens() returns( byte[32] consens ) {
  //   OptionSet os = start;
  //   uint index = 0;
  //   while ( os.os.length != 0 ) {
  //     consens[index] = os.o[os.os[0]]._type;
  //     index++;
  //     os = os.o[os.os[0]].os;
  //   }
  //   return consens;
  // }
  //
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
  //
  // function _computePerformance( Option o ) internal {
  //   if( o._type != byte(0xff) ) {
  //     Option memory bestChild = _getBestChild( o.os );
  //     // compute performance on the basis of best child
  //   }
  // }
  //
  // function _getBestChild( OptionSet os ) internal returns(Option o){
  //   
  // }

}
