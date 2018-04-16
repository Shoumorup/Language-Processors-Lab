%{
	#include<bits/stdc++.h>
	using namespace std;

	int yylex(); /* Call to yylex() to read input and generate tokens */
	void yyerror(const char*); /* Error handling routine */

		/* FUNCTIONAL UNITS */
	string expression_action(char*,char*,char*,char*,char*,char*,char*,char*,int,int);/* Specifies action for an Expression production*/
	void if_action(char*,char*,char*,char*,char*);/* Specifies what to do corresponding to if- production*/
	void if_else_action(char*,char*,char*,char*,char*,char*);/* Specifies what to do corresponding to if-else production*/
	string newtemp(); /* Generates a new temporary variable to be incorporated into 3-address code*/
	string newlabel(); /* Generates a new label to be incorporated into 3-address code */
	void declare(char*,char* ,string ); /* Used to declare the various identifiers */

		/* GLOBAL VARIABLES */
	int temp=0,temp1=0;/* Counters to generate temp variables and labels respectively */
	char* answer; /* Stores the final 3-address code to be printed */
	string pass,lbl; /* Global variables to be used for switch case constructs */
	bool error_flag=false; /* To not print output should any unforeseen error occur */
	map<string,string>sym_tab;	/* Symbol table that stores identifiers and their types */
%}

%union 
 { 
   char data[100]; /* Will store the data such as NUMBERS and IDENTIFIERS */
   struct return_info 
	{
		char* code; /* Stores the appended 3 address code */
		char addr[50]; /* The new temporary variable that is generated */
		char datatype[10];/*Stores the datatype of the expression returned for semantic analysis */	
	}inf; /*Structure that is the return type of non-terminals. Helps to generate 3-address code*/
 } 

 /* Defining TOKENS and their precedence and associativity */
%token TRUE FALSE
%token EQUALS PLUSEQ MINUSEQ MULEQ DIVEQ MODEQ EXPEQ
%token INT UINT BOOL
%token IF ELSE WHILE SWITCH CASE BREAK DEFAULT
%left OR
%left AND
%left BITOR
%left BITXOR
%left BITAND
%left EQ NE
%left LT LE GT GE
%left ADD MINUS
%left MUL DIV MOD 
%right EXP
%right NOT BITNOT 
%token <data> IDENTIFIER
%token <data> NUMBER
%start block /* Defining the start symbol */
		/* Defining return type of the non-terminals: TYPE= struct return_info inf */
%type <inf> block stmt declaration assignment E T if_stmt while_stmt switch_stmt cases
%type <inf> identifier_i identifier_ui identifier_b
		/* Defining the IF-ELSE precedence to resolve shift-reduce conflict */
%nonassoc IFS
%nonassoc ELSE


%%
block   : 	        {	
				$$.code=(char*)malloc(10);
				strcpy($$.code,"");						
			} /* Base Production to end recursion */
	| block stmt 	{	
				$$.code=(char*)malloc(10000);
				strcpy($$.code,$1.code);
				strcat($$.code,$2.code);
				strcpy(answer,$$.code); /* Stores the final answer */
		 	}/* Blocks of statements followed by one more statement*/				  
	;

	/* NON-TERMINAL: stmt= Derives the various statements in the Grammar */		  
stmt 	: '{' block '}'   {	
				$$.code=(char*)malloc(1000);
				strcpy($$.code,$2.code);
			  } /* Production for parenthesized blocks */

	| ';'		 {
				$$.code=(char*)malloc(1000);
				strcpy($$.code,"");
		         } /* Production for an empty statement */

	| BREAK ';'      {
				$$.code=(char*)malloc(1000);
				strcpy($$.code,"");
		         } /* Production to symbolise Break in a switch statement */

	|  declaration   {	
				$$.code=(char*)malloc(1000);
				strcpy($$.code,$1.code); /* Appending the code in a bottom-up fashion to head of production */
	                 } /* Production for a declaration statement */ 

	|  assignment    {	
				$$.code=(char*)malloc(1000);
				strcpy($$.code,$1.code);
			 } /* Production for an Assignment statement */

 	|  if_stmt       {	
				$$.code=(char*)malloc(1000);
				strcpy($$.code,$1.code);
		         } /* Production for an if-statement */ 

 	|  while_stmt	 {
				$$.code=(char*)malloc(1000);
				strcpy($$.code,$1.code);
 			 } /* Production for a while statement */

 	|  switch_stmt	 {
				$$.code=(char*)malloc(1000);
				strcpy($$.code,$1.code);
 			 } /* Production for a switch block statement */
 	;  

 		/* NON-TERMINAL: declaration= Derives all the declaration statements */
