%{
#include<stdio.h>
int cnt = 0;
%}

%s start
%x single
%x multi

%%
<single>\n {cnt++; BEGIN(start);}
<single>. {}
<multi>\n {}
<multi>"*/" {cnt++; BEGIN(start);}
<multi>. {}
<INITIAL,start>. {fprintf(yyout,"%s",yytext);}
<INITIAL,start>"//" {BEGIN(single);}
<INITIAL,start>"/*" {BEGIN(multi);}
%%

int main(){
	yyin = fopen("sample.c","r");
	yyout = fopen("output.c","w");
	yylex();
	printf("%d\n",cnt);
	return 0;
}


