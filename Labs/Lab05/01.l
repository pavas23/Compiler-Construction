 // yyterminate() acts like a return and returns out of yylex() function

%{
#include<stdio.h>
%}

%%
[a-z]+ {printf("lower case\n");
ECHO;
printf("\nBegin yyterminate\n");
yyterminate();
printf("End of yyterminate\n");
}

[a-zA-Z]+ {printf("Mixed Case\n");
ECHO;
}
%%

int main(){
	yylex();
	printf("Closing Bye...\n");
}

