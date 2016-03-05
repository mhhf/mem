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
    bytes _id;
    bytes _parent;
    bytes[] _children;
    byte _best_child;

    mapping (address => address[]) delegations;
    mapping (address => uint) votes;

    mapping (byte => OptionSet) optionFor;
    byte[] children;
    // todo refactor
    bytes data;
    uint maxPerformance;
    uint performance;
    // unfortnutately this has to be computed in storage
    // untill memory struct or mapping are possible
    // or someone comes up with a better solution
    // mapping (byte => mapping (address => uint)) performance;
  }
  bytes consens;

  mapping (bytes => OptionSet) node;

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
  function Org(bytes grammar) {
    // grammar has to be in right linear form
    if( grammar.length % 3 != 0 )
      throw;
    start._type = byte(0x01);

    // create start option set:
    for(var i=0; i < grammar.length; i+=3 ) {
      if( grammar[i+1] == byte(0xff) ) { // end
        accepted[grammar[i]] = true;
      }
      R[grammar[i]][grammar[i+1]]=grammar[i+2];
    }
  }

  function propose(bytes data, bytes _proof) {
    // assert atoicity
    if( !isValide(_proof) ) throw;

    bytes memory proof = __extend(_proof, 1);
    proof[_proof.length] = byte(0xff);
    //@log proposing candidate: `bytes proof`

    OptionSet storage parent = node[""];
    for (var i=0; i<proof.length; i++) {
      bytes memory slice = __slice(proof,0,i+1);
      //@debug looking at `bytes slice`
      OptionSet storage child = node[slice];
      if( child._id.length == 0 ) {
        //@debug not in trie
        child._id = slice;
        child._parent = parent._id;
        child._type = proof[i];
        parent._children.push (__slice(proof, 0, i));
      }
      parent = child;
    }
  }

  // TODO rewrite validation - simplify
  function isValide(bytes word) returns (bool) {
    byte rule = byte(0x01);
    for( var i=0; i<word.length; i++) {
      rule = R[rule][word[i]];
      if( rule == byte(0xff) )
        return true;
      if( rule == byte(0x00) && i<word.length-1 )
        return false;
    }
    return ((rule == byte(0xff))||(accepted[rule]));
  }

  function getConsens() returns(byte[32] _consens) {
    //@info getting consens
    OptionSet os = node[""];
    uint index = 0;
    while ( os._type != byte(0xff) && os._best_child != byte(0xff) ) {
      bytes memory link = __extend(os._id, 1);
      link[link.length - 1] = os._best_child;
      _consens[index++] = os._best_child;
      os = node[link];
    }
    return _consens;
  }

  function getNewConsens() returns( byte[32] consens ) {
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

  function vote(bytes candidate, uint vote) returns(bool success) {
    //@info --- VOTING
    if( !isValide(candidate) ) throw;
    if( vote > 1000 ) throw;

    // Grab the option set
    // update the users votes
    // compute the performance
    // propagate performance to the root
    OptionSet child = node[candidate];
    bool increase = vote > child.votes[msg.sender];
    uint update;
    if( increase ) {
      update = vote - child.votes[msg.sender];
    } else {
      update = child.votes[msg.sender] - vote;
    }
    child.votes[msg.sender] = vote;
    child.performance += update;
    //@debug updating child `bytes child._id`: `uint update`

    for(var i = 0; i < candidate.length; i++) {
      // 1. child was top performer
      // 1.1 child increased
      //  => update parent p.p += update
      // 1.2 child decreased
      //   ? check if other child has become top (c'.p > )
      // 1.2.1 yes => make other child to top
      // 1.2.2 no  => update parent p.p += update
      // 2. child was not top
      // 2.1 child increased
      //   ? check if child become top: c.p > p.p?
      // 2.1.1 yes => inherit performance from parent p.p = c.p
      // 2.1.2 no  => stop
      // 2.2 child decreased => stop

      OptionSet parent = node[child._parent];
      if( parent._best_child == child._type ) { // child was top performer
        if( increase ) { // 1.1 child increased
          //  => update parent p.p += update
          parent.performance += update;
        } else { // 1.2 child decreased
          //   ? check if other child has become top
          OptionSet storage best = _findBestPerformingChild(parent);
          if( best._type == child._type ) { // 1.2.2 no
            // update parent p.p += update
            parent.performance -= update;
          } else { // 1.2.1 yes
            // make other child to top
            parent.performance = best.performance;
            parent._best_child = best._type;
          }
        }
      } else { // child was not top performer
        if( increase ) { // 2.1 child increased
          if( child.performance > parent.performance ) { // check if child become top: c.p > p.p?
            // 2.1.1 yes => inherit from child p.p = c.p
            parent.performance = child.performance;
            parent._best_child = child._type;
          } else { // 2.1.2 no  => stop
            break;
          }
        } else { // 2.2 child decreased
          // stop
          break;
        }
      }
      child = parent;
      // TODO (1.1, 1.2.1, 1.2.2, 2.1.1) write tests
    }
    //@log stop at `bytes parent._id`, performance is `uint parent.performance`
    // TODO save consens
  }


  // QUESTION - does this eaven make sence? suppose a really big scenario
  // here one cannot compute everything in the gas limit
  function _computePerformance( OptionSet storage os ) internal returns(
    OptionSet storage bestChild,
    uint performance,
    byte[32] cs,
    uint ci
  ) {
    performance = 0;
    byte[32] memory _cs;
    uint _ci = 0;
    uint i;
    if( os._type != byte(0xff) ) { //if the OptionSet has children
      uint maxPerformance;
      // search for the child with the best performance
      for (i =0; i<os.children.length; i++) {
        OptionSet c = os.optionFor[os.children[i]];
        (,,cs, ci) = _computePerformance (c);
        if (c.maxPerformance > maxPerformance ||i == 0) {
          bestChild = c;
          maxPerformance = c.maxPerformance;
          _cs = cs;
          _ci = ci;
        }
      }
      _cs[_ci] = os._type;
      _ci++;
    } else {
      for (i=0; i<owners.length; i++) {
        // TODO - watch for overflow
        performance += shares[owners[i]]*os.votes[owners[i]];
      }
      bestChild = os;
    }
    // EXPENSIVE - maybe export to something different?!
    if( os.maxPerformance != performance ) {
      os.maxPerformance = performance;
    }
    return (bestChild, performance, _cs, _ci);
  }


  // DEPRECATED
  // given an option set, traverse all children and 
  // return best performing child
  // function _getBestChild( OptionSet storage os ) internal returns(
  //   OptionSet storage o,
  //   uint maxPerformance,
  //   byte[32] cs,
  //   uint ci
  // ) {
  //   uint index = 0;
  //   byte[32] memory _cs;
  //   uint _ci;
  //   for (var i =0; i<os.children.length; i++) {
  //     OptionSet c = os.optionFor[os.children[i]];
  //     (,,_cs, _ci) = _computePerformance (c);
  //     if (c.maxPerformance > maxPerformance ||i == 0) {
  //       index = i;
  //       maxPerformance = c.maxPerformance;
  //       cs = _cs;
  //       ci = _ci;
  //     }
  //   }
  //   // (,,_cs, _ci) = _computePerformance (os.optionFor[os.children[0]]);
  //   cs[ci] = os._type;
  //   ci++;
  //   return (os.optionFor[os.children[index]], maxPerformance, cs, ci);
  // }

  function _findBestPerformingChild( OptionSet _node ) internal returns(OptionSet storage best) {
    uint performance= 0;
    for (var j=0; j<_node._children.length; j++) {
      if(performance < node[_node._children[j]].performance) {
        performance = node[_node._children[j]].performance;
        best = node[_node._children[j]];
      }
    }
    return best;
  }

  function __slice(bytes _in, uint from, uint to) internal returns(bytes out) {
    out = new bytes(to-from);
    for(var i=0; i< to-from; i++) {
      out[i] = _in[from+i];
    }
    return out;
  }

  function __extend(bytes fst, uint extend) internal returns(bytes out) {
    out = new bytes(fst.length + extend);
    for(var i=0; i < fst.length; i++) {
      out[i] = fst[i];
    }
    return out;
  }

}
