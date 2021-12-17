/* CMSC 430: Compiler Theory and Design */
/* Name: Angel Lee */
/* Project 3* /
/* Date: Nov 5, 2021*/
/* This file is the parser with parsing methods, edited from lecture source file to fit Project 3 criteria */

%{

#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <cassert>
#include <cstdlib>
#include <queue>

using namespace std;

#include "values.h"
#include "listing.h"
#include "symbols.h"

int yylex();
void yyerror(const char* message);

Symbols<int> symbols;
int result;

///queue to store arg vector values in
queue<int> argQueue;

%}

%define parse.error verbose

%union
{
	CharPtr iden;
	Operators oper;
	int value;
}

%token <iden> IDENTIFIER
%token TYPE
%token <value> INT_LITERAL REAL_LITERAL BOOL_LITERAL

%token <oper> ADDOP MULOP RELOP REMOP EXPOP
%token ANDOP OROP NOTOP 

%token BEGIN_ BOOLEAN END ENDREDUCE FUNCTION INTEGER IS REDUCE RETURNS
%token ARROW CASE ELSE ENDCASE ENDIF IF OTHERS REAL THEN WHEN

%type <value> body statement_ statement reductions expression relation term
	factor primary andop remop expop case_ case
%type <oper> operator

%%

function: ///counts the whole text	
	function_header optional_variable body {result = $3;} ;
	
function_header: ///first line, must start with "function", and IDENTIFIER or test name based off the id in scanner.l, optional parameter, "returns", and then type
	FUNCTION IDENTIFIER parameters RETURNS type ';' |
	error ';'; ///added otherwise parser will stop at error at function header

optional_variable: ///optional variable can include a variable or nothing/blank
	optional_variable variable | ///another optional_variable added in case of 2 or more variable lines such as in test12
	;

variable: ///identifier + ':' + 'is', then type (int, real, or bool), word 'is', then statement
	IDENTIFIER ':' type IS statement_ {symbols.insert($1, $5);} |
	error ';' ; ///added otherwise parser will stop at error at variable problems

parameters: ///used in function header
	parameters ',' parameter | ///make it optional to have multiple parameters with commas
	parameter ; ///or parameter

parameter: ///used in parameters
	IDENTIFIER ':' type {symbols.insert($1, argQueue.front()); argQueue.pop();} | ///identifier or test name with ':' and then type (int, real, or bool)
	; ///or be blank

type: ///used in function header, can be integer, real, or boolean
	INTEGER | 
	REAL | 
	BOOLEAN ;

body: ///used in function
	BEGIN_ statement_ END ';' {$$ = $2;} ; /// begin + statement + end
    
statement_: ///statement with parenthesis, used in body and variable
	statement ';' | ///a statement
	error ';' {$$ = 0;} ;
	
statement:
	expression |
	REDUCE operator reductions ENDREDUCE {$$ = $3;} |
	IF expression THEN statement_ ELSE statement_ ENDIF {$$ = evaluateIf($2, $4, $6);} | /// if _ then 'statement' else 'statement' endif
	CASE expression {caseIdentifier($2);} IS case_ OTHERS ARROW statement_ ENDCASE {$$ = evaluateCaseStatement($5, $8);} ; 
	///case _ is 'when int. => statement' others => statement endcase

operator:
	ADDOP |
	MULOP ;

case_: ///can be a case, or blank
	case_ case {$$ = evaluateCases($1, $2);} | ///can have multiple cases {$$ = evaluateCase($1, $2);}
	{$$ = 0;}; ///case can be empty and provide value of 0 for case_ in 'case_ case'
		
case: ///used in statement
	WHEN INT_LITERAL ARROW statement_ {$$ = evaluateCase($2, $4);} | ///when int. => 'statement'.
	error ';' {$$ = 0;} ; ///added otherwise parser will stop at error at variable problems 
	 
	
reductions:
	reductions statement_ {$$ = evaluateReduction($<oper>0, $1, $2);} | ///the <oper>0 is the variable BEFORE reductions in statement, so its "operator"
	{$$ = $<oper>0 == ADD ? 0 : 1;} ;

expression:
	expression OROP relation {$$ = $1 || $3;} |
	andop ;

///added
andop:
	expression ANDOP relation {$$ = $1 && $3;} |
	relation;
	
relation:
	relation RELOP term {$$ = evaluateRelational($1, $2, $3);} |
	term ;

term:
	term ADDOP remop {$$ = evaluateArithmetic($1, $2, $3);} |
	remop ;
	
///added
remop:
	remop REMOP factor {$$ = evaluateArithmetic($1, $2, $3);} |
	factor;
	      
factor:
	factor MULOP expop {$$ = evaluateArithmetic($1, $2, $3);} |
	expop ;

///added
expop:
	expop EXPOP primary {$$ = evaluateExponent($1, $2, $3);} | ///primary ** exponent, right associative
	primary; ///or just primary
	
primary:
	'(' expression ')' {$$ = $2;} |
	INT_LITERAL |
	REAL_LITERAL |
	BOOL_LITERAL |
	IDENTIFIER {if (!symbols.find($1, $$)) appendError(UNDECLARED, $1);} ;

%%

void yyerror(const char* message)
{
	appendError(SYNTAX, message);
}

int main(int argc, char *argv[])    
{
	///count arguments and push current arg value into queue
	for(int i = 1; i < argc; i++) ///for integer of one and less
	{
		argQueue.push(atoi(argv[i])); ///push current argument value into queue	
	}
		
	firstLine();
	yyparse();
	if (lastLine() == 0)
		cout << "Result = " << result << endl;
	return 0;
} 
