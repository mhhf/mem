contract LangDefinitions {

  bytes l_001; // (a|b)*
  bytes l_002; // a*b*
  bytes l_003; // a+b*
  bytes l_004; // a+b*

  function LangDefinitions() {
    // S -> aS
    // S -> bS
    // final(S)
    l_001 = new bytes(12); 
    // S -> aS
    l_001[0] = byte(0x03);
    l_001[1] = byte("S");
    l_001[2] = byte("a");
    l_001[3] = byte("S");
    // S -> bS
    l_001[4] = byte(0x03);
    l_001[5] = byte("S");
    l_001[6] = byte("b");
    l_001[7] = byte("S");
    // final(S)
    l_001[8] = byte(0x03);
    l_001[9] = byte("S");
    l_001[10] = byte("$");
    l_001[11] = byte("$");

    // S -> aS
    // S -> bB
    // B -> bB
    // final(S,B)
    l_002 = new bytes(20);
    // S -> aS
    l_002[0] = byte(0x03);
    l_002[1] = byte("S");
    l_002[2] = byte("a");
    l_002[3] = byte("S");
    // S -> bB
    l_002[4] = byte(0x03);
    l_002[5] = byte("S");
    l_002[6] = byte("b");
    l_002[7] = byte(0x02);
    // B -> bB
    l_002[8] = byte(0x03);
    l_002[9] = byte(0x02);
    l_002[10] = byte("b");
    l_002[11] = byte(0x02);
    // final(S)
    l_002[12] = byte(0x03);
    l_002[13] = byte("S");
    l_002[14] = byte("$");
    l_002[15] = byte("$");
    // final(B)
    l_002[16] = byte(0x03);
    l_002[17] = byte(0x02);
    l_002[18] = byte("$");
    l_002[19] = byte("$");

    // S -> aA
    // A -> aA
    // A -> bB
    // B -> bB
    // final(A,B)
    l_003 = new bytes(24);
    // S -> aA
    l_003[0] = byte(0x03);
    l_003[1] = byte("S");
    l_003[2] = byte("a");
    l_003[3] = byte(0x02);
    // A -> aA
    l_003[4] = byte(0x03);
    l_003[5] = byte(0x02);
    l_003[6] = byte("a");
    l_003[7] = byte(0x02);
    // A -> bB
    l_003[8] = byte(0x03);
    l_003[9] = byte(0x02);
    l_003[10] = byte("b");
    l_003[11] = byte(0x03);
    // B -> bB
    l_003[12] = byte(0x03);
    l_003[13] = byte(0x03);
    l_003[14] = byte("b");
    l_003[15] = byte(0x03);
    // final(A)
    l_003[16] = byte(0x03);
    l_003[17] = byte(0x02);
    l_003[18] = byte("$");
    l_003[19] = byte("$");
    // final(B)
    l_003[20] = byte(0x03);
    l_003[21] = byte(0x03);
    l_003[22] = byte("$");
    l_003[23] = byte("$");

    l_004 = new bytes(29);
    // S -> pAB
    l_004[0] = byte(0x04);
    l_004[1] = byte("S");
    l_004[2] = byte("p");
    l_004[3] = byte("A");
    l_004[4] = byte("B");
    // S -> cC
    l_004[5] = byte(0x03);
    l_004[6] = byte("S");
    l_004[7] = byte("c");
    l_004[8] = byte("C");
    // final(c)
    l_004[9] = byte(0x03);
    l_004[10] = byte("C");
    l_004[11] = byte("$");
    l_004[12] = byte("$");
    // A -> aA
    l_004[13] = byte(0x03);
    l_004[14] = byte("A");
    l_004[15] = byte("a");
    l_004[16] = byte("A");
    // B -> bB
    l_004[17] = byte(0x03);
    l_004[18] = byte("B");
    l_004[19] = byte("b");
    l_004[20] = byte("B");
    // final(A)
    l_004[21] = byte(0x03);
    l_004[22] = byte("A");
    l_004[23] = byte("$");
    l_004[24] = byte("$");
    // final(B)
    l_004[25] = byte(0x03);
    l_004[26] = byte("B");
    l_004[27] = byte("$");
    l_004[28] = byte("$");

  }

  

}
