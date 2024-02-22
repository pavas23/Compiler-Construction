%x state
%x two

%%
<state>[a-zA-Z] {}
<state>\" {BEGIN(two);}
<two>[a-zA-Z] {printf("*");}
[a-zA-Z] {printf("*");}
\" {BEGIN(state);}
%%

int main(){
	yylex();
	return 0;
}