declaration:INT IDENTIFIER ';'	{	
					$$.code=(char*)malloc(1000);
					declare($2,$$.code,"INT");								
				} /* int a; */

	   | UINT IDENTIFIER ';'{	
					$$.code=(char*)malloc(1000);
					declare($2,$$.code,"UINT");			 
				}/* unsigned int a; */

	   | BOOL IDENTIFIER ';'{	
					$$.code=(char*)malloc(1000);
					declare($2,$$.code,"BOOL");		
		  		}/* bool check */

	   | INT IDENTIFIER ',' identifier_i ';' {
  								$$.code=(char*)malloc(1000);
								declare($2,$$.code,"INT");								
  								strcat($$.code,$4.code);
		  				 } /* int a,b,c */ 
		  							
	   | UINT IDENTIFIER ',' identifier_ui ';'{
  								$$.code=(char*)malloc(1000);
								declare($2,$$.code,"UINT");		
  								strcat($$.code,$4.code);	
		  				  }/* unsigned int a,b,c; */

	   | BOOL IDENTIFIER ','identifier_b ';' {
  								$$.code=(char*)malloc(1000);
								declare($2,$$.code,"BOOL");		
  								strcat($$.code,$4.code);	
		  				 }/* bool flag1,flag2; */
	  ;

	 /* NON-TERMINAL: identifier_i: Declaration of multiple identifiers of "int" type together */
identifier_i: IDENTIFIER            {
						$$.code=(char*)malloc(1000);
						declare($1,$$.code,"INT");		
				    }

	    | IDENTIFIER ',' identifier_i{
						$$.code=(char*)malloc(1000);
						declare($1,$$.code,"INT");		
						strcat($$.code,$3.code);	
					 } 
	    ; 

	    /* NON-TERMINAL: identifier_ui: Declaration of multiple identifiers of "uint" type together */
identifier_ui: IDENTIFIER            {
						$$.code=(char*)malloc(1000);
						declare($1,$$.code,"UINT");		
				     }

	     | IDENTIFIER ',' identifier_ui{
						$$.code=(char*)malloc(1000);
						declare($1,$$.code,"UINT");		
						strcat($$.code,$3.code);
					   } 
             ; 

        /* NON-TERMINAL: identifier_b: Declaration of multiple identifiers of "bool" type together */
identifier_b: IDENTIFIER            {
						$$.code=(char*)malloc(1000);
						declare($1,$$.code,"BOOL");		
				    }

	    | IDENTIFIER ',' identifier_b
					{
						$$.code=(char*)malloc(1000);
						declare($1,$$.code,"BOOL");	
						strcat($$.code,$3.code);	
					} 
	; 

