/// @title Simple ethereum package proposal v0.0.2
/// @author Denis Erfurt 
contract org {
  
  struct orga {
    address[] owners;
    mapping (address => uint) shares;
    uint size;
    string[] candidates;
    bytes32 language;
    mapping ( string => mapping (address => uint) ) votes;
  }
  
  // @dev Array of all orgas to iterate over.
  bytes32[] public orgasArray;
  
  /// @dev This will return the number of registered Packages.
  /// @return Number of packages.
  function numOrgs() constant returns ( uint number ) {
    return orgasArray.length;
  }
  
  function getAll () constant returns ( bytes32[] names ){
    return orgasArray;
  }
  
  // Package Name => Package Object
  mapping (bytes32 => orga) orgas;
  
  function org () {
    
  }
  
  
  function newOrg( bytes32 name, bytes32 _language ) returns (bool){
    
    
    // Test if package already exists
    orga test = orgas[name];
    if( test.size != 0 ) return false;
    
    orgasArray.length++;
    orgasArray[ orgasArray.length - 1 ] = name;
    
    orgas[name].owners.length++;
    orgas[name].owners[ 0 ] = msg.sender;
    orgas[name].shares[msg.sender] = 10000;
    orgas[name].size = 10000;
    orgas[name].language = _language;
    
    return true;
  }
  
  function info( bytes32 _orga ) constant returns ( uint numOwners, uint size, uint numCandidates, bytes32 language ) {
    var o = orgas[ _orga ];
    
    numOwners = o.owners.length;
    size = o.size;
    numCandidates = o.candidates.length;
    language = o.language;
    
  }
  
  function propose( bytes32 _orga, string _candidate ) {
    orgas[ _orga ].candidates.length ++;
    orgas[ _orga ].candidates[ orgas[ _orga ].candidates.length - 1 ] = _candidate;
  }
  
  function vote( bytes32 _orga, string _candidate, uint _vote ) {
    orgas[ _orga ].votes[ _candidate ][ msg.sender ] = _vote;
  }
  
  // The consens is computed based on following equasions
  // $$ value(k) &:=& \sum_{a\in A} share(a) \cdot vote(a,k) $$ \\
  // $$ consens (O) &:=& min_<(\{ k |\ value(k) = \max_{k'\in K_G} (value(k')) \}) $$
  function getConsens( bytes32 _orga ) constant returns( string _candidate ) {
    
    uint maxvote = 0;
    uint candidate = 0;
    var o = orgas[_orga];
    
    for( var i=0; i<o.candidates.length; i++ ) {
      
      uint currentvote = 0;
      for( var j=0; j<o.owners.length; j++ ) {
        
        currentvote += o.votes[ o.candidates[i] ][ o.owners[j] ] * o.shares[ o.owners[j] ];
        
      }
      if( currentvote > maxvote ) {
        maxvote = currentvote;
        candidate = i;
      }
      
    }
    
    _candidate = orgas[ _orga ].candidates[ candidate ];
    
  }
  
  function getCandidatesLength( bytes32 _orga ) constant returns ( uint numCandidates ) {
    return orgas[ _orga ].candidates.length;
  }
  
  function getCandidateAt( bytes32 _orga, uint _at ) constant returns ( string _candidate ) {
    return orgas[ _orga ].candidates[ _at ];
  }
  
  function send( bytes32 _orga, address _addr, uint _value ) {
    var orga = orgas[ _orga ];
    
    if( orga.shares[ msg.sender ] < _value ) throw;
    
    orga.shares[ _addr ] += _value;
    orga.shares[ msg.sender ] -= _value;
    
  }
  
  function getShares( bytes32 _orga, address _addr ) constant returns (uint shares) {
    return orgas[ _orga ].shares[ _addr ];
  }
  
}
