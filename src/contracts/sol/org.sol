import "dapple/debug.sol";
import "dapple/test.sol";




// THIS IS A PROOF  OF CONCEPT
// CURRENTLY THERE ARE LIMITS ON:
// OWNERSHIP SET: max 32 owners allowed
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
  struct Node {
    byte _type;
    bytes _id;
    bytes _parent;
    bytes[] _children;
    uint8 _best_child; // index

    // delegation is a set with d.length % 2 == 0
    // i   = owner._id
    // i+1 = vote ammount
    uint8[32] delegations;
    // mapping (address => address[]) delegations;
    // mapping (address => uint) votes;
    uint[32] votes;

    mapping (byte => Node) optionFor;
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

  mapping (bytes => Node) nodes;

  mapping (uint8 => address) owners;
  mapping (address => uint8) ownerId;
  uint8 public numOwners;
  mapping (uint8 => uint) public shares;

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

    // INITIALIZE orga with 10000 shares
    numOwners = 1;
    owners[1] = msg.sender;
    ownerId[msg.sender] = 1;
    shares[1] = 10000;

    // create start option set:
    for(var i=0; i < grammar.length; i+=3 ) {
      if( grammar[i+1] == byte(0xff) ) { // end
        accepted[grammar[i]] = true;
      }
      R[grammar[i]][grammar[i+1]]=grammar[i+2];
    }
  }

  function send(address to, uint value) {
    if(shares[ownerId[msg.sender]] < value) throw;
    if(ownerId[to] == 0) {
      if (numOwners >= 32) throw;
      numOwners++;
      owners[numOwners] = to;
      ownerId[to] = numOwners;
      shares[ownerId[msg.sender]] -= value;
      shares[numOwners] += value;
    }
  }

  function propose(bytes data, bytes _proof) {
    // assert atoicity
    if( !isValide(_proof) ) throw;

    bytes memory proof = __extend(_proof, 1);
    proof[_proof.length] = byte(0xff);
    //@log proposing candidate: `bytes proof`

    Node storage parent = nodes[""];
    for (var i=0; i<proof.length; i++) {
      bytes memory slice = __slice(proof,0,i+1);
      //@debug looking at `bytes slice`
      Node storage child = nodes[slice];
      if( child._id.length == 0 ) {
        //@debug not in trie
        child._id = slice;
        child._parent = parent._id;
        child._type = proof[i];
        parent._children.push (slice);
      }
      parent = child;
    }
    parent = nodes[""];
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
    Node storage node = nodes[""];
    //@log #children: `uint node._children.length` `bytes node._children[0]`
    uint8 index = 0;
    while ( node._type != byte(0xff) && node._children.length != 0 && index < 32) {
      node = nodes[node._children[node._best_child]];
      _consens[index++] = node._type;
    }
    return _consens;
  }

  // TODO - the delegation property is not transitive - make this transitive
  function getCandidatePerformance(bytes candidate) returns(uint performance) {
    // TODO - check if candidate is in Trie

    // var (delegations, votes) = _inheritBasis (candidate);
    // Node best = _getBestChild(nodes[candidate]);
    // return _getBestChildPerformance( delegations, votes, nodes[candidate] );

    //
    // BUILD DELIGATION SET
    Node node = nodes[""];
    uint8[32] memory delegations;
    uint[32] memory votes;
    uint8 i;
    for (i=0; i<candidate.length; i++) { // from root to candidate
      node = nodes[__slice(candidate,0,i+1)];
      for (var j=1; j<=numOwners; j++) { // inherit deligations
        if( node.delegations[j] > 0 ) { // if delegations is set
          delegations[j] = node.delegations[j]; // take
        }
        if( node.votes[j] > 0 ) {
          votes[j] = node.votes[j];
        }
      }
    }
    // TODO - compute transitive hull of delegations
    for (i=1; i<=numOwners; i++) {
      if (votes[i] > 0) { // has voted
        performance += votes[i] * shares[i];
      } else if(delegations[i] > 0) { // delegate has voted
        performance += votes[delegations[i]] * shares[i];
      }
    }
    return performance;
  }

  // function getNewConsens() returns( byte[32] consens ) {
  //   var (os, perf, cs, ci) = _computePerformance( start );
  //   return cs;
  // }
  // function _getConsens(Node storage os) internal returns(byte[32] consens ) {
  //   // compute the best performing option in the opton set
  //   // each option
  //   for ( var i=0; i<os.os.length; i++ ) {
  //     Option current = os.o[os.os[i]];
  //     uint performance = 0;
  //     for( var j=0; j<owners.length; j++ ) {
  //     }
  //   }
  // }

  // TODO - to fucking expensive - play with ways to optimize this
  function vote(bytes candidate, uint vote) returns(bool success) {
    if( !isValide(candidate) ) throw;
    if( vote > 1000 ) throw;
    //@info owner `uint ownerId[msg.sender]` voted `uint vote` for `bytes candidate`
    Node node = nodes[candidate];
    node.votes[ownerId[msg.sender]] = vote;
    if(node._type != byte(0xff)) {
      var (delegations, votes) = _inheritBasis(node._id);
      __correctBestChildRelationBottom(delegations, votes, node);
    }
    __correctBestChildRelation(node);
  }

  function delegate(address to, bytes context) returns(bool success) {
    if(ownerId[to] == 0) throw;
    Node node = nodes[context];
    node.delegations[ownerId[msg.sender]] = ownerId[to];
    var (delegations, votes) = _inheritBasis(node._id);
    __correctBestChildRelationBottom(delegations, votes, node);
    __correctBestChildRelation(node);
  }

  function __correctBestChildRelation(Node node) internal {
    Node storage parent = nodes[node._parent];
    uint8[32] memory delegations;
    uint[32] memory votes;
    uint performance;
    uint performance_;
    uint8 i;

    while ( node._id.length > 0) {
      (delegations, votes) = _inheritBasis(node._id);
      performance = _getBestChildPerformance (delegations, votes, node);
      //@log performance of node `bytes node._id` is `uint performance`
      // if node is best child
      if( nodes[parent._children[parent._best_child]]._type == node._type ) {
        //@log node is best child
        uint8 bestIndex = parent._best_child;
        // check if still best child
        for(i=0; i<parent._children.length; i++) {
          if(i==parent._best_child) { continue; }
          if(performance < _getBestChildPerformance(delegations, votes, nodes[parent._children[i]])) {
            bestIndex = i;
          }
        }
        if(bestIndex == parent._best_child) { // 1.1 still best
          //@log still best child
          // => propagate
        } else { // 1.2 not best
          //@log no more best child
          parent._best_child = bestIndex;
          // switch best and propagate with new
        }
      } else { // node is not best child
        //@log node is not best child
        // get best child performance
        performance_ = getCandidatePerformance(_getBestChild(parent)._id);
        //@log performance of previous best child was `uint performance_`
        // compare to nodes performance
        if( performance > performance_ ) {
          //@log node got new best child
          // swptch parents best child to node
          for(i=0; i<parent._children.length; i++) {
            if(nodes[parent._children[i]]._type == node._type) {
              //@log best child index is now `uint i`
              parent._best_child = i;
              break;
            }
          }
          // propagate
        } else {
          break;
        }
      }
      node = parent;
      parent = nodes[node._parent];
    }
  }

  function __correctBestChildRelationBottom(
    uint8[32] memory _delegations,
    uint[32] memory _votes,
    Node storage node) internal returns( uint _performance ) {
    uint8[32] memory delegations;
    uint[32] memory votes;

    uint8 i;
    for (i=1; i<=numOwners; i++) {
      if ( node.votes[i] != 0 ) {
        votes[i] = node.votes[i];
      } else {
        votes[i] = _votes[i];
      }
      if ( node.delegations[i] != 0 ) {
        delegations[i] = node.delegations[i];
      }
    }

    if( node._type != byte(0xff) ) {
      uint8 bestIndex;
      for (i=0; i<node._children.length; i++) {
        uint tmpPerformance = __correctBestChildRelationBottom(delegations,votes, nodes[node._children[i]]);
        if(tmpPerformance > _performance) {
          bestIndex = i;
          _performance = tmpPerformance;
        }
      }
      if( bestIndex != node._best_child ) {
        node._best_child = bestIndex;
      }
    } else {
      for (i=1; i<=numOwners; i++) {
        if (votes[i] > 0) { // has voted
          _performance += votes[i] * shares[i];
        } else if(delegations[i] > 0) { // delegate has voted
          _performance += votes[delegations[i]] * shares[i];
        }
      }
    }

    return _performance;
  }

  // function vote(bytes candidate, uint vote) returns(bool success) {
  //   //@info --- VOTING
  //   if( !isValide(candidate) ) throw;
  //   if( vote > 1000 ) throw;
  //
  //   // Grab the option set
  //   // update the users votes
  //   // compute the performance
  //   // propagate performance to the root
  //   Node child = nodes[candidate];
  //   bool increase = vote > child.votes[ownerId[msg.sender]];
  //   uint update;
  //   if( increase ) {
  //     update = vote - child.votes[ownerId[msg.sender]];
  //   } else {
  //     update = child.votes[ownerId[msg.sender]] - vote;
  //   }
  //   child.votes[ownerId[msg.sender]] = vote;
  //   child.performance += update;
  //   //@debug updating child `bytes child._id`: `uint update`
  //
  //   for(var i = 0; i < candidate.length; i++) {
  //     // 1. child was top performer
  //     // 1.1 child increased
  //     //  => update parent p.p += update
  //     // 1.2 child decreased
  //     //   ? check if other child has become top (c'.p > )
  //     // 1.2.1 yes => make other child to top
  //     // 1.2.2 no  => update parent p.p += update
  //     // 2. child was not top
  //     // 2.1 child increased
  //     //   ? check if child become top: c.p > p.p?
  //     // 2.1.1 yes => inherit performance from parent p.p = c.p
  //     // 2.1.2 no  => stop
  //     // 2.2 child decreased => stop
  //
  //     Node parent = nodes[child._parent];
  //     if( parent._best_child == child._type ) { // child was top performer
  //       if( increase ) { // 1.1 child increased
  //         //  => update parent p.p += update
  //         parent.performance += update;
  //       } else { // 1.2 child decreased
  //         //   ? check if other child has become top
  //         Node storage best = _findBestPerformingChild(parent);
  //         if( best._type == child._type ) { // 1.2.2 no
  //           // update parent p.p += update
  //           parent.performance -= update;
  //         } else { // 1.2.1 yes
  //           // make other child to top
  //           parent.performance = best.performance;
  //           parent._best_child = best._type;
  //         }
  //       }
  //     } else { // child was not top performer
  //       if( increase ) { // 2.1 child increased
  //         if( child.performance > parent.performance ) { // check if child become top: c.p > p.p?
  //           // 2.1.1 yes => inherit from child p.p = c.p
  //           parent.performance = child.performance;
  //           parent._best_child = child._type;
  //         } else { // 2.1.2 no  => stop
  //           break;
  //         }
  //       } else { // 2.2 child decreased
  //         // stop
  //         break;
  //       }
  //     }
  //     child = parent;
  //     // TODO (1.1, 1.2.1, 1.2.2, 2.1.1) write tests
  //   }
  //   //@log stop at `bytes parent._id`, performance is `uint parent.performance`
  //   // TODO save consens
  // }


  // QUESTION - does this eaven make sence? suppose a really big scenario
  // here one cannot compute everything in the gas limit
  // function _computePerformance( Node storage os ) internal returns(
  //   Node storage bestChild,
  //   uint performance,
  //   byte[32] cs,
  //   uint ci
  // ) {
  //   performance = 0;
  //   byte[32] memory _cs;
  //   uint _ci = 0;
  //   uint i;
  //   if( os._type != byte(0xff) ) { //if the Node has children
  //     uint maxPerformance;
  //     // search for the child with the best performance
  //     for (i =0; i<os.children.length; i++) {
  //       Node c = os.optionFor[os.children[i]];
  //       (,,cs, ci) = _computePerformance (c);
  //       if (c.maxPerformance > maxPerformance ||i == 0) {
  //         bestChild = c;
  //         maxPerformance = c.maxPerformance;
  //         _cs = cs;
  //         _ci = ci;
  //       }
  //     }
  //     _cs[_ci] = os._type;
  //     _ci++;
  //   } else {
  //     for (i=0; i<owners.length; i++) {
  //       // TODO - watch for overflow
  //       performance += shares[owners[i]]*os.votes[owners[i]];
  //     }
  //     bestChild = os;
  //   }
  //   // EXPENSIVE - maybe export to something different?!
  //   if( os.maxPerformance != performance ) {
  //     os.maxPerformance = performance;
  //   }
  //   return (bestChild, performance, _cs, _ci);
  // }


  function getNumChildrenFor(bytes candidate) returns(uint node) {
    return nodes[candidate]._children.length;
  }

  function getChildTypeAt(bytes candidate, uint8 i) returns(byte _type) {
    return nodes[nodes[candidate]._children[i]]._type;
  }

  function getBestChildIndex(bytes candidate) returns(uint8 index){
    return nodes[candidate]._best_child;
  }







  // ORG UTILS
  function _getBestChild( Node storage node ) internal returns(Node storage best) {
    uint performance = 0;
    while ( node._type != byte(0xff) && node._children.length != 0 ) {
      node = nodes[node._children[node._best_child]];
    }
    return node;
  }

  // TODO - maybe here only the memory pointer is passed
  function _getBestChildPerformance ( uint8[32] memory delegations,
                                      uint[32] memory votes, Node node)
                                      internal returns(uint performance) {
    uint8 i;
    while (node._type != byte(0xff) && node._children.length != 0) {
      node = nodes[node._children[node._best_child]];
      for (var j=1; j<=numOwners; j++) { // inherit deligations
        if( node.delegations[j] > 0 ) { // if delegations is set
          delegations[j] = node.delegations[j]; // take
        }
        if( node.votes[j] > 0 ) {
          votes[j] = node.votes[j];
        }
      }
    }
    // TODO - compute transitive hull of delegations
    for (i=1; i<=numOwners; i++) {
      if (votes[i] > 0) { // has voted
        performance += votes[i] * shares[i];
      } else if(delegations[i] > 0) { // delegate has voted
        performance += votes[delegations[i]] * shares[i];
      }
    }
    return performance;
  }

  function _inheritBasis (bytes candidate) internal returns (uint8[32] delegations, uint[32] votes) {
    Node node = nodes[""];
    for (var i=0; i<candidate.length; i++) { // from root to candidate
      node = nodes[__slice(candidate,0,i+1)];
      for (var j=1; j<=numOwners; j++) { // inherit deligations
        if( node.delegations[j] > 0 ) { // if delegations is set
          delegations[j] = node.delegations[j]; // take
        }
        if( node.votes[j] > 0 ) {
          votes[j] = node.votes[j];
        }
      }
    }
    return (delegations, votes);
  }

  // function _findBestPerformingChild( Node _node ) internal returns(Node storage best) {
  //   uint performance= 0;
  //   for (var j=0; j<_node._children.length; j++) {
  //     if(performance < nodes[_node._children[j]].performance) {
  //       performance = nodes[_node._children[j]].performance;
  //       best = nodes[_node._children[j]];
  //     }
  //   }
  //   return best;
  // }


  // UTILS
  function __slice(bytes _in, uint8 from, uint8 to) internal returns(bytes out) {
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
