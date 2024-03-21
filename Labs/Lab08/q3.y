%{
#include<stdio.h>
%}

%union {int ival; double dval;}
%token <ival> INTEGER	
%token <dval> NUMBER
%type <dval> sum

%%
sum:
INTEGER'+'INTEGER {$$ = (double)($1+$3); printf("%lf\n",$$);}
| NUMBER'+'NUMBER {$$ = $1 + $3; printf("%lf\n",$$);}
| INTEGER'+'NUMBER {$$ = (double)($1+$3); printf("%lf\n",$$);}
| '\n' {};
%%

int main(){
	yyparse();
	return 0;
}

void yyerror(){
	printf("Invalid Statement:\n");
	exit(0);
}