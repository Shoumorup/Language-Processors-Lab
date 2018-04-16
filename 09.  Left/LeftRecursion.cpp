//Will eliminate immediate left recursion from the Grammar and then left factor it
#include<bits/stdc++.h>
#define map1 map<string,set<string> >
#define itr1 map<string,set<string> >::iterator 
#define itr2 set<string>::iterator 
#define loop1(m1,it) for((it)=(m1).begin();(it)!=(m1).end();(it)++)
#define loop2(s1,it) for((it)=(s1).begin();(it)!=(s1).end();(it)++)
using namespace std;

map1 alpha;//Structure to store the "alpha's" of the Grammar corresponding to each Variable
map1 Beta;//Structure to store the "Beta's" of the Grammar corresponding to each Variable
map1 left_recursion_rem; //Structure to store removed left recursion
map1 left_factored;
set<char>non_terminals;

typedef
struct node
{
  bool isword;
  char data;
  map<char,node*> ptr;
}*Tptr;

char findrandom()
{
  srand(time(NULL));
  int r;
  while(1)
  {
    r=rand()%26+65;
    if(non_terminals.find((char)r)==non_terminals.end()) break;
  }
  non_terminals.insert((char)r);
  return (char)r;
}

void eliminate_immediate_left_recursion()
{
 	for(map1::iterator it=Beta.begin();it!=Beta.end();it++)
  	{
    	string p="";
    	for(set<string>::iterator itt=(it->second).begin();itt!=(it->second).end();itt++) 
    	{
        	string str=*itt;
        	if(alpha.find(it->first)==alpha.end())
        	{
            	left_recursion_rem[it->first].insert(str);
            	continue;
        	}
        	char x=findrandom();
        	non_terminals.insert(x);
        	p+=x;
       		str+=p;
        	left_recursion_rem[it->first].insert(str);        
    	}     
  	}

    for(map1::iterator it=alpha.begin();it!=alpha.end();it++)
  	{
      string p="";
    	for(set<string>::iterator itt=(it->second).begin();itt!=(it->second).end();itt++) 
    	{
    	  string str=*itt; 	
        set<string>::iterator ip=left_recursion_rem[it->first].begin();
        int l=(*ip).length();
        char x=(*ip)[l-1];
        str+=x;
        p+=x;
        left_recursion_rem[p].insert(str);          
    	}
    	left_recursion_rem[p].insert("e");//For NULL Production      
  	}

  	for(map1::iterator it=left_recursion_rem.begin();it!=left_recursion_rem.end();it++)
  	{
   	 cout<<it->first<<"-> ";
   	 for(set<string>::iterator itt=(it->second).begin();itt!=(it->second).end();itt++) 
   	 {
      	set<string>::iterator ip=itt; ip++;
     	  if(ip!=(it->second).end())  cout<<*itt<<" | ";
      	else cout<<*itt<<endl;
     }      
  	}
}


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

void assign_prefix(Tptr& T,string head,string prefix_seen)
{
  // cout<<prefix_seen<<endl; sleep(1);
  prefix_seen+=T->data;
  if(T->ptr.size()==0 && T->isword==true)
  {
    left_factored[head].insert(prefix_seen);
    return;
  }

  if(T->ptr.size()>1 || T->isword==true)
  {
    char x=findrandom();
    string sp=prefix_seen;
    sp+=x;
    left_factored[head].insert(sp);
    string z=""; z+=x;
    if(T->isword) left_factored[z].insert("e");
    map<char,node*>::iterator it=(T->ptr).begin();
    while(it!=(T->ptr).end())
    {
      assign_prefix(it->second,z,""); ++it;
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
  loop1(left_recursion_rem,it)
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

void print_left_factor()
{
  itr1 it;
  loop1(left_factored,it)
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
}


int main()
{
    string s;
    printf("Input the Grammar as: head->production\nDo not provide multiple productions in 1 line\n");
    cout<<"Enter the Grammar. Enter -1 to stop"<<endl;
    while(1)
    {
    	cin>>s;
    	if(s=="-1") break;
    	string ch=""; ch+=s[0];
      non_terminals.insert(s[0]);
    	if(s[0]==s[3]) alpha[ch].insert(s.substr(4)); //Immediate Left Recursive Production    		
    	else Beta[ch].insert(s.substr(3));
    }
    
    cout<<"\nThe left recursion eliminated grammar is:\n";
    eliminate_immediate_left_recursion(); 
    cout<<"\nThe left factored grammar is:\n";
    left_factor(); 
    print_left_factor();
    return 0;
}
                        