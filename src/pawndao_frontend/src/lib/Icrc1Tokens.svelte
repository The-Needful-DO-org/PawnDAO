<script lang="ts" module>
import {HttpAgent} from "@dfinity/agent";
import { IcrcLedgerCanister } from "@dfinity/ledger-icrc";
import { Principal } from "@dfinity/principal";

  console.log("icrc1 sscript");
  // helper to parse icrc1_metadata
  function valueToJs(v: any): string | number | bigint | Uint8Array {
    if ("Text" in v) return v.Text;
    if ("Nat" in v) return BigInt(v.Nat);
    if ("Int" in v) return BigInt(v.Int);
    if ("Blob" in v) return new Uint8Array(v.Blob);
    return v;
  }

    export let Icrc1Tokens = $state([
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
      // {
      //   canister_id: 'llcdy-4qaaa-aaaah-arcua-cai',
      //   // symbol: "TPAWN",
      //   watched: true
      // },
      {
        canister_id: 'ryjl3-tyaaa-aaaaa-aaaba-cai',
        symbol: "LICP",
        watched: false
      },
    ]);

// Icrc1Tokens.shift();

export function refreshAllICRC1Tokens() {
  console.log("refreshicrc1");
  Icrc1Tokens.forEach(async (token) => {
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
    console.log(token.decimals);
    console.log(token.canister_id);
    console.log(token.metadata);
  });
}

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

</script>

<script lang="ts">
  console.log("icrc1 sscript");
  refreshAllICRC1Tokens();
</script>
