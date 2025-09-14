<script lang="ts">
  import { backend } from "$lib/canisters";
  import type { PageProps } from './$types';
	let { data }: PageProps = $props();
</script>

<main>
  {#if data.loanRequest}
    <!-- <a href="/loan-requests/2"> -->
    <!--   <h1>Loan Request #{data.loanRequest.id}</h1> -->
    <!-- </a> -->
    <a href="/loan-requests/{data.loanRequest.id}">
      <h1>Loan Request #{data.loanRequest.id}</h1>
    </a>
    {console.log(data.loanRequest)}
      <div class="card">
        <div class="card-body">

          <span>User: </span>
          <span>{data.loanRequest.user_id}</span>

          <span>{data.loanRequest.collateral_canister_id}</span>
          <span>{data.loanRequest.collateral_amount}</span>
          
        </div>

      </div>
  {:else}
    Not found
  {/if}
</main>
