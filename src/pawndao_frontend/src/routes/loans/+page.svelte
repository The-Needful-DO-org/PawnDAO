<script lang="ts">
  import {auth} from "$lib/auth.svelte";
  import { backend } from "$lib/canisters";
  import type { PageProps } from './$types';
  import type { Loan as LoanType } from '../../../../../../../declarations/pawndao_backend/pawndao_backend.did.d.ts'; 
  import Loan from '$lib/components/Loan.svelte'
	let { data }: PageProps = $props();
  let loans : LoanType[] = $state(data.loans);

  async function refreshLoans() {
    // TODO a backend query for loanoffers by loanrequest id
    const loansAll = await backend.loansAll().then((response) => {
      return response;
    });
    // const loanOffers:LoanOffer[] = Array.from(loanOffersAll).filter((offer:LoanOffer) => { return offer.loan_request_id === data.loanRequest.id });
    loans = loansAll;
  }

</script>

<main class="prose">
  <div class="container mx-auto">
  <h1>My Loans</h1>
  <h2>Active</h2>
  <h3>Borrowing</h3>
  {#each loans.filter((loan) => Object.entries(loan.status)[0][0] === "Active" && loan.borrower_user_id.toString() == auth.principal ) as loan : LoanType}
    <Loan {loan} />
  {:else}
    <div class="text-center">- None -</div>
  {/each}

  <h3>Lending</h3>
  {#each loans.filter((loan) => Object.entries(loan.status)[0][0] === "Active" && loan.lender_user_id.toString() == auth.principal ) as loan : LoanType}
    <Loan {loan} />
  {:else}
    <div class="text-center">- None -</div>
  {/each}


  <h2>Ended</h2>
  <h3>Borrowing</h3>
  {#each loans.filter((loan) => Object.entries(loan.status)[0][0] != "Active" && loan.borrower_user_id.toString() == auth.principal ) as loan : LoanType}
    <Loan {loan} />
  {:else}
    <div class="text-center">- None -</div>
  {/each}

  <h3>Lending</h3>
  {#each loans.filter((loan) => Object.entries(loan.status)[0][0] != "Active"
    && loan.lender_user_id.toString() == auth.principal 
    ) as loan : LoanType}
    <Loan {loan} />
  {:else}
    <div class="text-center">- None -</div>
  {/each}


  <h1>Other Loans</h1>
  <h2>Active</h2>
  {#each loans.filter((loan) => (Object.entries(loan.status)[0][0] === "Active")
    // && loan.lender_user_id.toString() != auth.principal 
    // && loan.borrower_user_id.toString() != auth.principal 
    // && console.log(loan.borrower_user_id , auth.principal )
    && [loan.borrower_user_id.toString(), loan.lender_user_id.toString()].includes(auth.principal?.toString()) === false
    ) as loan : LoanType}
    <Loan {loan} />
  {:else}
    <div class="text-center">- None -</div>
  {/each}

  <h2>Ended</h2>
  {#each loans.filter((loan) => Object.entries(loan.status)[0][0] != "Active"
    && [loan.borrower_user_id.toString(), loan.lender_user_id.toString()].includes(auth.principal?.toString()) === false
    ) as loan : LoanType}
    <Loan {loan} />
  {:else}
    <div class="text-center">- None -</div>
  {/each}
  </div>


</main>
