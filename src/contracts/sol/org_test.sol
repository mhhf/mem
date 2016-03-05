import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "org.sol";

contract OrgTester is Test, LangDefinitions, CandidateDefinitions {

  Org org;
  function setUp() {
    org = new Org(l_001);
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

  // function testPropose() logs_gas() {
  //   Org org = new Org(lang1);
  //   org.propose("aaaa","aaaa");
  //   // org.propose("aaaa","aaaa");
  //   // byte[32] memory consens = org.getConsens();
  //   // // @log consens: `byte[32] consens`
  // }

  function testVote() {
    bytes memory cand = new bytes(3);
    cand[0] = byte(0x61);
    cand[1] = byte(0x62);
    cand[2] = byte(0xff);
    bytes memory cand2 = new bytes(2);
    cand2[0] = byte(0x62);
    cand2[1] = byte(0xff);
    org = new Org(l_001);
    org.propose("aaaa","aaaa");
    org.propose("ab","ab");
    org.propose("b","b");
    org.vote(cand, 200);
    org.vote(cand2, 400);
    byte[32] memory consens = org.getConsens();
    //@log consens: `byte[32] consens`
  }

}
