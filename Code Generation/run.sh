yacc -d parser.y 2>/dev/null
flex lexer.l
cc lex.yy.c y.tab.c -o a.out -ll
./a.out test1.pas
rm y.tab.c y.tab.h a.out lex.yy.c