%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include<ctype.h>
	#include "node.h"
	#define MAX_LENGTH 10000
	extern FILE* yyin;

	// struct for row entry in symbol table
	typedef struct RowEntry {
		char lexeme[MAX_LENGTH];
		char token[MAX_LENGTH];
		char data_type[MAX_LENGTH];
		int line_number;
		int initialized;
		struct RowEntry* next;
	} RowEntry;

	typedef struct ErrorEntry {
		char error[MAX_LENGTH];
		
		struct ErrorEntry* next;
	} ErrorEntry;

	struct RowEntry* symbol_table = NULL;
	struct RowEntry* symbol_table_tail = NULL;
	struct ErrorEntry* errorSet = NULL;
	struct ErrorEntry* errorSetTail = NULL;
	ASTNode* abstract_syntax_tree_root = NULL;

	int checkMultipleError(char *error){
		struct ErrorEntry* current = errorSet;
		while(current != NULL){
			if(strcmp(current->error,error) == 0){
				return 1;
			}
			current = current->next;
		}
		return 0;
	}

	void printError(){
		struct ErrorEntry* curr = errorSet;
		while(curr!=NULL){
			printf("%s\n",curr->error);
			curr = curr->next;
		}
		
	}
	void push_error(char *err){
		if(checkMultipleError(err)) return;
		struct ErrorEntry* new_entry = (struct ErrorEntry*)malloc(sizeof(struct ErrorEntry));
		if(new_entry == NULL){
			printf("Error: Memory allocation failed\n");
			exit(1);
		}
	
		strcpy(new_entry->error, err);
		new_entry->next = NULL;
		if(errorSetTail == NULL){
			errorSet = new_entry;
			errorSetTail = new_entry;
		}else{
			errorSetTail->next = new_entry;
			errorSetTail = errorSetTail->next;
		}
	}

	void convertToLowercase(char *str) {
		int i = 0;
		while (str[i] != '\0') {
			if(('a'<=str[i] && str[i]<='z' )|| ('A'<=str[i] && str[i]<='Z'))
			str[i] = tolower(str[i]);
			i++;
		}
	}
	// function to check for multiple declarations of same variable
	int check_multiple_declarations(char* lexeme,int* line_number){
		struct RowEntry* current = symbol_table;
		convertToLowercase(lexeme);
		while(current != NULL){
			if(strcmp(current->lexeme,lexeme) == 0){
				*line_number = current->line_number;
				return 1;
			}
			current = current->next;
		}
		return 0;
	}

	// function to insert row in symbol table
	
	void insert_row(char* lexeme, char* token, char* data_type, int line_number) {
		// check for re-declaration
		// if(check_multiple_declarations(lexeme,line_number) == 1){

		// 	printf("Error: Variable %s redeclared on line number %d\n",lexeme,line_number);
		// 	exit(1);
		// }
		struct RowEntry* new_entry = (struct RowEntry*)malloc(sizeof(struct RowEntry));
			convertToLowercase(lexeme);
		if(new_entry == NULL){
			printf("Error: Memory allocation failed\n");
			exit(1);
		}

		strcpy(new_entry->lexeme, lexeme);
		strcpy(new_entry->token, token);
		strcpy(new_entry->data_type,data_type);
		new_entry->line_number = line_number;
		new_entry->next = NULL;
		if(symbol_table_tail == NULL){
			symbol_table = new_entry;
			symbol_table_tail = new_entry;
		}else{
			symbol_table_tail->next = new_entry;
			symbol_table_tail = symbol_table_tail->next;
		}
	}

	// function to print symbol table
	void print_symbol_table() {
		printf("Symbol Table:\n");
		printf("Lexeme                   Token            Datatype 			Line Number\n");
		printf("--------------------------------------------------------\n");
		struct RowEntry* current = symbol_table;
		while (current != NULL) {
			printf("%-25s%-25s%-25s%d\n", current->lexeme, current->token, current->data_type, current->line_number);
			current = current->next;
		}
	}

	// function to create node
	ASTNode* create_ast_node(char* lexeme){
		ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
		if(node == NULL){
			printf("Error: Memory allocation failed\n");
			exit(1);
		}
		strcpy(node->lexeme,lexeme);
		node->left = NULL;
		node->right = NULL;
		return node;
	}

	// function to add child to ast node
	void add_ast_child(ASTNode* node,ASTNode* leftChild,ASTNode* rightChild){
		node->left = leftChild;
		node->right = rightChild;
	}
	
	// Function to recursively print the AST with indentation
	void print_ast_helper(ASTNode *node, int level) {
		if (node == NULL) return;
		for (int i = 0; i < level; i++) {
			printf("    |");
		}
		if (level > 0) printf("+---");
		printf("%s", node->lexeme);
		if (node->left == NULL && node->right == NULL) printf(" @");
		printf("\n");

		// Recursively print children with increased indentation
		print_ast_helper(node->left, level + 1);
		print_ast_helper(node->right, level + 1);
	}

	// Function to print the AST with proper indentation
	void print_ast(ASTNode *root, int level) {
		if (root == NULL) return;
		print_ast_helper(root, level);
	}


	// function to print inorder traversal
	void inorder_traversal(ASTNode *node) {
		if(node == NULL) return;
		
		// doing preorder for these nodes
		if(strcmp(node->lexeme,"var") == 0 || strcmp(node->lexeme,"while") == 0 || strcmp(node->lexeme,"if") == 0 || strcmp(node->lexeme,"begin") == 0 || strcmp(node->lexeme,"program") == 0 || strcmp(node->lexeme,"then") == 0 || strcmp(node->lexeme,"else") == 0 || strcmp(node->lexeme,"for") == 0 ||  strcmp(node->lexeme,"do") == 0){
			if(strlen(node->lexeme) != 0) printf("%s\n",node->lexeme);
			inorder_traversal(node->left);
			inorder_traversal(node->right);
		}else{
			inorder_traversal(node->left);
			if(strlen(node->lexeme) != 0) printf("%s\n",node->lexeme);
			inorder_traversal(node->right);
		}
	}

	// function to check type
	char* getDataType(char *lexeme){
		int i = 0;
		for(i=0;i<strlen(lexeme);i++){
			lexeme[i] = toupper(lexeme[i]);
		}
		if(strcmp(lexeme,"INTEGER") == 0){
			return "AST_INTEGER_DATA_TYPE";
		}else if(strcmp(lexeme,"REAL") == 0){
			return "AST_REAL_DATA_TYPE";
		}else if(strcmp(lexeme,"BOOLEAN") == 0){
			return "AST_BOOLEAN_DATA_TYPE";
		}else if(strcmp(lexeme,"CHAR") == 0){
			return "AST_CHAR_DATA_TYPE";
		}
	}

	// root of ast
	ASTNode* root;

	// saving AST as a list
	void saveASTasList(ASTNode* tree){
		FILE* fp;
		char text[100000];
		fp = fopen("syntaxtree.txt","w");
		if(fp == NULL){
			printf("Error opening file\n");
			return;
		}
		text[0] = '\0';
		saveASTHelper(tree, text);
		fprintf(fp, "%s", text);
		fclose(fp);
	}

	void saveASTHelper(ASTNode* tree, char* text){
		if(tree == NULL){
			return;
		}
		char temp[MAX_LENGTH];
		sprintf(temp, "{%s", tree->lexeme);
		strcat(text, temp);
		saveASTHelper(tree->left, text);
		saveASTHelper(tree->right, text);
		strcat(text, "}");
	}

	void setDataType(ASTNode *treeNode,char *data_type,int lineNumber){
		if(treeNode==NULL) return;
		if(treeNode->lexeme[0]==','){
			insert_row(treeNode->lexeme,"COMMA","AST_COMMA",lineNumber);
		}else{
			//check for redeclaration
			convertToLowercase(treeNode->lexeme);
			int ln = 0;
			if(check_multiple_declarations(treeNode->lexeme,&ln)){
				char error[MAX_LENGTH];
				sprintf(error,"Variable %s at line %d has been redeclared again, ignoring declaration at %d\n",treeNode->lexeme,ln,lineNumber);
				push_error(error);
			}else{
			insert_row(treeNode->lexeme,"ID",data_type,lineNumber);
			}
		}
		setDataType(treeNode->left,data_type,lineNumber);
		setDataType(treeNode->right,data_type,lineNumber);
		return;
	}

	int check_undeclared(char* lexeme,int line_number){
		struct RowEntry* current = symbol_table;
			convertToLowercase(lexeme);
		while(current != NULL){
			if(strcmp(current->lexeme,lexeme) == 0 && strcmp(current->token,"ID") == 0){
				return 0;
			}
			current = current->next;
		}
		char error[MAX_LENGTH];
		sprintf(error,"Variable %s at line %d is undeclared\n",lexeme,line_number);
		push_error(error);
		return 1;
	}

	int isInitialized(char* lexeme,int line_number){
		struct RowEntry* current = symbol_table;
			convertToLowercase(lexeme);
		while(current != NULL){
			if(strcmp(current->lexeme,lexeme) == 0 && strcmp(current->token,"ID") == 0 && current->initialized == 1){
				return 1;
			}
			current = current->next;
		}
		char error[MAX_LENGTH];
		sprintf(error,"Variable %s at line %d is not initialized\n",lexeme,line_number);
		push_error(error);
		return 0;
	}

	void initialize(char* lexeme){
		struct RowEntry* current = symbol_table;
			convertToLowercase(lexeme);
		while(current != NULL){
			if(strcmp(current->lexeme,lexeme) == 0 && strcmp(current->token,"ID") == 0){
				current->initialized = 1;
			}
			current = current->next;
		}
	}

	char *getType(char *lexeme){
		if(strcmp(lexeme,"AST_INTEGER_DATA_TYPE") == 0){
			return "INTEGER";
		}else if(strcmp(lexeme,"ARRAY_AST_INTEGER_DATA_TYPE")==0){
			return "ARRAY_INTEGER";
		}else if(strcmp(lexeme,"AST_REAL_DATA_TYPE") == 0 ){
			return "REAL";
		}else if(strcmp(lexeme,"ARRAY_AST_REAL_DATA_TYPE")==0){
			return "ARRAY_REAL";
		}else if(strcmp(lexeme,"AST_BOOLEAN_DATA_TYPE") == 0){
			return "BOOLEAN";
		}else if(strcmp(lexeme,"ARRAY_AST_BOOLEAN_DATA_TYPE")==0){
			return "ARRAY_BOOLEAN";
		}else if(strcmp(lexeme,"AST_CHAR_DATA_TYPE") == 0){
			return "CHAR";
		}else if(strcmp(lexeme,"ARRAY_AST_CHAR_DATA_TYPE")==0){
			return "ARRAY_CHAR";
		}else if(strcmp(lexeme,"AST_BOOLEAN_OPERATOR")==0){
			return "BOOLEAN_OPERATOR";
		}else if(strcmp(lexeme,"AST_NOT_OPERATOR")==0){
			return "NOT_OPERATOR";
		}else if(strcmp(lexeme,"AST_RELATIONAL_OPERATOR")==0){
			return "RELATIONAL_OPERATOR";
		}
	}

	char* findTypeFromSymbolTable(char* lexeme){
		convertToLowercase(lexeme);
		struct RowEntry* current = symbol_table;
		while(current != NULL){
			if(strcmp(current->lexeme,lexeme) == 0){
				return getType(current->data_type);
			}
			current = current->next;
		}
		return "UNDEFINED";
	}


	int getLineNumber(char* lexeme){
		struct RowEntry* current = symbol_table;
			convertToLowercase(lexeme);
		while(current != NULL){
			if(strcmp(current->lexeme,lexeme) == 0){
				return current->line_number;
			}
			current = current->next;
		}
		return -1;
	}

	char *findTypeFromAST(ASTNode *treeNode,int line_number){
		if(treeNode==NULL) return "";
		if((treeNode->left==NULL ||  strcmp(treeNode->left->lexeme,"(")==0) && (treeNode->right==NULL || strcmp(treeNode->right->lexeme,";")==0 ||  strcmp(treeNode->right->lexeme,")")==0)){
			return findTypeFromSymbolTable(treeNode->lexeme);
		}
		if(strcmp(treeNode->lexeme,"[")==0){
			char* indexType = findTypeFromAST(treeNode->right->left,line_number);
			if(strcmp(indexType,"INTEGER")){
				char error[MAX_LENGTH];
				sprintf(error,"Index is not INTEGER for array %s at line %d\n",treeNode->left->lexeme,line_number);
				push_error(error);
				if(strcmp(findTypeFromSymbolTable(treeNode->left->lexeme),"UNDEFINED")==0) return "UNDEFINED";
				
			}

			char* str = findTypeFromSymbolTable(treeNode->left->lexeme);
					printf("%s\n\n",str);
					if(strcmp(str,"ARRAY_INTEGER") == 0){
						return "INTEGER";
					}
					if(strcmp(str,"ARRAY_REAL") == 0){
						return "REAL";
					}
					if(strcmp(str,"ARRAY_BOOLEAN") == 0){
						return "BOOLEAN";
					}
					if(strcmp(str,"ARRAY_CHAR") == 0){
						return "CHAR";
					}else{
						char error[MAX_LENGTH];
						sprintf(error,"Variable %s at line %d, is not of datatype array\n",treeNode->left->lexeme,line_number);
						push_error(error);
						return "ERROR";
					}
		}
		char *leftType = findTypeFromAST(treeNode->left,line_number);
		char *rightType = findTypeFromAST(treeNode->right,line_number);

		if(strcmp(treeNode->lexeme,"%") == 0){
			if(strcmp(leftType,"INTEGER")==0 && strcmp(rightType,"INTEGER")==0){
				return leftType;
			}else{
				char error[MAX_LENGTH];
				sprintf(error,"Type mismatch at line %d, %s and %s are not compatible data types with %% operator\n",line_number,leftType,rightType);
				push_error(error);
				return "ERROR";
			}
		}

		if(strcmp(treeNode->lexeme,"/") == 0){
            if(strcmp(leftType,"INTEGER")==0 && strcmp(rightType,"INTEGER")==0){
                return "REAL";
            }else if(strcmp(leftType,"REAL")==0 && strcmp(rightType,"REAL")==0){
                return "REAL";
            }else if(strcmp(leftType,"INTEGER")==0 && strcmp(rightType,"REAL")==0){
                return "REAL";
            }else if(strcmp(leftType,"REAL")==0 && strcmp(rightType,"INTEGER")==0){
                return "REAL";
            }else{
                char error[MAX_LENGTH];
                sprintf(error,"Type mismatch at line %d, %s and %s are not compatible data types with %% operator\n",line_number,leftType,rightType);
                push_error(error);
                return "ERROR";
            }
        }

		if(strcmp(leftType,"ERROR")==0 || strcmp(rightType,"ERROR")==0){
			return "ERROR";
		}

		if(strcmp(leftType,"UNDEFINED")==0){
			char error[MAX_LENGTH];
			sprintf(error,"Variable %s has no type at line %d\n",treeNode->left->lexeme,line_number);
			push_error(error);
			return "ERROR";
		}

		if(strcmp(rightType,"UNDEFINED")==0){
			char error[MAX_LENGTH];
			sprintf(error,"Variable %s has no type at line %d\n",treeNode->right->lexeme,line_number);
			push_error(error);
			return "ERROR";
		}

		if((strcmp(leftType,"")==0 && strcmp(rightType,"INTEGER")==0)|| (strcmp(leftType,"")==0 && strcmp(rightType,"REAL")==0)){
			return rightType;
		}else if(strcmp(leftType,"INTEGER")==0 && strcmp(rightType,"INTEGER")==0){
			return "INTEGER";
		}else if(strcmp(leftType,"REAL")==0 && strcmp(rightType,"REAL")==0){
			return "REAL";
		}else if(strcmp(leftType,"INTEGER")==0 && strcmp(rightType,"REAL")==0){
			return "REAL";
		}else if(strcmp(leftType,"REAL")==0 && strcmp(rightType,"INTEGER")==0){
			return "REAL";
		}else if(strcmp(leftType,"ARRAY_INTEGER")==0 && strcmp(rightType,"ARRAY_INTEGER")==0){
			return "ARRAY_INTEGER";
		}else if(strcmp(leftType,"ARRAY_REAL")==0 && strcmp(rightType,"ARRAY_REAL")==0){
			return "ARRAY_REAL";
		}else{
			char error[MAX_LENGTH];
			sprintf(error,"Type mismatch at line %d, %s and %s are not compatible data types\n",line_number,leftType,rightType);
			push_error(error);
			return "ERROR";
		}
	}

	void substring(char *src, int start_index, int length, char *result) {
		strncpy(result, src + start_index, length);
		result[length] = '\0'; // Add null terminator to make it a valid string
	}

	int isValidType(ASTNode* treeNodeleft,int line_number,ASTNode* treeNode){
		// printf("lex receieved is %s\n",lexeme);
		// // find type of lexeme from symbol table
		// convertToLowercase(lexeme);
		// char* res = (char*)malloc(strlen(lexeme)+1);
		// substring(lexeme,0,strlen(lexeme)-1,res);
		// printf("\n\n\n%s\n",res);
		// char* lhsType;
		// if(strlen(lexeme)>1 && lexeme[strlen(lexeme)-2] == '['){
		// 	printf("wfe");
		// 	lhsType =  findTypeFromSymbolTable(res);
		// 	if(strcmp(lhsType,"ARRAY_INTEGER") == 0){
		// 		strcpy(lhsType,"INTEGER");
		// 			}
		// 			else if(strcmp(lhsType,"ARRAY_REAL") == 0){
		// 				strcpy(lhsType,"REAL");
		// 			}
		// 			else if(strcmp(lhsType,"ARRAY_BOOLEAN") == 0){
		// 				strcpy(lhsType,"BOOLEAN");
		// 			}
		// 			else if(strcmp(lhsType,"ARRAY_CHAR") == 0){
		// 				strcpy(lhsType,"CHAR");
		// 			}
		// }else{
		// 	lhsType =  findTypeFromSymbolTable(lexeme);
		// }
		char* lhsType = findTypeFromAST(treeNodeleft,line_number);
		char* rhsType = findTypeFromAST(treeNode,line_number);
		if(strcmp(lhsType,rhsType) == 0 ||  strcmp(lhsType,"UNDEFINED") == 0){
			return 1;
		}

		if( strcmp(rhsType,"UNDEFINED") == 0){
			return 1;
		}
		char error[MAX_LENGTH];
		sprintf(error,"Type mismatch at line %d, %s:=%s are not compatible data types\n",line_number,lhsType,rhsType);
		push_error(error);
		return 0;
	}

	int isValidCondition(ASTNode* treeNode,int line_number){
		if(treeNode==NULL) return 1;
		if((treeNode->left==NULL || strcmp(treeNode->left->lexeme,"(")==0) && (treeNode->right==NULL || strcmp(treeNode->right->lexeme,")")==0)){
			if(strcmp(findTypeFromSymbolTable(treeNode->lexeme),"BOOLEAN")==0){
				return 1;
			}else{
				char error[MAX_LENGTH];
				sprintf(error,"Type mismatch at line %d, %s is not compatible data type\n",line_number,treeNode->lexeme);
				push_error(error);
				return 0;
			}
		}
		if(strcmp(treeNode->lexeme,"[")==0){
			if(strcmp(findTypeFromSymbolTable(treeNode->left->lexeme),"BOOLEAN")==0){
				return 1;
			}else{
				char error[MAX_LENGTH];
				sprintf(error,"Type mismatch at line %d, %s is not compatible data type\n",line_number,treeNode->left->lexeme);
				push_error(error);
				return 0;
			}
		}
		 
		if(strcmp(findTypeFromSymbolTable(treeNode->lexeme),"RELATIONAL_OPERATOR")==0){
			char *leftType = findTypeFromAST(treeNode->left,line_number);
			char *rightType = findTypeFromAST(treeNode->right,line_number);
			if((strcmp(leftType,"INTEGER")==0 && strcmp(rightType,"INTEGER")==0) || (strcmp(leftType,"REAL")==0 && strcmp(rightType,"REAL")==0)) return 1;
			else if(strcmp(leftType,"INTEGER")==0 && strcmp(rightType,"REAL")==0){
				return 1;
			}else if(strcmp(leftType,"REAL")==0 && strcmp(rightType,"INTEGER")==0){
				return 1;
			}
			else{
				char error[MAX_LENGTH];
				sprintf(error,"Type mismatch at line %d, %s %s %s are not compatible data types\n",line_number,leftType,treeNode->lexeme,rightType);
				push_error(error);
				return 0;
			}
		}

		if(strcmp(findTypeFromSymbolTable(treeNode->lexeme),"NOT_OPERATOR")==0){
			return isValidCondition(treeNode->right,line_number);
		}

		return isValidCondition(treeNode->left,line_number) && isValidCondition(treeNode->right,line_number);

	}
