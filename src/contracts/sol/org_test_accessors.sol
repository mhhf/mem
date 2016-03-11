import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "dapple/reporter.sol";
import "org.sol";

contract OrgAccessorTester is Test, Reporter, LangDefinitions, CandidateDefinitions {

  Org org;
  function setUp() {
    org = new Org(l_001);
    // org.propose("1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","abb");
    // org.propose("aba","aba");
    // org.propose("aaaa","aaaa");
    // org.propose("aab","aab");
    setupReporter('doc/report.md');
  }

  function testGetNumChildren() {
    uint numChildren = org.getNumChildrenFor("ab");
    assertEq(2,numChildren);
  }

  function testGetChildTypeAt() {
    byte _type = org.getChildTypeAt("ab", 1);
    //@doc Tree:
  }

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
  //   bytes memory cand = candidate;
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

  function testVote () logs_gas {
    // org = new Org(l_001);
    // org.propose("aaaa","aaaa");
    // org.propose("ab","ab");
    // org.propose("b","b");
    // org.vote(c_abbabaaaf, 200);
    // org.getNode(c_abbf);
    // org.vote(c_bf, 400);
    // byte[32] memory consens = org._getConsens();
    ////@log consens: `byte[32] consens`
  }

  function testCandidatePerformance () logs_gas {
    // org = new Org(l_001);
    // org.vote(c_abf, 200);
    org.vote(c_abbf, 200);
    uint performance = org.getCandidatePerformance(c_abf);
    ////@log performance for candidate abf is `uint performance`
  }

}
