# Code Review: Owner-Directive Pass-Down to Executing Agents (Issue #1157)

**Review Date:** 2026-11-13
**Branch:** `feature/owner-directive-pass-down-1157` @ `621a6b83df30184693f563b9577a0c4f0a5753d5` (no PR open yet)
**Base:** `main`; merge base `1d62aa292161035aec8058e6c370f133e10a04db`
**Scope:** full branch diff, 119 files: 5 new and 2 edited PowerShell production files with bundle copies, settings and `core.json`, skill, rule, brief, and agent Markdown with mirrors, 7 new and 21 edited Pester suites, one Python test-support data edit, one ledger patch rebase, and feature-folder records

## Executive Summary

The implementation follows the spec design closely. Selection, rendering, decision, and ledger-append rules live in two pure modules whose purity is pinned by contract rows; all reads go through injectable seams in two siblings; the hook returns before any read for calls outside its three cases; and every deny is the standard `hookSpecificOutput` JSON with the `OWNER_DIRECTIVE_PASS_DOWN_BLOCKED:` prefix. Guarded imports follow the fail-closed pattern, and the hook is listed in the dependency-failure and workflow-exemption suites. Mirror parity holds for every `.claude` path in the diff.

Three blocking findings, all autonomous:

- F1: AC-29 requires `validate-orchestrator-output.OwnerDirectives.Tests.ps1` unchanged, but the new stop-hook read seam `Read-OrchestratorOutputOwnerPassDownText` forced a baseline null mock into that suite (and 13 other `validate-orchestrator-output*` suites) to satisfy the epic-state isolation discovery guard.
- F2: the Python post-change coverage artifact is absent for a branch that changes one Python file.
- F3: the ledger guard's path test is case-sensitive, so on Windows a subagent can write the ledger through a path whose letter case differs, bypassing D5 and AC-27.

Three non-blocking items follow.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (blocking, F1) | `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1`; `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1` | `Read-OrchestratorOutputOwnerPassDownText`; suite `BeforeAll` | The sibling introduces a new file-read seam. The discovery guard `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` requires a baseline null mock for every closure seam in each hook suite, so `Mock Read-OrchestratorOutputOwnerPassDownText { $null }` was added to the AC-29 suite. AC-29 requires that suite to pass without edits. Its assertions are unchanged and it passes 22/0, but the criterion is not met as written. | Preferred: read the ledger and the parent and child checkpoints through the existing seam `Get-CheckpointFileContent` (already null-mocked in the AC-29 suite and the other closure suites), remove `Read-OrchestratorOutputOwnerPassDownText`, and revert the mock line in the AC-29 suite; re-run the discovery guard. Alternative: a planner revision of AC-29 that admits a baseline isolation mock with no assertion change, with the owner informed in the PR. | The spec states the "without edits" clause to prove R3 and R6 are untouched; the item should either meet it or change it deliberately, not ship with it unmet. | Diff of the suite (one added line); `evidence/other/task-check.P6-T9.2026-11-13T13-50.md` records the gap; `evidence/qa-gates/pester-final.2026-11-11T05-28.md` records the 20 discovery-guard failures that drove the mock lines |
| Major (blocking, F2) | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | Python coverage evidence | The branch changes one Python file, and no `artifacts/python/lcov.info` exists in the item worktree. The P6-T7 gate ran `pytest -n auto` without `--cov`, so the `addopts` LCOV reporter wrote nothing. The changed file is under `tests/` and outside the measured source set, so no production figure can move, but the review contract requires the artifact for every language with changed files. | Run one `pytest -n auto --cov --cov-branch` gate in the item worktree, record pass and fail counts and the repo-wide line and branch figures in a new `evidence/qa-gates/pytest-final.<timestamp>.md`, and compare them with the merge-base CI TOTAL (35355 statements, 1035 missed; 13424 branches, 554 partial). | Coverage verification is mandatory for every language with changed files; the evidence model reads existing artifacts. | `ls artifacts/python` absent in the item worktree; `pyproject.toml` `addopts` carries `--cov-report=lcov:artifacts/python/lcov.info` without `--cov` |
| Medium (blocking, F3) | `.claude/hooks/enforce-owner-directive-pass-down.ps1` (and bundle copy) | `Get-OwnerDirectivePassDownDecision`, ledger branch | The ledger test is `$path -eq 'artifacts/orchestration/owner-directives.jsonl' -or $path.EndsWith('/artifacts/orchestration/owner-directives.jsonl', [System.StringComparison]::Ordinal)`. The suffix test is case-sensitive, while NTFS resolves `Artifacts/Orchestration/Owner-Directives.jsonl` to the same file. A `Write` by a subagent outside the acknowledgement set (for example `orchestrator` or `pr-author`), or by an acknowledgement-set agent with no pending entry, that spells the path in another case falls through to the other modes, emits nothing, and writes the ledger. The first operand also uses case-insensitive `-eq`, so the two operands disagree. | Compare the suffix with `[System.StringComparison]::OrdinalIgnoreCase` (and the bare relative form with `-ieq` or the same comparison) in the source and bundle copy, and add a relay-free test row: a subagent `Write` to a case-variant ledger path is denied with `OWNER_DIRECTIVE_LEDGER_WRITE_DENIED`. | Spec D5 and AC-27 state that only the main session writes the ledger; Windows is the primary host for these sessions. The fix is one comparison and one row and widens a deny only. | Source read at head; `enforce-owner-directive-pass-down.Tests.ps1` ledger rows use exact-case paths only |
| Minor (CR1) | `.claude/hooks/enforce-owner-directive-pass-down.ps1` | `Resolve-OwnerDirectivePassDownAck` | For every matched call by an acknowledgement-set agent, the hook resolves the item root (a `git worktree list` through `Resolve-HookTargetWorktree`) and reads the four sources before it knows whether any source exists. The spec Known Limitations disclose the per-call cost, and sibling #1159 targets it. | No change in this item; the #1159 dispatcher work should measure this hook. | Executors issue many Bash calls; the cost is one process and one listing per call. | Spec `## Known Limitations`, per-call cost bullet |
| Minor (CR2) | branch history | commit `a4e992584` | The commit that adds all seven production PowerShell files and seven test suites (3648 insertions) carries the subject `wip: pause checkpoint (owner-requested pause 2026-11-10)`. | Squash-merge, or describe the content in the PR body, so the history names the change. | A pause subject on the main implementation commit makes `git log` and blame less useful. | `git show --stat a4e992584` |
| Info (CR3) | `docs/features/active/owner-directive-pass-down-1157/evidence/baseline/pester-baseline.2026-11-10T04-02.md` | Phase 0 baseline | The Phase 0 Pester run overlapped the writing of a new module of this item (one manifest failure), so it is not a clean pre-change run. Its per-file figures for the two modified files (151 and 142 lines) match the pre-change files, so the no-regression comparison still holds. | None for this item; take a baseline before writing production files in later items. | Recorded so the baseline is not cited as clean pre-change evidence. | The artifact's own failure note |

