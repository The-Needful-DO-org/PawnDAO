<script lang="ts">
  import { onMount } from "svelte";
  import { auth } from "$lib/auth.svelte";
  import { goto } from "$app/navigation";

  onMount(() => {
    // If not authenticated, redirect or show message
    if (!auth.isAuthenticated) {
      // Option: redirect to home
      // goto("/");
    }
  });

  async function subscribeToNotifications() {
      const sw = await navigator.serviceWorker.ready;
      const subscription = await sw.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlBase64ToUint8Array("BCoiBTMpspyt6CyJwixHvr6-urI5HRREh9x7NW_EpiRC-A17HVI6jbhD1P2fQpYU-RzUHi8t1SgAXvQlWCbr3ps")
      });
      console.log(subscription.endpoint);

    const subObject = JSON.stringify(subscription);
    console.log(subObject);
    alert("Subscribed!");
  }

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
</script>

<div class="container mx-auto p-4">
  <h1 class="text-2xl font-bold mb-4">User Settings</h1>

  {#if auth.isAuthenticated}
    <div class="card bg-base-200 p-6 shadow-sm">
      <h2 class="text-lg font-semibold mb-2">Notifications</h2>
      <p class="text-sm opacity-70 mb-4">Manage your subscription preferences here.</p>
      <button class="btn btn-primary" onclick={subscribeToNotifications}>
        Subscribe to Notifications
      </button>
    </div>
  {:else}
    <div class="alert alert-warning">
      <span>Please authenticate to view your settings.</span>
    </div>
  {/if}
</div>
