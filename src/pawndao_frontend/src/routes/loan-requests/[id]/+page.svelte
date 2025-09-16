<script lang="ts">
  import { backend } from "$lib/canisters";
  import type { PageProps } from './$types';
	let { data }: PageProps = $props();

  // Handler to accept a loan offer via loanOfferAccept
  async function loanOfferAccept(offerId) {
    try {
      await backend.loanOfferAccept(offerId);
      alert("Loan offer accepted!");
      // Optionally refresh data or update UI here
    } catch (e) {
      alert("Error accepting loan offer: " + e);
    }
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
        {#each data.loanOffers as loan_offer}
          <div class="card mb-4">
            <div class="card-body">
              <div><strong>Offer ID:</strong> {loan_offer.id}</div>
              <div><strong>Lender:</strong> {loan_offer.user_id}</div>
              <div><strong>Asset Canister ID:</strong> {loan_offer.loan_asset_canister_id}</div>
              <div><strong>Amount:</strong> {loan_offer.loan_amount}</div>
              <div><strong>Duration:</strong> {loan_offer.duration}</div>
              <div><strong>Interest:</strong> {loan_offer.interest}</div>
              <button class="btn btn-success mt-3" on:click={() => loanOfferAccept(loan_offer.id)}>
                Accept Offer
              </button>
            </div>
          </div>
        {/each}
      </div>
  {/if}
</main>
