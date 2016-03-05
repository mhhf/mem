import "dapple/test.sol";
import "org.sol";
import "lang_def.sol";
import "cand_def.sol";

contract LangTester is Test, LangDefinitions, CandidateDefinitions {

  // Language tests
  // 001 - (a|b)*
  // 002 - a*b*
  // 003 - a+b*

  function setUp () {
  }

  // test start rule is final
  function testStartRuleIsFinal() {
    Org org = new Org(l_001);
    assertTrue(org.isValide(""));
    assertTrue(org.isValide("a"));
    assertTrue(org.isValide("b"));
    assertTrue(org.isValide("abab"));
    Org org2 = new Org(l_002);
    assertTrue(org2.isValide(""));
    assertTrue(org2.isValide("a"));
    assertTrue(org2.isValide("b"));
    assertTrue(org2.isValide("aaabb"));
  }

  function testCandidatesWithEndMark() {
    Org org = new Org(l_001);
    assertTrue(org.isValide(c_aff));
    assertTrue(org.isValide(c_bf));
    assertFalse(org.isValide(c_cf));
  }

  // test start rule is not final
  function testStartRuleIsNotFinal() {
    Org org = new Org(l_003);
    assertTrue(org.isValide("a"));
    assertTrue(org.isValide("aab"));
    assertFalse(org.isValide("b"));
    assertFalse(org.isValide(""));
    assertFalse(org.isValide("ac"));
  }

}
