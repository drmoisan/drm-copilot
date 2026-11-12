# Code Review: Orchestration Test Cadence, Task Check and Phase Gate (Issue #1167)

**Review Date:** 2026-11-12
**Branch:** `bug/orchestration-test-cadence-targeted-per-task-1167` @ `b9a97e86590e0d2a0a026d29d63b3ef6cba145de` (PR #1168)
**Base:** `main`; merge base `228e6f8c4606e53f36963dc9aa57d71b4882b49e` (equal to `origin/main` at review time)
**Scope:** full branch diff, 168 files (167 Markdown, TOML, template, and evidence files; one new Pester test file). Re-review after remediation cycle R1 (`b9a97e865`, 58 files).

## Executive Summary

Remediation cycle R1 resolves the prior blocking finding F1. The canonical `## Test Cadence (Mandatory)` section now states how an `[expect-fail]` phase is gated (its gate's unit stage accepts only the plan's named expected failures, each confirmed failing, and every other test must pass) and that a phase changing no tracked file needs no gate. The seven planner surfaces restate both provisions, the bug template marks Phase 1 as a no-change phase and turns its Phase 2 closing task into an expect-fail-aware `[phase-gate]`, and the feature and refactor templates already agree. The suite pins the new rule and was shown to discriminate by reviewer mutants. The three non-blocking items from the prior review (CR1 to CR3) are resolved.

No blocking finding remains. Three informational items follow (N1 to N3); none requires a change in this PR.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info (N1) | `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` | `TCW-PLANNER` rows for the four Copilot planners (file-level check, no heading) | The Copilot planner rows require `no-change phase` anywhere in the file. The checklist parenthetical "(an `[expect-fail]` phase keeps its gate; a no-change phase needs none)" also holds the token, so deleting only the no-change clause from the requirement bullet goes undetected. Deleting the whole D15 sentence is still detected because the checklist line does not hold `expected failures`. | Optional, in a later change: scope the Copilot planner check to the `If the plan changes code or tests` bullet. | The surviving mutant leaves the checklist line stating the rule, so the planner still receives it; the gap is narrow. | Reviewer mutant `planner` in a `git archive` copy: 136 of 136 rows passed |
| Info (N2) | `.claude/skills/atomic-plan-contract/SKILL.md` and five copies | `## Test Cadence (Mandatory)`, bullet `No-change phase` | "changes no tracked file" is read together with "such as an investigation or reproduction phase that only writes evidence". Evidence files are committed, so a strict reader could say such a phase changes tracked files. The example makes the intent clear. | None required. A later wording pass could say "changes no tracked file other than evidence". | The example resolves the reading; no gate or validator depends on the phrase. | Canonical text at head |
| Info (N3) | `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md` | `[P2-T2]` | `[P2-T2]` changed from `[expect-fail]` (run the gate to confirm the failure) to `[phase-gate]`; the `[expect-fail]` tag stays on `[P2-T1]`. The Python atomic executor CLI (`cli_execute_one_task.py`) accepts a failing test command only on an `[expect-fail]` task, so a CLI-executed plan that copies `[P2-T2]` and runs pytest there would not treat the expected failure as accepted at the task level; the phase-end `run_full` call receives the plan's expectations. The CLI is out of scope by spec D10 and is unchanged. | None in this PR. If the CLI is used for full-bug plans, confirm with a CLI run that the phase-end check accepts the `[P2-T1]` expectation. | The agent-facing rule (D15a) is the specified source; the CLI is not the executor the templates target, and no test or validator reads the tag on `[P2-T2]`. | `scripts/dev_tools/atomic_executor/cli_execute_one_task.py` expect-fail branch; `cli.py` phase-end `run_full(expectations=...)` |

No covered file is at or above 700 logical lines (the new suite has 541); no file-size Warning row applies.

## Detailed Review

### F1 resolution (expect-fail and no-change phases)

The two added canonical bullets sit directly after the phase-gate bullet in all six contract copies (base and bundle blob `f47258725` for the Claude pair). The expect-fail bullet keeps the owner rule "a full test after every phase": the gate still runs stages 1 to 6 and still requires every test outside the plan's named `[expect-fail]` set to pass, so a regression elsewhere fails the gate. Requiring each expected failure to be "confirmed failing" and listed by name in the gate evidence keeps the acceptance auditable. The no-change bullet removes the gate from a phase that has nothing for the gate to verify, and states that the next gate covers it.

The bug template now reads phase by phase in agreement with the rule: Phase 1 is marked no-change, Phase 2 ends with an expect-fail-aware gate that names `[P2-T1]`, Phase 3 ends with a normal gate, and Phase 4 is the final QA loop. The feature template gates Phase 1, and its Phase 2 is the last phase. The refactor template's Phase 1 (inventory) changes no tracked file, its Phase 2 is gated, and Phase 3 is verification.

### CR1 to CR3

- CR1: the `0011` `## Summary` names PR #1168; `stand-in` no longer occurs in the entry.
- CR2: both `## Mandatory Toolchain Loop` copies now stop "when every stage it runs completes without errors in a single pass; at phase gates and in the final QA loop, stage 7 runs in CI". The phase gate's stages 1 to 6 remain mandatory through the canonical section, so the change does not let an executor skip a local stage. `TCW-POLICY` rows require `every stage it runs` and forbid `all seven stages`.
- CR3: the sweep roots include `CLAUDE.md` and `.github/copilot-instructions.md`.

### Tests

The template row now computes each gate's phase bounds from the phase headings and checks gate count, last-task position, a later task, expect-fail wording and count, and the no-change heading per template. `TCW-CANONICAL-DISCRIMINATES` proves the canonical check reports all six D15 tokens when the D15 lines are removed in memory. Reviewer mutants in a `git archive` copy of the head tree:

| Mutant | Result |
|---|---|
| Control (no mutation) | 136 passed |
| Expected-failure clause removed from the bug Phase 2 gate | `TCW-TEMPLATE-BUG` failed: gate line of an expect-fail phase names no expected failures |
| No-change marker removed from bug Phase 1 heading | `TCW-TEMPLATE-BUG` failed |
| Bug template restored to the pre-R1 text | `TCW-TEMPLATE-BUG` failed: expected 2 gate lines, found 1 |
| No-change bullet deleted from the `.github` contract bundle | `TCW-CANONICAL-GITHUB-BUNDLE` failed: three D15 tokens reported absent |
| No-change clause removed from the C# Copilot planner requirement bullet | survived (N1) |

### Ledger

The reviewer replayed all 74 revert blocks of `0011` at head: each `Current` fence occurs once in its target, and substituting `Prior` restores all 49 non-identical sources to their merge-base content. The five ledger suites pass.

### Security and correctness

Text and test changes only. The suite runs no process, writes no file, and builds paths from `$PSScriptRoot`. No artifact records an absolute path.

## Verification Performed

- `git -C <item worktree> diff d789aa821..b9a97e865` over the contract, planner, policy, template, ledger, and test files; `git diff --stat` of the full branch.
- Reviewer Pester run (`New-PesterConfiguration`, `Run.PassThru`) over the new suite, `parallel-gate-wording.Tests.ps1`, `planning-contract-wording.Tests.ps1`, and the five ledger suites: 455 passed, 0 failed.
- Six mutation probes of the cadence suite in a scratch `git archive` copy (table above).
- Ledger `0011` revert replay against the merge base: 49 of 49 targets equal.
- `generate_codex_agent_variants --check`: exit 0. `validate_evidence_locations.py --root .`: exit 0.
- `git ls-files -s` blob comparison of the contract and bug-template pairs.
- `git fetch origin main` and `git merge-tree --write-tree origin/main HEAD`: no drift, no conflict.
- Logical line count of the new suite: 541.

## Verdict

**PASS.** No blocking finding. N1 to N3 are informational. AC14 is pending CI (two PowerShell QC shards pending at review time).
