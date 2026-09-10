import path from 'node:path';
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  resolve: {
    // Mirrors how webpack resolves the bare "components" specifier via source_path.
    alias: { components: path.resolve(process.cwd(), 'app/javascript/components') },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./spec/javascript/setup.js'],
    // Tests live outside app/javascript so require.context("components") cannot bundle them.
    include: ['spec/javascript/**/*.test.{js,jsx}'],
    restoreMocks: true,
  },
});
