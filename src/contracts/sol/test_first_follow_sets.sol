import "dapple/test.sol";

contract TestFirstAndFollowSets is Test {

  bytes lang;
  mapping (byte => bytes) first;
  function setUp() {
    lang = new bytes(25);
    lang[0]=byte(0x03);
    lang[1]=byte("S");
    lang[2]=byte("T");
    lang[3]=byte("X");
    lang[4]=byte(0x04);
    lang[5]=byte("T");
    lang[6]=byte("(");
    lang[7]=byte("S");
    lang[8]=byte(")");
    lang[9]=byte(0x03);
    lang[10]=byte("T");
    lang[11]=byte("i");
    lang[12]=byte("Y");
    lang[13]=byte(0x03);
    lang[14]=byte("X");
    lang[15]=byte("+");
    lang[16]=byte("S");
    lang[17]=byte(0x01);
    lang[18]=byte("X");
    lang[19]=byte(0x01);
    lang[20]=byte("Y");
    lang[21]=byte(0x03);
    lang[22]=byte("Y");
    lang[23]=byte("*");
    lang[24]=byte("T");
  }

  function computeFirst(bytes lang, byte n) internal returns (bytes){
    uint i = 0;
    bytes memory a = new bytes(0);
    uint index = 0;
    while(i < lang.length) {
      if(lang[i+1] == n) {
        if(uint(lang[i]) == 1) {
          a = __addToSet(a, byte(0x01));
        } else {
          a = __addToSet(a, lang[i + 2]);
        }
      }
      i += uint(lang[i]) + 1;
    }
    return a;
  }


  function testComputeFirstT() {
    bytes memory firstT = computeFirst(lang, 'T');
    //@log `string string(firstT)`
    assertTrue(__indexOf(firstT, 'i') > -1);
    assertTrue(__indexOf(firstT, '(') > -1);

    bytes memory firstS = computeFirst(lang, 'S');
    //@log `string string(firstS)`
    assertTrue(__indexOf(firstS, 'T') > -1);
  }

  function __indexOf(bytes memory str, byte search) internal returns(int){
    for(var i=0; i<str.length; i++) {
      if(str[i] == search) return i;
    }
    return -1;
  }

  function __append(bytes memory a, byte b) internal returns(bytes memory c) {
    c = new bytes(a.length+1);
    uint8 i;
    for (i = 0; i<a.length; i++) {
      c[i] = a[i];
    }
    c[i] = b;
    return c;
  }

  function __addToSet(bytes memory a, byte b) internal returns(bytes memory c) {
    if( __indexOf(a, b) == -1 ) {
      return __append(a,b);
    }
    return a;
  }



}
