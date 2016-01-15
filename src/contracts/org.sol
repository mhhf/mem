// TODO - normalize vote


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
    
    // Evolution
    bytes32[] evolutionProposals;
    mapping ( bytes32 => mapping (address => uint) ) evolutionVotes;
  }
  
  // An evolution schema is a tuple (L_1, L_2, migration)
  // It describes an external migration function which maps
  // words from L_1 to words to L_2
  struct evolutionSchema {
    bytes32 l_1; // L_1
    bytes32 l_2;   // L_2
    // IPFS Address of js file which actually maps the candidates
    // TODO: This has to be implemented in solidity so that the mapping can
    // be done on chain
    string migration;
  }
  
  mapping ( bytes32 => evolutionSchema ) evolutionSchemas;
  
  /* // $$ evolutionFrom: L_1 -> [L_2] $$ */
  /* // contains all languages, which can be reached in 1 step from L_1 */
  /* mapping ( bytes32 => bytes32[] ) evolutionFrom; */
  /*  */
  /* // $$ evolutionFrom: L_2 -> [L_1] $$ */
  /* // contains all languages, which can be reach L_2 in 1 step from L_1 */
  /* mapping ( bytes32 => bytes32[] ) evolutionTo; */
  
  /* // $$instanceOf: LANG -> P(O)$$ */
  /* // Maps every language to a set of Orgs in this language */
  /* mapping public (bytes32 => string[]) instancesOf; */
  
  // @dev Array of all orgas to iterate over.
  bytes32[] public orgasArray;
  bytes32[] public evolutionSchemasArray;
  
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
    
    /* instancesOf[_language].length ++; */
    /* instancesOf[_language][ instancesOf[_language].length - 1 ] = name; */
    
    return true;
  }
  
  function newEvolutionSchema( bytes32 name, bytes32 _L_1, bytes32 _L_2, string _migration ) returns (bool) {
    
    evolutionSchema test = evolutionSchemas[ name ];
    if( test.l_1 != 0 ) return false;
    
    evolutionSchemasArray.length ++;
    evolutionSchemasArray[ evolutionSchemasArray.length - 1 ] = name;
    
    // TODO test if _L_* are inhereted from SCHEMA/ are Languages
    evolutionSchemas[ name ].l_1 = _L_1;
    evolutionSchemas[ name ].l_2 = _L_2;
    
    // TODO test if _migration is inhereted from MIGRATION Language
    evolutionSchemas[ name ].migration = _migration;
    
    return true;
  }
  
  function info( bytes32 _orga ) constant returns ( 
                                                   uint numOwners,
                                                   uint size,
                                                   uint numCandidates, 
                                                   bytes32 language,
                                                   uint numEvolutions
                                                  ) {
    var o = orgas[ _orga ];
    
    numOwners = o.owners.length;
    size = o.size;
    numCandidates = o.candidates.length;
    language = o.language;
    numEvolutions = o.evolutionProposals.length;
    
  }
  
  // propose Candidate
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
    uint index = 0;
    var o = orgas[_orga];
    
    for( uint i=0; i<o.candidates.length; i++ ) {
      
      uint currentvote = 0;
      for( uint j=0; j<o.owners.length; j++ ) {
        
        currentvote += o.votes[ o.candidates[i] ][ o.owners[j] ] * o.shares[ o.owners[j] ];
        
      }
      if( currentvote > maxvote ) {
        maxvote = currentvote;
        index = i;
      }
      
    }
    
    _candidate = orgas[ _orga ].candidates[ index ];
    
  }
  
  // The consens is computed based on following equasions
  // $$ value(k) &:=& \sum_{a\in A} share(a) \cdot vote(a,k) $$ \\
  // $$ consens (O) &:=& min_<(\{ k |\ value(k) = \max_{k'\in K_G} (value(k')) \}) $$
  function getConsensIndex( bytes32 _orga ) constant returns( uint _index ) {
    
    uint maxvote = 0;
    uint index = 0;
    var o = orgas[_orga];
    
    for( uint i=0; i<o.candidates.length; i++ ) {
      
      uint currentvote = 0;
      for( uint j=0; j<o.owners.length; j++ ) {
        
        currentvote += o.votes[ o.candidates[i] ][ o.owners[j] ] * o.shares[ o.owners[j] ];
        
      }
      if( currentvote > maxvote ) {
        maxvote = currentvote;
        index = i;
      }
      
    }
    
    _index = index;
    
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
  
  

  //////////////////////////////////////////////////////                        EVOLUTION
  

  // propose
  function proposeEvolution( bytes32 _orga, bytes32 _evolutionSchema ) returns ( bool ) {
    
    // TODO - test if evolutionschema is actually a schema
    
    if( evolutionSchemas[ _evolutionSchema ].l_1 != orgas[ _orga ].language ) {
      return false;
    }
    
    orgas[ _orga ].evolutionProposals.length++;
    orgas[ _orga ].evolutionProposals[ orgas[ _orga ].evolutionProposals.length - 1 ] = _evolutionSchema;
    
    return true;
  }
  
  // vote
  function voteEvolution( bytes32 _orga, bytes32 _evolutionSchema, uint vote ) {
    
    orgas[ _orga ].evolutionVotes[_evolutionSchema][ msg.sender ] = vote;
    
  } 
  
  // evolve
  // TODO - split in components
  function evolve( bytes32 _orga ) returns (bool) {
    
    var o = orgas[_orga];
    
    uint maxVote = 0;
    uint evolutionIndex = 0;
    
    uint epsilon = 1; // TODO: 0.5 * size
    
    // get schema
    for( var i=0; i<o.evolutionProposals.length; i++ ) {
      
      uint currentvote = 0;
      for( var j=0; j<o.owners.length; j++ ) {
        currentvote += o.evolutionVotes[o.evolutionProposals[i]][o.owners[j]] * o.shares[ o.owners[j] ];
      }
      if( currentvote > epsilon && currentvote > maxVote ) {
        
        maxVote = currentvote;
        evolutionIndex = i;
        
      }
      
    }
    if( maxVote == 0 ) return false;
    
    var _eS = evolutionSchemas[ o.evolutionProposals[ evolutionIndex ] ];
    
    o.language = _eS.l_2;
    
    // TODO: candidate mapping has to be done here
    
    // get consens candidate index
    uint index = getConsensIndex( _orga );
    
    // get consens string
    string consens = o.candidates[index];
    
    for( i; i<o.candidates.length; i++ ) {
      
      // keep votes for consens candidate;
      if( i != index ) {
        
        // remove votes for other candidates
        for( j=0; j<o.owners.length; j++ ) {
            delete o.votes[o.candidates[i]][o.owners[j]];
        }
        
      }
      
    }
    
    // delete all candidates
    delete o.candidates;
    
    // add consens candidate back in
    o.candidates.length ++;
    o.candidates[ o.candidates.length - 1 ] = consens;
    
  }
  
  
  
  
}
