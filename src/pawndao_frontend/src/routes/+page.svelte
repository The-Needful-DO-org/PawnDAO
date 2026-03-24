<script>
  import { preventDefault } from 'svelte/legacy';
  import { AuthClient } from '@dfinity/auth-client';
  import { createActor } from '../../../declarations/pawndao_backend';
  import { canisterId } from '../../../declarations/pawndao_backend';
  import { auth } from '$lib/auth.svelte.ts'
  import { whoami } from '$lib/auth.svelte.ts'
  import { updateActor } from '$lib/auth.svelte.ts'
  import { login } from '$lib/auth.svelte.ts'
  import { logout } from '$lib/auth.svelte.ts'


  // import "../index.scss";
  import { backend } from "$lib/canisters";
  import {onMount} from 'svelte';

  import { browser } from '$app/environment';

  // Initialize auth client
  onMount(() => {
    // browser filter for testing env
    if (browser && process.env.NODE_ENV != "test") {
       // do that
      updateActor();
    } else {
      // do this
    }
  });

  let greeting = $state("");
  // let name = $state("");

  function onSubmit(event) {
    const name = event.target.elements.name.value;
    backend.greet(name).then((response) => {
      greeting = response;
    }).catch((error) => {
      console.log(error);
      greeting = error;
    });
    return false;
  }
</script>

<main class="flex-1 bg-base-200">

  <!-- <div class="hero bg-base-200 min-h-screen"> -->
  <div class="hero bg-base-200 min-h-[calc(80vh-65px)] md:min-h-[calc(50vh-65px)] -mt-[2.5em]">
    <div class="hero-content text-center">
      <div class="max-w-md">
        <h1 class="text-5xl font-bold">The People's Pawn Shop</h1>
        <p class="py-6">
          Peer to peer crypto lending. Borrow using ICP ICRC tokens as collateral.
          Lend to earn interest or receive the collateral if the borrower defaults.
        </p>
        <a href="/borrow">
          <button class="btn btn-primary">Borrow</button>
        </a>
        <a href="/lend">
          <button class="btn btn-secondary">Lend</button>
        </a>
        <a href="/learn">
          <button class="btn btn-outline">Learn More</button>
        </a>
      </div>
    </div>
  </div>

</main>
