<script>
  import { page } from '$app/stores';
</script>

<footer class="footer footer-center bg-base-200 text-base-content p-10 mt-auto">
  <nav>
    <div class="grid grid-flow-col gap-4">
      <a href="/learn" class="link link-hover" class:font-bold={$page.url.pathname === "/learn"}>Learn</a>
    </div>
  </nav>
  <aside>
    <!-- <p>Copyright © {new Date().getFullYear()} PawnDAO. All rights reserved.</p> -->
    <p>PawnDAO</p>
    <img src="/pawndao.svg" />
  </aside>
</footer>
