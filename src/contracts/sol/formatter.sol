import "org.sol";
import "dapple/reporter.sol";

contract OrgFormatter is TypeDef, Reporter {

  function _formatOrg(Org o) wrapCode("viz") {
    //@doc digraph A {
    __orgLog(o, "");
    //@doc }
  }

  function __orgLog(Org o, bytes32 cand) internal {
    uint8 numChildren = o.getNumChildrenFor(cand);
    uint bestChild = o.getBestChildIndex(cand);
    __renderNode(o, cand);
    for(var i=0; i<numChildren; i++) {
      bytes32 _childId = o.getChildIdAt(cand, i);
      if(i==bestChild) {
        //@doc "`bytes32 cand`" -> "`bytes32 _childId`";
      } else {
        //@doc "`bytes32 cand`" -> "`bytes32 _childId`" [style=dotted];
      }
      __orgLog(o, _childId);
    }
  }

  function __renderNode(Org o, bytes32 cand) internal {
    byte _type = o.getType(cand);
    bytes memory _id = new bytes(4);
    _id[0] = cand[0];
    _id[1] = cand[1];
    _id[2] = cand[2];
    _id[3] = cand[3];
    //@doc "`bytes32 cand`" [label=<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">
    //@doc <TR><TD><B>Id</B></TD><TD>`bytes _id`</TD></TR>
    //@doc <TR><TD><B>Type</B></TD><TD>`string string(__toBytes(_type))`</TD></TR>
    if(atomBytes[_type] == 1) {
      byte _byte = o.getChildData1(cand);
      //@doc <TR><TD><B>Data</B></TD><TD>`string string(__toBytes(_byte))`</TD></TR>
    } else if(atomBytes[_type] == 32) {
      byte[32] memory _data = o.getChildData32(cand);
      bytes memory data = new bytes(atomBytes[_type]);
      for(var i = 0; i < atomBytes[_type]; i++) {
        data[i] = _data[i];
      }
      //@doc <TR><TD><B>Data</B></TD><TD>`string string(data)`</TD></TR>
    }
    //@doc </TABLE>> shape=none];
  }

  function __toBytes(byte what) internal returns (bytes) {
    bytes memory ret = new bytes(1);
    ret[0] = what;
    return ret;
  }

  function __slice(bytes _in, uint8 from, uint8 to) internal returns(bytes out) {
    out = new bytes(to-from);
    for(var i=0; i< to-from; i++) {
      out[i] = _in[from+i];
    }
    return out;
  }

}
