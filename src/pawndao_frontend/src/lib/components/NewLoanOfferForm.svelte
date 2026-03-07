<script lang="ts">
  // Add any necessary script logic here
  // import { page } from '$app/stores';
  import { backend } from "$lib/canisters";
  import { Principal } from "@dfinity/principal";
  import { wallet } from '$lib/components/WalletBar.svelte';
  import { icrc1_decimals } from "$lib/icrc_functions";
  import { onMount } from "svelte";
  const { loan_request  } = $props();
  import { HttpAgent } from "@dfinity/agent";
  import type { AllowanceParams  } from "@dfinity/ledger-icrc";
  import { IcrcLedgerCanister } from "@dfinity/ledger-icrc";
  import { goto } from '$app/navigation';
  // import { redirect } from '@sveltejs/kit';
  import { auth } from "$lib/auth.svelte";

  let notification = $state("");
  let desired_assets = $state([]);
  let desired_amounts = $state(loan_request.desired_amounts.length > 0 ? loan_request.desired_amounts : [[]]);
  // TODO support multiple desired amounts
  let desired_amount_nat = $state((desired_amounts[0][1] || null));
  let collateral_canister_id = $state(loan_request.collateral_canister_id.toString());
  let collateral_amount = $state(loan_request.collateral_amount);
  let collateral_token = $derived(wallet.icrc1_tokens.find(token => token.canister_id === collateral_canister_id));
  let desired_duration = $state(loan_request.desired_duration || 30);
  let desired_interest = $state(loan_request.desired_interest || 4.20);
  try {
    desired_assets = loan_request.desired_asset_canister_ids.map((principal : Principal)=>{return (principal?.toString() || "")});
    } catch { 
    desired_assets = [];
    }
  let loan_asset_canister_id = $state(desired_assets[0]);
  $effect(() => { 
    if (loan_asset_canister_id) {
      // console.log('Selected:', loan_asset_canister_id );
      const res = wallet.addICRC1Token(loan_asset_canister_id);
    }
  } );

  // let loan_asset_canister_id = $state();
  let desired_token = $derived(wallet.icrc1_tokens.find(token => token.canister_id === desired_assets[0]));

  let loan_amount = $state(Number(desired_amount_nat) / 10**Number(desired_token?.decimals));
  let offer_duration =$state(desired_duration);
  let offer_interest =$state(desired_interest);

  // let loan_asset_token = $derived.by(() => {
  //     return wallet.icrc1_tokens.find(token => token.canister_id === loan_asset_canister_id  );
  //   });

  let loan_asset_token = $derived(wallet.icrc1_tokens.find(token => token.canister_id === loan_asset_canister_id));

  let allowance_bool = $derived(validateICRC2Allowance(loan_asset_canister_id, wallet.principal, loan_amount))
  let isLoanTokenAllowed = $state(false);

  onMount(async () => {
    loan_amount = Number(desired_amount_nat) / 10**Number(await icrc1_decimals(Principal.fromText(desired_token?.canister_id)));
  });

