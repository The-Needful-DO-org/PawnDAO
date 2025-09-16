import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { backend } from "$lib/canisters";

export const load: PageLoad = async ({params}) => {
  // const response = await fetch('https://jsonplaceholder.typicode.com/posts');
  const loanRequest = await backend.loanRequestByIdAsync(Number(params.id)).then((response) => {
    return response[0];
  });
  if (loanRequest  != null) {
		return {
      loanRequest: loanRequest
		};
	}

	error(404, 'Not found');
};

// +page.ts
// import type { PageLoad } from './$types';
//
// export const load: PageLoad = async ({ fetch }) => {
//   const response = await fetch('https://jsonplaceholder.typicode.com/posts');
//   const data = await response.json();
//   return { posts: data };
// };
