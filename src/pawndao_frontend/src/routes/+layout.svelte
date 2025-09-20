<script lang="ts">
  import "../app.css";
  // import "../index.scss";
  import WalletBar from "$lib/components/WalletBar.svelte";
	// // import type { PageProps } from './$types';
 //  import { page } from '$app/state'
 //  import { backend } from "$lib/canisters";
 //  import { auth, getIdentityProvider } from "$lib/../stores/auth";
 import { onMount } from "svelte";
 //  import { tick } from 'svelte';
	let { children } = $props();
  import Navbar from "$lib/components/Navbar.svelte";

  onMount(() => {

  // debugging tool eruda
    if (process.env.DFX_NETWORK !== "ic") {
      const script = document.createElement('script');
      script.onload = () => {
        if (eruda) {
          eruda.init();
        }
      };
      script.src = 'https://cdn.jsdelivr.net/npm/eruda';
      document.head.appendChild(script);
    }

  });



</script>

<Navbar/>

<WalletBar/>

{@render children()}

{#if process.env.DFX_NETWORK !== "ic"}
  <script src="https://cdn.jsdelivr.net/npm/eruda"></script>
  <script>eruda.init();</script>
{/if}
