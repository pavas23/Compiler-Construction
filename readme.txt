Steps to compile Semantic Analysis (Task 3):

yacc -d P2T2D2AV.y
flex P2T2D2AV.l
cc lex.yy.c y.tab.c -o a.out
./a.out test1.pas
rm y.tab.c y.tab.h a.out lex.yy.c
python3 tree.py

Steps to compile Code Generation (Task 4):

yacc -d P2T2D2AV.y
flex P2T2D2AV.l
cc lex.yy.c y.tab.c -o a.out
./a.out test1.pas
rm y.tab.c y.tab.h a.out lex.yy.c

Steps to compile the Final Stage (Task 5):

yacc -d P2T2D2AV.y
flex P2T2D2AV.l
cc lex.yy.c y.tab.c -o a.out
./a.out test1.pas
rm y.tab.c y.tab.h a.out lex.yy.c