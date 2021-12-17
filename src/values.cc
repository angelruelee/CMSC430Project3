/* CMSC 430: Compiler Theory and Design */
/* Name: Angel Lee */
/* Project 3* /
/* Date: Nov 5, 2021*/
/* This file contains the bodies of the evaluation functions, edited from lecture source file to fit Project 3 criteria */

#include <string>
#include <vector>
#include <cmath>
#include <map>
#include <iostream>

using namespace std;

#include "values.h"
#include "listing.h"
#include "symbols.h"

int foundValue;
bool matched;
int cases;

int evaluateReduction(Operators operator_, int head, int tail)
{
	if (operator_ == ADD)
		return head + tail;
	return head * tail;
}

int evaluateIf(int expression, int thenStatement, int elseStatement)
{
	if (expression == 1)
		return thenStatement;
	return elseStatement;
}

int evaluateCaseStatement(int cases, int otherStatement)
{
	if (matched == true) { ///if one of the cases matched
		matched = false; ///toggle back to false for future use
		return cases;
	}
	
	return otherStatement;
}


int evaluateCases(int head, int tail)
{
		cases = head + tail; //combine all non-other cases into case_
		return cases; 
}

int evaluateCase(int literal, int statement)
{	

	if (literal == foundValue) ///if the int is same as the found value
	{
		matched = true; //toggle to true
		return statement; //return statement as result
	}
	return 0; ///if unmatched, return 0
}

void caseIdentifier (int expression)
{
	foundValue = expression; ///expression base off ID will return stored value
}

int evaluateRelational(int left, Operators operator_, int right)
{
	int result;
	switch (operator_)
	{
		case LESS:
			result = left < right;
			break;
		case EQUAL:
			result = left == right;
			break;
		case NOTEQUAL:
			result = left != right;
			break;
		case MORE:
			result = left > right;
			break;
		case MOREEQUAL:
			result = left >= right;
			break;
		case LESSEQUAL:
			result = left <= right;
			break;
	}
	return result;
}

int evaluateArithmetic(int left, Operators operator_, int right)
{
	int result;
	switch (operator_)
	{
		case ADD:
			result = left + right;
			break;
		case SUBTRACT:
			result = left - right;
			break;
		case MULTIPLY:
			result = left * right;
			break;
		case DIVIDE:
			result = left / right;
			break;
	}
	return result;
}

int evaluateExponent(int left, Operators operator_, int right)
{
	int result;
	switch (operator_)
	{
		case EXPONENT:
			result = pow(left, right);
			break;
	}
	return result;
}

