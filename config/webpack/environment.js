const { environment } = require("@rails/webpacker");

environment.loaders.get(
  "file"
).test = /\.(jpg|jpeg|png|gif|tiff|ico|svg|eot|otf|ttf|woff|woff2|mp3)$/i;

module.exports = environment;
