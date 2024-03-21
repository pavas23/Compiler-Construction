%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include<string.h>

    struct course{
        int unit;
        int grade;
        char *code;
    } typedef course;

    struct student_record{
        int coursePtr;
        course *courses[31];
        char *id;
    }typedef student_record;


    student_record *rec=NULL;
    char str[100];
    char stud_id[100];
    char currStuID[100];
    int temp_unit = 0;
    int temp_grade = 0;

    int courseF = 0;
    int unitF = 0;
    int gradeF = 0;
    int record_index = 0;

    int validRec = 0;
    int comment  = 0;
    int courseCount = 0;
    student_record *init(){
        student_record *ptr = (student_record *)malloc(sizeof(student_record));
        ptr->coursePtr = 0;
        ptr->id = (char *)malloc(sizeof(char)*100);
        return ptr;
    }
%}

studID [A-Z]+[0-9]+
courseID [A-Z]+[0-9]+
A A
A_ A\-
B B
Bminus B\-
C C
units [2-4]

%x STUDENT_RECORD
%s start
%x VALID_REC
%x TUPLE
%%
<INITIAL,start>\$ {courseCount=0;BEGIN STUDENT_RECORD; }

<INITIAL,start>\/\/ {
    comment++;
    char c;
     while((c=input())!='\n'){
        if(c==0 || c==EOF){
            break;
        }
     }
}

<INITIAL,start>. {
    char c;
    char d = 'd';
    while((c = input())!='$') {
        if(c=='\n')
        break;
        else if(c=='/' && d!='/'){
            d = '/';
        }else if(c=='/' && d=='/'){
            break;
        }
    }
    if(c=='$'){
        BEGIN STUDENT_RECORD;
    }else if(c=='/' && d=='/'){
        comment++;
        while((c = input())!='\n'){
            if(c==EOF || c==0) break;
        } 
    }else{
        // printf("Invalid Record");
    }
}

<INITIAL,start>\n {}

<STUDENT_RECORD>\n {
    BEGIN INITIAL;
}

<STUDENT_RECORD>[ ]+ {}

<STUDENT_RECORD>{studID} {
    courseCount = 0;
    if(strcmp(yytext,stud_id)==0 && rec==NULL){
        rec = init();
        strcpy(rec->id,yytext);
    }
    strcpy(currStuID,yytext);
    BEGIN VALID_REC;
}

<STUDENT_RECORD>\/\/ {
    comment++;
    char c;
    while((c=input())!='\n'){
        if(c==0 || c==EOF){
            break;
        }
    }
    BEGIN  INITIAL;
}

<STUDENT_RECORD><<EOF>> {
    if(courseCount>0){
        validRec++;
    }else{
        // printf("Record has no courses thus invalid");
    }
    yyterminate();
}

<STUDENT_RECORD>\$ {courseCount=0;BEGIN STUDENT_RECORD;}

<STUDENT_RECORD>. {
    BEGIN INITIAL;
}

<VALID_REC>[ ]+ {}

<VALID_REC>\$ {
    //check here if record has >= 1 course recs
    if(courseCount>0){
        validRec++;
    }else{
        // printf("Record has no courses thus invalid");
    }
    BEGIN STUDENT_RECORD;
}

<VALID_REC>\n {
    //check here if record has >= 1 course recs
    if(courseCount>0){
        validRec++;
    }else{
        // printf("Record has no courses thus invalid");
    }
    BEGIN INITIAL;
}

<VALID_REC><<EOF>> {
    if(courseCount>0){
        validRec++;
    }else{
        // printf("Record has no courses thus invalid");
    }
    yyterminate();
}

<VALID_REC>\/\/ {
        comment++;
        char c;
        while((c=input())!='\n'){
            // printf("%d ",c);
           if(c==EOF || c=='\0')break;
        }
        //check here if record has >= 1 course recs
        if(courseCount>0){
            validRec++;
        }else{
            // printf("Record has no courses thus invalid");
        }
        BEGIN  INITIAL;
}

<VALID_REC>\< {
    BEGIN TUPLE;
}

<TUPLE>[ ]+ {}

<TUPLE>{courseID} {
    if(!courseF && !unitF && !gradeF){
        courseF = 1;
        strcpy(str,yytext);
    }else{
        courseF =0;
        unitF = 0;
        gradeF = 0;
        char c;
        while((c=input())!='>'){
            if(c==EOF || c=='\n' || c==0){
                // printf(" this ");
                break;
            }
        }   
        BEGIN VALID_REC;
    }    
}

