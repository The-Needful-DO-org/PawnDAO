// import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { backend } from "$lib/canisters";
import { HttpAgent } from "@dfinity/agent";

export const load: PageLoad = async ({depends}) => {
  depends('app:loanrequests');
  const agent = new HttpAgent({ /* no identity = anonymous */ });
  if (process.env.DFX_NETWORK !== "ic") {
    // Only in local/dev, never on mainnet:
    await agent.fetchRootKey();
  }

  const user_id = (await agent.getPrincipal());
  // const response = await fetch('https://jsonplaceholder.typicode.com/posts');
  // const loanRequests = await backend.loanRequestsAll().then((response) => {
  const loanRequests = await backend.loanRequestsGetByUser(user_id ).then((response) => {
    return response;
  });
	// if (params.slug === 'hello-world') {
		return {
      loanRequests: loanRequests
		};
	// }

	// error(404, 'Not found');
};

// +page.ts
// import type { PageLoad } from './$types';
//
// export const load: PageLoad = async ({ fetch }) => {
//   const response = await fetch('https://jsonplaceholder.typicode.com/posts');
//   const data = await response.json();
//   return { posts: data };
// };
