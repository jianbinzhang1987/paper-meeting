import { test as base, expect } from '@playwright/test';

/**
 * 项目合并 fixtures
 * 遵循: pure function → fixture → merge 架构
 */

export const test = base.extend<{
  loginAsAdmin: () => Promise<void>;
}>({
  loginAsAdmin: async ({ page, request, baseURL }, use) => {
    const loginAsAdmin = async () => {
      // 通过 API 获取 token（快速）
      const loginResp = await request.post('/admin-api/system/auth/login', {
        data: {
          username: process.env.ADMIN_USER || 'admin',
          password: process.env.ADMIN_PASSWORD || 'admin123',
        },
      });
      expect(loginResp.status()).toBe(200);
      const body = await loginResp.json();

      // 注入 cookie 到 browser context
      const hostname = new URL(baseURL!).hostname;
      await page.context().addCookies([
        {
          name: 'token',
          value: body.data.accessToken,
          domain: hostname,
          path: '/',
        },
      ]);
    };
    await use(loginAsAdmin);
  },
});

export { expect } from '@playwright/test';
