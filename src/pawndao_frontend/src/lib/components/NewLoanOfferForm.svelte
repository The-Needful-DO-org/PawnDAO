<script lang="ts">
  // Add any necessary script logic here
  // import { page } from '$app/stores';
  import { backend } from "$lib/canisters";
  import { Principal } from "@dfinity/principal";
  import { wallet } from '$lib/components/WalletBar.svelte';
  const { loan_request  } = $props();

  let greeting = $state("");
  let notification = $state("");
  let desired_assets = $state([]);
  let desired_amounts = $state(loan_request.desired_amounts.length > 0 ? loan_request.desired_amounts : [[]]);
  // TODO support multiple desired amounts
  let desired_amount = $state((desired_amounts[0][1] || null));
  let collateral_canister_id = $state(loan_request.collateral_canister_id.toString());
  let collateral_amount = $state(loan_request.collateral_amount);
  let collateral_token = $derived(wallet.icrc1_tokens.find(token => token.canister_id === collateral_canister_id));
  let desired_duration = $state(loan_request.desired_duration);
  let desired_interest = $state(loan_request.desired_interest);
  try {
    desired_assets = loan_request.desired_asset_canister_ids.map((principal)=>{return (principal?.toString() || "")});
    } catch { 
    desired_assets = [];
    }
  let loan_asset_canister_id = $state(desired_assets[0]);
  // let loan_asset_canister_id = $state();

  let loan_amount = $state(desired_amount);
  let offer_duration =$state(desired_duration);
  let offer_interest =$state(desired_interest);

  function loanRequestSubmit(event) {
    event.preventDefault();
    // console.log(event.target.collateral_canister_id);
    // console.log(typeof(event.target.collateral_canister_id));
    console.log(event);
    const collateral_canister_id = Principal.fromText(event.target.collateral_canister_id.value);
    const collateral_amount = Number(event.target.collateral_amount.value);
    // const desired_asset_canister_ids = event.target.desired_asset_canister_ids.value;
    // const desired_asset_canister_ids = [Principal.fromText(event.target.desired_asset_canister_ids.value)];

    // var desired_asset_canister_ids = [];
    // if (event.target.desired_asset_canister_ids.checked == true) {
    //   desired_asset_canister_ids = [Principal.fromText(event.target.desired_asset_canister_ids.value)];
    // }

    const desired_asset_canister_ids = Array.from(event.target.desired_asset_canister_ids)
      .filter(radio => radio.checked)
      .map(radio => Principal.fromText(radio.value));

    // const desired_amounts = event.target.desired_amounts.value;
    // const desired_amounts = [event.target.desired_amounts.value];
    var desired_amounts = [];
    if (desired_assets.length > 0 && event.target.desired_amounts.value.length > 0) {
      desired_amounts = [[Principal.fromText(desired_assets[0]), BigInt(event.target.desired_amounts.value)]];
    }
    const desired_duration = Number(event.target.desired_duration.value);
    const desired_interest = Number(event.target.desired_interest.value);
    backend.loanRequestNew(
        collateral_canister_id,
        collateral_amount,
        desired_asset_canister_ids,
        desired_amounts,
        desired_duration,
        desired_interest,
    ).catch((error) => {
      console.log(error);
      notification = error;
    }).then((response) => {
      greeting = response;
    });
    return false;
  }

// Add this function to handle loanOfferNew
  async function createLoanOffer() {
    const form = document.getElementById("LoanOfferForm");
    const loan_request_id = loan_request.id;
    const loan_asset_canister_id = Principal.fromText(form.loan_asset_canister_id.value);
    const loan_asset_token = wallet.icrc1_tokens.find(token => token.canister_id === loan_asset_canister_id.toString() );
    const loan_amount = Number(form.loan_amount.value);
    const loan_amount_nat = loan_amount * 10**Number(loan_asset_token.decimals);
    const duration = Number(form.offer_duration.value);
    const interest = Number(form.offer_interest.value);
    try {
      const offer = await backend.loanOfferNew(
        loan_request_id,
        loan_asset_canister_id,
        loan_amount_nat,
        duration,
        interest
      );
      notification = "Loan offer created!";
      // greeting = JSON.stringify(offer);
    } catch (e) {
      notification = "Error creating loan offer: " + e;
    }
  }
</script>

