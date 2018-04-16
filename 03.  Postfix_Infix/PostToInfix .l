  /*Give spaces between each operand/operator */
%{
  char* post; //Input string containing the postfix expression
  char* stack[1000]; //Stack Declaration
  int top=-1; //Points to the top of the stack
  void print();
  void push(char* input);
  char* pop();
%}

%%
[0-9]+ { push(yytext); }
[+|\-|*|/] { char* ch1=(char*)malloc(100*sizeof(char)); ch1=pop(); char* ch2=(char*)malloc(100*sizeof(char)); ch2=pop();  
             char* buffer=(char*)malloc(100*sizeof(char)); strcat(buffer,"("); strcat(buffer,ch2); strcat(buffer,yytext); 
             strcat(buffer,ch1); strcat(buffer,")");push(buffer);
           }
%%


void push(char* input)
{
  ++top;
  stack[top]=(char*)malloc(100*sizeof(char));
  strcpy(stack[top],input);  
}

char* pop()
{
  char* ret=(char*)malloc(100*sizeof(char));
  strcpy(ret,stack[top]);
  top--;
  return ret;
}

int main()
{
  yylex();
  printf("The infix expression is: %s\n",stack[top]);
}

int yywrap()
{
  return 1;
} 
