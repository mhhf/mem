'use strict';

var Lexer = require("lex");

var indent = [0];
var row = 1;
var col = 1;

var lexer = module.exports = new Lexer(function (char) {
    throw new Error("Unexpected character at row " + row + ", col " + col + ": " + char);
});

lexer.addRule(/\n+/, function (lexeme) {
    col = 1;
    row += lexeme.length;
    return "NEWLINE";
});

lexer.addRule(/\/\/[^\n]*\n/, function (lexeme) {
    col = 1;
    row += 1;
    return "NEWLINE";
});

lexer.addRule(/^ */gm, function (lexeme) {
    var indentation = lexeme.length;

    col += indentation;

    if (indentation > indent[0]) {
        indent.unshift(indentation);
        return "INDENT";
    }

    var tokens = [];

    while (indentation < indent[0]) {
        tokens.push("DEDENT");
        indent.shift();
    }

    if (tokens.length) return tokens;
});

lexer.addRule(/ +/, function (lexeme) {
    col += lexeme.length;
});

lexer.addRule(/def/, function (lexeme) {
    this.yytext = lexeme;
    col += lexeme.length;
    return "DEF";
});

lexer.addRule(/start/, function (lexeme) {
    this.yytext = lexeme;
    col += lexeme.length;
    return "START";
});

lexer.addRule(/[a-zA-Z]+/, function (lexeme) {
    col += lexeme.length;
    this.yytext = lexeme;
    return "SYMBOL";
});

lexer.addRule(/\:/, function () {
    col++;
    this.yytext = ":";
    return ":";
});

lexer.addRule(/$/, function () {
    return "EOF";
});

