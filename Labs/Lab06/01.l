 // %s is used for declaring states, if something matches with bar it goes to state 1, INITIAL means it is active from begining

 // %s is inclusive means all other regex are also active when we are on a particular state, wherease %x is exclusive that means only that state will be active and all other regex's will be inactive.
 
 // we can return to initial state by puttinh BEGIN INITIAL.
 
 // if we make a state a initial it means it is active since start, otherwise becomes active only on scanning bar.
%x one

%%
bar printf("Hai \n"); BEGIN one;
<one>\. {printf("Hello \n"); BEGIN INITIAL;}
. printf("*");
%%

int main(){
	yylex();
	return 0;
}


