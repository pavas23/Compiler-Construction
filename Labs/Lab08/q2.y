%{
#include<stdio.h>
int sum;
%}

%token NUM

%%
expr: ex{return 1;};
ex: NUM 