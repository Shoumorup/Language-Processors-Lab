//Will left factor the input grammar assuming no left recursion
#include<bits/stdc++.h>
#include<unistd.h>
#define map1 map<char,set<string> >
#define itr1 map<char,set<string> >::iterator 
#define itr2 set<string>::iterator 
#define loop1(m1,it) for((it)=(m1).begin();(it)!=(m1).end();(it)++)
#define loop2(s1,it) for((it)=(s1).begin();(it)!=(s1).end();(it)++)
using namespace std;

map1 input_grammar,final_grammar;
set<char>non_terminals;

char findnon_terminal()
{
	srand(time(NULL)); 
	int r;
	while(1)
	{
		r=rand()%26+65;
		if(non_terminals.find((char)r)==non_terminals.end()) break;
	}
	non_terminals.insert((char)r);
	return ((char)r);
}
typedef
struct node
{
	bool isword;
	char data;
	map<char,node*> ptr;
}*Tptr;

Tptr construct_trie(Tptr& T,string str,int i,int len)
{
	if(i==len)
	{
		T->isword=true;
		return T;
	}
	if((T->ptr).find(str[i])==(T->ptr).end())
	{
		(T->ptr)[str[i]]=new node();
		(T->ptr)[str[i]]->data=str[i];
		(T->ptr)[str[i]]->isword=false;
	}
	T->ptr[str[i]]=construct_trie(T->ptr[str[i]],str,i+1,len);
	return T;
}

void assign_prefix(Tptr& T,char head,string prefix_seen)
{
	prefix_seen+=T->data;
	if(T->ptr.size()==0 && T->isword==true)
	{
		final_grammar[head].insert(prefix_seen);
		return;
	}

	if(T->ptr.size()>1 || T->isword==true)
	{
		char x=findnon_terminal();
		string sp=prefix_seen;
		sp+=x;
		final_grammar[head].insert(sp);
		if(T->isword) final_grammar[x].insert("e");
		map<char,node*>::iterator it=(T->ptr).begin();
		while(it!=(T->ptr).end())
		{
			assign_prefix(it->second,x,""); ++it;
		}		
	}
    else
    {
    	map<char,node*>::iterator it=(T->ptr).begin();
    	assign_prefix(it->second,head,prefix_seen);
    }
}

void left_factor()
{
	itr1 it;
	loop1(input_grammar,it)
	{
		Tptr T=new node();
		T->data='\0';
		T->isword=false;
		itr2 itt;
		loop2(it->second,itt) T=construct_trie(T,*itt,0,(*itt).length());	
		for(map<char,node*>::iterator ip=(T->ptr).begin();ip!=(T->ptr).end();ip++)
			assign_prefix(ip->second,it->first,""); 
	}
}

int main()
{
	printf("Input the Grammar as: head->production\nDo not provide multiple productions in 1 line\n");
	cout<<"Enter the productions"<<endl;
	string s;
	while(1)
	{
     	cin>>s;
     	if(s=="-1") break;
     	non_terminals.insert(s[0]);
  		input_grammar[s[0]].insert(s.substr(3));  		
	}
	left_factor();
	itr1 it;
	cout<<"The left factored grammar is: \n";
	loop1(final_grammar,it)
	{
	  itr2 itt;
	  cout<<it->first<<"->";
      loop2(it->second,itt) 
      { 
      	itr2 ip=itt; ip++;
      	if(ip!=(it->second).end()) cout<<*itt<<"|";
      	else cout<<*itt<<endl;
	  }
	}
	return 0;
}