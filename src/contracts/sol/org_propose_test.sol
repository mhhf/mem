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
    org.propose("1101","aaaa");
    org.propose("0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose("1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","b");
  }


}
