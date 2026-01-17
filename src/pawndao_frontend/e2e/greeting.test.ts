import { expect, test } from '@playwright/test';

test('greeting test', async ({ page }) => {
	await page.goto('/');
	// await expect(page.locator('h1')).toBeVisible();
  await page.fill('#name', 'John Doe');

  // Click the button with the text "Click Me!"
  await page.click('text=Click Me!');
  await expect(page.locator('#greeting')).toHaveText('Hello, John Doe!');
});

