<script lang="ts">
  import {auth} from "$lib/auth.svelte";
  import { wallet } from "$lib/components/WalletBar.svelte";
  import { formatDistanceToNow } from 'date-fns';

  let { loan } = $props();
  let loan_asset_token = $derived(wallet.icrc1_tokens.find(token => token.canister_id === loan.loan_asset_canister_id.toString()));
  let collateral_asset_token = $derived(wallet.icrc1_tokens.find(token => token.canister_id === loan.collateral_canister_id.toString()));
  let allowance_bool = $derived(wallet.validateICRC2Allowance(loan.loan_asset_canister_id, wallet.principal, loan.loan_amount))
  let endDate = $derived(new Date(Number(loan.timestamp)/1000000+(86400000*Number(loan.duration))));
  let repay_amount = $derived.by(() => {
    let amount = Number(loan.loan_amount) * (1 + Number(loan.interest)/100);
    if (loan_asset_token) {
     amount = amount / 10**Number(loan_asset_token.decimals)
    } else {
      return `${Math.round(amount)}nat`;
    }
    return amount;
  })

  wallet.addICRC1Token(loan.loan_asset_canister_id);
  wallet.addICRC1Token(loan.collateral_canister_id);

  // Handler to accept a loan offer via loanOfferAccept
  async function loanRepay(loan_id:BigInt) {
    // TODO handle allowance
    try {
      await auth.actor.loanRepay(loan_id);
      alert("Loan repaid!");
      // Optionally refresh data or update UI here
    } catch (e) {
      alert("Error repaying loan: " + e);
    }
    refreshLoan(loan_id);
  }

  // Handler to default a loan via loanDefault
  async function loanDefault(loan_id: BigInt) {
    try {
      await auth.actor.loanDefault(loan_id);
      alert("Loan defaulted!");
      // Optionally refresh data or update UI here
    } catch (e) {
      alert("Error defaulting loan: " + e);
    }
    refreshLoan(loan_id);
  }

  async function refreshLoan(loan_id) {
    // TODO a backend query for loanoffers by loanrequest id
    const loanById = await auth.actor.loanById(loan_id).then((response) => {
      return response;
    });
    console.log(loanById);
    // const loanOffers:LoanOffer[] = Array.from(loanOffersAll).filter((offer:LoanOffer) => { return offer.loan_request_id === data.loanRequest.id });
    loan = loanById[0];
  }


