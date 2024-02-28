%{
#include<stdio.h>
#include<stdlib.h>
%}

/**
* return nl as a token otherwise it does not work sometimes, becuase of buffer issue
*/
%token A B nl

/**
* for epsilon give space | like this
* for concatenation provide space between two tokens
* put tokens on rhs of production
*/
%%
/**
* a*b*
*/
start: X Y nl {return 1;};
X: A |  ;
Y: B |  ;
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