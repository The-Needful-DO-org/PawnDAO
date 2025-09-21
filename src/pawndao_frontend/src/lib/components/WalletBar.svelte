<script lang="ts">
// import { createActor } from "../../../declarations/cloudpixels_backend";
// import { createActor, canisterId as cloudpixels_backend } from "../../../declarations/cloudpixels_backend";
// import { canisterId as cloudpixels_backend } from "../../../declarations/cloudpixels_backend";
// import {AuthClient} from "@dfinity/auth-client";
import {HttpAgent} from "@dfinity/agent";
import { createAgent } from "@dfinity/utils";

import { onMount } from "svelte";
// import { greeting } from "$lib/greetingstore.svelte.js";

// TODO auth
// import { auth, getIdentityProvider } from "../stores/auth";

import { LedgerCanister, AccountIdentifier } from "@dfinity/ledger-icp";
import { IcrcLedgerCanister } from "@dfinity/ledger-icrc";
import { Principal } from "@dfinity/principal";

// import { tick } from 'svelte';
// import { wallet } from "../stores/wallet.svelte.js";
// import { refreshICPBalance } from "../stores/wallet.svelte.js";
// import { refreshTICPBalance } from "../stores/wallet.svelte.js";
// import { refreshTCLOUDBalance } from "../stores/wallet.svelte.js";
// import { refreshCLOUDBalance } from "../stores/wallet.svelte.js";

// import { getICPUSDRate } from "$lib/../stores/icp_usd_rate.svelte.js";
// import { getCLOUDUSDRater } from "$lib/../stores/icp_usd_rate.svelte.js";
// TODO generic token price rater
// import { getTokenPriceRater } from "$lib/../stores/icp_usd_rate.svelte.js";
// const icp_rater = getICPUSDRate();
// const cloud_rater = getCLOUDUSDRater();
// TODO generic token price rater
// const price_rater = getTokenPriceRater();
// icp_rater.getRate();
// cloud_rater.getRate();

let isWalletBarExpanded = $state(false);
let showAddTokenInput = $state(false);
let isWalletBarEdit = $state(false);

let icrcBalances = $state({});

let walletAddTokenButton = $state.raw<HTMLElement | null>(null);

