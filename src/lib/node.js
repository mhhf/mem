'use strict';

var _ = require('lodash');
var Rule = require('./rules.js');
var SHA3 = require('sha3');


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
    if (this.terminal) args.push(`shape=box, label="${this.terminal}"`);
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

  _propagate (parent) {
    let production = [];
    production.push('(');
    _.each(this.nodes, (node, name) => {
      if( node.terminal ) {
        // let t = new Rule(node.name, node.terminal);
        production.push(node.terminal);
      } else if(node.array) {
        production.push(`R_${Node.rc}`);
        node._propagate(`R_${Node.rc++}`)
        production.push(parent);
        console.log(`${parent} -> epsilon;`);
        // Add epsilon rule
      } else {
        // let name = new Rule(node.name+'/name', 'name');
        production.push('Name');
        // Generate 512-bit digest.
        var d = new SHA3.SHA3Hash(256);
        d.update(node.name);
        let _id = d.digest('hex').slice(0,14);
        // let tId = new Rule(node.name, _id);
        production.push(_id);
        if (Object.keys(node.nodes).length == 1 && node.nodes[Object.keys(node.nodes)[0]].terminal) {
          production.push(node.nodes[Object.keys(node.nodes)[0]].terminal);
        } else {
          production.push(`R_${Node.rc}`);
          node._propagate(`R_${Node.rc++}`);
        }
      }
    });
    production.push(')');
    console.log(`${parent} -> ${production.join(' ')};`);
    // parent.addTransition(production);
  }

}
Node.rc = 0;
Node.nodes={};
Node.toGrammer = function() {
  var startRule = new Rule(`R_${Node.rc++}`);
  var rules = Node.nodes['#']._propagate(startRule);
  // var endRule = new Rule('EOF','EOF');
  // _.each(rules, r => r.addTransition([endRule]));
  // Rule.propagateLookahead();
}

module.exports = Node;
