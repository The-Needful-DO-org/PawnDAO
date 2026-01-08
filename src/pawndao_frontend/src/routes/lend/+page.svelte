<script lang="ts">
  // import { backend } from "$lib/canisters";
  import type { LoanRequest as loanRequest } from '../../../../declarations/pawndao_backend/pawndao_backend.did';
  import type { PageProps } from './$types';
  import LoanRequest from '$lib/components/LoanRequest.svelte';
  import { auth } from '$lib/auth.svelte';
	let { data }: PageProps = $props();
  let current_user_id = $state(data.current_user_id);
</script>

<main>
  <h1>Lending</h1>
  <h2>Loan Requests</h2>
  {#await data.loanRequests}
  loading...
  {:then loanRequests : loanRequest[]}
    <!-- TODO backend filter -->
  {#each loanRequests.filter(loanRequest => loanRequest.user_id.toString() != auth.principal?.toString()) as loanRequest}

    <div class="mb-2">
    <a href="/loan-requests/{loanRequest.id}">
      <LoanRequest loan_request={loanRequest} />
    <!-- <div class="card"> -->
    <!--   <div class="card-body"> -->
    <!---->
    <!--     <span>User: </span> -->
    <!--     <span>{loanRequest.user_id}</span> -->
    <!---->
    <!--     <span>{loanRequest.collateral_canister_id}</span> -->
    <!--     <span>{loanRequest.collateral_amount}</span> -->
    <!--      -->
    <!--   </div> -->
    <!---->
    <!-- </div> -->
    </a>
    </div>
  {/each}
  {/await}
</main>
