%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include<ctype.h>
	#include<limits.h>
	#include "node.h"
	#define MAX_LENGTH 10000
	#define MAX_LENGTH_TAC 100
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

	typedef struct Quadruple {
		char operator[MAX_LENGTH];
		char operand1[MAX_LENGTH];
		char operand2[MAX_LENGTH];
		char result[MAX_LENGTH];
		struct Quadruple* next;
	}Quadruple;

	typedef struct TempVar {
		char result[MAX_LENGTH];
	}TempVar;
	struct TempVar tempArr[MAX_LENGTH];

	typedef struct VarTable {
		char name[MAX_LENGTH];
		char datatype[MAX_LENGTH];
		char result[MAX_LENGTH];
		struct VarTable* next;
	}VarTable;

	struct TempVar* tempTable = NULL;
	struct TempVar* tempTail = NULL;

	struct VarTable* varTable = NULL;
	struct VarTable* varTableTail = NULL;

	void insert_row_vartable(char* name, char* datatype, char* result) {
		convertToLowercase(name);
		struct VarTable* new_entry = (struct VarTable*)malloc(sizeof(struct VarTable));
		if(new_entry == NULL){
			printf("Error: Memory allocation failed\n");
			//exit(1);
		}

		struct VarTable* curr = varTable;
		while(curr != NULL){
			if(strcmp(curr->name,name) == 0){
				strcpy(curr->name,name);
				strcpy(curr->datatype,datatype);
				strcpy(curr->result,result);
				return;
			}
			curr = curr->next;
		}

		strcpy(new_entry->name, name);
		strcpy(new_entry->datatype, datatype);
		strcpy(new_entry->result,result);
		new_entry->next = NULL;
		if(varTableTail == NULL){
			varTable = new_entry;
			varTableTail = new_entry;
		}else{
			varTableTail->next = new_entry;
			varTableTail = varTableTail->next;
		}
	}

	char* findValFromVartable(char* name){
		convertToLowercase(name);
		struct VarTable* curr = varTable;
		while(curr != NULL){
			if(strcmp(curr->name,name) == 0){
				return curr->result;
			}
			curr = curr->next;
		}
		return "0";
	}


	void printVartable(){
		struct VarTable* curr = varTable;
		while(curr != NULL){
			printf("%s %s %s\n",curr->name,curr->datatype,curr->result);
			curr = curr->next;
		}
	}

	void printTemptable(){
		for(int i=0;i<50;i++){
			// if(strlen(tempArr[i].result) == 0){
			// 	break;
			// }
			printf("$t%d %s\n",i,tempArr[i].result);
		}
	}

	int findDataType(char* str){
		if(strlen(str)==0) return -1;
		if(str[0]=='-'){
			int n = strlen(str);
			for(int i=1;i<n;i++){
				if(str[i] == '.'){
					return 1;
				}
			}
			return 0;
		}
		if((str[0]>='a' && str[0]<='z') || (str[0]>='A' && str[0]<='Z') || str[0]=='_'){
			return 5;
		}
		if(str[0] == '$'){
			return 4;
		}
		if(str[0] == '\''){
			return 2;
		}else{
			int n = strlen(str);
			for(int i=0;i<n;i++){
				if(str[i] == '.'){
					return 1;
				}
			}
			return 0;
		}
	}

	char* findSubstring(const char* str, int startIndex, int length) {
		int strLen = strlen(str);

		// Check if the start index is valid
		if (startIndex < 0 || startIndex >= strLen) {
			return NULL;
		}

		// Adjust length if it exceeds the available characters in the string
		if (length > strLen - startIndex) {
			length = strLen - startIndex;
		}

		// Return pointer to the start of the substring within the original string
		return (char*)&str[startIndex];
	}

	int tVal = 0;
	int lVal = 0;

	typedef struct stack { 
    char data[MAX_LENGTH]; 
    struct stack* next; 
	}stack;

	typedef struct ErrorEntry {
		char error[MAX_LENGTH];
		
		struct ErrorEntry* next;
	} ErrorEntry;

	struct RowEntry* symbol_table = NULL;
	struct RowEntry* symbol_table_tail = NULL;
	struct ErrorEntry* errorSet = NULL;
	struct ErrorEntry* errorSetTail = NULL;

	struct Quadruple* tacTable = NULL;
	struct Quadruple* tacTail = NULL;
	struct stack *top = NULL;
	ASTNode* abstract_syntax_tree_root = NULL;

		char* dfs(struct Quadruple* ptr){
		// go to res ke operands
		char* op1 = ptr->operand1;
		char* op2 = ptr->operand2;

		// printf("func called %s\n",ptr->result);

		convertToLowercase(ptr->operator);
		int valTyp1 = findDataType(op1);
		int valType2 = findDataType(op2);

		char* finalAns = (char*)malloc(MAX_LENGTH*sizeof(char));
		float value = -1;

		// if(findDataType(ptr->result) == 5){
		// 	return findValFromVartable(ptr->result);
		// }

		

		if(valType2 == -1){
			// not operator
			float res = -1;
			if(valTyp1 < 2){
				// nothing
			}else{
				struct Quadruple* temp = tacTable;
				char* ans  = (char*)malloc(MAX_LENGTH*sizeof(char));;
				while(temp != NULL){
					if(strcmp(temp->result,op1) == 0){
						// printf("%s\n",temp->result);
						char* temp1 = dfs(temp);
						strcpy(ans,temp1);
					}
					temp = temp->next;
				}
				strcpy(op1,ans);
			}
			if(strcmp(ptr->operator,"not") == 0){
				res = !atof(op1);
			}else if(strcmp(ptr->operator,":=") == 0){
				res = atof(op1);
			}else if(strcmp(ptr->operator,"-") == 0){
				res = -atof(op1);
			}
			// printf("%f\n res",res);
			sprintf(finalAns, "%f", res);
			return finalAns;
		}

		// num num
		if(valTyp1 < 2 && valType2 < 2){
			// nothing
		}else if(valTyp1 < 2){
			// find ptr where op2 is res
			struct Quadruple* temp = tacTable;
			char* ans = (char*)malloc(MAX_LENGTH*sizeof(char));
			while(temp != NULL){
				if(strcmp(temp->result,op2) == 0){
					char* temp1 = dfs(temp);
					strcpy(ans,temp1);
				}
				temp = temp->next;
			}
			strcpy(op2,ans);
		}
		else if(valType2 < 2){
			// find ptr where op2 is res
			struct Quadruple* temp = tacTable;
			char* ans = (char*)malloc(MAX_LENGTH*sizeof(char));
			while(temp != NULL){
				if(strcmp(temp->result,op1) == 0){
					char* temp1 = dfs(temp);
					// printf("returned value is %f\n",temp1);
					strcpy(ans,temp1);
				}
				temp = temp->next;
			}
			strcpy(op1,ans);
		}else{
			// find ptr where op2 is res
			struct Quadruple* temp = tacTable;
			char* ans1 = (char*)malloc(MAX_LENGTH*sizeof(char));
			while(temp != NULL){
				if(strcmp(temp->result,op2) == 0){
					char* temp1 = dfs(temp);
					strcpy(ans1,temp1);
				}
				temp = temp->next;
			}
			strcpy(op2,ans1);

			char* ans2 = (char*)malloc(MAX_LENGTH*sizeof(char));
			while(temp != NULL){
				if(strcmp(temp->result,op1) == 0){
					char* temp1 = dfs(temp);
					// printf("returned value is %f\n",temp1);
					strcpy(ans2,temp1);
				}
				temp = temp->next;
			}
			strcpy(op1,ans2);

		}

		if(strcmp(ptr->operator,"+") == 0){
			value = atof(op1) + atof(op2);
		}else if(strcmp(ptr->operator,"-") == 0){
			value = atof(op1) - atof(op2);
		}else if(strcmp(ptr->operator,"*") == 0){
			value = atof(op1) * atof(op2);
		}else if(strcmp(ptr->operator,"/") == 0){
			value =  atof(op1) / atof(op2);
		}else if(strcmp(ptr->operator,"<") == 0){
			// printf("hello");
			// printf("%f %f\n",atof(op1),atof(op2));
			value = atof(op1) < atof(op2);
		}else if(strcmp(ptr->operator,"<=") == 0){
			value = atof(op1) <= atof(op2);
		}else if(strcmp(ptr->operator,">") == 0){
			value = atof(op1) > atof(op2);
		}else if(strcmp(ptr->operator,">=") == 0){
			value = atof(op1) >= atof(op2);
		}else if(strcmp(ptr->operator,"<>") == 0){
			value = atof(op1) != atof(op2);
		}else if(strcmp(ptr->operator,"=") == 0){
			value = atof(op1) == atof(op2);
		}else if(strcmp(ptr->operator,"and") == 0){
			value = atof(op1) && atof(op2);
		}else if(strcmp(ptr->operator,"or") == 0){
			value = atof(op1) || atof(op2);
		}else if(strcmp(ptr->operator,"=") == 0){
			value = (atof(op1) == atof(op2));
		}
		// printf("val is %f\n",value);
		sprintf(finalAns, "%f", value);
		return finalAns;
	}


	struct stack* createNode(char* data) { 
		struct stack* newNode = (struct stack*)malloc(sizeof(struct stack)); 
		strcpy(newNode->data,data); 
		newNode->next = NULL; 
		return newNode; 
	}

	int isEmpty(struct stack* top) { 
		return top == NULL; 
	}

	void push(struct stack** top, char* data) { 
		struct stack* newNode = createNode(data); 
		newNode->next = *top; 
		*top = newNode;
	} 

	char* pop(struct stack** top) { 
		if (isEmpty(*top)) { 
			printf("Stack underflow!\n"); 
			return ""; 
		} 
		struct stack* temp = *top; 
		char *popped = malloc(MAX_LENGTH*sizeof(char));
		strcpy(popped,temp->data); 
		*top = (*top)->next; 
		free(temp); 
		return popped; 
	}

	void addTAC(char *operator,char* op1,char *op2, char *res){
		struct Quadruple* new_entry = (struct Quadruple*)malloc(sizeof(struct Quadruple));
		if(new_entry == NULL){
			printf("Error: Memory allocation failed\n");
			//exit(1);
		}
	
		strcpy(new_entry->operator, operator);
		strcpy(new_entry->operand1, op1);
		strcpy(new_entry->operand2, op2);
		strcpy(new_entry->result, res);

		new_entry->next = NULL;
		if(tacTail == NULL){
			tacTable = new_entry;
			tacTail = new_entry;
		}else{
			tacTail->next = new_entry;
			tacTail = tacTail->next;
		}
	}


	void printTAC(){
		struct Quadruple* current = tacTable;
		while(current != NULL){
			printf("%s %s %s %s\n",current->operator,current->operand1,current->operand2,current->result);
			current = current->next;
		}
		return 0;
	}

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
			//exit(1);
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

	// function to check for multiple declarations of same variable
	int check_multiple_declarations(char* lexeme,int* line_number){
		struct RowEntry* current = symbol_table;
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
	void convertToLowercase(char *str) {
		int i = 0;
		while (str[i] != '\0') {
			if(('a'<=str[i] && str[i]<='z' )|| ('A'<=str[i] && str[i]<='Z'))
			str[i] = tolower(str[i]);
			i++;
		}
	}

	void insert_row(char* lexeme, char* token, char* data_type, int line_number) {
		// check for re-declaration
		// if(check_multiple_declarations(lexeme,line_number) == 1){

		// 	printf("Error: Variable %s redeclared on line number %d\n",lexeme,line_number);
		// 	//exit(1);
		// }
		struct RowEntry* new_entry = (struct RowEntry*)malloc(sizeof(struct RowEntry));
		if(new_entry == NULL){
			printf("Error: Memory allocation failed\n");
			//exit(1);
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
			//exit(1);
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
		convertToLowercase(lexeme);
		struct RowEntry* current = symbol_table;
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
		while(current != NULL){
			if(strcmp(current->lexeme,lexeme) == 0 && strcmp(current->token,"ID") == 0){
				current->initialized = 1;
			}
			current = current->next;
		}
	}

	char *getType(char *lexeme){
		if(strcmp(lexeme,"AST_INTEGER_DATA_TYPE") == 0 || strcmp(lexeme,"ARRAY_AST_INTEGER_DATA_TYPE")==0){
			return "INTEGER";
		}else if(strcmp(lexeme,"AST_REAL_DATA_TYPE") == 0 || strcmp(lexeme,"ARRAY_AST_REAL_DATA_TYPE")==0){
			return "REAL";
		}else if(strcmp(lexeme,"AST_BOOLEAN_DATA_TYPE") == 0|| strcmp(lexeme,"ARRAY_AST_BOOLEAN_DATA_TYPE")==0){
			return "BOOLEAN";
		}else if(strcmp(lexeme,"AST_CHAR_DATA_TYPE") == 0|| strcmp(lexeme,"ARRAY_AST_CHAR_DATA_TYPE")==0){
			return "CHAR";
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
				else return findTypeFromSymbolTable(treeNode->left->lexeme);
			}
		}
		char *leftType = findTypeFromAST(treeNode->left,line_number);
		char *rightType = findTypeFromAST(treeNode->right,line_number);

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
		}else if(strcmp(leftType,"INTEGER")==0 || strcmp(rightType,"INTEGER")==0){
			return leftType;
		}else if(strcmp(leftType,"REAL")==0 || strcmp(rightType,"REAL")==0){
			return leftType;
		}else if(strcmp(leftType,"INTEGER")==0 || strcmp(rightType,"REAL")==0){
			return rightType;
		}else if(strcmp(leftType,"REAL")==0 || strcmp(rightType,"INTEGER")==0){
			return leftType;
		}else{
			char error[MAX_LENGTH];
			sprintf(error,"Type mismatch at line %d, %s and %s are not compatible data types\n",line_number,leftType,rightType);
			push_error(error);
			return "ERROR";
		}
	}

	int isValidType(char* lexeme,int line_number,ASTNode* treeNode){
		// find type of lexeme from symbol table
		convertToLowercase(lexeme);
		char* lhsType = findTypeFromSymbolTable(lexeme);
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

		if(strcmp(findTypeFromSymbolTable(treeNode->lexeme),"NOT_OPERATOR")){
			return isValidCondition(treeNode->right,line_number);
		}

		return isValidCondition(treeNode->left,line_number) && isValidCondition(treeNode->right,line_number);

	}

	void print_tac(){
		struct Quadruple* curr = tacTable;
		while(curr != NULL){
			if(strcmp(curr->operator,"goto")==0){
				printf("GOTO %s\n",curr->operand1);
			}else if(strcmp(curr->operator,"IF")==0){
				printf("IF %s GOTO %s\n",curr->operand1,curr->result);
			}else if(strcmp(curr->operator,"label")==0){
				printf("%s:\n",curr->operand1);
			}else{
				if(strcmp(curr->operator,":=")==0){
					printf("%s = %s\n",curr->result,curr->operand1);
				}else{
					if(strcmp(curr->operand2,"") == 0){
						if(strcmp(curr->operator,"SIZEOF")==0){
							printf("%s = %s(%s)\n",curr->result,curr->operator,curr->operand1);
						}else{
							printf("%s = %s%s\n",curr->result,curr->operator,curr->operand1);
						}
					}else{
						printf("%s = %s %s %s\n",curr->result,curr->operand1,curr->operator,curr->operand2);
					}
				}
			}
			curr = curr->next;
		}
	}