// helper to parse icrc1_metadata
function valueToJs(v: any): string | number | bigint | Uint8Array {
  if ("Text" in v) return v.Text;
  if ("Nat" in v) return BigInt(v.Nat);
  if ("Int" in v) return BigInt(v.Int);
  if ("Blob" in v) return new Uint8Array(v.Blob);
  return v;
}


  class Wallet {
    data = $state();

    icrc1_tokens = $state([
      {
        canister_id: 'ryjl3-tyaaa-aaaaa-aaaba-cai',
        // symbol: "LICP",
        watched: true
      },
      {
        canister_id: 'nrjl3-tyaaa-aaaaa-aaaba-cai',
        symbol: "NIL",
        watched: true
      },
      {
        canister_id: 'llcdy-4qaaa-aaaah-arcua-cai',
        // symbol: "TPAWN",
        watched: true
      },
      {
        canister_id: 'ryjl3-tyaaa-aaaaa-aaaba-cai',
        symbol: "LICP",
        watched: false
      },
    ]);

    watched_icrc1_tokens = $derived(this.icrc1_tokens.filter(token => token.watched));
 
    refreshWatchedICRC1Tokens = () => {
      this.watched_icrc1_tokens.forEach(async (token) => {
        if (token.metadata === undefined) {
          await icrc1_metadata(token.canister_id).then((metadata) => {
            token.metadata = metadata; 
            const map = new Map<string, any>(metadata.map(([k, v]: [string, any]) => [k, valueToJs(v)]));
            token.symbol = map.get("icrc1:symbol");        // Text -> e.g., "XTKN"
            token.decimals = map.get("icrc1:decimals");    // Nat  -> e.g., 8n
            token.fee = map.get("icrc1:fee");              // Nat  -> e.g., 10000n
          })
          .catch((error) => {console.error(error); });
        }
        // console.log(token.decimals);
        // console.log(token.canister_id);
        // console.log(token.metadata);
        icrc_balance(token.canister_id)
          .then((balance) => {token.balance = Number(balance) / 10**Number(token.decimals); })
          .catch((error) => {console.error(error); token.balance = "Unavailable"; });
        // token.balance = 42069;
      });
    }
   

    // current_game = $derived.by(async () => { return await backend.get_game(this.current_game_id)} );

    // containsUser = $derived(this.data?.seats.some(obj => obj.player[0]?.user_id.toString() === "2vxsx-fae"));
    // containsUser = (user_id) => { return this.data?.seats?.some(obj => obj.user_id.toString() === user_id) };

    // poll_data = () => {
    //   setTimeout( async () => { 
    //     this.get_table();
    //     this.current_game_id = (await backend.get_game_ids_by_table_id(table_id)).at(-1);
    //     if (this.current_game_id != null) {
    //       this.current_game = (await backend.get_game(this.current_game_id))[0];
    //     }
    //     // console.log(Date());
    //     this.poll_data();
    //           // e.target.parentElement.classList.remove("text-black")
    //   }, 2000);
    // }
    
    // // TODO player validation
    // isStartable = $derived(this.current_game?.status === "pending" && this.isShuffling == false);
    // new_game = () => {
    //   this.isNewGameable = false;
    //     // TODO isNewGameable ?
    //     // TODO auth call to backend
    //     backend.create_game(game_table.data.id)
    //       .catch((error) => {
    //         // TODO notification error
    //         // console.log("error");
    //         console.log(error);
    //         throw error;
    //       })
    //       .then((response) => {
    //         // console.log(response);
    //         // console.log(this);
    //         if (typeof(response) === 'bigint')
    //           game_table.current_game_id = response;
    //       })
    //       .then((response) => {
    //         // console.log(response);
    //         game_table.start_game();
    //       });
    // }
    //
    // join = async () => {
    //
    //   // game_table.data = ( await $auth.actor.join_table(game_table.data.id))[0]
    //   $auth.actor.join_table(game_table.data.id)
    //     .catch((error) => {
    //       // TODO notification error
    //       console.log(error);
    //       throw error;
    //     })
    //     .then((response) => {
    //       game_table.data = response[0];
    //     })
    // }
    //
    // start_game = () => {
    //   console.log(`Starting game: ${game_table.current_game_id}`);
    //   // this.isShuffling = true;
    //   // this.current_game = (await 
    //     backend.start_game(game_table.current_game_id)
    //     .catch((error) => {
    //       // TODO notification error
    //       // console.log("error");
    //       console.log(error);
    //       // this.isShuffling = false;
    //       throw error;
    //     })
    //     .then((response) => {
    //       // console.log(response);
    //       // console.log(this);
    //       if (typeof(response) === 'object')
    //         game_table.current_game = response[0];
    //       // this.isShuffling = false;
    //     });
    //     game_table.get_current_game();
    //
    // }
    //
    // get_current_game = async () => {
    //   console.log("get curreny game");
    //   this.current_game = (await backend.get_game(this.current_game_id))[0];
    // }
    //
    // get_table = async () => {
    //   this.data = (await backend.get_table(table_id))[0];
    // }
    //
    // // containsUser = $state((user_id) => {
    // //   console.log(user_id);
    // //   console.log(this);
    // //   console.log(this.data?.seats.some(obj => obj.player[0]?.user_id.toString() === user_id));
    // //   this.data?.seats.some(obj => obj.player[0]?.user_id.toString() === user_id)
    // //   // false;
    // // })
    //
    // get count() {
    //   return this.data;
    // }
}
  
export const wallet = new Wallet();
wallet.refreshWatchedICRC1Tokens();

