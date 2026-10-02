# Remediation Inputs: CI gaps - Linux Pester hook-suite job and kcov set -u (#743)

- Timestamp: 2026-10-01T18-07
- Branch: `bug/ci-gaps-linux-pester-and-kcov-set-u-743` @ `630237f4bf081ed117253e44a7f3d3780bb19368`
- Base: `main` @ `41217012d31d35c2ee33a50be50684affd2f5f43` (merge base)
- Work mode: `full-bug`; AC source: `spec.md` `## Acceptance Criteria`
- Remediation required: **yes**
- Blocking findings: **4** (R1 to R3 share one root cause; R4 is an operator-run item)

## Source Audit Artifacts

- policy-audit: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/policy-audit.2026-10-01T18-07.md`
- code-review: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/code-review.2026-10-01T18-07.md`
- feature-audit: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/feature-audit.2026-10-01T18-07.md`
- Executor evidence: `evidence/qa-gates/ci-final-linux.2026-10-01T17-57.md`, `evidence/qa-gates/linux-first-run-failures.2026-10-01T17-57.md`, `evidence/qa-gates/linux-remediation-required.2026-10-01T16-58.md`, `evidence/qa-gates/qc-actionlint.2026-10-01T17-23.md`

## Remediation-Required Findings

| ID | Severity | AC / Rule | Finding | Artifact |
|---|---|---|---|---|
| R1 | Blocker | AC-6 (FAIL) | `poshqc / PowerShell hook suites (Linux)` concluded `failure` on run 36901896617 (head `ecba8829`): `Tests Passed: 3400, Failed: 12`. | feature-audit row 6; code-review Findings rows 1-2 |
| R2 | Blocker | AC-10 (PARTIAL) | Inventory rows 1-12 of the first-run failure list are listed with fix `none`. The spec requires each to be fixed in the test file concerned, before merge. | feature-audit row 10 |
| R3 | Blocker | `modified-workflow-needs-green-run` | `.github/workflows/_poshqc.yml` is modified, and no run of it with `headSha` equal to the branch head concluded `success`. | policy-audit "Workflow Rule" section; code-review Findings row 3 |
| R4 | Major (blocks AC completion) | AC-5 and AC-21 (PARTIAL) | `scripts/dev-tools/run-actionlint.ps1` has not been run (operator blockers B1-B3). A direct `actionlint` 1.7.11 run is clean. | feature-audit rows 5, 21; code-review Findings row 4 |

## Enumerated Fix List

### F1 - Make the five hook-suite test files portable to Linux (resolves R1, R2; enables R3)

All 12 failures raise `DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.` on `ubuntu-latest`. Edit sites, located by this review with a `['"]C:[\\/]` search:

| File | Lines | Failing testcases (inventory rows) |
|---|---|---|
| `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` | 46 (JSON `"worktree_path":"C:/worktrees/alpha"`), 338, 345, 351, 357, 365 | rows 1-8 |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` | 303 (`-Root 'C:/synthetic-absent-root'`) | row 9 |
| `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1` | 304 (`-Root 'C:/synthetic-absent-root'`) | row 10 |
| `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` | 301 (`-Root 'C:/synthetic-absent-root'`) | row 11 |
| `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` | 298 (`-Root 'C:/synthetic-absent-root'`) | row 12 |

Expected behavior:
- Each synthetic root is derived from the host OS in `BeforeAll`: the Windows literal unchanged on Windows, and a `/`-rooted equivalent elsewhere (for example `/worktrees/alpha`, `/synthetic-absent-root`). This is the pattern already merged on this branch at `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1:47-51` and `:214`. Build JSON strings that embed the root with `-f` (with doubled braces) or concatenation.
- Every test asserts the same behavior on both hosts. The production code in these hooks does not branch on OS for the asserted outcome (deny or allow; direct mode when the checkpoint is absent).
- The Windows cases continue to pass in `poshqc / PowerShell QC`.
- The planner must confirm the line numbers above by reading each file. They come from a literal search and may include sites that do not fail but should be made consistent.

Verification commands:
- `git diff -U0 41217012d31d35c2ee33a50be50684affd2f5f43 -- tests/scripts/codex-hooks/ tests/scripts/claude-hooks/ | grep -c -E '^\+.*-Skip([[:space:]]|$|:\$true)'` -> expect `0` (exit 1).
- PoshQC MCP format, analyze, and test on the item worktree (operator decision: no pwsh in agent worktrees).
- Push, then `gh workflow run _poshqc.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743` (or `ci.yml`). Then:
  - `gh run view <run-id> --json jobs,headSha`: `headSha` equals `git rev-parse HEAD`; `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` both `success`.
  - `gh run view <run-id> --log --job <linux-job-id> | grep -F 'Tests Passed:'` shows `Failed: 0`.
  - `gh run view <run-id> --log --job <windows-job-id> | grep -F 'Tests Passed:'` shows `Failed: 0`. Line coverage from the `poshqc-test-results` `powershell-coverage.xml` LINE counter is >= 85%.
- Record the run ID and both job conclusions in a new timestamped file under `evidence/qa-gates/`. Add a new timestamped copy of the AC-10 inventory with rows 1-12 updated to their fix and `PASSING` status.

Contingency: if the re-run reports further Linux-only failures in other files under `tests/scripts/claude-hooks/` or `tests/scripts/codex-hooks/`, they are in scope per `spec.md` (Files/modules table, "Other files ... Modify (conditional)"). Add them to the inventory and fix them in the same cycle.

### F2 - Run and record the actionlint wrapper (resolves R4)

- Operator command: `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml`
- Expected: exit 0, no findings.
- Record the command, exit code, and output under `evidence/qa-gates/` with a new timestamp. If F1 changes no workflow file, one run after F1 satisfies both AC-5 and the AC-21 actionlint step.

### F3 - Re-run the final QC loop (closes AC-21)

- After F1, re-run the seven-stage loop for touched languages in one pass: PoshQC format, PoshQC analyze, Pester (Windows, with coverage >= 85%), `shell-qc.sh format`, `check`, and `test`, actionlint (F2), and the pytest parity test.
- Record the commands in the evidence file itself, not only through a session-scratchpad wrapper. This addresses the code-review Minor finding on AC-15 reproducibility.

## Do-Not-Do List

- Do not add `-Skip`, `-Skip:$true`, `Set-ItResult -Skipped`, or an OS guard that skips a test without a non-Windows assertion of the same behavior.
- Do not modify `.github/workflows/_quality-checks.yml`, `.github/workflows/_drm-copilot-extension-tests.yml`, `.github/workflows/ci.yml`, `.github/workflows/_shell-coverage.yml`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, or anything under `.claude/rules/` or `.github/instructions/` (AC-20).
- Do not change `Run.Path` in `poshqc-linux-hooks` to exclude the failing files or folders. Do not change the existing `poshqc` job (AC-4).
- Do not edit production hook scripts to make the tests pass. The defect is in the tests' Windows-only synthetic paths.
- Do not let `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` (495 lines) exceed 500 lines.
- Do not create temporary files in tests.
- Do not check off AC-5, AC-6, AC-10, or AC-21 until the evidence above exists.

## Handoff

- Route: orchestrator -> `atomic-planner` (remediation plan per `.claude/skills/atomic-plan-contract/SKILL.md`) -> `atomic-executor` preflight and execution -> `feature-review` re-audit.
- This review does not author the remediation plan. Under `remediation-handoff-atomic-planner`, `atomic-planner` authors it from these inputs.
- Exit condition: a re-audit with `blocking_count == 0`, with AC-5, AC-6, AC-10, and AC-21 PASS and checked in `spec.md`.
