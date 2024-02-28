%{
#include<stdio.h>
#include<stdlib.h>
%}

%token NUM WORD

%%
sent: WORDS NUM
{
/**
* sent is the start symbol as mentioned in first line
* action to be performed
*/
};

WORDS: WORD WORDS | WORD;
%%

void main(){
	printf("Enter the sentence:\n");
	yyparse();
	printf("Valid Statement\n");
	exit(0);
}

void yyerror(){
	printf("Invalid Statement\n");
	exit(0);
}