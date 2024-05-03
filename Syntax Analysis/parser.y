%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define MAX_LENGTH 100
extern FILE* yyin;
int yylex();
void yyerror();
void print_symbol_table();
%}

%token L_PARENTHESIS R_PARENTHESIS L_BRACE R_BRACE COMMA SEMICOLON COLON
%token RELATIONAL_OPERATOR
%token ASSIGNMENT ARRAY SINGLE_QUOTE NOT_OPERATOR
%token IF THEN ELSE WHILE FOR DO OF TO DOWNTO
%token PROGRAM PERIOD BEGIN_KEY END VAR TYPE
%token READ WRITE CHAR_INPUT BOOLEAN_OPERATOR
%token INTEGER REAL BOOLEAN ID STRING_INPUT_QUOTES INVALID
%left ARITHMETIC_OPERATOR ADDITIVE_OPERATOR BOOLEAN_OPERATOR RELATIONAL_OPERATOR R_PARENTHESIS
%right NOT_OPERATOR

/**
%type start prog prog_body var_body begin_body id_list array_declare read_statement write_statement assignment_statement block conditional_statements looping_statements expression arithmetic_expression boolean_expression comparision_exp loop_body loop_block for_val for_expression
*/

%%
start: prog{
	printf("valid input\n");
	return 1;
};

/**
* start symbol of grammar
*/
prog: PROGRAM ID SEMICOLON prog_body PERIOD {

};

prog_body:	VAR var_body BEGIN_KEY begin_body END
			| BEGIN_KEY begin_body END {

};

var_body:	id_list COLON TYPE SEMICOLON var_body
			| id_list COLON TYPE SEMICOLON
			| id_list COLON ARRAY array_declare OF TYPE SEMICOLON var_body
			| id_list COLON ARRAY array_declare OF TYPE SEMICOLON {

};

array_declare:	L_BRACE INTEGER PERIOD PERIOD INTEGER R_BRACE {

};

id_list:	ID COMMA id_list
			| ID {

};

/**
* main body of pascal program
*/
begin_body:	read_statement begin_body
			| write_statement begin_body
			| assignment_statement begin_body
			| block begin_body
			| conditional_statements begin_body
			| looping_statements begin_body
			| {
};

read_statement:	READ L_PARENTHESIS ID R_PARENTHESIS SEMICOLON
				| READ L_PARENTHESIS ID L_BRACE arithmetic_expression R_BRACE R_PARENTHESIS SEMICOLON {

};

id_list_read_write:	ID
					| STRING_INPUT_QUOTES
					| ID L_BRACE arithmetic_expression R_BRACE
					| ID COMMA id_list_read_write
					| ID L_BRACE arithmetic_expression R_BRACE COMMA id_list_read_write
					| STRING_INPUT_QUOTES COMMA id_list_read_write{

};

write_statement:	WRITE L_PARENTHESIS R_PARENTHESIS SEMICOLON
					| WRITE L_PARENTHESIS id_list_read_write R_PARENTHESIS SEMICOLON {

};

assignment_statement:	ID ASSIGNMENT assignment_expression SEMICOLON
						| ID L_BRACE arithmetic_expression R_BRACE ASSIGNMENT assignment_expression SEMICOLON{

};

assignment_expression:	CHAR_INPUT
						| arithmetic_expression

arithmetic_expression:	arithmetic_expression ARITHMETIC_OPERATOR arithmetic_expression_util
						| arithmetic_expression ADDITIVE_OPERATOR arithmetic_expression_util
						| L_PARENTHESIS arithmetic_expression R_PARENTHESIS
						| INTEGER
						| REAL
						| ID 
						| ID L_BRACE arithmetic_expression R_BRACE
						| ADDITIVE_OPERATOR arithmetic_expression_util {
};

arithmetic_expression_util:	L_PARENTHESIS arithmetic_expression R_PARENTHESIS
							| INTEGER
							| REAL
							| ID 
							| ID L_BRACE arithmetic_expression R_BRACE

block:	BEGIN_KEY begin_body END {
};

loop_block:	BEGIN_KEY loop_body END {
};

/**
* separate loop block to prevent nesting of loops
*/
loop_body:	read_statement begin_body
			| write_statement begin_body
			| assignment_statement begin_body
			| block begin_body
			| conditional_statements begin_body
			| {
};

comparision_exp:	comparision_exp BOOLEAN_OPERATOR comparision_exp
					| relational
					| ID BOOLEAN_OPERATOR comparision_exp
					| comparision_exp BOOLEAN_OPERATOR ID
					| ID BOOLEAN_OPERATOR ID
					| L_PARENTHESIS comparision_exp R_PARENTHESIS
					| NOT_OPERATOR comparision_exp
					| NOT_OPERATOR ID
					| ID

conditional_statements:	IF comparision_exp THEN block SEMICOLON
						| IF comparision_exp THEN block ELSE block SEMICOLON {

};

relational: arithmetic_expression RELATIONAL_OPERATOR arithmetic_expression{

};

looping_statements:	WHILE comparision_exp DO loop_block SEMICOLON
					| FOR  for_expression DO loop_block SEMICOLON{

};

/**
* value of condition in for loop
*/
for_val:	arithmetic_expression {

};

for_expression:	ID ASSIGNMENT for_val TO for_val
				| ID L_BRACE arithmetic_expression R_BRACE ASSIGNMENT for_val TO for_val
				| ID L_BRACE arithmetic_expression R_BRACE ASSIGNMENT for_val DOWNTO for_val
				| ID ASSIGNMENT for_val DOWNTO for_val {

};
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
	yyparse();
	return 0;
}

void yyerror(){
	printf("syntax error\n");
	exit(0);
}