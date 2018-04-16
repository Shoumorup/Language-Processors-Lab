  /*Give spaces between each operand/operator */
%{
  char* post; //Input string containing the postfix expression
  float stack[1000]; //Stack Declaration
  int top=-1; //Points to the top of the stack
  void push(char* input);
  float pop();
  void evaluate(char* yytext);
%}

%%
[ \t\n]  ;
[0-9]+  push(yytext);
[+|\-|*|/] evaluate(yytext);          
 . ;         
%%

void evaluate(char* yytext)
{
  float a=pop(); float b=pop(),x; 
  char* allot=(char*)malloc(100*sizeof(char));
  char c=yytext[0];
  switch(c)
  {
      case '+': x=b+a; sprintf(allot,"%f",x); break;
      case '-': x=b-a; sprintf(allot,"%f",x); break;
      case '*': x=b*a; sprintf(allot,"%f",x); break;   
      case '/': x=b/a; sprintf(allot,"%f",x); break;
  }
  push(allot);
}

void push(char* input)
{
  ++top;
  float x=atof(input);
  stack[top]=x;
}

float pop()
{
  return stack[top--];
}

int main()
{
  yylex();
  printf("The result is: %.02f\n",stack[top]);
}

int yywrap()
{
  return 1;
} 
