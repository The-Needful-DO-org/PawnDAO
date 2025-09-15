<script>
  // Add any necessary script logic here
  // import { page } from '$app/stores';
  import { backend } from "$lib/canisters";
  import { Principal } from "@dfinity/principal";
  let greeting = $state("");
  let notification = $state("");

  function loanRequestSubmit(event) {
    // console.log(event.target.collateral_canister_id);
    // console.log(typeof(event.target.collateral_canister_id));
    const collateral_canister_id = Principal.fromText(event.target.collateral_canister_id.value);
    const collateral_amount = Number(event.target.collateral_amount.value);
    // const desired_asset_canister_ids = event.target.desired_asset_canister_ids.value;
    const desired_asset_canister_ids = [Principal.fromText(event.target.collateral_canister_id.value)];
    // const desired_asset_canister_ids = [];
    // const desired_amounts = event.target.desired_amounts.value;
    // const desired_amounts = [event.target.desired_amounts.value];
    const desired_amounts = [];
    const desired_duration = Number(event.target.desired_duration.value);
    const desired_interest = Number(event.target.desired_interest.value);
    backend.loanRequestNew(
        collateral_canister_id,
        collateral_amount,
        desired_asset_canister_ids,
        desired_amounts,
        desired_duration,
        desired_interest,
    ).catch((error) => {
      console.log(error);
      notification = error;
    }).then((response) => {
      greeting = response;
    });
    return false;
  }
</script>

{notification}
{greeting}

<div class="flex justify-center items-center w-full min-h-screen px-5 py-5">
  <div class="xl:max-w-7xl drop-shadow-xl border border-black/20 w-full rounded-md flex justify-between items-stretch px-5 xl:px-5 py-5">
    <div class="mx-auto w-full lg:w-1/2 md:p-10 py-5 md:py-0">
      <h1 class="text-center text-2xl sm:text-3xl font-semibold text-[#4A07DA]">Create Loan Request</h1>
      <form class="w-full mt-5 sm:mt-8" onsubmit={loanRequestSubmit}>
        <div class="mx-auto w-full sm:max-w-md md:max-w-lg flex flex-col gap-5">
          <!-- Collateral Canister ID Input -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">Collateral Canister ID</span>
            </label>
            <input
              type="text"
              name="collateral_canister_id"
              placeholder="Enter canister ID"
              class="input input-bordered input-primary w-full max-w-xs"
              required
            />
          </div>

          <!-- Collateral Amount Input -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">Collateral Amount</span>
            </label>
            <input
              type="number"
              name="collateral_amount"
              placeholder="Enter amount"
              class="input input-bordered input-primary w-full max-w-xs"
              required
            />
          </div>

          <div class="form-control">
            <label class="label" for="desired_asset_canister_ids">
              <span class="label-text">desired_asset_canister_ids</span>
            </label>
            <input
              type="text"
              name="desired_asset_canister_ids"
              id="desired_asset_canister_ids"
              placeholder="Enter desired asset canister IDs"
              class="input input-bordered input-primary w-full max-w-xs"

            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">desired_amounts</span>
            </label>
            <input
              type="text"
              name="desired_amounts"
              placeholder="Enter desired asset amounts"
              class="input input-bordered input-primary w-full max-w-xs"

            />
          </div>

          <!-- Duration Input -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">Duration (days)</span>
            </label>
            <input
              type="number"
              name="desired_duration"
              placeholder="Enter duration in days"
              class="input input-bordered input-primary w-full max-w-xs"

            />
          </div>

          <!-- Interest Input -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">Interest</span>
            </label>
            <input
              type="number"
              step="0.01"
              name="desired_interest"
              placeholder="Enter interest"
              class="input input-bordered input-primary w-full max-w-xs"

            />
          </div>

          <!-- Submit Button -->
          <div class="flex flex-col md:flex-row gap-2 md:gap-4 justify-center items-center">
            <button type="submit" class="btn btn-active btn-primary btn-block max-w-[200px]">
              Submit
            </button>
            <!-- <button type="reset" class="btn btn-outline btn-primary btn-block max-w-[200px]"> -->
            <!--   Reset -->
            <!-- </button> -->
          </div>
        </div>
      </form>
    </div>
  </div>
</div>   

