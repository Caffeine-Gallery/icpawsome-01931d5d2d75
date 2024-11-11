import Bool "mo:base/Bool";
import Hash "mo:base/Hash";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";

import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Nat "mo:base/Nat";

actor Token {
    let name : Text = "DogeCoin ICP";
    let symbol : Text = "DOGE";
    let decimals : Nat8 = 8;
    var totalSupply : Nat = 1_000_000_000;

    private stable var balanceEntries : [(Principal, Nat)] = [];
    private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);

    public shared(msg) func mint() : async () {
        let amount = 100;
        let caller = msg.caller;
        
        switch (balances.get(caller)) {
            case (null) {
                balances.put(caller, amount);
            };
            case (?currentBalance) {
                balances.put(caller, currentBalance + amount);
            };
        };
        totalSupply += amount;
    };

    public shared(msg) func transfer(to: Principal, amount: Nat) : async Bool {
        let from = msg.caller;
        
        switch (balances.get(from)) {
            case (null) {
                return false;
            };
            case (?fromBalance) {
                if (fromBalance < amount) {
                    return false;
                };
                
                let newFromBalance = fromBalance - amount;
                balances.put(from, newFromBalance);
                
                switch (balances.get(to)) {
                    case (null) {
                        balances.put(to, amount);
                    };
                    case (?toBalance) {
                        balances.put(to, toBalance + amount);
                    };
                };
                
                return true;
            };
        };
    };

    public query func balanceOf(who: Principal) : async Nat {
        switch (balances.get(who)) {
            case (null) { return 0 };
            case (?balance) { return balance };
        };
    };

    public query func getSymbol() : async Text {
        return symbol;
    };

    public query func getName() : async Text {
        return name;
    };

    system func preupgrade() {
        balanceEntries := Iter.toArray(balances.entries());
    };

    system func postupgrade() {
        balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
    };
}
