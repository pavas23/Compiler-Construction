	// lex program to count number of lines, words, characters and blank spaces from a C file
 
%{
#include<stdio.h>
int numLines = 0;
int numWords = 0;
int numChars = 0;
int numSpaces = 0;
%}

%%
[a-zA-Z] {numChars++;}
[a-zA-Z]* {numWords++;}
[' '] {numSpaces++;}
[\n] {numLines++;}
. {}
%%

int main(){
	yyin = fopen("sample.txt","r");
	yylex();
	printf("Number of lines is %d\n",numLines);
	printf("Number of words is %d\n",numWords);
	printf("Number of characters is %d\n",numChars);
	printf("Number of spaces is %d\n",numSpaces);
	return 0;
}


