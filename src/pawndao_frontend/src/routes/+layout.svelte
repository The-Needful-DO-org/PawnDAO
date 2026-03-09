<script lang="ts">
  import "../app.css";
  import { dev } from '$app/environment';
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
    if (!dev)  return ;
    const eruda = (await import('eruda')).default;
    eruda.init();
  });

  async function subscribeToNotifications() {
      const sw = await navigator.serviceWorker.ready;
      const subscription = await sw.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlBase64ToUint8Array("BCoiBTMpspyt6CyJwixHvr6-urI5HRREh9x7NW_EpiRC-A17HVI6jbhD1P2fQpYU-RzUHi8t1SgAXvQlWCbr3ps")
      });
      console.log(subscription.endpoint);

    // Option 1: Use subscription.getKey() (returns ArrayBuffer)
    const p256dh = subscription.getKey('p256dh');
    const auth = subscription.getKey('auth');
    console.log(p256dh);
    console.log(auth);

    // Option 2: Serialize to JSON (automatically Base64-encoded)
    const subObject = JSON.stringify(subscription);
    console.log(subObject);
  }

  // for notification key
  function urlBase64ToUint8Array(base64String : String) {
    const padding = '='.repeat((4 - (base64String.length % 4)) % 4);
    const base64 = (base64String + padding)
      .replace(/-/g, '+')
      .replace(/_/g, '/');
    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i);
    }
    return outputArray;
  }

  onMount( async () => {
    navigator.serviceWorker.register('/service-worker.js', {
      type: dev ? 'module' : 'classic'
    });

  });

</script>

<Navbar/>

<WalletBar/>

<button onclick={subscribeToNotifications}>
  Subscribe
</button>

{@render children()}

