'use strict';

var _ = require('lodash');
var colors = require('colors');

class Node {

  static process(ast) {
    if( !Node.rules ) Node.rules = {};
    ast.forEach( n => {
      if (n.name === 'def') {
        let name = n.args[0];
        if(!Node.rules[name]) Node.rules[name] = [];
        n.args[1].forEach( r => {
          Node.rules[name].push(r.args);
        });
      }
    });
  }

  static setStart(rule) {
    Node.start = rule;
  }

  static normalize() {
    Node.reduceSingleRules();
    Node.findTerminals();
    Node.addDelimiter();
    Node.substitudeNonterminals();
    Node.transformLookaheads();
    Node.removeUnusedRules();
    Node.bufferize();
  }

  static reduceSingleRules() {
    var succ = false;
    _.each(Node.rules, (r, n) => {
      if(r.length == 1 && r[0].length == 1) {
        Node.substitudeRule(n,r[0][0]);
        delete Node.rules[n];
      }
    })
  }

  static substitudeRule(searchR, substitudeR) {
    _.each(Node.rules, (rs,n) => {
      rs.forEach( (r,i) => {
        rs[i] = r.map (rname => rname===searchR? substitudeR : rname);
      });
    });
  }

  static addDelimiter() {
    _.each(Node.rules, (rs, n) => {
      Node.rules[n]= rs.map( r => r.reduce( (s,c) => {
        if(c.type === 'N' && s.length > 0 && s[0].type === 'N' ) {
          return s.concat([{type:'T',name:'DEL'},c]);
        } else {
          return s.concat([c]);
        }
      },[]));
    });
  }

  static findTerminals() {
    _.each(Node.rules, (rs,name) => {
      rs.forEach( (r,i) => {
        rs[i] = r.map( Node.mapSymbol );
      });
    })
  }

  static transformLookaheads() {
    let rc = 0;
    _.each(Node.rules, (rs,name) => {
      let newrules = {};
      newrules[name] = rs;
      let success = true;
      while( success ) {
        success = false
        _.each(newrules, (rules, name) => {
          let stack = {};
          rules.forEach( (rule, i) => {
            if(rule.length <= 2 ) {
              // already in normalform
            } else if(rule.length > 2) {
              if(!stack[rule[0].name]) stack[rule[0].name] = [];
              stack[rule[0].name].push(rule.slice(1));
              // delete rules[i];
              rules[i] = [ rule[0], {name:name+'_'+rule[0].name, type:'N'} ];
            }
          });
          _.each(stack, (rs, lookahead ) => {
            success = true;
            newrules[name+'_'+lookahead] = rs;
          });
        });
      }
      Node.rules = _.merge(Node.rules, newrules);
    });
  }

  static mapSymbol( symbol ) {
    switch(symbol) {
    case 'String':
      return {name:symbol, type: 'T'}
    default:
      return {name:symbol, type: 'N'}
    }
  }

  static format() {
    _.each(Node.rules, (rs, name) => {
      rs.forEach( r => {
        // console.log(r);
        console.log(`${name.yellow} -> ${r.map( cr => cr.type=='N'?cr.name.yellow:cr.name ).join(' ')}`);
      });
    });
  }

  static substitudeNonterminals() {
    var success = true;
    while( success ) {
      success = false;
      _.each(Node.rules, (rules, name) => {
        rules.forEach( (rule, i) => {
          if(rule.length > 0 && rule[0].type === 'N') {
            success = true;
            delete rules[i];
            Node.rules[rule[0].name].forEach( r => {
              rules.push( r.concat(rule.slice(1)) );
            });
            // console.log(name, Node.rules[name]);
            // console.log(rules[i]);
          }
        });
        Node.rules[name] = rules.filter( r => !!r );
      });
    }
  }

  static removeUnusedRules() {
    var used = {};
    var succ = true;
    while( succ ) {
      succ = false;
      used = {};
      used[Node.start] = true;
      _.each(Node.rules, (rs, name) => {
        rs.forEach( r => {
          if(r.length > 1 )
            used[r[1].name] = true;
        });
      });
      Object.keys(Node.rules).forEach( name => {
        if(!used[name]) {
          succ = true;
          delete Node.rules[name];
        }
      });
    }
  }

  static bufferize() {
    var rc = 2;
    var buffer = {};
    var cMap = {};
    var terminalMap = {
      "String": 3,
      "DEL": 1
    };
    var toHex = function(i) {
      var s = i.toString(16);
      if(s.length % 2 == 1) s = "0"+s;
      return s;
    }
    cMap[Node.start] = 1;
    _.each( Node.rules, ( rs, name ) => {
      if(!cMap[name]) cMap[name] = rc++;
      buffer[cMap[name]] = rs.map( r => {
        if( r.length == 1 ) {
          return [terminalMap[r[0].name]];
        } else {
          if(!cMap[r[1].name]) cMap[r[1].name] = rc++;
          return [terminalMap[r[0].name], cMap[r[1].name]];
        }
      });
    });
    var buf= "";
    _.each(buffer, ( rs, name ) => {
      buf += _.unique(rs.map( r=> toHex(name)+r.map(t => toHex(t)).join('') )).join('');
    });
    return buf;
  }

  constructor( name, args ) {
    this.name = name;
    this.args = args;
  }

}

module.exports = Node;
