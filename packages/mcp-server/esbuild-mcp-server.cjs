/**
 * Bundles extensions/drm-copilot/src/mcp-server.ts into a self-contained
 * standalone Node.js executable at out/mcp-server.js.
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
    entryPoints: ["../../extensions/drm-copilot/src/mcp-server.ts"],
    bundle: true,
    platform: "node",
    target: "node18",
    format: "cjs",
    outfile: "out/mcp-server.js",
    allowOverwrite: true,
    banner: { js: "#!/usr/bin/env node" },
    plugins: [vscodeShimPlugin],
    tsconfig: "../../extensions/drm-copilot/tsconfig.json",
  })
  .catch(() => process.exit(1));
