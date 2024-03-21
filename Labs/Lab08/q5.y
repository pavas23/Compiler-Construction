%{
#include<stdlib.h>
#include<stdio.h>
int yylex(void);
%}

%token INTEGER
%left '+' '-'
%left '*' '/'
%right '^'

%%
line: expr '\n' {printf("%d\n",$1);}
;
expr: expr '+' expr {$$ = $1 + $3;}
	 | expr '-' expr {$$ = $1 - $3;}
	 | expr '*' expr {$$ = $1 * $3;}
	 | expr '^' expr {$$ = $1 ^ $3;}
	 | '(' expr ')' {$$ = $2;}
	 | INTEGER  {$$ = $1;}
;
%%

int main(){
	yyparse();
	return 0;
}

void yyerror(char* s){
	fprintf(stderr,"%s\n");
	exit(0);
}