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

# approve ICP transfer from borrower
dfx --identity dev canister call icp_ledger_canister icrc2_approve '(
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
  1.1 : float64,
  )'


dfx --identity pawn_loaner canister call pawndao_backend loanOfferNew '(
  0 : nat,
  principal "ryjl3-tyaaa-aaaaa-aaaba-cai",
  1_000_000_000 : nat,
  30 : nat,
  1.1 : float64,
)'

# create loan offer with invalid loan request id
dfx --identity pawn_loaner canister call pawndao_backend loanOfferNew '(
  6900 : nat,
  principal "ryjl3-tyaaa-aaaaa-aaaba-cai",
  1_000_000_000 : nat,
  30 : nat,
  1.15 : float64,
)'

echo "Backend TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "uxrrr-q7777-77774-qaaaq-cai";    subaccount = null; },    )'

echo "Borrower TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "fn5kk-kn4e4-lbi3j-to4w7-xq5fa-hcjgt-kevst-f3yy7-iemxh-h6qrs-oqe";    subaccount = null; }, )'

echo "Borrower ICP balance:"
dfx --identity dev ledger balance

echo "pawn_loaner ICP balance:"
dfx --identity pawn_loaner ledger balance

echo "Accept Loan Offer"
dfx canister call pawndao_backend loanOfferAccept 0

# dfx canister call pawndao_backend loanById 0

echo "Backend TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "uxrrr-q7777-77774-qaaaq-cai";    subaccount = null; },    )'

echo "Borrower TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "fn5kk-kn4e4-lbi3j-to4w7-xq5fa-hcjgt-kevst-f3yy7-iemxh-h6qrs-oqe";    subaccount = null; }, )'

echo "Borrower ICP balance:"
dfx --identity dev ledger balance

echo "pawn_loaner ICP balance:"
dfx --identity pawn_loaner ledger balance

# echo "Repay Loan"
# dfx canister call pawndao_backend loanRepay 0

echo "Backend TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "uxrrr-q7777-77774-qaaaq-cai";    subaccount = null; },    )'

echo "Borrower TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "fn5kk-kn4e4-lbi3j-to4w7-xq5fa-hcjgt-kevst-f3yy7-iemxh-h6qrs-oqe";    subaccount = null; }, )'

echo "Borrower ICP balance:"
dfx --identity dev ledger balance

echo "pawn_loaner ICP balance:"
dfx --identity pawn_loaner ledger balance

echo "Lender TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "527hb-qvt5w-dekj5-hmae5-jxhgs-vqo7l-jenzt-4ovjb-hi7yr-7ujgd-nae";    subaccount = null; }, )'


