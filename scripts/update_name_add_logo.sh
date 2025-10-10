LOGO_URI=$(base64 src/pawndao_frontend/static/icrc1_logos/pawndao.svg  -w 0)
dfx deploy test_pawn_ledger --argument "( 
  variant { 
    Upgrade = opt record {
      metadata = opt vec { record { \"icrc1:logo\"; variant { Text = \"data:image/svg+xml;base64,$LOGO_URI\" } }; };
    }
  }, 
)" --mode upgrade --upgrade-unchanged

#--ic

# token_name = opt \"Crypto Cloud\";