// async function onSubmitTransfer(event) {
//   console.log(event);
//   event.target.transfer_amount_submit.disabled = true;
//   
//   const transfer_to = event.target.transfer_to.value;
//   const amount = event.target.transfer_amount.value;
//   // TODO get decimals instead of hardcoded 8
//   const amountNat = Number(amount)*10**8
//   // console.log(amount);
//   // console.log(amountNat);
//
//   if ($auth.isAuthenticated) {
//     // console.log("hi");
//
//     const identity = await $auth.identity;
//     // const identity = $auth.identity; //TODO is await necessary?
//
//     const agent = await createAgent({
//       identity,
//       host:
//         process.env.DFX_NETWORK === "ic"
//           ? "https://icp-api.io"
//           : "http://127.0.0.1:4944",
//     });
//     // Fetch root key for certificate validation during development
//     if (process.env.DFX_NETWORK !== "ic") {
//       agent.fetchRootKey().catch((err) => {
//         console.warn(
//           "Unable to fetch root key. Check to ensure that your local replica is running"
//         );
//         console.error(err);
//       });
//     }
//
//     const { icrc1Transfer } = LedgerCanister.create({
//       agent,
//       canisterId: "ryjl3-tyaaa-aaaaa-aaaba-cai",
//     });
//
//     const transferArgs = {
//       to: {owner: Principal.fromText(transfer_to),
//                 subaccount: [],
//                },
//       amount: amountNat, // + 10000, // TODO dynamic fee
//       };
//
//
//     // try {
//         // Code that might throw an error
//         const transfer_response = await icrc1Transfer(transferArgs);
//     // } catch (error) {
//         // Handle the exception
//         // console.error('An error occurred:', error.message);
//     // }
//
//        // console.log(transfer_response);
//
//     let principal = $auth.identity._principal;
//     // console.log(principal.toString());
//
//     // TODO: do something with transfer response?
//     // let transfer = "";
//     // transfer = transfer_response;
//     // clear form
//     event.target.transfer_to.value = "";
//     event.target.transfer_amount.value = "";
//     event.target.transfer_amount_submit.disabled = false;
//
//     // refresh balance
//     refreshICPBalance();
//     refreshTICPBalance();
//
//   return false;
//   }
// }

// console.log("fn5kk-kn4e4-lbi3j-to4w7-xq5fa-hcjgt-kevst-f3yy7-iemxh-h6qrs-oqe");
// console.log("bkyz2-fmaaa-aaaaa-qaaaq-cai");


// TODO generic ICRC Transfer function
// async function onSubmitCLOUDTransfer(event) {
//   console.log(event);
//   event.target.transfer_amount_ticp_submit.disabled = true;
//   
//   const transfer_to = event.target.transfer_ticp_to.value;
//   const amount = event.target.transfer_amount_ticp.value;
//   // TODO get decimals instead of hardcoded 8
//   const amountNat = Number(amount)*10**8
//   // console.log(amount);
//   // console.log(amountNat);
//
//   if ($auth.isAuthenticated) {
//     // console.log("hi");
//
//     const identity = await $auth.identity;
//     // const identity = $auth.identity; //TODO is await necessary?
//
//     const agent = await createAgent({
//       identity,
//       host:
//         process.env.DFX_NETWORK === "ic"
//           ? "https://icp-api.io"
//           : "http://127.0.0.1:4944",
//     });
//     // Fetch root key for certificate validation during development
//     if (process.env.DFX_NETWORK !== "ic") {
//       agent.fetchRootKey().catch((err) => {
//         console.warn(
//           "Unable to fetch root key. Check to ensure that your local replica is running"
//         );
//         console.error(err);
//       });
//     }
//
//     const { transfer } = IcrcLedgerCanister.create({
//       agent,
//       canisterId: "pcj6u-uaaaa-aaaak-aewnq-cai", // CLOUD canister
//     });
//
//     const transferArgs = {
//       to: {owner: Principal.fromText(transfer_to),
//                 subaccount: [],
//                },
//       amount: amountNat, // + 10000, // TODO dynamic fee
//       };
//
//
//     try {
//         // Code that might throw an error
//         const transfer_response = await transfer(transferArgs);
//     } catch (error) {
//         // Handle the exception
//         console.error('An error occurred:', error.message);
//     }
//
//        // console.log(transfer_response);
//
//     // let principal = $auth.identity._principal;
//     // console.log(principal.toString());
//
//     // TODO: do something with transfer response?
//     // let transfer = "";
//     // transfer = transfer_response;
//     // clear form
//     event.target.transfer_ticp_to.value = "";
//     event.target.transfer_amount_ticp.value = "";
//     event.target.transfer_amount_ticp_submit.disabled = false;
//
//     // refresh balance
//     // refreshICPBalance();
//     // refreshTICPBalance();
//     refreshCLOUDBalance();
//
//   return false;
//   }
// }

// async function faucetTICP() {
//   faucetButton.disabled = true;
//
//   if ($auth.isAuthenticated) {
//     try {
//       const response = await $auth.actor.faucetTICP();
//     // console.log(response);
//     } catch(error) { console.log(error); }
//     await refreshTICPBalance();
//     faucetButton.disabled = false;
//   } else {
//     console.log("must login");
//     // alert("Login to see balance");
//     return false;
//   }
//   return false;
//
// }

