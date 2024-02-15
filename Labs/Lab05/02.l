 // it will read input twice from terminal as well as file
 
%{
#include<stdio.h>
%}

%%
[a-z]+ {printf("\nLower case token=");
ECHO; return;
}
[a-zA-Z]+ {ECHO;}
%%

int main(){
	yylex();
	printf("\nend of first yylex:\n");
	FILE* fp;
	fp = fopen("input.txt","r+");
	printf("\n Begin of 2nd lex operation on file\n");
	yyrestart(fp);
	yylex();
	printf("\nEnd of 2nd lex operation on file\n");
}

