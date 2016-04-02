import "dapple/test.sol";
import "org.sol";
import "lang_def.sol";
import "cand_def.sol";

// TODO - test metalinearity
contract LangTester is Test, LangDefinitions, CandidateDefinitions {

  // Language tests
  // 001 - (a|b)*
  // 002 - a*b*
  // 003 - a+b*

  function setUp () {
  }

  // test start rule is final
  function testStartRuleIsFinal() {
    bytes memory entryPoints = new bytes(1);
    entryPoints[0] = byte(01);
    Org org = new Org(l_001, entryPoints);
    assertTrue(org.isValide(byte(0x01), ""));
    assertTrue(org.isValide(byte(0x01), "a"));
    assertTrue(org.isValide(byte(0x01), "b"));
    assertTrue(org.isValide(byte(0x01), "abab"));
    Org org2 = new Org(l_002, entryPoints);
    assertTrue(org2.isValide(byte(0x01), ""));
    assertTrue(org2.isValide(byte(0x01), "a"));
    assertTrue(org2.isValide(byte(0x01), "b"));
    assertTrue(org2.isValide(byte(0x01), "aaabb"));
  }

  function renderCandidates() {
    
  }


  // function testCandidatesWithEndMark() {
  //   Org org = new Org(l_001);
  //   assertTrue(org.isValide(c_aff));
  //   assertTrue(org.isValide(c_bf));
  //   assertFalse(org.isValide(c_cf));
  // }

  // test start rule is not final
  function testStartRuleIsNotFinal() {
    bytes memory entryPoints = new bytes(1);
    entryPoints[0] = byte(01);
    Org org = new Org(l_003, entryPoints);
    assertTrue(org.isValide(byte(0x01), "a"));
    assertTrue(org.isValide(byte(0x01), "aab"));
    assertFalse(org.isValide(byte(0x01), "b"));
    assertFalse(org.isValide(byte(0x01), ""));
    assertFalse(org.isValide(byte(0x01), "ac"));
  }

}