// Add this function to handle loanOfferNew
  async function createLoanOffer(event) {
    try {
    // const form = document.getElementById("LoanOfferForm");
    // const form = new FormData(event.currentTarget);
    const form = event.currentTarget;
    // if (!form) { return };
    const loan_request_id = loan_request.id;
    const loan_asset_canister_id = Principal.fromText(form.loan_asset_canister_id.value);
    const loan_asset_token = wallet.icrc1_tokens.find(token => token.canister_id === loan_asset_canister_id.toString() );
    const loan_amount = Number(form.loan_amount.value);
    const loan_amount_nat = loan_amount * 10**Number(loan_asset_token.decimals);
    const duration = Number(form.offer_duration.value);
    const interest = Number(form.offer_interest.value);
    try {
      const offer = await auth.actor.loanOfferNew(
        loan_request_id,
        loan_asset_canister_id,
        loan_amount_nat,
        duration,
        interest
      );
      notification = "Loan offer created!";
      form.reset();
      await goto(`/loan-requests/${loan_request.id}/offers/${offer.id}`);
    } catch (e) {
      console.log(e);
      notification = "Error creating loan offer: " + e;
    }
  } catch(error) {
    notification = error;
  }
  }

  async function validateICRC2Allowance(canister_id : Principal, owner : Principal, amount : number) {
    const token = wallet.icrc1_tokens.find(token => token.canister_id === canister_id.toString() );
    const agent = await HttpAgent.create({});

    // Fetch root key for certificate validation during development
    if (process.env.DFX_NETWORK !== "ic") {
      agent.fetchRootKey().catch((err) => {
        console.warn(
          "Unable to fetch root key. Check to ensure that your local replica is running"
        );
        console.error(err);
      });
    }

    // TODO validate loan offer funds allowance
    const loan_asset_ledger = IcrcLedgerCanister.create({
      agent,
      canisterId: canister_id,
    });

  const lender_allowance_args : AllowanceParams = {
    account: {
      owner: owner,
      subaccount: []
    },
    spender: {
      owner: Principal.fromText(process.env.CANISTER_ID_PAWNDAO_BACKEND),
      subaccount: []
      }
  };

    const loan_asset_allowance_response = await loan_asset_ledger.allowance(lender_allowance_args);
    const loan_asset_allowance_nat = loan_asset_allowance_response.allowance;
    const loan_asset_allowance_float = Number(loan_asset_allowance_nat) / 10**Number(token.decimals);
    // console.log(collateral_allowance);
    // console.log(collateral_allowance_float);
    // alert(collateral_allowance.allowance);
    if (loan_asset_allowance_float < amount) {
      return false;
    } else {
      return true;
    }
  }


</script>

{notification}

