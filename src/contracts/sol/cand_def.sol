contract CandidateDefinitions {

  bytes c_aff;
  bytes c_bf;
  bytes c_cf;
  bytes c_abf;

  function CandidateDefinitions() {
    c_aff = new bytes(3);
    c_aff[0] = byte(0x61);
    c_aff[1] = byte(0xff);
    c_aff[2] = byte(0xff);

    c_bf = new bytes(2);
    c_bf[0] = byte(0x62);
    c_bf[1] = byte(0xff);

    c_cf = new bytes(2);
    c_cf[0] = byte(0x63);
    c_cf[1] = byte(0xff);

    c_abf = new bytes(3);
    c_abf[0] = byte(0x61);
    c_abf[1] = byte(0x62);
    c_abf[2] = byte(0xff);
  }

}