/* NON-TERMINAL: assignment: To assign values of expressions to identifiers with/without declaration */
assignment  :  INT IDENTIFIER EQUALS E ';'
					{
						 if(strcmp($4.datatype,"BOOL")==0)
						 {
						    	printf("ERROR! Cannot assign a Boolean value to an Integer\n");
						    	exit(1);  error_flag=true;
						 }/* Cannot assign a Boolean variable to an integer */
						 string s($2),temp($4.addr);
						 string code="Assign "+s+" 4 bytes\n";
						 sym_tab[s]="INT";//Store in Symbol table
						 $$.code=(char*)malloc(1000); 
						 strcpy($$.code,code.c_str());
						 if(strcmp($4.addr,$4.code)!=0) strcat($$.code,$4.code);/*If not terminal append the code*/
						 code=""; code=s+"="+temp+"\n";						
						 strcat($$.code,code.c_str());
					}/* Production for int a=5; */
	    |  UINT IDENTIFIER EQUALS E ';'
					{
						if(strcmp($4.datatype,"UINT")!=0)
					    	{
					    		printf("ERROR! Incompatible types\n");
					    		error_flag=true; exit(1);
					    	}/* Cannot assign a Boolean variable or an int to an unsigned integer */
					    	string s($2),temp($4.addr);
					    	string code="Assign "+s+" 4 bytes\n";
						sym_tab[s]="UINT";//Store in Symbol table
						$$.code=(char*)malloc(1000);
						strcpy($$.code,code.c_str());
						if(strcmp($4.addr,$4.code)!=0) strcat($$.code,$4.code);/*If not terminal append the code*/
						code=""; code=s+"="+temp+"\n";						
						strcat($$.code,code.c_str());
					}/* Production for unsigned int a=5; */									
	    |  BOOL IDENTIFIER EQUALS E ';'
					{
						if(strcmp($4.datatype,"BOOL")!=0)
					    	{
					    		printf("ERROR! Cannot assign a Integer value to an Integer\n");
					    		error_flag=true; exit(1);
					    	}/* Cannot assign a Integer variable to boolean variable*/
					    	string s($2),temp($4.addr);
					    	string code="Assign "+s+" 1 byte\n";
						sym_tab[s]="BOOL";//Store in Symbol table
						$$.code=(char*)malloc(1000);
						strcpy($$.code,code.c_str());
						if(strcmp($4.addr,$4.code)!=0) strcat($$.code,$4.code);/*If not terminal append the code*/
						code=""; code=s+"="+temp+"\n";						
						strcat($$.code,code.c_str());
					}/* Production for unsigned bool a=(5<4); */		
	    |  IDENTIFIER EQUALS E ';' 
					{
						string s($1),temp($3.addr);
						if(sym_tab.find(s)==sym_tab.end())
						{
							printf("Unrecognised identifier\n");
							error_flag=true; exit(1);
						}/* Check to make sure Identifier already exists */
						if(strcmp(sym_tab[s].c_str(),$3.datatype)!=0)
						{
							printf("Incompatible types\n");
							error_flag=true; exit(1);
						}/* Type checking */
						string code=s+" = "+temp+"\n";
						$$.code=(char*)malloc(1000);
						if(strcmp($3.addr,$3.code)!=0) strcpy($$.code,$3.code);/*If not terminal append the code*/
						strcat($$.code,code.c_str());
					}/* Production for a=(5+4); */
            |  IDENTIFIER PLUSEQ E ';'
					{
						string s($1),temp($3.addr);
						if(sym_tab.find(s)==sym_tab.end())
						{
							printf("Unrecognised identifier\n");
							error_flag=true; exit(1);
						}/* Check to make sure Identifier already exists */
						if(strcmp(sym_tab[s].c_str(),$3.datatype)!=0)
						{
							printf("Incompatible types\n");
							error_flag=true; exit(1);
						}/* Type checking */
						string code=s+" = "+s+" + "+temp+"\n"; 
						$$.code=(char*)malloc(1000);
						if(strcmp($3.addr,$3.code)!=0) strcpy($$.code,$3.code);/*If not terminal append the code*/
						strcat($$.code,code.c_str());
					}/* Production for a+=(5+4); */
	    |  IDENTIFIER MINUSEQ E ';'
					{
						string s($1),temp($3.addr);
						if(sym_tab.find(s)==sym_tab.end())
						{
							printf("Unrecognised identifier\n");
							error_flag=true; exit(1);
						}/* Check to make sure Identifier already exists */
						if(strcmp(sym_tab[s].c_str(),$3.datatype)!=0)
						{
							printf("Incompatible types\n");
							error_flag=true; exit(1);
						}/* Type checking */
						string code=s+" = "+s+" - "+temp+"\n";
						$$.code=(char*)malloc(1000);
						if(strcmp($3.addr,$3.code)!=0) strcpy($$.code,$3.code);/*If not terminal append the code*/
						strcat($$.code,code.c_str());
					}/* Production for a-=(5+4); */	
	    |  IDENTIFIER MULEQ E ';'
					{
						string s($1),temp($3.addr);
						if(sym_tab.find(s)==sym_tab.end())
						{
							printf("Unrecognised identifier\n");
							error_flag=true; exit(1);
						}/* Check to make sure Identifier already exists */
						if(strcmp(sym_tab[s].c_str(),$3.datatype)!=0)
						{
							printf("Incompatible types\n");
							error_flag=true; exit(1);
						}/* Type checking */
						string code=s+" = "+s+" * "+temp+"\n";
						$$.code=(char*)malloc(1000);
						if(strcmp($3.addr,$3.code)!=0) strcpy($$.code,$3.code);/*If not terminal append the code*/
						strcat($$.code,code.c_str());
					}/* Production for a*=(5+4); */
	    |  IDENTIFIER DIVEQ E ';'
					{
						string s($1),temp($3.addr);
						if(sym_tab.find(s)==sym_tab.end())
						{
							printf("Unrecognised identifier\n");
							error_flag=true; exit(1);
						}/* Check to make sure Identifier already exists */
						if(strcmp(sym_tab[s].c_str(),$3.datatype)!=0)
						{
							printf("Incompatible types\n");
							error_flag=true; exit(1);
						}/* Type checking */
						string code=s+" = "+s+" / "+temp+"\n";
						$$.code=(char*)malloc(1000);
						if(strcmp($3.addr,$3.code)!=0) strcpy($$.code,$3.code);/*If not terminal append the code*/
						strcat($$.code,code.c_str());
					}/* Production for a/=(5+4); */
	    |  IDENTIFIER MODEQ E ';'
					{
						string s($1),temp($3.addr);
						if(sym_tab.find(s)==sym_tab.end())
						{
							printf("Unrecognised identifier\n");
							error_flag=true; exit(1);
						}/* Check to make sure Identifier already exists */
						if(strcmp(sym_tab[s].c_str(),$3.datatype)!=0)
						{
							printf("Incompatible types\n");
							error_flag=true; exit(1);
						}/* Type checking */
						string code=s+" = "+s+" % "+temp+"\n";
						$$.code=(char*)malloc(1000);
						if(strcmp($3.addr,$3.code)!=0) strcpy($$.code,$3.code);/*If not terminal append the code*/
						strcat($$.code,code.c_str());
					}/* Production for a%=(5+4); */
	     |  IDENTIFIER EXPEQ E ';'
					{
						string s($1),temp($3.addr);
						if(sym_tab.find(s)==sym_tab.end())
						{
							printf("Unrecognised identifier\n");
							error_flag=true; exit(1);
						}/* Check to make sure Identifier already exists */
						if(strcmp(sym_tab[s].c_str(),$3.datatype)!=0)
						{
							printf("Incompatible types\n");
							error_flag=true; exit(1);
						}/* Type checking */
						string code=s+" = "+s+" @ "+temp+"\n";
						$$.code=(char*)malloc(1000);
						if(strcmp($3.addr,$3.code)!=0) strcpy($$.code,$3.code);/*If not terminal append the code*/
						strcat($$.code,code.c_str());
					}/* Production for a@=(5+4); */	
        ;

        /*NON-TERMINAL: if_stmt: To generate 3-address code for  the if-else construct */
