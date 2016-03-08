contract CandidateDefinitions {

  bytes c_aff;
  bytes c_bf;
  bytes c_cf;
  bytes c_abf;
  bytes c_abbf;
  bytes c_abaf;
  bytes c_aabf;
  bytes c_aaaaf;
  bytes c_abbabaaaf;

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

    c_abbf = new bytes(4);
    c_abbf[0] = byte(0x61);
    c_abbf[1] = byte(0x62);
    c_abbf[2] = byte(0x62);
    c_abbf[3] = byte(0xff);

    c_abaf = new bytes(4);
    c_abaf[0] = byte(0x61);
    c_abaf[1] = byte(0x62);
    c_abaf[2] = byte(0x61);
    c_abaf[3] = byte(0xff);

    c_aabf = new bytes(4);
    c_aabf[0] = byte(0x61);
    c_aabf[1] = byte(0x61);
    c_aabf[2] = byte(0x62);
    c_aabf[3] = byte(0xff);

    c_aaaaf = new bytes(5);
    c_aaaaf[0] = byte(0x61);
    c_aaaaf[1] = byte(0x61);
    c_aaaaf[2] = byte(0x61);
    c_aaaaf[3] = byte(0x61);
    c_aaaaf[4] = byte(0xff);

    c_abbabaaaf = new bytes(9);
    c_abbabaaaf[0] = byte(0x61);
    c_abbabaaaf[1] = byte(0x62);
    c_abbabaaaf[2] = byte(0x62);
    c_abbabaaaf[3] = byte(0x61);
    c_abbabaaaf[4] = byte(0x62);
    c_abbabaaaf[5] = byte(0x61);
    c_abbabaaaf[6] = byte(0x61);
    c_abbabaaaf[7] = byte(0x61);
    c_abbabaaaf[8] = byte(0xff);
  }

}