void print_quadruple() {
    struct Quadruple* curr = tacTable;
    while (curr != NULL) {
        printf("%-20s%-20s%-20s%-20s\n", curr->operator, curr->operand1, curr->operand2, curr->result);
        curr = curr->next;
    }
}
struct Quadruple* gotoHandler(char *label){
		struct Quadruple* curr = tacTable;
		while(curr!=NULL){
			if(strcmp("label",curr->operator)==0&&strcmp(label,curr->operand1)==0){
				return curr;
			}
			curr = curr->next;
		}
		return NULL;
}
int isBoolOrRel(char *op){
	convertToLowercase(op);
	return !strcmp(op,"<") || 
			!strcmp(op,"<=") ||
			 !strcmp(op,">")|| 
			 !strcmp(op,">=")||
			  !strcmp(op,"<>")||
			 !strcmp(op,"=")||
			  !strcmp(op,"and")||
			   !strcmp(op,"or")||
			     !strcmp(op,"not");

}

char *getWriteString(char *write){
	int n = strlen(write);
	char *result = (char *)malloc(sizeof(int)*MAX_LENGTH);
	int ptr = 0;
	int j =0;
	for(int i=0;i<n;i++){
		int stringStart = i+1;
		if(write[i]=='\"'){
			int prevLen = strlen(result);
			i++;
			while(i < n && write[i]!='\"'){
				result[i-stringStart+prevLen] = write[i];
				i++;
			}
			j = i+2;
			i+=1;
			result[strlen(result)] = ' ';
			

		}else if(write[i]==',' || i==n-1){
			if(write[i]=='\"') break;
			int top = i;
			if(write[i]==',') top = i-1;
			char *str = (char*)malloc(sizeof(char)*MAX_LENGTH);
			int p = 0;
			for(int k = j; k <= top ; k++){
				str[p] = write[k];
				p++;
			}
			
			char *res = findValFromVartable(str);
			int prevLen = strlen(result);
			
			for(int k = 0; k < strlen(res);k++){
				result[k+prevLen] = res[k];
			}
			result[strlen(result)] = ' ';
			
			j = i+1;
			
			

		}
	}
	return result;
}

	void computeTempValues(){
		struct Quadruple* curr = tacTable;
		while(curr != NULL){
			if(strcmp(curr->operator,"update") == 0){
				char* ans = (char*)malloc(MAX_LENGTH*sizeof(char));
				struct Quadruple* temp = tacTable;
				struct Quadruple* ref = NULL;
				while(temp != NULL){
					if(strcmp(temp->result,curr->operand1) == 0){
						ref = temp;
						break;
					}
					temp = temp->next;
				}
				int indexRes = atoi(findSubstring(curr->operand1,2,strlen(curr->operand1)-2));
				char tempRes[100];
				sprintf(tempRes,"%s",ans);
				strcpy(tempArr[indexRes].result,tempRes);
				// printf("%s\n %d\n",tempArr[indexRes].result,indexRes);
				return;
			}
			else if(strcmp(curr->operator,"goto")==0){
				struct Quadruple* label = gotoHandler(curr->operand1);
				if(label==NULL) {
					printf("Label %s not found, exiting\n",curr->operand1);	
				}else{
					// printf("weewfewf\n");
					curr = label;
					// printf("ref is %s\n",curr->operand1);
					}
			}else if(strcmp(curr->operator,"IF")==0){
				if(curr->operand1[0]=='#'){
					int n = 0;
					char *op = (char *)calloc(sizeof(char),MAX_LENGTH);
					char *bd = (char *)calloc(sizeof(char),MAX_LENGTH);
					for(int i =1;i < strlen(curr->operand1);i++){
						// printf("%c ",curr->operand1[i]);
						if(curr->operand1[i] == '<' ||curr->operand1[i] == '>' ){
							break;
						}
						n++;
						op[i-1] = curr->operand1[i]; 
					}

					for(int i = n+3; i < strlen(curr->operand1);i++){
						bd[i-(n+3)] = curr->operand1[i];
					}
					float bound = atof(bd);
					// printf("op %s bound %f",op,bound);
					// return;
					char* res = findValFromVartable(op);
					if(curr->operand1[n+1]=='>'){
						if(atof(res)>=bound){
							struct Quadruple* label = gotoHandler(curr->result);
						if(label==NULL) {
							printf("Label %s not found, exiting\n",curr->result);	
						}else{
							curr = label;
						}
						}else{

						}
					}else{
						
						if(atof(res)<=bound){
							struct Quadruple* label = gotoHandler(curr->result);
						if(label==NULL) {
							printf("Label %s not found, exiting\n",curr->result);	
						}else{
							curr = label;
						}
						}else{
							}

				}

			
				}else{

				
				int type = findDataType(curr->operand1);
				//num
				 if(type<2){
					float res = atof(curr->operand1);
					if(res != 0){
						struct Quadruple* label = gotoHandler(curr->result);
						if(label==NULL) {
							printf("Label %s not found, exiting\n",curr->result);	
						}else{
							curr = label;
						}
					}else {
						
					}
				 }else if(type ==4){
				
				 int index = atoi(findSubstring(curr->operand1,2,strlen(curr->operand1)-2));
				 float res = atof(tempArr[index].result);
				 if(res != 0){
						struct Quadruple* label = gotoHandler(curr->result);
						if(label==NULL) {
						printf("Label %s not found, exiting\n",curr->result);	
						}else{
						curr = label;
						}
					}else {
						//go down
					}
				 }else{
					char* result = findValFromVartable(curr->operand2);
					float res = atof(result);
					if(res != 0){
						struct Quadruple* label = gotoHandler(curr->result);
						if(label==NULL) {
						printf("Label %s not found, exiting\n",curr->result);	
						}else{
						curr = label;
						}
					}else {
						//go down
					}
				 }
				}
				//var
			}else if(strcmp(curr->operator,"label")==0){

			}else if(strcmp(curr->operator,"write")==0){
				printf("%s\n",getWriteString(curr->operand1));
			}
			
			else{
				if(strcmp(curr->operator,":=")==0){
					//printf("%s = %s\n",curr->result,curr->operand1);
					int typeRes = findDataType(curr->result);
					int typeOp1 = findDataType(curr->operand1);
					if(typeRes==5){
						if(typeOp1 == 4){
							int index = atoi(findSubstring(curr->operand1,2,strlen(curr->operand1)-2));
							int valType = findDataType(tempArr[index].result);
							char data_type[100];
							if(valType == 0){
								// printf("inside assign statemn\n");
								// printVartable();
								insert_row_vartable(curr->result,"INTEGER",tempArr[index].result);
								// printf("%s\n",tempArr[index].result);
							}else if(valType == 1){
								insert_row_vartable(curr->result,"REAL",tempArr[index].result);
							}else if(valType == 2){
								insert_row_vartable(curr->result,"CHAR",tempArr[index].result);
							}
						}else if(typeOp1 == 5){
							char* res = findValFromVartable(curr->operand1);
							int valType = findDataType(res);
							if(valType == 0){
								insert_row_vartable(curr->result,"INTEGER",res);
							}else if(valType == 1){
								insert_row_vartable(curr->result,"REAL",res);
							}else if(valType == 2){
								insert_row_vartable(curr->result,"CHAR",res);
							}
						}else{
							// string
							int valType = findDataType(curr->operand1);
							if(valType == 0){
								insert_row_vartable(curr->result,"INTEGER",curr->operand1);
							}else if(valType == 1){
								insert_row_vartable(curr->result,"REAL",curr->operand1);
							}else if(valType == 2){
								insert_row_vartable(curr->result,"CHAR",curr->operand1);
							}
						}
					}else if(typeRes == 4){
						// entry in temp table
						int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
						if(typeOp1 == 4){
							int index = atoi(findSubstring(curr->operand1,2,strlen(curr->operand1)-2));
							int valType = findDataType(tempArr[index].result);
							char data_type[100];
							strcpy(tempArr[indexRes].result,tempArr[index].result);
						}else if(typeOp1 == 5){
							char* res = findValFromVartable(curr->operand1);
							strcpy(tempArr[indexRes].result,res);
						}else{
							// string
							strcpy(tempArr[indexRes].result,curr->operand1);
						}
					}
					
				}else{
					if(strcmp(curr->operand2,"")==0 && !isBoolOrRel(curr->operator)){
						if(strcmp(curr->operator,"SIZEOF")==0){
							// printf("%s = %s(%s)\n",curr->result,curr->operator,curr->operand1);
						}
						else if(strcmp(curr->operator,"-")==0){
							int typeRes = findDataType(curr->result);
							if(typeRes == 4){
								int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									
								 	char *tempRes = (char *)malloc(sizeof(char)*MAX_LENGTH);
								 	sprintf(tempRes,"-%s",curr->operand1);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
							}else{
								int valType = findDataType(curr->operand1);
								char *res = (char *)malloc(sizeof(char)*MAX_LENGTH);
								sprintf("-%s",curr->operand1);
								if(valType == 0){
								insert_row_vartable(curr->result,"INTEGER",res);
							}else if(valType == 1){
								insert_row_vartable(curr->result,"REAL",res);
							}else if(valType == 2){
								insert_row_vartable(curr->result,"CHAR",res);
							}
							}
						}
						else{
							// printf("%s = %s%s\n",curr->result,curr->operator,curr->operand1);
						}
					}else if(isBoolOrRel(curr->operator)){
						convertToLowercase(curr->operator);
						int type1 = findDataType(curr->operand1);
						int type2 = findDataType(curr->operand2);
						//printf("%s\n",curr->operator);
						
						
						//num num
						if(type1<2 && type2 < 2){
							int res=-1;
							if(type2==-1){
								res = !atof(curr->operand1);
							}
							else if(!strcmp(curr->operator,"<")){
								res = atof(curr->operand1) < atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,"<=")){
								res = atof(curr->operand1) <= atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,">")){
								res = atof(curr->operand1) > atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,">=")){
								//printf("hello");
								res = atof(curr->operand1) >= atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,"<>")){
								res = atof(curr->operand1) != atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,"=")){
								res = atof(curr->operand1) == atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,"and")){
								res = atof(curr->operand1) && atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,"or")){
								res = atof(curr->operand1) || atof(curr->operand2);
								
							}

							//printf("%d",res);
							if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
						}

						//num $
						if(type1<2 && type2 == 4){
							int index = atoi(findSubstring(curr->operand2,2,strlen(curr->operand2)-2));
							int valType = findDataType(tempArr[index].result);
							int res=-1;
							float result = atof(tempArr[index].result);
							if(type2==-1){
								res = !atof(curr->operand1);
							}
							else if(!strcmp(curr->operator,"<")){
								res = atof(curr->operand1) < result;
								
							}else if(!strcmp(curr->operator,"<=")){
								res = atof(curr->operand1) <= result;
								
							}else if(!strcmp(curr->operator,">")){
								res = atof(curr->operand1) > result;
								
							}else if(!strcmp(curr->operator,">=")){
								//printf("hello");
								res = atof(curr->operand1) >= result;
								
							}else if(!strcmp(curr->operator,"<>")){
								res = atof(curr->operand1) != result;
								
							}else if(!strcmp(curr->operator,"=")){
								res = atof(curr->operand1) == result;
								
							}else if(!strcmp(curr->operator,"and")){
								res = atof(curr->operand1) && result;
								
							}else if(!strcmp(curr->operator,"or")){
								res = atof(curr->operand1) || result;
								
							}

							//printf("%d",res);
							if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
						}
						//$ num

						if(type1==4 && type2 < 2){
							int index = atoi(findSubstring(curr->operand1,2,strlen(curr->operand1)-2));
							int valType = findDataType(tempArr[index].result);
							int res=-1;
							float result = atof(tempArr[index].result);
							if(type2==-1){
								res = !result;
							}
							else if(!strcmp(curr->operator,"<")){
								res = result < atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,"<=")){
								res = result <= atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,">")){
								res = result > atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,">=")){
								//printf("hello");
								res = result >= atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,"<>")){
								res = result != atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,"=")){
								res = result = atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,"and")){
								res = result && atof(curr->operand2);
								
							}else if(!strcmp(curr->operator,"or")){
								res = result || atof(curr->operand2);
								
							}

							//printf("%d",res);
							if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
						}

						//$ $

						if(type1==4 && type2 ==4){
							int index1 = atoi(findSubstring(curr->operand1,2,strlen(curr->operand1)-2));
							int valType1 = findDataType(tempArr[index1].result);
							int res=-1;
							float result1 = atof(tempArr[index1].result);

							int index2 = atoi(findSubstring(curr->operand2,2,strlen(curr->operand2)-2));
							int valType2 = findDataType(tempArr[index2].result);
							
							float result2 = atof(tempArr[index2].result);
							if(type2==-1){
								res = !result1;
							}
							else if(!strcmp(curr->operator,"<")){
								res = result1 < result2;
								
							}else if(!strcmp(curr->operator,"<=")){
								res = result1 <= result2;
								
							}else if(!strcmp(curr->operator,">")){
								res = result1 > result2;
								
							}else if(!strcmp(curr->operator,">=")){
								//printf("hello");
								res = result1 >= result2;
								
							}else if(!strcmp(curr->operator,"<>")){
								res = result1 != result2;
								
							}else if(!strcmp(curr->operator,"=")){
								res = result1 = result2;
								
							}else if(!strcmp(curr->operator,"and")){
								res = result1 && result2;
								
							}else if(!strcmp(curr->operator,"or")){
								res = result1 ||  result2;
								
							}

							//printf("%d",res);
							if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
						}

						// var var
						if(type1==5 && type2 ==5){
							char* res1 = findValFromVartable(curr->operand1);
							int valType1 = findDataType(res1);
							char* res2 = findValFromVartable(curr->operand2);
							int valType2 = findDataType(res2);
							int res = -1;

							float result2 = atof(res2);
							float result1 = atof(res1);
							if(valType2==-1){
								res = !result1;
							}
							else if(!strcmp(curr->operator,"<")){
								res = result1 < result2;
								
							}else if(!strcmp(curr->operator,"<=")){
								res = result1 <= result2;
								
							}else if(!strcmp(curr->operator,">")){
								res = result1 > result2;
								
							}else if(!strcmp(curr->operator,">=")){
								res = result1 >= result2;
								
							}else if(!strcmp(curr->operator,"<>")){
								res = result1 != result2;
								
							}else if(!strcmp(curr->operator,"=")){
								res = result1 = result2;
								
							}else if(!strcmp(curr->operator,"and")){
								res = result1 && result2;
								
							}else if(!strcmp(curr->operator,"or")){
								res = result1 ||  result2;
								
							}

							//printf("%d",res);
							if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
						}

						//var $ 
						if(type1==5 && type2 ==4){
							char* res1 = findValFromVartable(curr->operand1);
							int valType1 = findDataType(res1);

							int index2 = atoi(findSubstring(curr->operand2,2,strlen(curr->operand2)-2));
							int valType2 = findDataType(tempArr[index2].result);

							float result2 = atof(tempArr[index2].result);
							float result1 = atof(res1);
							int res = -1;
							if(valType2==-1){
								res = !result1;
							}
							else if(!strcmp(curr->operator,"<")){
								res = result1 < result2;
								
							}else if(!strcmp(curr->operator,"<=")){
								res = result1 <= result2;
								
							}else if(!strcmp(curr->operator,">")){
								res = result1 > result2;
								
							}else if(!strcmp(curr->operator,">=")){
								res = result1 >= result2;
								
							}else if(!strcmp(curr->operator,"<>")){
								res = result1 != result2;
								
							}else if(!strcmp(curr->operator,"=")){
								res = result1 = result2;
								
							}else if(!strcmp(curr->operator,"and")){
								res = result1 && result2;
								
							}else if(!strcmp(curr->operator,"or")){
								res = result1 ||  result2;
								
							}

							//printf("%d",res);
							if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
						}

						//$ var
						if(type1==4 && type2 ==5){
							char* res2 = findValFromVartable(curr->operand2);
							int valType2 = findDataType(res2);

							int index1 = atoi(findSubstring(curr->operand1,2,strlen(curr->operand1)-2));
							int valType1 = findDataType(tempArr[index1].result);

							float result2 = atof(res2);
							float result1 = atof(tempArr[index1].result);
							int res = -1;

							if(valType2==-1){
								res = !result1;
							}
							else if(!strcmp(curr->operator,"<")){
								res = result1 < result2;
								
							}else if(!strcmp(curr->operator,"<=")){
								res = result1 <= result2;
								
							}else if(!strcmp(curr->operator,">")){
								res = result1 > result2;
								
							}else if(!strcmp(curr->operator,">=")){
								res = result1 >= result2;
								
							}else if(!strcmp(curr->operator,"<>")){
								res = result1 != result2;
								
							}else if(!strcmp(curr->operator,"=")){
								res = result1 = result2;
								
							}else if(!strcmp(curr->operator,"and")){
								res = result1 && result2;
								
							}else if(!strcmp(curr->operator,"or")){
								res = result1 ||  result2;
								
							}

							//printf("%d",res);
							if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
						}

						// var num
						if(type1==5 && type2 < 2){
							char* res1 = findValFromVartable(curr->operand1);
							int valType1 = findDataType(res1);

							int res = -1;
							int valType2 = findDataType(curr->operand2);

							float result2 = atof(curr->operand2);
							float result1 = atof(res1);
							if(valType2==-1){
								res = !result1;
							}
							else if(!strcmp(curr->operator,"<")){
								res = result1 < result2;
								
							}else if(!strcmp(curr->operator,"<=")){
								res = result1 <= result2;
								
							}else if(!strcmp(curr->operator,">")){
								res = result1 > result2;
								
							}else if(!strcmp(curr->operator,">=")){
								res = result1 >= result2;
								
							}else if(!strcmp(curr->operator,"<>")){
								res = result1 != result2;
								
							}else if(!strcmp(curr->operator,"=")){
								res = result1 = result2;
								
							}else if(!strcmp(curr->operator,"and")){
								res = result1 && result2;
								
							}else if(!strcmp(curr->operator,"or")){
								res = result1 ||  result2;
								
							}

							//printf("%d",res);
							if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
						}

						// num var
						if(type1<2 && type2 ==5){
							char* res2 = findValFromVartable(curr->operand2);
							int valType2 = findDataType(res2);

							int valType1 = findDataType(curr->operand1);
							float result1 = atof(curr->operand1);
							float result2 = atof(res2);
							int res = -1;
							if(valType2==-1){
								res = !result1;
							}
							else if(!strcmp(curr->operator,"<")){
								res = result1 < result2;
								
							}else if(!strcmp(curr->operator,"<=")){
								res = result1 <= result2;
								
							}else if(!strcmp(curr->operator,">")){
								res = result1 > result2;
								
							}else if(!strcmp(curr->operator,">=")){
								res = result1 >= result2;
								
							}else if(!strcmp(curr->operator,"<>")){
								res = result1 != result2;
								
							}else if(!strcmp(curr->operator,"=")){
								res = result1 = result2;
								
							}else if(!strcmp(curr->operator,"and")){
								res = result1 && result2;
								
							}else if(!strcmp(curr->operator,"or")){
								res = result1 ||  result2;
								
							}

							//printf("%d",res);
							if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
						}


						
					}
					else{
					
						int type1 = findDataType(curr->operand1);
						int type2 = findDataType(curr->operand2);
						// printf("%d %d\n",type1,type2);
						// int int
						if(type1 == 0 && type2 == 0){
							if(strcmp(curr->operator,"/") == 0){
								// division by 0 check
								if(atoi(curr->operand2) == 0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = atoi(curr->operand1)*1.0 / atoi(curr->operand2)*1.0;
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}else if(strcmp(curr->operator,"*") == 0){
								int res = atoi(curr->operand1) * atoi(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}else if(strcmp(curr->operator,"+") == 0){
								int res = atoi(curr->operand1) + atoi(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}else if(strcmp(curr->operator,"-") == 0){
								int res = atoi(curr->operand1) - atoi(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}else if(strcmp(curr->operator,"%") == 0){
								int res = atoi(curr->operand1) % atoi(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}
						}

						// int float
						if(type1 == 0 && type2 == 1){
							if(strcmp(curr->operator,"/") == 0){
								// division by 0 check
								if(atof(curr->operand2) == 0){
									printf("Error: cannot divide by 0\n");
									////exit(1);
								}
								float res = atoi(curr->operand1)*1.0/ atof(curr->operand2)*1.0;
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}else if(strcmp(curr->operator,"*") == 0){
								float res = atoi(curr->operand1) * atof(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}else if(strcmp(curr->operator,"+") == 0){
								float res = atoi(curr->operand1) + atof(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}else if(strcmp(curr->operator,"-") == 0){
								float res = atoi(curr->operand1) - atof(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}
						}

						// float int
						if(type1 == 1 && type2 == 0){
							if(strcmp(curr->operator,"/") == 0){
								// division by 0 check
								if(atoi(curr->operand2) == 0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = atof(curr->operand1) / atoi(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}else if(strcmp(curr->operator,"*") == 0){
								float res = atof(curr->operand1) * atoi(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}else if(strcmp(curr->operator,"+") == 0){
								float res = atof(curr->operand1) + atoi(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}else if(strcmp(curr->operator,"-") == 0){
								float res = atof(curr->operand1) - atoi(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}
						}

						// float float
						if(type1 == 1 && type2 == 1){
							if(strcmp(curr->operator,"/") == 0){
								// division by 0 check
								if(atof(curr->operand2) == 0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = atof(curr->operand1) / atof(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}else if(strcmp(curr->operator,"*") == 0){
								float res = atof(curr->operand1) * atof(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);/
								}
							}else if(strcmp(curr->operator,"+") == 0){
								float res = atof(curr->operand1) + atof(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}else if(strcmp(curr->operator,"-") == 0){
								float res = atof(curr->operand1) - atof(curr->operand2);
								if(curr->result[0] == '$'){
									int index = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",index);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[index].result,tempRes);
									// printf("%s\n",tempArr[index].result);
								}
							}
						}

						// int $
						if(type1==0 && type2 == 4){
							int val1 = atoi(curr->operand1);
							int index = atoi(findSubstring(curr->operand2,2,strlen(curr->operand2)-2));
							int valType = findDataType(tempArr[index].result);
							if(valType==0){
								int val2 = atoi(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1*1.0 / val2*1.0;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								int res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								int res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								int res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"%") == 0){
								
								int res = val1 % val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}

							}
							else if(valType==1){
							float val2 = atof(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0.0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"*") == 0){
								
								float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							}
						}
							// $ int
						if(type1==4 && type2 == 0){
							int val2 = atoi(curr->operand2);
							int index = atoi(findSubstring(curr->operand1,2,strlen(curr->operand1)-2));
							int valType = findDataType(tempArr[index].result);
							if(valType==0){
								int val1 = atoi(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1*1.0 / val2*1.0;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								int res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								int res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								int res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"%") == 0){
								
								int res = val1 % val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}

							}
							else if(valType==1){
							float val1 = atof(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"*") == 0){
								
								float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							}
						}

					

						// float $
						if(type1==1 && type2 == 4){
							float val1 = atof(curr->operand1);
							int index = atoi(findSubstring(curr->operand2,2,strlen(curr->operand2)-2));
							int valType = findDataType(tempArr[index].result);
							if(valType==0){
								int val2 = atoi(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							

							}
							else if(valType==1){
							float val2 = atof(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0.0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"*") == 0){
								
								float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							}
						}

						// $ float

						if(type1==4 && type2 == 1){
							float val2 = atof(curr->operand2);
							int index = atoi(findSubstring(curr->operand1,2,strlen(curr->operand1)-2));
							int valType = findDataType(tempArr[index].result);
							if(valType==0){
								int val1 = atoi(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							

							}
							else if(valType==1){
							float val1 = atof(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"*") == 0){
								
								float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							}
						}

						// var float
						if(type1==5 && type2 == 1){
							float val2 = atof(curr->operand2);
							char* res = findValFromVartable(curr->operand1);
							int valType = findDataType(res);
							if(valType==0){
								int val1 = atoi(res);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							
							}
							else if(valType==1){
							float val1 = atof(res);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"*") == 0){
								
								float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							}
						}

						// int var
						if(type1==0 && type2 == 5){
							int val1 = atoi(curr->operand1);
							char* res = findValFromVartable(curr->operand2);
							int valType = findDataType(res);
							if(valType==0){
								int val2 = atoi(res);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1*1.0 / val2*1.0;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 int res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								int res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								int res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"%") == 0){
								
								int res = val1 % val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							
							}
							else if(valType==1){
							float val2 = atof(res);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"*") == 0){
								
								float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							}
						}
						// float var

						if(type1==1 && type2 == 5){
							float val1 = atof(curr->operand1);
							char* res = findValFromVartable(curr->operand2);
							int valType = findDataType(res);
							if(valType==0){
								int val2 = atoi(res);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							
							}
							else if(valType==1){
							float val2 = atof(res);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"*") == 0){
								
								float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							}
						}

						// var int
						if(type1==5 && type2 == 0){
							int val2 = atoi(curr->operand2);
							char* res = findValFromVartable(curr->operand1);
							int valType = findDataType(res);
							if(valType==0){
								int val1 = atoi(res);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1*1.0 / val2*1.0;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 int res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								int res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								int res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"%") == 0){
								
								int res = val1 % val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							
							}
							else if(valType==1){
							float val1 = atof(res);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"*") == 0){
								
								float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							}
						}
						// var $
						if(type1==5 && type2 == 4){
							int index = atoi(findSubstring(curr->operand2,2,strlen(curr->operand2)-2));
							int valType2 = findDataType(tempArr[index].result);
							char* res = findValFromVartable(curr->operand1);
							int valType1 = findDataType(res);
						if(valType1==0 && valType2==0){

								int val1 = atoi(res);
								int val2 = atoi(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1*1.0 / val2*1.0;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 int res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								int res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								int res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"%") == 0){
								
								int res = val1 % val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							
						
							
							
								
						}
						else if(valType1==0 && valType2==1){
							int val1 = atoi(res);
								float val2 = atof(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%f\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}

						}else if(valType1==1 && valType2==0){
							float val1 = atof(res);
							int val2 = atoi(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%f\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}

						}else if(valType1==1 && valType2==1){
							float val1 = atof(res);
							float val2 = atof(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%f\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
						}

						
						
						
						}
						// $ var

						if(type1==4 && type2 == 5){
							int index = atoi(findSubstring(curr->operand1,2,strlen(curr->operand1)-2));
							int valType1 = findDataType(tempArr[index].result);
							char* res = findValFromVartable(curr->operand2);
							int valType2 = findDataType(res);
						if(valType1==0 && valType2==0){

								int val2 = atoi(res);
								int val1 = atoi(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1*1.0 / val2*1.0;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 int res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								int res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								int res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"%") == 0){
								
								int res = val1 % val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							
						
							
							
								
						}
						else if(valType1==0 && valType2==1){
							int val2 = atoi(res);
								float val1 = atof(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%f\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}

						}else if(valType1==1 && valType2==1){
							float val2 = atof(res);
							float val1 = atof(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%f\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}

						}else if(valType1==1 && valType2==0){
							float val2 = atof(res);
							int val1 = atoi(tempArr[index].result);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%f\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
						}

						
						
						
						}


						// var var
						if(type1==5 && type2 == 5){
							char* res1 = findValFromVartable(curr->operand1);
							int valType1 = findDataType(res1);
							char* res2 = findValFromVartable(curr->operand2);
							int valType2 = findDataType(res2);
							// printf("%s %s",res1,res2);
						if(valType1==0 && valType2==0){

								int val2 = atoi(res2);
								int val1 = atoi(res1);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1*1.0 / val2*1.0;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 int res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								int res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								int res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"%") == 0){
								
								int res = val1 % val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							
						
							
							
								
						}
						else if(valType1==0 && valType2==1){
							int val1 = atoi(res1);
								float val2 = atof(res2);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1*1.0 / val2*1.0;

								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%f\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}

						}else if(valType1==1 && valType2==1){
							float val2 = atof(res2);
							float val1 = atof(res1);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1*1.0 / val2*1.0;

								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%f\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}

						}else if(valType1==1 && valType2==0){
							int val2 = atoi(res2);
							float val1 = atof(res1);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1*1.0 / val2*1.0;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%f\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
						}
						}
						

						// $ $
							if(type1==4 && type2 == 4){
								//printf("hello");
							int index1 = atoi(findSubstring(curr->operand1,2,strlen(curr->operand1)-2));
							// printf("%s\n",tempArr[index1].result);
							
							int valType1 = findDataType(tempArr[index1].result);
							char* res1 = tempArr[index1].result;
							int index2 = atoi(findSubstring(curr->operand2,2,strlen(curr->operand2)-2));
							// printf("%s\n",tempArr[index2].result);
							int valType2 = findDataType(tempArr[index2].result);
							char* res2 = tempArr[index2].result;
						if(valType1==0 && valType2==0){
								int val2 = atoi(res2);
								int val1 = atoi(res1);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1*1.0 / val2*1.0;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 int res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								int res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								int res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}else if(strcmp(curr->operator,"%") == 0){
								
								int res = val1 % val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%d",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							
						
							
							
								
						}
						else if(valType1==0 && valType2==1){
							int val1 = atoi(res1);
								float val2 = atof(res2);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%f\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}

						}else if(valType1==1 && valType2==1){
							float val2 = atof(res2);
							float val1 = atof(res1);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%f\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}

						}else if(valType1==1 && valType2==0){
							int val2 = atoi(res2);
							float val1 = atof(res1);
							if(strcmp(curr->operator,"/") == 0){
								if(val2==0){
									printf("Error: cannot divide by 0\n");
									//exit(1);
								}
								float res = val1 / val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"*") == 0){
								
								 float res = val1 * val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%f\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"+") == 0){
								
								float res = val1 + val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
							else if(strcmp(curr->operator,"-") == 0){
								
								float res = val1 - val2;
								if(curr->result[0] == '$'){
									int indexRes = atoi(findSubstring(curr->result,2,strlen(curr->result)-2));
									// printf("\n\n%d\n",indexRes);
									char tempRes[100];
									sprintf(tempRes,"%f",res);
									strcpy(tempArr[indexRes].result,tempRes);
									// printf("%s\n",tempArr[indexRes].result);
								}
								
							}
						}
						}
						
					}
				}
			}
			curr = curr->next;
		}
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
%left <tokenObj> BOOLEAN_OPERATOR
%left <tokenObj> NOT_OPERATOR
%left <tokenObj> RELATIONAL_OPERATOR
%left <tokenObj> ADDITIVE_OPERATOR
%left  <tokenObj> ARITHMETIC_OPERATOR R_PARENTHESIS

%type <tokenObj> start prog prog_body var_body begin_body id_list id_list_read_write array_declare read_statement write_statement assignment_statement block conditional_statements looping_statements expression arithmetic_expression boolean_expression comparision_exp loop_body loop_block for_val for_expression assignment_expression arithmetic_expression_util relational

%%
start: prog{
	saveASTasList(root);
	// printf("\n\n--------------------TAC Code Generated-------------------\n\n");
	// print_tac();
	// printf("\n\n--------------------Quadruples Generated-------------------\n\n");
	// print_quadruple();
	printf("\n\n");
	computeTempValues();
	printf("\n\n--------------------Variable Table-------------------\n\n");
	printVartable();
	printf("\n\n---------------------------------------\n\n");
	// printf("\n\n-------------------Temp Variable Table-------------------\\n\n");
	// printTemptable();
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
					pop(&top);
				};
write_red:ID L_BRACE arithmetic_expression R_BRACE {pop(&top);}
id_list_read_write:	ID {
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
						//push(&top,$1.lexeme);
					}
						$$.ptr = create_ast_node($1.lexeme);
						
						push(&top,$1.lexeme);
					}
					| STRING_INPUT_QUOTES {
						$$.ptr = create_ast_node($1.lexeme);
						push(&top,$1.lexeme);
					}
					| write_red{

					}
					| ID COMMA id_list_read_write{
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
					}
						ASTNode* commaNode = create_ast_node($2.lexeme);
						add_ast_child(commaNode,create_ast_node($1.lexeme),$3.ptr);
						$$.ptr = commaNode;
						char *str = pop(&top);
						char *newStr = (char *)malloc(sizeof(char)*MAX_LENGTH);
						
						sprintf(newStr,"%s,%s",$1.lexeme,str);
						push(&top,newStr);
					}
					|  write_red COMMA id_list_read_write {
					// 	ASTNode* lbraceNode = create_ast_node($2.lexeme);
					// 	ASTNode* idNode = create_ast_node($1.lexeme);
					// 	ASTNode* rbraceNode = create_ast_node($4.lexeme);
					// 	ASTNode* commaNode = create_ast_node($5.lexeme);
					// 	add_ast_child(lbraceNode,idNode,rbraceNode);
					// 	add_ast_child(rbraceNode,$3.ptr,commaNode);
					// 	add_ast_child(commaNode,NULL,$6.ptr);
					// 	$$.ptr = lbraceNode;
					// 	findTypeFromAST(lbraceNode,$1.line_number);
					// 	if(!check_undeclared($1.lexeme,$1.line_number)){
					// 	isInitialized($1.lexeme,$1.line_number);
					// }
					}
					| STRING_INPUT_QUOTES COMMA id_list_read_write{
						ASTNode* commaNode = create_ast_node($2.lexeme);
						add_ast_child(commaNode,create_ast_node($1.lexeme),$3.ptr);
						$$.ptr = commaNode;
						char *str = pop(&top);
						char *newStr = (char *)malloc(sizeof(char)*MAX_LENGTH);
						char *pushStr = (char*)malloc(sizeof(char)*MAX_LENGTH);
						sprintf(newStr,"%s,%s",$1.lexeme,str);
						push(&top,newStr);
					};

