module.exports = function (api) {
  const defaultConfigFunc = require('shakapacker/package/babel/preset.js')
  const resultConfig = defaultConfigFunc(api)
  const isProductionEnv = api.env('production')

  return {
    presets: [
      ...resultConfig.presets,
      ['@babel/preset-react', { development: !isProductionEnv, useBuiltIns: true }]
    ],
    plugins: [
      ...resultConfig.plugins,
      isProductionEnv && [
        'babel-plugin-transform-react-remove-prop-types',
        { removeImport: true }
      ]
    ].filter(Boolean)
  }
}
