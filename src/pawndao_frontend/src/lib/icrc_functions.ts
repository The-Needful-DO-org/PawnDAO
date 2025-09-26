import {HttpAgent} from "@dfinity/agent";
import { IcrcLedgerCanister } from "@dfinity/ledger-icrc";
import { mapTokenMetadata } from "@dfinity/ledger-icrc";
import type { BalanceParams } from "@dfinity/ledger-icrc";
import { Principal } from "@dfinity/principal";

export async function icrc1_balance(principal : Principal, canister_id : Principal) {

  const agent = new HttpAgent({ /* no identity = anonymous */ });
  if (process.env.DFX_NETWORK !== "ic") {
  // Only in local/dev, never on mainnet:
    await agent.fetchRootKey();
  }
  // console.log(agent);
  // console.log(`${await agent.getPrincipal()}`);

    // const { metadata } = IcrcLedgerCanister.create({
    //   agent,
    //   canisterId: Principal.fromText(canister_id),
    // });

    const { balance } = IcrcLedgerCanister.create({
      agent,
      canisterId: canister_id,
    });

    const icrc1BalanceOfArgs : BalanceParams = {
      owner: principal,
      subaccount: undefined,
    };

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


export async function icrc1_decimals(canister_id : Principal) : Promise<Number> {

  const agent = new HttpAgent({ /* no identity = anonymous */ });
  if (process.env.DFX_NETWORK !== "ic") {
  // Only in local/dev, never on mainnet:
    await agent.fetchRootKey();
  }

    const ledger = IcrcLedgerCanister.create({
      agent,
      canisterId: canister_id,
    });

    try {
        // Code that might throw an error
        const meta_response = await ledger.metadata({certified: false});
        // console.log(meta_response);
        const meta_map = mapTokenMetadata(meta_response);
        // return meta_response;
        return meta_map?.decimals;
    } catch (error) {
        // Handle the exception
        console.error('An error occurred:', error.message);
        return error;
    }

}

