const { generateWebpackConfig, merge } = require('shakapacker');

// ExecJS evaluates server-bundle.js by itself, so entries have to stay whole.
module.exports = merge(generateWebpackConfig(), {
  optimization: { splitChunks: false, runtimeChunk: false },
});
