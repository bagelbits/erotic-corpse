const { generateWebpackConfig, merge } = require('shakapacker');

/**
 * React server rendering runs the one pack alone, so the entry has to stay whole:
 * a split would drag ReactRailsUJS out to a chunk that the renderer never loads.
 */
module.exports = merge(generateWebpackConfig(), {
  optimization: { splitChunks: false, runtimeChunk: false },
});