// async function faucetTCLOUD() {
//   faucetTCLOUDButton.disabled = true;
//
//   if ($auth.isAuthenticated) {
//     try {
//       const response = await $auth.actor.faucetTCLOUD();
//     } catch(error) { console.log(error); }
//     // console.log(response);
//     await refreshTCLOUDBalance();
//     faucetTCLOUDButton.disabled = false;
//   } else {
//     console.log("must login");
//     // alert("Login to see balance");
//     return false;
//   }
//   return false;
//
// }

onMount(() => {
  // $auth.init();
});

$effect(() => {
    console.log('effect');
    console.log('wallet view changed:', isWalletBarExpanded);
});

$effect(() => {
    console.log('effect');
    console.log('watched tokens changed:');
    wallet.watched_icrc1_tokens;
    wallet.refreshWatchedICRC1Tokens();
    // if (wallet.watched_icrc1_tokens) {
      // console.log('watched tokens changed:', wallet.watched_icrc1_tokens);
    // }
});

async function icrc1_metadata(canister_id : string) {

  const agent = new HttpAgent({ /* no identity = anonymous */ });
  if (process.env.DFX_NETWORK !== "ic") {
  // Only in local/dev, never on mainnet:
    await agent.fetchRootKey();
  }
  // console.log(agent);
  // console.log(`${await agent.getPrincipal()}`);
  const principal = await agent.getPrincipal();

    const { metadata } = IcrcLedgerCanister.create({
      agent,
      canisterId: Principal.fromText(canister_id),
    });

    try {
        // Code that might throw an error
        const meta_response = await metadata({certified: false});
        // console.log(meta_response);
        return meta_response;
    } catch (error) {
        // Handle the exception
        console.error('An error occurred:', error.message);
        return error;
    }

}

async function icrc_balance(canister_id : string) {

  const agent = new HttpAgent({ /* no identity = anonymous */ });
  if (process.env.DFX_NETWORK !== "ic") {
  // Only in local/dev, never on mainnet:
    await agent.fetchRootKey();
  }
  // console.log(agent);
  // console.log(`${await agent.getPrincipal()}`);
  const principal = await agent.getPrincipal();

    const { metadata } = IcrcLedgerCanister.create({
      agent,
      canisterId: Principal.fromText(canister_id),
    });

    const { balance } = IcrcLedgerCanister.create({
      agent,
      canisterId: Principal.fromText(canister_id),
    });

    const icrc1BalanceOfArgs = {
      owner: principal,
      subaccount: null,
    };

    // TODO cleaner design
    icrcBalances[canister_id] = icrcBalances[canister_id] ?? {};

    try {
        // Code that might throw an error
        const meta_response = await metadata({certified: false});
        // console.log(meta_response);
        icrcBalances[canister_id].metadata = meta_response;
        // return meta_response;
    } catch (error) {
        // Handle the exception
        console.error('An error occurred:', error.message);
        return error;
    }

    try {
        // Code that might throw an error
        const balance_response = await balance(icrc1BalanceOfArgs);
        // console.log(balance_response);
        icrcBalances[canister_id].balance = balance_response;
        return balance_response;
    } catch (error) {
        // Handle the exception
        console.error('An error occurred:', error.message);
        return error;
    }
}

</script>



