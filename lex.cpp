#include<bits/stdc++.h>
#include<iostream>
#include<fstream>
using namespace std;

const int N = 1e5+5; // max number of states in automata

/* We are defining data structures for storing ,
 * NFA with epsilon transitions, NFA and DFA,
 * all these global data structures are being
 * cleared after scanning each regex.
 */

set<int> final_states_nfa_epsilon; // NFA with epsilon moves
set<int> final_states; // NFA
vector<pair<int,int> > adjListNfaEpsilon[N]; // NFA with epsilon moves
set<pair<int,int> > adjList[N]; // NFA
map<vector<int>,vector<vector<int> > > dfa; // DFA
set<vector<int> > final_states_dfa; // DFA
set<int> epsilonClosure[N]; // for storing epsilon closure of each state
vector<bool> epsilonVisited(N,false);
map<vector<int>,int> mapping; // maps vector state to int state
map<int,vector<int> > dfa_mapped; // final dfa
set<int> final_states_dfa_mapped; // final states for mapped dfa

class NFAE_entry{
    public:
    vector<vector<int>> v;
    NFAE_entry(){
        v.push_back({-1});
        v.push_back({-1});
        v.push_back({-1});
    }
};

void clear_all_global_data_structures(){
    // clearing all global values
    final_states_nfa_epsilon.clear();
    final_states.clear();
    dfa.clear();
    final_states_dfa.clear();
    mapping.clear();
    dfa_mapped.clear();
    final_states_dfa_mapped.clear();

    for(int i=0;i<N;i++){
        adjListNfaEpsilon[i].clear();
        adjList[i].clear();
        epsilonClosure[i].clear();
        epsilonVisited[i] = false;
    }
}

// function to find longest matching string with a given dfa
string max_len_lexeme(map<int,vector<int>> &dfa, string &str, int ind, set<int> &final_states){
    int currState = 1;
    int currChar = str[ind]-'a';
    string ans;
    int startInd = ind;

    while(ind < str.length()){   
        if(dfa.find(currState) == dfa.end()) return "";
        currState = dfa[currState][currChar];
        if(final_states.find(currState) != final_states.end()){
            ans = str.substr(startInd,ind-startInd+1);
        }
        ind++;
        currChar = str[ind]-'a';
    }
    return ans;
} 

// function to print original dfa without mapping
void print_dfa(){
    cout<<"\n";
    cout<<"DFA Transition Table"<<endl;
    for(auto it=dfa.begin(); it != dfa.end(); it++){
        vector<int> state = it->first;
        vector<vector<int>> transitions = it->second;

        cout<<"[";
        for(int i=0;i<state.size();i++){
            cout<<state[i]<<", ";
        }
        cout<<"]"<<"\t";

        for(int num=0;num<transitions.size();num++){
            cout<<"[";
            for(int i=0;i<transitions[num].size();i++){
                cout<<transitions[num][i]<<", ";
            }
            cout<<"]"<<"\t";
        }
        cout<<endl;
    }
}

// function to print final states of original dfa without mapping
void print_final_states_dfa(){
    cout<< final_states_dfa.size()<<"\n";
    cout<<"Final States of DFA"<<endl;
    for(auto it=final_states_dfa.begin(); it != final_states_dfa.end(); it++){
        vector<int> temp = *it;
        cout<<"[";
        for(int i=0;i<temp.size();i++){
            cout<<temp[i]<<", ";
        }
        cout<<"]"<<"\t";
    }
    cout<<endl;
}

void print_nfae(int n){
    cout<<endl<<"NFA with epsilon transition table"<<endl;
    for(int i=0;i<n;i++){
        cout<<i<<"\t";
        cout<<"{";
        for(auto p : adjListNfaEpsilon[i]){
            if(p.first == 0){
                cout<<p.second<<", ";
            }
        }
        cout<<"} {";
        for(auto p : adjListNfaEpsilon[i]){
            if(p.first == 1){
                cout<<p.second<<", ";
            }
        }
        cout<<"} {";
        for(auto p : adjListNfaEpsilon[i]){
            if(p.first == 2){
                cout<<p.second<<", ";
            }
        }
        cout<<"}"<<endl;
    }
}

void print_nfa(int n){
    cout<<endl<<"NFA transition table"<<endl;
    for(int i=0;i<n;i++){
        cout<<i<<"\t";
        cout<<"{";
        for(auto p : adjList[i]){
            if(p.first == 0){
                cout<<p.second<<", ";
            }
        }
        cout<<"} {";
        for(auto p : adjList[i]){
            if(p.first == 1){
                cout<<p.second<<", ";
            }
        }
        cout<<"}"<<endl;
    }
}

