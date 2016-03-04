import "dapple/test.sol";
import "org.sol";

contract LangTester is Test {
  bytes lang1;

  Org org;
  function setUp() {
    lang1 = new bytes(6); // language
    lang1[0] = byte(0x01);
    lang1[1] = byte(0x61);
    lang1[2] = byte(0x01);
    lang1[3] = byte(0x01);
    lang1[4] = byte(0xff);
    lang1[5] = byte(0xff);
    org = new Org(lang1);
    org.propose("aaaa","aaaa");
    org.propose("a","a");
    org.propose("aa","aa");
  }

  function testSetUp () {

    Org org = new Org(lang1);

    // terminals:
    // 0x01 - bool
    // 0x02 - uint
    // 0x03 - string256
    // 0xff - reference
    // bytes terminals;
    /* Orga org = new Orga(lang); */
    // org.linkTerminal(0x5f, <orga ref>) // reference all nonatomic terminals - consens of linked orgas has to be a language!!
  }

  // function testValidation() {
  //   Org org = new Org(lang1);
  //   assertTrue(org.isValide("a"));
  //   assertTrue(org.isValide("aaa"));
  //   assertFalse(org.isValide("aab"));
  //   assertFalse(org.isValide("b"));
  // }
  //
  // function testPropose() {
  //   Org org = new Org(lang1);
  //   org.propose("aaa","aaa");
  //   org.propose("aaaa","aaaa");
  //   byte[32] memory consens = org.getConsens();
  //   //@log consens: `byte[32] consens`
  // }

  function testProposeNew() logs_gas() {
    byte[32] memory consens = org.getNewConsens();
    //@log consens: `byte[32] consens`
  }

  function testVote() {
  }
}