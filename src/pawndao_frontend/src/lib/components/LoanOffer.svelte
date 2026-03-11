<script lang="ts">
  let { loan_offer, loan_request } = $props();
  import { backend } from "$lib/canisters";
  import { onMount } from "svelte";
  import type { PageProps } from './$types';
  import type { LoanOffer as loanOffer, LoanRequest } from '../../../../../../../declarations/pawndao_backend/pawndao_backend.did.d.ts'; 
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
  import LoanOffer from '$lib/components/LoanOffer.svelte';
  import {auth} from "$lib/auth.svelte";



  // let { data }: PageProps = $props();
  // let loan_request = $state(data.loanRequest);
  // let loan_offer = $state(data.loanOffer);
  // let collateral_token_ledger =
  let collateral_decimals = $state();
  let validate_funds_function = $state(validateLoanOfferFunds(loan_offer));

  wallet.addICRC1Token(loan_offer.loan_asset_canister_id);
  let loan_asset_token = $derived(wallet.icrc1_tokens.find(token => token.canister_id === loan_offer.loan_asset_canister_id.toString()));
  let allowance_bool_lender = $derived(wallet.validateICRC2Allowance(loan_offer.loan_asset_canister_id, wallet.principal, loan_offer.loan_amount))

  onMount(async () => {
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
      // TODO use wallet
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

  async function validateLoanOfferFunds(loan_offer : loanOffer) {
  let isValid = true;
  let validations = [];
  // let validations = {
  //   collateral_funds_available: undefined,
  //   loan_funds_available: undefined 
  //   }

    // validate collateral balance
    const loan_requester_principal = loan_request.user_id;
    const collateral_canister_id = loan_request.collateral_canister_id;
    const collateral_balance_nat = await icrc1_balance(loan_requester_principal, collateral_canister_id);
    const collateral_decimals : Number = await icrc1_decimals(collateral_canister_id);
    const collateral_balance_float = Number(collateral_balance_nat) / 10**Number(collateral_decimals);
    if (collateral_balance_nat < loan_request.collateral_amount) { // TODO account for fee
      isValid = false;
      validations.push([false, "Collateral Funds Unavailable"]);
    } else {
      validations.push([true, "Collateral Funds Available"]);
    }

    // alert(collateral_balance_nat);
    // alert(collateral_balance_float);
    // alert(collateral_decimals);

    // validate collateral allowance
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

    // const { approve } = IcrcLedgerCanister.create({
    const collateral_ledger = IcrcLedgerCanister.create({
      agent,
      canisterId: collateral_canister_id,
    });

  // const allowance_args = {
  const allowance_args : AllowanceParams = {
    account: {
      owner: loan_request.user_id,
      subaccount: []
    },
    spender: {
      owner: Principal.fromText(process.env.CANISTER_ID_PAWNDAO_BACKEND),
      subaccount: []
      }
  };

    const collateral_allowance_response = await collateral_ledger.allowance(allowance_args);
    const collateral_allowance_nat = collateral_allowance_response.allowance;
    const collateral_allowance_float = Number(collateral_allowance_nat) / 10**collateral_decimals;
    // console.log(collateral_allowance);
    // console.log(collateral_allowance_float);
    // alert(collateral_allowance.allowance);
    if (collateral_allowance_nat < loan_request.collateral_amount) {
      isValid = false;
      validations.push([false, "Collateral Allowance Unavailable"]);
    } else {
      validations.push([true, "Collateral Allowance Available"]);
    }



    // validate loan offer funds balance
    const lender_balance_nat : Number  = await icrc1_balance(loan_offer.user_id, loan_offer.loan_asset_canister_id);
    const loan_asset_decimals : Number = await icrc1_decimals(loan_offer.loan_asset_canister_id);
    const lender_balance_float = Number(lender_balance_nat) / 10**loan_asset_decimals;
    if (lender_balance_nat < loan_offer.loan_amount) { // TODO account for fee
      isValid = false;
      validations.push([false, "Lender Funds Unavailable"]);
    } else {
      validations.push([true, "Lender Funds Available"]);
    }


    // TODO validate loan offer funds allowance
    const loan_asset_ledger = IcrcLedgerCanister.create({
      agent,
      canisterId: loan_offer.loan_asset_canister_id,
    });

  const lender_allowance_args : AllowanceParams = {
    account: {
      owner: loan_offer.user_id,
      subaccount: []
    },
    spender: {
      owner: Principal.fromText(process.env.CANISTER_ID_PAWNDAO_BACKEND),
      subaccount: []
      }
  };

    const loan_asset_allowance_response = await loan_asset_ledger.allowance(lender_allowance_args);
    const loan_asset_allowance_nat = loan_asset_allowance_response.allowance;
    const loan_asset_allowance_float = Number(loan_asset_allowance_nat) / 10**loan_asset_decimals;
    // console.log(collateral_allowance);
    // console.log(collateral_allowance_float);
    // alert(collateral_allowance.allowance);
    if (loan_asset_allowance_nat < loan_offer.loan_amount) {
      isValid = false;
      validations.push([false, "Lender Allowance Unavailable"]);
    } else {
      validations.push([true, "Lender Allowance Available"]);
    }

    // await sleep(5000); // mock test await 
    return [isValid, validations];
  }

  async function refreshLoanOffers() {
    // TODO a backend query for loanoffers by loanrequest id
    const loanOffersAll:LoanOffer[] = await backend.loanOffersAll().then((response:LoanOffer[]) => {
      return response;
    });
    const loanOffers:LoanOffer[] = Array.from(loanOffersAll).filter((offer:LoanOffer) => { return offer.loan_request_id === loan_request.id });
    loan_offers = loanOffers;
  }

  async function refreshLoanOffer(offer_id) {
    const loanOfferByIdAsync:LoanOffer[] = await backend.loanOfferByIdAsync(offer_id).then((response:LoanOffer[]) => {
      return response;
    });
    loan_offer = loanOfferByIdAsync;
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
      await auth.actor.loanOfferAccept(offerId);
      alert("Loan offer accepted!");
      // Optionally refresh data or update UI here
    } catch (e) {
      if (e.message.match("InsufficientAllowance")) {
        // TODO calculate amount to approve
        const icrc2_approve_response = wallet.icrc2_approve(loan_request.collateral_canister_id)
          .catch((error) => {
            alert(error);
            console.error("henlo");
            console.error(error);
            throw error;
          })
          .then((response) => {
            // alert(response);
            // alert("HI");
            loanOfferAccept(offerId);
          });
        // console.log(icrc2_approve_response );
        // alert(icrc2_approve_response );
        // alert(loan_request.collateral_canister_id);
        // alert("Error InsufficientAllowance " + e);
      } else {
        alert("Error accepting loan offer: " + e);
      }
    } finally {
      refreshLoanOffer(offerId);
    }
  }

  // Handler to reject a loan offer via loanOfferReject
  async function loanOfferReject(offerId:BigInt) {
    try {
      let modified_loan_offer = await backend.loanOfferReject(offerId);
      alert("Loan offer rejected!");
      // Optionally refresh data or update UI here
    } catch (e) {
      alert("Error rejecting loan offer: " + e);
    } finally {
      refreshLoanOffer(offerId);
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
      await auth.actor.loanOfferCollateralWithdraw(offerId);
      alert("Loan offer collateral withdrawn!");
      // Optionally refresh data or update UI here
    } catch (e) {
      alert("Error withdrawing collateral from loan offer: " + e);
    } finally {
      refreshLoanOffer(offerId);
    }
  }

  // Handler to fund the loan offer
  async function loanOfferFundLoan(offerId:BigInt) {
    try {
      await auth.actor.loanOfferFundLoan(offerId);
      alert("Loan offer funded Loan created!");
      // Optionally refresh data or update UI here
    } catch (e) {
      alert("Error funding loan offer: " + e);
    } finally {
      refreshLoanOffer(offerId);
    }
  }
</script>
<div>
  <div class="card mb-4">
    <div class="card-body">
      <a href="/loan-requests/{loan_request.id}/offers/{loan_offer.id}" >
      <div><strong>Offer ID:</strong>
          {loan_offer.id}
      </div>
      </a>
      <div><strong>Status:</strong> {Object.entries(loan_offer.status)[0][0]}</div>
      <div>
        <strong>Funds:</strong>
        <!-- {#await validateLoanOfferFunds(loan_offer) } -->
        {#await validate_funds_function }
          <span class="loading loading-ring loading-xs"></span>
        {:then loan_offer_funds_validation}
          {#if loan_offer_funds_validation[0] == true}
            <div class="tooltip tooltip-right" data-tip="All Funds Available">
              <span class="indicator-item status status-success"></span>
            </div>
          {:else}
            <!-- <div class="tooltip tooltip-right" data-tip={loan_offer_funds_validation[1].join("\r")}> -->
            <div class="tooltip tooltip-right">
              <div class="tooltip-content">
                <ul class="text-left">
                {#each loan_offer_funds_validation[1] as validation}
                  <li>
                    <span class={["indicator-item status", `status-${validation[0] ? "success" : "warning"}`]}></span>
                    {validation[1]}
                  </li>
                {/each}
                </ul>
              </div>
              <span class="indicator-item status status-warning"></span>
            </div>
          {/if}
        {:catch error}
          <button onclick={()=> validate_funds_function = validateLoanOfferFunds(loan_offer) }>🔄 Try Again</button>
          <div class="collapse bg-base-100 border-base-300 border">
            <input type="checkbox" />
            <div class="collapse-title font-semibold">Error validating funds</div>
            <div class="collapse-content text-sm">
              {error}
            </div>
          </div>
        {/await}
            </div>
            <div><strong>Lender:</strong> {loan_offer.user_id}</div>
            <div><strong>Borrower:</strong> {loan_request.user_id}</div>
            <div><strong>Asset Canister ID:</strong> {loan_offer.loan_asset_canister_id}</div>
            <div><strong>Amount:</strong> {Number(loan_offer.loan_amount) / 10**Number(wallet?.icrc1_tokens.find((token) => token.canister_id === loan_offer.loan_asset_canister_id.toString())?.decimals) || loan_offer.loan_amount + " nat"}
              {loan_asset_token?.symbol}
            </div>
            <div><strong>Duration:</strong> {loan_offer.duration} Days</div>
            <div><strong>Interest:</strong> {loan_offer.interest} %</div>

            {#if (process.env.DFX_NETWORK !== "ic") }
              <!-- Debug controls -->
              <button class="btn btn-success mt-3" onclick={() => wallet.icrc2_approve(loan_request.collateral_canister_id, 0) }>
                Debug: Collateral Allowance 0
              </button>
            {/if}

            <!-- Borrower controls -->
            {#if wallet.principal?.toString() == loan_request.user_id}
              {#if Object.entries(loan_offer.status)[0][0] === "Pending" } 
                <button class="btn btn-success mt-3" onclick={() => loanOfferAccept(loan_offer.id)}>
                  Accept Offer
                </button>
                <button class="btn btn-error mt-3" onclick={() => loanOfferReject(loan_offer.id)}>
                  Reject Offer
                </button>
              {/if}
              <!-- TODO validate withdraw collateral -->
              {#if Object.entries(loan_offer.status)[0][0] === "Collateralized" } 
                <button class="btn btn-warning mt-3" onclick={() => loanOfferCollateralWithdraw(loan_offer.id)}>
                  Withdraw Collateral
                </button>
              {/if}
            {/if}

            <!-- Lender controls -->

          <!-- validate allowance -->
            {#if loan_offer.user_id.toString() === auth?.principal?.toString() }
                {#await allowance_bool_lender }
                  <span class="loading loading-ring loading-xs"></span>
                  validating allowance...
                {:then istokenallowed}
                  <span class={"align-[0.05em] status status-" + (istokenallowed ? "success" : "warning") }></span>
                  {loan_asset_token?.symbol || loan_offer.loan_asset_canister_id}
                  allowance
                  {#if !istokenallowed}
                    <br>
                    <button 
                      type="button"
                      onclick={async (e) => {
                        e.target.disabled = true;
                        console.log(e);
                        // todo dynamic amount
                        const supply = await wallet.icrc1_total_supply(loan_asset_token.canister_id);
                        await wallet.icrc2_approve(loan_asset_token.canister_id, supply )
                        // refresh allowance validation
                        allowance_bool_lender = wallet.validateICRC2Allowance(loan_offer.loan_asset_canister_id, wallet.principal, loan_offer.loan_amount);
                        // loan_asset_token = loan_asset_token;
                        wallet.refreshwatchedicrc1tokens();
                      } }
                      class="btn btn-info"
                    >approve</button>
                  <span>cost: </span>
                  <span>{loan_asset_token?.fee / 10**loan_asset_token?.decimals}  {loan_asset_token?.symbol}</span>
                  {/if}

              {:catch error}
                <button onclick={()=> allowance_bool_lender = wallet.validateICRC2Allowance(loan_offer.loan_asset_canister_id, wallet.principal, loan_offer.loan_amount) }>🔄 Try Again</button>
                <div class="collapse bg-base-100 border-base-300 border">
                  <input type="checkbox" />
                  <div class="collapse-title font-semibold">Error validating allowance</div>
                  <div class="collapse-content text-sm">
                    {error}
                  </div>
                </div>
              {/await}
            {:else}
              {#await wallet.getPrincipal()}{/await}
            {/if}


            {#if wallet.principal?.toString() == loan_offer.user_id}
              {#if Object.entries(loan_offer.status)[0][0] === "Collateralized" } 
                <button class="btn btn-info mt-3" onclick={() => loanOfferFundLoan(loan_offer.id)}>
                  Fund Loan
                </button>
              {/if}
              {#if Object.entries(loan_offer.status)[0][0] === "Pending" } 
                <button class="btn btn-error mt-3" onclick={() => loanOfferCancel(loan_offer.id)}>
                  Cancel Offer
                </button>
              {/if}
            {/if}
      </div>
    </div>
  </div>

