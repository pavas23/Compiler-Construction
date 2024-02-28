%{
#include<stdio.h>
#include<stdlib.h>
%}

%token plus open closeBracket mult id

%%
E: E plus T | T {return 1;};
T: T mult F | F;
F: open E closeBracket | id;
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