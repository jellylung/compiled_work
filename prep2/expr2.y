%{
/*********************************************
中缀转后缀
YACC file
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
#ifndef YYSTYPE
#define YYSTYPE char* //返回字符串后缀表达式
#endif
char idstr[50];
char numstr[50];
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

//TODO:给每个符号定义一个单词类别
%token ADD MINUS
%token MULTIPLY DIVIDE
%token NUMBER
%token ID //标识符
%token LPAREN RPAREN

%left LPAREN
%left ADD MINUS
%left MULTIPLY DIVIDE
%right UMINUS  
%right RPAREN


%%


lines   :       lines expr '\n' { printf("%s\n", $2); }
        |       lines '\n'
        |
        ;
//TODO:完善表达式的规则
expr    :       expr ADD expr   { $$=(char*)malloc(50*sizeof(char)); 
                                strcpy($$,$1);strcat($$,$3);strcat($$,"+");  }
        |       expr MINUS expr   {$$=(char*)malloc(50*sizeof(char)); 
                                strcpy($$,$1);strcat($$,$3);strcat($$,"-");  }
		|       expr MULTIPLY expr   { $$=(char*)malloc(50*sizeof(char)); 
                                strcpy($$,$1);strcat($$,$3);strcat($$,"*");  }
		|       expr DIVIDE expr   { $$=(char*)malloc(50*sizeof(char)); 
                                strcpy($$,$1);strcat($$,$3);strcat($$,"/");  }
		|       LPAREN expr RPAREN      { $$=(char*)malloc(50*sizeof(char)); 
                                        strcpy($$,$2); }
        |       MINUS expr %prec UMINUS   {$$=(char*)malloc(50*sizeof(char));
                                                 strcpy($$,$2); strcat($$,"- "); }
		|       NUMBER    {$$=(char*)malloc(50*sizeof(char)); 
                                 strcpy($$,$1); strcat($$,""); }
        |       ID      {$$=(char*)malloc(50*sizeof(char)); 
                                strcpy($$,$1); strcat($$,""); }
        ;

%%

// programs section

int yylex()
{
    int t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'){
            //do noting 忽略空格、制表符
        }else if(isdigit(t)){
            //TODO:解析多位数字返回数字类型 
            int ti=0;
            while(isdigit(t)){
                numstr[ti]=t;
                t=getchar();
                ti++;
            }   
            numstr[ti]='\0';//结束字符串（数组末尾/0）
            yylval=numstr;
            ungetc(t, stdin);
            return NUMBER;
        }
         else if((t>='a'&&t<='z')||(t>='A'&&t<='Z')||(t=='_')){
              int ti=0;
              while((t>='a'&&t<='z')||(t>='A'&&t<='Z')
                     ||(t=='_')||(t>='0'&& t<='9')){
                      idstr[ti]=t;
                      ti++;
                      t=getchar();
                  }
               idstr[ti]='\0';
               yylval=idstr;
               ungetc(t,stdin);
               return ID;
        }
        else if(t=='+'){
            return ADD;
        }else if(t=='-'){
            return MINUS;
        }//TODO:识别其他符号
        else if(t=='*'){
            return MULTIPLY;
        }else if(t=='/'){
            return DIVIDE;
        }else if(t=='('){
            return 	LPAREN;
        }else if(t==')'){
            return RPAREN;
        }else{
            return t;
        }
    }
}

int main(void)
{
    yyin=stdin;
    do{
        yyparse();
        printf("Parsing complete.\n"); // 调试输出
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}