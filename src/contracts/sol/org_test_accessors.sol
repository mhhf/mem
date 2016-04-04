import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "dapple/reporter.sol";
import "org.sol";

contract OrgAccessorTester is Test, Reporter, LangDefinitions {

  Org org;
  Org org2;
  function setUp() {
    org = new Org(l_001);
    org.propose(bytes32(""), "1101", "aaaa$");
    org.propose(bytes32(""), "0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "ab$");
    org.propose(bytes32(""), "1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "ab$");
    org.propose(bytes32(""), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", "b$");

    org2 = new Org(l_004);
    org2.propose(bytes32(""), "0","pqa$");
    org2.propose(bytes32(""), "1","pqa$");
    org2.propose(bytes32(""), "01","pqaa$");
    org2.propose(bytes32(""), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","prb$");
    org2.propose(bytes32(""), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","prbb");
    org2.propose(bytes32(""), "00000000000000000000000000000042","c");
    // setupReporter('doc/report.md');
  }

  function testCandidateAccessors() {
    org2 = new Org(l_004);
    org2.propose(bytes32(""), "0","pqa$");
    assertTrue(org.getChildId("1101","aaaa$")[0] == byte(0x01));
    assertTrue(org.getChildId("1","a")[0] == byte(0xb7));
    assertTrue(org.getChildId("11","aa")[0] == byte(0x3d));
    assertTrue(org2.getChildId("","p")[0] == byte(0xa6));
    assertTrue(org2.getChildId("","pq")[0] == byte(0x3f));
    assertTrue(org2.getChildId("0","pqa")[0] == byte(0xdb));
    // assertTrue(org2.getChildId("0","pqa$")[0] == byte(0xdb));
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

  bytes32 candidate;
  function testLog() wrapCode('dot') {
    candidate = "";
    //@doc digraph A {
    //@doc omg
    // __recLog();
    //@doc }
  }

  // function __recLog() internal {
  //   uint numChildren = org.getNumChildrenFor(candidate);
  //   bytes32 memory cand = candidate;
  //   uint length = candidate.length++;
  //   uint bestChild = org.getBestChildIndex(candidate);
  //   for(var i=0; i<numChildren; i++) {
  //     byte _type = org.getChildTypeAt(cand, i);
  //     candidate[length] = _type;
  //     if(i==bestChild) {
  //       //@doc "`bytes cand`" -> "`bytes candidate`";
  //     } else {
  //       //@doc "`bytes cand`" -> "`bytes candidate`" [style=dotted];
  //     }
  //     //@doc "`bytes candidate`" [label="`byte _type`"];
  //     __recLog();
  //   }
  //   candidate.length--;
  // }

  // function testCandidatePerformance () logs_gas {
  //   // org = new Org(l_001);
  //   // org.vote(c_abf, 200);
  //   org.vote(c_abbf, 200);
  //   uint performance = org.getCandidatePerformance(c_abf);
  //   ////@log performance for candidate abf is `uint performance`
  // }

}
