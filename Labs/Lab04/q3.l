%{
#include<stdio.h>
%}

%%
[a-zA-Z \t][a-zA-Z]* fprintf(yyout,"%s\n", yytext);
%%

main(){
	yyin = fopen("sample.txt","r");
	yyout = fopen("output.txt","w");
	yylex();
}


