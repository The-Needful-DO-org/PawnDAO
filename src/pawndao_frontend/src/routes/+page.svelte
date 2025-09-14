<script>
  import { preventDefault } from 'svelte/legacy';

  import "../index.scss";
  import { backend } from "$lib/canisters";

  let greeting = $state("");

  function onSubmit(event) {
    const name = event.target.name.value;
    backend.greet(name).then((response) => {
      greeting = response;
    });
    return false;
  }
</script>

<main>
  <!-- <div class="hero bg-base-200 min-h-screen"> -->
  <div class="hero bg-base-200 min-h-[calc(100vh-65px)]">
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

  <br />
  <br />
  <img src="/logo2.svg" alt="DFINITY logo" />
  <br />
  <br />
  <form action="#" onsubmit={preventDefault(onSubmit)}>
    <label for="name">Enter your name: &nbsp;</label>
    <input id="name" alt="Name" type="text" />
    <button type="submit">Click Me!</button>
  </form>
  <section id="greeting">{greeting}</section>
</main>
