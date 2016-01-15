var Contract = Pudding.web3.eth.contract(org.abi);
var c = Contract.at(org.deployed_address);

c.Print({}, function(e,r){
  console.log(e,r);
});

