sh ./scripts/mint_icp_to_anon.sh 
sh ./scripts/mint_pawn_to_anon.sh

echo "Approve LICP anon"
dfx --identity anonymous canister call icp_ledger_canister icrc2_approve '
(
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


echo "Approve PAWN anon"
dfx --identity anonymous canister call test_pawn_ledger icrc2_approve '
(
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


dfx --identity anonymous canister call pawndao_backend loanRequestNew '(
  principal "llcdy-4qaaa-aaaah-arcua-cai",
  10_000_000_000 : nat,
  vec {},
  vec {},
  30 : nat,
  1.1 : float64,
  )'


dfx --identity anonymous canister call pawndao_backend loanOfferNew '(
  1 : nat,
  principal "ryjl3-tyaaa-aaaaa-aaaba-cai",
  1_000_000_000 : nat,
  0 : nat,
  1.1 : float64,
)'

# echo "anon Accept Loan Offer"
# dfx --identity anonymous canister call pawndao_backend loanOfferAccept 3



