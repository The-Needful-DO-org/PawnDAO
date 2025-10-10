<script lang="ts">
  import { backend } from "$lib/canisters";
  import { onMount } from "svelte";
  import type { PageProps } from './$types';
  import type { LoanOffer as loanOffer, LoanRequest as loanRequest } from '../../../../../../../declarations/pawndao_backend/pawndao_backend.did.d.ts'; 
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
  import LoanRequest from "$lib/components/LoanRequest.svelte";



	let { data }: PageProps = $props();
  let loan_request = $state(data.loanRequest);
  let loan_offer = $state(data.loanOffer);
  // let collateral_token_ledger =
  let collateral_decimals = $state();

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
      canisterId: data.loanRequest.collateral_canister_id,
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

  async function validateLoanOfferFunds(loan_offer : loanOffer) {
  let isValid = true;
  let validations = [];
  // let validations = {
  //   collateral_funds_available: undefined,
  //   loan_funds_available: undefined 
  //   }

    // validate collateral balance
    const loan_requester_principal = data.loanRequest.user_id;
    const collateral_canister_id = data.loanRequest.collateral_canister_id;
    const collateral_balance_nat = await icrc1_balance(loan_requester_principal, collateral_canister_id);
    const collateral_decimals : Number = await icrc1_decimals(collateral_canister_id);
    const collateral_balance_float = Number(collateral_balance_nat) / 10**Number(collateral_decimals);
    if (collateral_balance_nat < data.loanRequest.collateral_amount) { // TODO account for fee
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
      owner: data.loanRequest.user_id,
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
    if (collateral_allowance_nat < data.loanRequest.collateral_amount) {
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
    if (loan_asset_allowance_float < loan_offer.loan_amount) {
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
    const loanOffers:LoanOffer[] = Array.from(loanOffersAll).filter((offer:LoanOffer) => { return offer.loan_request_id === data.loanRequest.id });
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
      if (e.message.match("InsufficientAllowance")) {
        // TODO calculate amount to approve
        const icrc2_approve_response = icrc2_approve(data.loanRequest.collateral_canister_id)
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
        // alert(data.loanRequest.collateral_canister_id);
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

<main>
  {#if !data.loanOffer}
    Not found
  {:else}
    <div class="breadcrumbs text-sm">
      <ul>
        <li><a href="/loan-requests/">Loan Requests</a></li>
        <li><a href="/loan-requests/{data.loanRequest.id}">{data.loanRequest.id}</a></li>
        <li><a href="/loan-requests/{data.loanRequest.id}/offers">Offers</a></li>
        <li><a href="/loan-requests/{data.loanRequest.id}/offers/{data.loanOffer.id}">{data.loanOffer.id}</a></li>
      </ul>
    </div>
    <a href="/loan-requests/{data.loanRequest.id}">
      <h1>Loan Offer #{data.loanOffer.id}</h1>
    </a>

    <!-- {console.log(data.loanRequest)} -->
    <!-- {console.log(data.loanOffers)} -->
    <LoanRequest loan_request={data.loanRequest} />
    <LoanOffer loan_request={data.loanRequest} loan_offer={data.loanOffer} />
  {/if}
</main>
