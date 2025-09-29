import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { backend } from "$lib/canisters";
import { HttpAgent } from "@dfinity/agent";


async function getLoanRequests() {
  // const loanRequests = await backend.loanRequestsAll();
  const loanRequests = await backend.loanRequestsAll().then((response) => {
  // const loanRequests = await backend.loanRequestsGetByUserNot(user_id ).then((response) => {
    return response;
  });
  // console.log(loanRequests);
  return loanRequests;

}
export const load: PageLoad = async () => {
  const agent = new HttpAgent({ /* no identity = anonymous */ });
  if (process.env.DFX_NETWORK !== "ic") {
  // Only in local/dev, never on mainnet:
    await agent.fetchRootKey();
  }

const user_id = (await agent.getPrincipal());
  // const response = await fetch('https://jsonplaceholder.typicode.com/posts');
  // const loanRequests = await backend.loanRequestsAll().then((response) => {
  //   return response;
  // });
	// if (params.slug === 'hello-world') {
		return {
      // loanRequests: loanRequests
      loanRequests: getLoanRequests(),
      current_user_id: user_id
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