<div class="flex justify-center items-center w-full min-h-screen px-5 py-5">
  <div class="xl:max-w-7xl drop-shadow-xl border border-black/20 w-full rounded-md flex justify-between items-stretch px-5 xl:px-5 py-5">
    <div class="mx-auto w-full lg:w-1/2 md:p-10 py-5 md:py-0">
      <h1 class="text-center text-2xl sm:text-3xl font-semibold text-secondary">Create Loan Offer</h1>

      <h2 class="text-left text-xl sm:text-xl font-semibold text-info">Loan Request Terms: </h2>
      <form id="LoanRequestForm" class="w-full mt-5 sm:mt-8" onsubmit={loanRequestSubmit}>
        <div class="mx-auto w-full sm:max-w-md md:max-w-lg flex flex-col gap-5">
          <!-- Collateral Canister ID Input -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">Collateral</span>
            </label>
            <!-- <input -->
            <!--   type="text" -->
            <!--   name="collateral_canister_id" -->
            <!--   placeholder="Enter canister ID" -->
            <!--   class="input input-bordered input-primary w-full max-w-xs" -->
            <!--   required -->
            <!-- /> -->
            <div class="filter">
              <input disabled id="icp-btn" bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="ryjl3-tyaaa-aaaaa-aaaba-cai" aria-label="ICP" required />
              {#if (process.env.DFX_NETWORK !== "ic")}
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="llcdy-4qaaa-aaaah-arcua-cai" aria-label="TPAWN" required />
              {/if}
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="mxzaz-hqaaa-aaaar-qaada-cai" aria-label="ckBTC" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="ss2fx-dyaaa-aaaar-qacoq-cai" aria-label="ckETH" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="xevnm-gaaaa-aaaar-qafnq-cai" aria-label="ckUSDC" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="kylwo-viaaa-aaaaq-aae7a-cai" aria-label="TENDY" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="hvgxa-wqaaa-aaaaq-aacia-cai" aria-label="SNEED" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="rh2pm-ryaaa-aaaan-qeniq-cai" aria-label="EXE" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="pcj6u-uaaaa-aaaak-aewnq-cai" aria-label="CLOUD" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="7pail-xaaaa-aaaas-aabmq-cai" aria-label="BOB" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="2ouva-viaaa-aaaaq-aaamq-cai" aria-label="CHAT" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="iwv6l-6iaaa-aaaal-ajjjq-cai" aria-label="CLOWN" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="zfcdd-tqaaa-aaaaq-aaaga-cai" aria-label="DKP" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="6c7su-kiaaa-aaaar-qaira-cai" aria-label="GLDT" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="buwm7-7yaaa-aaaar-qagva-cai" aria-label="nICP" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="7xkvf-zyaaa-aaaal-ajvra-cai" aria-label="PARTY" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="i2s4q-syaaa-aaaan-qz4sq-cai" aria-label="sGLDT" required />
            </div>
          </div>

          <!-- Collateral Amount Input -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">Collateral Amount</span>
            </label>
            <input
              value={(Number(collateral_amount) / 10**Number(collateral_token?.decimals)) || collateral_amount + " nat"}
              type="text"
              name="collateral_amount"
              placeholder="Enter amount"
              class="input input-bordered input-primary w-full max-w-xs"
              required
              disabled
            />
          </div>

          <div id="desiredAssets" class="form-control">
            <label class="label" for="desired_asset_canister_ids">
              <span class="label-text">Desired Asset: </span>
            </label>
              {#if desired_assets.length < 1}
                <span>Any</span>
              {/if}
            <!-- single text input for debugging -->
            <!-- <input -->
            <!--   type="text" -->
            <!--   name="desired_asset_canister_ids" -->
            <!--   id="desired_asset_canister_ids" -->
            <!--   placeholder="Enter desired asset canister IDs" -->
            <!--   class="input input-bordered input-primary w-full max-w-xs" -->
            <!---->
            <!-- /> -->

            <!-- proof of concept multiple checkboxes -->
          <!--   <label> -->
          <!--   <input -->
          <!--     type="checkbox" -->
          <!--     placeholder="Enter desired asset canister IDs" -->
          <!--     name="desired_asset_canister_ids_any" -->
          <!--     class="checkbox" -->
          <!--     onclick={(el)=>{console.log(el); -->
          <!--       console.log(LoanRequestForm.desired_asset_canister_ids); -->
          <!--       LoanRequestForm.desired_asset_canister_ids.forEach(function(checkbox) { -->
          <!--         checkbox.checked = false; -->
          <!--       }); -->
          <!--     }} -->
          <!--   /> Any</label> -->
          <!--   <label> -->
          <!--   <input -->
          <!--     type="checkbox" -->
          <!--     name="desired_asset_canister_ids" -->
          <!--     id="desired_asset_canister_ids" -->
          <!--     value="ryjl3-tyaaa-aaaaa-aaaba-cai" -->
          <!--     placeholder="Enter desired asset canister IDs" -->
          <!--     class="checkbox" -->
          <!--     onclick={()=>{ -->
          <!--       LoanRequestForm.desired_asset_canister_ids_any.checked = false; -->
          <!--     }} -->
          <!---->
          <!--   /> ICP</label> -->
          <!--   <label> -->
          <!--   <input -->
          <!--     type="checkbox" -->
          <!--     name="desired_asset_canister_ids" -->
          <!--     value="llcdy-4qaaa-aaaah-arcua-cai" -->
          <!--     placeholder="Enter desired asset canister IDs" -->
          <!--     class="checkbox" -->
          <!--     onclick={()=>{ -->
          <!--       LoanRequestForm.desired_asset_canister_ids_any.checked = false; -->
          <!--     }} -->
          <!---->
          <!--   /> TPAWN</label> -->
          <!-- </div> -->
          <!---->
          <!-- svelte-ignore a11y_click_events_have_key_events, a11y_no_static_element_interactions (because of reasons) -->
          <!-- <span class="btn" role="button" tabindex="0" -->
          <!--       onclick={()=> { -->
          <!--       LoanRequestForm.desired_asset_canister_ids_any.checked = false; -->
          <!--       var checkbox = document.createElement('input'); -->
          <!--         checkbox.type = 'checkbox'; -->
          <!--         checkbox.name = 'desired_asset_canister_ids'; -->
          <!--         checkbox.value = 'llcdy-4qaaa-aaaah-arcua-cai'; -->
          <!--         checkbox.id = 'checkbox1'; -->
          <!--         checkbox.className = 'checkbox'; -->
          <!--         checkbox.checked = true; -->
          <!--         checkbox.onclick = () => {LoanRequestForm.desired_asset_canister_ids_any.checked = false}; -->
          <!---->
          <!--         desiredAssets.append(checkbox); -->
          <!--       var input = document.createElement('input'); -->
          <!--         input.type = 'text'; -->
          <!--         input.name = 'desired_asset_canister_ids_input'; -->
          <!--         input.value = 'llcdy-4qaaa-aaaah-arcua-cai'; -->
          <!--         input.id = 'input1'; -->
          <!--         input.className = 'input'; -->
          <!--         desiredAssets.append(input); }} -->
          <!--   >+ Asset -->
          <!-- </span> -->

              {#if desired_assets.length > 0}
              <!-- use filter to enforce max 1 desired asset -->
              <!-- <div> -->
              <div class="filter">
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="ryjl3-tyaaa-aaaaa-aaaba-cai" aria-label="ICP" />
              {#if (process.env.DFX_NETWORK !== "ic")}
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="llcdy-4qaaa-aaaah-arcua-cai" aria-label="TPAWN" />
              {/if}
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="mxzaz-hqaaa-aaaar-qaada-cai" aria-label="ckBTC" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="ss2fx-dyaaa-aaaar-qacoq-cai" aria-label="ckETH" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="xevnm-gaaaa-aaaar-qafnq-cai" aria-label="ckUSDC" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="kylwo-viaaa-aaaaq-aae7a-cai" aria-label="TENDY" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="hvgxa-wqaaa-aaaaq-aacia-cai" aria-label="SNEED" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="rh2pm-ryaaa-aaaan-qeniq-cai" aria-label="EXE" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="pcj6u-uaaaa-aaaak-aewnq-cai" aria-label="CLOUD" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="7pail-xaaaa-aaaas-aabmq-cai" aria-label="BOB" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="2ouva-viaaa-aaaaq-aaamq-cai" aria-label="CHAT" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="iwv6l-6iaaa-aaaal-ajjjq-cai" aria-label="CLOWN" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="zfcdd-tqaaa-aaaaq-aaaga-cai" aria-label="DKP" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="6c7su-kiaaa-aaaar-qaira-cai" aria-label="GLDT" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="buwm7-7yaaa-aaaar-qagva-cai" aria-label="nICP" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="7xkvf-zyaaa-aaaal-ajvra-cai" aria-label="PARTY" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="i2s4q-syaaa-aaaan-qz4sq-cai" aria-label="sGLDT" />
            </div>
            {/if}
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Desired Amount: </span>
            </label>
            {#if desired_assets.length > 0}
              {#if desired_amount_nat === null}
                <span>Any</span>
              {:else}
                <div class="join">
                  <input
                    type="text"
                    value={Number(desired_amount_nat) / 10**Number(desired_token?.decimals) || desired_amount_nat + " nat"}
                    name="desired_amounts"
                    id="desired_amounts"
                    placeholder="Enter desired asset amount (optional)"
                    class="input input-bordered input-primary w-full max-w-xs"
                    disabled

                  />
                  <label for="desired_amounts" class={["label input join-item", (desired_token?.metadata instanceof(Error)) ? "text-error" : ""]}>
                    {desired_token?.symbol || "Unknown"}</label>
                </div>
              {/if}
            {:else}
              <span>Any</span>
            {/if}
          </div>

          <!-- Duration Input -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">Duration (days)</span>
            </label>
            {#if desired_duration }
              <input
                type="number"
                name="desired_duration"
                placeholder="Enter duration in days"
                class="input input-bordered input-primary w-full max-w-xs"
                bind:value={desired_duration}
                disabled
              />
            {:else}
              <span>Any</span>
            {/if}
          </div>

          <!-- Interest Input -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">Desired Interest: </span>
            </label>
            {#if desired_interest }
              <input
                type="number"
                step="0.01"
                name="desired_interest"
                placeholder="Enter interest"
                class="input input-bordered input-primary w-full max-w-xs"
                bind:value={desired_interest}
                disabled

              />
            {:else}
              <span>Any</span>
            {/if}
          </div>
        </div>
      </form>


          <!-- New Loan Offer Inputs -->
          <div class="mt-8 border-t pt-6">
            <h2 class="text-left text-xl sm:text-xl font-semibold text-secondary">Loan Offer Terms: </h2>
            <form id="LoanOfferForm" class="w-full mt-5 sm:mt-8" onsubmit={createLoanOffer}>
            <div class="form-control mb-2">
              <label class="label">
                <span class="label-text">Loan Asset</span>
              </label>
              <!-- <input -->
              <!--   bind:value={loan_asset_canister_id} -->
              <!--   type="text" -->
              <!--   name="loan_asset_canister_id" -->
              <!--   placeholder="Enter canister ID" -->
              <!--   class="input input-bordered input-primary w-full max-w-xs" -->
              <!--   required -->
              <!-- /> -->
            <div class="filter">
              <input class="btn btn-square filter-reset" type="radio" name="loan_asset_canister_id" value="×" aria-label="×" 
                onclick={() => {
                      loan_asset_canister_id = null;
                    }}
                />
              <input id="icp-btn" bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="ryjl3-tyaaa-aaaaa-aaaba-cai" aria-label="ICP" required />
              {#if (process.env.DFX_NETWORK !== "ic")}
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="llcdy-4qaaa-aaaah-arcua-cai" aria-label="TPAWN" required />
              {/if}
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="mxzaz-hqaaa-aaaar-qaada-cai" aria-label="ckBTC" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="xevnm-gaaaa-aaaar-qafnq-cai" aria-label="ckUSDC" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="hvgxa-wqaaa-aaaaq-aacia-cai" aria-label="SNEED" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="7pail-xaaaa-aaaas-aabmq-cai" aria-label="BOB" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="buwm7-7yaaa-aaaar-qagva-cai" aria-label="nICP" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="ss2fx-dyaaa-aaaar-qacoq-cai" aria-label="ckETH" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="zfcdd-tqaaa-aaaaq-aaaga-cai" aria-label="DKP" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="pcj6u-uaaaa-aaaak-aewnq-cai" aria-label="CLOUD" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="iwv6l-6iaaa-aaaal-ajjjq-cai" aria-label="CLOWN" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="2ouva-viaaa-aaaaq-aaamq-cai" aria-label="CHAT" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="6c7su-kiaaa-aaaar-qaira-cai" aria-label="GLDT" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="i2s4q-syaaa-aaaan-qz4sq-cai" aria-label="sGLDT" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="7xkvf-zyaaa-aaaal-ajvra-cai" aria-label="PARTY" required />
              <input bind:group={loan_asset_canister_id} class="btn" type="radio" name="loan_asset_canister_id" value="rh2pm-ryaaa-aaaan-qeniq-cai" aria-label="EXE" required />
            </div>

            </div>


          {#if loan_asset_canister_id}
            <span class={[(loan_amount > wallet.icrc1_balance(loan_asset_canister_id)) && "text-warning"]}>Balance: {wallet.icrc1_balance(loan_asset_canister_id)}</span>
          {/if}

            <div class="form-control mb-2">
              <label class="label">
                <span class="label-text">Loan Amount</span>
              </label>
              <input
                bind:value={loan_amount}
                type="number"
                step="0.00000001"
                name="loan_amount"
                placeholder="Enter loan amount"
                class="input input-bordered input-primary w-full max-w-xs validator"
                required
              />
            </div>
            <div class="form-control mb-2">
              <label class="label">
                <span class="label-text">Duration (days)</span>
              </label>
              <input
                bind:value={offer_duration}
                type="number"
                min="1"
                name="offer_duration"
                placeholder="Enter duration in days"
                class="input input-bordered input-primary w-full max-w-xs validator"
                required
              />
            </div>
            <div class="form-control mb-2">
              <label class="label">
                <span class="label-text">Interest (%)</span>
              </label>
              <input
                bind:value={offer_interest}
                type="number"
                step="0.01"
                min="0.10"
                name="offer_interest"
                placeholder="Enter interest"
                class="input input-bordered input-primary w-full max-w-xs validator"
                required
              />
            </div>

            <!-- approve asset before create loan offer -->
            <!-- TODO different check for logged in probably auth.loggedIn because wallet.principal causes refresh when open wallet -->
            {#if loan_asset_token && loan_amount && wallet?.principal}
            <!-- {#await validateICRC2Allowance(loan_asset_canister_id, wallet.principal, loan_amount)} -->
            {#await allowance_bool }
              <span class="loading loading-ring loading-xs"></span>
              Validating allowance...
            {:then isTokenAllowed}
              <span class={"align-[0.05em] status status-" + (isTokenAllowed ? "success" : "warning") }></span>
              {loan_asset_token.symbol}
              Allowance

              <input class="validator hidden" checked={isTokenAllowed} type="checkbox" name="allowance" id="allowance" required />
              <span class="validator-hint hidden">Required: Must approve allowance</span>

              {#if !isTokenAllowed}
                <br>
                <button 
                  type="button"
                  onclick={async (e) => {
                    e.target.disabled = true;
                    console.log(e);
                    // TODO dynamic amount
                    const supply = await wallet.icrc1_total_supply(loan_asset_token.canister_id);
                    await wallet.icrc2_approve(loan_asset_token.canister_id, supply )
                    // TODO less hacky method to refresh allowance validation
                    // const stash_loan_amount = loan_amount;
                    // loan_amount = undefined;
                    // loan_amount = stash_loan_amount;
                    allowance_bool = validateICRC2Allowance(loan_asset_canister_id, wallet.principal, loan_amount);
                    // loan_asset_token = loan_asset_token;
                    wallet.refreshWatchedICRC1Tokens();
                  } }
                  class="btn btn-success"
                >Approve</button>
              <span>Cost: </span>
              <span>{loan_asset_token.fee / 10**loan_asset_token.decimals}  {loan_asset_token.symbol}</span>
              {/if}

            {:catch error}
              Error validating allowance
              {error}
            {/await}
            {:else}
              <input class="validator hidden" checked={false} type="checkbox" name="allowance" id="allowance" required />
              <span class="validator-hint hidden">Error: Token unrecognized: {loan_asset_canister_id}</span>
              {#await wallet.getPrincipal()}{/await}
            {/if}

            <!-- <div class="form-control"> -->
            <!--   <button  -->
            <!--     onclick={async(e)=> { e.preventDefault(); await invalidateAll();}} -->
            <!--     type="reset" class="btn btn-warning mt-2"> -->
            <!--     Reset -->
            <!--   </button> -->
            <!-- </div> -->


              <!-- disabled={allowance_bool == false} -->
            <div class="form-control">
              <button 
                type="submit" class="btn btn-primary mt-2">
                Create Loan Offer
              </button>
            </div>

          </form>
        </div>


        </div>
    </div>
  </div>

