'use strict';

var _ = require('lodash');
var colors = require('colors');

class Rule {

  static contextualize() {
    _.each(Rule.rules, rule => {
      rule.findContext();
    });
  }

  static addDelimiter() {
    _.each(Rule.rules, rule => rule.addDelimiter());
  }
  
  static _format() {
    console.log(`digraph A {`);
    _.each(Rule.rules, (rule, name) => {
      _.each(rule.transitions, t => {
        // console.log(`"${name.yellow}" -> "${t.join('" -> "')}";`);
        console.log(`${name.yellow} -> ${t.map( cr => cr.terminal ).join(' ')}`);
      });
    });
    console.log(`}`);
  }

  static format() {
    console.log(`digraph A {`);
    _.each(Rule.rules, (rule, name) => {
      _.each(rule.transitions, t => {
        // console.log(`"${name.yellow}" -> "${t.join('" -> "')}";`);
        console.log(`(${rule.ctx.green}) ${name.yellow} -> ${t.map( cr => cr.terminal?cr+'('+cr.ctx.green+')':cr.name.yellow+'('+cr.ctx.green+')' ).join(' ')}`);
      });
    });
    console.log(`}`);
  }

  static propagateSingleTerminals() {
    _.each(Rule.rules, (rule, name) => {
      rule.propagateTerminals();
    });
  }

  static eliminateEpsilonTransitions() {
    let epsRules = [];
    let toRemove = [];
    // find rules which have epsilon transitions
    _.each(Rule.rules, (rule, name) => {
      if (rule.transitions.filter( t => t.length === 0).length > 0) {
        epsRules.push(new Rule(name));
        if(rule.transitions.length == 1) toRemove.push(name);
      }
      // remove epsilon transitions from rule
      rule.transitions = rule.transitions.filter( t => t.length !== 0  );
    });
    // substitude epsilon rules
    _.each(Rule.rules, (rule, name) => {
      rule.transitions.forEach( t => {
        let diff = _.difference(t,epsRules);
        if(diff.length != t.length) rule.transitions.push(diff);
        // removes the transition rules that are holding illegal rules
        rule.transitions = rule.transitions.filter( r => toRemove.reduce( (s,c) => s && r.indexOf(new Rule(c))==-1, true ) );
      });
    });
    return epsRules.length > 0;
  }

  static propagateLookahead() {
    let succ = false;
    _.each(Rule.rules, (rule, name) => {
      let rsuccess = rule.propagateLookahead();
      succ = succ || rsuccess;
    });
    return succ;
  }

  static clearUnused() {
    let toRemove = [];
    Object.keys(Rule.rules).forEach( ruleName => {
      let found = false;
      // Terminals are kept
      if(Rule.rules[ruleName].terminal) return true;
      // startrule is kept
      if(Rule.rules[ruleName].start) return true;
      _.each(Rule.rules, (rule, name) => {
        let filtered = _.filter(_.flatten(rule.transitions), r => r.name === ruleName );
        found = found || filtered.length > 0;
        // console.log(found);
      });
      if(!found) {
        delete Rule.rules[ruleName];
      }
    });
  }

  static splitToNormalForm() {
    let succ = false;
    _.each(Rule.rules, (rule, name) => {
      let rsuccess = rule.splitToNormalForm();
      succ = succ || rsuccess;
    });
    while( Rule.eliminateEpsilonTransitions() ) {}
    return succ;
  }
  
  static serialize() {
    return _.map(Rule.rules, rule => rule.serialize()).join('');
  }

  constructor( name, terminal ) {
    if( Rule.rules[name] ) return Rule.rules[name];
    Rule.rules[name] = this;
    this.start = false;
    this.name = name;
    if( typeof Rule.terminals[terminal] === 'number' ) {
      this.terminal = true;
      this.type = terminal;
    } else {
      this.terminal = false;
    }
    this.transitions = [];
    this.ctx = name;
  }

  toString() {
    return this.name;
  }

  addTransition( args ) {
    this.transitions.push(args);
  }

  setStart() {
    this.start = true;
    Rule.start = this;
  }