write_statement:	WRITE L_PARENTHESIS R_PARENTHESIS SEMICOLON {
						ASTNode* openNode = create_ast_node($2.lexeme);
						ASTNode* closeNode = create_ast_node($3.lexeme);
						add_ast_child(openNode,create_ast_node($1.lexeme),closeNode);
						add_ast_child(closeNode,NULL,create_ast_node($4.lexeme));
						$$.ptr = openNode;
						addTAC("write","","","");
					}
					| WRITE L_PARENTHESIS id_list_read_write R_PARENTHESIS SEMICOLON {
						ASTNode* openNode = create_ast_node($2.lexeme);
						ASTNode* closeNode = create_ast_node($4.lexeme);
						add_ast_child(openNode,create_ast_node($1.lexeme),closeNode);
						add_ast_child(closeNode,$3.ptr,create_ast_node($5.lexeme));
						$$.ptr = openNode;
						char *write = pop(&top);
						addTAC("write",write,"","");
					};

assignment_statement:	ID ASSIGNMENT assignment_expression SEMICOLON{
					// 	initialize($1.lexeme);
					// 	if(!check_undeclared($1.lexeme,$1.line_number)){
					// 	isInitialized($1.lexeme,$1.line_number);
					// }
					// 		ASTNode*  assignmentNode = create_ast_node($2.lexeme);
					// 		add_ast_child(assignmentNode,create_ast_node($1.lexeme),$3.ptr);
					// 		ASTNode* temp = $3.ptr;
					// 		while(temp!=NULL && temp->right!=NULL){
					// 			temp = temp->right;
					// 		}
					// 		temp->right = create_ast_node($4.lexeme);
					// 		isValidType($1.lexeme,$1.line_number,$3.ptr);
					// 		$$.ptr = assignmentNode;

							char t[MAX_LENGTH_TAC];
							strcpy(t,pop(&top));
							addTAC($2.lexeme,t,"",$1.lexeme);
							

						}
						| ID L_BRACE arithmetic_expression R_BRACE ASSIGNMENT assignment_expression SEMICOLON{
							//printf("kills mew");
							

							char index[MAX_LENGTH];
							char assign[MAX_LENGTH];
							strcpy(assign,pop(&top));
							strcpy(index,pop(&top));
							char t0[MAX_LENGTH_TAC];
							sprintf(t0,"$t%d",tVal++);
							addTAC("&",$1.lexeme,"",t0);
							char t1[MAX_LENGTH_TAC];
							sprintf(t1,"$t%d",tVal++);
							addTAC("SIZEOF",findTypeFromSymbolTable($1.lexeme),"",t1);
							char t2[MAX_LENGTH_TAC];
							sprintf(t2,"$t%d",tVal++);
							addTAC("*",t1,index,t2);
							char t3[MAX_LENGTH_TAC];
							sprintf(t3,"$t%d",tVal++);
							addTAC("+",t0,t2,t3);
							char res[MAX_LENGTH_TAC];
							sprintf(res,"*%s",t3);
							addTAC(":=",assign,"",res);
							
						};