if_stmt : IF '(' E ')' stmt  %prec IFS
					{
						$$.code=(char*)malloc(10000);
						if_action($$.code,$3.datatype,$3.code,$3.addr,$5.code);
					}/* Generates 3-address code for  if-statements */

	| IF '(' E ')' stmt ELSE stmt 
					{
						$$.code=(char*)malloc(10000);
						if_else_action($$.code,$3.datatype,$3.code,$3.addr,$5.code,$7.code);
					}/* Generates 3-address code for  if-else statements */
        ;

  	/*NON-TERMINAL: switch_stmt: To generate 3-address code for the switch construct */
switch_stmt : SWITCH '(' E ')' '{' cases '}'
					{	
					   	$$.code=(char*)malloc(10000);
					   	if(strcmp($3.datatype,"BOOL")==0)
						{
							printf("Incompatible types\n");
							error_flag=true; exit(1);
						}/*Check whether the datatype to switch is an Integer or Unsigned Int */
						sprintf($$.code,"%s\nswitch %s\n{\n%s}\n%s:\n",$3.code,$3.addr,$6.code,lbl.c_str());						
					} /*Generates 3-address code for Switch block */
	    ;

	/* NON-TERMINAL: cases: To generate 3-address code for the various cases */
cases   : CASE NUMBER ':' block cases
					{
						$$.code=(char*)malloc(10000);
						string label1=newlabel();
						sprintf($$.code,"if not equal to %s goto %s\n%sgoto %s\n%s\n%s",$2,label1.c_str(),$4.code,lbl.c_str(),label1.c_str(),$5.code);
					} 
	| DEFAULT ':' stmt 	        {
						$$.code=(char*)malloc(10000);
						lbl=newlabel();
						sprintf($$.code,"%sgoto %s\n",$3.code,lbl.c_str());																
					}
	;
	
	/*NON-TERMINAL: switch_stmt: To generate 3-address code for the while construct */