%}

%union {
	struct tokenObj {
		char lexeme[MAX_LENGTH];
		int line_number;
		struct ASTNode* ptr;
	}tokenObj;
}

%token <tokenObj> L_PARENTHESIS L_BRACE R_BRACE COMMA SEMICOLON COLON
%token <tokenObj> ASSIGNMENT ARRAY SINGLE_QUOTE
%token <tokenObj> IF THEN ELSE WHILE FOR DO OF TO DOWNTO
%token <tokenObj> PROGRAM PERIOD BEGIN_KEY END VAR TYPE
%token <tokenObj> READ WRITE CHAR_INPUT
%token <tokenObj> INTEGER REAL BOOLEAN ID STRING_INPUT_QUOTES INVALID
%left  <tokenObj>  ARITHMETIC_OPERATOR ADDITIVE_OPERATOR BOOLEAN_OPERATOR RELATIONAL_OPERATOR R_PARENTHESIS
%right <tokenObj> NOT_OPERATOR

%type <tokenObj> start prog prog_body var_body begin_body id_list id_list_read_write array_declare read_statement write_statement assignment_statement block conditional_statements looping_statements expression arithmetic_expression boolean_expression comparision_exp loop_body loop_block for_val for_expression assignment_expression arithmetic_expression_util relational

