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
map1 store_first;
map1 store_follow;
set<char>non_terminals;
map<pair<string,string>,string>table;//To store the Predictive Parsing table
string input;

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


void compute_first(string symbol)
{
  map1::iterator it=left_recursion_rem.find(symbol);
  for(set<string>::iterator itt=(it->second).begin();itt!=(it->second).end();itt++)
  {
  	string str=*itt;
  	int i=0;
  	while(i<str.length())
  	{
  		string c="";
  		c+=str[i];
  		int flag=0;
       if(left_recursion_rem.find(c)==left_recursion_rem.end())//This symbol of the production is a terminal
       {
         	store_first[symbol].insert(c);
       		break;
       	}
       	else //The case of a non-terminal
       	{
          compute_first(c);
          for(set<string>::iterator ip=store_first[c].begin();ip!=store_first[c].end();ip++)
        	{
         		if(*ip=="e") flag=1;
         		if(*ip!="e" && store_first[symbol].find(*ip)==store_first[symbol].end()) store_first[symbol].insert(*ip);
         	}
          	if(flag) ++i;
           	else break;
       	}
  	}
    if(i==str.length()) store_first[symbol].insert("e");
   }
}

void compute_follow(string symbol,string stck)
{
   for(map1::iterator it=left_recursion_rem.begin();it!=left_recursion_rem.end();it++)
   {
    for(set<string>::iterator itt=(it->second).begin();itt!=(it->second).end();itt++)
    {
      string str=*itt;//Take up each Production
      int i;
      for(i=0;i<str.length();i++)
      {
        if(str[i]==symbol[0])
        {
          bool flag=false;
          string y="";
          if(i<str.length()-1) 
          {
            char x=str[i+1];
            y+=x;
          }
          if(i<str.length()-1 && non_terminals.find(str[i+1])==non_terminals.end())
            store_follow[symbol].insert(y);
            
          else if(i<str.length()-1 && non_terminals.find(str[i+1])!=non_terminals.end())
          { 
            for(set<string>::iterator ip=store_first[y].begin();ip!=store_first[y].end();ip++)
             {
              if(*ip!="e")  store_follow[symbol].insert(*ip);
              else flag=true;
             } 
          }
          if(i==str.length()-1 || flag)
          {
            if(it->first!=symbol && stck.find(it->first)==std::string::npos)
            {
              compute_follow(it->first,stck+symbol);
              for(set<string>::iterator ip=store_follow[it->first].begin();ip!=store_follow[it->first].end();ip++)
                 store_follow[symbol].insert(*ip);
            }             
          }
        }
      }
    }
   }
}

void constructTable()
{
  for(map1::iterator it=left_recursion_rem.begin();it!=left_recursion_rem.end();it++)
  {
    for(set<string>::iterator itt=(it->second).begin();itt!=(it->second).end();itt++)
    {
      //Doing for each production
      bool flag=true;
      char x=(*itt)[0];
      string k=""; k+=x;
      if(non_terminals.find(x)!=non_terminals.end())
      {
        for(set<string>::iterator ip=store_first[k].begin();ip!=store_first[k].end();ip++)
       {
          if(*ip!="e")
          {
            pair<string,string> p=make_pair(it->first,*ip);
            table[p]=*itt;
          }
          else flag=false;
        }
      }
      else 
      {
        if(*itt!="e") table[make_pair(it->first,k)]=*itt;
        else flag=false; 
      } 

      if(!flag)
      {
        for(set<string>::iterator ip=store_follow[it->first].begin();ip!=store_follow[it->first].end();ip++)
        {
          pair<string,string> p=make_pair(it->first,*ip);
          table[p]=*itt;
        }
      }            
    }  
  }    
}

void printTable()
{
  cout<<"The Predictive Parsing Table for the given Grammar is:\n ";
  for(map<pair<string,string>,string>::iterator it=table.begin();it!=table.end();it++)
    cout<<(it->first).first<<" , "<<(it->first).second<<" : "<<(it->first).first<<"->"<<it->second<<endl;
}

void top_down_parse(string start)
{
  stack<char>st;
  st.push('$');
  st.push(start[0]);
  int i=0;
  input+="$";
  while(i<input.length())
  {
    if(st.top()==input[i])
    {
      ++i;
      cout<<st.top()<<" has been matched\n";
      st.pop();
    }
    else if(non_terminals.find(st.top())!=non_terminals.end())
    {
      char x=st.top();
      string y=""; y+=x;
      string z=""; z+=input[i];
      st.pop();
      string prod=table[make_pair(y,z)];
      if(prod!="e") 
      {
          for(int j=prod.length()-1;j>=0;j--) st.push(prod[j]);
      }
      cout<<y<<"-> "<<prod<<endl;  
    }
    else
    {
      cout<<"Error has ocurred\n";
      st.pop();
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
    string start;
    cout<<"Enter the start symbol\n";
    cin>>start;
    
    for(map1::iterator it=left_recursion_rem.begin();it!=left_recursion_rem.end();it++)
      compute_first(it->first);
    
    cout<<"The first of the non-terminals are:\n";
    for(map1::iterator it=store_first.begin();it!=store_first.end();it++)
    {
    	cout<<"first( "<<it->first<<" )=  ";
    	for(set<string>::iterator ip=(it->second).begin();ip!=(it->second).end();ip++) cout<<*ip<<" ";
      cout<<" \n";		
    }

    store_follow[start].insert("$");
    for(map1::iterator it=left_recursion_rem.begin();it!=left_recursion_rem.end();it++)
      compute_follow(it->first,"");
       
    cout<<"The follow of the non-terminals are:\n";
    for(map1::iterator it=store_follow.begin();it!=store_follow.end();it++)
    {
      cout<<"follow( "<<it->first<<" )=  ";
      for(set<string>::iterator ip=(it->second).begin();ip!=(it->second).end();ip++) cout<<*ip<<" ";
      cout<<" \n";    
    }

    constructTable();
    printTable();
    cout<<"Enter an input string\n";
    cin>>input;

    top_down_parse(start);
	return 0;
}
                        