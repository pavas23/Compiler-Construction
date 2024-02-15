%{
#include<stdio.h>
%}

%%
[a-zA-Z \t][a-zA-Z]* printf("%s\n", yytext);
%%

int main(){
	yyin = fopen("sample.txt","r");
	yylex();
}

