# Fail-Before Baseline — `npm audit`, Repository Root (#414, [P0-T7], [expect-fail])

Timestamp: 2026-07-25T17-01

Command: `npm audit --audit-level=moderate` (working directory: repository root, BEFORE any manifest edit)
EXIT_CODE: 1

Expected outcome for this task: non-zero exit. This is the fail-before evidence for #414.

## Flagged Nodes

```text
brace-expansion  <=5.0.7
Severity: high
brace-expansion: DoS via unbounded expansion length causing an out-of-memory process crash - https://github.com/advisories/GHSA-mh99-v99m-4gvg
fix available via `npm audit fix --force`
Will install jest@25.0.0, which is a breaking change
node_modules/brace-expansion
node_modules/minimatch/node_modules/brace-expansion
  minimatch  2.0.0 - 10.0.2
  Depends on vulnerable versions of brace-expansion
  node_modules/minimatch
    glob  4.3.0 - 10.5.0
    Depends on vulnerable versions of minimatch
    node_modules/glob
```

The two directly flagged `brace-expansion` nodes are exactly those named in `spec.md`:

- `node_modules/brace-expansion`
- `node_modules/minimatch/node_modules/brace-expansion`

Downstream effect chain reported by npm (all dev-dependency subtree): `minimatch` -> `glob` -> `@jest/reporters`, `jest-config`, `jest-runtime`, `mocha`, `test-exclude`, and their transitive dependents (`@jest/core`, `jest`, `jest-cli`, `ts-jest`, `jest-circus`, `jest-runner`, `@vscode/test-cli`, `babel-plugin-istanbul`, `@jest/transform`, `jest-snapshot`, `@jest/expect`, `@jest/globals`, `jest-resolve-dependencies`, `babel-jest`).

## Advisory Attribution

All reported findings are attributable to the single advisory GHSA-mh99-v99m-4gvg (`brace-expansion`, vulnerable range `<=5.0.7`, severity high). No other advisory ID appears in the report.

## Summary Line

```text
22 high severity vulnerabilities
```

Output Summary: FAIL as expected. `npm audit --audit-level=moderate` exits 1 in the repository root with 22 high-severity findings, all attributable to GHSA-mh99-v99m-4gvg. The two flagged `brace-expansion` nodes are `node_modules/brace-expansion` and `node_modules/minimatch/node_modules/brace-expansion`, matching the counts and node paths recorded in `spec.md`. npm's `fixAvailable` suggestion is `jest@25.0.0` (breaking major downgrade) and is prohibited by this plan.
