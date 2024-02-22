%x one

%%
bar printf("Hai \n"); BEGIN one;
<one>foo {printf("Hello \n"); yyless(1);}
%%

int main(){
	yylex();
	return 0;
}