  propagateTerminals() {
    this.transitions = this.transitions.map( t => {
      // Rules with the form R -> AB; and A -> a; will get transformed to R -> aB;
      return t.map( r => ( r.transitions.length == 1 &&
                           r.transitions[0].length == 1 &&
                           r.transitions[0][0].terminal )?r.transitions[0][0]:r );
    });
  }

  splitToNormalForm() {
    let la = {};
    let succ = false;
    this.transitions.forEach( t => {
      if(!la[t[0].name]) la[t[0].name] = [];
      la[t[0].name].push(t);
    });
    _.each(la, (rs, name) => {
      if(rs.length > 1 && !(rs.length == 2 && (rs[0].length === 1 || rs[1].length === 1)) || rs[0].length > 2) {
        succ = true;
        this.transitions = _.difference(this.transitions, rs);
        let rule = new Rule(this.name+'_'+(++Rule.ruleCounter));
        this.transitions.push([rs[0][0]].concat(rule));
        rule.transitions = rs.map( r => r.slice(1));
      }
    });
    return succ;
  }

  propagateLookahead() {
    // 1. get all rules, where the first element is a nonterminal
    let illegalRules = this.transitions.filter( t => !t[0].terminal );
    let succ = illegalRules.length > 0;
    let legalRules = [];
    // 2. clear transition rules from illegalRules
    legalRules = _.difference(this.transitions, illegalRules);
    // 3. propagate the first rule
    let timeoutCounter = 0;
    while(illegalRules.length > 0 && timeoutCounter++ < 100 ) {
      illegalRules = _.flatten(illegalRules.map( rule => {
        return rule[0].transitions.map( r => r.concat(rule.slice(1)));
      }));
      legalRules = legalRules.concat(illegalRules.filter( t => {
        return t.length==0 || t[0].terminal;
      }));
      illegalRules = illegalRules.filter( t => ![0].terminal )
    }
    this.transitions = legalRules;
    return succ;
  }

  setContext (ctx) {
    this.ctx = ctx;
  }

  findContext() {
    this.transitions = this.transitions.map( rule => {
      return rule.map( variable => {
        if( Rule.rules[variable] ) {
          return Rule.rules[variable];
        } else if(Rule.terminals[variable]) {
          let r= new Rule(variable);
          r.setContext(rule.ctx);
          return r;
        } else {
          throw new Error('Symbol '+variable+' is not a Rule, Terminal or Linked!');
        }
      });
    });
  }

  addDelimiter() {
    this.transitions = this.transitions.map( rule => {
      return rule.reduce( (s, c) => {
        if( !c.terminal && s.length > 0 && !s.terminal ) {
          let del = new Rule('DEL'+(Rule.delimiterCounter++));
          if(Rule.delimiterCounter >= 16) throw new Error('you have reached the maximum delimiter count, time to increase it');
          del.terminal = true;
          return s.concat([del, c ]);
        } else {
          return s.concat(c);
        }
      }, []);
    });
  }

  serialize() {
    let code = this.getCode();
    return _.map(this.transitions, t => {
      if( t.length === 2 ) {
        return code + t[0].getCode() + t[1].getCode();
      } else {
        return code + t[0].getCode() + 'ff';
      }
    }).join('');
  }

  getCode() {
    let c;
    if(this.terminal) {
      c = Rule.terminalEncoding[this.type].toString(16);
    } else {
      if(!Rule.sm[this.name]) Rule.sm[this.name] = Rule.sc++;
      c = Rule.sm[this.name].toString(16);
    }
    if(c.length == 1) c = '0' + c;
    return c;
  }

}
Rule.sc = 1;
Rule.sm = {};
Rule.delimiterCounter = 0;
Rule.rules = {};
Rule.ruleCounter = 0;
Rule.terminals = {
  "String": 32,
  "Ipfs": 46,
  "Bool": 1,
  "EOF": 1
}
Rule.terminalEncoding = {
  "Bool": 96,
  "String": 97,
  "Number": 98,
  "EOF": 255
};

module.exports = Rule;
