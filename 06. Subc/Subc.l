%{
	#include<bits/stdc++.h>
  #include<fstream>
	using namespace std;
	set<string>key; //Will store all the keywords
  void extract_words(char* input);
  void extract_operator(char* yytext);
  void extract_num(char* input);
%}

alpha [a-z|A-Z]
digit [0-9]

%%
{alpha}+"\'"?{alpha}*  extract_words(yytext);
{digit}+  extract_num(yytext);
[+|\-|*|/|=|<|>|(|)|\^|\!|\~] extract_operator(yytext);
. ; 
%%

void extract_words(char* input)
{
   string s(input);
   if(key.find(s)!=key.end()) cout<<s<<" is written as :"<<s<<endl;
   else cout<<s<<" is written as : id"<<endl;
}

void extract_operator(char* yytext)
{
  cout<<yytext<<" is written as: "<<yytext<<endl;
}

void extract_num(char* input)
{
  cout<<yytext<<" is written as: num"<<endl;
}

int main()
{
  //Storing keywords in a map
  ifstream fin;
  fin.open("Keywords.txt");
  string s="";
  while(fin)
  {
     getline(fin,s);
     key.insert(s);
  }
	yyin=fopen("Sample.txt","r");
	yylex();	
	return 0;
}