%%
start: prog{
	// print_ast_helper(root,0);
	// printf("Inorder is:\n\n\n");
	// inorder_traversal(root);
	// printf("valid input\n");
	saveASTasList(root);
	printf("----------------------------------------------------------------------\n\n");
	printError();
	printf("----------------------------------------------------------------------\n\n");
	return 1;
};

/**
* start symbol of grammar
*/
prog: PROGRAM ID SEMICOLON prog_body PERIOD {
	root = create_ast_node($1.lexeme);
	ASTNode* rightChild = create_ast_node($3.lexeme);
	ASTNode* temp  = $4.ptr;
	while(temp != NULL && temp->right != NULL){
		temp = temp->right;
	}
	if(temp != NULL){
		temp->right = create_ast_node($5.lexeme);
		add_ast_child(rightChild,NULL,$4.ptr);
	}else{
		add_ast_child(rightChild,NULL,create_ast_node($5.lexeme));
	}
	add_ast_child(root,create_ast_node($2.lexeme),rightChild);

	insert_row($1.lexeme,"PROGRAM","AST_PROGRAM",$1.line_number);
	insert_row($2.lexeme,"PROGRAM_NAME","AST_PROGRAM_NAME",$2.line_number);
	insert_row($3.lexeme,"SEMICOLON","AST_SEMICOLON",$3.line_number);
	insert_row($5.lexeme,"PERIOD","AST_PERIOD",$5.line_number);
};

