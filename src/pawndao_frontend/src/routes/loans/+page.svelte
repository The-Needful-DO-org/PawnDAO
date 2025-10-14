<script lang="ts">
  import {auth} from "$lib/auth.svelte";
  import { backend } from "$lib/canisters";
  import type { PageProps } from './$types';
  import Loan from '$lib/components/Loan.svelte'
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

</script>

<main>
  <div class="container mx-auto">
  <h1>Loans</h1>
  <h2>Active</h2>
  {#each loans.filter(loan => Object.entries(loan.status)[0][0] === "Active") as loan}
    <Loan {loan} />
  {/each}

  <h2>Ended</h2>
  {#each loans.filter(loan => Object.entries(loan.status)[0][0] != "Active") as loan}
    <Loan {loan} />
  {/each}
  </div>
</main>
