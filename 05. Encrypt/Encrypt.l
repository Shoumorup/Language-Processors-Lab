	/* Encrpyt words/numbers recognised using LEX */
%{
   #include<bits/stdc++.h>
   #include<fstream>
   using namespace std;
   ofstream fout;
   set<string>key; //Will store all the keywords
   void foundwords(char* input);
   void foundother(char* input);
   void foundnum(char* input);
%}

alpha [a-z|A-Z]
digit [0-9]

%%
{alpha}+ foundwords(yytext);
{digit}+ foundnum(yytext);
\n cout<<endl;
. foundother(yytext);
%%

void foundwords(char* input)
{
	string s(input);
    if(s.length()<=2) 
    {
       cout<<s<<" ";
       return;
    }
	if(key.find(s)!=key.end())//It is a special word, hence LEFT ROTATE
	{
		string str="";
		for(int i=2;i<s.length();i++)
		{
			str+=s[i];
		}
		str+=s[0];
		str+=s[1];
		reverse(str.begin(),str.end());
		cout<<str<<" ";
	}
	else //RIGHT ROTATE
	{
        string str="";
		str+=s[s.length()-2];
		str+=s[s.length()-1];
		for(int i=0;i<s.length()-2;i++)
		{
			str+=s[i];
		}
		reverse(str.begin(),str.end());
		cout<<str<<" ";
	}
}

void foundnum(char* input)
{
	string s(input);
	int len = s.length();
	int mid = len/2;
	string firstHalf = s.substr(0, mid);
	string secHalf = s.substr(mid, len);
	secHalf += firstHalf;
	cout<<secHalf<<" ";
}

void foundother(char* input)
{
	string s(input),str="";
	for(int i=0;i<s.length();)
	{
	   str+=s[i++];	
       while(i<s.length() && s[i]==' ') ++i;

	}
    cout<<str<<" ";
}

int main()
{
	//Storing keywords in a map
  	ifstream fin;
  	fin.open("Keywords.txt");
  	fout.open("Encrypted.txt");
  	string s="";
  	while(fin)
  	{
    	getline(fin,s);
     	key.insert(s);
  	}
  	fin.close();
  	yyin=fopen("Sample.txt","r");
	yylex();
    //fout.close();
    return 0;
}