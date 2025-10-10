import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import type { LoanOffer, LoanRequest } from '../../../../../declarations/pawndao_backend/pawndao_backend.did.d.ts'; 
import { backend } from "$lib/canisters";
import {HttpAgent} from '@dfinity/agent';

export const load: PageLoad = async ({params}) => {
  const agent = HttpAgent.createSync();
  if (process.env.DFX_NETWORK !== "ic") {
  // Only in local/dev, never on mainnet:
    await agent.fetchRootKey();
  }


    const [loanRequestReq, loanOffersAllReq] = await Promise.all([
        backend.loanRequestByIdAsync(Number(params.id)),
        backend.loanOffersAll()
    ]);

    // if (true || loanRequestReq.ok && loanOffersAllReq.ok) {
    if (true) {
        const loanRequest = loanRequestReq[0];
        const loanOffers = loanOffersAllReq;
        return { loanRequest , loanOffers };
    }

    // return { error: 'Failed to fetch data' };

  // const response = await fetch('https://jsonplaceholder.typicode.com/posts');
  // const loanRequest:LoanRequest = await backend.loanRequestByIdAsync(Number(params.id)).then((response:LoanRequest[]) => {
  //   return response[0];
  // });
  // TODO a backend query for loanoffers by loanrequest id
  // const loanOffersAll:LoanOffer[] = await backend.loanOffersAll().then((response:LoanOffer[]) => {
  //   return response;
  // });
  // const loanOffers:LoanOffer[] = Array.from(loanOffersAll).filter((offer:LoanOffer) => { return offer.loan_request_id === loanRequest.id });

 //  if (loanRequest != null) {
	// 	return {
 //      loanRequest: loanRequest,
 //      loanOffers: loanOffers
	// 	};
	// }

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
