 /* 
lex program to read from one file and write to another file as shown as an action but replacing CS with Computer Science
give []CS instead of CS otherwise for MATHEMATICS also it will take CS as a lexeme and replace it so put sapce in front of CS.
 */

%{
#include<stdio.h>
#include<stdlib.h>
char str[] = "Computer Science";
%}

%%
[' ']CS {
	fprintf(yyout," %s",str);
}
%%

int main(){
	yyin = fopen("sample.txt","r");
	yyout = fopen("output.txt","w");
	yylex();
	return 0;
}


