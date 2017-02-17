/* description: Parses end evaluates mathematical expressions. */

/* lexical grammar */
%lex
%%
\s+                   {/* skip whitespace */}
\w+                   {return 'SYMBOL';}
<<EOF>>               {return 'EOF';}

/lex

/* operator associations and precedence */

%start DSLS

%% /* language grammar */

DSLS: DSL
    {return $1;}
    ;

DSL: DEFINITION DSL
   { $$ = $1.concat($2); }
   | STARTRULE DSL
   { $$ = $2; }
   | EOF
   { $$ = []; }
   ;

STARTRULE: START SYMBOL NEWLINE
   { yy.Node.setStart($2); }
   ;

DEFINITION: DEF SYMBOL ":" NEWLINE INDENT OPTIONS DEDENT
          { $$ = [new yy.Node("def", [$2, $6])]; }
          ;

OPTIONS: OPTION NEWLINE OPTIONS
       { $$ = [new yy.Node("option", $1 )].concat($3); }
       | OPTION NEWLINE
       { $$ = [new yy.Node("option", $1 )]; }
       | NEWLINE OPTIONS
       { $$ = $2; }
       | NEWLINE
       { $$ = []; }
       ;

OPTION: SYMBOL OPTION
      { $$ = [$1].concat($2); }
      | SYMBOL
      { $$ = [$1]; }
      ;
