import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";

actor {
    type Proposal = {
        caller : Principal;
        proposal_name : Text;
        votes : {
            yes: Nat;
            no: Nat;
        }
    };

    stable var proposal_array: [(Nat, Proposal)] = [];

    var proposals = HashMap.fromIter<Nat, Proposal>(proposal_array.vals(), 1 ,Nat.equal, Hash.hash);
    stable var porposal_count: Nat = 0;

    public shared({caller}) func submit_proposal(proposal_name : Text) : async {#Ok : Proposal; #Err : Text} {
        if(proposal_name == ""){
            return #Err("");

        };
        porposal_count += 1;
        let votes = {
            yes = 0;
            no = 0;
        };
        let new_proposal = {caller ; proposal_name; votes };
        proposals.put(porposal_count, new_proposal);
        return #Ok new_proposal;
    };

    public shared({caller}) func vote(proposal_id : Nat, yes_or_no : Bool) : async {#Ok : {yes: Nat; no: Nat}; #Err : Text} {
        let current_proposal = proposals.get(proposal_id);
        
        switch(current_proposal) {
            case(null) { return #Err("No Proposal Found. Try other proposal_id"); };
            case(?current_proposal) { 
                var total_votes_yes  = current_proposal.votes.yes;
                var total_votes_no  = current_proposal.votes.no;
                if(yes_or_no){
                    total_votes_yes += 1;
                }else{
                    total_votes_no += 1;
                };    
                let update_proposal : Proposal = {
                        caller = current_proposal.caller;
                        proposal_name = current_proposal.proposal_name;
                        votes = {
                            yes = total_votes_yes;
                            no = total_votes_no;
                        }
                        
                };   
                proposals.put(proposal_id, update_proposal);
                return #Ok (update_proposal.votes);
                
            };
        };
    };

    public query func get_proposal(id : Nat) : async ?Proposal {
        return proposals.get(id);
    };
    
    public query func get_all_proposals() : async [(Int, Proposal)] {
        var buffer = Buffer.Buffer<(Int, Proposal)>(0);
        for (proposal in proposals.entries()){
            buffer.add(proposal);
        };
        return Buffer.toArray(buffer);
    };


    // UPGRADE FUNCTIONS
    system func preupgrade() {
        proposal_array := Iter.toArray<(Nat, Proposal)>(proposals.entries());
    };

    system func postupgrade() {
        proposal_array := [];
    }
};