prog_body:	VAR var_body BEGIN_KEY begin_body END {
				ASTNode* varNode = create_ast_node($1.lexeme);
				ASTNode* beginNode = create_ast_node($3.lexeme);
				add_ast_child(beginNode,$4.ptr,create_ast_node($5.lexeme));
				add_ast_child(varNode,$2.ptr,beginNode);
				$$.ptr = varNode;

				insert_row($1.lexeme,"VAR","AST_VAR",$1.line_number);
				insert_row($3.lexeme,"BEGIN_KEY","AST_BEGIN_KEY",$3.line_number);
				insert_row($5.lexeme,"END","AST_END_KEY",$5.line_number);
			}
			| BEGIN_KEY begin_body END {
				ASTNode* beginNode = create_ast_node($1.lexeme);
				add_ast_child(beginNode,$2.ptr,create_ast_node($3.lexeme));
				$$.ptr = beginNode;

				insert_row($1.lexeme,"BEGIN_KEY","AST_BEGIN_KEY",$1.line_number);
				insert_row($3.lexeme,"END","AST_END_KEY",$3.line_number);
			};

var_body:	id_list COLON TYPE  SEMICOLON var_body {
				ASTNode* colonNode = create_ast_node($2.lexeme);
				ASTNode* typeNode = create_ast_node($3.lexeme);
				ASTNode* semicolonNode = create_ast_node($4.lexeme);
				add_ast_child(semicolonNode,NULL,$5.ptr);
				add_ast_child(typeNode,NULL,semicolonNode);
				add_ast_child(colonNode,$1.ptr,typeNode);
				$$.ptr = colonNode;

				insert_row($2.lexeme,"COLON","AST_COLON",$2.line_number);
				insert_row($3.lexeme,"TYPE",getDataType($3.lexeme),$3.line_number);
				insert_row($4.lexeme,"SEMICOLON","AST_SEMICOLON",$4.line_number);
				setDataType($1.ptr,getDataType($3.lexeme),$2.line_number);
			}
			| id_list COLON TYPE SEMICOLON {
				ASTNode* colonNode = create_ast_node($2.lexeme);
				ASTNode* typeNode = create_ast_node($3.lexeme);
				ASTNode* semicolonNode = create_ast_node($4.lexeme);
				add_ast_child(typeNode,NULL,semicolonNode);
				add_ast_child(colonNode,$1.ptr,typeNode);
				$$.ptr = colonNode;

				insert_row($2.lexeme,"COLON","AST_COLON",$2.line_number);
				insert_row($3.lexeme,"TYPE",getDataType($3.lexeme),$3.line_number);
				insert_row($4.lexeme,"SEMICOLON","AST_SEMICOLON",$4.line_number);
				setDataType($1.ptr,getDataType($3.lexeme),$2.line_number);
			}
			| id_list COLON ARRAY array_declare OF TYPE SEMICOLON var_body {
				ASTNode* colonNode = create_ast_node($2.lexeme);
				ASTNode* ofNode = create_ast_node($5.lexeme);
				ASTNode* arrayNode = create_ast_node($3.lexeme);
				ASTNode* typeNode = create_ast_node($6.lexeme);
				ASTNode* semicolonNode = create_ast_node($7.lexeme);
				add_ast_child(semicolonNode,NULL,$8.ptr);
				add_ast_child(typeNode,NULL,semicolonNode);
				add_ast_child(arrayNode,NULL,$4.ptr);
				add_ast_child(ofNode,arrayNode,typeNode);
				add_ast_child(colonNode,$1.ptr,ofNode);
				$$.ptr = colonNode;

				insert_row($2.lexeme,"COLON","AST_COLON",$2.line_number);
				insert_row($3.lexeme,"ARRAY","AST_ARRAY",$3.line_number);
				insert_row($5.lexeme,"OF","AST_OF",$5.line_number);
				insert_row($6.lexeme,"TYPE",getDataType($6.lexeme),$6.line_number);
				insert_row($7.lexeme,"SEMICOLON","AST_SEMICOLON",$7.line_number);
				char text[MAX_LENGTH];
				sprintf(text,"ARRAY_%s",getDataType($6.lexeme));
				setDataType($1.ptr,text,$2.line_number);
			}
			| id_list COLON ARRAY array_declare OF TYPE SEMICOLON {
				ASTNode* colonNode = create_ast_node($2.lexeme);
				ASTNode* ofNode = create_ast_node($5.lexeme);
				ASTNode* arrayNode = create_ast_node($3.lexeme);
				ASTNode* typeNode = create_ast_node($6.lexeme);
				ASTNode* semicolonNode = create_ast_node($7.lexeme);
				add_ast_child(semicolonNode,NULL,NULL);
				add_ast_child(typeNode,NULL,semicolonNode);
				add_ast_child(arrayNode,NULL,$4.ptr);
				add_ast_child(ofNode,arrayNode,typeNode);
				add_ast_child(colonNode,$1.ptr,ofNode);
				$$.ptr = colonNode;

				insert_row($2.lexeme,"COLON","AST_COLON",$2.line_number);
				insert_row($3.lexeme,"ARRAY","AST_ARRAY",$3.line_number);
				insert_row($5.lexeme,"OF","AST_OF",$5.line_number);
				insert_row($6.lexeme,"TYPE",getDataType($6.lexeme),$6.line_number);
				insert_row($7.lexeme,"SEMICOLON","AST_SEMICOLON",$7.line_number);
				char text[MAX_LENGTH];
				sprintf(text,"ARRAY_%s",getDataType($6.lexeme));
					setDataType($1.ptr,text,$2.line_number);
			};

