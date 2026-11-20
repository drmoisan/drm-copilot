# Prohibited-Flag Guard Verification — Extension Entry Point

Timestamp: 2026-07-26T01-07

Task: [P2-T5]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC6, AC7

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f\extensions\drm-copilot`
Entry point under test: `extensions/drm-copilot/run-jest.cjs`

## Invocation 1

Command: `node run-jest.cjs --passWithNoTests` (run from `extensions/drm-copilot/`)
EXIT_CODE: 1

stderr:
```
--passWithNoTests is prohibited in this repository: zero discovered tests must fail (issue #423).
```

## Invocation 2

Command: `node run-jest.cjs --onlyChanged` (run from `extensions/drm-copilot/`)
EXIT_CODE: 1

stderr:
```
--onlyChanged is prohibited in this repository: zero discovered tests must fail (issue #423).
```

## Invocation 3

Command: `node run-jest.cjs --lastCommit` (run from `extensions/drm-copilot/`)
EXIT_CODE: 1

stderr:
```
--lastCommit is prohibited in this repository: zero discovered tests must fail (issue #423).
```

## Verification

| Requirement | Invocation 1 | Invocation 2 | Invocation 3 |
|---|---|---|---|
| Exit code 1 | PASS | PASS | PASS |
| stderr names the rejected flag | PASS (`--passWithNoTests`) | PASS (`--onlyChanged`) | PASS (`--lastCommit`) |
| stderr states zero discovered tests must fail | PASS | PASS | PASS |
| stderr cites `issue #423` | PASS | PASS | PASS |
| Jest was NOT spawned | PASS | PASS | PASS |

### Proof that Jest was not spawned

Each invocation produced exactly one line of output — the guard message — and nothing else. With the
fix applied, an actual Jest spawn in this package discovers 169 test suites and prints a full run
summary, as recorded in `evidence/regression-testing/pass-after-extension-jest.*.md`. No such output
appeared, and no `No tests found, exiting with code 1` diagnostic appeared either. In this entry
point the guard is positioned before `require.resolve("jest/bin/jest")` as well as before
`cp.spawnSync(...)`, so the Jest binary is not even resolved on the rejection path.

Note this is the same code path exercised by `npm --prefix extensions/drm-copilot run test`, whose
`test` script is `node run-jest.cjs`; the flags are therefore rejected identically when passed
through npm.

Output Summary: PASS. All three prohibited flags rejected at the extension entry point with exit code
1. Each stderr message names the rejected flag, states that zero discovered tests must fail, and
cites issue #423. No Jest output of any kind appeared in any invocation, confirming Jest was never
spawned. AC6 and AC7 (extension entry point) satisfied. Combined with [P2-T4], AC7 is fully
satisfied across both entry points.
