#include<bits/stdc++.h>
#include<unistd.h>
#define m map<char,set<string> > 
using namespace std;

m input_grammar;
m store_first;
m store_follow;
set<char> non_terminals;
set<char>grammar_symbols;

struct state
{
	int number;
	m items;
	map<char,state > transition;
};

vector<m >visited;
vector<int>state_number;
vector<state>states;
map<pair<int,char>,string>action_table;
map<pair<int,char>,int>goto_table;

void take_input()
{
	string s;
	cout<<"Enter the Grammar. Enter -1 to stop\n";
	while(true)
	{
       cin>>s;
       if(s=="-1") break;
       non_terminals.insert(s[0]);
       input_grammar[s[0]].insert(s.substr(3));
       grammar_symbols.insert(s[0]);
	}

	for(m::iterator it=input_grammar.begin();it!=input_grammar.end();it++)
	{
		for(set<string>::iterator itt=(it->second).begin();itt!=(it->second).end();itt++)
		{
			int i=0;
			while(i<(*itt).length())
			{
				if((*itt)[i]!='.' && non_terminals.find((*itt)[i])==non_terminals.end())
					grammar_symbols.insert((*itt)[i]);				
				++i;
			}
		}
	}
	grammar_symbols.insert('$');
}

state generate_closure(state st1)
{
	state st=st1;
	while(1)
	{	
		int cnt=(st.items).size();	
		m::iterator it=(st.items).begin();
		while(it!=(st.items).end())
		{
		  for(set<string>::iterator itt=(it->second).begin();itt!=(it->second).end();itt++)
	      {
	      	string str=*itt; 
	      	int pos=0;
	      	while(pos<str.length()) 
	      	{
	      		if(str[pos]=='.') break;
	      		++pos;
	      	}
	      	if(pos==str.length()-1) continue;
	      	else 
	      	{
	           char x=str[pos+1]; 
	           if(non_terminals.find(x)==non_terminals.end()) continue; 
	           for(set<string>::iterator ip=input_grammar[x].begin();ip!=input_grammar[x].end();ip++) 
	           {
	           	 string s=""; s+="."; s+=(*ip);
	           	 (st.items[x]).insert(s); 
	           }	   	
	       	}       	
	      }
	      ++it;    
		}
		if(cnt==(st.items).size()) break;		
	}

	return st; 
}

void generate_LR0_Automaton(char start)
{
	int p=0;
	state st;
	string s=""; s+="."; s+=start;
	st.number=p; ++p;
	st.items['A'].insert(s);
	state st1=generate_closure(st);//Generating the start state 
	queue<state>q;
	q.push(st1);//Pushed in the starting state
	visited.push_back(st1.items);
	state_number.push_back(st1.number);

	while(!q.empty())
	{
		st=q.front(); q.pop();
		//Check for all the Grammar Symbols
		for(set<char>::iterator it=grammar_symbols.begin();it!=grammar_symbols.end();it++)
		{
			state tmp;
			tmp.number=p;  
			for(m::iterator ip=(st.items).begin();ip!=(st.items).end();ip++)
        	{
        		for(set<string>:: iterator itt=(ip->second).begin();itt!=(ip->second).end();itt++)
        		{	
	        		int x=(*itt).find('.');
	        		if(x==(*itt).length()-1) continue;
	        		if((*itt)[x+1]!=*it) continue;

	        		string temp=(*itt).substr(0,x);
	        		temp+=(*it); temp+=".";
	        		if(x+1<(*itt).length()-1) temp+=(*itt).substr(x+2);
	        		
	        		tmp.items[ip->first].insert(temp);	        		
	        	}	
        	}
        	if((tmp.items).size()==0) continue;//No kernel items  	
  			state tmp1=generate_closure(tmp);
  			int i;
  			for(i=0;i<visited.size();i++)
  			{
  				if(visited[i]==(tmp1.items))
	  			{
	  				tmp1.number=state_number[i];
	  				break; 
	  			}	  			
  			} 
  			if(i==visited.size())
  			{
  				q.push(tmp1); ++p;	
	  			visited.push_back(tmp1.items);
	  			state_number.push_back(tmp1.number);
  			} 			
  			st.transition[*it]=tmp1; 
		}
		states.push_back(st);		
	}
}

void print_automaton()
{
	cout<<"\n\nThe LR0 Automaton is: \n";
    for(int i=0;i<states.size();i++)
    {
      state st=states[i]; 
      cout<<"Printing the closure of State "<<st.number<<endl;
      for(m::iterator it=(st.items).begin();it!=(st.items).end();it++)
      {
      	for(set<string>::iterator itt=(it->second).begin();itt!=(it->second).end();itt++) 
	    	cout<<it->first<<"->"<<*itt<<endl; 
	  }
	  if((st.transition).size()==0) 
	  {
	  	cout<<"No transitions\n\n"; continue;
	  }
	  cout<<"Printing the transitions of State "<<st.number<<endl;
	  for(map<char,state>::iterator it=(st.transition).begin();it!=(st.transition).end();it++) cout<<it->first<<" "<<(it->second).number<<endl;
	  
	  cout<<endl<<endl;
	}
	cout<<"--------------------------------------------------------\n\n";
}

