'use strict';

var _ = require('lodash');
var Rule = require('./rules.js');

class Node {
  constructor (name, terminal) {
    if( Node.nodes[name] ) return Node.nodes[name];
    Node.nodes[name] = this;
    this.name = name;
    this.nodes = {};
    this.required = true;
    this.terminal = (typeof terminal === 'string')?terminal:false;
    this.array = false;
  }

  addNode (name) {
    let node = new Node(name);
    Node.nodes[name] = node;
    this.nodes[name] = node;
    return node;
  }

  format() {
    let args = [];
    if (this.terminal) args.push('shape=box');
    if (this.required) args.push('color=red');
    if (this.array) args.push('style=dashed');
    if (args.length > 0) console.log(`"${this.name}" [${args.join(', ')}];`);
    _.each(this.nodes, (node, name) => {
      console.log(`"${this.name}" -> "${name}";`);
      node.format();
    });
  }

  propagate ( parents ) {
    if( this.terminal ) {
      let t = new Rule(this.name, this.terminal);
      let rule = new Rule('R_'+(Node.rc++));
      _.each(parents, r => r.addTransition([t,rule]));
      return [rule];
    }
    var arrayRule;
    if( this.array ) {
      arrayRule = new Rule('R_'+(Node.rc++));
      _.each(parents, rule => {
        rule.addTransition([arrayRule]);
      })
      parents = [arrayRule];
      // parents = _.union(parents, node.propagate(parents, parents))
    }
    _.each(this.nodes, (node, name) => {
      if( !node.required ) {
        parents = _.union( node.propagate(parents), parents );
      } else {
        parents = node.propagate(parents);
      }
    });
    if( this.array ) {
      _.each(parents, rule => {
        rule.addTransition([arrayRule]);
      });
    }
    return parents;
  }
}
Node.rc = 0;
Node.nodes={};
Node.toGrammer = function() {
  var startRule = new Rule('#');
  var rules = Node.nodes['#'].propagate([startRule]);
  var endRule = new Rule('EOF','EOF');
  _.each(rules, r => r.addTransition([endRule]));
  Rule.propagateLookahead();
}

module.exports = Node;
