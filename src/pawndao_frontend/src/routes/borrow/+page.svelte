<script lang="ts">
  // import { backend } from "$lib/canisters";
  import type { PageProps } from './$types';
  let { data }: PageProps = $props();
  import NewLoanRequestForm from '$lib/components/NewLoanRequestForm.svelte';
  // import { wallet } from '$lib/components/WalletBar.svelte';
  let showLoanRequestForm = $state(false);
</script>

<main>
  <div class="container mx-auto">
    <h1 class="text-xl">Borrow</h1>

    {#if !showLoanRequestForm}
      <button 
        class="btn btn-primary"
        onclick={() => showLoanRequestForm = true}>
        New Loan Request
      </button>
    {/if}

    {#if showLoanRequestForm}
      <NewLoanRequestForm bind:showLoanRequestForm />
    {/if}

  <h2>My Loan Requests</h2>
  <!-- <button class="btn" onclick={()=> {invalidate('app:loanrequests'); -->
  <!-- // alert(data.loanRequests.length); -->
  <!--   }}> -->
  <!--   Refresh -->
  <!-- </button> -->
  {#each data.loanRequests.reverse() as loanRequest}
    <!-- {console.log(loanRequest)} -->
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

    <!-- <form class="form-control gap-4 mt-6" onsubmit={loanRequestSubmit}> -->
    <!--   <label for="collateral_canister_id" class="label"> -->
    <!--     <span class="w-48">Collateral Canister ID</span> -->
    <!--   </label> -->
    <!--     <input type="text" id="collateral_canister_id" name="collateral_canister_id" class="input grow" required /> -->
    <!--   <label class="label input-bordered flex items-center gap-2"> -->
    <!--     <span class="w-48">Collateral Amount</span> -->
    <!--     <input type="number" name="collateral_amount" class="input grow" required min="0" step="any" /> -->
    <!--   </label> -->
    <!--   <label class="label input-bordered flex items-center gap-2"> -->
    <!--     <span class="w-48">Desired Asset Canister IDs</span> -->
    <!--     <input type="text" name="desired_asset_canister_ids" class="input grow" placeholder="Comma separated" required /> -->
    <!--   </label> -->
    <!--   <label class="label input-bordered flex items-center gap-2"> -->
    <!--     <span class="w-48">Desired Amounts</span> -->
    <!--     <input type="text" name="desired_amounts" class="input grow" placeholder="Comma separated" required /> -->
    <!--   </label> -->
    <!--   <label class="label input-bordered flex items-center gap-2"> -->
    <!--     <span class="w-48">Desired Duration</span> -->
    <!--     <input type="number" name="desired_duration" class="input grow" required min="0" step="any" /> -->
    <!--   </label> -->
    <!--   <label class="label input-bordered flex items-center gap-2"> -->
    <!--     <span class="w-48">Desired Interest</span> -->
    <!--     <input type="number" name="desired_interest" class="input grow" required min="0" step="any" /> -->
    <!--   </label> -->
    <!--   <button type="submit" class="btn btn-primary mt-4">Submit</button> -->
    <!-- </form> -->



  </div>
</main>
