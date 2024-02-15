%{
#include<stdio.h>
%}

%%
. {printf("Good:\n");}
%%

main()
{
yylex();
}


