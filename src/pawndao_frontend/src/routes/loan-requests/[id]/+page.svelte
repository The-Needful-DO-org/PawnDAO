<script lang="ts">
  import { backend } from "$lib/canisters";
  import type { PageProps } from './$types';
  import type { LoanOffer, LoanRequest } from '../../../../../declarations/pawndao_backend/pawndao_backend.did.d.ts'; 
  import { Principal } from "@dfinity/principal";
  import { createAgent } from "@dfinity/utils";
  import { LedgerCanister } from "@dfinity/ledger-icp";
  import { IcrcLedgerCanister } from "@dfinity/ledger-icrc";
  import { HttpAgent } from "@dfinity/agent";


	let { data }: PageProps = $props();
  let loan_offers = $state(data.loanOffers);


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


    const agent = new HttpAgent({ /* no identity = anonymous */ });

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
  {#if !data.loanRequest}
    Not found
  {:else}
    <a href="/loan-requests/{data.loanRequest.id}/offers/new">
      <span class="btn">Make Offer</span>
    </a>
    <!-- <a href="/loan-requests/2"> -->
    <!--   <h1>Loan Request #{data.loanRequest.id}</h1> -->
    <!-- </a> -->
    <a href="/loan-requests/{data.loanRequest.id}">
      <h1>Loan Request #{data.loanRequest.id}</h1>
    </a>
    <!-- {console.log(data.loanRequest)} -->
    <!-- {console.log(data.loanOffers)} -->
      <div class="card">
        <div class="card-body">

          <div>
          <span>User: </span>
          <span>{data.loanRequest.user_id}</span>
          <div class="divider"></div>

          <span>collateral_canister_id: </span>
          <span>{data.loanRequest.collateral_canister_id}</span>
          <div class="divider"></div>

          <span>collateral_amount: </span>
          <span>{data.loanRequest.collateral_amount}</span>
          <div class="divider"></div>
          
          <span>desired_asset_canister_ids</span>
          <span>{data.loanRequest.desired_asset_canister_ids}</span>
          <div class="divider"></div>

          <span>desired_amounts</span>
          <span>{data.loanRequest.desired_amounts}</span>
          <span>desired_duration</span>
          <span>{data.loanRequest.desired_duration}</span>
          <div class="divider"></div>

          <span>desired_interest</span>
          <span>{data.loanRequest.desired_interest}</span>
          </div>
        </div>

      </div>

      <div>
        <h2>Loan Offers</h2>
        {#each loan_offers  as loan_offer}
          <div class="card mb-4">
            <div class="card-body">
              <div><strong>Offer ID:</strong> {loan_offer.id}</div>
              <div><strong>Status:</strong> {Object.entries(loan_offer.status)[0][0]}</div>
              <div><strong>Lender:</strong> {loan_offer.user_id}</div>
              <div><strong>Asset Canister ID:</strong> {loan_offer.loan_asset_canister_id}</div>
              <div><strong>Amount:</strong> {loan_offer.loan_amount}</div>
              <div><strong>Duration:</strong> {loan_offer.duration}</div>
              <div><strong>Interest:</strong> {loan_offer.interest}</div>
              <button class="btn btn-success mt-3" onclick={() => icrc2_approve(data.loanRequest.collateral_canister_id, 0) }>
                Debug: Collateral Allowance 0
              </button>
              <button class="btn btn-success mt-3" onclick={() => loanOfferAccept(loan_offer.id)}>
                Accept Offer
              </button>
              <button class="btn btn-error mt-3" onclick={() => loanOfferReject(loan_offer.id)}>
                Reject Offer
              </button>
              <button class="btn btn-warning mt-3" onclick={() => loanOfferCollateralWithdraw(loan_offer.id)}>
                Withdraw Collateral
              </button>
              <button class="btn btn-info mt-3" onclick={() => loanOfferFundLoan(loan_offer.id)}>
                Fund Loan
              </button>
              <button class="btn btn-error mt-3" onclick={() => loanOfferCancel(loan_offer.id)}>
                Cancel Offer
              </button>
            </div>
          </div>
        {/each}
      </div>
  {/if}
</main>
