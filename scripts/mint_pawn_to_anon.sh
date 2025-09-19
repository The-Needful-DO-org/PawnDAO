echo "Minting PAWN to anon"
dfx --identity icp_minter canister call test_pawn_ledger icrc1_transfer '
(
  record {
    to = record { owner = principal "2vxsx-fae"; subaccount = null };
    fee = null;
    memo = null;
    from_subaccount = null;
    created_at_time = null;
    amount = 10_000_000_000 : nat;
  },
)'