</script>
    <div class="card bg-neutral">
      <div class="card-body">
        <span>Loan: </span>
        <a href="/loans/{loan.id}">
        <span>#{loan.id}</span>
        </a>

        <div class="grid grid-cols-3 gap-2 wrap-anywhere text-primary-content/70">

          <div><strong>Status:</strong> {Object.entries(loan.status)[0][0]}</div>

          <div>
            <span>Borrower User: </span>
            <span>{loan.borrower_user_id}</span>
          </div>

          <div>
            <span>Lender User: </span>
            <span>{loan.lender_user_id}</span>
          </div>

          <div>
            <span>Collateral: </span>
            <!-- <span>{typeof collateral_asset_token?.decimals !== 'undefined' ? Number(loan.collateral_amount)/10**Number(collateral_asset_token?.decimals) : loan.collateral_amount + "nat"}</span> -->
            <span>{collateral_asset_token?.decimals ? Number(loan.collateral_amount)/10**Number(collateral_asset_token?.decimals) : loan.collateral_amount + "nat"}</span>
            <span>{collateral_asset_token?.symbol}</span>
            <span>{loan.collateral_canister_id}</span>
          </div>

          <div>
            <span>Loaned: </span>
            <span>{loan_asset_token?.decimals ? Number(loan.loan_amount)/10**Number(loan_asset_token?.decimals) : loan.loan_amount + "nat"}</span>
            <!-- <span>{loan.loan_amount}</span> -->
            <span>{loan_asset_token?.symbol}</span>
            <span>{loan.loan_asset_canister_id}</span>
          </div>

          <div>
            <span>Interest: </span>
            <span>{loan.interest} %</span>
          </div>

          <div>
            <span>Repay Amount: </span>
            <span>{repay_amount} {loan_asset_token?.symbol || loan.loan_asset_canister_id}</span>
          </div>

          <div>
            <span>Duration: </span>
            <span>{loan.duration} Days</span>
          </div>

          <div>
            <span>Started: </span>
            <span>{new Date(Number(loan.timestamp)/1000000)}</span>
          </div>

          <div>
            <span>Time Remaining: </span>
            <!-- <span>{endDate}</span> -->
            <span>
                {new Date - endDate > 0 ? "Ended " : ""}
                {formatDistanceToNow(endDate)}
                <!-- {formatDistanceToNow(endDate, { addSuffix: true })} -->
                {new Date - endDate > 0 ? " ago" : ""}
            </span>
          </div>

        </div>

        <div class="divider"></div>

        <!-- validate allowance -->
        <!-- {@const bro = "bro"} -->
        {#if loan.borrower_user_id.toString() === auth?.principal?.toString()
          && Object.entries(loan.status)[0][0] === "Active"
          }
            {#await allowance_bool }
              <span class="loading loading-ring loading-xs"></span>
              Validating allowance...
            {:then isTokenAllowed}
              <span class={"align-[0.05em] status status-" + (isTokenAllowed ? "success" : "warning") }></span>
              {loan_asset_token?.symbol || loan.loan_asset_canister_id}
              Allowance
              {#if !isTokenAllowed}
                <br>
                <button 
                  type="button"
                  onclick={async (e) => {
                    e.target.disabled = true;
                    console.log(e);
                    // TODO dynamic amount
                    const supply = await wallet.icrc1_total_supply(loan_asset_token.canister_id);
                    await wallet.icrc2_approve(loan_asset_token.canister_id, supply )
                    // TODO less hacky method to refresh allowance validation
                    // const stash_loan_amount = loan_amount;
                    // loan_amount = undefined;
                    // loan_amount = stash_loan_amount;
                    allowance_bool = wallet.validateICRC2Allowance(loan.loan_asset_canister_id, wallet.principal, loan.loan_amount);
                    // loan_asset_token = loan_asset_token;
                    wallet.refreshWatchedICRC1Tokens();
                  } }
                  class="btn btn-info"
                >Approve</button>
              <span>Cost: </span>
              <span>{loan_asset_token?.fee / 10**loan_asset_token?.decimals}  {loan_asset_token?.symbol}</span>
              {/if}

            {:catch error}
                <button onclick={()=> allowance_bool = wallet.validateICRC2Allowance(loan.loan_asset_canister_id, wallet.principal, loan.loan_amount) }>🔄 Try Again</button>
                <div class="collapse bg-base-100 border-base-300 border">
                  <input type="checkbox" />
                  <div class="collapse-title font-semibold">Error validating allowance</div>
                  <div class="collapse-content text-sm">
                    {error}
                  </div>
                </div>
            {/await}
          {:else}
            <!-- {#await wallet.getPrincipal()}{/await} -->
          {/if}

        <!-- TODO is_repayable -->
        {#if loan.borrower_user_id.toString() === auth?.principal?.toString()
          && Object.entries(loan.status)[0][0] === "Active"
          }
          <button class="btn btn-success mt-3" onclick={() => loanRepay(loan.id)}>
            Repay Loan
          </button>
        {/if}

        <!-- TODO is_defaultable -->
        {#if loan.lender_user_id.toString() === auth?.principal?.toString()
          && Object.entries(loan.status)[0][0] === "Active"
          }
          <button class="btn btn-secondary mt-3" onclick={() => loanDefault(loan.id)}>
            Default Loan
          </button>
        {/if}

      </div>

    </div>
