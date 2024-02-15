%{
#include<stdio.h>
%}

%%
[a-zA-Z \t][a-zA-Z]* printf("%s\n",yytext);
[0-9]* {}
[?%$#] {}
%%

main(){
	yyin = fopen("sample.txt","r");
	yylex();
}

