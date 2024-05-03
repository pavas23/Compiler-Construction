yacc -d parser.y
flex lexer.l
cc lex.yy.c y.tab.c -o a.out
./a.out test1.pas
rm y.tab.c y.tab.h a.out lex.yy.c
