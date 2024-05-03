%{
    #include<stdio.h>
    #include<math.h>
    #include<string.h>
    #include<stdlib.h>
    #define MAX_LENGTH 100
    
    int line_number = 1;

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
        printf("--------------------------------------------------------\n");
        struct RowEntry* current = symbol_table;
        while (current != NULL) {
            printf("%-25s%-25s%d\n", current->lexeme, current->token, current->line_number);
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

"(" {insert_row(yytext, "L_PARENTHESIS", line_number);}
")" {insert_row(yytext, "R_PARENTHESIS", line_number);}
"[" {insert_row(yytext, "L_BRACE", line_number);}
"]" {insert_row(yytext, "R_BRACE", line_number);}
"," {insert_row(yytext, "COMMA", line_number);}
";" {insert_row(yytext, "SEMICOLON", line_number);}
":" {insert_row(yytext, "COLON", line_number);}

"-" {insert_row(yytext, "ARITHMETIC_OPERATOR", line_number);}
"+" {insert_row(yytext, "ARITHMETIC_OPERATOR", line_number);}
"*" {insert_row(yytext, "ARITHMETIC_OPERATOR", line_number);}
"/" {insert_row(yytext, "ARITHMETIC_OPERATOR", line_number);}
"%" {insert_row(yytext, "ARITHMETIC_OPERATOR", line_number);}

"=" {insert_row(yytext, "RELATIONAL_OPERATOR", line_number);}
"<>" {insert_row(yytext, "RELATIONAL_OPERATOR", line_number);}
"<" {insert_row(yytext, "RELATIONAL_OPERATOR", line_number);}
">" {insert_row(yytext, "RELATIONAL_OPERATOR", line_number);}
"<=" {insert_row(yytext, "RELATIONAL_OPERATOR", line_number);}
">=" {insert_row(yytext, "RELATIONAL_OPERATOR", line_number);}

{AND} {insert_row(yytext, "BOOLEAN_OPERATOR", line_number);}
{OR} {insert_row(yytext, "BOOLEAN_OPERATOR", line_number);}
{NOT} {insert_row(yytext, "BOOLEAN_OPERATOR", line_number);}

{ASSIGNMENT} {insert_row(yytext, "ASSIGNMENT", line_number);}

{ARRAY} {insert_row(yytext,"ARRAY",line_number);}

{IF} {insert_row(yytext, "IF", line_number);}
{THEN} {insert_row(yytext, "THEN", line_number);}
{ELSE} {insert_row(yytext, "ELSE", line_number);}
{WHILE} {insert_row(yytext, "WHILE", line_number);}
{FOR} {insert_row(yytext, "FOR", line_number);}
{DO} {insert_row(yytext, "DO", line_number);}

{PROGRAM_KEY} {insert_row(yytext,"KEYWORD",line_number);}
{INTEGER_KEY} {insert_row(yytext,"KEYWORD",line_number);}
{REAL_KEY} {insert_row(yytext,"KEYWORD",line_number);}
{BOOLEAN_KEY} {insert_row(yytext,"KEYWORD",line_number);}
{CHAR_KEY} {insert_row(yytext,"KEYWORD",line_number);}
{VAR_KEY} {insert_row(yytext,"KEYWORD",line_number);}
{BEGIN_KEY} {insert_row(yytext,"KEYWORD",line_number);}
{END_KEY} {insert_row(yytext,"KEYWORD",line_number);}
{OF_KEY} {insert_row(yytext,"KEYWORD",line_number);}
{TO_KEY} {insert_row(yytext,"KEYWORD",line_number);}
{DOWNTO_KEY} {insert_row(yytext,"KEYWORD",line_number);}

"." {insert_row(yytext,"PERIOD",line_number);}

{READ} {insert_row(yytext,"READ",line_number); }
{WRITE} {insert_row(yytext,"WRITE",line_number); }

"\'" {insert_row(yytext,"SINGLE_QUOTE",line_number); }
"//".*\n {line_number++;}
"\'.\'" {insert_row(yytext,"CHAR_INPUT",line_number);}
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
}

{INTEGER} {insert_row(yytext,"INTEGER",line_number);}
{REAL} {insert_row(yytext,"REAL",line_number); }
{CHARACTER} {insert_row(yytext,"CHARACTER",line_number);}
{ID} {insert_row(yytext,"ID",line_number);}

\"([^\"\n]|\\\")*\n {
    insert_row("\"","DOUBLE_QUOTE",line_number); 
    int len = yyleng;
    char *str = (char *)malloc(len*sizeof(char));
    for(int i=1;i<len-1;i++){
        if(yytext[i]=='\n') line_number++;
        str[i-1] = yytext[i];
    }
    insert_row(str,"INVALID",line_number);
    line_number++; 
}

. {insert_row(yytext,"INVALID",line_number);}
%%

int main(int argc, char* argv[]){
    char filename[MAX_LENGTH];

    // checking if correct number of command line arguments are provided
    if(argc != 2){
        printf("Arguments provided are wrong\n");
        return 1;
    }
    strncpy(filename,argv[1],MAX_LENGTH);
    filename[MAX_LENGTH-1] = '\0';

    yyin = fopen(filename,"r");
    yylex();
    print_symbol_table();
    return 0;
}