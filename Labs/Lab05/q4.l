 // use o unput('a') returns the character a back to the input stream
 // yytext() changes after unput() is used

%{
#include<stdio.h>
%}

%%
"un" {printf("\nThe unput char is = ");
ECHO;
}

[a-z]+ {printf("Lower case token is = ");
ECHO;
unput('n');
// printf("%s\n",yytext);
unput('u');
// printf("%s\n",yytext);
printf("\nThe token after unput is = ");
ECHO;
}

[a-zA-Z]+ {printf("\nMixed Token is = ");
ECHO;
}
%%

int main(){
	yylex();
	return 0;
}

