import { expect, test } from '@playwright/test';

test('new loan request', async ({ page }) => {
	await page.goto('/borrow');
  await page.click('text=New Loan Request');
  await page.click('id=icp-btn');
	// await expect(page.locator('h1')).toBeVisible();
  // await page.fill('#name', 'John Doe');
  await page.fill('#collateral_amount', '420');
  await page.click('id=icp-btn');
  await page.check('input[name="desired_asset_canister_ids"][value="ryjl3-tyaaa-aaaaa-aaaba-cai"]');
  await page.fill('#desired_amounts', '210');
  await page.fill('#desired_duration', '30');
  await page.fill('#desired_interest', '2.5');
  await page.locator('#LoanRequestForm button[type="submit"]').click();
  await expect(page.locator('body')).toContainText('Collateral 420 LICP');
  await expect(page.locator('body')).toContainText('Amount 210 LICP');

});

