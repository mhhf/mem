import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "dapple/reporter.sol";
import "org.sol";
import "type_def.sol";

contract OrgVoteDelegationTester is TypeDef, Test, Reporter, LangDefinitions {

  Org org;
  Org org2;
  bytes32 c_1101$;
  bytes32 c_0a$;
  bytes32 c_1a;
  bytes32 c_1;
  function setUp() {
    org = new Org(l_001);
    org.propose(bytes32(""), "1101","aaaa$");
    org.propose(bytes32(""), "0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab$");
    org.propose(bytes32(""), "1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab$");
    org.propose(bytes32(""), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","b$");

    org2 = new Org(l_004);
    org2.propose(bytes32(""), "0","pqa$");
    org2.propose(bytes32(""), "1","pqa$");
    org2.propose(bytes32(""), "01","pqaa$");
    org2.propose(bytes32(""), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","prb$");
    org2.propose(bytes32(""), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","prbb");
    org2.propose(bytes32(""), "00000000000000000000000000000042","c");

    c_1101$ = org.getChildId("1101","aaaa$");
    c_0a$ = org.getChildId("0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab$");
    c_1 = org.getChildId("1","a$");
    c_1a = org.getChildId("1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab$");
    // setupReporter('doc/report.md');
  }

  // function testCorrectlyInitiateFirstConsensCandidate() {
  //   assertTrue(__consensEq(org.getConsens(bytes32("")), c_1101$));
  // }
  //
  // function testCorrectlySwitchesToNewTestCandidate() {
  //   org.vote(c_0a$, 100);
  //   assertTrue(__consensEq(org.getConsens(bytes32("")), c_0a$));
  // }
  //
  // function testCorrectlyVotesForMiddleCandidate() {
  //   org.vote(c_1, 200);
  //   assertTrue(__consensEq(org.getConsens(bytes32("")), c_1101$));
  // }
  //
  // function testCorrectlyPropagatesVotesDownTheTree() {
  //   org.vote(c_1a, 10);
  //   org.vote(c_1, 200);
  //   assertTrue(__consensEq(org.getConsens(bytes32("")), c_1101$));
  // }

  // function testSimpleGetParallelConsensus() {
  //   org2.propose(bytes32(""), "0","pAa");
  //   org2.propose(bytes32(""), "1","pAa");
  //   org2.propose(bytes32(""), "01","pAaa");
  //   org2.propose(bytes32(""), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","pBb");
  //   org2.propose(bytes32(""), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","pBbb");
  //   org2.propose(bytes32(""), "00000000000000000000000000000042","c");
  //   org2.getConsens(bytes32(""));
  // }

  function testSimpleConsensusConstruction() {
    bytes memory consensus = _constructConsensus(org, "");
    //@log consensus `bytes consensus`
  }

  function testSimpleParrallelVoting() {
    org2.vote(org.getChildId("01","pqaa$"), 200 );
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
