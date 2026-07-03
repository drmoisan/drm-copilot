/**
 * Bundles out/mcp-server.js into a self-contained file that can run as a
 * standalone Node.js process without access to node_modules.
 *
 * The vscode module is shimmed with an empty object because the MCP server
 * transitively imports command-runtime which has a top-level vscode import,
 * but the MCP code path never calls any vscode API.
 */
const esbuild = require("esbuild");

/** @type {import("esbuild").Plugin} */
const vscodeShimPlugin = {
  name: "vscode-shim",
  setup(build) {
    build.onResolve({ filter: /^vscode$/ }, () => ({
      path: "vscode",
      namespace: "vscode-shim",
    }));
    build.onLoad({ filter: /.*/, namespace: "vscode-shim" }, () => ({
      contents: "module.exports = {};",
      loader: "js",
    }));
  },
};

esbuild
  .build({
    entryPoints: ["src/mcp-server.ts"],
    bundle: true,
    platform: "node",
    target: "node18",
    outfile: "out/mcp-server.js",
    allowOverwrite: true,
    plugins: [vscodeShimPlugin],
  })
  .catch(() => process.exit(1));
