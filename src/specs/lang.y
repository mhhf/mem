/* description: Parses end evaluates mathematical expressions. */

/* lexical grammar */
%lex
%%
\s+                   {/* skip whitespace */}
\w+                   {return 'SYMBOL';}
<<EOF>>               {return 'EOF';}

/lex

/* operator associations and precedence */

%start DSL

%% /* language grammar */

DSL: SYMBOL
   { return $1; }
   ;
