import "dapple/test.sol";
import "lang_def.sol";
import "org.sol";
import "formatter.sol";

contract DocLanguages is Test, Reporter, LangDefinitions, OrgFormatter {

  Org org;
  Org org2;
  Org org3;
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

    org3 = new Org(l_005);
    org3.propose(bytes32(""), "(a0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbba0)$");
    org3.propose(bytes32(""), "((a0baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0)bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbba0)$");
    setupReporter('doc/languages.md');
  }

  function testFormatLang1() {
    //@doc ## Org1
    _formatOrg(org);
  }

  function testFormatLang2() {
    //@doc ## Org2
    _formatOrg(org2);
  }

  function testFormatLang3() {
    //@doc ## Org3
    _formatOrg(org3);
  }

}
