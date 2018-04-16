/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    TRUE = 258,
    FALSE = 259,
    EQUALS = 260,
    PLUSEQ = 261,
    MINUSEQ = 262,
    MULEQ = 263,
    DIVEQ = 264,
    MODEQ = 265,
    EXPEQ = 266,
    INT = 267,
    UINT = 268,
    BOOL = 269,
    IF = 270,
    ELSE = 271,
    WHILE = 272,
    SWITCH = 273,
    CASE = 274,
    BREAK = 275,
    DEFAULT = 276,
    OR = 277,
    AND = 278,
    BITOR = 279,
    BITXOR = 280,
    BITAND = 281,
    EQ = 282,
    NE = 283,
    LT = 284,
    LE = 285,
    GT = 286,
    GE = 287,
    ADD = 288,
    MINUS = 289,
    MUL = 290,
    DIV = 291,
    MOD = 292,
    EXP = 293,
    NOT = 294,
    BITNOT = 295,
    IDENTIFIER = 296,
    NUMBER = 297,
    IFS = 298
  };
#endif
/* Tokens.  */
#define TRUE 258
#define FALSE 259
#define EQUALS 260
#define PLUSEQ 261
#define MINUSEQ 262
#define MULEQ 263
#define DIVEQ 264
#define MODEQ 265
#define EXPEQ 266
#define INT 267
#define UINT 268
#define BOOL 269
#define IF 270
#define ELSE 271
#define WHILE 272
#define SWITCH 273
#define CASE 274
#define BREAK 275
#define DEFAULT 276
#define OR 277
#define AND 278
#define BITOR 279
#define BITXOR 280
#define BITAND 281
#define EQ 282
#define NE 283
#define LT 284
#define LE 285
#define GT 286
#define GE 287
#define ADD 288
#define MINUS 289
#define MUL 290
#define DIV 291
#define MOD 292
#define EXP 293
#define NOT 294
#define BITNOT 295
#define IDENTIFIER 296
#define NUMBER 297
#define IFS 298

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 25 "Assignment.y" /* yacc.c:1909  */
 
   char data[100]; /* Will store the data such as NUMBERS and IDENTIFIERS */
   struct return_info 
	{
		char* code; /* Stores the appended 3 address code */
		char addr[50]; /* The new temporary variable that is generated */
		char datatype[10];/*Stores the datatype of the expression returned for semantic analysis */	
	}inf; /*Structure that is the return type of non-terminals. Helps to generate 3-address code*/
 

#line 151 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
