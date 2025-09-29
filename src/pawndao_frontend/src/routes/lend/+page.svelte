<script lang="ts">
  // import { backend } from "$lib/canisters";
  import type { LoanRequest } from '../../../../declarations/pawndao_backend/pawndao_backend.did';
  import type { PageProps } from './$types';
	let { data }: PageProps = $props();
  let current_user_id = $state(data.current_user_id);
</script>

<main>
  <h1>Lending</h1>
  <h2>Loan Requests</h2>
  {#await data.loanRequests}
  loading...
  {:then loanRequests : LoanRequest[]}
    <!-- TODO backend filter -->
  {#each loanRequests.filter(loanRequest => loanRequest.user_id.toString() != current_user_id.toString()) as loanRequest}
    <a href="/loan-requests/{loanRequest.id}">
    <div class="card">
      <div class="card-body">

        <span>User: </span>
        <span>{loanRequest.user_id}</span>

        <span>{loanRequest.collateral_canister_id}</span>
        <span>{loanRequest.collateral_amount}</span>
        
      </div>

    </div>
    </a>
  {/each}
  {/await}
</main>
