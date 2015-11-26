#!/bin/sh
mem new FIN
mem propose FIN -l QmfSnGmfexFsLDkbgN76Qhx2W8sxrNDobFEQZ6ER5qg2wW # {}
mem new ABI
mem propose ABI -l QmU4zsusFSjB3ufKHF7HJA68vyrMgRRysqBgqiP6M3LejM # all valid abis
mem new SCHEMA
mem propose SCHEMA -l QmcpucZJhDMYoTWjKKTiS3jnmbwZyk2r2DhHAJATT9qVEr # json meta schema
mem new short_simple_name
mem propose short_simple_name -l Qmb8kc9gKpwd9oTeYJoXCF5xgR9fgxewdgHWP9ah2WfCSi # [a-z ]{3,32}
mem new a --lang short_simple_name
