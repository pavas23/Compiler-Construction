%{
#include<stdio.h>
%}

%%
a {ECHO;
printf("\n");
printf("yytext before yymore() is %s\n",yytext);
yymore();
printf("yytext after yymore() is %s\n",yytext);
}
b ECHO;
%%

int main(){
	yylex();
	return 1;
}

