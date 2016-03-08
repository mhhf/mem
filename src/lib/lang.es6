'use strict';

var lexer = require('./lexer.js');
var fs = require('fs');
var color = require('colors');
var Parser = require('jison').Parser;
var Node = require('./ast.js');

var grammar = fs.readFileSync('./src/specs/lang.y','utf8');

var parser = new Parser(grammar);
parser.yy.Node = Node;


module.exports = function( path ) {
  var content = fs.readFileSync(path, 'utf8');

  console.log('\nCONTENT:'.green);
  console.log(content);

  console.log('\nTOKENS:'.green);
  parser.lexer = lexer;

  var lex = lexer.setInput(content);
  lex.yytext = "";
  var token,i=0;
  do{
    (token = lex.lex());
    i++;
    console.log( '< '+token.yellow+', '+lex.yytext.red+' >' );
  } while ( token != 'EOF')

  var output = parser.parse(content);
  Node.process(output);
  Node.normalize();
  
  Node.format();
  // console.log( JSON.stringify(Node.rules,false,2) );
  // console.log(JSON.stringify(output,false, 2));
}

