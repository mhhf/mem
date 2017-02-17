import "lang_def.sol";
import "cand_def.sol";
import "dapple/test.sol";
import "dapple/reporter.sol";
import "org.sol";

contract OrgOwnerTester is Test, Reporter, LangDefinitions, CandidateDefinitions {

  Tester T1; address t1;
  Tester T2; address t2;
  Org org;
  function setUp() {
    org = new Org(l_001);
    org.propose(bytes32(""), "a1a1a0a1");
    org.propose(bytes32(""), "a0baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    org.propose(bytes32(""), "a1baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    org.propose(bytes32(""), "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
    setupReporter('doc/report.md');
    T1 = new Tester(); t1 = address(T1);
    T2 = new Tester(); t2 = address(T2);
    T1._target( org );
    T2._target( org );
  }

  function testSend() logs_gas {
    org.send(t1, 100);
    assertTrue(org.numOwners() == 2, "should have only two owners");
    Org(t1).send(t2, 40);
    assertTrue(org.numOwners() == 3, "should increase the owner count");
    assertTrue(org.shares(2) == 60, "t1 should have only 60 shares");
  }

}
