import js from '@eslint/js';
import globals from 'globals';
import eslintReact from '@eslint-react/eslint-plugin';
import reactHooks from 'eslint-plugin-react-hooks';
import jsxA11y from 'eslint-plugin-jsx-a11y-x';
import { importX } from 'eslint-plugin-import-x';
import prettierRecommended from 'eslint-plugin-prettier/recommended';

export default [
  { ignores: ['node_modules/**', 'public/**', 'vendor/**', 'tmp/**', 'log/**', 'storage/**'] },

  js.configs.recommended,
  eslintReact.configs.recommended,
  reactHooks.configs.flat['recommended-latest'],
  jsxA11y.configs.recommended,
  importX.flatConfigs.recommended,

  {
    files: ['**/*.{js,jsx,mjs}'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: globals.browser,
      parserOptions: { ecmaFeatures: { jsx: true } },
    },
    settings: {
      // Bare "components/..." specifiers resolve through shakapacker's source_path.
      'import-x/resolver': {
        node: {
          extensions: ['.js', '.jsx', '.mjs'],
          moduleDirectory: ['node_modules', 'app/javascript'],
        },
      },
    },
    rules: {
      'no-unused-vars': ['error', { varsIgnorePattern: '^React$' }],
      // The node resolver cannot follow package exports maps, which is how
      // react-on-rails publishes its client-only entry.
      'import-x/no-unresolved': ['error', { ignore: ['^react-on-rails/'] }],
    },
  },

  {
    // This file loads its channels through require.context rather than import.
    files: ['app/javascript/channels/index.js'],
    languageOptions: {
      sourceType: 'commonjs',
      globals: { ...globals.browser, ...globals.commonjs },
    },
  },

  {
    // Build tooling runs in Node and predates the move to modules.
    files: ['*.config.js', 'config/webpack/**/*.js'],
    languageOptions: {
      sourceType: 'commonjs',
      globals: { ...globals.node, ...globals.commonjs },
    },
  },

  {
    files: ['spec/javascript/**/*.{js,jsx}', 'vitest.config.mjs'],
    languageOptions: { globals: { ...globals.browser, ...globals.node } },
    rules: {
      // Specs pull from devDependencies, which app code may not.
      'import-x/no-extraneous-dependencies': 'off',
      'import-x/no-unresolved': 'off',
    },
  },

  prettierRecommended,
];
