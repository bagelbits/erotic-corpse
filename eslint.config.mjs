import js from '@eslint/js';
import globals from 'globals';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import jsxA11y from 'eslint-plugin-jsx-a11y';
import importPlugin from 'eslint-plugin-import';
import prettierRecommended from 'eslint-plugin-prettier/recommended';

export default [
  { ignores: ['node_modules/**', 'public/**', 'vendor/**', 'tmp/**', 'log/**', 'storage/**'] },

  js.configs.recommended,
  react.configs.flat.recommended,
  reactHooks.configs.flat['recommended-latest'],
  jsxA11y.flatConfigs.recommended,
  importPlugin.flatConfigs.recommended,

  {
    files: ['**/*.{js,jsx,mjs}'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: globals.browser,
      parserOptions: { ecmaFeatures: { jsx: true } },
    },
    settings: {
      react: { version: 'detect' },
      // Bare "components/..." specifiers resolve through shakapacker's source_path.
      'import/resolver': {
        node: {
          extensions: ['.js', '.jsx', '.mjs'],
          moduleDirectory: ['node_modules', 'app/javascript'],
        },
      },
    },
    rules: {
      'react/jsx-one-expression-per-line': 'off',
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
      // Specs spread props and pull from devDependencies, which app code may not.
      'react/prop-types': 'off',
      'import/no-extraneous-dependencies': 'off',
      'import/no-unresolved': 'off',
    },
  },

  prettierRecommended,
];
