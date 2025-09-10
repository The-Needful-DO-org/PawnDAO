import Array "mo:core/Array";
import Nat "mo:core/Nat";
// import Random "mo:core/Random";
import Map "mo:core/Map";
import Principal "mo:core/Principal";
import List "mo:core/List";
import Iter "mo:core/Iter";
import Debug "mo:base/Debug";


persistent actor {
  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

// Example class
// class Account(initialBalance : Nat) {
//   var balance = initialBalance;
//
//   public func getBalance() : Nat {
//     balance
//   };
//
//
//   public func deposit(amount : Nat) : async Nat {
//     balance += amount;
//     balance
//   };
//   public func withdraw(amount : Nat) : ?Nat {
//     if (amount > balance) { return null };
//       balance -= amount;
//       ?balance
//     };
// };
//
//  public func accountNew(init_balance : Nat) : async Nat {
//     // Creating multiple accounts
//     let account1 = Account(init_balance);
//     ignore account1.withdraw(25);
//     let account2 = Account(1000);
//     return account1.getBalance();
//   };


public type LoanRequest = {
    id : Nat;
    user_id : Principal;
    // purpose : Text;
    collateral_canister_id : Principal;
    collateral_amount : Nat;
    desired_asset_canister_ids : [Principal];
    desired_amounts : [(Principal, Nat)];
    desired_duration : Nat;
    desired_apr : Float;
    // timestamp : Int;
  };

  // Map from Principal to List of LoanRequests
  // stable let loanRequests = Map.empty<Principal, List.List<Article>>();
  transient var userLoanRequests = Map.empty<Principal, List.List<LoanRequest>>();
  transient var nextLoanRequestId = 0;

  // Add a loan request for the caller
  public shared(msg) func loanRequestNew(collateral_canister_id : Principal,
    collateral_amount : Nat,
    desired_asset_canister_ids : [Principal],
    desired_amounts : [(Principal, Nat)],
    desired_duration : Nat,
    desired_apr : Float,
) : async Principal {
    // let caller = Principal.fromActor(this); // Replace with `Principal.fromCaller()` for real user
    let caller = msg.caller; // Replace with `Principal.fromCaller()` for real user
    let loan_requests = switch (Map.get(userLoanRequests, Principal.compare, caller)) {
      case (?list) list;
      case null List.empty<LoanRequest>();
    };
    let newLoanRequest : LoanRequest = {
      id = nextLoanRequestId;
      user_id = caller;
      // purpose = Text;
      collateral_canister_id = collateral_canister_id;
      collateral_amount = collateral_amount;
      desired_asset_canister_ids = desired_asset_canister_ids;
      desired_amounts = desired_amounts;
      desired_duration = desired_duration;
      desired_apr = desired_apr;
      // timestamp = 0; // Replace 0 with actual timestamp
    };
    let updated = List.add(loan_requests, newLoanRequest);
    Debug.print(debug_show(updated));
    Debug.print(debug_show(loan_requests));
    Map.add(userLoanRequests, Principal.compare, caller, loan_requests);
    nextLoanRequestId += 1;
    return caller;
  };

  // Retrieve all articles for a given user
  public query func loanRequestsGetByUser(user : Principal) : async [LoanRequest] {
    switch (Map.get(userLoanRequests, Principal.compare, user)) {
      case (?list) List.toArray(list);
      case null [];
    }
  };

  // public query func loanRequestsAll() : async [LoanRequest] {
  //   let allEntries = Iter.toArray(Map.entries(userLoanRequests));
  //   var allLoanRequests : [LoanRequest] = [];
  //   for ((_, loanRequestList) in allEntries) {
  //     allLoanRequests := Array.append(allLoanRequests, List.toArray(loanRequestList));
  //   };
  //  return allLoanRequests;
  // };

public type LoanOffer = {
    id : Nat;
    loan_request_id : Nat;
    user_id : Principal;
    loan_asset_canister_id : Principal;
    loan_amount : Nat;
    duration : Nat;
    interest : Float;
    // timestamp : Int;
  };

  transient var userLoanOffers = Map.empty<Principal, List.List<LoanOffer>>();
  transient var nextLoanOfferId = 0;

  public shared(msg) func loanOfferNew(
    loan_request_id : Nat,
    loan_asset_canister_id : Principal,
    loan_amount : Nat,
    duration : Nat,
    interest : Float,
) : async LoanOffer {
    // let caller = Principal.fromActor(this); // Replace with `Principal.fromCaller()` for real user
    let caller = msg.caller; // Replace with `Principal.fromCaller()` for real user
    let loan_offers = switch (Map.get(userLoanOffers, Principal.compare, caller)) {
      case (?list) list;
      case null List.empty<LoanOffer>();
    };
    let newLoanOffer : LoanOffer = {
      id = nextLoanOfferId;
      user_id = caller;
      // purpose = Text;
      loan_request_id = loan_request_id;
      loan_asset_canister_id = loan_asset_canister_id;
      loan_amount = loan_amount;
      duration = duration;
      interest = interest;
      // timestamp = 0; // Replace 0 with actual timestamp
    };
    let updated = List.add(loan_offers, newLoanOffer);
    Map.add(userLoanOffers, Principal.compare, caller, loan_offers);
    nextLoanOfferId += 1;
    return newLoanOffer;
  };

  // Retrieve all loan offers for a given user
  public query func loanOffersGetByUser(user : Principal) : async [LoanOffer] {
    switch (Map.get(userLoanOffers, Principal.compare, user)) {
      case (?list) List.toArray(list);
      case null [];
    }
  };

};
