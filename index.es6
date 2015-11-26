#! /usr/bin/env node
"use strict"; 

var docopt = require('docopt');
var fs     = require('fs-extra');
var CONFIG = require( './src/lib/config.es6' );
var CHAIN  = require( './src/lib/chain.es6' );
var tv4    = require('tv4');

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
  
  var link = config.contracts.spore().instance.getLink( app['<name>'] );
  var schema = config.ipfs().catJsonSync( link );
  
  var file = fs.readFileSync( app['<path>'], 'utf8' );
  var json = JSON.parse( file );
  
  var valid = tv4.validate( json, schema );
  
  if( !valid ) {
    console.log( 'no :( '.red.bold, tv4.error.message );
  } else {
    console.log('indeed it is!'.green.bold);
  }

} else if( config.publish ) {
  
  var file = fs.readFileSync( app['<path>'], 'utf8' );
  var json = JSON.parse( file );
  var ipfsLink = config.ipfs().addJsonSync(json);
  var spr = config.contracts.spore();
  spr.instance.registerPackage( app['<name>'], ipfsLink );

} else if( config.chain ) {
  
  CHAIN(config);
  
} else if( config.get ) {
  
  console.log('Get consens');

  var org = config.contracts.org();
  var _orga = config['<name>'];

  org.getConsens.call( _orga ).then( consens => {
    console.log('Consens:', consens);
  });
  // var data = config.ipfs().catJsonSync( link );
  // console.log( JSON.stringify(data, false, 2) );

} else if ( config.p || config.propose  ) {
  
  console.log('Propose ');
  var org = config.contracts.org();
  
  org.propose( config['<name>'], config['<path>'] ).then( tx => {
    console.log(tx);
  });

  
} else if( config.candidates ) {
  
  console.log('list proposals');
  var org = config.contracts.org();
  
  org.getCandidatesLength.call( config['<name>'] ).then( l => {
    for(var i=0; i<l; i++ ) {
      org.getCandidateAt( config['<name>'], i ).then( e => console.log(e) );
    }
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
    console.log('language: ', a[3]);
  });
  
} else if( config.balanceOf ) {

  var org = config.contracts.org();
  
  var _orga = config['<name>'];
  var _addr = config['<address>'];
  
  org.getShares.call( _orga, _addr ).then( shares => {
    console.log('shares:', shares.toString());
  })
  

}
