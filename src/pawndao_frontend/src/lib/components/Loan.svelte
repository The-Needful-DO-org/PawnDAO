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

  // Handler to repay a loan
  async function loanRepay(loan_id:BigInt) {
    try {
      await auth.actor.loanRepay(loan_id);
      alert("Loan repaid!");
    } catch (e) {
      alert("Error repaying loan: " + e);
    }
    refreshLoan(loan_id);
  }

  // Handler to default a loan
  async function loanDefault(loan_id: BigInt) {
    try {
      await auth.actor.loanDefault(loan_id);
      alert("Loan defaulted!");
    } catch (e) {
      alert("Error defaulting loan: " + e);
    }
    refreshLoan(loan_id);
  }

  async function refreshLoan(loan_id) {
    const loanById = await auth.actor.loanById(loan_id).then((response) => {
      return response;
    });
    console.log(loanById);
    loan = loanById[0];
  }

  // Helpers
  function truncate(id: string, start = 10, end = 5) {
    if (!id || id.length <= start + end + 3) return id;
    return `${id.slice(0, start)}...${id.slice(-end)}`;
  }

  $: loanStatus = Object.entries(loan.status)[0][0];
  $: isExpired = new Date() > endDate;
  $: daysElapsed = Math.min(Number(loan.duration), Number(loan.duration) - Math.max(0, Math.round((endDate.getTime() - Date.now()) / 86400000)));
  $: progressPct = Math.round((daysElapsed / Number(loan.duration)) * 100);
  $: timeRemainingDays = Math.max(0, Math.round((endDate.getTime() - Date.now()) / 86400000));
  $: urgency = timeRemainingDays <= 1 ? "error" : timeRemainingDays <= 2 ? "warning" : "success";

  $: loanedDisplay = loan_asset_token?.decimals
    ? Number(loan.loan_amount) / 10 ** Number(loan_asset_token.decimals)
    : loan.loan_amount + "nat";

  $: collateralDisplay = collateral_asset_token?.decimals
    ? Number(loan.collateral_amount) / 10 ** Number(collateral_asset_token.decimals)
    : loan.collateral_amount + "nat";

  $: isBorrower = loan.borrower_user_id.toString() === auth?.principal?.toString();
  $: isLender = loan.lender_user_id.toString() === auth?.principal?.toString();
  $: isActive = loanStatus === "Active";
</script>

