const { runNodeTool } = require("./run-node-tool.cjs");

const rewrittenArgs = process.argv
  .slice(2)
  .map((arg) => (arg === "--testPathPattern" ? "--testPathPatterns" : arg));

process.exit(
  runNodeTool("jest/bin/jest", [
    "--config",
    "jest.config.cjs",
    ...rewrittenArgs,
  ]),
);
