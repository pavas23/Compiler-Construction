%{
char buf[100];
char *s;
%}

%x STRING

%%
\" {BEGIN STRING; s=buf;}
<STRING>\\n {*s++ = '\n';}
<STRING>\\t {*s++ = '\t';}
<STRING>\\\" {*s++ = '\"';}
<STRING>\" {*s=0; BEGIN 0; printf("found '%s'\n",buf);}
<STRING>\n {printf("invalid string"); exit(1);}
<STRING>. {*s++ = *yytext;}
%%

int main(){
	yylex();
	printf("string buf is %s\n",buf);
	return 0;
}

