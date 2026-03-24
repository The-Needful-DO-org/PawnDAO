<script lang="ts">
  import "../app.css";
  import { dev } from '$app/environment';
  // import "../index.scss";
  import WalletBar from "$lib/components/WalletBar.svelte";
	// // import type { PageProps } from './$types';
 //  import { page } from '$app/state'
 //  import { backend } from "$lib/canisters";
 //  import { auth, getIdentityProvider } from "$lib/../../stores/auth";
 import { onMount } from "svelte";
 //  import { tick } from 'svelte';
	let { children } = $props();
  import Navbar from "$lib/components/Navbar.svelte";
  import Footer from "$lib/components/Footer.svelte";

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
    if (!dev)  return ;
    const eruda = (await import('eruda')).default;
    eruda.init();
  });

  onMount( async () => {
    navigator.serviceWorker.register('/service-worker.js', {
      type: dev ? 'module' : 'classic'
    });

  });

</script>

<div class="flex flex-col min-h-screen">
  <Navbar/>

  <WalletBar/>

  {@render children()}

  <Footer/>
</div>
