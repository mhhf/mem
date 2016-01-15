#!/bin/sh
cd src
truffle deploy
grep -e "^\s*org.address = \"\([^\"]*\)\".*$" environments/development/contracts/org.sol.js |sed 's/    org.address = "\([^"]*\)";/\1/g'
cd ../setup
./fill.sh
