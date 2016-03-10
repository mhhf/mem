'use strict';

var lexer = require('./lexer.js');
var fs = require('fs');
var color = require('colors');
var Parser = require('jison').Parser;
// var Node = require('./ast.js');
var Node = require('./node.js');
var Rule = require('./rules.js');
var _ = require('lodash');

var grammar = fs.readFileSync('./src/specs/lang.y','utf8');

var parser = new Parser(grammar);
parser.yy.Node = Node;


// module.exports = function( path ) {
//   var content = fs.readFileSync(path, 'utf8');
//
//   console.log('\nCONTENT:'.green);
//   console.log(content);
//
//   console.log('\nTOKENS:'.green);
//   parser.lexer = lexer;
//
//   var lex = lexer.setInput(content);
//   lex.yytext = "";
//   var token,i=0;
//   do{
//     (token = lex.lex());
//     i++;
//     console.log( '< '+token.yellow+', '+lex.yytext.red+' >' );
//   } while ( token != 'EOF')
//
//   var output = parser.parse(content);
//   Node.process(output);
//   Node.normalize();
//
//   Node.format();
//   // console.log( JSON.stringify(Node.rules,false,2) );
//   // console.log(JSON.stringify(output,false, 2));
// }
//
// TODO - check or process title to valid name
var parseRules = function(json, name) {
  // if(typeof json.title === 'string') name = json.title;
  let rule = new Node(name);
  if (json.type === 'object') {
    let required = json.required || [];
    let cname = name;
    let parent = name;
    _.each(json.properties, (ctx, ctxName) => {
      // cname = name+'_'+(Rule.ruleCounter++);
      // if(Object.keys(json.properties).indexOf(ctxName) < Object.keys(json.properties).length-1) {
        let rule_ = rule.addNode(name+'/'+ctxName);
        // check if property is optional
        if (required.indexOf(ctxName) === -1) rule_.required = false;
      // } else {
        // rule.addTransition([name+'/'+ctxName]);
        // if(required.indexOf(ctxName) === -1) rule.addTransition([]);
      // }
      parseRules(ctx, name+'/'+ctxName);
    });
  } else if (json.type === 'string') {
    // TODO - resolve Atoms
    // let r = new Node(name+'/string', 'String');
    rule = rule.addNode(name + '/string');
    rule.terminal = 'String';
    // r.setContext(name);
    // rule.addTransition([r]);
  } else if (json.type === 'array') {
    // TODO - support min and max arrays
    rule = rule.addNode(name + '/items');
    rule.array = true;
    // rule.addTransition([name+'/items', name]);
    // rule.addTransition([]);
    parseRules(json.items, name+'/items');
  } else {
    throw new Error(`type "${json.type}" not supported.`);
  }
}

module.exports = function( path ) {
  var rawFile = fs.readFileSync(path);
  var jsonSchema = JSON.parse(rawFile);
  // console.log(jsonSchema);
  parseRules(jsonSchema, '#');
  Node.toGrammer();
  Rule.format();
  let s = Rule.serialize();
  console.log(s);
}