array_declare:	L_BRACE INTEGER PERIOD PERIOD INTEGER R_BRACE {
					ASTNode* periodNode = create_ast_node($4.lexeme);
					ASTNode* intNode1 = create_ast_node($2.lexeme);
					ASTNode* intNode2 = create_ast_node($5.lexeme);
					add_ast_child(intNode2,NULL,create_ast_node($6.lexeme));
					add_ast_child(intNode1,create_ast_node($1.lexeme),create_ast_node($3.lexeme));
					add_ast_child(periodNode,intNode1,intNode2);
					$$.ptr = periodNode;
					insert_row($1.lexeme,"LBRACE","AST_LBRACE",$1.line_number);
					insert_row($2.lexeme,"ARRAY_INTEGER_1","AST_INTEGER_DATA_TYPE",$1.line_number);
					insert_row($3.lexeme,"PERIOD","AST_PERIOD",$1.line_number);
					insert_row($4.lexeme,"PERIOD","AST_PERIOD",$1.line_number);
					insert_row($5.lexeme,"ARRAY_INTEGER_2","AST_INTEGER_DATA_TYPE",$1.line_number);
					insert_row($6.lexeme,"RBRACE","AST_RBRACE",$1.line_number);

			};

id_list:	ID COMMA id_list {
				ASTNode* commaNode = create_ast_node($2.lexeme);
				add_ast_child(commaNode,create_ast_node($1.lexeme),$3.ptr);
				$$.ptr = commaNode;
			}
			| ID {
				$$.ptr = create_ast_node($1.lexeme);
			};

/**
* main body of pascal program
*/
begin_body:	read_statement begin_body {
				ASTNode* temp = $1.ptr;
				while(temp != NULL && temp->right != NULL){
					temp = temp->right;
				}
				if(temp != NULL){
					temp->right = $2.ptr;
				}
				$$.ptr = $1.ptr;
			}
			| write_statement begin_body{
				ASTNode* temp = $1.ptr;
				while(temp != NULL && temp->right != NULL){
					temp = temp->right;
				}
				if(temp != NULL){
					temp->right = $2.ptr;
				}
				$$.ptr = $1.ptr;
			}
			| assignment_statement begin_body{
				ASTNode* temp = $1.ptr;
				while(temp != NULL && temp->right != NULL){
					temp = temp->right;
				}
				if(temp != NULL){
					temp->right = $2.ptr;
				}
				$$.ptr = $1.ptr;
			}
			| block begin_body{
				ASTNode* temp = $1.ptr;
				while(temp != NULL && temp->right != NULL){
					temp = temp->right;
				}
				if(temp != NULL){
					temp->right = $2.ptr;
				}
				$$.ptr = $1.ptr;
			}
			| conditional_statements begin_body{
				ASTNode* temp = $1.ptr;
				while(temp != NULL && temp->right != NULL){
					temp = temp->right;
				}
				if(temp != NULL){
					temp->right = $2.ptr;
				}
				$$.ptr = $1.ptr;
			}
			| looping_statements begin_body {
				ASTNode* temp = $1.ptr;
				while(temp != NULL && temp->right != NULL){
					temp = temp->right;
				}
				if(temp != NULL){
					temp->right = $2.ptr;
				}
				$$.ptr = $1.ptr;
			}
			| {
				$$.ptr = NULL;
			};

read_statement:	READ L_PARENTHESIS ID R_PARENTHESIS SEMICOLON{
					if(!check_undeclared($3.lexeme,$3.line_number)){
						isInitialized($3.lexeme,$3.line_number);
					}
					ASTNode* idNode = create_ast_node($3.lexeme);
					ASTNode* openNode = create_ast_node($2.lexeme);
					ASTNode* closeNode = create_ast_node($4.lexeme);
					add_ast_child(openNode,create_ast_node($1.lexeme),NULL);
					add_ast_child(closeNode,NULL,create_ast_node($5.lexeme));
					add_ast_child(idNode,openNode,closeNode);
					$$.ptr = idNode;
				}
				| READ L_PARENTHESIS ID L_BRACE arithmetic_expression R_BRACE R_PARENTHESIS SEMICOLON {
					ASTNode* lbraceNode = create_ast_node($4.lexeme);
					ASTNode* idNode = create_ast_node($3.lexeme);
					ASTNode* openNode = create_ast_node($2.lexeme);
					ASTNode* rbraceNode = create_ast_node($6.lexeme);
					ASTNode* closeNode = create_ast_node($7.lexeme);
					add_ast_child(openNode,create_ast_node($1.lexeme),NULL);
					add_ast_child(idNode,openNode,NULL);
					add_ast_child(lbraceNode,idNode,rbraceNode);
					add_ast_child(rbraceNode,$5.ptr,closeNode);
					add_ast_child(closeNode,NULL,create_ast_node($8.lexeme));
					$$.ptr = lbraceNode;
					findTypeFromAST(lbraceNode,$1.line_number);
					if(!check_undeclared($3.lexeme,$3.line_number)){
						isInitialized($3.lexeme,$3.line_number);
					}
				};

id_list_read_write:	ID {
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
						$$.ptr = create_ast_node($1.lexeme);
					}
					| STRING_INPUT_QUOTES {
						$$.ptr = create_ast_node($1.lexeme);
					}
					| ID L_BRACE arithmetic_expression R_BRACE {
						ASTNode* lbraceNode = create_ast_node($2.lexeme);
						ASTNode* idNode = create_ast_node($1.lexeme);
						ASTNode* rbraceNode = create_ast_node($4.lexeme);
						add_ast_child(lbraceNode,idNode,rbraceNode);
						add_ast_child(rbraceNode,$3.ptr,NULL);
						$$.ptr = lbraceNode;
						findTypeFromAST(lbraceNode,$1.line_number);
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
					}
					| ID COMMA id_list_read_write{
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
						ASTNode* commaNode = create_ast_node($2.lexeme);
						add_ast_child(commaNode,create_ast_node($1.lexeme),$3.ptr);
						$$.ptr = commaNode;
					}
					| ID L_BRACE arithmetic_expression R_BRACE COMMA id_list_read_write {
						ASTNode* lbraceNode = create_ast_node($2.lexeme);
						ASTNode* idNode = create_ast_node($1.lexeme);
						ASTNode* rbraceNode = create_ast_node($4.lexeme);
						ASTNode* commaNode = create_ast_node($5.lexeme);
						add_ast_child(lbraceNode,idNode,rbraceNode);
						add_ast_child(rbraceNode,$3.ptr,commaNode);
						add_ast_child(commaNode,NULL,$6.ptr);
						$$.ptr = lbraceNode;
						findTypeFromAST(lbraceNode,$1.line_number);
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
					}
					| STRING_INPUT_QUOTES COMMA id_list_read_write{
						ASTNode* commaNode = create_ast_node($2.lexeme);
						add_ast_child(commaNode,create_ast_node($1.lexeme),$3.ptr);
						$$.ptr = commaNode;
					};

write_statement:	WRITE L_PARENTHESIS R_PARENTHESIS SEMICOLON {
						ASTNode* openNode = create_ast_node($2.lexeme);
						ASTNode* closeNode = create_ast_node($3.lexeme);
						add_ast_child(openNode,create_ast_node($1.lexeme),closeNode);
						add_ast_child(closeNode,NULL,create_ast_node($4.lexeme));
						$$.ptr = openNode;
					}
					| WRITE L_PARENTHESIS id_list_read_write R_PARENTHESIS SEMICOLON {
						ASTNode* openNode = create_ast_node($2.lexeme);
						ASTNode* closeNode = create_ast_node($4.lexeme);
						add_ast_child(openNode,create_ast_node($1.lexeme),closeNode);
						add_ast_child(closeNode,$3.ptr,create_ast_node($5.lexeme));
						$$.ptr = openNode;
					};

