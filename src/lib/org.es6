var deasync = require('deasync');
var colors  = require('colors');


var Spore = function ( config ){
  // var settings = require("../../config/app.json");

  // var Contract = require('../../contract.json').Spore;

  // var address = process.env.SPORE_ADDRESS || config.chains[ config.selected ].address || Contract.address;
  var address = '0xc305c901078781c232a2a521c2af7980f8385ee9';
  // var abi = Contract.abi;
  var abi = [{ "constant": true, "inputs": [], "name": "numPackages", "outputs": [{ "name": "number", "type": "uint256" }], "type": "function" }, { "constant": false, "inputs": [{ "name": "name", "type": "bytes32" }, { "name": "ipfs", "type": "string" }], "name": "registerPackage", "outputs": [{ "name": "", "type": "bool" }], "type": "function" }, { "constant": true, "inputs": [], "name": "getAll", "outputs": [{ "name": "names", "type": "bytes32[]" }], "type": "function" }, { "constant": true, "inputs": [], "name": "version", "outputs": [{ "name": "", "type": "bytes32" }], "type": "function" }, { "constant": true, "inputs": [{ "name": "", "type": "uint256" }], "name": "packagesArray", "outputs": [{ "name": "", "type": "bytes32" }], "type": "function" }, { "constant": false, "inputs": [{ "name": "name", "type": "bytes32" }, { "name": "to", "type": "address" }], "name": "transfearOwner", "outputs": [], "type": "function" }, { "constant": true, "inputs": [{ "name": "name", "type": "bytes32" }], "name": "getOwner", "outputs": [{ "name": "owner", "type": "address" }], "type": "function" }, { "constant": true, "inputs": [{ "name": "name", "type": "bytes32" }], "name": "getLink", "outputs": [{ "name": "link", "type": "string" }], "type": "function" }, { "inputs": [], "type": "constructor" }, { "anonymous": false, "inputs": [{ "indexed": false, "name": "name", "type": "bytes32" }, { "indexed": false, "name": "ipfs", "type": "string" }], "name": "Update", "type": "event" }];
  
  
  if( !process.env.SPORE_ADDRESS && config.web3().eth.getCode( address )  === "0x" ) {
    console.log(`No Spore contract found at ${address}`.red);
    process.exit();
  }

  var instance = config.web3().eth.contract(abi).at(address);
  
  var getOwnerSync         = deasync( instance.getOwner );
  var registerPackageSync  = deasync( instance.registerPackage );
  var getLinkSync          = deasync( instance.getLink );
  var getNumPackagesSync   = deasync( instance.numPackages );
  var getPackageName       = deasync( instance.packagesArray );
  // var getPackagesArraySync = deasync( instance.getLink );
  
  var getPackagesArraySync = function() {
    var num = getNumPackagesSync();
    var obj = {};
    
    for ( var i = 0; i< num; i++ ) {
      var name = config.web3().toAscii(getPackageName(i));
      var head = getLinkSync(name);
      obj[name] = head;
    }
    return obj;
  }
  
  return {
    instance,
    getOwnerSync,
    getLinkSync,
    registerPackageSync,
    getPackagesArraySync,
    getNumPackagesSync
  };
}

module.exports = Spore;