while_stmt : WHILE '(' E ')' stmt  
					{
						$$.code=(char*)malloc(10000);
						if(strcmp($3.datatype,"BOOL")!=0)
						{
							printf("Incompatible types\n");
							error_flag=true; exit(1);
						}/* Type checking as only works with BOOL return type expressions */
						string label2=newlabel(),label1=newlabel();
						sprintf($$.code,"%s:\n%sif %s ==false goto %s\n{\n%sgoto %s\n}\n%s:\n",label2.c_str(),$3.code,$3.addr,label1.c_str(),$5.code,label2.c_str(),label1.c_str());
				       	}
	   ;

	/* NON-TERMINAL: E: To generate 3-address code for Expressions- Integer and Boolean */
E	: 	T 	{ 
				strcpy($$.datatype,$1.datatype);
				strcpy($$.addr,$1.addr);
			}/* Production to return an identifier,number or Boolean literal */

	| E ADD E       {
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,0);
				strcpy($$.addr,s.c_str()); char buffer[100];
				sprintf(buffer,"%s = %s + %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);							
		        }/* Production to ADD 2 integer or unsigned integer expressions*/

	| E MINUS E     {
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,0);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s - %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to SUBTRACT 2 integer or unsigned integer expressions*/	

	| E MUL E 	{
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,0);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s * %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to MULTIPLY 2 integer or unsigned integer expressions*/

	| E DIV E	{
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,0);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s / %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to DIVIDE 2 integer or unsigned integer expressions*/

	| E MOD E	{
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,0);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s % %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to get MOD of 2 integer or unsigned integer expressions*/

	| E EXP E	{
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,0);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s @ %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to EXPONENTIATE 2 integer or unsigned integer expressions*/

	| E BITAND E    {
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,0);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s & %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to find BITWISE AND of 2 integer or unsigned integer expressions*/

	| E BITOR E     {
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,0);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s | %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to find BITWISE OR of 2 integer or unsigned integer expressions*/

	| BITNOT E 	{
				if(strcmp($2.datatype,"BOOL")==0)
				{
				  printf("ERROR! Incompatible datatypes\n");
				  error_flag=true; exit(1);
				}/*Checking whether of Integer or Unsigned Int tpyes */
				string s=newtemp(),temp($2.datatype);
				strcpy($$.addr,s.c_str());
				sym_tab[s]=temp; strcpy($$.datatype,temp.c_str());
				$$.code=(char*)malloc(1000); char buffer[100]; strcpy($$.code,"");
				if(strcmp($2.addr,$2.code)!=0) strcat($$.code,$2.code);
				sprintf(buffer,"%s = ~%s\n",s.c_str(),$2.addr);	
				strcat($$.code,buffer);				
		        }/* Production to find BITWISE NOT of an integer or unsigned integer expression*/

	| E BITXOR E 	{
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,0);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s ^ %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to find BITWISE XOR of 2 integer or unsigned integer expressions*/

	| E AND E	{
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,1,1);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s && %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to find LOGICAL AND of 2 boolean expressions*/

	| E OR E	{
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,1,1);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s || %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to find LOGICAL OR of 2 boolean expressions*/

	| NOT E	   	{
				if(strcmp($2.datatype,"BOOL")!=0)
				{
				  printf("ERROR! Incompatible datatypes\n");
				  error_flag=true; exit(1);
				}/* Perform this operation only if E is of type "BOOL" */
				string s=newtemp();
				strcpy($$.addr,s.c_str());
				sym_tab[s]="BOOL"; strcpy($$.datatype,"BOOL");
				$$.code=(char*)malloc(1000); char buffer[100]; strcpy($$.code,"");
				if(strcmp($2.addr,$2.code)!=0) strcat($$.code,$2.code);
				sprintf(buffer,"%s = !%s\n",s.c_str(),$2.addr);	
				strcat($$.code,buffer);		
	                }/* Production to find LOGICAL NOT of a boolean expressions*/

	| E EQ E 	{
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,1);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s == %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
 			}/* Production to check if 1st Integer expression equals 2nd Integer expression. Returns Boolean type*/

	| E GT E        {
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,1);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s > %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to check if 1st Integer expression is greater than 2nd Integer expression. Returns Boolean type*/

	| E LT E 	{
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,1);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s < %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to check if 1st Integer expression is lesser than 2nd Integer expression. Returns Boolean type*/

	| E NE E        {
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,1);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s != %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to check if 1st Integer expression does not equal 2nd Integer expression. Returns Boolean type*/

	| E GE E        {
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,1);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s >= %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to check if 1st Integer expression greater than equals 2nd Integer expression. Returns Boolean type*/

	| E LE E        {
				$$.code=(char*)malloc(1000);
				string s=expression_action($$.code,$$.datatype,$1.datatype,$3.datatype,$1.addr,$3.addr,$1.code,$3.code,0,1);
				strcpy($$.addr,s.c_str());	char buffer[100];
				sprintf(buffer,"%s = %s <= %s\n",s.c_str(),$1.addr,$3.addr);
				strcat($$.code,buffer);
		        }/* Production to check if 1st Integer expression lesser than equals 2nd Integer expression. Returns Boolean type*/

	;
	/* NON-TERMINAL: T: To generate 3-address code for identifiers,numbers and Boolean literals */
