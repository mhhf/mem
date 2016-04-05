import "dapple/debug.sol";
import "dapple/test.sol";
import "type_def.sol";




// THIS IS A PROOF  OF CONCEPT
// CURRENTLY THERE ARE LIMITS ON:
// OWNERSHIP SET: max 32 owners allowed
contract Org is TypeDef {

  // Atomic Terminals
  // 0x61 - bool
  // 0x62 - string256
  // 0x63 - uint256
  // 0x70 - paralell voting Type

  // Nonatomic Terminals
  // Has to be explicitly linked
  // 0x40+

  // TODO - a delegation set is List[ Address x Address ]
  //        an optimisation could be refering to addresses
  //        saved in an global ownership table, but what if they change?
  struct Node {
    // sha3(__concat(parent._id, __concat(proofSlice, dataSlice)))
    bytes32 _id;

    bytes _state; // the Nonterminal String, which should be derivated next
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
  mapping (byte => mapping (byte => bytes)) R;
  mapping (byte => bool) accepted; // accepted rules

  // MULTILINIARITY
  // Entry points are a subset of nonterminals of the language
  bytes entryPoints;

  // Gets an byte array where each byte is (N -> t N)
  // i%3=0 is current rule
  // i%3=1 is terminal
  // i%3=2 is next rule
  function Org(bytes grammar) {
    // setup start node
    Node node = nodes[""];
    node._state = "S$";
    node._entry = true;
    node._id = "";

    uint8 internalRule = 0x4f;
    uint8 parallelityContext = 0x71;

    // INITIALIZE orga with 10000 shares
    numOwners = 1;
    owners[1] = msg.sender;
    ownerId[msg.sender] = 1;
    shares[1] = 10000;

    // create start option set:
    uint8 i = 0;
    while (i < grammar.length) {
      uint8 length = uint8(grammar[i++]);
      if( grammar[i+1] == byte("$") ) { // end
        accepted[grammar[i]] = true;
      }
      bytes memory rule = __slice(grammar, i + 1, i + length);
      if (grammar[i+1] == byte("p")) { // parallel Kernel
        R[grammar[i]][grammar[i + 1]] = __toBytes(byte("p"));
      } else {
        R[grammar[i]][grammar[i + 1]] = rule;
      }
      i += length;
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

  // TODO propose happenes always on a start rule/ entry point
  // TODO - test if data has valide length
  function propose(bytes32 _nodeId, bytes data, bytes _proof) {
    // assert atoicity
    // if( !isValide(byte("S"), _proof) ) throw;

    // only the submision of complete words is allowed.
    // here we exend the proof candidate with an end of line symbol
    bytes memory proof = __extend(_proof, 1);
    proof[_proof.length] = byte("$");

    //@log proposing candidate: `bytes proof`
    uint8 dataIndex = 0;

    Node storage parent = nodes[_nodeId];

    bytes memory state = parent._state;
    if(state.length == 0) throw; // node is not available

    // bytes memory _entryPoint = new bytes(1);
    // _entryPoint[0] = entryPoint;

    uint8 i = 0;
    while(state.length > 0) {

      //@log state `string string(state)`
      if(state.length == 0) {
        throw;
      } else if (state.length == 1 && state[0] == byte(0x01) ) { // epsilon
        state = __slice(state, 1, uint8(state.length));
      } else if (byte(0x41) <= state[0] && state[0] <= byte(0x5a)) { // nonterminal
        bytes memory newstate = R[state[0]][proof[i]];
        //@log lookahead is nonterminal -> reduce to `bytes newstate`
        if(newstate.length == 0) throw;
        state = __concat(newstate, __slice(state, 1, uint8(state.length))); // reduce
      } else { // terminal
        //@log lookahead is terminal -> shift


        bytes memory dataSlice = __slice(data, dataIndex, dataIndex + atomBytes[proof[i]]);
        // bytes memory dataHistory = __slice(data, 0, dataIndex + atomBytes[proof[i]]);
        bytes memory proofSlice = __slice(proof, 0, i + 1);
        bytes32 _id = sha3(__concat(parent._id, __concat(proofSlice, dataSlice)));
        //@debug looking at `bytes proofSlice` with `bytes dataSlice` _id: `bytes32 _id`
        Node storage child = nodes[_id];
        // step in the graph based on the lookahead
        // state = __concat(R[state[0]][proof[i]], __slice(state, 1, uint8(state.length)));
        //@log proof: `byte proof[i]`
        //@log state step `bytes state`
        // TODO - test invalide words - should i test here for "$"?
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
        if (state[0] == byte("$")) {
          if (proof[i] != byte("$")) throw;
          break;
        }
        //@log proof state `byte proof[i]` `byte state[0]`
        if (proof[i] == byte("p")) {
          //TODO -test if nonterminal is actually in rule
          state[0] = dataSlice[0];
          //@log state `bytes state`i++
          i++;
        } else if (state.length == 0 || proof[i++] != state[0]) {
          throw;
        } else {
          state = __slice(state, 1, uint8(state.length)); // shift
        }
      }

    }
    //@log newstate `string string(state)`

    // TODO - simplify
    // if(state != byte("$") || accepted[state]) throw; // if word is not in a final state
  }

  // TODO rewrite validation - simplify
  function isValide(bytes proof) returns (bool) {
    // init with start state
    bytes memory state = "S$";

    uint8 i = 0;
    while(state.length > 0) {
      //@log state `string string(state)`
      if(state.length == 0) {
        return false;
      } else if(state[0] == byte("$")) {
        return proof[i] == byte("$");
      } else if (state.length == 1 && state[0] == byte(0x01) ) { // epsilon
        state = __slice(state, 1, uint8(state.length));
      } else if (byte(0x41) <= state[0] && state[0] <= byte(0x5a)) { // nonterminal
        //@log lookahead is nonterminal -> reduce
        bytes memory newstate = R[state[0]][proof[i]];
        if(newstate.length == 0) return false;
        state = __concat(newstate, __slice(state, 1, uint8(state.length))); // reduce
      } else { // terminal
        //@log lookahead is terminal -> shift
        if(proof[i++] != state[0]) return false;
        state = __slice(state, 1, uint8(state.length)); // shift
      }
      //@log newstate `string string(state)`
    }
    //@log endstate `bytes state`
    return i == proof.length;
  }

  function getConsens(bytes32 _nodeId) returns(bytes32 _consens) {
    //@info getting consens
    Node storage node = nodes[_nodeId];
    //@log #children: `uint node._children.length` `bytes32 node._children[0]`
    while ( node._type != byte("$") && node._children.length != 0) {
      node = nodes[node._children[node._best_child]];
    }
    //@log consens `bytes32 node._id`
    return node._id;
  }

  // TODO - the delegation property is not transitive - make this transitive
  function getCandidatePerformance(bytes32 candidate) returns(uint performance) {
    // TODO - check if candidate is in Trie

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

  // TODO - to fucking expensive - play with ways to optimize this
  function vote(bytes32 candidate, uint vote) returns(bool success) {
    if( nodes[candidate]._type == byte(0x00) ) throw;
    if( vote > 1000 ) throw;
    //@info owner `uint ownerId[msg.sender]` voted `uint vote` for `bytes32 candidate`
    Node node = nodes[candidate];
    node.votes[ownerId[msg.sender]] = vote;
    if(node._type != byte("$")) {
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

    if( node._type != byte("$") ) {
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

  function getType(bytes32 _id) returns(byte _type) {
    return nodes[_id]._type;
  }


  function getNumChildrenFor(bytes32 _id) returns(uint8 _length) {
    uint8 length = uint8(nodes[_id]._children.length);
    return length;
  }

  function getChildData1(bytes32 _id) returns(byte data) {
    return nodes[_id].data[0];
  }

  // function getChildDataLength(bytes32 _id) returns(uint length) {
  //
  // }

  // retarded
  function getChildData32(bytes32 _id) returns(byte[32] memory _return) {
    uint8 _length = uint8(nodes[_id].data.length);
    if(_length > 32) _length = 32;
    for(uint8 i = 0; i < _length; i++) {
      _return[i] = nodes[_id].data[i];
    }
  }

  function getChildIdAt(bytes32 _id, uint8 i) returns (bytes32 id) {
    return nodes[_id]._children[i];
  }

  function getChildTypeAt(bytes32 _id, uint8 i) returns(byte _type) {

    // get the node
    Node node = nodes[_id];

    // get node child
    bytes32 child = node._children[i];

    //return the type of the child
    return nodes[child]._type;
  }

  function getBestChildIndex(bytes32 _id) returns(uint8 index){
    return nodes[_id]._best_child;
  }

  function getBestChildId(bytes32 _id) returns(bytes32 id) {
    Node n = nodes[_id];
    return n._children[n._best_child];
  }








  // ORG UTILS
  function _getBestChild( Node storage node ) internal returns(Node storage best) {
    uint performance = 0;
    while ( node._type != byte("$") && node._children.length != 0 ) {
      node = nodes[node._children[node._best_child]];
    }
    return node;
  }

  // TODO - maybe here only the memory pointer is passed
  function _getBestChildPerformance ( uint8[32] memory delegations,
                                      uint[32] memory votes, Node node)
                                      internal returns(uint performance) {
    uint8 i;
    while (node._type != byte("$") && node._children.length != 0) {
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

  function getChildId(bytes data, bytes proof) returns (bytes32 _id){
    _id = bytes32("");
    uint8 dataIndex = 0;
    for(var i = 0; i < proof.length; i++) {
      bytes memory dataSlice = __slice(data, dataIndex, dataIndex + atomBytes[proof[i]]);
      bytes memory proofSlice = __slice(proof, 0, i + 1);
      _id = sha3(__concat(_id, __concat(proofSlice, dataSlice)));
      dataIndex += atomBytes[proof[i]];
    }
    return _id;
  }



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

  function __concat(bytes32 a, bytes memory b) internal returns(bytes memory c) {
    c = new bytes(a.length+b.length);
    uint8 i;
    for (i = 0; i<a.length; i++) {
      c[i] = a[i];
    }
    for (i = 0; i<b.length; i++) {
      c[i + a.length] = b[i];
    }
    return c;
  }

  function __concat(bytes memory a, bytes memory b) internal returns(bytes memory c) {
    c = new bytes(a.length+b.length);
    uint8 i;
    for (i = 0; i<a.length; i++) {
      c[i] = a[i];
    }
    for (i = 0; i<b.length; i++) {
      c[i + a.length] = b[i];
    }
    return c;
  }

  function __toBytes(uint8 what) internal returns (bytes) {
    bytes memory ret = new bytes(1);
    ret[0] = byte(what);
    return ret;
  }
  function __toBytes(byte what) internal returns (bytes) {
    bytes memory ret = new bytes(1);
    ret[0] = what;
    return ret;
  }

}
