%{
#include <bits/stdc++.h>
using namespace std;

map <char*,int> table;// To store values assigned to identifiers
void yyerror(char*s);// To report errors if some other symbol is encountered
int yylex(void);
%}


%union {int num; string id;}
%start line
%token print
%token exit_command
%token bracketopen
%token bracketclose
%token <num> number
%token <id> identifier
%type <num> line exp term factor
%type <id> assignment




%%

line	: assignment ';'		{;}
		| exit_command ';'		{exit(EXIT_SUCCESS);}
		| print exp ';'			{printf("Printing %d\n",$2);}
		| line assignment ';'	{;}
		| line print exp   ';'	{printf("Printing %d\n",$3);}
		| line exit_command ';'	{exit(EXIT_SUCCESS);}
		;

assignment : identifier '=' exp {string s($1); table[s]=$3;}

exp		: term 					{$$=$1;}
		| exp '+' term 			{$$=$1+$3;}
		| exp '-' term 			{$$=$1-$3;}
		;


term	: 	factor				{$$=$1;}
		|	term '*' factor		{$$=$1*$3;}
		|	term '/' factor 	{$$=$1/$3;}
		;
factor 	:	bracketopen exp bracketclose			{$$=$2;}
	 	| number 				{$$=$1;}
		| identifier			{string s($1);
		if(table.find(s)!=table.end())$$=table[s];else printf("%c not defined\n",$1);}
		;

%%

void yyerror(char *s){
	printf("the error \n");
	return;
}

int main(void){
	return yyparse();
}