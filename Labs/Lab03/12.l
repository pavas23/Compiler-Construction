 // write a lex program to find the keywords (int,for,while,if,then) and identifiers in C language (no keyword is identifier)

%{
	#include<stdio.h>
	int key = 0;
	int id = 1;
%}

%%
int {key=1;}
for {key=1;}
[0-9]+[a-zA-Z]* {id=0;}
\n return;
%%

int main(){
	yylex();
	if(key == 1){
		printf("Keyword\n");
	}else if(id == 1){
		printf("Identifier\n");
	}else{
		printf("None\n");
	}
}

int yywrap(){return(1);}

