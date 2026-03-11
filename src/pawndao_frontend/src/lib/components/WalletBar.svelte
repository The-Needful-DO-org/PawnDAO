<script lang="ts" module>
  import { untrack } from 'svelte';
  import { auth } from '$lib/auth.svelte.ts'
  import { whoami } from '$lib/auth.svelte.ts'
  import { updateActor } from '$lib/auth.svelte.ts'
  import { login } from '$lib/auth.svelte.ts'
  import { logout } from '$lib/auth.svelte.ts'
import { Ed25519KeyIdentity } from '@dfinity/identity';
import { invalidate } from '$app/navigation';
import { invalidateAll } from '$app/navigation';

// Generate a new Ed25519 identity in the frontend
// const identity = Ed25519KeyIdentity.generate();

let pem_file = $state();
let transfer_error_message = $state();

// pawn_loaner id for debugging
const pem = `-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIEfWpA1TPKMAXKfSFXawBURQQmOq3BPDU9Mq4bmGtptQoAcGBSuBBAAK
oUQDQgAEgY2Rd6cOJL10yXwaTJzdPBl2zrffBzstvac4Ock6MdA8ls/MaaWocNOm
vMfR6ZjU7AUkDeO6u+OHe+FIeMo9Fg==
-----END EC PRIVATE KEY-----`

// serialize functions to store BigInt
function serialize(value : Object) {
  return JSON.stringify(value, (_key, value) =>
    typeof value === 'bigint' ? value.toString() : value
  );
}

function deserialize(str : string) {
  return JSON.parse(str, (_key, value) => {
    // console.log(_key);
    // console.log(value);
    // original bigint regexp from llm
    // /(?:^|[^\d])(\d{15,})(?:[^\d]|$)/.test(value) ? BigInt(value) : value
    // TODO better bigint regexp because this matches base64 logo data
    if (/(?:^|[^\d])(\d{15,})(?:[^\d]|$)/.test(value)) {
      try {
      return BigInt(value);
      } catch {
      return value; 
      }
    } else {
      return value;
    }
  });
}

// helper to parse icrc1_metadata
function valueToJs(v: any): string | number | bigint | Uint8Array {
  if ("Text" in v) return v.Text;
  if ("Nat" in v) return BigInt(v.Nat);
  if ("Int" in v) return BigInt(v.Int);
  if ("Blob" in v) return new Uint8Array(v.Blob);
  return v;
}

function updateOrAddObject(arr, canisterId, newObject) {
  const existingObject = arr.find(obj => obj.canister_id === canisterId);
  
  if (existingObject) {
    // Update the existing object
    Object.assign(existingObject, newObject);
  } else {
    // Add a new object if not found
    arr.push(newObject);
  }
}

async function icrc_balance(canister_id : string) {

  // const agent = new HttpAgent({ /* no identity = anonymous */ });
  // const agent = await HttpAgent.create({ /* no identity = anonymous */ });
  const agent = HttpAgent.createSync({ /* no identity = anonymous */ });
  if (process.env.DFX_NETWORK !== "ic") {
  // Only in local/dev, never on mainnet:
    await agent.fetchRootKey();
  }
  // console.log(agent);
  // console.log(`${await agent.getPrincipal()}`);
  // const principal = await agent.getPrincipal();
  const principal = auth.principal;

    // const { metadata } = IcrcLedgerCanister.create({
    //   agent,
    //   canisterId: Principal.fromText(canister_id),
    // });

    const { balance } = IcrcLedgerCanister.create({
      agent,
      canisterId: Principal.fromText(canister_id),
    });

    const icrc1BalanceOfArgs = {
      owner: principal,
      subaccount: null,
    };

    // TODO cleaner design
    // icrcBalances[canister_id] = icrcBalances[canister_id] ?? {};

    try {
        // Code that might throw an error
        // const meta_response = await metadata({certified: false});
        // console.log(meta_response);
        // icrcBalances[canister_id].metadata = meta_response;
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
        // icrcBalances[canister_id].balance = balance_response;
        return balance_response;
    } catch (error) {
        // Handle the exception
        console.error('An error occurred:', error.message);
        return error;
    }
}