assignment_expression:	CHAR_INPUT{
						insert_row($1.lexeme,"CHAR_INPUT","AST_CHAR_DATA_TYPE",$1.line_number);
							$$.ptr = create_ast_node($1.lexeme);
							push(&top,$1.lexeme);

						}
						| arithmetic_expression{
							$$.ptr = $1.ptr;
						}

arithmetic_expression:	arithmetic_expression ADDITIVE_OPERATOR arithmetic_expression{
							ASTNode* operatorNode = create_ast_node($2.lexeme);
							add_ast_child(operatorNode,$1.ptr,$3.ptr);
							$$.ptr = operatorNode;
							char *res=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
							char athExp[MAX_LENGTH];
							char athExpUt[MAX_LENGTH];
							strcpy(athExpUt,pop(&top));
							strcpy(athExp,pop(&top));
							sprintf(res,"$t%d",tVal++);
							addTAC($2.lexeme,athExp,athExpUt,res);
							push(&top,res);
						}
						| arithmetic_expression ARITHMETIC_OPERATOR arithmetic_expression{
							ASTNode* operatorNode = create_ast_node($2.lexeme);
							add_ast_child(operatorNode,$1.ptr,$3.ptr);
							$$.ptr = operatorNode;

							char *res=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
							char athExp[MAX_LENGTH];
							char athExpUt[MAX_LENGTH];
							strcpy(athExpUt,pop(&top));
							strcpy(athExp,pop(&top));
							sprintf(res,"$t%d",tVal++);
							addTAC($2.lexeme,athExp,athExpUt,res);
							push(&top,res);
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
							push(&top,$1.lexeme);
						}
						| REAL{
							insert_row($1.lexeme,"REAL","AST_REAL_DATA_TYPE",$1.line_number);
							$$.ptr = create_ast_node($1.lexeme);
							push(&top,$1.lexeme);
						}
						| ID {
						if(!check_undeclared($1.lexeme,$1.line_number)){
						isInitialized($1.lexeme,$1.line_number);
							}
							push(&top,$1.lexeme);
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

							char index[MAX_LENGTH];
							strcpy(index,pop(&top));
							char t0[MAX_LENGTH_TAC];
							sprintf(t0,"$t%d",tVal++);
							addTAC("&",$1.lexeme,"",t0);
							char t1[MAX_LENGTH_TAC];
							sprintf(t1,"$t%d",tVal++);
							addTAC("SIZEOF",findTypeFromSymbolTable($1.lexeme),"",t1);
							char t2[MAX_LENGTH_TAC];
							sprintf(t2,"$t%d",tVal++);
							addTAC("*",t1,index,t2);
							char t3[MAX_LENGTH_TAC];
							sprintf(t3,"$t%d",tVal++);
							addTAC("+",t0,t2,t3);
							char *res=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
							sprintf(res,"*%s",t3);
							push(&top,res);
						}
						| ADDITIVE_OPERATOR arithmetic_expression{
							ASTNode* additiveNode = create_ast_node($1.lexeme);
							add_ast_child(additiveNode,NULL,$2.ptr);
							$$.ptr = additiveNode;

							char *res=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
							sprintf(res,"$t%d",tVal++);
							addTAC($1.lexeme,pop(&top),"",res);
							push(&top,res);
						};


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

						char op2[MAX_LENGTH_TAC];
						strcpy(op2,pop(&top));
						char op1[MAX_LENGTH_TAC];
						strcpy(op1,pop(&top));
						char *t1=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
						sprintf(t1,"$t%d",tVal++);
						addTAC($2.lexeme,op1,op2,t1);
						push(&top,t1);
					}
					| relational{
						$$.ptr = $1.ptr;
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

						char op1[MAX_LENGTH_TAC];
						strcpy(op1,pop(&top));
						char *t1=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
						sprintf(t1,"$t%d",tVal++);
						addTAC($1.lexeme,op1,"",t1);
						push(&top,t1);
					}
					| arithmetic_expression{
						$$.ptr = $1.ptr;
						
					}
