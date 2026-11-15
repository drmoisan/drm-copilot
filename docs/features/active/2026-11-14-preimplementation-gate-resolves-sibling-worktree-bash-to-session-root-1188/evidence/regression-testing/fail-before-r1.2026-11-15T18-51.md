# Fail-before proof - remediation cycle 1, finding R1 (P1-T3)

Timestamp: 2026-11-15T18-50
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classify.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Invoke-PoshQCParallelTest, 4 workers, wall-clock 140.47 s, exit code 1, against the unmodified hooks (no classify sibling, no gate wiring, no operands-sibling change). Shard JUnit: 394 test cases, 96 failed, 0 skipped. Every failure is a named fail-before row; every other row passes.

Plan: remediation-plan.2026-11-14T23-56.md

Run notes: the run was started by a helper under the item worktree's gitignored `artifacts/scratch-issue-1188/` (`targeted-pester.sh`), which re-invokes the launcher on exit 75. The first seven attempts exited 75 (`TEST_EXECUTION_QUEUE_TIMEOUT:`, lock held in turn by the `pester` suites of the `feature-ci-shards` and `bug-launcher-jest-path` worktrees); they are queue timeouts, not failures. The eighth attempt is the run above. Counts were read from the per-shard JUnit files under `artifacts/pester/parallel/` (a failed run writes no merged artifact).

## Failing rows, per surface (48 on the Claude surface, 48 on the Codex surface)

Each of the two surfaces (`Claude gate ...` in `tests/scripts/claude-hooks/`, `Codex gate ...` in `tests/scripts/codex-hooks/`) fails the same rows:

- Operands suite, unquoted V3: `V3 npm --prefix unquoted substitution` (expected deny `TARGET_WORKTREE_NOT_DERIVABLE`; observed allow, because `Test-ImplementationCommand` does not classify the command).
- Operands suite, both N3 rows: `N3 npx --prefix ready` and `N3 npx --prefix not ready` (expected one item read and one listing call; observed zero, because the command is unclassified).
- Operands suite, both bash option-value G-rows: `G bash --rcfile value is not the script operand` and `G bash --init-file value is not the script operand` (the rcfile value is taken as the script operand).
- Classify suite, every positive classification row (14): `classifies Positive row <Command> as $true` for `npm --prefix $(pwd) run lint`, `npm --prefix ${W} run test:unit`, ``npm --prefix `pwd` run typecheck``, `env -u VIRTUAL_ENV npm --prefix $(pwd) run lint`, `npx --prefix /synthetic-worktrees/w-item jest`, `npx --prefix=/synthetic-worktrees/w-item tsc`, `npx -C /synthetic-worktrees/w-item eslint`, `npx --yes jest`, `npx -y -q prettier`, `npx --no jest`, `npx --quiet tsc`, `npx --prefix $(pwd) jest`, `npm --prefix $(dirname $(pwd)) run lint`, `npm --prefix $(pwd)/$(echo x) run lint`.
- Classify suite, the function-row container: `Get-OrchestrationGateSupplementalPatternIndex alone (function rows)` fails in its `BeforeAll` (the classify sibling does not exist), so all 29 `F <Name>` rows report failed.

## Passing rows (non-failing by design)

- Operands suites: `V3 npm --prefix quoted substitution` (deny), every other G-row and gate row, `baseline mock interception probe`, and I1.
- Classify suites: every Negative row (10) and every Control row (3) of `classifies <Kind> row <Command> as <Expected>`, `baseline mock interception probe`, and I2 (`I2 denies naming enforce-orchestration-preimplementation-gate-classify.ps1 when its dot-source failed`).

No named fail-before row passed before the fix, so no row is non-discriminating.
