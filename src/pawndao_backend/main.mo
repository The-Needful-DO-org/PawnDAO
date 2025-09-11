import Array "mo:core/Array";
import Nat "mo:core/Nat";
// import Random "mo:core/Random";
import Map "mo:core/Map";
import Principal "mo:core/Principal";
import List "mo:core/List";
import Iter "mo:core/Iter";
import Debug "mo:base/Debug";
import PureList "mo:core/pure/List";
// Import our ICRC type definitions
import ICRC "./ICRC";
import Result "mo:core/Result";
import Error "mo:core/Error";
import Time "mo:core/Time";
import Float "mo:core/Float";
import Int "mo:core/Int";



persistent actor PawnDAO {
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
    desired_interest : Float;
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
    desired_interest : Float,
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
      desired_interest = desired_interest;
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


public query func loanRequestsAll() : async [LoanRequest] {
  var acc : [LoanRequest] = [];
  for ((_, l) in Map.entries(userLoanRequests)) { // iterator over entries [[Map entries](https://internetcomputer.org/docs/motoko/core/Map#function-entries)]
    let va = List.toVarArray<LoanRequest>(l);    // List<T> -> [var T] [[List toVarArray](https://internetcomputer.org/docs/motoko/core/List#function-tovararray)]
    let a = Array.fromVarArray<LoanRequest>(va);  // [var T] -> [T] [[fromVarArray](https://internetcomputer.org/docs/motoko/core/List#function-fromvararray)]
    acc := Array.concat(acc, a);
  };
  return acc;
};

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

public type Loan = {
    id : Nat;
    loan_request_id : Nat;
    loan_offer_id : Nat;
    borrower_user_id : Principal;
    lender_user_id : Principal;
    collateral_canister_id : Principal;
    collateral_amount : Nat;
    loan_asset_canister_id : Principal;
    loan_amount : Nat;
    duration : Nat;
    interest : Float;
    timestamp : Int;
    // status : Text;
  };

  transient var idLoansMap = Map.empty<Nat, Loan>();
  transient var nextLoanId : Nat = 0;

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

  public query func loanOffersAll() : async [LoanOffer] {
    var acc : [LoanOffer] = [];
    for ((_, l) in Map.entries(userLoanOffers)) { // iterator over entries [[Map entries](https://internetcomputer.org/docs/motoko/core/Map#function-entries)]
      let va = List.toVarArray<LoanOffer>(l);    // List<T> -> [var T] [[List toVarArray](https://internetcomputer.org/docs/motoko/core/List#function-tovararray)]
      let a = Array.fromVarArray<LoanOffer>(va);  // [var T] -> [T] [[fromVarArray](https://internetcomputer.org/docs/motoko/core/List#function-fromvararray)]
      acc := Array.concat(acc, a);
    };
    return acc;
  };

  public shared func loanRequestByIdAsync(loan_request_id : Nat) : async ?LoanRequest {
    var loan_request : ?LoanRequest = null;
    for ((_, loan_requests) in Map.entries(userLoanRequests)) {
      List.forEach<LoanRequest>(loan_requests, func (iter_loan_request) {
        if (iter_loan_request.id == loan_request_id) {
           loan_request := ?iter_loan_request;
        }
      });
    };
    return loan_request;
  };

  private func loanRequestById(loan_request_id : Nat) : ?LoanRequest {
    var loan_request : ?LoanRequest = null;
    for ((_, loan_requests) in Map.entries(userLoanRequests)) {
      List.forEach<LoanRequest>(loan_requests, func (iter_loan_request) {
        if (iter_loan_request.id == loan_request_id) {
           loan_request := ?iter_loan_request;
        }
      });
    };
    return loan_request;
  };

  public shared(msg) func loanOfferAccept(
    loan_offer_id : Nat,
) : async ?Loan {
    let caller = msg.caller; // Replace with `Principal.fromCaller()` for real user
    var loan_offer : ?LoanOffer = null;
    for ((_, l) in Map.entries(userLoanOffers)) { // iterator over entries [[Map entries](https://internetcomputer.org/docs/motoko/core/Map#function-entries)]
      let va = List.toVarArray<LoanOffer>(l);    // List<T> -> [var T] [[List toVarArray](https://internetcomputer.org/docs/motoko/core/List#function-tovararray)]
      let a = Array.fromVarArray<LoanOffer>(va);  // [var T] -> [T] [[fromVarArray](https://internetcomputer.org/docs/motoko/core/List#function-fromvararray)]
      List.forEach<LoanOffer>(l, func (offer) {
        if (offer.id == loan_offer_id ) {
          loan_offer := ?offer;
        }
      });
    };
    // return loan_offer;

    switch (loan_offer) {
      case (null) { null }; // TODO return Result with message
      case (?loan_offer) { 
       // TODO validate caller is loan requester
       // TODO validate loan offer i.e. already accepted?
       // TODO ensure atomicity
       // let loan_request_maybe = loanRequestById(loan_offer.loan_request_id);
       let ?loan_request = loanRequestById(loan_offer.loan_request_id) else throw Error.reject("Loan Request not found");

       // Perform the transfer, to capture the tokens.
       // TODO use token-handler https://github.com/research-ag/token-handler/blob/main/example/main.mo
       let token : ICRC.Actor = actor (Principal.toText(loan_request.collateral_canister_id));
       let collateral_transfer_result = await token.icrc2_transfer_from({
         spender_subaccount = null;
         from = { owner = msg.caller; subaccount = null};
         to = { owner = Principal.fromActor(PawnDAO); subaccount = null };
         amount = loan_request.collateral_amount;
         fee = null;
         memo = null;
         created_at_time = null;
       });

       // TODO validate collateral_transfer_result 

       // TODO distribute loan 
       let loan_token : ICRC.Actor = actor (Principal.toText(loan_offer.loan_asset_canister_id ));
       let loan_transfer_result = await loan_token.icrc2_transfer_from({
         spender_subaccount = null;
         from = { owner = loan_offer.user_id; subaccount = null};
         to = { owner = msg.caller; subaccount = null }; // maybe use loan_request.user_id instead of msg.caller
         amount = loan_offer.loan_amount;
         fee = null;
         memo = null;
         created_at_time = null;
       });

       // TODO validate loan_transfer_result 
       // TODO create Loan
       let new_loan = {
         id : Nat = nextLoanId;
         loan_request_id : Nat = loan_request.id;
         loan_offer_id : Nat = loan_offer.id;
         borrower_user_id : Principal = loan_request.user_id;
         lender_user_id : Principal = loan_offer.user_id;
         collateral_canister_id : Principal = loan_request.collateral_canister_id;
         collateral_amount : Nat = loan_request.collateral_amount;
         loan_asset_canister_id : Principal = loan_offer.loan_asset_canister_id;
         loan_amount : Nat = loan_offer.loan_amount;
         duration : Nat = loan_offer.duration;
         interest : Float = loan_offer.interest;
         timestamp : Int = Time.now();
         // status : Text;
       };

       Map.add(idLoansMap, Nat.compare, new_loan.id, new_loan);
       nextLoanId += 1;

       // ?loan_offer 
       ?new_loan
      };
    };

  };

  public query func loanById(loan_id: Nat) : async ?Loan {
    return Map.get(idLoansMap, Nat.compare, loan_id);
  };

  public shared(msg) func loanRepay(loan_id: Nat) : async ?Loan {
    let ?loan = Map.get(idLoansMap, Nat.compare, loan_id) else return null; // TODO Result with message if loan not found

    // TODO validate loan, status, transactions, etc...

    let amount_to_repay_float = (Float.fromInt(Nat.toInt(loan.loan_amount)) * (1.0 + loan.interest / 100.0));
    // let amount_to_repay = (1000000000 * (1.0 + 1.1 / 100.0));
    let amount_to_repay_nat : Nat = Int.abs(Float.toInt(amount_to_repay_float));
    Debug.print(debug_show(amount_to_repay_nat));

    let token : ICRC.Actor = actor (Principal.toText(loan.loan_asset_canister_id));
    let loan_repay_transfer_result = await token.icrc2_transfer_from({
          spender_subaccount = null;
          from = { owner = msg.caller; subaccount = null};
          to = { owner = loan.lender_user_id; subaccount = null };
          amount = amount_to_repay_nat;
          fee = null;
          memo = null;
          created_at_time = null;
        });

     // TODO validate loan_repay_transfer_result

     // TODO update Loan status, record of payment

     // return the collateral
    let collateral_token : ICRC.Actor = actor (Principal.toText(loan.collateral_canister_id));
    let collateral_transfer_fee = 10_000; // TODO dynamic fee
    let loan_return_collateral_transfer_result = await collateral_token.icrc2_transfer_from({
          spender_subaccount = null;
          from = { owner = Principal.fromActor(PawnDAO); subaccount = null};
          to = { owner = loan.borrower_user_id; subaccount = null };
          amount = loan.collateral_amount - collateral_transfer_fee;
          fee = null;
          memo = null;
          created_at_time = null;
        });

     // TODO validate loan_return_collateral_transfer_result
     // TODO update Loan status, record of payment

    return ?loan;
  };

};
