import "dapple/test.sol";
import "lang_def.sol";
import "cand_def.sol";
import "org.sol";

contract OrgProposeTester is Test, LangDefinitions {

  // Org org;
  function setUp() {
    // org = new Org(l_001);
  }

  function testSimplePropose() {
    Org org = new Org(l_001);
    org.propose(bytes32(""), "a1a1a0a1");
    org.propose(bytes32(""), "a0baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    org.propose(bytes32(""), "a1baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    org.propose(bytes32(""), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
  }

  function testParallelKernel() {
    Org org = new Org(l_004);
    org.propose(bytes32(""), "pAa0$");
    org.propose(bytes32(""), "pAa1$");
    org.propose(bytes32(""), "pAa0a1$");
    org.propose(bytes32(""), "pBbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$");
    org.propose(bytes32(""), "pBbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb$");
    org.propose(bytes32(""), "c00000000000000000000000000000042$");
  }

  function testNestedParallelKernel() {
    Org org = new Org(l_006);
    org.propose(bytes32(""), "pAa0pAa1c00000000000000000000000000000001$");
  }

}
