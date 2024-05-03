flex lexer.l
gcc lex.yy.c -o a.out -ll
./a.out test1.pas
rm lex.yy.c a.out