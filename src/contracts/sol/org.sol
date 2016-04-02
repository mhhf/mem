import "dapple/debug.sol";
import "dapple/test.sol";




// THIS IS A PROOF  OF CONCEPT
// CURRENTLY THERE ARE LIMITS ON:
// OWNERSHIP SET: max 32 owners allowed
contract Org is Test {

  // Atomic Terminals
  // 0x61 - bool
  // 0x62 - string256
  // 0x63 - uint256

  // Nonatomic Terminals
  // Has to be explicitly linked
  // 0x40+

  // TODO - a delegation set is List[ Address x Address ]
  //        an optimisation could be refering to addresses
  //        saved in an global ownership table, but what if they change?
  struct Node {
    // sha3(__concat(parent._id, __concat(proofSlice, dataSlice)))
    bytes32 _id;

    byte _state; // the current state in the language graph
    byte _type; // last read terminal - the data type
    bytes data;

    bytes32 _parent; // link to parent node
    bytes32[] _children; // links to all children
    uint8 _best_child; // index of best performing child - only needed for runtime optimisation (reduce complexity)
    bool _entry; // bool, which indecates if this node is an entry node (node of the metalinarity level)

    // TODO - verify if this still holds
    // delegation is a set with d.length % 2 == 0
    // i   = owner._id
    // i+1 = vote ammount
    uint8[32] delegations;

    // Votes is a array. The index of an array represents an owner and
    // the value of the array represents its votes:
    // OwnerId => Vote
    uint[32] votes;
  }

  // Set of possible types
  mapping (byte => uint8) atomBytes;

  // notes in the trie
  ///@dev bytes32 - nodeId's: 
  // sha3(__concat(parent._id, __concat(proofSlice, dataSlice)))
  mapping (bytes32 => Node) nodes;

  // OWNERS
  mapping (uint8 => address) owners;
  mapping (address => uint8) ownerId;
  uint8 public numOwners;

  // SHARES
  mapping (uint8 => uint) public shares;

  // DIRECTED GRAPH
  // Organisation Language
  mapping (byte => mapping (byte => byte)) R;
  mapping (byte => bool) accepted; // accepted rules

  // MULTILINIARITY
  // Entry points are a subset of nonterminals of the language
  bytes entryPoints;

  // Gets an byte array where each byte is (N -> t N)
  // i%3=0 is current rule
  // i%3=1 is terminal
  // i%3=2 is next rule
  function Org(bytes grammar, bytes _entryPoints) {
    // grammar has to be in right linear form
    // if( grammar.length % 3 != 0 )
    //   throw;

    // setup entry points
    entryPoints = _entryPoints;
    for (var j = 0; j < entryPoints.length; j++) {
      Node node = nodes[bytes32(entryPoints[j])];
      node._state = entryPoints[j];
      node._entry = true;
      node._id = bytes32(entryPoints[j]);
      //@log created `bytes32 node._id`
    }

    // INITIALIZE orga with 10000 shares
    numOwners = 1;
    owners[1] = msg.sender;
    ownerId[msg.sender] = 1;
    shares[1] = 10000;

    // create start option set:
    uint8 i = 0;
    while (i < grammar.length) {
      uint8 length = uint8(grammar[i++]);
      if( grammar[i+1] == byte(0xff) ) { // end
        accepted[grammar[i]] = true;
      }
      R[grammar[i]][grammar[i+1]]=grammar[i+2];
      i += length;
    }

    atomBytes[byte(0x61)] = 1;  // bool
    atomBytes[byte(0x62)] = 32; // bytes256
    atomBytes[byte(0x63)] = 32; // uint256
    atomBytes[byte(0xff)] = 0;  // bottom ($)
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

  // TODO propose happenes always on a start rule/ entry point
  // TODO - test if data has valide length
  function propose(bytes32 _nodeId, bytes data, bytes _proof) {
    // assert atoicity
    // if( !isValide(byte(0x01), _proof) ) throw;

    // only the submision of complete words is allowed.
    // here we exend the proof candidate with an end of line symbol
    bytes memory proof = __extend(_proof, 1);
    proof[_proof.length] = byte(0xff);

    //@log proposing candidate: `bytes proof`
    uint8 dataIndex = 0;

    Node storage parent = nodes[_nodeId];

    byte state = parent._state;
    if(state == byte(0x00)) throw; // node is not available

    // bytes memory _entryPoint = new bytes(1);
    // _entryPoint[0] = entryPoint;



    for (var i=0; i<proof.length; i++) {
      bytes memory dataSlice = __slice(data, dataIndex, dataIndex + atomBytes[proof[i]]);
      bytes memory dataHistory = __slice(data, 0, dataIndex + atomBytes[proof[i]]);
      bytes memory proofSlice = __slice(proof, 0, i+1);
      bytes32 _id = sha3(__concat(parent._id, __concat(proofSlice, dataSlice)));
      //@debug looking at `bytes proofSlice` with `bytes dataSlice` _id: `bytes32 _id`
      Node storage child = nodes[_id];
      // step in the graph based on the lookahead
      state = R[state][proof[i]];
      //@log state step `byte state`
      if(state == byte(0x00)) throw;
      // TODO - test invalide words - should i test here for 0xff?
      if( child._type == byte(0x00) ) {
        //@log not in trie `bytes32 _id`
        child._id = _id;
        child.data = dataSlice;
        //@log `bytes32 parent._id`
        child._parent = parent._id;
        child._type = proof [i];
        child._state = state;
        parent._children.push (_id);
      }
      dataIndex += atomBytes[proof[i]];
      parent = child;
    }
    // TODO - simplify
    if(state != byte(0xff) || accepted[state]) throw; // if word is not in a final state
  }

  // TODO rewrite validation - simplify
  function isValide(byte _entry, bytes word) returns (bool) {
    byte rule = _entry;
    for (var i = 0; i < word.length; i++) {
      rule = R[rule][word[i]];
      if (rule == byte(0xff))
        return true;
      if (rule == byte(0x00) && i < word.length - 1)
        return false;
    }
    return ((rule == byte(0xff)) || (accepted[rule]));
  }

  function getConsens(bytes32 _nodeId) returns(bytes32 _consens) {
    //@info getting consens
    Node storage node = nodes[_nodeId];
    //@log #children: `uint node._children.length` `bytes32 node._children[0]`
    while ( node._type != byte(0xff) && node._children.length != 0) {
      node = nodes[node._children[node._best_child]];
    }
    //@log consens `bytes32 node._id`
    return node._id;
  }

  // TODO - the delegation property is not transitive - make this transitive
  function getCandidatePerformance(bytes32 candidate) returns(uint performance) {
    // TODO - check if candidate is in Trie

    // var (delegations, votes) = _inheritBasis (candidate);
    // Node best = _getBestChild(nodes[candidate]);
    // return _getBestChildPerformance( delegations, votes, nodes[candidate] );

    //
    // BUILD DELIGATION SET
    uint8 i;
    var (delegations, votes) = _inheritBasis(candidate);
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
  function vote(bytes32 candidate, uint vote) returns(bool success) {
    if( nodes[candidate]._type == byte(0x00) ) throw;
    if( vote > 1000 ) throw;
    //@info owner `uint ownerId[msg.sender]` voted `uint vote` for `bytes32 candidate`
    Node node = nodes[candidate];
    node.votes[ownerId[msg.sender]] = vote;
    if(node._type != byte(0xff)) {
      var (delegations, votes) = _inheritBasis(node._id);
      __correctBestChildRelationBottom(delegations, votes, node);
    }
    __correctBestChildRelation(node);
  }

  function delegate(address to, bytes32 context) returns(bool success) {
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

    while (!node._entry) {
      (delegations, votes) = _inheritBasis(node._id);
      performance = _getBestChildPerformance (delegations, votes, node);
      //@log performance of node `bytes32 node._id` is `uint performance`
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
          //@log node got new best child out of `uint parent._children.length` children
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


  function getNumChildrenFor(bytes32 candidate) returns(uint node) {
    return nodes[candidate]._children.length;
  }

  ///@dev 
  function getChildTypeAt(bytes32 candidate, uint8 i) returns(byte _type) {

    // get the node
    Node node = nodes[candidate];

    // get node child
    bytes32 child = node._children[i];

    //return the type of the child
    return nodes[child]._type;
  }

  function getBestChildIndex(bytes32 candidate) returns(uint8 index){
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

  function _inheritBasis (bytes32 candidate) internal returns (uint8[32] delegations, uint[32] votes) {
    Node node = nodes[candidate];
    while( node._id != "" ) {
      for (var i=1; i<=numOwners; i++) { // inherit deligations
        if( delegations[i] == 0 && node.delegations[i] > 0 ) { // if delegations is set
          delegations[i] = node.delegations[i]; // take
        }
        if( votes[i] == 0 && node.votes[i] > 0 ) {
          votes[i] = node.votes[i];
        }
      }
      node = nodes[node._parent];
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

  function __concat(bytes32 a, bytes b) internal returns(bytes c) {
    c = new bytes(a.length+b.length);
    uint8 i;
    for (i; i<a.length; i++) {
      c[i] = a[i];
    }
    for (i; i<b.length; i++) {
      c[i + a.length] = b[i];
    }
    return c;
  }

  function __concat(bytes a, bytes b) internal returns(bytes c) {
    c = new bytes(a.length+b.length);
    uint8 i;
    for (i; i<a.length; i++) {
      c[i] = a[i];
    }
    for (i; i<b.length; i++) {
      c[i + a.length] = b[i];
    }
    return c;
  }

}