assignment_statement:	ID ASSIGNMENT assignment_expression SEMICOLON{
						initialize($1.lexeme);
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
							ASTNode*  assignmentNode = create_ast_node($2.lexeme);
							add_ast_child(assignmentNode,create_ast_node($1.lexeme),$3.ptr);
							ASTNode* temp = $3.ptr;
							while(temp!=NULL && temp->right!=NULL){
								temp = temp->right;
							}
							temp->right = create_ast_node($4.lexeme);
							isValidType(create_ast_node($1.lexeme),$1.line_number,$3.ptr);
							$$.ptr = assignmentNode;
						}
						| ID L_BRACE arithmetic_expression R_BRACE ASSIGNMENT assignment_expression SEMICOLON{
							ASTNode*  assignmentNode = create_ast_node($5.lexeme);
							ASTNode* lbraceNode = create_ast_node($2.lexeme);
							ASTNode* idNode = create_ast_node($1.lexeme);
							ASTNode* rbraceNode = create_ast_node($4.lexeme);
							add_ast_child(lbraceNode,idNode,rbraceNode);
							add_ast_child(rbraceNode,$3.ptr,NULL);
							add_ast_child(assignmentNode,lbraceNode,$6.ptr);
							ASTNode* temp = $6.ptr;
							while(temp!=NULL && temp->right!=NULL){
								temp = temp->right;
							}
							temp->right = create_ast_node($7.lexeme);
							$$.ptr = assignmentNode;		
							initialize($1.lexeme);
							findTypeFromAST(lbraceNode,$1.line_number);
							if(!check_undeclared($1.lexeme,$1.line_number)){
							isInitialized($1.lexeme,$1.line_number);
							// char temp[MAX_LENGTH];
							// strcpy(temp,$1.lexeme);
							// strcat(temp,"[");
							isValidType(lbraceNode,$1.line_number,$6.ptr);
							}
						};

assignment_expression:	CHAR_INPUT{
						insert_row($1.lexeme,"CHAR_INPUT","AST_CHAR_DATA_TYPE",$1.line_number);
							$$.ptr = create_ast_node($1.lexeme);
						}
						| arithmetic_expression{
							$$.ptr = $1.ptr;
						}

arithmetic_expression:	arithmetic_expression ARITHMETIC_OPERATOR arithmetic_expression_util{
							ASTNode* operatorNode = create_ast_node($2.lexeme);
							add_ast_child(operatorNode,$1.ptr,$3.ptr);
							$$.ptr = operatorNode;
						}
						| arithmetic_expression ADDITIVE_OPERATOR arithmetic_expression_util{
							ASTNode* operatorNode = create_ast_node($2.lexeme);
							add_ast_child(operatorNode,$1.ptr,$3.ptr);
							$$.ptr = operatorNode;
						}
						| L_PARENTHESIS arithmetic_expression R_PARENTHESIS{
							ASTNode* temp = $2.ptr;
							while(temp!=NULL && temp->left!=NULL){
								temp = temp->left;
							}
							temp->left = create_ast_node($1.lexeme);
							temp = $2.ptr;
							while(temp!=NULL && temp->right!=NULL){
								temp = temp->right;
							}
							temp->right = create_ast_node($3.lexeme);
							$$.ptr = $2.ptr;
						}
						| INTEGER{
							insert_row($1.lexeme,"INTEGER","AST_INTEGER_DATA_TYPE",$1.line_number);
							$$.ptr = create_ast_node($1.lexeme);
						}
						| REAL{
							insert_row($1.lexeme,"REAL","AST_REAL_DATA_TYPE",$1.line_number);
							$$.ptr = create_ast_node($1.lexeme);
						}
						| ID {
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
							$$.ptr = create_ast_node($1.lexeme);
						}
						| ID L_BRACE arithmetic_expression R_BRACE{
							ASTNode* lbraceNode = create_ast_node($2.lexeme);
							ASTNode* idNode = create_ast_node($1.lexeme);
							ASTNode* rbraceNode = create_ast_node($4.lexeme);
							add_ast_child(lbraceNode,idNode,rbraceNode);
							add_ast_child(rbraceNode,$3.ptr,NULL);
							$$.ptr = lbraceNode;
							findTypeFromAST(lbraceNode,$1.line_number);
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
						}
						| ADDITIVE_OPERATOR arithmetic_expression_util{
							ASTNode* additiveNode = create_ast_node($1.lexeme);
							add_ast_child(additiveNode,NULL,$2.ptr);
							$$.ptr = additiveNode;
						};

arithmetic_expression_util:	L_PARENTHESIS arithmetic_expression R_PARENTHESIS{
							ASTNode* temp = $2.ptr;
							while(temp!=NULL && temp->left!=NULL){
								temp = temp->left;
							}
							temp->left = create_ast_node($1.lexeme);
							temp = $2.ptr;
							while(temp!=NULL && temp->right!=NULL){
								temp = temp->right;
							}
							temp->right = create_ast_node($3.lexeme);
							$$.ptr = $2.ptr;
							}
							| INTEGER{
								insert_row($1.lexeme,"INTEGER","AST_INTEGER_DATA_TYPE",$1.line_number);
								$$.ptr = create_ast_node($1.lexeme);
							}
							| REAL{
								insert_row($1.lexeme,"REAL","AST_REAL_DATA_TYPE",$1.line_number);
								$$.ptr = create_ast_node($1.lexeme);
							}
							| ID {
							if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
								$$.ptr = create_ast_node($1.lexeme);
							}
							| ID L_BRACE arithmetic_expression R_BRACE{
								ASTNode* lbraceNode = create_ast_node($2.lexeme);
								ASTNode* idNode = create_ast_node($1.lexeme);
								ASTNode* rbraceNode = create_ast_node($4.lexeme);
								add_ast_child(lbraceNode,idNode,rbraceNode);
								add_ast_child(rbraceNode,$3.ptr,NULL);
								$$.ptr = lbraceNode;
						findTypeFromAST(lbraceNode,$1.line_number);
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
							}

block:	BEGIN_KEY begin_body END {
			ASTNode* beginNode = create_ast_node($1.lexeme);
			add_ast_child(beginNode,$2.ptr,create_ast_node($3.lexeme));
			$$.ptr = beginNode;
		};

loop_block:	BEGIN_KEY loop_body END {
				ASTNode* beginNode = create_ast_node($1.lexeme);
				add_ast_child(beginNode,$2.ptr,create_ast_node($3.lexeme));
				$$.ptr = beginNode;
			};

