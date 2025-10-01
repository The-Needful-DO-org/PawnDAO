<script>
  // Add any necessary script logic here
  import { page } from '$app/stores';
</script>

<!-- <nav class="navbar bg-base-100 shadow container mx-auto"> -->
<nav class="navbar bg-base-100 shadow">
  <div class="flex-1">
    <a href="/" class="btn btn-ghost normal-case text-xl">
      <!-- Replace with your logo image if desired -->
      PawnDAO
    </a>
  </div>
  <div class="flex-none">
    <ul class="menu menu-horizontal px-1">
      <li>
        <a href="/borrow" class:menu-active={$page.url.pathname == "/borrow"}>Borrow</a>
      </li>
      <li>
        <a href="/lend" class:menu-active={$page.url.pathname == "/lend"}>Lend</a>
      </li>
      <li>
        <a href="/loans" class:menu-active={$page.url.pathname == "/loans"}>Loans</a>
      </li>
      <li class="hidden md:block">
        <a href="/learn" class:menu-active={$page.url.pathname == "/learn"}>Learn</a>
      </li>
    </ul>
  </div>
</nav>
