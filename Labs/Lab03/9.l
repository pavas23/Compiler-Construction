%{
	#include<stdio.h>
%}

%%
. {ECHO;}
%%

main()
{
yylex();
}
