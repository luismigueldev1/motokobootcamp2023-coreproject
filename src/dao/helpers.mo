import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

module {

    private func isCanisterPrincipal(p : Principal) : Bool {
        let principal_text = Principal.toText(p);
        let correct_length = Text.size(principal_text) == 27;
        let correct_last_characters = Text.endsWith(principal_text, #text "-cai");

        if (Bool.logand(correct_length, correct_last_characters)) {
            return true;
        };
        return false;
    };

    public func isCanister(p : Principal) : Bool {
        return isCanisterPrincipal(p);
    };

};
