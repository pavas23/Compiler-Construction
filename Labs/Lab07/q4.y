%{
#include<stdio.h>
#include<stdlib.h>
%}

%token NUM

%%
val: NUM {printf("Value is: %d\n",yylval); return 1;};

%%

void main(){
	printf("Enter the number:\n");
	yyparse();
	exit(0);
}

void yyerror(){
	printf("Invalid Statement\n");
	exit(0);
}