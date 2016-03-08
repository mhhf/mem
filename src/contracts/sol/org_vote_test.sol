import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "dapple/reporter.sol";
import "org.sol";

contract OrgVoteDelegationTester is Test, Reporter, LangDefinitions, CandidateDefinitions {

  Org org;
  function setUp() {
    org = new Org(l_001);
    org.propose("aba","aba");
    org.propose("abb","abb");
    org.propose("aab","aab");
    org.propose("aaaa","aaaa");
    setupReporter('doc/report.md');
  }

  function testCorrectlyInitiateFirstConsensCandidate() {
    assertTrue(__consensEq(org.getConsens(), c_abaf));
  }

  function testCorrectlySwitchesToNewTestCandidate() {
    org.vote(c_abbf, 100);
    // assertTrue(__consensEq(org.getConsens(), c_abbf));
  }

  function testCorrectlyVotesForMiddleCandidate() {
    org.vote("aa", 200);
    assertTrue(__consensEq(org.getConsens(), c_aabf));
  }

  function testCorrectlyPropagatesVotesDownTheTree() logs_gas {
    org.vote("aab", 10);
    org.vote("aa", 200);
    byte[32] memory consens = org.getConsens();
    assertTrue(__consensEq(org.getConsens(), c_aaaaf));
  }

  function __consensEq(byte[32] a, bytes bs) internal returns(bool success){
    success = true;
    for (var i=0; i<32; i++) {
      // halt if end of consens candidate is reached
      if(a[i]==byte(0x00) && i == bs.length) return success;
      success = success && a[i] == bs[i];
      if(!success) return false;
    }
  }

}
