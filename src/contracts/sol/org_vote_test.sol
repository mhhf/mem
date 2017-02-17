import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "dapple/reporter.sol";
import "org.sol";
import "type_def.sol";
import "formatter.sol";

contract OrgVoteDelegationTester is TypeDef, Test, Reporter, LangDefinitions, OrgFormatter {

  Org org;
  Org org2;
  bytes32 c_1101$;
  bytes32 c_0a$;
  bytes32 c_1a;
  bytes32 c_1;
  function setUp() {
    org = new Org(l_001);
    org.propose(bytes32(""), "a1a1a0a1$");
    org.propose(bytes32(""), "a0baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$");
    org.propose(bytes32(""), "a1baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$");
    org.propose(bytes32(""), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb$");

    org2 = new Org(l_004);
    org2.propose(bytes32(""), "pAa0$");
    org2.propose(bytes32(""), "pAa1$");
    org2.propose(bytes32(""), "pAa0a1$");
    org2.propose(bytes32(""), "pBbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$");
    org2.propose(bytes32(""), "pBbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
    org2.propose(bytes32(""), "c00000000000000000000000000000042");

    c_1101$ = org.getChildId("a1a1a0a1$");
    c_0a$ = org.getChildId("a0baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$");
    c_1 = org.getChildId("a1");
    c_1a = org.getChildId("a1baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    // setupReporter('doc/vote.md');
  }

  function testCorrectlyInitiateFirstConsensCandidate() {
    assertTrue(__consensEq(org.getConsens(bytes32("")), c_1101$));
  }

  function testCorrectlySwitchesToNewCandidate() {
    org.vote(c_0a$, 100);
    assertTrue(__consensEq(org.getConsens(bytes32("")), c_0a$));
  }

  function testCorrectlyVotesForMiddleCandidate() {
    org.vote(c_1, 200);
    assertTrue(__consensEq(org.getConsens(bytes32("")), c_1101$));
  }

  function testCorrectlyPropagatesVotesDownTheTree() {
    org.vote(c_1a, 10);
    org.vote(c_1, 200);
    assertTrue(__consensEq(org.getConsens(bytes32("")), c_1101$));
  }

  function testSimpleConsensusConstruction() {
    bytes memory consensus = _constructConsensus(org, "");
    //@log consensus `bytes consensus`
  }

  function testSimpleParrallelVoting() {
    org2.vote(org.getChildId("pAa0a1$"), 200 );
    bytes memory consensus = _constructConsensus(org2, "");
    //@log consensus `bytes consensus`
  }

  function __consensEq(bytes32 a, bytes32 bs) internal returns(bool success){
    success = true;
    for (var i=0; i<32; i++) {
      // halt if end of consens candidate is reached
      if(a[i]==byte(0x00) && i == bs.length) return success;
      success = success && a[i] == bs[i];
      if(!success) return false;
    }
  }

  function _constructConsensus(Org o, bytes32 _id) internal returns (bytes memory _ret){
    byte _type = o.getType(_id);
    uint8 i;
    if (_type == byte("p")) {
      bytes memory tmp = _constructConsensus(o, o.getChildIdAt(_id, 0));
      for(i = 1; i < o.getNumChildrenFor(_id); i++) {
        _ret = __concat(tmp, _constructConsensus(o, o.getChildIdAt(_id, i)));
      }
      return _ret;
    } else if(_type == byte("$")) { // 0 byte -> return
      return "";
    } else if(_type == byte("a")) { // 1 byte
      byte _byte = o.getChildData1(_id);
      bytes memory bytedata = new bytes(1);
      bytedata[0] = _byte;
      _ret = __concat(bytedata, _constructConsensus(o, o.getBestChildId(_id)));
      return _ret;
    } else { //32 bytes
      byte[32] memory _data = o.getChildData32(_id);
      bytes memory data = new bytes(atomBytes[_type]);
      for(i = 0; i < atomBytes[_type]; i++) {
        data[i] = _data[i];
      }
      _ret = __concat(data, _constructConsensus(o, o.getBestChildId(_id)));
      return _ret;
    }
  }

  function __concat(bytes a, bytes b) internal returns(bytes memory c) {
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

}
