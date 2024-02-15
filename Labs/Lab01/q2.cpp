#include<bits/stdc++.h>
#include<iostream>

using namespace std;

vector<int> final_states;
vector<pair<int,int> > adjList[100];

bool dfs(string input,int ind,int src){
	int n = input.size();
	if(ind == n){
		for(int f : final_states){
			if(src == f) return true;
		}
		return false;
	}

	int symbol = input[ind] - '0';
	for(auto p : adjList[src]){
		int ele = p.first;
		if(ele != symbol) continue;
		int nextState = p.second;
		if(dfs(input,ind+1,nextState)) return true;
	}

	return false;
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
		string temp;
		getline(cin,temp);

        int a=0, z=0;
        int num = temp[0] - '0';
        if(num >= 0 && num <= 9){
            z++;
            while(z<temp.length() && (temp[z] - '0' >= 0) && (temp[z] - '0' <= 9)){
                num = num*10 + (temp[z] - '0');
                z++;
            }
            z--;
            a = num;
        }
        int indVal = z;

		for(int i=indVal+1;i<temp.length();i++){
			if(temp[i] == '{'){
				int ind = 0;
				// 0 symbol
				for(int j=i+1;j<temp.length();j++){
					if(temp[j] == '}'){
						ind = j+1;
						break;
					}
					
					int num = temp[j] - '0';
					if(num >= 0 && num <= 9){
                        j++;
                        while(j<temp.length() && (temp[j] - '0' >= 0) && (temp[j] - '0' <= 9)){
                            num = num*10 + (temp[j] - '0');
                            j++;
                        }
                        j--;
						adjList[a].push_back(make_pair(0,num));
					}
				}
	
				// 1 symbol
				for(int k=ind;k<temp.length();k++){
					if(temp[k] == '{'){
						for(int y=k+1;y<temp.length();y++){
							if(temp[y] == '}'){	
								i = temp.length();
								break;
							}

                            int num = temp[y] - '0';
                            if(num >= 0 && num <= 9){
                                y++;
                                while(y<temp.length() && (temp[y] - '0' >= 0) && (temp[y] - '0' <= 9)){
                                    num = num*10 + (temp[y] - '0');
                                    y++;
                                }
                                y--;
                                adjList[a].push_back(make_pair(1,num));
                            }
						}
						break;
					}
				}
				
			}
		}
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
