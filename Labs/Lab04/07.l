 /* using ECHO REJECT Actions
 	REJECT allows us to move pointer backwards even after a pattern matches
 	for input as beginning first it will select longest matching prefix then because of REJECT it comes back to start and then matches 2nd longest prefix
 	begin anf the comes to start again where it will print b e g i n ing then again rejects and prints i n g
 */
 
%{
#include<stdio.h>
%}

%%
begin | 
beginning |
ing ECHO; REJECT
. printf("  %c  ",*yytext);
%%


