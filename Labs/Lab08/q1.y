%{
#include<stdio.h>
%}

%token NUM

%%
S:val{return 1;}
val:NUM{$$=$1;}
%%

void main(){
	printf("Enter the number:\n");
	yyparse();
	printf("Value is: %d\n",yylval);
	exit(0);
}

void yyerror(){
	printf("Invalid Statement:\n");
	exit(0);
}