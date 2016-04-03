import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "dapple/reporter.sol";
import "org.sol";

contract OrgVoteDelegationTester is Test, Reporter, LangDefinitions, CandidateDefinitions {

  Org org;
  function setUp() {
    org = new Org(l_001);
    org.propose(bytes32(""), "1101","aaaa");
    org.propose(bytes32(""), "0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose(bytes32(""), "1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose(bytes32(""), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","b");
    // setupReporter('doc/report.md');
  }

  function testCorrectlyInitiateFirstConsensCandidate() {
    org = new Org(l_001);
    org.propose(bytes32(""), "1101","aaaa");
    org.propose(bytes32(""), "0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose(bytes32(""), "1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose(bytes32(""), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","b");
    assertTrue(__consensEq(org.getConsens(bytes32("")), org.getChildId("1101","aaaa")));
  }

  function testCorrectlySwitchesToNewTestCandidate() {
    org.vote(c_0af, 100);
    assertTrue(__consensEq(org.getConsens(bytes32("")), c_0af));
  }

  function testCorrectlyVotesForMiddleCandidate() {
    org.vote(c_1, 200);
    assertTrue(__consensEq(org.getConsens(bytes32("")), c_1101f));
  }

  function testCorrectlyPropagatesVotesDownTheTree() logs_gas {
    org.vote(c_1a, 10);
    org.vote(c_1, 200);
    assertTrue(__consensEq(org.getConsens(bytes32("")), c_1101f));
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
