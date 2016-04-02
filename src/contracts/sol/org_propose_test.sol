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
    bytes memory entryPoints = new bytes(1);
    entryPoints[0] = byte(01);
    Org org = new Org(l_001, entryPoints);
    org.propose(bytes32(byte(0x01)), "1101","aaaa");
    org.propose(bytes32(byte(0x01)), "0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose(bytes32(byte(0x01)), "1aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","ab");
    org.propose(bytes32(byte(0x01)), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","b");
  }


}
