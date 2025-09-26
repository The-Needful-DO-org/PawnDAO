<script lang="ts">
  // import { backend } from "$lib/canisters";
  import type { PageProps } from './$types';
  import NewLoanOfferForm from '$lib/components/NewLoanOfferForm.svelte';
	let { data }: PageProps = $props();
</script>

<main>
  {#if data.loanRequest}

    <a href="/loan-requests/{data.loanRequest.id}">
      <h1>Loan Request #{data.loanRequest.id}</h1>
    </a>

    <NewLoanOfferForm loan_request={data.loanRequest} />

    <!-- <a href="/loan-requests/2"> -->
    <!--   <h1>Loan Request #{data.loanRequest.id}</h1> -->
    <!-- </a> -->
    {console.log(data.loanRequest)}
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
          <div class="divider"></div>

          <span>desired_duration</span>
          <span>{data.loanRequest.desired_duration}</span>
          <div class="divider"></div>

          <span>desired_interest</span>
          <span>{data.loanRequest.desired_interest}</span>
          </div>
        </div>

      </div>
  {:else}
    Not found
  {/if}
</main>
