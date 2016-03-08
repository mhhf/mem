import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "dapple/reporter.sol";
import "org.sol";

contract OrgVoteDelegationTester is Test, Reporter, LangDefinitions, CandidateDefinitions {

  Org org;
  function setUp() {
    org = new Org(l_001);
    org.propose("1101","aaaa");
    org.propose("0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose("1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","b");
    setupReporter('doc/report.md');
  }

  function testCorrectlyInitiateFirstConsensCandidate() {
    assertTrue(__consensEq(org.getConsens(), c_1101));
  }

  function testCorrectlySwitchesToNewTestCandidate() {
    org.vote(c_0a, 100);
    assertTrue(__consensEq(org.getConsens(), c_0a));
  }

  function testCorrectlyVotesForMiddleCandidate() {
    org.vote(c_1, 200);
    assertTrue(__consensEq(org.getConsens(), c_1101));
  }

  function testCorrectlyPropagatesVotesDownTheTree() logs_gas {
    org.vote(c_1a, 10);
    org.vote(c_1, 200);
    assertTrue(__consensEq(org.getConsens(), c_1101));
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
