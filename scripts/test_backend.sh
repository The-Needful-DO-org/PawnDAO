## give test icp to test users
#sh ./scripts/mint_icp.sh # to pawn_loaner
## sh ./scripts/mint_icp_to_anon.sh
#sh ./scripts/mint_icp_to_dev.sh
## sh ./scripts/mint_pawn_to_anon.sh
#sh ./scripts/mint_pawn_to_dev.sh
#
## approve allowance of test pawn TPAWN to backend from borrower
#dfx --identity dev canister call test_pawn_ledger icrc2_approve '(
#  record {
#    fee = null;
#    memo = null;
#    from_subaccount = null;
#    created_at_time = null;
#    amount = 4_206_900_000_000_000_000 : nat;
#    expected_allowance = null;
#    expires_at = null;
#    spender = record {
#      owner = principal "u6s2n-gx777-77774-qaaba-cai";
#      subaccount = null;
#    };
#  },
#)'
#
#dfx --identity pawn_loaner canister call icp_ledger_canister icrc2_approve '(
#  record {
#    fee = null;
#    memo = null;
#    from_subaccount = null;
#    created_at_time = null;
#    amount = 4_206_900_000_000_000_000 : nat;
#    expected_allowance = null;
#    expires_at = null;
#    spender = record {
#      owner = principal "u6s2n-gx777-77774-qaaba-cai";
#      subaccount = null;
#    };
#  },
#)'
#
## approve TICP transfer from borrower
#dfx --identity dev canister call icp_ledger_canister icrc2_approve '(
#  record {
#    fee = null;
#    memo = null;
#    from_subaccount = null;
#    created_at_time = null;
#    amount = 4_206_900_000_000_000_000 : nat;
#    expected_allowance = null;
#    expires_at = null;
#    spender = record {
#      owner = principal "u6s2n-gx777-77774-qaaba-cai";
#      subaccount = null;
#    };
#  },
#)'

LOAN_REQUEST_ID=$(dfx --identity dev canister call pawndao_backend loanRequestNew '(
  principal "llcdy-4qaaa-aaaah-arcua-cai",
  10_000_000_000 : nat,
  vec {},
  vec {},
  30 : nat,
  1.1 : float64,
  )' | idl2json | bc)

# echo $LOAN_REQUEST_ID
# LOAN_REQUEST_ID=$(($(echo LOAN_REQUEST_ID)))

echo "Loan Req ID"
echo $LOAN_REQUEST_ID

# TODO use loan request id var
LOAN_OFFER_ID=$(dfx --identity pawn_loaner canister call pawndao_backend loanOfferNew "(
  $LOAN_REQUEST_ID : nat,
  principal \"ryjl3-tyaaa-aaaaa-aaaba-cai\",
  1_000_000_000 : nat,
  30 : nat,
  1.1 : float64,
  )" | idl2json | jq '.id' | bc)

echo "Loan Offer:"
echo $LOAN_OFFER_ID

# create loan offer with invalid loan request id
# dfx --identity pawn_loaner canister call pawndao_backend loanOfferNew '(
#   6900 : nat,
#   principal "ryjl3-tyaaa-aaaaa-aaaba-cai",
#   1_000_000_000 : nat,
#   30 : nat,
#   1.15 : float64,
# )'

echo "Backend TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "umunu-kh777-77774-qaaca-cai";    subaccount = null; },    )'

echo "Backend TICP balance:"
dfx canister call icp_ledger_canister icrc1_balance_of '( record { owner = principal "umunu-kh777-77774-qaaca-cai";    subaccount = null; },    )'

echo "Borrower TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "fn5kk-kn4e4-lbi3j-to4w7-xq5fa-hcjgt-kevst-f3yy7-iemxh-h6qrs-oqe";    subaccount = null; }, )'

echo "Borrower TICP balance:"
dfx --identity dev ledger balance

echo "pawn_loaner TICP balance:"
dfx --identity pawn_loaner ledger balance

echo "Accept Loan Offer"
# TODO use loan offer id var
LOAN_ID=$(dfx --identity dev canister call pawndao_backend loanOfferAccept $LOAN_OFFER_ID | idl2json | jq '.[0].id' | bc)

echo "Loan ID:"
echo $LOAN_ID

# dfx canister call pawndao_backend loanById 0

echo "Backend TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "umunu-kh777-77774-qaaca-cai";    subaccount = null; },    )'

echo "Backend TICP balance:"
dfx canister call icp_ledger_canister icrc1_balance_of '( record { owner = principal "umunu-kh777-77774-qaaca-cai";    subaccount = null; },    )'

echo "Borrower TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "fn5kk-kn4e4-lbi3j-to4w7-xq5fa-hcjgt-kevst-f3yy7-iemxh-h6qrs-oqe";    subaccount = null; }, )'

echo "Borrower TICP balance:"
dfx --identity dev ledger balance

echo "pawn_loaner TICP balance:"
dfx --identity pawn_loaner ledger balance

echo "Repay Loan"
dfx --identity dev canister call pawndao_backend loanRepay $LOAN_ID

echo "Backend TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "umunu-kh777-77774-qaaca-cai";    subaccount = null; },    )'

echo "Backend TICP balance:"
dfx canister call icp_ledger_canister icrc1_balance_of '( record { owner = principal "umunu-kh777-77774-qaaca-cai";    subaccount = null; },    )'

echo "Borrower TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "fn5kk-kn4e4-lbi3j-to4w7-xq5fa-hcjgt-kevst-f3yy7-iemxh-h6qrs-oqe";    subaccount = null; }, )'

echo "Borrower TICP balance:"
dfx --identity dev ledger balance

echo "pawn_loaner TICP balance:"
dfx --identity pawn_loaner ledger balance

echo "Lender TPAWN balance:"
dfx canister call test_pawn_ledger icrc1_balance_of '( record { owner = principal "527hb-qvt5w-dekj5-hmae5-jxhgs-vqo7l-jenzt-4ovjb-hi7yr-7ujgd-nae";    subaccount = null; }, )'

# offer with duration of zero
#dfx --identity pawn_loaner canister call pawndao_backend loanOfferNew '(
#  0 : nat,
#  principal "ryjl3-tyaaa-aaaaa-aaaba-cai",
#  1_000_000_000 : nat,
#  0 : nat,
#  1.1 : float64,
#)'
#
#echo "Accept Loan Offer zero duration"
#dfx canister call pawndao_backend loanOfferAccept 2
#
#echo "Default Loan zero duration"
#dfx --identity pawn_loaner canister call pawndao_backend loanDefault 1
#
#sh ./scripts/test_anon_loans.sh
