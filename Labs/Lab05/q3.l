 // it will match any expression starting with " and will scan until another " double quote occurs and ignores them rest of string it echoes
 
%{
#include<stdio.h>
%}

%%
\" while(input() != '"');
ECHO;
%%

int main(){
	yylex();
}

