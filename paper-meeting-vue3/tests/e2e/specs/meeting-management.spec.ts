import { test, expect } from '../fixtures';

test.describe('会议管理', () => {
  test('应该能打开会议管理页面 @meeting @p1', async ({ page }) => {
    await page.goto('/meeting/control');
    await expect(page).toHaveURL(/\/meeting/);
  });
});
