# Prohibited-Flag Guard Verification — Root Entry Point

Timestamp: 2026-07-26T01-06

Task: [P2-T4]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC5, AC7

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`
Entry point under test: `run-jest.cjs` (repo root)

## Invocation 1

Command: `node run-jest.cjs --passWithNoTests`
EXIT_CODE: 1

stderr:
```
--passWithNoTests is prohibited in this repository: zero discovered tests must fail (issue #423).
```

## Invocation 2

Command: `node run-jest.cjs --onlyChanged`
EXIT_CODE: 1

stderr:
```
--onlyChanged is prohibited in this repository: zero discovered tests must fail (issue #423).
```

## Invocation 3

Command: `node run-jest.cjs --lastCommit`
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

Each invocation produced exactly one line of output — the guard message — and nothing else. In
particular, none of the three runs emitted any Jest output. The distinguishing signal is decisive in
this worktree: the fix is now applied, so an actual Jest spawn at the repository root discovers 171
test suites and prints a full run summary (`Test Suites: ... Tests: ... Time: ...`), as recorded in
`evidence/regression-testing/pass-after-root-jest.*.md`. Zero such output means Jest never ran.
Equally, no `No tests found, exiting with code 1` diagnostic appeared, which rules out the alternate
path where Jest starts and reports empty discovery. The process therefore terminated in the guard,
before `runNodeTool("jest/bin/jest", ...)` was reached.

Output Summary: PASS. All three prohibited flags rejected at the repository root with exit code 1.
Each stderr message names the rejected flag, states that zero discovered tests must fail, and cites
issue #423. No Jest output of any kind appeared in any invocation, confirming Jest was never spawned.
AC5 and AC7 (root entry point) satisfied.
