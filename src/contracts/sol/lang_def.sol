contract LangDefinitions {

  bytes l_001; // (a|b)*
  bytes l_002; // a*b*
  bytes l_003; // a+b*
  bytes l_004; // a+b*
  bytes l_005; // a+b*
  bytes l_006; // a+b*
  bytes l_007; // a+b*

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
    l_002[7] = byte("A");
    // B -> bB
    l_002[8] = byte(0x03);
    l_002[9] = byte("A");
    l_002[10] = byte("b");
    l_002[11] = byte("A");
    // final(S)
    l_002[12] = byte(0x03);
    l_002[13] = byte("S");
    l_002[14] = byte("$");
    l_002[15] = byte("$");
    // final(B)
    l_002[16] = byte(0x03);
    l_002[17] = byte("A");
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
    l_003[3] = byte("A");
    // A -> aA
    l_003[4] = byte(0x03);
    l_003[5] = byte("A");
    l_003[6] = byte("a");
    l_003[7] = byte("A");
    // A -> bB
    l_003[8] = byte(0x03);
    l_003[9] = byte("A");
    l_003[10] = byte("b");
    l_003[11] = byte("B");
    // B -> bB
    l_003[12] = byte(0x03);
    l_003[13] = byte("B");
    l_003[14] = byte("b");
    l_003[15] = byte("B");
    // final(A)
    l_003[16] = byte(0x03);
    l_003[17] = byte("A");
    l_003[18] = byte("$");
    l_003[19] = byte("$");
    // final(B)
    l_003[20] = byte(0x03);
    l_003[21] = byte("B");
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

    l_005 = new bytes(10);
    // A -> (AbA)
    l_005[0] = byte(0x06);
    l_005[1] = byte("S");
    l_005[2] = byte("(");
    l_005[3] = byte("S");
    l_005[4] = byte("b");
    l_005[5] = byte("S");
    l_005[6] = byte(")");
    // A -> a
    l_005[7] = byte(0x02);
    l_005[8] = byte("S");
    l_005[9] = byte("a");

    l_006 = new bytes(29);
    // S -> pAB
    l_006[0] = byte(0x04);
    l_006[1] = byte("S");
    l_006[2] = byte("p");
    l_006[3] = byte("A");
    l_006[4] = byte("B");
    // S -> cC
    l_006[5] = byte(0x03);
    l_006[6] = byte("S");
    l_006[7] = byte("c");
    l_006[8] = byte("C");
    // final(c)
    l_006[9] = byte(0x03);
    l_006[10] = byte("C");
    l_006[11] = byte("$");
    l_006[12] = byte("$");
    // A -> aA
    l_006[13] = byte(0x03);
    l_006[14] = byte("A");
    l_006[15] = byte("a");
    l_006[16] = byte("S");
    // B -> bB
    l_006[17] = byte(0x03);
    l_006[18] = byte("B");
    l_006[19] = byte("b");
    l_006[20] = byte("B");
    // final(A)
    l_006[21] = byte(0x03);
    l_006[22] = byte("A");
    l_006[23] = byte("$");
    l_006[24] = byte("$");
    // final(B)
    l_006[25] = byte(0x03);
    l_006[26] = byte("B");
    l_006[27] = byte("$");
    l_006[28] = byte("$");

    l_007 = new bytes(29);
    // S -> pAB
    l_007[0] = byte(0x04);
    l_007[1] = byte("S");
    l_007[2] = byte("p");
    l_007[3] = byte("A");
    l_007[4] = byte("A");
    // S -> cC
    l_007[5] = byte(0x03);
    l_007[6] = byte("S");
    l_007[7] = byte("c");
    l_007[8] = byte("C");
    // final(c)
    l_007[9] = byte(0x03);
    l_007[10] = byte("C");
    l_007[11] = byte("$");
    l_007[12] = byte("$");
    // A -> aA
    l_007[13] = byte(0x03);
    l_007[14] = byte("A");
    l_007[15] = byte("a");
    l_007[16] = byte("S");
    // B -> bB
    l_007[17] = byte(0x03);
    l_007[18] = byte("B");
    l_007[19] = byte("b");
    l_007[20] = byte("B");
    // final(A)
    l_007[21] = byte(0x03);
    l_007[22] = byte("A");
    l_007[23] = byte("$");
    l_007[24] = byte("$");
    // final(B)
    l_007[25] = byte(0x03);
    l_007[26] = byte("B");
    l_007[27] = byte("$");
    l_007[28] = byte("$");
  }

}
