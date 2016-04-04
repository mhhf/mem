contract TypeDef {
  // Set of possible types
  mapping (byte => uint8) atomBytes;

  function TypeDef() {
    atomBytes[byte("a")] = 1;  // bool
    atomBytes[byte("b")] = 32; // bytes256
    atomBytes[byte("c")] = 32; // uint256
    atomBytes[byte("p")] = 0;  // parallel voting type
    atomBytes[byte("$")] = 0;  // bottom ($)
  }
}
