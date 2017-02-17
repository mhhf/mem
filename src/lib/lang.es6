'use strict';

var lexer = require('./lexer.js');
var fs = require('fs');
var color = require('colors');
var Parser = require('jison').Parser;
// var Node = require('./ast.js');
var Node = require('./node.js');
var Rule = require('./rules.js');
var _ = require('lodash');
var SHA3 = require('sha3');

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
//   console.log(parser.productions);
//   // Node.process(output);
//   // Node.normalize();
//   //
//   // Node.format();
//   // console.log( JSON.stringify(Node.rules,false,2) );
//   // console.log(JSON.stringify(output,false, 2));
// }
//
// TODO - check or process title to valid name
var rc = 2147483649;
var Rs = [];
var parseRules = function(json, name, parent) {
  // if(typeof json.title === 'string') name = json.title;
  let rule = new Node(name);
  if (json.type === 'object') {
    let required = json.required || [];
    let cname = name;
    // let parent = name;
    let p = [parent.toString(16)];
    p.push('p');
    p.push('(');
    _.each(json.properties, (ctx, ctxName) => {
      // cname = name+'_'+(Rule.ruleCounter++);
      // if(Object.keys(json.properties).indexOf(ctxName) < Object.keys(json.properties).length-1) {
        // let rule_ = rule.addNode(name+'/'+ctxName);
        // check if property is optional
        // if (required.indexOf(ctxName) === -1) rule_.required = false;
      // } else {
        // rule.addTransition([name+'/'+ctxName]);
        // if(required.indexOf(ctxName) === -1) rule.addTransition([]);
      // }
      // 
      var d = new SHA3.SHA3Hash(256);
      d.update(name+'/'+ctxName);
      let _id = d.digest('hex').slice(0,7);
      console.log( _id, ':=', name+'/'+ctxName);
      p.push(rc.toString(16));
      if (required.indexOf(ctxName) === -1) Rs.push([rc.toString(16),'2'+_id]);
      if(ctx.type == 'string' ) {
        Rs.push([rc.toString(16), '2'+_id, 'String']);
      } else {
        Rs.push([rc.toString(16), '2'+_id, (rc+1).toString(16)]);
        rc++;
        parseRules(ctx, name+'/'+ctxName, (rc++).toString(16));
      }
      rc++;
    });
    p.push(')');
    Rs.push(p);
  } else if (json.type === 'string') {
    // TODO - resolve Atoms
    // let r = new Node(name+'/string', 'String');
    // rule = rule.addNode(name + '/string');
    // rule.terminal = 'String';
    // r.setContext(name);
    // rule.addTransition([r]);
    Rs.push([parent.toString(16), 'String']);
  } else if (json.type === 'array') {
    // TODO - support min and max arrays
    // rule = rule.addNode(name + '/items');
    // rule.array = true;
    // rule.addTransition([name+'/items', name]);
    // rule.addTransition([]);
    Rs.push([parent.toString(16), (rc+1).toString(16), (rc).toString(16)]);
    rc++;
    parseRules(json.items, name+'/items', (rc).toString(16));
  } else {
    throw new Error(`type "${json.type}" not supported.`);
  }
}

module.exports = function( path ) {
  var rawFile = fs.readFileSync(path);
  var jsonSchema = JSON.parse(rawFile);
  // console.log(jsonSchema);
  parseRules(jsonSchema, '#', 2147483648);
  console.log(Rs.map(r => r.join(' ')).join('\n'));
  // console.log(Node.nodes['#'].format());
  // Node.toGrammer();
  // Rule._format();
  // let s = Rule.serialize();
  // console.log(s);
}
