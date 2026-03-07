# mint TPAWN to pawn_loaner identity

echo "Minting PAWN to pawn_loaner"
dfx --identity icp_minter canister call test_pawn_ledger icrc1_transfer '
(
  record {
    to = record { owner = principal "527hb-qvt5w-dekj5-hmae5-jxhgs-vqo7l-jenzt-4ovjb-hi7yr-7ujgd-nae"; subaccount = null };
    fee = null;
    memo = null;
    from_subaccount = null;
    created_at_time = null;
    amount = 10_000_000_000 : nat;
  },
)'
