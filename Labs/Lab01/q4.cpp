#include<iostream>
#include<bits/stdc++.h>

using namespace std;

set<int> final_states_nfa_epsilon; // NFA with epsilon moves
set<int> final_states; // NFA
vector<pair<int,int> > adjListNfaEpsilon[100]; // NFA with epsilon moves
set<pair<int,int> > adjList[100]; // NFA
map<vector<int>,vector<vector<int> > > dfa; // DFA
set<vector<int> > final_states_dfa; // DFA
set<int> epsilonClosure[100];

void find_final_states_for_nfa(int start){
    vector<int> common;
    vector<int> epsilon_start;
    vector<int> finalNFAE;

    // converting set to vector
    for(auto x: epsilonClosure[start]){
        epsilon_start.push_back(x);
    }
    for(auto x: final_states_nfa_epsilon){
        finalNFAE.push_back(x);
    }

    set_intersection(epsilon_start.begin(),epsilon_start.end(),finalNFAE.begin(),finalNFAE.end(),back_inserter(common));
    if(common.size() == 0){
        // intersection is empty
        final_states = final_states_nfa_epsilon;
    }else{
        final_states = final_states_nfa_epsilon;
        final_states.insert(start);
    }
}

void findEpsilonClosure(int src){
    epsilonClosure[src].insert(src);
    for(auto p : adjListNfaEpsilon[src]){
        if(p.first == 2){
            // epsilon transition
            epsilonClosure[src].insert(p.second);
            findEpsilonClosure(p.second);
            for(auto it=epsilonClosure[p.second].begin(); it != epsilonClosure[p.second].end(); it++){
                epsilonClosure[src].insert(*it);
            }
        }
    }
}

void convert_nfa_with_epsilon_to_nfa(int n,int start){
    // find epsilon closure for all states
    for(int i=0;i<n;i++){
        findEpsilonClosure(i);
    }
    
    // now find transitions
    for(int i=0;i<n;i++){
        for(int x : epsilonClosure[i]){
            for(auto j : adjListNfaEpsilon[x]){
                for(int y : epsilonClosure[j.second]){
                    if(j.first != 2) adjList[i].insert(make_pair(j.first,y));
                }
            }
        }
    }

    find_final_states_for_nfa(start);
}

// bfs over NFA 
void convert_nfa_to_dfa(int n){
    set<vector<int> > s;
    queue<vector<int> > q;
    q.push({0});

    while(!q.empty()){
        vector<int> state = q.front();
        q.pop();
        if(s.find(state) != s.end()){
            continue;
        }

        s.insert(state);
        set<int> zero, one;
        // iterate over each substate of this current state
        for(auto st : state){
            for(auto it=adjList[st].begin(); it != adjList[st].end(); it++){
                if((*it).first == 0) zero.insert((*it).second);
                else one.insert((*it).second);
            }
        }

        vector<int> zeros,ones;
        for(auto it=zero.begin(); it != zero.end(); it++){
            zeros.push_back(*it);
        }
        for(auto it=one.begin(); it != one.end(); it++){
            ones.push_back(*it);
        }

        vector<vector<int> > temp;
        temp.push_back(zeros);
        temp.push_back(ones);
        dfa[state] = temp;

        q.push(ones);  
        q.push(zeros);
    }
}

bool check(vector<int> vec){
    for(auto ele : vec){
        if(final_states.find(ele) != final_states.end()) return true;
    }
    return false;
}

void find_final_states_for_dfa(){
    for(auto it=dfa.begin(); it != dfa.end(); it++){
        if(check(it->first)){
            final_states_dfa.insert(it->first);
        }
        for(auto vec : it->second){
            if(check(vec)){
                final_states_dfa.insert(vec);
            }
        }
    }
}

int main(void){
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
            final_states_nfa_epsilon.insert(num);
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
						adjListNfaEpsilon[a].push_back(make_pair(0,num));
					}
				}
	
				// 1 symbol
				for(int k=ind;k<temp.length();k++){
					if(temp[k] == '{'){
						for(int y=k+1;y<temp.length();y++){
							if(temp[y] == '}'){	
								ind = y+1;
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
                                adjListNfaEpsilon[a].push_back(make_pair(1,num));
                            }
						}
						break;
					}
				}

                // e (epsilon) symbol -> 2
				for(int z=ind;z<temp.length();z++){
					if(temp[z] == '{'){
						for(int q=z+1;q<temp.length();q++){
							if(temp[q] == '}'){	
								ind = q+1;
                                i = temp.length();
								break;
							}

                            int num = temp[q] - '0';
                            if(num >= 0 && num <= 9){
                                q++;
                                while(q<temp.length() && (temp[q] - '0' >= 0) && (temp[q] - '0' <= 9)){
                                    num = num*10 + (temp[q] - '0');
                                    q++;
                                }
                                q--;
                                adjListNfaEpsilon[a].push_back(make_pair(2,num));
                            }
						}
						break;
					}
				}
			}
		}
	}

    convert_nfa_with_epsilon_to_nfa(n,0);
    convert_nfa_to_dfa(n);
    find_final_states_for_dfa();

    // print DFA
    cout<<endl;
    for(auto it=dfa.begin(); it != dfa.end(); it++){
        vector<int> state = it->first;
        vector<vector<int>> transitions = it->second;

        cout<<"[";
        for(int i=0;i<state.size()-1;i++){
            cout<<state[i]<<", ";
        }
        if(state.size()-1 >= 0) cout<<state[state.size()-1]<<"]"<<" ";
        cout<<"\t";

        for(int num=0;num<transitions.size();num++){
            cout<<"[";
            for(int i=0;i<transitions[num].size()-1;i++){
                cout<<transitions[num][i]<<", ";
            }
            if(transitions[num].size()-1 >= 0) cout<<transitions[num][transitions[num].size()-1]<<"]"<<" ";
            cout<<"\t";
        }

        cout<<endl;
    }

    // print final states of DFA
    for(auto it=final_states_dfa.begin(); it != final_states_dfa.end(); it++){
        vector<int> temp = *it;
        cout<<"[";
        for(int i=0;i<temp.size()-1;i++){
            cout<<temp[i]<<", ";
        }
        if(temp.size()-1 >= 0) cout<<temp[temp.size()-1]<<"]"<<" ";
    }
    cout<<endl;

    return 0;
}
