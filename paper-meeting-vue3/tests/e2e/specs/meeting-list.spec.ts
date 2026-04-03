import { test, expect } from '../fixtures';

test.describe('会议列表 @p1', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/meeting/list');
  });

  test('应该能进入会议列表页', async ({ page }) => {
    await expect(page).toHaveURL(/meeting/);
  });
});
