import "dapple/test.sol";
import "lang_def.sol";
import "cand_def.sol";
import "org.sol";

contract OrgProposeTester is Test, LangDefinitions, CandidateDefinitions {

  Org org;
  function setUp() {
    org = new Org(l_001);
  }

  function testSimplePropose() {
    org.propose("aaaa","aaaa");
    org.propose("ab","ab");
    org.propose("b","b");
  }


}