T    : IDENTIFIER 	{
				string s($1);
				if(sym_tab.find(s)==sym_tab.end())
				{
				  printf("ERROR! Variable not defined\n");
				  error_flag=true; exit(1);
				}/* Check if already defined or not. If not, ERROR! */		
				strcpy($$.datatype,sym_tab[$1].c_str());
				strcpy($$.addr,$1);		
				$$.code=(char*)malloc(1000); strcpy($$.code,$1);						
			}/* Production to use an identifier */

        | NUMBER   	{
				strcpy($$.datatype,"INT");
				strcpy($$.addr,$1); 
				$$.code=(char*)malloc(1000); strcpy($$.code,$1);	        					
                        }/* Production to use an number */

        | TRUE		{
				strcpy($$.datatype,"BOOL");
				strcpy($$.addr,"true"); 
				$$.code=(char*)malloc(1000); strcpy($$.code,"true");	       					
                        }/* Production to use a TRUE boolean literal*/

        | FALSE         {
		                strcpy($$.datatype,"BOOL");
		                strcpy($$.addr,"false"); 
		                $$.code=(char*)malloc(1000); strcpy($$.code,"false");	
                        }/* Production to use a FALSE boolean literal*/

        | '(' E ')'     {
				$$.code=(char*)malloc(10000);
				strcpy($$.datatype,$2.datatype);
				strcpy($$.addr,$2.addr);
				strcpy($$.code,$2.code);        					
        		}/* Production to parenthesize expressions*/
        ;
%%        

