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

type LoanRequestStatus = {
  #Pending;
  #Matched;
  #Cancelled;
  // #Banned : Text; // Optionally carry extra data, like a reason
};

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
    status : LoanRequestStatus;
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
      status = #Pending;
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

type LoanOfferStatus = {
  #Pending;
  #Collateralized;
  #Lended;
  #Accepted;
  #Rejected;
  #Cancelled;
  // #Banned : Text; // Optionally carry extra data, like a reason
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
    status : LoanOfferStatus;
  };

  transient var userLoanOffers = Map.empty<Principal, List.List<LoanOffer>>();
  transient var nextLoanOfferId = 0;

type LoanStatus = {
  #Pending;
  #Active;
  #Inactive;
  #Repaid;
  #Defaulted;
  #Cancelled;
  // #Banned : Text; // Optionally carry extra data, like a reason
};

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
    status : LoanStatus;
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
      status = #Pending;
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

  // to get index of loanoffer list
  // TODO probably change the stable var user map List to a Map by id
  func loanOfferEqualById(a: LoanOffer, b: LoanOffer) : Bool {
    a.id == b.id
  };

  func loanOfferSetStatus(loan_offer: LoanOffer, new_status: LoanOfferStatus) : LoanOffer {
     let modified_loan_offer = { loan_offer with status = new_status };
     let loan_offers = switch (Map.get(userLoanOffers, Principal.compare, loan_offer.user_id)) {
       case (?list) list;
       case null List.empty<LoanOffer>();
     };
     // let updated_loan_offers = List.set(loan_offers, 0, modified_loan_offer );
     let loan_offer_index = List.indexOf<LoanOffer>(loan_offers, loanOfferEqualById, loan_offer ); // else throw Error.reject("Loan Offer index not found");
     switch (loan_offer_index) {
       case (null) { return loan_offer }; // do nothing
       case (?loan_offer_index) {
         List.put(loan_offers, loan_offer_index, modified_loan_offer );
         Map.add(userLoanOffers, Principal.compare, loan_offer.user_id, loan_offers);
         return modified_loan_offer;
       };
     };
  };

  func loanOfferGetSync(loan_offer_id : Nat) : LoanOffer {
    var maybe_loan_offer : ?LoanOffer = null;
    for ((_, l) in Map.entries(userLoanOffers)) { // iterator over entries [[Map entries](https://internetcomputer.org/docs/motoko/core/Map#function-entries)]
      let va = List.toVarArray<LoanOffer>(l);    // List<T> -> [var T] [[List toVarArray](https://internetcomputer.org/docs/motoko/core/List#function-tovararray)]
      let a = Array.fromVarArray<LoanOffer>(va);  // [var T] -> [T] [[fromVarArray](https://internetcomputer.org/docs/motoko/core/List#function-fromvararray)]
      List.forEach<LoanOffer>(l, func (offer) {
        if (offer.id == loan_offer_id ) {
          maybe_loan_offer := ?offer;
        }
      });
    };
    let ?loan_offer = maybe_loan_offer;
    return loan_offer;
  };

  public shared(msg) func loanOfferCollateralWithdraw(
    loan_offer_id : Nat,
    ) : async LoanOffer {
    let loan_offer = loanOfferGetSync(loan_offer_id);
    if (loan_offer.status != #Collateralized) { throw Error.reject("Loan Offer status not Collateralized") };

    // TODO ensure atomicity
    // let loan_request_maybe = loanRequestById(loan_offer.loan_request_id);
    let ?loan_request = loanRequestById(loan_offer.loan_request_id) else throw Error.reject("Loan Request not found");
    // validate caller is loan requester
    if (loan_request.user_id != msg.caller) { throw Error.reject("You are not the loan requester") };

    // Perform the transfer, to withdraw the tokens.
    // TODO check for balance and allowance?
    // TODO use token-handler https://github.com/research-ag/token-handler/blob/main/example/main.mo
    let collateral_token : ICRC.Actor = actor (Principal.toText(loan_request.collateral_canister_id));
    let collateral_token_fee = await collateral_token.icrc1_fee();
    let collateral_withdraw_transfer_result = await collateral_token.icrc2_transfer_from({
      spender_subaccount = null;
      from = { owner = Principal.fromActor(PawnDAO); subaccount = null };
      to = { owner = msg.caller; subaccount = null};
      amount = loan_request.collateral_amount - collateral_token_fee;
      fee = null;
      memo = null;
      created_at_time = null;
    });

   // validate collateral_transfer_result 
      // Check that the transfer was successful.
      let collateral_withdraw_block_height = switch (collateral_withdraw_transfer_result ) {
        case (#Ok(block_height)) {
            // set status of Loan Offer to collateralized
            ignore loanOfferSetStatus(loan_offer, #Pending);
            block_height;
          };
        case (#Err(err)) {
          // Transfer failed. There's no cleanup for us to do since no state has
          // changed, so we can just wrap and return the error to the frontend.
          // TODO define return type insteadbof throw Result.Result<Loan, LoanOfferAcceptError> {
          // return #err(#TransferFromError(err));
          throw Error.reject("Collateral withdraw transfer error: " # debug_show(err) );
        };
      };
 
    // return loan_offer;
    return loanOfferGetSync(loan_offer_id);
  };

  // This is for a LoanOffer which has been collateralized by the Requester
  // But funding by the lender failed, for example if the Lender lacks funds
  // when the Requester accepts the offer
  // This function allows the lender to fund the offer and create the Loan
  public shared(msg) func loanOfferFundLoan(
    loan_offer_id : Nat,
    ) : async LoanOffer {
    let loan_offer = loanOfferGetSync(loan_offer_id);
    if (loan_offer.status != #Collateralized) { throw Error.reject("Loan Offer status not Collateralized") };

    // TODO ensure atomicity
    // let loan_request_maybe = loanRequestById(loan_offer.loan_request_id);
    let ?loan_request = loanRequestById(loan_offer.loan_request_id) else throw Error.reject("Loan Request not found");
    // validate caller is loan requester
    if (loan_offer.user_id != msg.caller) { throw Error.reject("You are not the lender") };

    // Perform the transfer, to fund the loan
    // TODO check for balance and allowance?
    // TODO use token-handler https://github.com/research-ag/token-handler/blob/main/example/main.mo
    let loan_token : ICRC.Actor = actor (Principal.toText(loan_offer.loan_asset_canister_id ));
    let loan_token_fee = await loan_token.icrc1_fee();
    let loan_transfer_result = await loan_token.icrc2_transfer_from({
      spender_subaccount = null;
      from = { owner = loan_offer.user_id; subaccount = null};
      to = { owner = loan_request.user_id; subaccount = null };
      amount = loan_offer.loan_amount;
      fee = null;
      memo = null;
      created_at_time = null;
    });

    // validate loan_transfer_result 
    // Check that the transfer was successful.
    let loan_transfer_block_height = switch (loan_transfer_result) {
      case (#Ok(block_height)) {
          // set status of Loan Offer to collateralized
          ignore loanOfferSetStatus(loan_offer, #Lended);
          // TODO create loan
          block_height;
        };
      case (#Err(err)) {
        // Transfer failed. There's no cleanup for us to do since no state has
        // changed, so we can just wrap and return the error to the frontend.
        // TODO define return type insteadbof throw Result.Result<Loan, LoanOfferAcceptError> {
        // return #err(#TransferFromError(err));
        throw Error.reject("Lending transfer error: " # debug_show(err) );
      };
    };

    // Maybe move this to the transfer validation block?
    // create Loan
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
      status : LoanStatus = #Active;
    };

    Map.add(idLoansMap, Nat.compare, new_loan.id, new_loan);
    nextLoanId += 1;

    // update LoanOffer status
    ignore loanOfferSetStatus(loan_offer, #Accepted );
 
    // return loan_offer;
    return loanOfferGetSync(loan_offer_id);
  };

  public shared(msg) func loanOfferReject(
    loan_offer_id : Nat,
    ) : async LoanOffer {
    let loan_offer = loanOfferGetSync(loan_offer_id);
    if (loan_offer.status != #Pending) { throw Error.reject("Loan Offer status not Pending") };

    // TODO ensure atomicity
    // let loan_request_maybe = loanRequestById(loan_offer.loan_request_id);
    let ?loan_request = loanRequestById(loan_offer.loan_request_id) else throw Error.reject("Loan Request not found");
    // validate caller is loan requester
    if (loan_request.user_id != msg.caller) { throw Error.reject("You are not the borrower") };
    let modified_loan_offer = loanOfferSetStatus(loan_offer, #Rejected);

    return modified_loan_offer;
  };

  public shared(msg) func loanOfferCancel(
    loan_offer_id : Nat,
    ) : async LoanOffer {
    let loan_offer = loanOfferGetSync(loan_offer_id);
    if (loan_offer.status != #Pending and loan_offer.status != #Collateralized) { throw Error.reject("Loan Offer status not Pending or Collateralized") };

    // TODO ensure atomicity
    // let loan_request_maybe = loanRequestById(loan_offer.loan_request_id);
    let ?loan_request = loanRequestById(loan_offer.loan_request_id) else throw Error.reject("Loan Request not found");
    // validate caller is loan requester
    if (loan_offer.user_id != msg.caller) { throw Error.reject("You are not the lender") };


    if (loan_offer.status == #Collateralized) { 
      // Perform the transfer, to withdraw the collateral tokens
      // TODO check for balance and allowance?
      // TODO use token-handler https://github.com/research-ag/token-handler/blob/main/example/main.mo
      let collateral_token : ICRC.Actor = actor (Principal.toText(loan_request.collateral_canister_id));
      let collateral_token_fee = await collateral_token.icrc1_fee();
      let collateral_withdraw_transfer_result = await collateral_token.icrc2_transfer_from({
          spender_subaccount = null;
          from = { owner = Principal.fromActor(PawnDAO); subaccount = null };
          to = { owner = msg.caller; subaccount = null};
          amount = loan_request.collateral_amount - collateral_token_fee;
          fee = null;
          memo = null;
          created_at_time = null;
          });

      // validate collateral_transfer_result 
      // Check that the transfer was successful.
      let collateral_withdraw_block_height = switch (collateral_withdraw_transfer_result ) {
        case (#Ok(block_height)) {
          // ignore loanOfferSetStatus(loan_offer, #Cancelled);
          block_height;
        };
        case (#Err(err)) {
          // Transfer failed. There's no cleanup for us to do since no state has
          // changed, so we can just wrap and return the error to the frontend.
          // TODO define return type insteadbof throw Result.Result<Loan, LoanOfferAcceptError> {
          // return #err(#TransferFromError(err));
          // TODO log error for review
          throw Error.reject("Collateral withdraw transfer error: " # debug_show(err) );
        };
      };


    };

    let modified_loan_offer = loanOfferSetStatus(loan_offer, #Cancelled);

    return modified_loan_offer;
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
       // TODO validate loan offer i.e. already accepted?
       if (loan_offer.status == #Accepted) { throw Error.reject("Loan Offer already accepted") };
       if (loan_offer.status == #Cancelled) { throw Error.reject("Loan Offer cancelled") };
       if (loan_offer.status != #Pending) { throw Error.reject("Loan Offer not pending") };

       // TODO ensure atomicity
       // let loan_request_maybe = loanRequestById(loan_offer.loan_request_id);
       let ?loan_request = loanRequestById(loan_offer.loan_request_id) else throw Error.reject("Loan Request not found");
       // validate caller is loan requester
       if (loan_request.user_id != msg.caller) { throw Error.reject("You are not the loan requester") };

       // Perform the transfer, to capture the tokens.
       // TODO check for balance and allowance?
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

       // validate collateral_transfer_result 
      // Check that the transfer was successful.
      let collateral_block_height = switch (collateral_transfer_result) {
        case (#Ok(block_height)) {
            // set status of Loan Offer to collateralized
            ignore loanOfferSetStatus(loan_offer, #Collateralized);
            block_height;
          };
        case (#Err(err)) {
          // Transfer failed. There's no cleanup for us to do since no state has
          // changed, so we can just wrap and return the error to the frontend.
          // TODO define return type insteadbof throw Result.Result<Loan, LoanOfferAcceptError> {
          // return #err(#TransferFromError(err));
          throw Error.reject("Collateral transfer error: " # debug_show(err) );
        };
      };
       

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
       // validate loan_transfer_result
      // Check that the transfer was successful.
      let loan_transfer_block_height = switch (loan_transfer_result) {
        case (#Ok(block_height)) {
            // set status of Loan Offer to collateralized
            ignore loanOfferSetStatus(loan_offer, #Lended);
            block_height;
          };
        case (#Err(err)) {
          // Transfer failed. There's no cleanup for us to do since no state has
          // changed, so we can just wrap and return the error to the frontend.
          // TODO define return type insteadbof throw Result.Result<Loan, LoanOfferAcceptError> {
          // return #err(#TransferFromError(err));
          throw Error.reject("Lending transfer error: " # debug_show(err) );
        };
      };
 
       // create Loan
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
         status : LoanStatus = #Active;
       };

       Map.add(idLoansMap, Nat.compare, new_loan.id, new_loan);
       nextLoanId += 1;

       // TODO update LoanOffer status
       let modified_loan_offer = { loan_offer with status = #Accepted };
       // Map.add(userLoanOffers, Principal.compare, modified_loan.id, modified_loan);
       let loan_offers = switch (Map.get(userLoanOffers, Principal.compare, loan_offer.user_id)) {
         case (?list) list;
         case null List.empty<LoanOffer>();
       };
       // let updated_loan_offers = List.set(loan_offers, 0, modified_loan_offer );
       let ?loan_offer_index = List.indexOf<LoanOffer>(loan_offers, loanOfferEqualById, loan_offer ) else throw Error.reject("Loan Offer index not found");
       List.put(loan_offers, loan_offer_index, modified_loan_offer );
       Map.add(userLoanOffers, Principal.compare, loan_offer.user_id, loan_offers);



       // ?loan_offer 
       ?new_loan
      };
    };

  };

  public query func loansAll() : async [Loan] {
    return Iter.toArray(Map.values(idLoansMap));
  };

  public query func loanById(loan_id: Nat) : async ?Loan {
    return Map.get(idLoansMap, Nat.compare, loan_id);
  };

  public shared(msg) func loanRepay(loan_id: Nat) : async ?Loan {
    let ?loan = Map.get(idLoansMap, Nat.compare, loan_id) else throw Error.reject("Loan not found") ;

    // TODO validate loan, status, transactions, etc...
    // TODO return Response instead of error
    if (loan.borrower_user_id != msg.caller) { throw Error.reject("Not your loan") };
    if (loan.status == #Repaid) { throw Error.reject("Loan already repaid") };
    if (loan.status == #Cancelled) { throw Error.reject("Loan is cancelled") };
    if (loan.status != #Active) { throw Error.reject("Loan status is not Active") };

    // validate timestamp vs end time
    let oneDay : Int = 24 * 60 * 60 * 1_000_000_000;
    let endtime = loan.timestamp + loan.duration * oneDay;
    if (Time.now() >= endtime) { throw Error.reject("Loan time expired"); };

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
    let collateral_token_fee = await collateral_token.icrc1_fee();
    let loan_return_collateral_transfer_result = await collateral_token.icrc2_transfer_from({
          spender_subaccount = null;
          from = { owner = Principal.fromActor(PawnDAO); subaccount = null};
          to = { owner = loan.borrower_user_id; subaccount = null };
          amount = loan.collateral_amount - collateral_token_fee;
          fee = null;
          memo = null;
          created_at_time = null;
        });

    // TODO validate loan_return_collateral_transfer_result
    // TODO update Loan status, record of payment
    let modified_loan = { loan with status = #Repaid };
    Map.add(idLoansMap, Nat.compare, modified_loan.id, modified_loan);

    return ?modified_loan;
  };

  public shared(msg) func loanDefault(loan_id: Nat) : async ?Loan {
    let ?loan = Map.get(idLoansMap, Nat.compare, loan_id) else throw Error.reject("Loan not found");

    // TODO validate loan, status, transactions, etc...
    // TODO return Response instead of error
    if (loan.lender_user_id != msg.caller) { throw Error.reject("You are not the Lender") };
    if (loan.status == #Repaid) { throw Error.reject("Loan already Repaid") };
    if (loan.status == #Defaulted) { throw Error.reject("Loan already Defaulted") };
    if (loan.status == #Cancelled) { throw Error.reject("Loan already Cancelled") };
    if (loan.status != #Active) { throw Error.reject("Loan status is not Active") };

    // validate timestamp vs end time
    let oneDay : Int = 24 * 60 * 60 * 1_000_000_000;
    let endtime = loan.timestamp + loan.duration * oneDay;
    if (Time.now() < endtime) { throw Error.reject("Loan time not expired"); };

     // transfer the collateral to the lender
    let collateral_token : ICRC.Actor = actor (Principal.toText(loan.collateral_canister_id));
    let collateral_token_fee = await collateral_token.icrc1_fee();
    let loan_default_collateral_transfer_result = await collateral_token.icrc2_transfer_from({
          spender_subaccount = null;
          from = { owner = Principal.fromActor(PawnDAO); subaccount = null};
          to = { owner = loan.lender_user_id; subaccount = null };
          amount = loan.collateral_amount - collateral_token_fee;
          fee = null;
          memo = null;
          created_at_time = null;
        });

    // TODO validate loan_default_collateral_transfer_result
    // validate loan_default_collateral_transfer_result
   // Check that the transfer was successful.
   let loan_default_transfer_block_height = switch (loan_default_collateral_transfer_result) {
     case (#Ok(block_height)) {
         block_height;
       };
     case (#Err(err)) {
       // Transfer failed. There's no cleanup for us to do since no state has
       // changed, so we can just wrap and return the error to the frontend.
       // TODO define return type instead of throw Result.Result<Loan, LoanOfferAcceptError> {
       // return #err(#TransferFromError(err));
       // TODO log error for review
       throw Error.reject("Defaulted collateral transfer error: " # debug_show(err) );
     };
   };

    // update Loan status, record of default
    let modified_loan = { loan with status = #Defaulted };
    Map.add(idLoansMap, Nat.compare, modified_loan.id, modified_loan);

    return ?modified_loan;
  };

};
