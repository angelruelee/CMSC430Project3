/* CMSC 430: Compiler Theory and Design */
/* Name: Angel Lee */
/* Project 3* /
/* Date: Nov 5, 2021*/
/* This file contains function definitions for the evaluation functions */
/*edited from lecture source file to fit Project 3 criteria */


typedef char* CharPtr;
enum Operators {LESS, ADD, SUBTRACT, MULTIPLY, DIVIDE, EXPONENT, EQUAL, NOTEQUAL, MORE, MOREEQUAL, LESSEQUAL};

int evaluateReduction(Operators operator_, int head, int tail);
int evaluateIf(int expression, int thenStatement, int elseStatement);
int evaluateCaseStatement(int cases, int otherStatement);
int evaluateCases(int head, int tail);
int evaluateCase(int literal, int statement);
void caseIdentifier (int expression);
int evaluateCase(int literal, int statement);
int evaluateRelational(int left, Operators operator_, int right);
int evaluateArithmetic(int left, Operators operator_, int right);
int evaluateExponent(int left, Operators operator_, int right);
