#include<bits/stdc++.h>
#define mm map<string,set<string> >
using namespace std;

int main()
{
	mm m;
	//Entering the Expression Grammar
	string word="";
	m["AB"].insert("S");
	m["BC"].insert("S");
	m["BA"].insert("A");
	m["a"].insert("A");
	m["CC"].insert("B");
	m["b"].insert("B");
	m["AB"].insert("C");
	m["a"].insert("C");
	cout<<"Enter the input String "<<endl;
	cin>>word;
	string arr[word.length()][word.length()];
	int n=word.length();
	for(int i=0;i<n;i++)
	{
		for(int j=0;j<n;j++) arr[i][j]="";
	}
	//Base Case	
	for(int i=0;i<n;i++)
	{
	  string s="";
	  s+=word[i];
	  for(set<string>::iterator it=m[s].begin();it!=m[s].end();it++) arr[n-1][i]+=*it;
	}
	
	for(int i=n-2;i>=0;i--)
    {
      for(int j=0;j<=i;j++)
	  {
	  	int x1=i+1,x2=n-1,y1=j,y2=j+(x2-i);
	  	set<string>present;
	  	while(x1<n && x2>i && y2>j)
	  	{
	  		for(int p=0;p<arr[x1][y1].length();p++)
	  		{
	  			for(int q=0;q<arr[x2][y2].length();q++)
	  			{
	  				string k="";
	  				k+=arr[x1][y1][p];
					k+=arr[x2][y2][q];
	  				for(set<string>::iterator it=m[k].begin();it!=m[k].end();it++)	
	  			    {
	  			    	if(present.find(*it)==present.end())
	  			    	{
	  			    		present.insert(*it);
	  			    		arr[i][j]+=*it;
	  			    	}
	  			    }
	  			}
	  		}
	  		x1++; x2--; y2--;
	  	}	  	
	  }	
    }
    int x;
	for(x=0;x<arr[0][0].length();x++)
	{
	  	if(arr[0][0][x]=='S') break;
	}
	if(x==arr[0][0].length()) cout<<word<<" is not present in the Grammar"<<endl;
	else cout<<word<<" is present in the Grammar"<<endl;
	return 0;	
}
