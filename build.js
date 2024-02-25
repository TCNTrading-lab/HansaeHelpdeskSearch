const { build } = require("esbuild");

build({
  entryPoints: ["./bin/www"],
  bundle: true,
  outfile: "./dist/bundle.js",
  platform: "node",
  target: "node20", // Chọn phiên bản Node.js tương thích
  minify: process.env.NODE_ENV === "production", // Tối ưu hóa trong môi trường production
}).catch(() => process.exit(1));
