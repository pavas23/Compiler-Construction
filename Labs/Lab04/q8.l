%{
#include<stdio.h>
int npink = 0;
int npin = 0;
int nink = 0;
%}

%%
pink {npink++; REJECT;}
pin {npin++; REJECT;}
ink {nink++; REJECT;}
\n return;
. {printf("%c\n",*yytext);}
%%

main(){
	yylex();
	printf("\n");
	printf("npink : %d\n",npink);
	printf("npin : %d\n",npin);
	printf("nink : %d\n",nink);
	return 0;
}

