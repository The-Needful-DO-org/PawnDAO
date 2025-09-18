import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { backend } from "$lib/canisters";

export const load: PageLoad = async () => {
  // const response = await fetch('https://jsonplaceholder.typicode.com/posts');
  const loans = await backend.loansAll().then((response) => {
    return response;
  });
	// if (params.slug === 'hello-world') {
		return {
      loans: loans
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
