%{
#include<stdio.h>
%}

%%
bits- {ECHO; yymore();}
hyd ECHO;
%%

int main(){
	yylex();
	return 1;
}

