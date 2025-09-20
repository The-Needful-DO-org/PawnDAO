<script>
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
// let showICPTransferForm = $state(false);
// let showTICPTransferForm = $state(false);
// let showTCLOUDTransferForm = $state(false);
// let showCLOUDTransferForm = $state(false);
// let credit_balance = $state(0);

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

</script>



<div class=" sticky  top-15 z-1000">

  <div id="walletBar" class="absolute top-0 right-0 text-white text-sm text-shadow-cloud text-right">

    <button class="rounded-full btn " aria-label="Toggle Wallet View" onclick={() => isWalletBarExpanded = !isWalletBarExpanded}>
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-wallet" viewBox="0 0 16 16">
        <path d="M0 3a2 2 0 0 1 2-2h13.5a.5.5 0 0 1 0 1H15v2a1 1 0 0 1 1 1v8.5a1.5 1.5 0 0 1-1.5 1.5h-12A2.5 2.5 0 0 1 0 12.5zm1 1.732V12.5A1.5 1.5 0 0 0 2.5 14h12a.5.5 0 0 0 .5-.5V5H2a2 2 0 0 1-1-.268M1 3a1 1 0 0 0 1 1h12V2H2a1 1 0 0 0-1 1" />
      </svg>   
    </button>

    {#if isWalletBarExpanded}
      <p class="bg-primary">
        TODO Wallet
      </p>
    {/if}

  </div>
</div>

