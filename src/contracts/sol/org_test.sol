import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "org.sol";

contract OrgTester is Test, LangDefinitions, CandidateDefinitions {

  Org org;
  function setUp() {
    org = new Org(l_001);
    org.propose("aaaa","aaaa");
    org.propose("ab","ab");
    // org.vote(c_abf, 200);
  }

  function testSetUp () {
    // terminals:
    // 0x01 - bool
    // 0x02 - uint
    // 0x03 - string256
    // 0xff - reference
    // bytes terminals;
    /* Orga org = new Orga(lang); */
    // org.linkTerminal(0x5f, <orga ref>) // reference all nonatomic terminals - consens of linked orgas has to be a language!!
  }

  function testVote() logs_gas {
    // org = new Org(l_001);
    // org.propose("aaaa","aaaa");
    // org.propose("ab","ab");
    // org.propose("b","b");
    org.vote(c_abf, 200);
    // org.vote(c_bf, 400);
    // byte[32] memory consens = org.getConsens();
    ////@log consens: `byte[32] consens`
  }

  function testCandidatePerformance() logs_gas {
    // org = new Org(l_001);
    uint performance = org.getCandidatePerformance(c_abf);
    //@log performance for candidate abf is `uint performance`
  }

}
