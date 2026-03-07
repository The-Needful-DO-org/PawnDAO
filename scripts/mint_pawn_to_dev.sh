echo "Minting PAWN to dev"
dfx --identity icp_minter canister call test_pawn_ledger icrc1_transfer '
(
  record {
    to = record { owner = principal "fn5kk-kn4e4-lbi3j-to4w7-xq5fa-hcjgt-kevst-f3yy7-iemxh-h6qrs-oqe"; subaccount = null };
    fee = null;
    memo = null;
    from_subaccount = null;
    created_at_time = null;
    amount = 10_000_000_000 : nat;
  },
)'

