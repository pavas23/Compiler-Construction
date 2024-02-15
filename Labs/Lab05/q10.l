 // write a lex program to simulate calculator with (+,-,*./)

%{
#include<stdio.h>
#include<stdlib.h>
int op1=0;
int op2=0;
int ans = 0;
%}

%%
[0-9]+ {
printf("%s\n",yytext);
op1 = atoi(yytext);
printf("\n%d\n",op1);
while(input() != '+');
printf("%s\n",yytext);
op2 = atoi(yytext);
ans = op1 + op2;
yyterminate();
}
\n return;
%%

int main(){
	yylex();
	printf("ans is %d\n",ans);
	return 0;
}



