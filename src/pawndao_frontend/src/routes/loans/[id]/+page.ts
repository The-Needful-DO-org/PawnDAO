import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { backend } from "$lib/canisters";
import { HttpAgent } from "@dfinity/agent";

export const load: PageLoad = async ({params}) => {
  if (process.env.DFX_NETWORK !== "ic") {
  // Only in local/dev, never on mainnet:
    const agent = new HttpAgent({ /* no identity = anonymous */ });
    await agent.fetchRootKey();
  }

  const loan = await backend.loanById(Number(params.id)).then((response) => {
    return response[0];
  });

  // const loan = await backend.loansAll().then((response) => {
  //   return response[params.id];
  // });

	if (loan) {
		return {
      loan: loan,
		};
	}

	error(404, 'Not found');
};
