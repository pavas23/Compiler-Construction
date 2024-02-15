%{
#include<stdio.h>
%}

%%
foobar {ECHO; printf("\n"); yyless(3); printf("\n%s\n",yytext);}
[a-z]+ ECHO;
%%

int main(){
	yylex();
	return 0;
}

