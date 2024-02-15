 // subtract 1 for space, yyleng gives length of current regular expression which it matches

%{
#include<stdio.h>
int maxLen = 0;
char str[200];
%}

%%
[a-zA-Z]*[' '] {
	if(yyleng-1 > maxLen){
		maxLen = yyleng-1;
		strcpy(str,yytext);
	}
}
[\n] {}
. {}
%%

int main(){
	yyin = fopen("sample.txt","r");
	yylex();
	printf("Longest String is %s\n",str);
	printf("length is %d\n",maxLen);
	return 0;
}

