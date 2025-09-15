<script lang="ts">
  import "../app.css";
  // import "../index.scss";
 //  import Wallet from "../lib/Wallet.svelte";
	// // import type { PageProps } from './$types';
 //  import { page } from '$app/state'
 //  import { backend } from "$lib/canisters";
 //  import { auth, getIdentityProvider } from "$lib/../stores/auth";
 //  import { onMount } from "svelte";
 //  import { tick } from 'svelte';
	let { children } = $props();
  import Navbar from "$lib/components/Navbar.svelte";

</script>

<Navbar/>

{@render children()}

{#if process.env.DFX_NETWORK !== "ic"}
  <script src="https://cdn.jsdelivr.net/npm/eruda"></script>
  <script>eruda.init();</script>
{/if}
