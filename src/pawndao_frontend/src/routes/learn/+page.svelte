<main class="max-w-4xl mx-auto px-5 py-10">
  <h1 class="text-4xl font-bold text-center mb-4">How PawnDAO Works</h1>
  <p class="text-center text-base-content/70 mb-12">
    PawnDAO is a peer-to-peer crypto lending protocol on the Internet Computer.
    Borrowers post ICP ICRC tokens as collateral; lenders fund loans and earn interest —
    or receive the collateral if the borrower doesn't repay.
  </p>

  <!-- Borrowing -->
  <div class="card bg-base-200 shadow mb-8">
    <div class="card-body">
      <h2 class="card-title text-2xl">🏦 Borrowing</h2>
      <p>
        Borrowers create a <strong>Loan Request</strong> to receive tokens by pledging collateral they already hold.
      </p>
      <ol class="list-decimal list-inside space-y-2 mt-3">
        <li>Navigate to <a href="/borrow" class="link link-primary">Borrow</a> and click <strong>New Loan Request</strong>.</li>
        <li>Select a <strong>collateral token</strong> (e.g. ICP, ckBTC, ckETH) and enter the amount you'll pledge.</li>
        <li>Optionally specify a <strong>desired token</strong> and amount you want to receive, a <strong>duration</strong> in days, and a maximum <strong>interest rate</strong> (%).</li>
        <li>Submit the request. It becomes publicly visible to lenders on the <a href="/loan-requests" class="link link-primary">Loan Requests</a> board.</li>
        <li>When a lender makes an offer you're happy with, <strong>accept it</strong>. Accepting transfers your collateral into escrow on the PawnDAO canister and simultaneously releases the loan funds to your wallet.</li>
      </ol>
      <div class="alert alert-info mt-4">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>You must grant PawnDAO an <strong>ICRC-2 allowance</strong> for your collateral token before accepting an offer. This allows the canister to pull the collateral on your behalf.</span>
      </div>
    </div>
  </div>

  <!-- Loaning -->
  <div class="card bg-base-200 shadow mb-8">
    <div class="card-body">
      <h2 class="card-title text-2xl">💰 Loaning (Lending)</h2>
      <p>
        Lenders browse open Loan Requests and make <strong>Loan Offers</strong> to earn interest — or receive the borrower's collateral if they fail to repay.
      </p>
      <ol class="list-decimal list-inside space-y-2 mt-3">
        <li>Navigate to <a href="/lend" class="link link-primary">Lend</a> to see all open Loan Requests.</li>
        <li>Review the collateral token and amount, the token the borrower wants, and the proposed terms (duration, interest).</li>
        <li>Click <strong>Make Offer</strong> on any request and set your own terms — you can offer a different token, amount, duration, or interest rate than what the borrower asked for.</li>
        <li>Your offer is submitted and the borrower is notified. You may have multiple open offers at once.</li>
        <li>If the borrower accepts your offer, your funds are transferred directly to them, and their collateral enters escrow. The loan is now <strong>Active</strong>.</li>
      </ol>
      <div class="alert alert-info mt-4">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>You must grant PawnDAO an <strong>ICRC-2 allowance</strong> for the token you intend to lend. The canister will pull the funds at the moment the borrower accepts your offer.</span>
      </div>
    </div>
  </div>

  <!-- Repayment -->
  <div class="card bg-base-200 shadow mb-8">
    <div class="card-body">
      <h2 class="card-title text-2xl">✅ Repayment</h2>
      <p>
        Borrowers repay the loan <strong>before the duration expires</strong> to reclaim their collateral.
      </p>
      <ol class="list-decimal list-inside space-y-2 mt-3">
        <li>Navigate to <a href="/loans" class="link link-primary">Loans</a> and find your active loan.</li>
        <li>Click <strong>Repay</strong>. The repayment amount is the original loan amount plus the agreed interest.</li>
        <li>PawnDAO collects the full repayment from your wallet, forwards the principal + interest (minus a small <strong>5% fee on the interest</strong>) to the lender, and simultaneously returns your collateral to you.</li>
      </ol>
      <div class="overflow-x-auto mt-4">
        <table class="table table-zebra w-full">
          <thead>
            <tr>
              <th>Who receives</th>
              <th>Amount</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Lender</td>
              <td>Loan amount + interest − 5% of interest (app fee)</td>
            </tr>
            <tr>
              <td>Borrower</td>
              <td>Collateral returned in full (minus token transfer fee)</td>
            </tr>
            <tr>
              <td>PawnDAO</td>
              <td>5% of the interest earned</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="alert alert-warning mt-4">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
        <span>Repayment must happen <strong>before the loan duration expires</strong>. Once the deadline passes the lender can claim your collateral.</span>
      </div>
    </div>
  </div>

  <!-- Defaulting -->
  <div class="card bg-base-200 shadow mb-8">
    <div class="card-body">
      <h2 class="card-title text-2xl">⚠️ Defaulting</h2>
      <p>
        If the borrower does not repay before the loan expires, the lender can <strong>claim the collateral</strong>.
      </p>
      <ol class="list-decimal list-inside space-y-2 mt-3">
        <li>After the loan duration has passed without repayment, navigate to <a href="/loans" class="link link-primary">Loans</a>.</li>
        <li>The lender clicks <strong>Claim Default</strong> on the expired loan.</li>
        <li>PawnDAO transfers the borrower's escrowed collateral to the lender, minus a <strong>5% app fee on the collateral</strong>.</li>
        <li>The loan is marked <strong>Defaulted</strong> and no further action is possible.</li>
      </ol>
      <div class="overflow-x-auto mt-4">
        <table class="table table-zebra w-full">
          <thead>
            <tr>
              <th>Who receives</th>
              <th>Amount</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Lender</td>
              <td>Collateral amount − 5% app fee − token transfer fee</td>
            </tr>
            <tr>
              <td>Borrower</td>
              <td>Nothing — collateral is forfeited</td>
            </tr>
            <tr>
              <td>PawnDAO</td>
              <td>5% of the collateral</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="alert alert-error mt-4">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span>Defaulting is permanent and irreversible. Always repay before your loan's deadline to avoid losing your collateral.</span>
      </div>
    </div>
  </div>

  <!-- CTA -->
  <div class="text-center mt-10 flex gap-4 justify-center">
    <a href="/borrow"><button class="btn btn-primary">Start Borrowing</button></a>
    <a href="/lend"><button class="btn btn-secondary">Start Lending</button></a>
  </div>
</main>
