%{
#include<stdio.h>
#include<stdlib.h>
%}

%token A B

%%
/**
* a^nb^n
*/
stmt: S;
S: A S B | ;
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