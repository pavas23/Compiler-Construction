#include<bits/stdc++.h>

using namespace std;

vector<int> final_states;
vector<pair<int,int>> adjList[100];

bool dfs(string input,int ind,int src){
	int n = input.size();
	if(ind == n){
		for(int f : final_states){
			if(src == f) return true;
		}
		return false;
	}

	int symbol = input[ind] - '0';
	int nextState = adjList[src][0].second;
	return dfs(input,ind+1,nextState);
}

int main(){
	int n;
	cin>>n;
	
	string empty;
	getline(cin,empty);
	string line;
	getline(cin,line);
	
	for(int i=0;i<line.length();i++){
        int num = line[i] - '0';
        if(num >= 0 && num <= 9){
            i++;
            while(i<line.length() && (line[i] - '0' >= 0) && (line[i] - '0' <= 9)){
                num = num*10 + (line[i] - '0');
                i++;
            }
            i--;
            final_states.push_back(num);
        }
	}

	for(int i=0;i<n;i++){
		int a,b,c;
		cin>>a>>b>>c;

		adjList[a].push_back({0,b});
		adjList[a].push_back({1,c});
	}

	string input;
	cin>>input;
	
	if(dfs(input,0,0)){
		cout<<"Accepted"<<endl;
	}else{
		cout<<"Not Accepted"<<endl;
	}

	return 0;
}
