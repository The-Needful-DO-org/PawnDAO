<script lang="ts">
  import { backend } from "$lib/canisters";
  import type { PageProps } from './$types';
  import { onMount } from 'svelte';
  let { data }: PageProps = $props();
  import NewLoanRequestForm from '$lib/components/NewLoanRequestForm.svelte';
  import { wallet } from '$lib/components/WalletBar.svelte';
  import type { LoanOffer } from "../../../../declarations/pawndao_backend/pawndao_backend.did";
  let showLoanRequestForm = $state(false);

  // TODO cleaner solution for loan offer count
  let allLoanOffers : LoanOffer[] = $state([]);

  onMount(async() => {
    allLoanOffers = await backend.loanOffersAll();
  });
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
  <div class="my-loan-requests flex flex-wrap gap-1 justify-center w-full">
  <!-- <div class="my-loan-requests grid grid-cols auto-rows-fr"> -->
    {#each data.loanRequests.reverse() as loanRequest}
      <!-- {console.log(loanRequest)} -->
      {@const collateral_token = wallet.icrc1_tokens.find(token => token.canister_id == loanRequest.collateral_canister_id)}
      <a class="w-full md:w-1/4" href="/loan-requests/{loanRequest.id}">
        <!-- <div class="h-full card card-border bg-base-300 shadow-sm"> -->
        <div class="card h-full card-border bg-base-300 image-full shadow-sm">
          <!-- TODO scalable asset logo handler -->
          {#if collateral_token?.canister_id == "ryjl3-tyaaa-aaaaa-aaaba-cai"}
          <figure>
            <img 
              src="/icrc1_logos/ryjl3-tyaaa-aaaaa-aaaba-cai.ico"
              alt="{collateral_token?.symbol} ICRC1 Logo" />
          </figure>
          {/if}
          <div class="card-body">

            <p>
            <span>Borrower: </span>
            <span>{loanRequest.user_id}</span>
            </p>

            <div>
              <span>Status:</span> <span class="badge">{Object.entries(loanRequest.status)[0][0]}</span>
            </div>

            <p>
            <span>Collateral: </span>
            <!-- <span>{wallet.icrc1_tokens.find(token => token.canister_id == loanRequest.collateral_canister_id)?.symbol || loanRequest.collateral_canister_id}</span> -->
            <span>{collateral_token?.symbol || loanRequest.collateral_canister_id}</span>
            <span>{ Number(loanRequest.collateral_amount) / 10**Number(collateral_token?.decimals) || loanRequest.collateral_amount + "nat"}</span>
            </p>

            <div>
              <span>Offers:</span> <span>{allLoanOffers?.filter(offer => offer.loan_request_id == loanRequest.id && Object.entries(offer.status)[0][0] == "Pending").length}</span>
            </div>

          </div>

        </div>
      </a>
    {/each}
  </div>
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
