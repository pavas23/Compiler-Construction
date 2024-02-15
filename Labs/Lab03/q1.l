%{
	#include<stdio.h>
	int num = 0;
	int flt = 0;
%}

dot [.]

%%
[0-9]+{dot}[0-9]+ {flt=1;}
[0-9]+ {num=1;}
\n return;
%%

main()
{
yylex();
if(flt == 1){
	printf("Float\n");
}else if(num == 1){
	printf("Number\n");
}else{
	printf("Invalid\n");
}
}

int yywrap(){return(1);}