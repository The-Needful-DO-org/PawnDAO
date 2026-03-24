<script lang="ts">
  import { backend } from "$lib/canisters";
  import type { PageProps } from './$types';
  import { onMount } from 'svelte';
  // import { invalidate } from '$app/navigation';
  let { data }: PageProps = $props();
  import NewLoanRequestForm from '$lib/components/NewLoanRequestForm.svelte';
  import { wallet } from '$lib/components/WalletBar.svelte';
  import type { LoanOffer } from "../../../../declarations/pawndao_backend/pawndao_backend.did";
  import LoanRequest from "$lib/components/LoanRequest.svelte";
  let showLoanRequestForm = $state(false);
  import { pushState } from '$app/navigation';
  import { page } from '$app/state';

  function showElement() {
    pushState('', { showLoanRequestForm: true }); // Update history state without changing URL
  }

  // TODO cleaner solution for loan offer count
  let allLoanOffers : LoanOffer[] = $state([]);

  onMount(async() => {
    allLoanOffers = await backend.loanOffersAll();
  });
</script>

<main>
  <div class="container mx-auto">
    <h1 class="text-xl">Borrow</h1>

    {#if !page.state.showLoanRequestForm}
      <button 
        class="btn btn-primary"
        onclick={showElement}>
        New Loan Request
      </button>
      <!-- TODO use a page instead of element visibility
      <a href="/loan-requests/new">New Loan Request</a>
      <a href="/borrow/new">New Loan Request</a> -->
    {/if}

    <div style="display: {page.state.showLoanRequestForm ? 'block' : 'none'}">
      <NewLoanRequestForm />
    </div>

    <h2>My Loan Requests</h2>

    <!-- <button class="btn" onclick={()=> {invalidate('app:loanrequests'); }}> -->
    <!--   Refresh -->
    <!-- </button> -->

    <div class="my-loan-requests flex flex-wrap gap-3 justify-center w-full">
    <!-- <div class="my-loan-requests grid grid-cols auto-rows-fr"> -->
      {#each data.loanRequests.reverse() as loanRequest}
        <!-- {console.log(loanRequest)} -->
        <!-- {@const collateral_token = wallet.icrc1_tokens.find(token => token.canister_id == loanRequest.collateral_canister_id)} -->
        <!-- <a class="w-full md:w-1/4" href="/loan-requests/{loanRequest.id}"> -->
        <a class="w-full" href="/loan-requests/{loanRequest.id}">
          <LoanRequest loan_request={loanRequest} />
        </a>
      {/each}
    </div>

  </div>
</main>