async function icrc1_metadata(canister_id : string) {

  const agent = new HttpAgent({ /* no identity = anonymous */ });
  if (process.env.DFX_NETWORK !== "ic") {
  // Only in local/dev, never on mainnet:
    await agent.fetchRootKey();
  }
  // console.log(agent);
  // console.log(`${await agent.getPrincipal()}`);
  // const principal = await agent.getPrincipal();

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

  type WalletICRC1Token = {canister_id : string,
   watched? : boolean,
   decimals? : BigInt,
   metadata? : [string, object]
   fee? : BigInt,
   symbol? : string,
   logo? : string,
   balance_nat? : BigInt,
   balance? : Number}

  class Wallet {
    data = $state();

    default_icrc1_tokens : WalletICRC1Token[] = [
      {
        canister_id: 'ryjl3-tyaaa-aaaaa-aaaba-cai',
        // symbol: "LICP",
        watched: true
      },
      // {
      //   canister_id: 'llcdy-4qaaa-aaaah-arcua-cai',
      //   // symbol: "TPAWN",
      //   watched: true
      // },
    ];
    icrc1_tokens : WalletICRC1Token[] = $state(this.default_icrc1_tokens);

    watched_icrc1_tokens = $derived(this.icrc1_tokens.filter(token => token.watched));
 
    refreshWatchedICRC1Tokens = () => {
      // console.log("refreshWatchedICRC1Tokens()");
      this.watched_icrc1_tokens.forEach(async (token) => {
        // TODO cache and expire token metadata 
        // if (true || token.metadata === undefined) {
        if (token.metadata === undefined) {
          await icrc1_metadata(token.canister_id).then((metadata) => {
            token.metadata = metadata; 
            const map = new Map<string, any>(metadata.map(([k, v]: [string, any]) => [k, valueToJs(v)]));
            token.symbol = map.get("icrc1:symbol");        // Text -> e.g., "XTKN"
            token.decimals = map.get("icrc1:decimals");    // Nat  -> e.g., 8n
            token.fee = map.get("icrc1:fee");              // Nat  -> e.g., 10000n
            token.logo = map.get("icrc1:logo");
          })
          .catch((error) => {console.error(error); });
        }
        // console.log(token);
        // console.log(token.decimals);
        // console.log(token.canister_id);
        // console.log(token.metadata);
        icrc_balance(token.canister_id)
          .then((balance) => {token.balance = Number(balance) / 10**Number(token.decimals); })
          .catch((error) => {console.error(error); token.balance = "Unavailable"; });
        // token.balance = 42069;
      });
      localStorage.setItem('icrc1tokens', serialize(this.icrc1_tokens));
    }

    refreshAllICRC1Tokens = () => {
      console.log("Wallet refreshing all icrc1 tokens");
      this.icrc1_tokens.forEach(async (token) => {
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
          .then((balance_nat) => {
            console.log(`balancing: ${token.symbol} ${token.decimals} ${balance_nat}`)
            const balance_float = Number(balance_nat) / 10**Number(token.decimals);
            token.balance = balance_float != null && !isNaN(balance_float) ? balance_float: "Unavailable";
            // if (typeof balance_float === 'number' && !isNaN(balance_float)) {
            //   token.balance = balance_float; 
            // } else {
            //   token.balance = "Unavailable"; 
            //}
            })
          // .then((balance) => {token.balance = Number(balance) / 10**Number(token.decimals); })
          .catch((error) => {console.error(error); token.balance = "Error Unavailable"; });
        // token.balance = 42069;
      });
      // localStorage.setItem('icrc1tokens', serialize(this.icrc1_tokens));
    }
   
  refreshICRC1Token = async (canister_id : String) => {
    const token = this.icrc1_tokens.find(obj => obj.canister_id === canister_id);
      // TODO cache and expire token metadata 
      // if (true || token.metadata === undefined) {
      if (token && token.metadata === undefined) {
        await icrc1_metadata(token.canister_id).then((metadata) => {
          token.metadata = metadata; 
          const map = new Map<string, any>(metadata.map(([k, v]: [string, any]) => [k, valueToJs(v)]));
          token.symbol = map.get("icrc1:symbol");        // Text -> e.g., "XTKN"
          token.decimals = map.get("icrc1:decimals");    // Nat  -> e.g., 8n
          token.fee = map.get("icrc1:fee");              // Nat  -> e.g., 10000n
          token.logo = map.get("icrc1:logo");
        })
        .catch((error) => {console.error(error); });
        // console.log(token);
        // console.log(token.decimals);
        // console.log(token.canister_id);
        // console.log(token.metadata);
      icrc_balance(token.canister_id)
          .then((balance) => {token.balance = Number(balance) / 10**Number(token.decimals); })
          .catch((error) => {console.error(error); token.balance = "Unavailable"; });
        // token.balance = 42069;
      // console.log(`refreshed icrc1 token ${token.canister_id}`);
      // localStorage.setItem('icrc1tokens', serialize(this.icrc1_tokens));
    }
    }


  icrc1_balance = (canister_id : String) => {
    // TODO 
    // updateOrAddObject(this.icrc1_tokens, canisterId, newObject) {
    const token = this.icrc1_tokens.find(obj => obj.canister_id === canister_id);
    if (token) {
      console.log(`wallet token: ${token.symbol} ${token.balance}`)
      // return token?.balance || "Token Unavailable";
      return token.balance;
    } else {
        console.log(`wallet token not found`)
      // add token to list
      // this.icrc1_tokens.push({canister_id: canister_id, watched: false});
      // this.refreshAllICRC1Tokens();
    }
    return this.icrc1_tokens.find(obj => obj.canister_id === canister_id)?.balance || "Unavailable";
  }

  addICRC1Token = (canister_id : Principal) => {
    const token = this.icrc1_tokens.find(obj => obj.canister_id === canister_id.toString());
    if (token) {
      return false;
    } else {
      // add token to list
      this.icrc1_tokens.push({canister_id: canister_id.toString(), watched: false});
      // this.refreshAllICRC1Tokens();
      this.refreshICRC1Token(canister_id.toString());
    }
    return true;
  }

  // Is derived appropriate?
  // principal : Principal | undefined = $state();
  principal : Principal | undefined = $derived(auth.principal);

  // Deprcated?
  getPrincipal = async () => {
    // const agent = HttpAgent.createSync({ /* no identity = anonymous */ });
    // console.log("getprinc");
    // const identity = auth.authClient.getIdentity();
    // const principal = identity.getPrincipal();
    // console.log(identity);
    // console.log(principal);
    // console.log(principal.toString());
    // console.log(auth.principal.toString());
    // this.principal = principal;
    this.principal = auth.principal;
    return this.principal;
  }

  // approve ICRC transfer by backend
  icrc2_approve = async (canister_id : Principal, amount : Number = 42069000000) => {

    //  TODO add auth
    const identity = auth.identity;
    if (!identity) { return false; } // TODO throw error?
    // var agent = await createAgent({
    //   identity,
    //   host:
    //     process.env.DFX_NETWORK === "ic"
    //       ? "https://icp-api.io"
    //       : "http://10.0.0.200:4943",
    // });
    const agent = await HttpAgent.create({identity});

    // console.log(agent);
    // deprecated anon agent
    // const anonagent = await HttpAgent.create({});
    // console.log(anonagent);
    // agent = anonagent;

    // Fetch root key for certificate validation during development
    if (process.env.DFX_NETWORK !== "ic") {
      agent.fetchRootKey().catch((err) => {
        console.warn(
          "Unable to fetch root key. Check to ensure that your local replica is running"
        );
        console.error(err);
      });
    }

    const { approve } = IcrcLedgerCanister.create({
      agent,
      canisterId: canister_id,
    });

    const approveArgs = {
      spender: {owner: Principal.fromText(process.env.CANISTER_ID_PAWNDAO_BACKEND),
                subaccount: [],
               },
      amount: amount,
      };

      // TODO handle errors
      try {
          // Code that might throw an error
          const approval = await approve(approveArgs);
          console.log("ICRC approval: " + approval);
      } catch (error) {
          // Handle the exception
          console.error('An error occurred:', error.message);
          console.error('An error occurred:', error);
          console.error('An error occurred:', error.errorType);
          throw error;
      }

  }

  icrc1_total_supply = async (canister_id : Principal) => {
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

    const { totalTokensSupply } = IcrcLedgerCanister.create({
      agent,
      canisterId: canister_id,
    });

      try {
          const supply = await totalTokensSupply({});
          return supply;
          // console.log("ICRC supply: " + supply );
      } catch (error) {
          // Handle the exception
          console.error('An error occurred:', error.message);
          console.error('An error occurred:', error);
          console.error('An error occurred:', error.errorType);
          throw error;
      }

  }

  validateICRC2Allowance = async (canister_id : Principal, owner : Principal, amount : number) => {
    // console.log("validating allowance ", canister_id.toString());
    // this.addICRC1Token(canister_id);
    const token = this.icrc1_tokens.find(token => token.canister_id === canister_id.toString() );
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
    if (loan_asset_allowance_nat < amount) {
      return false;
    } else {
      return true;
    }
  }


}
  
export const wallet = new Wallet();
const savedICRC1Tokens = localStorage.getItem('icrc1tokens');
if (savedICRC1Tokens) wallet.icrc1_tokens = deserialize(savedICRC1Tokens);
if (!wallet.icrc1_tokens) {
  alert("Wallet Error loading saved ICRC1 Token data");
  wallet.icrc1_tokens = wallet.default_icrc1_tokens;
}

// localStorage.setItem('icrc1tokens', JSON.stringify(wallet.icrc1_tokens));
</script>

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
let icrc1_token_to_transfer = $state({});

let walletAddTokenButton = $state.raw<HTMLElement | null>(null);



wallet.refreshWatchedICRC1Tokens();

// Initialize auth client
onMount(async () => {
  await updateActor();
  // await wallet.getPrincipal();
});

async function onSubmitICRC1Transfer(event : Event) {
  event.preventDefault();
  console.log(event);
  transfer_error_message = "";
  event.target.transfer_amount_submit.disabled = true;
  
  const token = icrc1_token_to_transfer;
  const transfer_to = event.target.transfer_to.value;
  const amount = event.target.transfer_amount.value;
  // TODO get decimals instead of hardcoded 8
  const amountNat = Number(amount)*10**Number(token.decimals);
  // console.log(amount);
  // console.log(amountNat);

  // TODO auth
  // if ($auth.isAuthenticated) {
  if (true) {
    // console.log("hi");

    // TODO auth
    const identity = auth.identity;
    // // const identity = $auth.identity; //TODO is await necessary?

    if (typeof identity === "undefined") {
      console.warn("identity undefined");
      return;
    }

    // const agent = await createAgent({
    //   identity,
    //   host:
    //     process.env.DFX_NETWORK === "ic"
    //       ? "https://icp-api.io"
    //       : "http://127.0.0.1:4944",
    // });
    const agent = await createAgent({identity});

    // const agent = new HttpAgent({ /* no identity = anonymous */ });
    // const agent = new HttpAgent({ identity: auth.identity });

    // Fetch root key for certificate validation during development
    if (process.env.DFX_NETWORK !== "ic") {
      agent.fetchRootKey().catch((err) => {
        console.warn(
          "Unable to fetch root key. Check to ensure that your local replica is running"
        );
        console.error(err);
      });
    }

    let transfer;
    let transferArgs;
    try {
      transfer = IcrcLedgerCanister.create({
        agent,
        canisterId: token.canister_id,
      }).transfer;
      // console.log(transfer);

      transferArgs = {
        to: {owner: Principal.fromText(transfer_to),
                  subaccount: [],
                 },
        amount: amountNat, // + 10000, // TODO dynamic fee?
        };

    } catch (error: unknown) {
      if (error instanceof Error) {
        console.log(error);
        console.log("Ledger transferverror");
        console.error('An error occurred:', error.message);
        // event.target.transfer_amount_submit.disabled = false;
        // throw error;
      } else if (typeof error === 'string') {
        console.log('Error message:', error); // Handle string errors
      } else {
        console.log('Unknown error type:', error);
      }
    }

    let transfer_response;
    try {
        // Code that might throw an error
        transfer_response = await transfer(transferArgs);
    } catch (error) {
        // Handle the exception
        // console.log("Ledger transfer_response error");
        console.error('An error occurred:', error.message);
        transfer_error_message = error.message
    }

       console.log('Transfer response: ', transfer_response);

    // let principal = $auth.identity._principal;
    // console.log(principal.toString());

    // TODO: do something with transfer response?
    // let transfer = "";
    // transfer = transfer_response;
    // clear form
    if (transfer_response != undefined) {
      event.target.transfer_to.value = "";
      event.target.transfer_amount.value = "";
    }
    event.target.transfer_amount_submit.disabled = false;

    // refresh balance
    wallet.refreshWatchedICRC1Tokens();

  return false;
  }
}


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

let pem_string = $derived.by(async() => {
    if (!pem_file) { return undefined; }
    console.log('pem file changed:', await pem_file[0].text());
    return await pem_file[0].text();
    }
);

$effect(async() => {
    console.log(await pem_string);
    console.log('wallet view changed:', isWalletBarExpanded);
});

$effect(() => {
    auth.principal;
    console.log('auth changed');
  untrack(() => {
    wallet.refreshWatchedICRC1Tokens();
  });
});

$effect(() => {
    console.log('effect');
    console.log('watched tokens changed:');
    wallet.watched_icrc1_tokens;
    untrack(() => {
      wallet.refreshWatchedICRC1Tokens();
    });
    // if (wallet.watched_icrc1_tokens) {
      // console.log('watched tokens changed:', wallet.watched_icrc1_tokens);
    // }
});



</script>



<div class="sticky  top-15 z-1000 container mx-auto">

  <div id="walletBar" class="absolute top-2 right-2 md:right-0 lg:-right-6 text-white text-sm text-shadow-cloud text-right">

    {#if (process.env.DFX_NETWORK !== "ic") }
      <!-- TODO figure out proper invalidation tactic -->
      <button class="btn" onclick={async()=> {await updateActor({pem: pem}); invalidateAll();}}>Loaner login</button>
      <button class="btn" onclick={()=>updateActor({ii: true})}>II</button>
      <!-- <button class="btn" onclick={async ()=>await wallet.getPrincipal()}>wallet.getPrincipal</button> -->
      <button class="btn" onclick={() => login_modal.showModal() }>Login</button>
    {:else}
      {#if (auth.isAuthenticated == false)}
        <button class="btn" onclick={login}>Login</button>
      {:else}
        <button class="btn btn-error" onclick={logout}>Logout</button>
      {/if}
    {/if}

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
            // wallet.getPrincipal();
            wallet.refreshWatchedICRC1Tokens();
            } }
      >
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-wallet" viewBox="0 0 16 16">
        <path d="M0 3a2 2 0 0 1 2-2h13.5a.5.5 0 0 1 0 1H15v2a1 1 0 0 1 1 1v8.5a1.5 1.5 0 0 1-1.5 1.5h-12A2.5 2.5 0 0 1 0 12.5zm1 1.732V12.5A1.5 1.5 0 0 0 2.5 14h12a.5.5 0 0 0 .5-.5V5H2a2 2 0 0 1-1-.268M1 3a1 1 0 0 0 1 1h12V2H2a1 1 0 0 0-1 1" />
      </svg>   
    </button>

    {#if isWalletBarExpanded}
      <div class="walletBarExpanded bg-[#111111] p-2 max-h-[70vh] overflow-auto">
      <p class="bg-neutral overflow-hidden">
        <!-- {#await wallet.getPrincipal()} -->
        <!--   <span class="loading loading-ring loading-xs"></span> -->
        <!-- {:then} -->
          <button 
            class="select-none tooltip tooltip-bottom before:z-2000 z-2000"
            data-tip="Click to Copy"
            onclick={
            async (e) => {
                try {
                  const text = wallet?.principal?.toString() || "None";
                  await navigator.clipboard.writeText(text);
                  console.log('Content copied to clipboard');
                  e.target.dataset.tip = "Copied!";
                } catch (err) {
                  console.error('Failed to copy: ', err);
                }
              }
          }>
            ⧉
          </button>
          <span class="tooltip tooltip-bottom before:z-2000 z-2000"
                data-tip="Click to Copy"
                role="button"
                tabindex="0"
                aria-roledescription="Click to Copy Principal"
                onkeypress={()=>console.log("keypress on principal")}
                onmouseenter={(e)=>
                        e.target.dataset.tip = "Click to Copy" }
                onfocus={(e)=>
                        e.target.dataset.tip = "Click to Copy" }
                onclick={
                  async (e) => {
                      try {
                        const text = wallet?.principal?.toString() || "None";
                        await navigator.clipboard.writeText(text);
                        console.log('Content copied to clipboard');
                        e.target.dataset.tip = "Copied!";
                      } catch (err) {
                        console.error('Failed to copy: ', err);
                      }
                    }
                }
          >
            <!-- {auth.principal} -->
            {wallet.principal?.toString()}
          </span>
        <!-- {/await} -->
      </p>
      {#if isWalletBarEdit}
        <h3 class="font-bold bg-success">Watched Tokens</h3>
      {/if}
      <ul>
        <!-- <li>ICP: {icrc_balance("ryjl3-tyaaa-aaaaa-aaaba-cai").then((response) => { return response}) }</li> -->
        {#each wallet.watched_icrc1_tokens as token}
          <li class="py-1 flex items-center justify-end space-x-1">
            {#if isWalletBarEdit}
              <input class="toggle toggle-info checkbox-xs" type="checkbox" bind:checked={token.watched} />
            {/if}
            <span>{token.symbol || token.canister_id}: {token.balance }</span>
            <button class={["rounded-full btn btn-info btn-xs btn-outline"]}
                    aria-label="Token Send Modal Open" 
                    onclick={() => {
                    icrc1_token_to_transfer = token;
                    icrc1_tansfer_modal.showModal();
                    // alert(`TODO show transfer modal ${token.symbol}`);
                    wallet.refreshWatchedICRC1Tokens();
                    } }
              >
              <!-- bootstrap eject icon -->
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-eject" viewBox="0 0 16 16"><path d="M7.27 1.047a1 1 0 0 1 1.46 0l6.345 6.77c.6.638.146 1.683-.73 1.683H1.656C.78 9.5.326 8.455.926 7.816zM14.346 8.5 8 1.731 1.654 8.5zM.5 11.5a1 1 0 0 1 1-1h13a1 1 0 0 1 1 1v1a1 1 0 0 1-1 1h-13a1 1 0 0 1-1-1z" /></svg>
              <!-- bootstrap send icon -->
              <!-- <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-send" viewBox="0 0 16 16"> <path d="M15.854.146a.5.5 0 0 1 .11.54l-5.819 14.547a.75.75 0 0 1-1.329.124l-3.178-4.995L.643 7.184a.75.75 0 0 1 .124-1.33L15.314.037a.5.5 0 0 1 .54.11ZM6.636 10.07l2.761 4.338L14.13 2.576zm6.787-8.201L1.591 6.602l4.339 2.76z"/> </svg> -->
            </button>
            <!-- {token.canister_id}: {token.metadata} : {token.balance } -->
          </li>
        {/each}
      </ul>

      {#if isWalletBarEdit}
        <h3 class="font-bold bg-warning">All Tokens</h3>
        <ul>
        {#each wallet.icrc1_tokens as token}
          <li class="py-1 flex items-center justify-end space-x-1">
            <!-- TODO maybe use eye for checkbox or toggle switch -->
            <!-- <label> -->
            <!--   <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-eye" viewBox="0 0 16 16"> -->
            <!--     <path d="M16 8s-3-5.5-8-5.5S0 8 0 8s3 5.5 8 5.5S16 8 16 8M1.173 8a13 13 0 0 1 1.66-2.043C4.12 4.668 5.88 3.5 8 3.5s3.879 1.168 5.168 2.457A13 13 0 0 1 14.828 8q-.086.13-.195.288c-.335.48-.83 1.12-1.465 1.755C11.879 11.332 10.119 12.5 8 12.5s-3.879-1.168-5.168-2.457A13 13 0 0 1 1.172 8z"/> -->
            <!--     <path d="M8 5.5a2.5 2.5 0 1 0 0 5 2.5 2.5 0 0 0 0-5M4.5 8a3.5 3.5 0 1 1 7 0 3.5 3.5 0 0 1-7 0"/> -->
            <!--   </svg>    -->
            <input class="toggle toggle-info checkbox-xs" type="checkbox" bind:checked={token.watched} />
            <!-- </label> -->
            <span>{token.symbol || token.canister_id}: {token.balance }</span>
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
                onclick={() => showAddTokenInput = !showAddTokenInput}
        >+ Add Token</button>
      {:else}
        <div class="join">
        <button class="btn btn-error btn-xs join-item"
                onclick={() => showAddTokenInput = !showAddTokenInput}
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
                //wallet.refreshWatchedICRC1Tokens();
                walletAddToken.value = "";
                // alert(wallet.icrc1_tokens);
                // showAddTokenInput = !showAddTokenInput;
                }}
        >+</button>
        </div>

      {/if}
      </div>
    {/if}

<!-- Open the modal using ID.showModal() method -->
  <dialog id="icrc1_tansfer_modal" class="modal">
    <div class="modal-box">
      <h3 class="text-lg font-bold">Transfer</h3>
      <p class="py-4">Balance: {icrc1_token_to_transfer.balance} {icrc1_token_to_transfer.symbol}</p>
          <!-- <h3 class="pb-4">{icrc1_token_to_transfer.symbol || icrc1_token_to_transfer.canister_id} Transfer:</h3> -->
          <form id="transfer_form" action="#" onsubmit={onSubmitICRC1Transfer}>
            <label class="floating-label"
                   for="transfer_to">
              <input class="input" size="64" id="transfer_to" alt="Transfer to input" type="text"
                placeholder="Destination principal:"
              />
              <span>Destination principal: &nbsp;</span>
            </label>
            <div>
              <label class="floating-label inline-block"
                     for="transfer_amount">
                <input class="input" id="transfer_amount" alt="Transfer amount input" type="text"
                  placeholder="Amount to transfer: "
                />
                <span>Amount to transfer: </span>
              </label>
              <span class="align-middle">{icrc1_token_to_transfer.symbol}</span>
            </div>
            <button class="btn btn-info"
              id="transfer_amount_submit" type="submit">Send</button>
            <span class="text-error">{transfer_error_message}</span>
          </form>
    </div>

    <form method="dialog" class="modal-backdrop">
      <button>close</button>
    </form>
  </dialog>

<!-- Open the modal using ID.showModal() method -->
  <dialog id="login_modal" class="modal">
    <div class="modal-box center">
      <h3 class="text-lg font-bold">Login</h3>
      <p class="py-4">
        Internet Identity
      </p>
      {#if (auth.isAuthenticated == false)}
        <button class="btn" onclick={login}>II Login</button>
      {:else}
        <button class="btn btn-error" onclick={logout}>Logout</button>
      {/if}
      <p class="py-4">
        PEM Key
      </p>
      <button class="btn" onclick={()=>{updateActor({random: true}); login_modal.close();}}>Random ID</button>
      <form onsubmit={async (e)=> {
            e.preventDefault();
            const pem_str : string = await pem_string;
            updateActor({pem: pem_str});
            login_modal.close();
            }}>
        <input bind:files={pem_file} class="file-input" type="file" accept=".pem" required>
        <button
          class="btn btn-warning"
          type="reset" >
          Reset
        </button>
        <button
          class="btn btn-info"
          type="submit" >
          pem login
        </button>
      </form>
    </div>

    <form method="dialog" class="modal-backdrop">
      <button>close</button>
    </form>
  </dialog>


  </div>
</div>