void construct_table(char start)
{  
	string accept="rA->";
	accept+=start; 
	for(int i=0;i<states.size();i++)
	{
		state st=states[i];
		//Filling the ACTION table
	    for(m::iterator it=(st.items).begin();it!=(st.items).end();it++)
	    {
	    	for(set<string>::iterator ip=(it->second).begin();ip!=(it->second).end();ip++)
	    	{
	    		int x=(*ip).find('.');
	    		if(x<(*ip).length()-1) 
	    		{
	    			char a=(*ip)[x+1];
	    			if(non_terminals.find(a)!=non_terminals.end()) continue;
	    			if((st.transition).find(a)!=(st.transition).end()) 
	    			{
	    				string s="s";
	    				s+=to_string((st.transition[a]).number);
	    				action_table[make_pair(st.number,a)]=s;
	    			}
	    		}
	    		else
	    		{
	    			for(set<string>::iterator itt=store_follow[it->first].begin();itt!=store_follow[it->first].end();itt++)
	    			{
	    				string str=*itt;
	    				string s="r"; s+=it->first;
	    				s+="->"; s+=(*ip).substr(0,x);
	    				if(s==accept) action_table[make_pair(st.number,str[0])]="acc";
	    				else action_table[make_pair(st.number,str[0])]=s; 
	    			}	
	    		}
	    	}	    	
	    }
	    //Filling the GOTO table
	    for(set<char>::iterator it=non_terminals.begin();it!=non_terminals.end();it++)
	    {
	    	if((st.transition).find(*it)!=(st.transition).end()) 
	    		goto_table[make_pair(st.number,*it)]=(st.transition[*it]).number;
	    }
	}
}

void compute_first(char symbol)
{
  m::iterator it=input_grammar.find(symbol);
  for(set<string>::iterator itt=(it->second).begin();itt!=(it->second).end();itt++)
  {
  	string str=*itt;
  	int i=0;
  	while(i<str.length())
  	{
  		char c=str[i];
  		string d=""; d+=c;
  		int flag=0;
       	if(input_grammar.find(c)==input_grammar.end())//This symbol of the production is a terminal
       	{
         	store_first[symbol].insert(d);
       		break;
       	}
       	else //The case of a non-terminal
       	{
          if(c!=symbol)
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
          else ++i;          
       	}
  	}
    if(i==str.length()) store_first[symbol].insert("e");
   }
}

void compute_follow(char symbol,string stck)
{
   for(m::iterator it=input_grammar.begin();it!=input_grammar.end();it++)
   {
    for(set<string>::iterator itt=(it->second).begin();itt!=(it->second).end();itt++)
    {
      string str=*itt;//Take up each Production
      int i;
      for(i=0;i<str.length();i++)
      {
        if(str[i]==symbol)
        {
          bool flag=false;
          string y=""; char x;
          if(i<str.length()-1) 
          {
            x=str[i+1];
            y+=x;
          }
          if(i<str.length()-1 && non_terminals.find(str[i+1])==non_terminals.end())
            store_follow[symbol].insert(y);
            
          else if(i<str.length()-1 && non_terminals.find(str[i+1])!=non_terminals.end())
          { 
            for(set<string>::iterator ip=store_first[x].begin();ip!=store_first[x].end();ip++)
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

void compute_first_and_follow(char start)
{
	string s=""; s+=start;
	input_grammar['A'].insert(s);

	for(m::iterator it=input_grammar.begin();it!=input_grammar.end();it++)
      compute_first(it->first);
  	

    store_follow['A'].insert("$");
    for(m::iterator it=input_grammar.begin();it!=input_grammar.end();it++)
      compute_follow(it->first,"");
}

void print_table()
{
	cout<<"\nAction Table\n";
	for(map<pair<int,char>,string>::iterator it=action_table.begin();it!=action_table.end();it++)
		cout<<"( "<<(it->first).first<<" , "<<(it->first).second<<" ) "<<it->second<<endl;
	
	cout<<"\nGoto Table\n";
    for(map<pair<int,char>,int>::iterator it=goto_table.begin();it!=goto_table.end();it++)
		cout<<"( "<<(it->first).first<<" , "<<(it->first).second<<" ) "<<it->second<<endl;
}

void parse(string input)
{
	stack<string>stck;
	stck.push("0");
	input+="$";
	int i=0;
	while(i<input.length())
	{
		string action=action_table[make_pair(atoi((stck.top()).c_str()),input[i])];
		if(action[0]=='s') 
		{
			string x=""; x+=input[i];
			stck.push(x);
			stck.push(action.substr(1));
			++i;
			cout<<"Shifting "<<input[i-1]<<" onto stack due to "<<action<<endl;
		}
		else if(action[0]=='r')
		{
			int x=action.find('>');
			string p=action.substr(x+1);
			x=p.length()*2;
			while(!stck.empty() && x>0) 
			{
				stck.pop(); x--;
			}
			p=""; p+=action[1]; //Head of production
			string top=stck.top();
			stck.push(p);
			stck.push(to_string(goto_table[make_pair(atoi((top).c_str()),action[1])]));
			cout<<"Reducing by "<<action.substr(1)<<endl;	
		}
		else
		{
			cout<<"String has been accepted\n"; ++i;
		}
	}
}

int main()
{
	printf("Input the Grammar as: head->production\nDo not provide multiple productions in 1 line\n");
	take_input();
	char start;
	cout<<"Enter the start symbol\n";
	cin>>start;
	generate_LR0_Automaton(start);
	print_automaton();

    compute_first_and_follow(start);	
    construct_table(start);  
    print_table();
    string input;
    cout<<"Enter input to parse\n";
    cin>>input;
    parse(input);
	return 0;
}