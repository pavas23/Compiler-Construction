%{
	#include<stdio.h>
%}

%%
begin printf("Compiler");
[a-z]+ printf("Compiler Design");
%%

main()
{
yylex();
}


