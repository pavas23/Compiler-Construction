%{
#include<stdio.h>
%}

%%
ab* printf("%s valid string \n",yytext);
%%

main()
{
yylex();
}


