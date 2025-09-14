<script>
  import { preventDefault } from 'svelte/legacy';

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
  <div class="container mx-auto">
    <h1>Borrow</h1>

  </div>
</main>
