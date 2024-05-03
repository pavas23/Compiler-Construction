%{
	#include "node.h"
    #include "y.tab.h"
    #include<stdio.h>
    #include<math.h>
    #include<string.h>
    #include<stdlib.h>
    #include<limits.h>
    int line_number = 1;
%}

A [aA]
B [bB]
C [cC]
D [dD]
E [eE]
F [fF]
G [gG]
H [hH]
I [iI]
J [jJ]
K [kK]
L [lL]
M [mM]
N [nN]
O [oO]
P [pP]
Q [qQ]
R [rR]
S [sS]
T [tT]
U [uU]
V [vV]
W [wW]
X [xX]
Y [yY]
Z [zZ]

INTEGER [0-9]+
REAL {INTEGER}\.{INTEGER}
BOOLEAN {T}{R}{U}{E}|{F}{A}{L}{S}{E}
CHARACTER [a-zA-Z]
ID [a-zA-Z][a-zA-Z0-9_]*

WHITESPACE [ \t]+
NEWLINE [\n]
ASSIGNMENT [:][=]

PROGRAM_KEY {P}{R}{O}{G}{R}{A}{M}
INTEGER_KEY {I}{N}{T}{E}{G}{E}{R} 
REAL_KEY {R}{E}{A}{L} 
BOOLEAN_KEY {B}{O}{O}{L}{E}{A}{N}
CHAR_KEY {C}{H}{A}{R}
VAR_KEY {V}{A}{R}
TO_KEY {T}{O}
DOWNTO_KEY {D}{O}{W}{N}{T}{O}
BEGIN_KEY {B}{E}{G}{I}{N}
END_KEY {E}{N}{D}
OF_KEY {O}{F}

READ {R}{E}{A}{D}
WRITE {W}{R}{I}{T}{E}

AND {A}{N}{D}
OR {O}{R}
NOT {N}{O}{T}

IF {I}{F}
THEN {T}{H}{E}{N}
ELSE {E}{L}{S}{E}
WHILE {W}{H}{I}{L}{E}
FOR {F}{O}{R}
DO {D}{O}

ARRAY {A}{R}{R}{A}{Y}

%%
{WHITESPACE} {}
{NEWLINE} {line_number++;}

"(" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return L_PARENTHESIS;}
")" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return R_PARENTHESIS;}
"[" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return L_BRACE;}
"]" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return R_BRACE;}
"," {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return COMMA;}
";" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return SEMICOLON;}
":" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return COLON;}

"+" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return ADDITIVE_OPERATOR;}
"-" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return ADDITIVE_OPERATOR;}
"*" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return ARITHMETIC_OPERATOR;}
"/" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return ARITHMETIC_OPERATOR;}
"%" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return ARITHMETIC_OPERATOR;}

"=" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return RELATIONAL_OPERATOR;}
"<>" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return RELATIONAL_OPERATOR;}
"<" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return RELATIONAL_OPERATOR;}
">" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return RELATIONAL_OPERATOR;}
"<=" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return RELATIONAL_OPERATOR;}
">=" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return RELATIONAL_OPERATOR;}

{AND} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return BOOLEAN_OPERATOR;}
{OR} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return BOOLEAN_OPERATOR;}
{NOT} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return NOT_OPERATOR;}

{ASSIGNMENT} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return ASSIGNMENT;}

{ARRAY} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return ARRAY;}

{IF} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return IF;}
{THEN} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return THEN;}
{ELSE} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return ELSE;}
{WHILE} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return WHILE;}
{FOR} {strcpy(yylval.tokenObj.lexeme,(yytext)); yylval.tokenObj.line_number=line_number;return FOR;}
{DO} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return DO;}

{PROGRAM_KEY} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return PROGRAM;}
{INTEGER_KEY} {strcpy(yylval.tokenObj.lexeme,(yytext)); yylval.tokenObj.line_number=line_number;return TYPE;}
{REAL_KEY} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return TYPE;}
{BOOLEAN_KEY} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return TYPE;}
{CHAR_KEY} {strcpy(yylval.tokenObj.lexeme,(yytext)); yylval.tokenObj.line_number=line_number;return TYPE;}
{VAR_KEY} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return VAR;}
{BEGIN_KEY} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return BEGIN_KEY;}
{END_KEY} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return END;}
{OF_KEY} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return OF;}
{TO_KEY} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return TO;}
{DOWNTO_KEY} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return DOWNTO;}

"." {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return PERIOD;}

{READ} {strcpy(yylval.tokenObj.lexeme,(yytext)); yylval.tokenObj.line_number=line_number;return READ;}
{WRITE} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return WRITE;}

"\'" {strcpy(yylval.tokenObj.lexeme,(yytext)); yylval.tokenObj.line_number=line_number;return SINGLE_QUOTE;}
"//".*\n {line_number++;}
"\'"."\'" {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return CHAR_INPUT;}

\"([^\']|\\\')*\" {
   strcpy(yylval.tokenObj.lexeme,(yytext));
   yylval.tokenObj.line_number=line_number;
   int len = yyleng;
    for(int i=1;i<len-1;i++){
        if(yytext[i]=='\n') line_number++;   
    }
    return STRING_INPUT_QUOTES; 
}

{INTEGER} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return INTEGER;}
{REAL} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return REAL;}
{ID} {strcpy(yylval.tokenObj.lexeme,(yytext));yylval.tokenObj.line_number=line_number;return ID;}
%%

int yywrap() {
    return 1;
}