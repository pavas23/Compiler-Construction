%{
#include<stdio.h>
int sum;
%}

%token NUM

/**
* $$ is top of the stack
* $1 is first symbol from top, then $2 will be + so on $3 is second number
*/

%%
expr: NUM '+' NUM {
$$ = $1 + $3;
sum = $$;
printf("Sum is %d\n",sum);
return 1;
};
%%

void main(){
	printf("Enter the addition expression:\n");
	yyparse();
	printf("Addition result is %d\n",sum);
	exit(0);
}

void yyerror(){
	printf("Invalid Statement\n");
	exit(0);
}