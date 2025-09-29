<script lang="ts">
  // Add any necessary script logic here
  // import { page } from '$app/stores';
  import { invalidate } from '$app/navigation';
  import { backend } from "$lib/canisters";
  import { Principal } from "@dfinity/principal";
  import { wallet } from '$lib/components/WalletBar.svelte';
  // import { Icrc1Tokens } from '$lib/Icrc1Tokens.svelte';
  import { refreshAllICRC1Tokens} from '$lib/Icrc1Tokens.svelte';

  let { showLoanRequestForm = $bindable() } = $props();
  let notification = $state("");
  let desired_assets = $state([]);
  let selectedCollateralId = $state("");
  let collateral_amount : Number | undefined = $state();
  let collateral_token = $derived(wallet.icrc1_tokens.find(token => token.canister_id === selectedCollateralId));
  let desired_token = $derived(wallet.icrc1_tokens.find(token => token.canister_id === desired_assets[0]));
  refreshAllICRC1Tokens();

  function loanRequestSubmit(event : Event) {
    event.preventDefault();
    try {
    if (!event.target) throw "Error: Form not found";
    let form = event.currentTarget as HTMLFormElement;
    if (!collateral_token) throw "Collateral Token not found";

    // console.log(event.target.collateral_canister_id);
    // console.log(form.collateral_canister_id.value);
    // console.log(typeof(event.target.collateral_canister_id));
    // console.log(event);
    const collateral_canister_id = Principal.fromText(form.collateral_canister_id.value);
    const collateral_amount = Number(form.collateral_amount.value);
    const collateral_amount_nat = Math.floor(collateral_amount*10**Number(collateral_token.decimals));
    // const desired_asset_canister_ids = event.target.desired_asset_canister_ids.value;
    // const desired_asset_canister_ids = [Principal.fromText(event.target.desired_asset_canister_ids.value)];

    // var desired_asset_canister_ids = [];
    // if (event.target.desired_asset_canister_ids.checked == true) {
    //   desired_asset_canister_ids = [Principal.fromText(event.target.desired_asset_canister_ids.value)];
    // }

    // TODO support multiple desired assets
    const desired_asset_canister_ids : Principal[] = Array.from(form.desired_asset_canister_ids)
      .filter((radio): radio is HTMLInputElement => (radio as HTMLInputElement).checked)
      .map(radio => Principal.fromText(radio.value));

    // const desired_amounts = event.target.desired_amounts.value;
    // const desired_amounts = [event.target.desired_amounts.value];
    var desired_amounts : (Principal | BigInt)[][] = [];
    var desired_amount_nat;
    if (desired_assets.length > 0 && form.desired_amounts.value.length > 0) {
      desired_amount_nat = Math.floor(form.desired_amounts.value*10**Number(desired_token?.decimals));
      desired_amounts = [[Principal.fromText(desired_assets[0]), BigInt(desired_amount_nat)]];
    }
    const desired_duration = Number(form.desired_duration.value);
    const desired_interest = Number(form.desired_interest.value);

    backend.loanRequestNew(
        collateral_canister_id,
        collateral_amount_nat,
        desired_asset_canister_ids,
        desired_amounts,
        desired_duration,
        desired_interest,
    ).catch((error: unknown) => {
      console.log(error);
      if (error instanceof Error) {
        notification = error.message;
        throw(error);
      } else {
        console.log('Unexpected error:', error);
        // notification = 'Unexpected error: ' + error;
        notification = 'Unexpected error';
      }
    }).then((response : BigInt) => {
      // console.log(response);
      notification = `Success: Created new Loan Request: <a href="/loan-requests/${response}">#${response}</a>`;
      window.scrollTo({ top: 0, left: 0, behavior: 'smooth' });
      form.reset();
      invalidate('app:loanrequests');
      showLoanRequestForm = false;
    });
    return false;
    } catch(error : unknown) {
      if (error instanceof Error) {
        notification = error.message;
        throw error;
      } else {
        console.log('Unexpected error:', error);
        // notification = 'Unexpected error: ' + error;
        notification = 'Unexpected error';
      }
    }
  }

  $effect(() => {
      // console.log('effect');
      // console.log('collateral changed:', selectedCollateralId);
      if (selectedCollateralId) {
        wallet.addICRC1Token(selectedCollateralId);

        // TODO this is sloppy bro but wtv keep going
        // if (!Icrc1Tokens.find((token) => token.canister_id === selectedCollateralId)) {
        //   // Icrc1Tokens.push({canister_id: selectedCollateralId});
        //   Icrc1Tokens.unshift({canister_id: selectedCollateralId});
        //   refreshAllICRC1Tokens();
        // }
      }
  });

  $effect(() => {
      // console.log('effect');
      // console.log('collateral changed:', selectedCollateralId);
      if (desired_assets[0]) {
        wallet.addICRC1Token(desired_assets[0] );
      }
  });

