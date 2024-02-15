%{
#include<stdio.h>
%}

%%
ab* printf("%s valid string of ab* \n",yytext);
d*c printf(" %s valid string of d*c \n",yytext);
%%

main()
{
yylex();
}


