import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "dapple/reporter.sol";
import "type_def.sol";
import "org.sol";
import "formatter.sol";

contract OrgAccessorTester is TypeDef, Test, Reporter, LangDefinitions, OrgFormatter {

  Org org;
  Org org2;
  function setUp() {
    org = new Org(l_001);
    org.propose(bytes32(""), "a1a1a0a1");
    org.propose(bytes32(""), "a0baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    org.propose(bytes32(""), "a1baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    org.propose(bytes32(""), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");

    org2 = new Org(l_004);
    org2.propose(bytes32(""), "pAa0$");
    org2.propose(bytes32(""), "pAa1$");
    org2.propose(bytes32(""), "pAa0a1$");
    org2.propose(bytes32(""), "pBbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$");
    org2.propose(bytes32(""), "pBbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
    org2.propose(bytes32(""), "c00000000000000000000000000000042");
    // org2.propose(bytes32(""), "00000000000000000000000000000042","c$");
    setupReporter('doc/report.md');
  }

  function testCandidateAccessors() {
    assertTrue(org.getChildId("a1a1a0a1$")[0] == byte(0x01));
    assertTrue(org.getChildId("a1")[0] == byte(0xb7));
    assertTrue(org.getChildId("a1a1")[0] == byte(0x3d));
    assertTrue(org2.getChildId("pA")[0] == byte(0xff));
    assertTrue(org2.getChildId("pAa0")[0] == byte(0x8b));
    assertTrue(org2.getChildId("pAa0$")[0] == byte(0x8b));
  }

  // function testGetNumChildren() {
  //   uint numChildren = org.getNumChildrenFor(c_1);
  //   assertEq(2, numChildren);
  // }
  //
  // function testGetChildTypeAt() {
  //   byte _type = org.getChildTypeAt(c_1, 1);
  //   assertTrue(_type == byte(0x62));
  // }
  
  function testOrg2() {
    //@doc ## Describing org
    _formatOrg(org2);
  }

  // function testCandidatePerformance () logs_gas {
  //   // org = new Org(l_001);
  //   // org.vote(c_abf, 200);
  //   org.vote(c_abbf, 200);
  //   uint performance = org.getCandidatePerformance(c_abf);
  //   ////@log performance for candidate abf is `uint performance`
  // }

}
