import { defineConfig, devices } from '@playwright/test';

const BASE_URL = process.env.CI
  ? 'https://staging.example.com'
  : process.env.BASE_URL || 'http://localhost:3333';

export default defineConfig({
  testDir: './tests/e2e/specs',
  outputDir: './tests/e2e/test-results',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: process.env.CI
    ? [['html', { outputFolder: './tests/e2e/report' }], ['github'], ['list']]
    : [['html', { outputFolder: './tests/e2e/report' }], ['list']],
  use: {
    baseURL: BASE_URL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: process.env.CI ? 'on-first-retry' : 'off',
    actionTimeout: 10_000,
    navigationTimeout: 15_000,
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'], channel: 'chrome' },
    },
    {
      name: 'smoke',
      use: { ...devices['Desktop Chrome'] },
      grep: /@p0|@smoke/,
    },
  ],
  webServer: process.env.CI
    ? undefined
    : {
        command: 'pnpm dev',
        url: 'http://localhost:3333',
        timeout: 120_000,
        reuseExistingServer: true,
      },
});
