<script lang="ts">
  let { loan_request } = $props();
  import { backend } from "$lib/canisters";
  import { onMount } from "svelte";
  import type { LoanRequest } from '../../../../../../declarations/pawndao_backend/pawndao_backend.did.d.ts'; 
  import { Principal } from "@dfinity/principal";
  import { createAgent } from "@dfinity/utils";
  import { LedgerCanister } from "@dfinity/ledger-icp";
  import { IcrcLedgerCanister } from "@dfinity/ledger-icrc";
  import { mapTokenMetadata } from "@dfinity/ledger-icrc";
  import type { AllowanceParams  } from "@dfinity/ledger-icrc";
  // import type { Account, AllowanceArgs, icrc21_consent_message_request as ConsentMessageArgs, GetBlocksArgs, Subaccount, Timestamp, Tokens } from "@dfinity/ledger-icrc/dist/candid/icrc_ledger";

  import { HttpAgent } from "@dfinity/agent";
  import { icrc1_balance, icrc1_decimals } from "$lib/icrc_functions";
  import { wallet } from '$lib/components/WalletBar.svelte';



  // let { data }: PageProps = $props();
  // let loan_request = $state(loan_request);
  // let loan_offer = $state(data.loanOffer);
  // let collateral_token_ledger =
  let collateral_decimals = $state();
  let collateral_token = $derived(wallet.icrc1_tokens.find(token => token.canister_id == loan_request.collateral_canister_id));
  let desired_token = $derived(wallet.icrc1_tokens.find(token => token.canister_id == loan_request.desired_asset_canister_ids[0]));

  onMount(async () => {
    // add assets to wallet so metadata is available
    // TODO a more efficient solution
    wallet.addICRC1Token(loan_request.collateral_canister_id);
    if (loan_request.desired_asset_canister_ids[0]) {
      wallet.addICRC1Token(loan_request.desired_asset_canister_ids[0]);
    }

    const agent = await HttpAgent.create({});
    // const agent = new HttpAgent({ /* no identity = anonymous */ });

    // Fetch root key for certificate validation during development
    if (process.env.DFX_NETWORK !== "ic") {
     await agent.fetchRootKey().catch((err) => {
        console.warn(
          "Unable to fetch root key. Check to ensure that your local replica is running"
        );
        console.error(err);
      });
    }

    const collateral_ledger = IcrcLedgerCanister.create({
      agent,
      canisterId: loan_request.collateral_canister_id,
    });

    try {
      const meta_response = await collateral_ledger.metadata({certified: false});
      const meta_map = mapTokenMetadata(meta_response);
      console.log(meta_response);
      collateral_decimals = meta_map?.decimals;
    } catch(error) {
      console.log(333);
      console.log(error);

    }
  });

  // function sleep(ms) {
  //   return new Promise(resolve => setTimeout(resolve, ms));
  // }

  async function refreshLoanOffers() {
    // TODO a backend query for loanoffers by loanrequest id
    const loanOffersAll:LoanOffer[] = await backend.loanOffersAll().then((response:LoanOffer[]) => {
      return response;
    });
    const loanOffers:LoanOffer[] = Array.from(loanOffersAll).filter((offer:LoanOffer) => { return offer.loan_request_id === loan_request.id });
    loan_offers = loanOffers;
  }

  // approve ICRC transfer by backend
  async function icrc2_approve(canister_id : string, amount : Number = 42069000000) {

    //  TODO add auth
    // const identity = await $auth.identity;
    // const agent = await createAgent({
    //   identity,
    //   host:
    //     process.env.DFX_NETWORK === "ic"
    //       ? "https://icp-api.io"
    //       : "http://127.0.0.1:4944",
    // });


    const agent = await HttpAgent.create({});

    // Fetch root key for certificate validation during development
    if (process.env.DFX_NETWORK !== "ic") {
      agent.fetchRootKey().catch((err) => {
        console.warn(
          "Unable to fetch root key. Check to ensure that your local replica is running"
        );
        console.error(err);
      });
    }


    // const { metadata } = LedgerCanister.create({
    //   agent,
    //   canisterId: "ryjl3-tyaaa-aaaaa-aaaba-cai",
    // });

    // const { icrc2Approve } = LedgerCanister.create({
    const { approve } = IcrcLedgerCanister.create({
      agent,
      canisterId: canister_id,
    });
    const icp_amountNat = Math.round(amount*10**8);
    const approveArgs = {
      spender: {owner: Principal.fromText(process.env.CANISTER_ID_PAWNDAO_BACKEND),
                subaccount: [],
               },
      amount: icp_amountNat, // TODO dynamic fee
      };

      // TODO handle errors
      try {
          // Code that might throw an error
          const approval = await approve(approveArgs);
          console.log("ICRC approval: " + approval);
      } catch (error) {
          // Handle the exception
          console.error('An error occurred:', error.message);
          console.error('An error occurred:', error);
          console.error('An error occurred:', error.errorType);
          throw error;
      }

  }


  // Handler to accept a loan offer via loanOfferAccept
  async function loanOfferAccept(offerId:BigInt) {
    try {
      await backend.loanOfferAccept(offerId);
      alert("Loan offer accepted!");
      // Optionally refresh data or update UI here
    } catch (e) {
      // TODO deprecate because could cause infinite approve loop
      if (e.message.match("InsufficientAllowance")) {
        // calculate amount to approve
        const approval_amount = loan_request.collateral_amount * 1000000000000;
        const icrc2_approve_response = icrc2_approve(loan_request.collateral_canister_id, approval_amount)
          .catch((error) => {
            alert(error);
            console.error("henlo");
            console.error(error);
            throw error;
          })
          .then((response) => {
            alert(response);
            alert("HI");
            loanOfferAccept(offerId);
          });
        // console.log(icrc2_approve_response );
        // alert(icrc2_approve_response );
        // alert(loan_request.collateral_canister_id);
        // alert("Error InsufficientAllowance " + e);
      } else {
        alert("Error accepting loan offer: " + e);
      }
    }
    refreshLoanOffers();
  }

  // Handler to reject a loan offer via loanOfferReject
  async function loanOfferReject(offerId:BigInt) {
    try {
      let modified_loan_offer = await backend.loanOfferReject(offerId);
      alert("Loan offer rejected!");
      // Optionally refresh data or update UI here
      console.log(modified_loan_offer);
      refreshLoanOffers();
    } catch (e) {
      alert("Error rejecting loan offer: " + e);
    }
  }

  // Handler to reject a loan offer via loanOfferCancel
  async function loanOfferCancel(offerId:BigInt) {
    try {
      await backend.loanOfferCancel(offerId);
      alert("Loan offer cancelled!");
      // Optionally refresh data or update UI here
    } catch (e) {
      alert("Error cancelling loan offer: " + e);
    }
    refreshLoanOffers();
  }

  // Handler to withdraw collateral from a loan offer
  async function loanOfferCollateralWithdraw(offerId:BigInt) {
    try {
      await backend.loanOfferCollateralWithdraw(offerId);
      alert("Loan offer collateral withdrawn!");
      // Optionally refresh data or update UI here
    } catch (e) {
      alert("Error withdrawing collateral from loan offer: " + e);
    }
    refreshLoanOffers();
  }

  // Handler to fund the loan offer
  async function loanOfferFundLoan(offerId:BigInt) {
    try {
      await backend.loanOfferFundLoan(offerId);
      alert("Loan offer funded Loan created!");
      // Optionally refresh data or update UI here
    } catch (e) {
      alert("Error funding loan offer: " + e);
    }
    refreshLoanOffers();
  }
