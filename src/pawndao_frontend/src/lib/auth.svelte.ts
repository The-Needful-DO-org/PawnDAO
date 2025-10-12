import { AuthClient } from '@dfinity/auth-client';
import { createActor } from '../../../declarations/pawndao_backend';
import { canisterId } from '../../../declarations/pawndao_backend';
const network = process.env.DFX_NETWORK;
const identityProvider =
  network === 'ic'
    ? 'https://id.ai/' // Mainnet
    : 'http://rdmx6-jaaaa-aaaaa-aaadq-cai.localhost:4943'; // Local
    // : 'http://10.0.0.200:4943/?canisterId=uqqxf-5h777-77774-qaaaa-cai&id=u6s2n-gx777-77774-qaaba-cai'; // Local

  export const auth = $state({
    actor: undefined,
    authClient: undefined,
    isAuthenticated: false,
    principal: 'Click "Whoami" to see your principal ID'
  });

  export const updateActor = async () => {
    const authClient = await AuthClient.create();
    const identity = authClient.getIdentity();
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
    console.log(identity);
    // console.log(identity?._principal?.toString());

    auth.actor = actor
    auth.authClient = authClient
    auth.isAuthenticated = isAuthenticated
    auth.principal = authClient?._identity?.getPrincipal() || auth.principal

    // Cannot reassign exported state var
    // auth = {
    //   actor,
    //   authClient,
    //   isAuthenticated,
    //   // principal: auth.principal
    //   principal: authClient?._identity?.getPrincipal() || auth.principal
    // };
    // console.log(auth);
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
    auth.principal = principal;
  };


