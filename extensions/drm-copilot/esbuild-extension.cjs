/**
 * Bundles src/extension.ts into a single out/extension.js file so the
 * packaged VS Code extension ships a small number of JavaScript files
 * instead of one file per compiled TypeScript source module.
 *
 * The vscode module is marked external because the extension entry point
 * imports the real vscode API at runtime inside the extension host, which
 * provides the module.
 */
const esbuild = require("esbuild");

esbuild
  .build({
    entryPoints: ["src/extension.ts"],
    bundle: true,
    platform: "node",
    target: "node18",
    outfile: "out/extension.js",
    allowOverwrite: true,
    external: ["vscode"],
  })
  .catch(() => process.exit(1));