<div class="card bg-base-100 shadow-2xl border border-base-300 rounded-2xl overflow-hidden font-mono">

  <!-- Header -->
  <div class="bg-neutral text-neutral-content px-6 py-4 flex items-center justify-between">
    <div class="flex items-center gap-3">
      <span class="text-xs font-bold tracking-widest uppercase opacity-60">Loan</span>
      <a href="/loans/{loan.id}" class="badge badge-outline badge-lg text-neutral-content border-neutral-content/30 font-bold hover:bg-neutral-focus transition-colors">
        #{loan.id}
      </a>
    </div>
    <div class="badge gap-1 font-semibold uppercase tracking-wide text-xs"
      class:badge-success={loanStatus === 'Active'}
      class:badge-warning={loanStatus === 'Pending'}
      class:badge-error={loanStatus === 'Defaulted'}
      class:badge-ghost={loanStatus === 'Repaid'}
    >
      {#if loanStatus === 'Active'}
        <span class="w-1.5 h-1.5 rounded-full bg-success-content inline-block animate-pulse"></span>
      {/if}
      {loanStatus}
    </div>
  </div>

  <div class="card-body gap-5 p-6">

    <!-- Parties -->
    <div class="grid grid-cols-2 gap-3">
      <div class="bg-base-200 rounded-xl p-3">
        <p class="text-xs font-bold tracking-widest uppercase opacity-50 mb-1">Borrower</p>
        <div class="tooltip tooltip-bottom w-full" data-tip={loan.borrower_user_id.toString()}>
          <p class="text-xs font-mono text-primary truncate cursor-help">{truncate(loan.borrower_user_id.toString())}</p>
        </div>
      </div>
      <div class="bg-base-200 rounded-xl p-3">
        <p class="text-xs font-bold tracking-widest uppercase opacity-50 mb-1">Lender</p>
        <div class="tooltip tooltip-bottom w-full" data-tip={loan.lender_user_id.toString()}>
          <p class="text-xs font-mono text-secondary truncate cursor-help">{truncate(loan.lender_user_id.toString())}</p>
        </div>
      </div>
    </div>

    <div class="divider my-0 opacity-30"></div>

    <!-- Financials -->
    <div class="grid grid-cols-2 gap-3">
      <div class="stat bg-primary/10 rounded-xl px-4 py-3">
        <div class="stat-title text-xs uppercase tracking-widest opacity-60">Loaned</div>
        <div class="stat-value text-primary text-xl">{loanedDisplay} <span class="text-sm">{loan_asset_token?.symbol ?? ''}</span></div>
        <div class="tooltip tooltip-bottom" data-tip={loan.loan_asset_canister_id.toString()}>
          <div class="stat-desc text-xs truncate cursor-help opacity-50">{truncate(loan.loan_asset_canister_id.toString(), 8, 4)}</div>
        </div>
      </div>
      <div class="stat bg-secondary/10 rounded-xl px-4 py-3">
        <div class="stat-title text-xs uppercase tracking-widest opacity-60">Collateral</div>
        <div class="stat-value text-secondary text-xl">{collateralDisplay} <span class="text-sm">{collateral_asset_token?.symbol ?? ''}</span></div>
        <div class="tooltip tooltip-bottom" data-tip={loan.collateral_canister_id.toString()}>
          <div class="stat-desc text-xs truncate cursor-help opacity-50">{truncate(loan.collateral_canister_id.toString(), 8, 4)}</div>
        </div>
      </div>
    </div>

    <!-- Repay / Interest row -->
    <div class="flex items-center gap-3">
      <div class="flex-1 bg-base-200 rounded-xl px-4 py-3">
        <p class="text-xs font-bold tracking-widest uppercase opacity-50 mb-0.5">Repay Amount</p>
        <p class="text-base font-bold text-accent">{repay_amount} {loan_asset_token?.symbol || loan.loan_asset_canister_id}</p>
      </div>
      <div class="bg-base-200 rounded-xl px-4 py-3 text-center">
        <p class="text-xs font-bold tracking-widest uppercase opacity-50 mb-0.5">Interest</p>
        <p class="text-base font-bold text-warning">{loan.interest}%</p>
      </div>
    </div>

    <div class="divider my-0 opacity-30"></div>

    <!-- Time progress -->
    <div>
      <div class="flex justify-between items-center mb-2">
        <span class="text-xs font-bold tracking-widest uppercase opacity-50">Duration Progress</span>
        <span class="badge badge-sm font-semibold gap-1"
          class:badge-error={urgency === 'error'}
          class:badge-warning={urgency === 'warning'}
          class:badge-success={urgency === 'success'}
        >
          ⏱ {isExpired ? 'Ended' : ''} {formatDistanceToNow(endDate)}{isExpired ? ' ago' : ' left'}
        </span>
      </div>
      <progress
        class="progress w-full h-2.5"
        class:progress-error={urgency === 'error'}
        class:progress-warning={urgency === 'warning'}
        class:progress-success={urgency === 'success'}
        value={progressPct}
        max="100"
      ></progress>
      <div class="flex justify-between mt-1 text-xs opacity-40">
        <span>Day 0</span>
        <span>{daysElapsed}/{loan.duration} days elapsed</span>
        <span>Day {loan.duration}</span>
      </div>
    </div>

    <!-- Started date -->
    <div class="flex items-center gap-2 text-xs opacity-50">
      <svg xmlns="http://www.w3.org/2000/svg" class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
          d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
      </svg>
      <span>Started: {new Date(Number(loan.timestamp)/1000000).toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' })}</span>
    </div>

    <!-- Allowance validation (borrower only, active loans) -->
    {#if isBorrower && isActive}
      {#await allowance_bool}
        <div class="flex items-center gap-2 text-sm opacity-60">
          <span class="loading loading-ring loading-xs"></span>
          Validating allowance...
        </div>
      {:then isTokenAllowed}
        <div class="flex items-center gap-2 text-sm">
          <span class={"align-[0.05em] status status-" + (isTokenAllowed ? "success" : "warning")}></span>
          {loan_asset_token?.symbol || loan.loan_asset_canister_id} Allowance
          {#if !isTokenAllowed}
            <div class="flex flex-col gap-1 mt-1">
              <button
                type="button"
                onclick={async (e) => {
                  e.target.disabled = true;
                  const supply = await wallet.icrc1_total_supply(loan_asset_token.canister_id);
                  await wallet.icrc2_approve(loan_asset_token.canister_id, supply)
                  allowance_bool = wallet.validateICRC2Allowance(loan.loan_asset_canister_id, wallet.principal, loan.loan_amount);
                  wallet.refreshWatchedICRC1Tokens();
                }}
                class="btn btn-info btn-sm w-fit"
              >Approve</button>
              <span class="text-xs opacity-60">Cost: {loan_asset_token?.fee / 10**loan_asset_token?.decimals} {loan_asset_token?.symbol}</span>
            </div>
          {/if}
        </div>
      {:catch error}
        <div class="collapse bg-base-100 border-base-300 border rounded-xl">
          <input type="checkbox" />
          <div class="collapse-title font-semibold text-sm">⚠ Error validating allowance</div>
          <div class="collapse-content text-xs">{error}</div>
        </div>
        <button class="btn btn-ghost btn-xs w-fit" onclick={() => allowance_bool = wallet.validateICRC2Allowance(loan.loan_asset_canister_id, wallet.principal, loan.loan_amount)}>
          🔄 Try Again
        </button>
      {/await}
    {/if}

    <!-- Action buttons -->
    {#if isBorrower && isActive}
      <button class="btn btn-success mt-1" onclick={() => loanRepay(loan.id)}>
        Repay Loan
      </button>
    {/if}

    {#if isLender && isActive}
      <button class="btn btn-secondary mt-1" onclick={() => loanDefault(loan.id)}>
        Default Loan
      </button>
    {/if}

  </div>
</div>
