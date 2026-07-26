const cp = require("node:child_process");

// Prohibited-flag guard (issue #423). These are the flags on Jest's `exitWith0`
// path (`passWithNoTests || lastCommit || onlyChanged`); any of them converts
// zero discovered tests into a green run, which would mask a test-discovery
// defect. Reject them before Jest is spawned so no run can ever be silently
// empty. Kept inline and exact-match, matching the `--testPathPattern` rewrite
// style below.
const PROHIBITED_FLAGS = ["--passWithNoTests", "--onlyChanged", "--lastCommit"];

const rawArgs = process.argv.slice(2);
const prohibitedFlag = rawArgs.find((arg) => PROHIBITED_FLAGS.includes(arg));

if (prohibitedFlag !== undefined) {
  console.error(
    `${prohibitedFlag} is prohibited in this repository: zero discovered tests must fail (issue #423).`,
  );
  process.exit(1);
}

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
