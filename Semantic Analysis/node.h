#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
#define MAX_LENGTH 10000

// typedef enum {
//     AST_INTEGER_DATA_TYPE,
//     AST_REAL_DATA_TYPE,
//     AST_BOOLEAN_DATA_TYPE,
//     AST_CHAR_DATA_TYPE,
//     AST_STRING_DATA_TYPE,
//     AST_INTEGER_LITERAL,
//     AST_REAL_LITERAL,
//     AST_BOOLEAN_LITERAL,
//     AST_CHAR_LITERAL,
//     AST_STRING_LITERAL,
//     AST_PLUS ,
//     AST_MINUS,
//     AST_MUL,
//     AST_DIV,
//     AST_MOD,
//     AST_LT,
//     AST_LE,
//     AST_GT,
//     AST_GE,
//     AST_EQUAL,
//     AST_UNEQUAL,
//     AST_NOT,
//     AST_OR,
//     AST_AND,
//     AST_TO,
//     AST_DOWNTO,
//     AST_READ,
//     AST_WRITE,
//     AST_PROGRAM ,
//     AST_PROGRAM_NAME,
//     AST_VAR,
//     AST_BEGIN,
//     AST_END,
//     AST_ID,
//     AST_SEMICOLON,
//     AST_PERIOD,
//     AST_NONTERMINAL,
//     AST_COLON,
//     AST_TYPE,
//     AST_ARRAY,
//     AST_OF,
//     AST_LBRACE,
//     AST_RBRACE,
//     AST_COMMA,
//     AST_LPARENTHESIS,
//     AST_RPARENTHESIS
// } DataType;

// struct for each node in abstract syntax tree
typedef struct ASTNode {
    char lexeme[MAX_LENGTH];
    struct ASTNode* left;
    struct ASTNode* right;
} ASTNode;