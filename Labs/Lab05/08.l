 // matching a right context, notation r1/r2 where the regexp r1 will match only if the right context matches th regex r2. The longest match is computed using r1 and r2 concatenated together

%{
#include<stdio.h>
%}

%%
a+/b {printf("T_AB: %s\n",yytext);}
a+/c {printf("T_AC: %s\n", yytext);}
b {printf("T_B: %s\n", yytext);}
c {printf("T_C: %s\n", yytext);}
. ECHO;
\n return 1;
%%

int main(){
	yylex();
}