<TUPLE>{units} {
    if(courseF && !unitF && !gradeF){
        unitF=1;
        temp_unit = atoi(yytext);
    }else{
        courseF =0;
        unitF = 0;
        gradeF = 0;
        char c;
        while((c=input())!='>'){
            if(c==EOF || c=='\n' || c==0){
                // printf(" this ");
                break;
            }
        }
        BEGIN VALID_REC;
    }
}

<TUPLE>{A}|{Bminus}|{A_}|{B}|{C} {
    if(courseF && unitF && !gradeF){
        gradeF=1;
        char *gradesArr[] = {"A","A-","B","B-","C"};
        for(int i=0;i<5;i++){
            if(strcmp(yytext,gradesArr[i])==0){
                temp_grade = 10 - 2*i;
                break;
            }
        }
    }else{
        courseF =0;
        unitF = 0;
        gradeF = 0;
        char c;
        while((c=input())!='>'){
            if(c==EOF || c=='\n' || c==0){
                // printf(" this ");
                break;
            }
        }
        BEGIN VALID_REC;
    }
}

<TUPLE>\/\/ {
    comment++;
    char c;
    while((c=input())!='\n'){
        if(c==EOF || c==0) {
            courseF=0;
            unitF=0;
            gradeF=0;
            if(courseCount>0){
                validRec++;
            }else{
                // printf("Record has no courses thus invalid");
            }
            yyterminate();
        }
        else if(c=='\n'){
            // printf("n\n");
        }
    }
    if(c=='\n') {
        // printf("n\n");
    }
    courseF=0;
    unitF=0;
    gradeF=0;
    //check here if record has >= 1 course recs
    if(courseCount>0){
        validRec++;
    }else{
       // printf("Record has no courses thus invalid");
    }
    BEGIN  INITIAL;
}

<TUPLE>\> {
    if(gradeF && unitF && courseF){
        int f = -1;
        if(rec!=NULL && strcmp(stud_id,currStuID)==0){
            for(int i=0;i<rec->coursePtr;i++){
                if(strcmp(str,rec->courses[i]->code)==0){
                    f = i;
                    break;
                }
            }
            if(f==-1){
                rec->courses[rec->coursePtr] = (course *)malloc(sizeof(course));
                rec->courses[rec->coursePtr]->code = (char *)malloc(100*sizeof(char *));
                strcpy(rec->courses[rec->coursePtr]->code,str);
                rec->courses[rec->coursePtr]->unit = temp_unit;
                rec->courses[rec->coursePtr]->grade = temp_grade;
                rec->coursePtr++;
            }else{
                rec->courses[f]->grade = temp_grade;
            }
        }
        courseCount++;
    }else{
    	// printf("invalid tuple ");
    }
    courseF =0;
    unitF = 0;
    gradeF = 0;
    temp_grade = 0;
    temp_unit = 0;
    BEGIN VALID_REC;
}

<TUPLE>\n {
    BEGIN INITIAL;
    if(courseCount>0){
        validRec++;
    }else{
        // printf("Record has no courses thus invalid");
    }
    //check here if record has >= 1 course recs
}

<TUPLE><<EOF>> {
    if(courseCount>0){
        validRec++;
    }else{
        // printf("Record has no courses thus invalid");
    }
    yyterminate();
}

<TUPLE>. {
    courseF =0;
    unitF = 0;
    gradeF = 0;
    char c;
    while((c=input())!='>'){
        if(c==EOF || c=='\n' || c==0){
            // printf(" this ");
            break;
        }
    }
    BEGIN VALID_REC;
}

%%

int main(){
    yyin = fopen("data.txt","r");
    FILE *ip = fopen("input.txt","r");
    FILE *op = fopen("output.txt","w+");

    if(ip==NULL){
        printf("Error opening input file \n");
        return 0;
    }

    if(op==NULL){
        printf("Error opening output file \n");
        return 0;
    }

    fscanf(ip,"%s",stud_id);
    yylex();
    
    int grades = 0;
    int units = 0;
    int dist_courses = 0;
    int cgpa=0;

    if(rec != NULL){
        dist_courses = rec->coursePtr;
        for(int j=0;j<rec->coursePtr;j++){
            grades += (rec->courses[j]->grade)*(rec->courses[j]->unit);
            units += rec->courses[j]->unit;
        }
    
        if(units==0){
            cgpa = 0;
        }else{
            cgpa  = (int)round(((float)grades/(float)units)*100);
        }
    }
   
    fprintf(op,"%d@%d@%d@%d#",validRec,comment,dist_courses,cgpa);
    fclose(ip);
    fclose(op);

    return 0;
}