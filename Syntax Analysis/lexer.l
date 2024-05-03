%{
    #include "y.tab.h"
    #include<stdio.h>
    #include<math.h>
    #include<string.h>
    #include<stdlib.h>
    int line_number = 1;

    #define MAX_LENGTH 100

    struct RowEntry {
        char lexeme[MAX_LENGTH];
        char token[MAX_LENGTH];
        int line_number;
        struct RowEntry* next;
    }typedef RowEntry;

    struct RowEntry* symbol_table = NULL;
    struct RowEntry* symbol_table_tail = NULL;

    void insert_row(char* lexeme, char* token, int line_number) {
        struct RowEntry* new_entry = (struct RowEntry*)malloc(sizeof(struct RowEntry));
        strcpy(new_entry->lexeme, lexeme);
        strcpy(new_entry->token, token);
        new_entry->line_number = line_number;
        new_entry->next = NULL;
        if(symbol_table_tail == NULL){
            symbol_table = new_entry;
            symbol_table_tail = new_entry;
        }else{
            symbol_table_tail->next = new_entry;
            symbol_table_tail = symbol_table_tail->next;
        }
    }

    void print_symbol_table() {
        printf("Symbol Table:\n");
        printf("Lexeme                   Token            Line Number\n");
        printf("--------------------------------------------------------------\n");
        struct RowEntry* current = symbol_table;
        while (current != NULL) {
            printf("%-30s%-30s%d\n", current->lexeme, current->token, current->line_number);
            current = current->next;
        }
    }
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

"(" {insert_row(yytext, "L_PARENTHESIS", line_number); return L_PARENTHESIS;}
")" {insert_row(yytext, "R_PARENTHESIS", line_number); return R_PARENTHESIS;}
"[" {insert_row(yytext, "L_BRACE", line_number); return L_BRACE;}
"]" {insert_row(yytext, "R_BRACE", line_number); return R_BRACE;}
"," {insert_row(yytext, "COMMA", line_number); return COMMA;}
";" {insert_row(yytext, "SEMICOLON", line_number); return SEMICOLON;}
":" {insert_row(yytext, "COLON", line_number); return COLON;}

"+" {insert_row(yytext, "ARITHMETIC_OPERATOR", line_number); return ADDITIVE_OPERATOR;}
"-" {insert_row(yytext, "ARITHMETIC_OPERATOR", line_number); return ADDITIVE_OPERATOR;}
"*" {insert_row(yytext, "ARITHMETIC_OPERATOR", line_number); return ARITHMETIC_OPERATOR;}
"/" {insert_row(yytext, "ARITHMETIC_OPERATOR", line_number); return ARITHMETIC_OPERATOR;}
"%" {insert_row(yytext, "ARITHMETIC_OPERATOR", line_number); return ARITHMETIC_OPERATOR;}

"=" {insert_row(yytext, "RELATIONAL_OPERATOR", line_number); return RELATIONAL_OPERATOR;}
"<>" {insert_row(yytext, "RELATIONAL_OPERATOR", line_number); return RELATIONAL_OPERATOR;}
"<" {insert_row(yytext, "RELATIONAL_OPERATOR", line_number); return RELATIONAL_OPERATOR;}
">" {insert_row(yytext, "RELATIONAL_OPERATOR", line_number); return RELATIONAL_OPERATOR;}
"<=" {insert_row(yytext, "RELATIONAL_OPERATOR", line_number); return RELATIONAL_OPERATOR;}
">=" {insert_row(yytext, "RELATIONAL_OPERATOR", line_number); return RELATIONAL_OPERATOR;}

{AND} {insert_row(yytext, "BOOLEAN_OPERATOR", line_number); return BOOLEAN_OPERATOR;}
{OR} {insert_row(yytext, "BOOLEAN_OPERATOR", line_number); return BOOLEAN_OPERATOR;}
{NOT} {insert_row(yytext, "BOOLEAN_OPERATOR", line_number); return NOT_OPERATOR;}

{ASSIGNMENT} {insert_row(yytext, "ASSIGNMENT", line_number); return ASSIGNMENT;}

{ARRAY} {insert_row(yytext,"ARRAY",line_number); return ARRAY;}

{IF} {insert_row(yytext, "IF", line_number); return IF;}
{THEN} {insert_row(yytext, "THEN", line_number); return THEN;}
{ELSE} {insert_row(yytext, "ELSE", line_number); return ELSE;}
{WHILE} {insert_row(yytext, "WHILE", line_number); return WHILE;}
{FOR} {insert_row(yytext, "FOR", line_number); return FOR;}
{DO} {insert_row(yytext, "DO", line_number); return DO;}

{PROGRAM_KEY} {insert_row(yytext,"PROGRAM",line_number); return PROGRAM;}
{INTEGER_KEY} {insert_row(yytext,"TYPE",line_number); return TYPE;}
{REAL_KEY} {insert_row(yytext,"TYPE",line_number); return TYPE;}
{BOOLEAN_KEY} {insert_row(yytext,"TYPE",line_number); return TYPE;}
{CHAR_KEY} {insert_row(yytext,"TYPE",line_number); return TYPE;}
{VAR_KEY} {insert_row(yytext,"VAR",line_number); return VAR;}
{BEGIN_KEY} {insert_row(yytext,"BEGIN",line_number); return BEGIN_KEY;}
{END_KEY} {insert_row(yytext,"END",line_number); return END;}
{OF_KEY} {insert_row(yytext,"OF",line_number); return OF;}
{TO_KEY} {insert_row(yytext,"TO",line_number); return TO;}
{DOWNTO_KEY} {insert_row(yytext,"DOWNTO",line_number); return DOWNTO;}

"." {insert_row(yytext, "PERIOD", line_number); return PERIOD;}

{READ} {insert_row(yytext,"READ",line_number); return READ;}
{WRITE} {insert_row(yytext,"WRITE",line_number); return WRITE;}

"\'" {insert_row(yytext,"SINGLE_QUOTE",line_number); return SINGLE_QUOTE;}
"//".*\n {line_number++;}
"\'.\'" {insert_row(yytext,"CHAR_INPUT",line_number); return CHAR_INPUT;}
\"([^\"\n]|\\\")*\" {
    insert_row("\"","DOUBLE_QUOTE",line_number); 
    int len = yyleng;
    char *str = (char *)malloc(len*sizeof(char));
    for(int i=1;i<len-1;i++){
        if(yytext[i]=='\n') line_number++;
        str[i-1] = yytext[i];
    }
    insert_row(str,"STRING_INPUT",line_number); 
    insert_row("\"","DOUBLE_QUOTE",line_number); 
    return STRING_INPUT_QUOTES;
}

{INTEGER} {insert_row(yytext,"INTEGER",line_number); return INTEGER;}
{REAL} {insert_row(yytext,"REAL",line_number); return REAL;}
{ID} {insert_row(yytext,"ID",line_number); return ID;}

\"([^\"\n]|\\\")*\n {
    insert_row("\"","DOUBLE_QUOTE",line_number); 
    int len = yyleng;
    char *str = (char *)malloc(len*sizeof(char));
    for(int i=1;i<len-1;i++){
        if(yytext[i]=='\n') line_number++;
        str[i-1] = yytext[i];
    }
    insert_row(str,"INVALID",line_number); 
    return INVALID;
}

. {insert_row(yytext,"INVALID",line_number); return INVALID;}
%%