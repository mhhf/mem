import "dapple/test.sol";
import "lang_def.sol";
import "cand_def.sol";
import "org.sol";

contract OrgProposeTester is Test, LangDefinitions, CandidateDefinitions {

  // Org org;
  function setUp() {
    // org = new Org(l_001);
  }

  function testSimplePropose() {
    Org org = new Org(l_001);
    org.propose(bytes32(""), "1101","aaaa");
    org.propose(bytes32(""), "0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose(bytes32(""), "1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose(bytes32(""), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","b");
  }

  function testParallelKernel() {
    Org org = new Org(l_004);
    org.propose(bytes32(""), "A0","pa$");
    org.propose(bytes32(""), "A1","pa$");
    org.propose(bytes32(""), "A01","paa$");
    org.propose(bytes32(""), "Baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","pb$");
    org.propose(bytes32(""), "Baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","pbb$");
    org.propose(bytes32(""), "00000000000000000000000000000042","c$");
  }

}