</script>

      <div class="card h-full card-border border-secondary/20 bg-base-200 image-full shadow-sm">
        <!-- Desired asset logo -->
        {#if desired_token}
          <!-- <figure -->
          <!--   class="max-w-full max-h-2/5 absolute -->
          <!--   top-5/6 left-1/2 transform -translate-x-1/2 -translate-y-5/6" -->
          <!-- > -->
          <figure>
          <img 
            class="max-w-full max-h-1/2 bottom-0 absolute"
            loading = "lazy"
            src={desired_token?.logo || (desired_token.canister_id == "ryjl3-tyaaa-aaaaa-aaaba-cai" ? "/icrc1_logos/ryjl3-tyaaa-aaaaa-aaaba-cai.ico" : null) }
            alt="{desired_token?.symbol} ICRC1 Logo" />
          </figure>
        {/if}
          <!-- TODO scalable asset logo handler -->
          {#if collateral_token?.canister_id == "ryjl3-tyaaa-aaaaa-aaaba-cai"}
            <figure>
            <img 
              class="max-w-1/2 max-h-1/2 top-0 absolute"
              loading = "lazy"
              src="/icrc1_logos/ryjl3-tyaaa-aaaaa-aaaba-cai.ico"
              alt="{collateral_token?.symbol} ICRC1 Logo" />
          </figure>
          {:else if collateral_token?.canister_id == "XXllcdy-4qaaa-aaaah-arcua-cai"}
          <figure>
            <!-- {console.log(collateral_token)} -->
            <img 
              class="max-w-full max-h-1/2 top-0 absolute"
              loading = "lazy"
              src={collateral_token.logo || "/icrc1_logos/llcdy-4qaaa-aaaah-arcua-cai.svg"}
              alt="{collateral_token.symbol} ICRC1 Logo" />
          </figure>
          {:else if collateral_token?.logo}
          <figure>
            <!-- TODO broken logo handler -->
            <img 
              class="max-h-2/5 top-5 absolute"
              loading = "lazy"
              src={collateral_token.logo}
              alt="{collateral_token.symbol} ICRC1 Logo" />
          </figure>
          {/if}

        <div class="card-body">
          <h2>Loan Request #{loan_request.id}</h2>

          <div>
            <span>Status:</span> <span class={["badge bg-neutral/40",
                                       Object.entries(loan_request.status)[0][0] == "Pending" ? "bg-success/40" : "",
                                       Object.entries(loan_request.status)[0][0] == "Cancelled" ? "bg-error/40" : "",
                                       Object.entries(loan_request.status)[0][0] == "Matched" ? "bg-warning/40" : ""]}>{Object.entries(loan_request.status)[0][0]}</span>
            {#if Object.entries(loan_request.status)[0][0] == "Matched" }
              <span>Loan Offer #{Object.entries(loan_request.status)[0][1] }</span>
            {/if}
          </div>

          <!-- <div class="flex flex-row flex-wrap"> -->
          <div class="grid grid-cols-3 gap-2 wrap-anywhere text-primary-content/70">

          <div>
            <span class="text-primary-content/50">
              User </span> <br/>
            <span>{loan_request.user_id}</span>
          </div>

          <div>
            <span class="text-primary-content/50">
              Collateral </span> <br/>
          <!-- <span>{Number(loan_request.collateral_amount) / 10**Number(collateral_decimals) || loan_request.collateral_amount + "n"} {wallet.icrc1_tokens.find(token => token.canister_id == loan_request.collateral_canister_id)?.symbol}</span> -->
          <span>{Number(loan_request.collateral_amount) / 10**Number(collateral_decimals) || loan_request.collateral_amount + "n"} {collateral_token?.symbol}</span>
          </div>

          <div>
            <span class="text-primary-content/50">
              Canister Id </span> <br/>
          <span>{loan_request.collateral_canister_id}</span>
          </div>

          <div class="col-span-full bg-neutral/60 outline-base-200 outline-1 text-center">
            <h2 class="">Desired Terms</h2>
          </div>

          <div>
            <span class="text-primary-content/50">
              Asset</span> <br/>
          <span>{loan_request.desired_asset_canister_ids[0] || "Any"}</span>
          </div>

          <div>
            <span class="text-primary-content/50">
              Amount</span> <br/>
            {#each loan_request.desired_amounts as [desired_canister_id, desired_amount_nat] }
              {@const desired_token = wallet.icrc1_tokens.find(token => token.canister_id == desired_canister_id)}
              {@const desired_amount = desired_amount_nat ?
              Number(desired_amount_nat) / 10**Number(desired_token?.decimals)
              || desired_amount_nat + "n"
              : "Any"
              } 
              <!-- <span>{loan_request.desired_amounts?.[0]?.[1] ?  -->
                <!-- Number(loan_request.desired_amounts[0][1]) / 10**Number(wallet.icrc1_tokens.find(token => token.canister_id == loan_request.desired_amounts[0][0]).decimals)  loan_request.desired_amounts[0][0]).symbol -->
                <!-- || loan_request.desired_amounts?.[0]?.[1] + 'n'  -->
                <!-- : "Any"} -->
              <span>
                {desired_amount} {desired_token?.symbol}
              </span>
            {:else}
              <span>
                Any
              </span>
            {/each}
          <!-- {console.log(loan_request.desired_amounts)} -->
          <!-- {console.log(loan_request)} -->
          </div>

          <div>
            <span class="text-primary-content/50">
              Duration</span> <br/>
            <span>{loan_request.desired_duration} Days</span>
          </div>

          <div class="col-end-4">
            <span class="text-primary-content/50">
              Interest</span> <br/>
          <span>{loan_request.desired_interest}%</span>
          </div>

          </div>
        </div>

      </div>


