 /*Code to print the Symbol table while reading from a file. All entries in Symbol table should be consisting of word,freq and line numbers(Unique) */
%{
	#include<bits/stdc++.h>
	using namespace std;
	map<string,pair<int,set<int> > >mm;//Will store the symbol table
    int cnt=1; //To count line numbers
    void insert_word(char* input);
%}

alpha [a-z|A-Z]
digit [0-9]

%%
{alpha}+"\'"?{alpha}*  insert_word(yytext);
{digit}+  insert_word(yytext);
\n  ++cnt;
. ;
%%

void insert_word(char* input)
{
   string s(input);	
   mm[s].first++;
   if((mm[s].second).find(cnt)==(mm[s].second).end()) (mm[s].second).insert(cnt);
}

int main()
{
	yyin=fopen("Readthis.txt","r");
	yylex();
	printf("The symbol table is as follows: \n");
	printf("Symbol                    Frequency     LineNumbers\n");
    for(map<string,pair<int,set<int> > >::iterator it=mm.begin();it!=mm.end();it++)
    {
    	cout<<it->first;
    	for(int i=0;i<(30-(it->first).length());i++) cout<<" ";
    	cout<<(it->second).first<<"              ";
    	for(set<int>::iterator itt=((it->second).second).begin();itt!=((it->second).second).end();itt++) cout<<*itt<<",";
        cout<<endl;		
    }
	return 0;
}