void print_final_states_nfa(){
    cout<<endl<<"Final states of NFA"<<endl;
    for(auto x : final_states){
        cout<<x<<" ";
    }
    cout<<endl;
}

void RE_to_NFAE(string RE,map<int,NFAE_entry> &table,int *cnt){
    stack<int> start_states;
    stack<int> final_states;
    stack<int> union1;

    int union2 = -1;
    stack<int> s;
    start_states.push(0);
    final_states.push(0);

    int i = 0;
    while(i < RE.length()){
        if(!s.empty() && s.top()=='|' && RE[i]==')'){
            union2 = *cnt;
            *(cnt) = *(cnt)+1;

            start_states.pop();
            final_states.pop();

            table[union1.top()].v[2].push_back(*cnt);
            table[union2].v[2].push_back(*cnt);
            final_states.push(*cnt);

            union1.pop();
            s.pop();
            s.pop();
        }
        else if(RE[i]=='('){
            *(cnt) = *(cnt)+1;

            table[final_states.top()].v[2].push_back(*cnt);
            start_states.push(*cnt);
            final_states.push(*cnt);

            s.push(RE[i]);
        }else if(RE[i]=='a' || RE[i]=='b'){
            NFAE_entry q1;
            NFAE_entry q2;

            if(RE[i]=='a'){
                q1.v[0].push_back(*(cnt)+2);
            }else{
                q1.v[1].push_back(*(cnt)+2);
            }

            q2.v[2].push_back(*(cnt)+3);

            table[start_states.top()].v[2].push_back(*(cnt)+1);
            table[(*cnt)+1] = q1;
            table[(*cnt)+2] = q2;

            *(cnt) = *(cnt)+3;
            final_states.pop();
            final_states.push(*cnt);

        }else if(RE[i]==')'){
            table[final_states.top()].v[2].push_back(*(cnt)+1);
            *(cnt) = *(cnt)+1;

            start_states.pop();
            final_states.pop();
            final_states.push(*cnt);

            s.pop();
        }else{
            if(RE[i]=='*'){
                table[final_states.top()].v[2].push_back(*(cnt)+1);
                table[final_states.top()].v[2].push_back(start_states.top());
                table[start_states.top()].v[2].push_back(final_states.top());

                *(cnt) = *(cnt)+1;

                start_states.pop();
                final_states.pop();
                final_states.push(*cnt);

                s.pop();
                i++;
            }else if(RE[i]=='+'){
                table[final_states.top()].v[2].push_back(*(cnt)+1);
                table[final_states.top()].v[2].push_back(start_states.top());

                *(cnt) = *(cnt)+1;

                start_states.pop();
                final_states.pop();
                final_states.push(*cnt);

                s.pop();
                i++;
            }else if(RE[i]=='?'){
                table[final_states.top()].v[2].push_back(*(cnt)+1);
                table[start_states.top()].v[2].push_back(final_states.top());

                *(cnt) = *(cnt)+1;

                start_states.pop();
                final_states.pop();
                final_states.push(*cnt);

                s.pop();
                i++;
            }else if(RE[i]=='|'){
                union1.push( final_states.top());
                final_states.push(start_states.top());
                s.push('|');
            }
        }
        i++;
    }
}   

void convertToAdjList(map<int,NFAE_entry> &table){
    for(auto u: table){
        for(int i=0;i<u.second.v.size();i++){
            for(auto v: u.second.v[i]){
                if(v != -1)
                adjListNfaEpsilon[u.first].push_back({i,v});
            }
        }
    }
}

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

