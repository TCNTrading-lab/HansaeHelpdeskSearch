const path = require("path");
module.exports = {
  mode: "production",
  entry: "./bin/www",
//   resolve: {
//     "pg-native": "./no_action.js",
//   },
  output: {
    path: path.join(__dirname, "dist"),
    publicPath: "/",
    filename: "final.js",
  },
  target: "node",
  
};