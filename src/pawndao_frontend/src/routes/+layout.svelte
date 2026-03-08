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

  let isDebug = false;

  onMount(async () => {
    const url = new URL(window.location.href);
    isDebug = url.searchParams.get('debug') === 'true';
    if (isDebug) {
      console.log('Debug mode: activated');
      const eruda = (await import('eruda')).default;
      eruda.init();
    }
  });

  onMount(async () => {
    if (process.env.DFX_NETWORK == "ic") return;
    const eruda = (await import('eruda')).default;
    eruda.init();
  });


</script>

<Navbar/>

<WalletBar/>

{@render children()}

