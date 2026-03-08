import { AuthClient } from '@dfinity/auth-client';
import { createActor } from '../../../declarations/pawndao_backend';
import { canisterId } from '../../../declarations/pawndao_backend';
import { Secp256k1KeyIdentity } from '@dfinity/identity-secp256k1';
import { Principal } from '@dfinity/principal';
import { Ed25519KeyIdentity } from '@dfinity/identity';
import { invalidateAll } from '$app/navigation';

// Generate a new Ed25519 identity in the frontend
// const identity = Ed25519KeyIdentity.generate();


const pem_raw = `-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIEfWpA1TPKMAXKfSFXawBURQQmOq3BPDU9Mq4bmGtptQoAcGBSuBBAAK
oUQDQgAEgY2Rd6cOJL10yXwaTJzdPBl2zrffBzstvac4Ock6MdA8ls/MaaWocNOm
vMfR6ZjU7AUkDeO6u+OHe+FIeMo9Fg==
-----END EC PRIVATE KEY-----`

const pem_identity = Secp256k1KeyIdentity.fromPem(pem_raw);

// const pem_identity = Ed25519KeyIdentity.fromSecretKey(pem);
// Now you can use `identity` to authenticate with an agent

const network = process.env.DFX_NETWORK;
const identityProvider =
  network === 'ic'
    ? 'https://id.ai/' // Mainnet
    : 'http://rdmx6-jaaaa-aaaaa-aaadq-cai.localhost:4943'; // Local
    // : 'http://10.0.0.200:4943/?canisterId=uqqxf-5h777-77774-qaaaa-cai&id=u6s2n-gx777-77774-qaaba-cai'; // Local

  export const auth = $state({
    actor: undefined,
    authClient: undefined,
    identity: undefined,
    isAuthenticated: false,
    principal: undefined
  });

  // TODO remember pem login
  export const updateActor = async (options?:object) => {
    const authClient = await AuthClient.create();
    let identity;
    // console.log(pem);
    // if (typeof(options?.pem) == "string") {
    if (options?.pem) {
      // alert("pem");
      const pem_identity = Secp256k1KeyIdentity.fromPem(options.pem);
      identity = pem_identity;
    } else if (options?.random) {
      // alert("rand");
      identity = Ed25519KeyIdentity.generate();
    } else if (options?.ii) {
      // alert("ii");
      // internet identity
      identity = authClient.getIdentity();
    } else {
      identity = auth.identity || authClient.getIdentity();
    }
    const actor = createActor(canisterId, {
      agentOptions: {
        identity
      }
    });
    const isAuthenticated = await authClient.isAuthenticated();
  
    // console.log(auth);
    // console.log(authClient);
    // console.log(authClient._identity?._principal?.toString());
    // console.log(actor);
    // console.log("identity");
    // console.log(identity);
    // console.log(identity.constructor.name);
    // console.log(identity.getPrincipal().toString());
    // console.log(identity?._principal?.toString());

    auth.actor = actor
    auth.authClient = authClient
    auth.identity = identity
    auth.isAuthenticated = isAuthenticated

    if (["DelegationIdentity", "zi", "Vt"].includes(identity.constructor.name)) {
      // works for II
      auth.principal =  authClient?._identity?.getPrincipal() || auth.principal
    } else if (["_Secp256k1KeyIdentity"].includes(identity.constructor.name)) {
      // works for pem
      auth.principal = identity.getPrincipal() || auth.principal
    } else {
      // works for II
      auth.principal =  authClient?._identity?.getPrincipal() || auth.principal
    }

    // Cannot reassign exported state var
    // auth = {
    //   actor,
    //   authClient,
    //   isAuthenticated,
    //   // principal: auth.principal
    //   principal: authClient?._identity?.getPrincipal() || auth.principal
    // };
    // console.log(auth);

    // TODO is this a good invalidation tactic?
    invalidateAll();
  };

  export const login = async () => {
    await auth.authClient.login({
      identityProvider,
      onSuccess: updateActor
    });
  };

  export const logout = async () => {
    await auth.authClient.logout();
    updateActor();
  };

  export const whoami = async () => {
    auth.principal = 'Loading...';

    const result = await auth.actor.whoami();
    const principal = result.toString();
    auth.principal = Principal.fromText(principal);
  };


