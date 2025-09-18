<script lang="ts">
  import { backend } from "$lib/canisters";
  import type { PageProps } from './$types';
	let { data }: PageProps = $props();
  let loans = $state(data.loans);

  async function refreshLoans() {
    // TODO a backend query for loanoffers by loanrequest id
    const loansAll = await backend.loansAll().then((response) => {
      return response;
    });
    // const loanOffers:LoanOffer[] = Array.from(loanOffersAll).filter((offer:LoanOffer) => { return offer.loan_request_id === data.loanRequest.id });
    loans = loansAll;
  }

  // Handler to accept a loan offer via loanOfferAccept
  async function loanRepay(loan_id:BigInt) {
    try {
      await backend.loanRepay(loan_id);
      alert("Loan repaid!");
      // Optionally refresh data or update UI here
    } catch (e) {
      alert("Error repaying loan: " + e);
    }
    refreshLoans();
  }

</script>

<main>
  <h1>Lending</h1>
  <h2>Loan Requests</h2>
  {#each loans as loan}
    <div class="card">
      <div class="card-body">
        <span>Loan: </span>
        <a href="/loans/{loan.id}">
        <span>#{loan.id}</span>
        </a>

        <div><strong>Status:</strong> {Object.entries(loan.status)[0][0]}</div>

        <span>Borrower User: </span>
        <span>{loan.borrower_user_id}</span>

        <span>Lender User: </span>
        <span>{loan.lender_user_id}</span>

        <div class="divider"></div>

        <span>Collateral: </span>
        <span>{loan.collateral_canister_id}</span>
        <span>{loan.collateral_amount}</span>

        <div class="divider"></div>

        <span>Loaned: </span>
        <span>{loan.loan_asset_canister_id}</span>
        <span>{loan.loan_amount}</span>

        <div class="divider"></div>

        <span>Duration: </span>
        <span>{loan.duration} Days</span>

        <div class="divider"></div>

        <span>Started: </span>
        <span>{loan.timestamp} TODO friendly timestamp</span>

        <div class="divider"></div>
 
        <span>Time Remaining: </span>
        <span>TODO calculate time remaining</span>

        <div class="divider"></div>

        <button class="btn btn-success mt-3" onclick={() => loanRepay(loan.id)}>
          Repay Loan
        </button>

        <!-- <button class="btn btn-success mt-3" onclick={() => loanDefault(loan.id)}> -->
        <!--   Default Loan -->
        <!-- </button> -->

      </div>

    </div>
  {/each}
</main>
