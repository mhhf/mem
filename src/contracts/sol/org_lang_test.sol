import "dapple/test.sol";
import "org.sol";
import "lang_def.sol";
import "cand_def.sol";

// TODO - test metalinearity
contract LangTester is Test, LangDefinitions {

  // Language tests
  // 001 - (a|b)*
  // 002 - a*b*
  // 003 - a+b*
  //
  // function setUp () {
  // }

  function testOrgCreation() {
    Org org = new Org(l_001);
  }

  // test start rule is final
  // function testStartRuleIsFinal() {
  //   Org org = new Org(l_001);
  //   assertTrue(org.isValide("$"));
  //   assertTrue(org.isValide("a0$"));
  //   assertTrue(org.isValide("baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$"));
  //   assertTrue(org.isValide("a0baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$"));
  //   Org org2 = new Org(l_002);
  //   assertTrue(org2.isValide("$"));
  //   assertTrue(org2.isValide("a0$"));
  //   assertTrue(org2.isValide("baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$"));
  //   assertTrue(org2.isValide("a0a0a0baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$"));
  // }
  //
  // // test start rule is not final
  // function testStartRuleIsNotFinal() {
  //   Org org = new Org(l_003);
  //   assertTrue(org.isValide("a1$"));
  //   assertTrue(org.isValide("a1a1baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$"));
  //   assertFalse(org.isValide("baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$"));
  //   assertFalse(org.isValide("$"));
  //   assertFalse(org.isValide("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaac00000000000000000000000000000001$"));
  // }
  //
  // function testParallelity() {
  //   Org org = new Org(l_004);
  // }

  LL1.ParseTable table;
  function testNestedParallelity() {
    // Org org = new Org(l_006);
    LL1.setup(table, l_006);
    assertTrue(LL1.isValide(table, "p0a0p0a1c00000000000000000000000000000001$"));
  }

  // function testDeployCfg() logs_gas {
  //   Org org = new Org(l_005);
  //   assertTrue(org.isValide("(a0baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0)$"));
  // }



}
