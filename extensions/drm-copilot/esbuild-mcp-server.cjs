/** Build the extension-hosted MCP executable with deterministic identity. */
const path = require("node:path");
const esbuild = require("esbuild");
const {
  buildMcpServerBundle,
} = require("../../scripts/dev_tools/mcp-bundle-builder.cjs");

buildMcpServerBundle({
  esbuild,
  repositoryRoot: path.resolve(__dirname, "..", ".."),
  dependencyRoot: __dirname,
  outputPath: path.join(__dirname, "out", "mcp-server.js"),
}).catch((error) => {
  process.stderr.write(
    `${error instanceof Error ? error.message : String(error)}\n`,
  );
  process.exitCode = 1;
});