ifStart: IF comparision_exp THEN{
			char op[MAX_LENGTH];
			strcpy(op,pop(&top));
			char l1[MAX_LENGTH_TAC];
			sprintf(l1,"@L%d",lVal++);
			addTAC("IF",op,"goto",l1);
			char *l2=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
			sprintf(l2,"@L%d",lVal++);
			addTAC("goto",l2,"","");
			addTAC("label",l1,":","");
			push(&top,l2);
}

else: ELSE{
		char *l3=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
		sprintf(l3,"@L%d",lVal++);
		addTAC("goto",l3,"","");
		char l2[MAX_LENGTH_TAC];
		strcpy(l2,pop(&top));
		addTAC("label",l2,":","");
		push(&top,l3);
}

conditional_statements:	ifStart  block SEMICOLON{
						// 	ASTNode* ifNode = create_ast_node($1.lexeme);
						// 	ASTNode* thenNode = create_ast_node($3.lexeme);
						// 	add_ast_child(ifNode,$2.ptr,thenNode);
						// 	add_ast_child(thenNode,$4.ptr,create_ast_node($5.lexeme));
						// 	$$.ptr = ifNode;
						// isValidCondition($2.ptr,$1.line_number);
						char l2[MAX_LENGTH_TAC];
						strcpy(l2,pop(&top));
						addTAC("label",l2,":","");
						}
						| ifStart block else block SEMICOLON {
							// ASTNode* ifNode = create_ast_node($1.lexeme);
							// ASTNode* thenNode = create_ast_node($3.lexeme);
							// ASTNode* elseNode = create_ast_node($5.lexeme);
							// add_ast_child(ifNode,$2.ptr,thenNode);
							// add_ast_child(thenNode,$4.ptr,elseNode);
							// add_ast_child(elseNode,$6.ptr,create_ast_node($7.lexeme));
							// $$.ptr = ifNode;
							// isValidCondition($2.ptr,$1.line_number);
							char l2[MAX_LENGTH_TAC];
							strcpy(l2,pop(&top));
							addTAC("label",l2,":","");
						};