int main(int argc,char** argv)
{
	printf("Please follow the following rules: \n 1. Do not put break anywhere else other than with switch \n 2. Datatypes are int,unsigned int,bool \n ");
	printf("3. Define Variables before use \n 4. Do not assign int to Unsigned int \n 5. Nested if-else,switch and while work \n ");
	printf("6. Provide default with switch \n 7. Blank statement is ; {} not accepted \n 8. Do not apply &&, ||, ! to Integer expressions\n ");
	printf("9. Switch is only for Integer or Unsigned int \n 10. Do not provide Expressions in cases \n 11. Do not put break in while \n ");
        printf("12. if and while only handles boolean expressions,i.e. Expressions that are boolean or evaluate to boolean \n");
	printf("13. Press Ctrl+D to see output \n");  
  	 
	answer=(char*)malloc(65536);
	yyparse(); /* Call to parse the input */
	/* Print the final answer - the entire 3-address Code */
	if(!error_flag) printf("The generated Intermediate Code is: \n%s",answer);		
}

void declare(char* data,char* ecode,string typ) /* Used to declare the various identifiers */
{
	string s(data),code="Assign "+s;
	if(typ!="BOOL") code+=" 4 bytes\n"; 
	else code+=" 1 byte\n";
	sym_tab[s]=typ; /* Storing the identifier in the Symbol table along with its datatype */
	strcpy(ecode,code.c_str());	/* Returning the 3-address code of the declaration in ecode */		
}
/* Specifies action for an Expression production*/
string expression_action(char* ecode,char* $$_type,char *$1_type,char *$3_type,char* $1_place,char* $3_place,char* $1_code,char* $3_code,int flag,int check)
{

    if(!flag && (strcmp($1_type,$3_type)!=0 || strcmp($1_type,"BOOL")==0) ||(flag && (strcmp($1_type,"BOOL")!=0 || strcmp($3_type,"BOOL")!=0)))
    {
	printf("ERROR! Incompatible datatypes\n");
	error_flag=true; exit(1);
    }/*Check for type compatibility. Flag=0 means both should be Integers or Unsigned Int; Flag=1 means both should be boolean*/
    string s=newtemp(),temp($1_type);
    if(!check) 
    {
      sym_tab[s]=temp;
      strcpy($$_type,$1_type);
    }/* Return Type=(Same as that of operands) when check=0 */
    else 
    {
      sym_tab[s]="BOOL";
      strcpy($$_type,"BOOL");
    }/* Return Type=BOOL when check=1 (For Relational operations) */
    strcpy(ecode,"");
    if(strcmp($1_place,$1_code)!=0) strcat(ecode,$1_code);
    if(strcmp($3_place,$3_code)!=0)  strcat(ecode,$3_code);
    return s;
}

string newtemp() /* Generates a new temporary variable to be incorporated into 3-address code */
{
	++temp;
	char buffer[100];
	sprintf(buffer,"t%d",temp);
	string s(buffer); return s;
}

string newlabel() /* Generates a new label to be incorporated into 3-address code */
{
	++temp1;
	char buffer[100];
	sprintf(buffer,"L%d",temp1);
	string s(buffer); return s;
}

/* Specifies what to do corresponding to if- production*/
void if_action(char* ecode,char* type,char* code,char* addr,char* code2)
{
	if(strcmp(type,"BOOL")!=0) 
	{
		printf("Incompatible datatypes\n");
		error_flag=true; exit(1);
	} /* Type checking to see if expression returns BOOL type. ELse report error! */
	string s=newlabel(); /* New Label generated where to go when false */
	sprintf(ecode,"%sif %s ==false goto %s\n{\n%s}\n%s:\n",code,addr,s.c_str(),code2,s.c_str());	
}

/* Specifies what to do corresponding to if-else production*/
void if_else_action(char* ecode,char* type,char* code,char* addr,char* code1,char* code2) 
{

	if(strcmp(type,"BOOL")!=0) 
	{
		printf("Incompatible datatypes\n");
		error_flag=true; exit(1);
	} /* Type checking to see if expression returns BOOL type. ELse report error! */

	string label1=newlabel(),label2=newlabel();/* Label1= Goto when if=false; Goto when if=true */
	sprintf(ecode,"%sif %s ==false goto %s\n{\n%s}\ngoto %s\n%s:\n{\n%s}\n%s:\n",code,addr,label1.c_str(),code1,label2.c_str(),label1.c_str(),code2,label2.c_str());	
}

void yyerror(const char *s) /* Error handling routine */
{
	fprintf(stderr, "error: %s\n", s);
}
