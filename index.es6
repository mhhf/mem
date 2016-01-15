#! /usr/bin/env node
"use strict"; 

var docopt = require('docopt');
var fs     = require('fs-extra');
var CONFIG = require( './src/lib/config.es6' );
var CHAIN  = require( './src/lib/chain.es6' );
var tv4    = require('tv4');
var Bluebird = require('bluebird');
var path   = require('path');
var jsonlint = require('jsonlint');

var cli = fs.readFileSync(__dirname + `/src/specs/cli.docopt`,'utf8');

var __package = require('./package.json');

var app = docopt.docopt(cli, {
  argv: process.argv.slice(2),
  help: false,
  version: __package.version
});

var config = CONFIG( app, { 
  cli: true
});


if( config.is ) {
  
  
  var org = config.contracts.org();
  var _orga = config['<name>'];
  
  org.getConsens.call( _orga ).then( schemaIpfs => {
    
    var schema = config.ipfs().catJsonSync( schemaIpfs );
    
    var file = fs.readFileSync( app['<path>'], 'utf8' );
    var json = jsonlint.parse( file );
    
    var valid = tv4.validate( json, schema );
    
    if( !valid ) {
      console.log( 'no :( '.red.bold, tv4.error.message );
    } else {
      console.log('indeed it is!'.green.bold);
    }
    
  });
  

} else if( config.chain ) {
  
  CHAIN(config);
  
} else if( config.get ) {
  
  var org = config.contracts.org();
  var _orga = config['<name>'];

  org.getConsens.call( _orga ).then( consens => {
    
    var data = config.ipfs().catJsonSync( consens );
    console.log( data );
    
  });
  // var data = config.ipfs().catJsonSync( link );
  // console.log( JSON.stringify(data, false, 2) );

} else if ( !config.evolution && config.propose  ) {
  
  var org = config.contracts.org();
  var _orga = config['<name>'];
  if( config['-s'] || config['-l'] ) {
    var _data = config['<string>'];
  } else {
    var _path = config['<path>'];
    var _data = JSON.parse(fs.readFileSync( _path, 'utf8' ));
  }
  var _candidate;
  
  org.info.call( _orga ).then( a => {
    var _langIpfs = a[3];
    
    if( a[3] == '0x46494e0000000000000000000000000000000000000000000000000000000000' ) {
     return "QmfSnGmfexFsLDkbgN76Qhx2W8sxrNDobFEQZ6ER5qg2wW";
    } else {
      return org.getConsens( _langIpfs );
    }
  }).then( _langIpfs => {
  
    var schema = config.ipfs().catJsonSync( _langIpfs );
    
    if( config['-l'] ) {
      var valid = tv4.validate( config.ipfs().catJsonSync(_data), schema );
    } else {
      var valid = tv4.validate( _data, schema );
    }
    if( !valid ) {
      console.log( tv4.error.message );
      throw Error(' Data is not valid in Language ', tv4.error.message );
    }
   
    if( config['-l'] ) {
      _candidate = _data;
    } else {
      _candidate = config.ipfs().addJsonSync( _data );
    }
    
    return getCandidates( _orga );

  }).then( candidates => {
    
    if( candidates.indexOf( _candidate ) > -1 ) throw Error('candidate already proposed');
    
    return org.propose( _orga, _candidate );
  }).then( tx => {
    // 2. check if candidate is valid language word
    console.log(tx);
  }).catch(e => {
    console.log(e);
  });
  
} else if( config.candidates ) {
  
  console.log('list proposals');
  var org = config.contracts.org();
  
  // TODO - unperformant
  getCandidates( config['<name>'] ).then( candidates => {
    console.log( candidates );
  });

} else if( config.vote ) {
  
  var org   = config.contracts.org();
  var _orga = config['<name>'];
  var _cand = config['<candidate>']; 
  var _vote = config['<vote>'];
  
  org.vote( _orga, _cand, _vote ).then( tx => {
    
    console.log(tx);
    
  });

} else if( config.new ) {
  // TODO - test if lang is aviable
  
  var _orga   = config['<name>'];
  var _lang   = config['--lang'] || 'FIN';
  var _size   = config['--size'] || 10000;
  
  console.log(_lang, _size);
  
  var org = config.contracts.org();
  org.newOrg( _orga, _lang ).then( tx => {
    console.log(tx);
  });

} else if( config.send ) {
  
  var org = config.contracts.org();
  
  var _orga  = config['<name>'];
  var _addr  = config['<address>'];
  var _value = config['<value>'];
  
  org.send( _orga, _addr, _value ).then( tx => {
    console.log(tx);
  });

} else if( config.info ) {
  
  var org = config.contracts.org();
  
  var _orga = config['<name>'];
  
  org.info.call( _orga ).then( a => {
    console.log('#Owners: ', a[0].toString());
    console.log('size: ', a[1].toString());
    console.log('#Candidates: ', a[2].toString());
    console.log('#Evolutions: ', a[4].toString());
    console.log('language: ', config.web3().toAscii( a[3] ));
  });
  
} else if( config.balanceOf ) {

  var org = config.contracts.org();
  
  var _orga = config['<name>'];
  var _addr = config['<address>'];
  
  org.getShares.call( _orga, _addr ).then( shares => {
    console.log('shares:', shares.toString());
  })
  

} else if( config.evolution && config.propose ) {
  
  var org = config.contracts.org();
  
  var _name = config['<name>'];
  var _l_1 = config['<from>'];
  var _l_2 = config['<to>'];
  var _schema = config['<schema>'];
  
  org.newEvolutionSchema( _name, _l_1, _l_2, _schema ).then( tx => {
    
    console.log(tx);
    
  });
  
} else if( config.proposeEvolution ) {
  var _orga = config['<name>'];
  var _eN = config['<evolutionName>'];
  
  var org = config.contracts.org();
  org.proposeEvolution( _orga, _eN ).then( tx => {
    console.log(tx);
  });

} else if( config.evolve ) {
  var _orga = config['<name>'];
  
  var org = config.contracts.org();
  org.evolve().then( tx => {
    console.log(tx);
  });
  
} else if( config.list ) {
  var org = config.contracts.org();
  
  org.getAll().then( list => {
    list.forEach( name => console.log( config.web3().toAscii( name ) ) );
    // console.log( list );
  })
    
} else if( config.voteEvolution ) {
  // mem voteEvolution <name> <evolutionName> <vote>
  var _orga = config['<name>'];
  var _ev = config['<evolutionName>'];
  var _vote = config['<vote>'];
  
  var org = config.contracts.org();
  org.voteEvolution( _orga, _ev, _vote ).then( tx => {
    console.log(tx);
  } );
}

function getCandidates( _orga ) {
  return org.getCandidatesLength.call( _orga ).then( l => {
      
      var tasks = [];
      for(var i=0; i<l; i++ ) {
        tasks.push( org.getCandidateAt( _orga, i )) 
      }
      return Bluebird.all( tasks );
    });
}