relational: arithmetic_expression RELATIONAL_OPERATOR arithmetic_expression{
				ASTNode* relationalNode = create_ast_node($2.lexeme);
				add_ast_child(relationalNode,$1.ptr,$3.ptr);
				$$.ptr = relationalNode;
				insert_row($2.lexeme,"RELATIONAL_OPERATOR","AST_RELATIONAL_OPERATOR",$2.line_number);

				char op2[MAX_LENGTH];
				strcpy(op2,pop(&top));
				char op1[MAX_LENGTH];
				strcpy(op1,pop(&top));
				char *res=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
				sprintf(res,"$t%d",tVal++);
				addTAC($2.lexeme,op1,op2,res);
				push(&top,res);
			};

while: WHILE  {
			char *l1=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
			sprintf(l1,"L%d",lVal++);
			addTAC("label",l1,":","");
			push(&top,l1);
			}
			 comparision_exp{
			char op[MAX_LENGTH];
			char *l1=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
			strcpy(op,pop(&top));
			strcpy(l1,pop(&top));
			char l2[MAX_LENGTH_TAC];
			sprintf(l2,"L%d",lVal++);
			addTAC("IF",op,"goto",l2);
			char *l3=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
			sprintf(l3,"L%d",lVal++);
			addTAC("goto",l3,"","");
			addTAC("label",l2,":","");
			push(&top,l3);
			push(&top,l1);
}
looping_statements:	while DO loop_block SEMICOLON {
						// ASTNode* whileNode = create_ast_node($1.lexeme);
						// ASTNode* doNode = create_ast_node($3.lexeme);
						// add_ast_child(whileNode,$2.ptr,doNode);
						// add_ast_child(doNode,$4.ptr,create_ast_node($5.lexeme));
						// $$.ptr = whileNode;
						// isValidCondition($2.ptr,$1.line_number);
						char l1[MAX_LENGTH_TAC];
						strcpy(l1,pop(&top));
						char l3[MAX_LENGTH_TAC];
						strcpy(l3,pop(&top));
						char l4[MAX_LENGTH_TAC];
						strcpy(l4,pop(&top));
						addTAC("goto",l1,"","");
						addTAC("label",l3,":","");

					}
					| FOR  for_expression DO loop_block SEMICOLON{
						//pop(&top);
						ASTNode* forNode = create_ast_node($1.lexeme);
						ASTNode* doNode = create_ast_node($3.lexeme);
						add_ast_child(forNode,$2.ptr,doNode);
						add_ast_child(doNode,$4.ptr,create_ast_node($5.lexeme));
						$$.ptr = forNode;

						char op[MAX_LENGTH_TAC];
						strcpy(op,pop(&top));
						char id[MAX_LENGTH];
						strcpy(id,pop(&top));
						char t[MAX_LENGTH_TAC];
						sprintf(t,"$t%d",tVal++);
						addTAC(op,id,"1",t);
						addTAC(":=",t,"",id);
						char l1[MAX_LENGTH_TAC];
						strcpy(l1,pop(&top));
						addTAC("goto",l1,"","");
						char l3[MAX_LENGTH_TAC];
						strcpy(l3,pop(&top));
						addTAC("label",l3,":","");
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
					char op2[MAX_LENGTH];
					strcpy(op2,pop(&top));
					char op1[MAX_LENGTH];
					strcpy(op1,pop(&top));
					addTAC(":=",op1,"",$1.lexeme);
					char *l1=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
					sprintf(l1,"@L%d",lVal++);
					addTAC("label",l1,":","");
					char condition[MAX_LENGTH];
					sprintf(condition,"#%s<=%s",$1.lexeme,op2);
					char l2[MAX_LENGTH_TAC];
					sprintf(l2,"@L%d",lVal++);
					addTAC("IF",condition,"goto",l2);
					char *l3=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
					sprintf(l3,"@L%d",lVal++);
					addTAC("goto",l3,"","");
					addTAC("label",l2,":","");
					push(&top,l3);
					push(&top,l1);
					push(&top,$1.lexeme);
					push(&top,"+");

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

					char op2[MAX_LENGTH];
					strcpy(op2,pop(&top));
					char op1[MAX_LENGTH];
					strcpy(op1,pop(&top));
					char index1[MAX_LENGTH];
					strcpy(index1,pop(&top));

					char t0[MAX_LENGTH_TAC];
					sprintf(t0,"$t%d",tVal++);
					addTAC("&",$1.lexeme,"",t0);
					char t1[MAX_LENGTH_TAC];
					sprintf(t1,"$t%d",tVal++);
					addTAC("SIZEOF",findTypeFromSymbolTable($1.lexeme),"",t1);
					char t2[MAX_LENGTH_TAC];
					sprintf(t2,"$t%d",tVal++);
					addTAC("*",t1,index1,t2);
					char t3[MAX_LENGTH_TAC];
					sprintf(t3,"$t%d",tVal++);
					addTAC("+",t0,t2,t3);
					char *res1= (char*)malloc(MAX_LENGTH_TAC*sizeof(char));;
					sprintf(res1,"*%s",t3);

					addTAC(":=",op1,"",res1);
					char *l1 = (char*)malloc(MAX_LENGTH_TAC*sizeof(char));
					sprintf(l1,"@L%d",lVal++);
					addTAC("label",l1,":","");
					char *condition=(char*)malloc(MAX_LENGTH_TAC*sizeof(char));
					sprintf(condition,"#%s<=%s",$1.lexeme,op2);
					char *l2=(char*)malloc(MAX_LENGTH_TAC*sizeof(char));;
					sprintf(l2,"@L%d",lVal++);
					addTAC("IF",condition,"goto",l2);
					char *l3=(char*)malloc(MAX_LENGTH_TAC*sizeof(char));;
					sprintf(l3,"@L%d",lVal++);
					addTAC("goto",l3,"","");
					addTAC("label",l2,":","");
					push(&top,l3);
					push(&top,l1);
					push(&top,res1);
					push(&top,"+");

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

					char op2[MAX_LENGTH];
					strcpy(op2,pop(&top));
					char op1[MAX_LENGTH];
					strcpy(op1,pop(&top));
					char index1[MAX_LENGTH];
					strcpy(index1,pop(&top));

					char t0[MAX_LENGTH_TAC];
					sprintf(t0,"$t%d",tVal++);
					addTAC("&",$1.lexeme,"",t0);
					char t1[MAX_LENGTH_TAC];
					sprintf(t1,"$t%d",tVal++);
					addTAC("SIZEOF",findTypeFromSymbolTable($1.lexeme),"",t1);
					char t2[MAX_LENGTH_TAC];
					sprintf(t2,"$t%d",tVal++);
					addTAC("*",t1,index1,t2);
					char t3[MAX_LENGTH_TAC];
					sprintf(t3,"$t%d",tVal++);
					addTAC("+",t0,t2,t3);
					char *res1=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
					sprintf(res1,"*%s",t3);

					addTAC(":=",op1,"",res1);
					char *l1=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
					sprintf(l1,"@L%d",lVal++);
					addTAC("label",l1,":","");
					char condition[MAX_LENGTH];
					sprintf(condition,"#%s>=%s",$1.lexeme,op2);
					char l2[MAX_LENGTH_TAC];
					sprintf(l2,"@L%d",lVal++);
					addTAC("IF",condition,"goto",l2);
					char *l3=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
					sprintf(l3,"@L%d",lVal++);
					addTAC("goto",l3,"","");
					addTAC("label",l2,":","");
					push(&top,l3);
					push(&top,l1);
					push(&top,res1);
					push(&top,"-");
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
					char op2[MAX_LENGTH];
					strcpy(op2,pop(&top));
					char op1[MAX_LENGTH];
					strcpy(op1,pop(&top));
					addTAC(":=",op1,"",$1.lexeme);
					char *l1=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
					sprintf(l1,"@L%d",lVal++);
					addTAC("label",l1,":","");
					char condition[MAX_LENGTH];
					sprintf(condition,"#%s>=%s",$1.lexeme,op2);
					char l2[MAX_LENGTH_TAC];
					sprintf(l2,"@L%d",lVal++);
					addTAC("IF",condition,"goto",l2);
					char *l3=(char*) malloc(MAX_LENGTH_TAC*sizeof(char));
					sprintf(l3,"@L%d",lVal++);
					addTAC("goto",l3,"","");
					addTAC("label",l2,":","");
					push(&top,l3);
					push(&top,l1);
					push(&top,$1.lexeme);
					push(&top,"-");
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
	/* print_symbol_table(); */
	return 0;
}

void yyerror(){
	printf("syntax error\n");
	//print_symbol_table();
	exit(0);
}