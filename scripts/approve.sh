# approve allowance of test pawn TPAWN to backend from borrower
dfx --identity dev canister call test_pawn_ledger icrc2_approve '(
  record {
    fee = null;
    memo = null;
    from_subaccount = null;
    created_at_time = null;
    amount = 4_206_900_000_000_000_000 : nat;
    expected_allowance = null;
    expires_at = null;
    spender = record {
      owner = principal "umunu-kh777-77774-qaaca-cai";
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
      owner = principal "umunu-kh777-77774-qaaca-cai";
      subaccount = null;
    };
  },
)'

# approve TICP transfer from borrower
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
      owner = principal "umunu-kh777-77774-qaaca-cai";
      subaccount = null;
    };
  },
)'


