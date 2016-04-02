import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "dapple/reporter.sol";
import "org.sol";

contract OrgAccessorTester is Test, Reporter, LangDefinitions, CandidateDefinitions {

  Org org;
  function setUp() {
    bytes memory entryPoints = new bytes(1);
    entryPoints[0] = byte(01);
    org = new Org(l_001, entryPoints);
    org.propose(bytes32(byte(0x01)), "1101", "aaaa");
    org.propose(bytes32(byte(0x01)), "0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "ab");
    org.propose(bytes32(byte(0x01)), "1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "ab");
    org.propose(bytes32(byte(0x01)), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", "b");
    setupReporter('doc/report.md');
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
    __recLog();
    //@doc }
  }

  function __recLog() internal {
    uint numChildren = org.getNumChildrenFor(candidate);
    bytes memory cand = candidate;
    uint length = candidate.length++;
    uint bestChild = org.getBestChildIndex(candidate);
    for(var i=0; i<numChildren; i++) {
      byte _type = org.getChildTypeAt(cand, i);
      candidate[length] = _type;
      if(i==bestChild) {
        //@doc "`bytes cand`" -> "`bytes candidate`";
      } else {
        //@doc "`bytes cand`" -> "`bytes candidate`" [style=dotted];
      }
      //@doc "`bytes candidate`" [label="`byte _type`"];
      __recLog();
    }
    candidate.length--;
  }

  // function testCandidatePerformance () logs_gas {
  //   // org = new Org(l_001);
  //   // org.vote(c_abf, 200);
  //   org.vote(c_abbf, 200);
  //   uint performance = org.getCandidatePerformance(c_abf);
  //   ////@log performance for candidate abf is `uint performance`
  // }

}
