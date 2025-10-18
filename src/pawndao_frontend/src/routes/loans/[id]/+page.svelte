<script lang="ts">
  import {auth} from "$lib/auth.svelte";
  import { backend } from "$lib/canisters";
  import type { PageProps } from './$types';
  import type { Loan as LoanType } from '../../../../../../../declarations/pawndao_backend/pawndao_backend.did.d.ts'; 
  import Loan from '$lib/components/Loan.svelte'
	let { data }: PageProps = $props();
  let loan : LoanType[] = $state(data.loan);


</script>

<main>
  {console.log(data.loan_byid)}
  <div class="container mx-auto">
    <Loan {loan} />
  </div>
</main>