{notification}
{greeting}

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
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="mxzaz-hqaaa-aaaar-qaada-cai" aria-label="ckBTC" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="xevnm-gaaaa-aaaar-qafnq-cai" aria-label="ckUSDC" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="hvgxa-wqaaa-aaaaq-aacia-cai" aria-label="SNEED" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="7pail-xaaaa-aaaas-aabmq-cai" aria-label="BOB" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="buwm7-7yaaa-aaaar-qagva-cai" aria-label="nICP" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="ss2fx-dyaaa-aaaar-qacoq-cai" aria-label="ckETH" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="zfcdd-tqaaa-aaaaq-aaaga-cai" aria-label="DKP" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="pcj6u-uaaaa-aaaak-aewnq-cai" aria-label="CLOUD" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="iwv6l-6iaaa-aaaal-ajjjq-cai" aria-label="CLOWN" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="2ouva-viaaa-aaaaq-aaamq-cai" aria-label="CHAT" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="6c7su-kiaaa-aaaar-qaira-cai" aria-label="GLDT" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="i2s4q-syaaa-aaaan-qz4sq-cai" aria-label="sGLDT" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="7xkvf-zyaaa-aaaal-ajvra-cai" aria-label="PARTY" required />
              <input disabled bind:group={collateral_canister_id} class="btn" type="radio" name="collateral_canister_id" value="rh2pm-ryaaa-aaaan-qeniq-cai" aria-label="EXE" required />
            </div>
          </div>

          <!-- Collateral Amount Input -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">Collateral Amount</span>
            </label>
            <input
              value={Number(collateral_amount) / 10**Number(collateral_token.decimals)}
              type="number"
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

              <!-- use filter to enforce max 1 desired asset -->
              <!-- <div> -->
              <div class="filter">
                <input class="btn btn-square filter-reset" type="button" name="reset_desired_asset_canister_ids" value="×" aria-label="×"
                disabled
                onclick={() => {
                      desired_assets = [];
                      // LoanRequestForm.desired_asset_canister_ids.forEach(function(checkbox) {
                        // checkbox.checked = false;
                      // });
                    }}
                />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="ryjl3-tyaaa-aaaaa-aaaba-cai" aria-label="ICP" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="mxzaz-hqaaa-aaaar-qaada-cai" aria-label="ckBTC" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="xevnm-gaaaa-aaaar-qafnq-cai" aria-label="ckUSDC" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="hvgxa-wqaaa-aaaaq-aacia-cai" aria-label="SNEED" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="7pail-xaaaa-aaaas-aabmq-cai" aria-label="BOB" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="buwm7-7yaaa-aaaar-qagva-cai" aria-label="nICP" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="ss2fx-dyaaa-aaaar-qacoq-cai" aria-label="ckETH" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="zfcdd-tqaaa-aaaaq-aaaga-cai" aria-label="DKP" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="pcj6u-uaaaa-aaaak-aewnq-cai" aria-label="CLOUD" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="iwv6l-6iaaa-aaaal-ajjjq-cai" aria-label="CLOWN" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="2ouva-viaaa-aaaaq-aaamq-cai" aria-label="CHAT" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="6c7su-kiaaa-aaaar-qaira-cai" aria-label="GLDT" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="i2s4q-syaaa-aaaan-qz4sq-cai" aria-label="sGLDT" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="7xkvf-zyaaa-aaaal-ajvra-cai" aria-label="PARTY" />
              <input disabled bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="rh2pm-ryaaa-aaaan-qeniq-cai" aria-label="EXE" />
            </div>
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Desired Amount: </span>
            </label>
            {#if desired_assets.length > 0}
              <input
                type="text"
                bind:value={desired_amount}
                name="desired_amounts"
                placeholder="Enter desired asset amount (optional)"
                class="input input-bordered input-primary w-full max-w-xs"
                disabled

              />
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
                name="loan_amount"
                placeholder="Enter loan amount"
                class="input input-bordered input-primary w-full max-w-xs"
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
                name="offer_duration"
                placeholder="Enter duration in days"
                class="input input-bordered input-primary w-full max-w-xs"
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
                name="offer_interest"
                placeholder="Enter interest"
                class="input input-bordered input-primary w-full max-w-xs"
                required
              />
            </div>
            <button type="button" class="btn btn-primary mt-2" onclick={createLoanOffer}>
              Create Loan Offer
            </button>
          </form>
        </div>


        </div>
    </div>
  </div>

