import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "dapple/reporter.sol";
import "org.sol";

contract OrgVoteDelegationTester is Test, Reporter, LangDefinitions {

  Org org;
  Org org2;
  bytes32 c_1101$;
  bytes32 c_0a$;
  bytes32 c_1a;
  bytes32 c_1;
  function setUp() {
    org = new Org(l_001);
    org.propose(bytes32(""), "1101","aaaa");
    org.propose(bytes32(""), "0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose(bytes32(""), "1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose(bytes32(""), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","b");

    org2 = new Org(l_004);
    // org2.propose(bytes32(""), "0","pAa");
    // org2.propose(bytes32(""), "1","pAa");
    // org2.propose(bytes32(""), "01","pAaa");
    // org2.propose(bytes32(""), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","pBb");
    // org2.propose(bytes32(""), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","pBbb");
    // org2.propose(bytes32(""), "00000000000000000000000000000042","c");

    c_1101$ = org.getChildId("1101","aaaa$");
    c_0a$ = org.getChildId("0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab$");
    c_1 = org.getChildId("1","a");
    c_1a = org.getChildId("1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
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

  function testSimpleGetParallelConsensus() {
    org2.propose(bytes32(""), "0","pAa");
    org2.propose(bytes32(""), "1","pAa");
    org2.propose(bytes32(""), "01","pAaa");
    org2.propose(bytes32(""), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","pBb");
    org2.propose(bytes32(""), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","pBbb");
    org2.propose(bytes32(""), "00000000000000000000000000000042","c");
    org2.getConsens(bytes32(""));
  }

  function testSimpleParrallelVoting() {
    // org2.vote(org.getChildId("0","pAa"), 200 );
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


}