// finding epsilon closure using dfs
void findEpsilonClosure(int src){
    epsilonVisited[src] = true;
    epsilonClosure[src].insert(src);
    for(auto p : adjListNfaEpsilon[src]){
        if(p.first == 2){
            if(!epsilonVisited[p.second]){
                findEpsilonClosure(p.second);
            }
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

// converting nfa to dfa using bfs
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

// checking if a given dfa state is final or not
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

// mapping each dfa state vector to integer
void map_dfa(){
    int i = 0;
    for(auto x: dfa){
        mapping[x.first] = i;
        i++;
    }
}

void print_dfa_map(){
    for(auto x: dfa_mapped){
        cout<<x.first<<" ";
        for(auto i : x.second){
            cout<<i<<" ";
        }
        cout<<endl;
    }
}

void print_final_states_dfa_map(){
    cout << endl;
    for(auto x: final_states_dfa){
        cout << mapping[x] << " ";
    }
    cout << endl;
}

// storing dfa in mapped form
void dfa_to_mappedDfa(){
    for(auto x : dfa){
        for(auto i :x.second){
            dfa_mapped[mapping[x.first]].push_back(mapping[i]);
        }
    } 
    for(auto x : final_states_dfa){
            final_states_dfa_mapped.insert(mapping[x]);
    }
}

// function to print longest matching lexeme along with index of regex generating it
vector<pair<string,int> > lexical_analyser(string& str, vector<string> &regex_list){
    vector<map<int,vector<int> > > dfa_list;
    vector<set<int> > dfa_final_states_list;

    // converting each regex to dfa
    for(int i=0;i<regex_list.size();i++){
        map<int,NFAE_entry> NFAE_transition_table;
        NFAE_entry start_state;

        //adding start state entry;
        NFAE_transition_table[0] = start_state;

        int state = 0;
        RE_to_NFAE(regex_list[i],NFAE_transition_table,&state);

        //adding final state entry;
        NFAE_entry end_state;
        NFAE_transition_table[state]  = end_state;

        //final state
        int final_state = state;
        int n = final_state + 1;

        // converting to requried format
        convertToAdjList(NFAE_transition_table);

        final_states_nfa_epsilon.insert(final_state);

        //converting nfae to nfa
        convert_nfa_with_epsilon_to_nfa(n,0);

        // converting nfa to dfa
        convert_nfa_to_dfa(n);

        // finding final states for dfa
        find_final_states_for_dfa();

        // adding state 0 as dummy state
        dfa[{}] = {{},{}};

        // mapping dfa
        map_dfa();
        dfa_to_mappedDfa();

        // storing the dfa formed for this regex
        dfa_list.push_back(dfa_mapped);
        dfa_final_states_list.push_back(final_states_dfa_mapped);

        clear_all_global_data_structures();
    }

    vector<pair<string,int> > lexemes;

    // if input string is empty
    if(str.length() == 0){
        // check dfa's which accept empty string
        for(int x=0;x<dfa_list.size();x++){
            if(dfa_final_states_list[x].find(1) != dfa_final_states_list[x].end()){
                lexemes.push_back(make_pair("",x+1));
                return lexemes;
            }
        }
    }

    int ind = 0;
    while(ind < str.length()){
        int maxLen = 0;
        int regexIndex = 0;
        string ans = "";
        for(int x=0;x<dfa_list.size();x++){
            string temp = max_len_lexeme(dfa_list[x],str,ind,dfa_final_states_list[x]);
            if(temp.length() > maxLen){
                maxLen = temp.length();
                regexIndex = x+1;
                ans = temp;
            }
        }
        if(ans.length() == 0){
            string temp = "";
            temp += str[ind];
            lexemes.push_back(make_pair(temp,regexIndex));
            ind++;
        }else{
            lexemes.push_back(make_pair(ans,regexIndex));
            ind = ind+ans.length();
        }
    }

    return lexemes;
}

int main(){
    vector<string> regex_list;
    string inputStr; 

    // taking file input
    ifstream inf{"input.txt"};
    if(!inf){
        cout << "Error in opening input file";
        return 0;
    }

    string temp;
    int lineNum = 0;
    while(inf){
        inf >> temp;
        if(lineNum == 0){
            inputStr = temp;
            // checking if inputStr is empty
            bool flag = false;
            for(auto ch : inputStr){
                if(ch == '(' || ch == ')'){
                    flag = true;
                    break;
                }
            }
            if(flag){
                regex_list.push_back(temp);
                inputStr = "";
            }
        }
        else regex_list.push_back(temp);
        lineNum++;
    }

    vector<pair<string,int> > ans = lexical_analyser(inputStr,regex_list);

    string output;
    for(auto x : ans){
        output += "<" + x.first + ","+ to_string(x.second) + ">";

    }

    // writing output in file
    FILE* fp = fopen("./output.txt","w+");

    if(fp == NULL){
        cout<<"Error in opening output file"<<endl;
        exit(1);
    }

    const char* opstr = output.c_str();
    fprintf(fp,"%s\n",opstr);
    fclose(fp);

    return 0;
}
