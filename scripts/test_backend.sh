# approve allowance of test pawn TPAWN to backend from borrower
dfx canister call test_pawn_ledger icrc2_approve '(
  record {
    fee = null;
    memo = null;
    from_subaccount = null;
    created_at_time = null;
    amount = 4_206_900_000_000_000_000 : nat;
    expected_allowance = null;
    expires_at = null;
    spender = record {
      owner = principal "uxrrr-q7777-77774-qaaaq-cai";
      subaccount = null;
    };
  },
)'

dfx --identity pawn_loaner canister call icp_ledger_canister icrc2_approve '(
  record {
    fee = null;
    memo = null;
    from_subaccount = null;
    created_at_time = null;
    amount = 4_206_900_000_000_000_000 : nat;
    expected_allowance = null;
    expires_at = null;
    spender = record {
      owner = principal "uxrrr-q7777-77774-qaaaq-cai";
      subaccount = null;
    };
  },
)'


dfx canister call pawndao_backend loanRequestNew '(
  principal "llcdy-4qaaa-aaaah-arcua-cai",
  10_000_000_000 : nat,
  vec {},
  vec {},
  30 : nat,
  4.2 : float64,
  )'


dfx --identity default canister call pawndao_backend loanOfferNew '(
  0 : nat,
  principal "ryjl3-tyaaa-aaaaa-aaaba-cai",
  1_000_000_000 : nat,
  30 : nat,
  1.15 : float64,
)'

# create loan offer with invalid loan request id
dfx --identity default canister call pawndao_backend loanOfferNew '(
  6900 : nat,
  principal "ryjl3-tyaaa-aaaaa-aaaba-cai",
  1_000_000_000 : nat,
  30 : nat,
  1.15 : float64,
)'


dfx canister call pawndao_backend loanOfferAccept 0
