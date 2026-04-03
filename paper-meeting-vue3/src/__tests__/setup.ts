import { describe, it, expect, vi } from 'vitest';
import { config } from '@vue/test-utils';

// 全局 mock
config.global.stubs = {
  RouterLink: true,
  RouterView: true,
};
