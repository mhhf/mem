contract LangDefinitions {

  bytes l_001; // (a|b)*
  bytes l_002; // a*b*
  bytes l_003; // a+b*

  function LangDefinitions() {
    // S -> aS
    // S -> bS
    // final(S)
    l_001 = new bytes(12); 
    // S -> aS
    l_001[0] = byte(0x03);
    l_001[1] = byte(0x01);
    l_001[2] = byte(0x61);
    l_001[3] = byte(0x01);
    // S -> bS
    l_001[4] = byte(0x03);
    l_001[5] = byte(0x01);
    l_001[6] = byte(0x62);
    l_001[7] = byte(0x01);
    // final(S)
    l_001[8] = byte(0x03);
    l_001[9] = byte(0x01);
    l_001[10] = byte(0xff);
    l_001[11] = byte(0xff);

    // S -> aS
    // S -> bB
    // B -> bB
    // final(S,B)
    l_002 = new bytes(20);
    // S -> aS
    l_002[0] = byte(0x03);
    l_002[1] = byte(0x01);
    l_002[2] = byte(0x61);
    l_002[3] = byte(0x01);
    // S -> bB
    l_002[4] = byte(0x03);
    l_002[5] = byte(0x01);
    l_002[6] = byte(0x62);
    l_002[7] = byte(0x02);
    // B -> bB
    l_002[8] = byte(0x03);
    l_002[9] = byte(0x02);
    l_002[10] = byte(0x62);
    l_002[11] = byte(0x02);
    // final(S)
    l_002[12] = byte(0x03);
    l_002[13] = byte(0x01);
    l_002[14] = byte(0xff);
    l_002[15] = byte(0xff);
    // final(B)
    l_002[16] = byte(0x03);
    l_002[17] = byte(0x02);
    l_002[18] = byte(0xff);
    l_002[19] = byte(0xff);

    // S -> aA
    // A -> aA
    // A -> bB
    // B -> bB
    // final(A,B)
    l_003 = new bytes(24);
    // S -> aA
    l_003[0] = byte(0x03);
    l_003[1] = byte(0x01);
    l_003[2] = byte(0x61);
    l_003[3] = byte(0x02);
    // A -> aA
    l_003[4] = byte(0x03);
    l_003[5] = byte(0x02);
    l_003[6] = byte(0x61);
    l_003[7] = byte(0x02);
    // A -> bB
    l_003[8] = byte(0x03);
    l_003[9] = byte(0x02);
    l_003[10] = byte(0x62);
    l_003[11] = byte(0x03);
    // B -> bB
    l_003[12] = byte(0x03);
    l_003[13] = byte(0x03);
    l_003[14] = byte(0x62);
    l_003[15] = byte(0x03);
    // final(A)
    l_003[16] = byte(0x03);
    l_003[17] = byte(0x02);
    l_003[18] = byte(0xff);
    l_003[19] = byte(0xff);
    // final(B)
    l_003[20] = byte(0x03);
    l_003[21] = byte(0x03);
    l_003[22] = byte(0xff);
    l_003[23] = byte(0xff);
  }
}
