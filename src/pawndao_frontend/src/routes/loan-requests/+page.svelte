<script lang="ts">
  import { backend } from "$lib/canisters";
  import type { PageProps } from './$types';
	let { data }: PageProps = $props();
</script>

<main>
  <h1>Lending</h1>
  <h2>Loan Requests</h2>
  {#each data.loanRequests as loanRequest}
    {console.log(loanRequest)}
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
</main>
