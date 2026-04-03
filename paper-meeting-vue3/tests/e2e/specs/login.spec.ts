import { test, expect } from '@playwright/test';

test.describe('登录页面', () => {
  test('P0 - 应该显示登录表单 @smoke @p0', async ({ page }) => {
    await page.goto('/login');
    await expect(page.getByRole('button', { name: /登录/ })).toBeVisible();
  });
});
