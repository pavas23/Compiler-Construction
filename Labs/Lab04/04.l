 // lex program to count number of words and numbers found in a text file

%{
#include<stdio.h>
int wordCount = 0;
int numCount  = 0;
%}

%%
[a-zA-Z]+ {wordCount++;}
[0-9]* {numCount++;}
[?%$#*\n] {}
. {}
%%

int main(){
	yyin = fopen("sample.txt","r");
	yylex();
	printf("Word Count is %d\n",wordCount);
	printf("Number Count is %d\n",numCount);
	return 0;
}