<div class=" sticky  top-15 z-1000">

  <div id="walletBar" class="absolute top-0 right-0 text-white text-sm text-shadow-cloud text-right">

    {#if isWalletBarExpanded}
      <button class={["rounded-full btn btn-warning", !isWalletBarEdit && 'btn-outline']}
              aria-label="Toggle Wallet Edit" 
              onclick={() => {
              isWalletBarEdit = !isWalletBarEdit ;
              wallet.refreshWatchedICRC1Tokens();
              } }
        >
        ✎
      </button>
    {/if}

    <button class="rounded-full btn "
            aria-label="Toggle Wallet View" 
            onclick={() => {
            isWalletBarExpanded = !isWalletBarExpanded;
            wallet.refreshWatchedICRC1Tokens();
            } }
      >
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-wallet" viewBox="0 0 16 16">
        <path d="M0 3a2 2 0 0 1 2-2h13.5a.5.5 0 0 1 0 1H15v2a1 1 0 0 1 1 1v8.5a1.5 1.5 0 0 1-1.5 1.5h-12A2.5 2.5 0 0 1 0 12.5zm1 1.732V12.5A1.5 1.5 0 0 0 2.5 14h12a.5.5 0 0 0 .5-.5V5H2a2 2 0 0 1-1-.268M1 3a1 1 0 0 0 1 1h12V2H2a1 1 0 0 0-1 1" />
      </svg>   
    </button>

    {#if isWalletBarExpanded}
      <div class="walletBarExpanded bg-[#111111] p-2 max-h-[70vh] overflow-auto">
      <p class="bg-primary">
        TODO Principal
      </p>
      {#if isWalletBarEdit}
        <h3 class="font-bold bg-success">Watched Tokens</h3>
      {/if}
      <ul>
        <!-- <li>ICP: {icrc_balance("ryjl3-tyaaa-aaaaa-aaaba-cai").then((response) => { return response}) }</li> -->
        {#each wallet.watched_icrc1_tokens as token}
          <li>
            {#if isWalletBarEdit}
              <input class="checkbox checkbox-info checkbox-xs" type="checkbox" bind:checked={token.watched} />
            {/if}
            {token.symbol || token.canister_id}: {token.balance }
            <!-- {token.canister_id}: {token.metadata} : {token.balance } -->
          </li>
        {/each}
      </ul>

      {#if isWalletBarEdit}
        <h3 class="font-bold bg-warning">All Tokens</h3>
        <ul>
        {#each wallet.icrc1_tokens as token}
          <li>
            <!-- TODO maybe use eye for checkbox or toggle switch -->
            <!-- <label> -->
            <!--   <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-eye" viewBox="0 0 16 16"> -->
            <!--     <path d="M16 8s-3-5.5-8-5.5S0 8 0 8s3 5.5 8 5.5S16 8 16 8M1.173 8a13 13 0 0 1 1.66-2.043C4.12 4.668 5.88 3.5 8 3.5s3.879 1.168 5.168 2.457A13 13 0 0 1 14.828 8q-.086.13-.195.288c-.335.48-.83 1.12-1.465 1.755C11.879 11.332 10.119 12.5 8 12.5s-3.879-1.168-5.168-2.457A13 13 0 0 1 1.172 8z"/> -->
            <!--     <path d="M8 5.5a2.5 2.5 0 1 0 0 5 2.5 2.5 0 0 0 0-5M4.5 8a3.5 3.5 0 1 1 7 0 3.5 3.5 0 0 1-7 0"/> -->
            <!--   </svg>    -->
            <input class="checkbox checkbox-info checkbox-xs" type="checkbox" bind:checked={token.watched} />
            <!-- </label> -->
            {token.symbol || token.canister_id}: {token.balance }
            <input class="btn btn-xs btn-error" 
                   type="button" 
                   value="×"
                   onclick={()=> {wallet.icrc1_tokens.splice(wallet.icrc1_tokens.indexOf(token), 1) }}
            />
          </li>
        {/each}
        </ul>
      {/if}

      {#if !showAddTokenInput}
        <button class="btn btn-primary btn-outline btn-xs"
                onclick={showAddTokenInput = !showAddTokenInput}
        >+ Add Token</button>
      {:else}
        <div class="join">
        <button class="btn btn-error btn-xs join-item"
                onclick={showAddTokenInput = !showAddTokenInput}
        >×</button>
        <input class="input input-xs join-item" type="text" placeholder="canister-id" id="walletAddToken" name="walletAddToken"
               onkeydown={(e)=> { e.key === 'Enter' ? walletAddTokenButton!.click() : null }}

        >
        <button class="btn btn-success btn-xs join-item"
                bind:this={walletAddTokenButton}
                id="DEPRECATED_use_bind_instead_walletAddTokenButton"
                onclick={() => {
                // alert(walletAddToken.value);
                // alert(wallet.icrc1_tokens);
                wallet.icrc1_tokens.push({canister_id: walletAddToken.value, watched: true});
                wallet.refreshWatchedICRC1Tokens();
                walletAddToken.value = "";
                // alert(wallet.icrc1_tokens);
                // showAddTokenInput = !showAddTokenInput;
                }}
        >+</button>
        </div>

      {/if}
      </div>
    {/if}

  </div>
</div>

