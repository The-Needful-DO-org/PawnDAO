import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import type { LoanOffer, LoanRequest } from '../../../../../../../declarations/pawndao_backend/pawndao_backend.did.d.ts'; 
import { backend } from "$lib/canisters";

export const load: PageLoad = async ({params}) => {

  const loanRequest:LoanRequest = await backend.loanRequestByIdAsync(Number(params.id)).then((response:LoanRequest[]) => {
    return response[0];
  });
  // const loanOffer:LoanOffer = await backend.loanOfferByIdAsync(Number(params.id)).then((response:LoanOffer[]) => {
  //   return response[0];
  // });

  const loanOffer:LoanOffer = await backend.loanOfferByIdAsync(Number(params.loanOfferId));

  if (loanRequest  != null) {
		return {
      loanRequest: loanRequest,
      loanOffer: loanOffer
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
