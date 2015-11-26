
contract('org', function(accounts) {
  
  it("should assert true", function(done) {
    
    var _org = org.at( org.deployed_address ); 
    
    assert.isTrue(true);
    
    done();
  });
  
  it("should instantiate a new org", function(done){
    
    var _org = org.at( org.deployed_address ); 
    
    _org.newOrg( 'test', 'abi' ).then( tx => {
      return _org.numOrgs.call();
    }).then( e => {
      assert.equal( e, 1 );
      done();
    });
    
  });
  
  it("should submit and return a candidate", function(done){
    
    var _org = org.at( org.deployed_address ); 
    
    _org.propose( 'test', 'omg_candidate' ).then(tx => {
      return _org.getConsens.call('test');
    }).then( e => {
      assert.equal( e, 'omg_candidate' );
      done();
    });
    
  });
  
  it("should submit and return a second candidate", function(done){
    
    var _org = org.at( org.deployed_address ); 
    
    _org.propose( 'test', 'awesome_candidate' ).then(tx => {
      
      return _org.getConsens.call('test');
    }).then( e => {
      // test if consens is affected
      assert.equal(e, 'omg_candidate');
      done();
    });
    
  });
  
  it("should vote for a candidate", function(done){

    var _org = org.at( org.deployed_address ); 

    _org.vote( 'test', 'awesome_candidate', 100 ).then( tx => {
      
      return _org.getConsens.call('test');
    }).then( e => {
      // test if vote has changed candidate
      assert.equal( e, 'awesome_candidate' );
      done();
    });

  });
  

  
  
});
