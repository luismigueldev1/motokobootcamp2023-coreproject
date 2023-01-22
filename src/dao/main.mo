import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";

import Helpers "helpers";

actor {
    type Proposal = {
        caller : Principal;
        proposal_name : Text;
        votes_yes : Nat;
        votes_no : Nat;
    };

    stable var porposal_count : Nat = 0;
    stable var proposal_array : [(Nat, Proposal)] = [];
    var proposals = HashMap.fromIter<Nat, Proposal>(proposal_array.vals(), 1, Nat.equal, Hash.hash);

    // UPGRADE FUNCTIONS
    system func preupgrade() {
        proposal_array := Iter.toArray<(Nat, Proposal)>(proposals.entries());
    };
    system func postupgrade() {
        proposal_array := [];
    };

    //DAO FUNCTIONS
    public shared ({ caller }) func submit_proposal(proposal_name : Text) : async {
        #Ok : Proposal;
        #Err : Text;
    } {
        if (proposal_name == "") {
            return #Err("No proposal submited");

        };

        //validate if is a non-anonymous
        // if( Principal.isAnonymous(caller) == true ){
        //     return #Err("Anonymous submit proposal is not allowed.");
        // };

        porposal_count += 1;

        let new_proposal = {
            caller;
            proposal_name;
            votes_yes = 0;
            votes_no = 0;
        };
        proposals.put(porposal_count, new_proposal);
        return #Ok new_proposal;
    };

    public shared ({ caller }) func vote(proposal_id : Nat, yes_or_no : Bool) : async {
        #Ok : (Nat, Nat);
        #Err : Text;
    } {

        //validate if is a non-anonymous
        // if( Principal.isAnonymous(caller) == true ){
        //     return #Err("Anonymous vote is not allowed.");
        // };

        let current_proposal = proposals.get(proposal_id);

        switch (current_proposal) {
            case (null) {
                return #Err("No Proposal Found. Try other proposal_id");
            };
            case (?current_proposal) {
                var total_votes_yes = current_proposal.votes_yes;
                var total_votes_no = current_proposal.votes_no;

                if (yes_or_no) {
                    total_votes_yes += 1;
                } else {
                    total_votes_no += 1;
                };

                let update_proposal : Proposal = {
                    caller = current_proposal.caller;
                    proposal_name = current_proposal.proposal_name;
                    votes_yes = total_votes_yes;
                    votes_no = total_votes_no;
                };

                proposals.put(proposal_id, update_proposal);
                return #Ok(update_proposal.votes_yes, update_proposal.votes_no);
            };
        };
    };

    public query func get_proposal(id : Nat) : async ?Proposal {
        return proposals.get(id);
    };

    public query func get_all_proposals() : async [(Int, Proposal)] {
        var buffer = Buffer.Buffer<(Int, Proposal)>(0);
        for (proposal in proposals.entries()) {
            buffer.add(proposal);
        };
        return Buffer.toArray(buffer);
    };

};