/**
* separate loop block to prevent nesting of loops
*/
loop_body:	read_statement begin_body{
				ASTNode* temp = $1.ptr;
				while(temp != NULL && temp->right != NULL){
					temp = temp->right;
				}
				if(temp != NULL){
					temp->right = $2.ptr;
				}
				$$.ptr = $1.ptr;
			}
			| write_statement begin_body{
				ASTNode* temp = $1.ptr;
				while(temp != NULL && temp->right != NULL){
					temp = temp->right;
				}
				if(temp != NULL){
					temp->right = $2.ptr;
				}
				$$.ptr = $1.ptr;
			}
			| assignment_statement begin_body{
				ASTNode* temp = $1.ptr;
				while(temp != NULL && temp->right != NULL){
					temp = temp->right;
				}
				if(temp != NULL){
					temp->right = $2.ptr;
				}
				$$.ptr = $1.ptr;
			}
			| block begin_body{
				ASTNode* temp = $1.ptr;
				while(temp != NULL && temp->right != NULL){
					temp = temp->right;
				}
				if(temp != NULL){
					temp->right = $2.ptr;
				}
				$$.ptr = $1.ptr;
			}
			| conditional_statements begin_body{
				ASTNode* temp = $1.ptr;
				while(temp != NULL && temp->right != NULL){
					temp = temp->right;
				}
				if(temp != NULL){
					temp->right = $2.ptr;
				}
				$$.ptr = $1.ptr;
			}
			| {
				$$.ptr = NULL;
			};

comparision_exp:	comparision_exp BOOLEAN_OPERATOR comparision_exp{
						ASTNode* boolNode = create_ast_node($2.lexeme);
						add_ast_child(boolNode,$1.ptr,$3.ptr);
						$$.ptr = boolNode;

						insert_row($2.lexeme,"BOOLEAN_OPERATOR","AST_BOOLEAN_OPERATOR",$2.line_number);
					}
					| relational{
						$$.ptr = $1.ptr;
					}
					| ID BOOLEAN_OPERATOR comparision_exp{
												if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
						ASTNode* boolNode = create_ast_node($2.lexeme);
						add_ast_child(boolNode,create_ast_node($1.lexeme),$3.ptr);
						$$.ptr = boolNode;
						insert_row($2.lexeme,"BOOLEAN_OPERATOR","AST_BOOLEAN_OPERATOR",$2.line_number);
					}
					| comparision_exp BOOLEAN_OPERATOR ID{
												if(!check_undeclared($3.lexeme,$3.line_number)){
						isInitialized($3.lexeme,$3.line_number);
					}
						ASTNode* boolNode = create_ast_node($2.lexeme);
						add_ast_child(boolNode,$1.ptr,create_ast_node($3.lexeme));
						$$.ptr = boolNode;
						insert_row($2.lexeme,"BOOLEAN_OPERATOR","AST_BOOLEAN_OPERATOR",$2.line_number);
					}
					| ID BOOLEAN_OPERATOR ID{
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
						if(!check_undeclared($3.lexeme,$3.line_number)){
						isInitialized($3.lexeme,$3.line_number);
					}
						ASTNode* boolNode = create_ast_node($2.lexeme);
						add_ast_child(boolNode,create_ast_node($1.lexeme),create_ast_node($3.lexeme));
						$$.ptr = boolNode;
						insert_row($2.lexeme,"BOOLEAN_OPERATOR","AST_BOOLEAN_OPERATOR",$2.line_number);
					}
					| L_PARENTHESIS comparision_exp R_PARENTHESIS{
						ASTNode* temp = $2.ptr;
						while(temp!=NULL && temp->left!=NULL){
							temp = temp->left;
						}
						temp->left = create_ast_node($1.lexeme);

						 temp = $2.ptr;
						while(temp!=NULL && temp->right!=NULL){
							temp = temp->right;
						}
						temp->right = create_ast_node($3.lexeme);
						$$.ptr = $2.ptr;
					}
					| NOT_OPERATOR comparision_exp{
						ASTNode *notNode = create_ast_node($1.lexeme);
						add_ast_child(notNode,NULL,$2.ptr);
						$$.ptr = notNode;
						insert_row($1.lexeme,"NOT_OPERATOR","AST_NOT_OPERATOR",$2.line_number);
					}
					| NOT_OPERATOR ID{
						if(!check_undeclared($2.lexeme,$2.line_number)){
						isInitialized($2.lexeme,$2.line_number);
					}
						ASTNode *notNode = create_ast_node($1.lexeme);
						add_ast_child(notNode,NULL,create_ast_node($2.lexeme));
						$$.ptr = notNode;
						insert_row($1.lexeme,"NOT_OPERATOR","AST_NOT_OPERATOR",$2.line_number);
					}
					| ID{
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
						}
						$$.ptr = create_ast_node($1.lexeme);
					} 
					| ID L_BRACE arithmetic_expression R_BRACE{
						ASTNode* lbraceNode = create_ast_node($2.lexeme);
								ASTNode* idNode = create_ast_node($1.lexeme);
								ASTNode* rbraceNode = create_ast_node($4.lexeme);
								add_ast_child(lbraceNode,idNode,rbraceNode);
								add_ast_child(rbraceNode,$3.ptr,NULL);
								$$.ptr = lbraceNode;
						findTypeFromAST(lbraceNode,$1.line_number);
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
						}

						$$.ptr = lbraceNode;
					}
					| NOT_OPERATOR  ID L_BRACE arithmetic_expression R_BRACE{
						ASTNode * notNode = create_ast_node($1.lexeme);
						ASTNode* lbraceNode = create_ast_node($3.lexeme);
								ASTNode* idNode = create_ast_node($2.lexeme);
								ASTNode* rbraceNode = create_ast_node($5.lexeme);
								add_ast_child(lbraceNode,idNode,rbraceNode);
								add_ast_child(rbraceNode,$4.ptr,NULL);
								$$.ptr = lbraceNode;
						findTypeFromAST(lbraceNode,$2.line_number);
						if(!check_undeclared($2.lexeme,$2.line_number)){
						isInitialized($2.lexeme,$2.line_number);
						}

						add_ast_child(notNode,NULL,lbraceNode);
						$$.ptr = notNode;
						insert_row($1.lexeme,"NOT_OPERATOR","AST_NOT_OPERATOR",$2.line_number);
					}
					| ID L_BRACE arithmetic_expression R_BRACE BOOLEAN_OPERATOR ID L_BRACE arithmetic_expression R_BRACE{
						ASTNode* lbraceNode = create_ast_node($2.lexeme);
								ASTNode* idNode = create_ast_node($1.lexeme);
								ASTNode* rbraceNode = create_ast_node($4.lexeme);
								add_ast_child(lbraceNode,idNode,rbraceNode);
								add_ast_child(rbraceNode,$3.ptr,NULL);
								$$.ptr = lbraceNode;
						findTypeFromAST(lbraceNode,$1.line_number);
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
						}

						ASTNode* lbraceNode1 = create_ast_node($7.lexeme);
								ASTNode* idNode1 = create_ast_node($6.lexeme);
								ASTNode* rbraceNode1 = create_ast_node($9.lexeme);
								add_ast_child(lbraceNode1,idNode1,rbraceNode1);
								add_ast_child(rbraceNode1,$8.ptr,NULL);
								$$.ptr = lbraceNode1;
						findTypeFromAST(lbraceNode1,$6.line_number);
						if(!check_undeclared($6.lexeme,$6.line_number)){
						isInitialized($6.lexeme,$6.line_number);
						}

						ASTNode *boolNode = create_ast_node($5.lexeme);
						add_ast_child(boolNode,lbraceNode,lbraceNode1);
						$$.ptr = boolNode; 
						insert_row($5.lexeme,"BOOLEAN_OPERATOR","AST_BOOLEAN_OPERATOR",$5.line_number);
					}
					|ID L_BRACE arithmetic_expression R_BRACE BOOLEAN_OPERATOR comparision_exp{
							ASTNode* lbraceNode = create_ast_node($2.lexeme);
								ASTNode* idNode = create_ast_node($1.lexeme);
								ASTNode* rbraceNode = create_ast_node($4.lexeme);
								add_ast_child(lbraceNode,idNode,rbraceNode);
								add_ast_child(rbraceNode,$3.ptr,NULL);
								$$.ptr = lbraceNode;
						findTypeFromAST(lbraceNode,$1.line_number);
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);

						}

						ASTNode* boolNode = create_ast_node($5.lexeme);
						add_ast_child(boolNode,lbraceNode,$6.ptr);
						$$.ptr = boolNode;
						insert_row($5.lexeme,"BOOLEAN_OPERATOR","AST_BOOLEAN_OPERATOR",$5.line_number);
					}
					| comparision_exp BOOLEAN_OPERATOR  ID L_BRACE arithmetic_expression R_BRACE{
						ASTNode* lbraceNode = create_ast_node($4.lexeme);
								ASTNode* idNode = create_ast_node($3.lexeme);
								ASTNode* rbraceNode = create_ast_node($6.lexeme);
								add_ast_child(lbraceNode,idNode,rbraceNode);
								add_ast_child(rbraceNode,$5.ptr,NULL);
								$$.ptr = lbraceNode;
						findTypeFromAST(lbraceNode,$3.line_number);
						if(!check_undeclared($3.lexeme,$3.line_number)){
						isInitialized($3.lexeme,$3.line_number);
						}

						ASTNode* boolNode = create_ast_node($2.lexeme);
						add_ast_child(boolNode,$1.ptr,lbraceNode);
						$$.ptr = boolNode;
						insert_row($2.lexeme,"BOOLEAN_OPERATOR","AST_BOOLEAN_OPERATOR",$2.line_number);
					}

