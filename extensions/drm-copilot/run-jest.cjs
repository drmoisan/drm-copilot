const cp = require("node:child_process");

const rewrittenArgs = process.argv
  .slice(2)
  .map((arg) => (arg === "--testPathPattern" ? "--testPathPatterns" : arg));

const jestBin = require.resolve("jest/bin/jest");
const result = cp.spawnSync(
  process.execPath,
  [jestBin, "--config", "jest.config.cjs", ...rewrittenArgs],
  {
    stdio: "inherit",
  },
);

if (result.error) {
  console.error(result.error);
  process.exit(1);
}

process.exit(result.status ?? 1);
