%{
#define MAX_LENGTH 256
#define LIST strcat(buffer, yytext)
#define token(t) { LIST; printf("<%s>\n", #t); }
#define tokenChar(t) { LIST; printf("<'%c'>\n", t); }
#define tokenInteger(t,i) { LIST; printf("<%s: %d>\n", #t, i); }
#define tokenString(t,s) { LIST; printf("<%s: %s>\n", #t, s); }

#include <string>
#include <map>
#include <vector>

using std::string;
using std::map;
using std::vector;

int lineNo = 1;
char buffer[MAX_LENGTH];

class symbolTable 
{
	public:
		symbolTable();
		int lookup(string s);
		int insert(string s);
		int dump();
        private:
                vector<string> symbols;
                map<string, int> tableMap;
                int index;

};

symbolTable *table;

%}

arithmetic              ([-+*/%])
delimiters              ([,:;.()[\]{}])
identifiers             ([A-Za-z][0-9A-Za-z]*)
digit                   ([0-9]+)
integer                 ({digit})
relational              ([<>!=])
real                    ([-+]?{digit}\.{digit}?([eE](-+)?{digit})?)
string                  (\"(\"\"|[^"\n])*\")
singleComment           (\/\/[^\n]*)
startComment            (\/\*)
endComment              (\*\/)

%x COMMENT

%%

 /* Single-character token */
{delimiters}  |
{arithmetic} |
{relational}	{ 
			tokenChar(yytext[0]); 
		}

  /* Double-relational-character token */
"<="                    { token('<='); }
">="                    { token('>='); }
"=="                    { token('=='); }
"!="                    { token('!='); }

 /* Double-logical-character token */
"&&"                    { token('&&'); }
"||"                    { token('||'); }

 /* keyword */
"boolean"       { token(BOOLEAN); }
"begin"         { token(BEGIN); }
"break"         { token(BREAK); }
"char"          { token(CHAR); }
"case"          { token(CASE); }
"class"         { token(CLASS); }
"continue"      { token(CONTINUE); }
"def"           { token(DEF); }
"do"            { token(DO); }
"else"          { token(ELSE); }
"end"           { token(END); }
"exit"          { token(EXIT); }
"false"         { token(FALSE); }
"float"         { token(FLOAT); }
"for"           { token(FOR); }
"if"            { token(IF); }
"int"           { token(INT); }
"null"          { token(NULL); }
"object"        { token(OBJECT); }
"print"         { token(PRINT); }
"println"       { token(PRINTLN); }
"repeat"        { token(REPEAT); }
"return"        { token(RETURN); }
"string"        { token(STRING); }
"to"            { token(TO); }
"true"          { token(TRUE); }
"type"          { token(TYPE); }
"val"           { token(VAL); }
"var"           { token(VAR); }
"while"         { token(WHILE); }

{integer}	{
			tokenInteger(integer, atoi(yytext));
		}

{identifiers}	{
			tokenString(id, yytext);
			table -> insert(yytext);
		}

{real}		{
			tokenString(real, yytext);
		}

{string}	{
			char s[MAX_LENGTH] = {0};
			int idx = 0;
			for (int i = 1; i < yyleng - 1; ++i)
			{
				if (yytext[i] == '"')
					++i;
				s[idx++] = yytext[i];
			}
			tokenString(string, s);
		}

{singleComment}	{
			LIST;
		}

{startComment}	{
			LIST;
			BEGIN COMMENT;
		}

<COMMENT>[^\n]	{
			LIST;
		}

<COMMENT>\n	{	
			LIST;
			printf("%d: %s", lineNo, buffer);
			lineNo++;
			buffer[0] = '\0';
		}

<COMMENT>{endComment}	{
				LIST;
				BEGIN INITIAL;
			}

\n		{
			LIST;
			printf("%d: %s", lineNo, buffer);
			lineNo++;
			buffer[0] = '\0';
		}

[ \t]*		{
			LIST;
		}

.		{
			LIST;
			printf("%d: %s\n", lineNo, buffer);
			printf("Unknown character: '%s'\n", yytext);
			exit(-1);
		}

%%

symbolTable::symbolTable()
{
	index = 0;
}

int symbolTable::lookup(string s)
{
	if (tableMap.find(s) != tableMap.end())
		return tableMap[s];
	else
		return -1;
}

int symbolTable::insert(string s)
{
	if (tableMap.find(s) != tableMap.end())
		return -1;
	else
	{
		symbols.push_back(s);
		tableMap[s] = index;
		return index++;
	}

}

void create()
{
	table = new symbolTable();
}

int symbolTable::dump()
{
	for (int i = 0; i < index; ++i)
	{
		printf("%s\n", symbols[i].c_str());
	}
	return index;
}

int main()
{
	create();
	yylex();
	printf("\n%s\n", "Symbol Table:");
	table -> dump();
}
