dfx --identity anonymous canister call icp_ledger_canister icrc2_approve '(
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


