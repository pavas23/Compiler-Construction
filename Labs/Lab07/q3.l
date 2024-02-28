%{
#include "y.tab.h"
%}

%%
"+" {return plus;}
"(" {return open;}
")" {return closeBracket;}
"*" {return mult;}
[a-z]+ {return id;}
\n {return 0;}
. {return yytext[0];}
%%