conditional_statements:	IF comparision_exp THEN block SEMICOLON{
							ASTNode* ifNode = create_ast_node($1.lexeme);
							ASTNode* thenNode = create_ast_node($3.lexeme);
							add_ast_child(ifNode,$2.ptr,thenNode);
							add_ast_child(thenNode,$4.ptr,create_ast_node($5.lexeme));
							$$.ptr = ifNode;
						isValidCondition($2.ptr,$1.line_number);
						}
						| IF comparision_exp THEN block ELSE block SEMICOLON {
							ASTNode* ifNode = create_ast_node($1.lexeme);
							ASTNode* thenNode = create_ast_node($3.lexeme);
							ASTNode* elseNode = create_ast_node($5.lexeme);
							add_ast_child(ifNode,$2.ptr,thenNode);
							add_ast_child(thenNode,$4.ptr,elseNode);
							add_ast_child(elseNode,$6.ptr,create_ast_node($7.lexeme));
							$$.ptr = ifNode;
							isValidCondition($2.ptr,$1.line_number);
						};

relational: arithmetic_expression RELATIONAL_OPERATOR arithmetic_expression{
				ASTNode* relationalNode = create_ast_node($2.lexeme);
				add_ast_child(relationalNode,$1.ptr,$3.ptr);
				$$.ptr = relationalNode;
				insert_row($2.lexeme,"RELATIONAL_OPERATOR","AST_RELATIONAL_OPERATOR",$2.line_number);
			};

looping_statements:	WHILE comparision_exp DO loop_block SEMICOLON {
						ASTNode* whileNode = create_ast_node($1.lexeme);
						ASTNode* doNode = create_ast_node($3.lexeme);
						add_ast_child(whileNode,$2.ptr,doNode);
						add_ast_child(doNode,$4.ptr,create_ast_node($5.lexeme));
						$$.ptr = whileNode;
						isValidCondition($2.ptr,$1.line_number);
					}
					| FOR  for_expression DO loop_block SEMICOLON{
						ASTNode* forNode = create_ast_node($1.lexeme);
						ASTNode* doNode = create_ast_node($3.lexeme);
						add_ast_child(forNode,$2.ptr,doNode);
						add_ast_child(doNode,$4.ptr,create_ast_node($5.lexeme));
						$$.ptr = forNode;
					};

/**
* value of condition in for loop
*/
for_val:	arithmetic_expression {
				$$.ptr = $1.ptr;
			};

for_expression:	ID ASSIGNMENT for_val TO for_val {
							initialize($1.lexeme);

																			if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
					ASTNode* toNode = create_ast_node($4.lexeme);
					ASTNode* assignNode = create_ast_node($2.lexeme);
					add_ast_child(assignNode,create_ast_node($1.lexeme),$3.ptr);
					add_ast_child(toNode,assignNode,$5.ptr);
					$$.ptr = toNode;
				}
				| ID L_BRACE arithmetic_expression R_BRACE ASSIGNMENT for_val TO for_val{
					ASTNode* toNode = create_ast_node($7.lexeme);
					ASTNode* assignNode = create_ast_node($5.lexeme);
					ASTNode* lbraceNode = create_ast_node($2.lexeme);
					ASTNode* idNode = create_ast_node($1.lexeme);
					ASTNode* rbraceNode = create_ast_node($4.lexeme);
					add_ast_child(lbraceNode,idNode,rbraceNode);
					add_ast_child(rbraceNode,$3.ptr,NULL);
					add_ast_child(assignNode,lbraceNode,$6.ptr);
					add_ast_child(toNode,assignNode,$8.ptr);
					$$.ptr = toNode;
					findTypeFromAST(lbraceNode,$1.line_number);
						initialize($1.lexeme);

						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
				}
				| ID L_BRACE arithmetic_expression R_BRACE ASSIGNMENT for_val DOWNTO for_val{
					ASTNode* downtoNode = create_ast_node($7.lexeme);
					ASTNode* assignNode = create_ast_node($5.lexeme);
					ASTNode* lbraceNode = create_ast_node($2.lexeme);
					ASTNode* idNode = create_ast_node($1.lexeme);
					ASTNode* rbraceNode = create_ast_node($4.lexeme);
					add_ast_child(lbraceNode,idNode,rbraceNode);
					add_ast_child(rbraceNode,$3.ptr,NULL);
					add_ast_child(assignNode,lbraceNode,$6.ptr);
					add_ast_child(downtoNode,assignNode,$8.ptr);
					$$.ptr = downtoNode;
					findTypeFromAST(lbraceNode,$1.line_number);
							initialize($1.lexeme);
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
				}
				| ID ASSIGNMENT for_val DOWNTO for_val {
							initialize($1.lexeme);
																			if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
					ASTNode* downtoNode = create_ast_node($4.lexeme);
					ASTNode* assignNode = create_ast_node($2.lexeme);
					add_ast_child(assignNode,create_ast_node($1.lexeme),$3.ptr);
					add_ast_child(downtoNode,assignNode,$5.ptr);
					$$.ptr = downtoNode;
				};
%%

int main(int argc, char* argv[]){
	char filename[MAX_LENGTH];

    // checking if correct number of command line arguments are provided
    if(argc != 2){
        printf("Arguments provided are wrong\n");
        return 1;
    }
    strncpy(filename,argv[1],MAX_LENGTH);
    filename[MAX_LENGTH-1] = '\0';

    yyin = fopen(filename,"r");
	yyparse();
	//print_symbol_table();
	return 0;
}

void yyerror(){
	printf("syntax error\n");
	//print_symbol_table();
	exit(0);
}