No covered file in the diff is at or above 700 logical lines (largest: `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`, 543), so no file-size Warning row applies, and `config/file-size-baseline.json` is not in the diff.

## Detailed Review

### Hook structure and fast path

`Get-OwnerDirectivePassDownDecision` returns the dependency decision first, then parses the payload, then branches: a file tool on a ledger path goes to the ledger guard, an acknowledgement-set `agent_type` goes to acknowledgement mode, and an `Agent` or `Task` call to a relay target goes to relay mode. Any other call returns `$null` before a seam is invoked, which `returns before any file, worktree, or clock read for a call outside the three cases` pins. The entry tail fails closed with exit 2 when the guard script does not load. The registration suite and `hook-dependency-guard-completeness` (743 rows) pass.

### Selection and decision modules

`Select-OwnerDirectivePassDown` takes validity only from `Get-OrchestratorStateOwnerDirectiveValidEntry`, compares issue, branch, and step ordinally, and applies strict `expires_at > Now`. `Test-OwnerDirectiveDecision` parses dates with the ISO shape check and `AssumeUniversal`, and compares against `$Now.ToUniversalTime()`; the clock seams return `DateTimeKind.Utc` (pinned by test rows), so no local-time shift enters. The purity rows search the module text case-insensitively for clock, file, and process commands.

### Acknowledgement mode

Decision-file writes are validated against the selected directive and denied when the file exists, the tool is not `Write`, or the `agent_id` segment differs. A decision-file write to a case-variant path does not match the decision regex, but the agent still has a pending entry, so the call is denied with `OWNER_DIRECTIVE_DECISION_REQUIRED`; the hold is not bypassed that way. The ledger guard (F3) has no such backstop.

### Stop-hook sibling

The sibling is called after the #1139 owner-directive block, only when the resolution yields a worktree root. It reads the ledger at the checkpoint root on every stop, and for a linked item checkpoint calls the parent seam once; the clock is read only after a candidate exists. Counting-seam rows pin both. The read seam is the source of F1.

### Mirrors and documentation

All 23 `.claude` paths in the diff are byte-identical to their bundle copies; the six owner-directives copies and six execution-environment copies are byte-identical. The epic-orchestrator, orchestrator, and parallel-orchestrator agent files are untouched. The orchestrator-state rule keeps the #1139 strings and adds the ledger, the two new codes, the amended clock statement, and the enforcement bullet.

### Security and correctness

The ledger and decision files are policy-level controls (spec Known Limitations). F3 is the one path where the hook's own stated guarantee does not hold on the primary host. No artifact records an absolute path; the scratch-file references use the `SCRATCH` token.

## Verification Performed

- `git -C <item worktree> diff 1d62aa292..HEAD` over the hook, siblings, modules, stop hook, rule, and edited suites.
- Full read of `enforce-owner-directive-pass-down.ps1` and `OrchestratorStateOwnerDirectiveDecision.psm1`; targeted reads of the stop-hook sibling and the selection purity rows.
- `cmp` of every `.claude` path in the diff with its bundle copy; `cmp` of the six-copy skill and brief sets.
- Parse of `artifacts/pester/powershell-coverage.xml` LINE counters (repo-wide and seven production files).
- Logical line counts (`awk 'END{print NR}'`) of every covered file in the diff.
- `check_quality_tiers.py` and `validate_evidence_locations.py` against the item worktree: both clean.
- Merge-base CI run 43170341553: every job succeeded, including `Enforce Python coverage thresholds`.

The owner's parallel-only rule forbids single-file Pester runs, so test discrimination was judged by reading the fixtures and rows rather than by reviewer mutant runs.

## Verdict

**REMEDIATION REQUIRED.** Three blocking findings (F1 design, F2 and F3 contained), all autonomous. CR1 to CR3 are non-blocking.
