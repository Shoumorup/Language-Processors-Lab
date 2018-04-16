%{
	#include <bits/stdc++.h>
	#include "y.tab.h" /*Includes the Yacc generated header file "y.tab.h"*/
	using namespace std;	
%}

DIGIT [0-9]
ALPHA [a-zA-Z]

%%
[ \t\n]+ ;/*Ignore Tabs, whitespaces and newlines*/

	/* Pattern to recognise integer literals */
{DIGIT}+ { 
		   strcpy(yylval.data,yytext);
		   return (NUMBER);/* Return Token=NUMBER and value(the number itself) in yylval */
		 }

	/* Patterns to recognise various keywords that are self-explanatory */
"if" {return (IF);}
"else" {return (ELSE);}
"while" {return (WHILE); }
"switch" {return (SWITCH);}
"case" {return (CASE);}
"break" {return (BREAK);}
"default" {return (DEFAULT);}

	/* Patterns to recognise various datatypes that are self-explanatory */
"int" { return (INT);}
"unsigned int" {return (UINT);}
"bool" {return (BOOL);}

	/* Patterns to recognise boolean literals that are self-explanatory */
"true" { return (TRUE);}
"false" { return (FALSE);}

	/* Pattern to reconise keywords */
 {ALPHA}+ { 
            strcpy(yylval.data,yytext);
	        return (IDENTIFIER); /* Return Token=IDENTIFIER and value(the identifier itself) in yylval */
	      }

	/* Patterns to recognise various Relational Operators */
"="  { return (EQUALS);} // Assignment
"==" { return (EQ);} // Equal to- Equal to
"!=" { return (NE);} // Not Equal to
"<"  { return (LT);} // Lesser than
">"  { return (GT);} // Greater than
">=" { return (GE);} // Greater than or equal to
"<=" { return (LE);} // Lesser than or equal to

	/* Patterns to recognise various Assignment Operators that are self-explanatory */
"+=" { return (PLUSEQ);}
"-=" { return (MINUSEQ);}
"*=" { return (MULEQ);}
"/=" { return (DIVEQ);}
"^=" { return (EXPEQ);}
"%=" { return (MODEQ);}

	/* Patterns to recognise various Arithmetic Operators */
"+"  { return (ADD);} // Addition
"-"  { return (MINUS);} // Subtraction
"*"  { return (MUL);} // Multiplication
"/"  { return (DIV);} // Division
"@"  { return (EXP);} // Exponentiation
"%"  { return (MOD);} // Remainder/Modulus

	/* Patterns to recognise various Bitwise Operators that are self-explanatory */
"|"	 { return (BITOR);}
"&"  { return (BITAND);}
"~"	 { return (BITNOT);}
"^"  { return (BITXOR);}

	/* Patterns to recognise various Logical Operators that are self-explanatory */
"||" { return (OR);}
"&&" { return (AND);}
"!"  { return (NOT);}

	/* Patterns to recognise miscellaneous characters that form integral part of Sub-C statements */
['(' | ')' | '{' | '}' | ',' | ':' | ';' ]  { return yytext[0];}
.    ;
%%

int yywrap(void) /* Called to return 1 when the input is exhausted, otherwise returns 0 if more input is pending*/
{
	return 1;
}