</script>

{#if notification}
  <div role="alert" class="alert">
  <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
  </svg>
    <span>{@html notification}</span>
  </div>
{/if}
<!-- {greeting} -->
<!-- {desired_assets} -->

<!-- <button onclick={()=>alert(`${Icrc1Tokens[0].canister_id} ${Icrc1Tokens[0].decimals}`)}>ICRC1Token Info</button> -->

<!-- <div class="flex justify-center items-center w-full min-h-screen px-5 py-5"> -->
<div class="justify-center items-center w-full px-5 py-5">
  <!-- <div class="xl:max-w-7xl drop-shadow-xl border border-black/20 w-full rounded-md flex justify-between items-stretch px-5 xl:px-5 py-5"> -->
  <div class="xl:max-w-7xl drop-shadow-xl border border-black/20 w-full rounded-md justify-between items-stretch px-5 xl:px-5 py-5">
    <div class="mx-auto w-full lg:w-1/2 md:p-10 py-5 md:py-0">
      <h1 class="text-center text-2xl sm:text-3xl font-semibold text-[#4A07DA]">Create Loan Request</h1>
      <form id="LoanRequestForm" class="w-full mt-5 sm:mt-8" onsubmit={loanRequestSubmit}>
        <div class="mx-auto w-full sm:max-w-md md:max-w-lg flex flex-col gap-5">
          <!-- Collateral Canister ID Input -->
          <div class="form-control">
            <label for="collateral_canister_id" class="label">
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
              <input id="collateral_canister_id" class="btn btn-square filter-reset validator" type="radio" name="collateral_canister_id" value="×" aria-label="×" 
                bind:group={selectedCollateralId}
                onclick={() => {
                      selectedCollateralId = "";
                    }}
                required />
              <div class="validator-hint hidden">Required</div>
              <input bind:group={selectedCollateralId} id="icp-btn" class="btn validator" type="radio" name="collateral_canister_id" value="ryjl3-tyaaa-aaaaa-aaaba-cai" aria-label="ICP" required />
              {#if (process.env.DFX_NETWORK !== "ic")}
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="llcdy-4qaaa-aaaah-arcua-cai" aria-label="TPAWN" required />
              {/if}
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="mxzaz-hqaaa-aaaar-qaada-cai" aria-label="ckBTC" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="xevnm-gaaaa-aaaar-qafnq-cai" aria-label="ckUSDC" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="hvgxa-wqaaa-aaaaq-aacia-cai" aria-label="SNEED" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="7pail-xaaaa-aaaas-aabmq-cai" aria-label="BOB" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="buwm7-7yaaa-aaaar-qagva-cai" aria-label="nICP" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="ss2fx-dyaaa-aaaar-qacoq-cai" aria-label="ckETH" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="zfcdd-tqaaa-aaaaq-aaaga-cai" aria-label="DKP" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="pcj6u-uaaaa-aaaak-aewnq-cai" aria-label="CLOUD" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="iwv6l-6iaaa-aaaal-ajjjq-cai" aria-label="CLOWN" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="2ouva-viaaa-aaaaq-aaamq-cai" aria-label="CHAT" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="6c7su-kiaaa-aaaar-qaira-cai" aria-label="GLDT" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="i2s4q-syaaa-aaaan-qz4sq-cai" aria-label="sGLDT" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="7xkvf-zyaaa-aaaal-ajvra-cai" aria-label="PARTY" required />
              <input bind:group={selectedCollateralId} class="btn" type="radio" name="collateral_canister_id" value="rh2pm-ryaaa-aaaan-qeniq-cai" aria-label="EXE" required />
            </div>
          </div>

          <!-- Collateral Balance -->
          <!-- {wallet.icrc1_tokens[0].symbol} {wallet.icrc1_tokens[0].balance}  -->
          {#if selectedCollateralId}
            <!-- TODO account for fees -->
            <span class={[((collateral_amount ?? 0) > (wallet.icrc1_balance(selectedCollateralId) ?? 0) ) && "text-warning"]}>Balance: {wallet.icrc1_balance(selectedCollateralId)}</span>
            <!-- <span>{wallet.refreshICRC1Token(selectedCollateralId)}</span> -->

            {#if (collateral_token?.metadata instanceof(Error))}
              <span class="badge badge-error">Error loading token</span>
            {/if}

          <!-- Collateral Amount Input -->
          <div class="form-control">
            <label for="collateral_amount" class="label">
              <span class="label-text">Collateral Amount</span>
            </label>

            <div class="join">
            <input
              type="number"
              bind:value={collateral_amount}
              id="collateral_amount"
              name="collateral_amount"
              step="0.00000001"
              placeholder="Enter amount"
              class="input input-bordered input-primary w-full max-w-xs join-item validator"
              required
            />
            <!-- {console.log(collateral_token)} -->
            <!-- {console.log(collateral_token?.metadata?.constructor.name)} -->
            <!-- <label for="collateral_amount" class={["input join-item", collateral_token?.metadata?.constructor.name === '_RejectError' ? "text-error" : ""]}> -->
            <label for="collateral_amount" class={["input join-item", (collateral_token?.metadata instanceof(Error)) ? "text-error" : ""]}>
              {collateral_token?.symbol || "Unknown"}</label>
            </div>
          </div>
          {/if}

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
                onclick={() => {
                      desired_assets = [];
                      // LoanRequestForm.desired_asset_canister_ids.forEach(function(checkbox) {
                        // checkbox.checked = false;
                      // });
                    }}
                />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="ryjl3-tyaaa-aaaaa-aaaba-cai" aria-label="ICP" />
              {#if (process.env.DFX_NETWORK !== "ic")}
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="llcdy-4qaaa-aaaah-arcua-cai" aria-label="TPAWN" />
              {/if}
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="mxzaz-hqaaa-aaaar-qaada-cai" aria-label="ckBTC" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="xevnm-gaaaa-aaaar-qafnq-cai" aria-label="ckUSDC" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="hvgxa-wqaaa-aaaaq-aacia-cai" aria-label="SNEED" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="7pail-xaaaa-aaaas-aabmq-cai" aria-label="BOB" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="buwm7-7yaaa-aaaar-qagva-cai" aria-label="nICP" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="ss2fx-dyaaa-aaaar-qacoq-cai" aria-label="ckETH" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="zfcdd-tqaaa-aaaaq-aaaga-cai" aria-label="DKP" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="pcj6u-uaaaa-aaaak-aewnq-cai" aria-label="CLOUD" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="iwv6l-6iaaa-aaaal-ajjjq-cai" aria-label="CLOWN" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="2ouva-viaaa-aaaaq-aaamq-cai" aria-label="CHAT" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="6c7su-kiaaa-aaaar-qaira-cai" aria-label="GLDT" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="i2s4q-syaaa-aaaan-qz4sq-cai" aria-label="sGLDT" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="7xkvf-zyaaa-aaaal-ajvra-cai" aria-label="PARTY" />
              <input bind:group={desired_assets} class="btn" type="checkbox" name="desired_asset_canister_ids" value="rh2pm-ryaaa-aaaan-qeniq-cai" aria-label="EXE" />
            </div>
          </div>

          <div class="form-control">
            <label for="desired_amounts" class="label">
              <span class="label-text">Desired Amount: </span>
            </label>
            {#if desired_assets.length > 0}
              {#if (desired_token?.metadata instanceof(Error))}
                <span class="badge badge-error">Error loading token</span>
              {/if}

              <div class="join">
              <input
                type="number"
                step="0.00000001"
                name="desired_amounts"
                id="desired_amounts"
                placeholder="Enter desired asset amount (optional)"
                class="input input-bordered input-primary w-full max-w-xs join-item validator"

              />
                <label for="desired_amounts" class={["input join-item", (desired_token?.metadata instanceof(Error)) ? "text-error" : ""]}>
                 {desired_token?.symbol || "Unknown"}</label>
              </div>
            {:else}
              <span>Any</span>
            {/if}
          </div>

          <!-- Duration Input -->
          <div class="form-control">
            <label for="desired_duration" class="label">
              <span class="label-text">Duration (days)</span>
            </label>
            <input
              type="number"
              name="desired_duration"
              id="desired_duration"
              placeholder="Enter duration in days"
              class="input input-bordered input-primary w-full max-w-xs validator"

            />
            <label for="desired_duration" class="label validator-hint hidden">
              <div>Whole number of days</div>
            </label>
          </div>

          <!-- Interest Input -->
          <div class="form-control">
            <label for="desired_interest" class="label">
              <span class="label-text">Interest</span>
            </label>
            <input
              type="number"
              step="0.01"
              id="desired_interest"
              name="desired_interest"
              placeholder="Enter interest"
              class="input input-bordered input-primary w-full max-w-xs"

            />
          </div>

          <!-- Submit Button -->
          <div class="flex flex-col md:flex-row gap-2 md:gap-4 justify-center items-center">
            <button type="submit" class="btn btn-active btn-primary btn-block max-w-[200px]"
              disabled={!(collateral_token?.metadata instanceof(Array)) || (desired_token && !(desired_token?.metadata instanceof(Array)))}
              >
              <!-- disabled={(collateral_token?.metadata instanceof(Error)) || (desired_token?.metadata instanceof(Error))} -->
              Submit
            </button>
            <!-- <button type="reset" class="btn btn-outline btn-primary btn-block max-w-[200px]"> -->
            <!--   Reset -->
            <!-- </button> -->
          </div>
        </div>
      </form>
    </div>
  </div>
</div>   

