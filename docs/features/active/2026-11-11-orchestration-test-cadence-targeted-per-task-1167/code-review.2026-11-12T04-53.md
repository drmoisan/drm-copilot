# Code Review: Orchestration Test Cadence, Task Check and Phase Gate (Issue #1167)

**Review Date:** 2026-11-12
**Branch:** `bug/orchestration-test-cadence-targeted-per-task-1167` @ `d789aa821f900b36dfc884952ffc45126e15a042` (PR #1168)
**Base:** `main`; merge base `228e6f8c4606e53f36963dc9aa57d71b4882b49e`
**Scope:** full branch diff, 149 files (148 Markdown, TOML, and template files; one new Pester test file)

## Executive Summary

The change does what the spec asks on every surface the spec names: the cadence is defined once in `## Test Cadence (Mandatory)`, every per-task full-run prescription is replaced with a reference sentence, the Codex variants are regenerated, the mirrors are byte-identical, and the new suite pins all of it. The suite is well structured and its sweep is shown to discriminate: the seven sweep tokens occur in more than 30 surface files at the merge base.

One blocking design defect remains in the canonical rule itself (F1): it requires a clean full-suite gate at the end of every intermediate phase and does not say what happens when that phase ends with an `[expect-fail]` regression test still failing. The bug plan template, which every full-bug plan starts from, puts that test in its own phase and shows no gate there. Three non-blocking items follow.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (blocking, F1) | `.claude/skills/atomic-plan-contract/SKILL.md` and five copies; `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md` and bundle | `## Test Cadence (Mandatory)`, bullet `Phase gate (after each phase)`; bug template `Phase 1 — Preparation`, `Phase 2 — Regression Test (must fail first)` | The rule requires every phase between Phase 0 and the final QA phase to end with a `[phase-gate]` task that closes only after one clean pass of the full unit suite. A phase whose last task is `[expect-fail]` ends with a failing test by design, so its gate cannot pass, and the rule gives no exception. The bug template shows a gate only in Phase 3, so Phases 1 and 2 contradict the rule the template cites. | State in the canonical section how such a phase is gated (for example: the gate of a phase that ends with an `[expect-fail]` task accepts exactly the expected failures recorded in that task's evidence and no other failure; or such a phase carries no gate and the next phase's gate covers it), and state whether a phase that changes no file needs a gate. Align the three templates, the planner surfaces, and `TCW-CANONICAL` and `TCW-TEMPLATE` rows; refresh the `0011` revert blocks. | A planner that follows the rule writes an unpassable gate into every bug plan; one that follows the template writes a plan that violates the rule. Either result surfaces as a preflight or review defect on every full-bug orchestration. | Canonical text read at head; `docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md` Phases 1 to 4; `## Expect-Fail Test Tasks` holds no gate provision |
| Minor (CR1) | `docs/engineering/process-reductions/0011-task-check-cadence.md` | `## Summary`, last sentence | After `d789aa821` the `Merge commit:` line reads `pending (PR #1168)`, but the summary still says the line carries the canonical issue number as a stand-in. | Reword the sentence to match the line, in the F1 remediation commit. | Ledger prose should describe the entry as it stands. | `git show d789aa821` |
| Minor (CR2) | `.claude/rules/general-code-change.md` and three counterparts | `## Mandatory Toolchain Loop` | The section still says "Do not stop the loop until all seven stages complete without errors in a single pass", and the added sentence moves stage 7 to CI for phase gates and the final QA loop. The two sentences read as a conflict on stage 7. | Optional: qualify the earlier sentence ("all stages that run locally") in a later change. | The intent is clear from the added sentence; no executor behavior is ambiguous enough to fail a gate. | Diff of the rule file |
| Info (CR3) | `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` | `Get-TcwSweepFile`, `$script:SweepRoot` | The sweep roots do not include `CLAUDE.md` or `.github/copilot-instructions.md`. Neither holds a sweep token today. | Optional: add both files as leaf roots. | Keeps the sweep closed over every standing-instruction surface. | Reviewer `git grep` at head |

No covered file is at or above 700 logical lines; no file-size Warning row applies.

## Detailed Review

### F1, phase gate and `[expect-fail]` phases

The canonical bullet reads: "The last task of every phase between Phase 0 and the final QA phase carries the `[phase-gate]` tag ... On a failure or an auto-fix, fix the cause and restart from step 1; the phase closes only after one clean pass." The only exceptions are Phase 0 and the final QA phase. The bug template's Phase 2 adds a regression test tagged `[expect-fail]` and runs the parallel gate to confirm it fails; the fix lands in Phase 3. A gate at the end of Phase 2 would therefore run the full unit suite with a known failing test and could not reach one clean pass. "Fix the cause" at that point would mean implementing the Phase 3 fix inside Phase 2.

The template avoids the deadlock by giving Phase 2 no gate, but that contradicts the rule, and `TCW-TEMPLATE-BUG` pins exactly one gate line, so the suite locks the contradiction in. Phase 1 (preparation, no file change) has the same mismatch with lower impact. The owner rule ("a full test after every phase") can be kept by either documented resolution; the choice is a wording decision the planner can make within the owner's rule and the spec's D4, so the finding is autonomous. It changes the canonical section in six copies, the ledger blocks, and the suite, so it is not a contained fix.

### Tests

The suite reads each requirement in the narrowest scope, which prevents a token elsewhere in the file from satisfying a row. `Get-TcwSection` handles fenced headings and stops at an equal-or-higher heading. The sweep helper row proves each token is detected after case change and pins the count. The byte-identity rows close the gap for the five Copilot files not covered by other parity tests. The reviewer ran the suite with the #1094 and #1097 wording suites and the five ledger suites: 454 tests, 0 failed.

### Mirrors and generated files

`generate_codex_agent_variants --check` exits 0. The contract base and its bundle share one blob id; the six brief copies share one blob id. The bundle-only csharp-legacy variants carry the reference sentence (`TCW-RULE-*-CSHARP-LEGACY`, `TCW-QAGATE-*-CSHARP-LEGACY`).

### Residual wording sweep

A reviewer search of the harness roots for per-task run wording outside the reference sentence found only "For each task:" step lists and the `5.1-Beast-adjusted` agent line "Run static checks after each change, and the single gate run when the change is complete", which prescribes no per-task full suite. `planned batch` remains only in the ledger's prior-text blocks.

### Security and correctness

Text and test changes only. The suite runs no process, writes no file, and builds paths from `$PSScriptRoot`. No artifact records an absolute path.

## Verification Performed

- `git -C <item worktree> diff 228e6f8c4..HEAD` over the canonical, policy, orchestrate, executor, planner, prompt, rule, QA-gate, brief, and template files.
- Reviewer Pester run (`New-PesterConfiguration`, `Run.Exit = $true`) over the new suite, `parallel-gate-wording.Tests.ps1`, `planning-contract-wording.Tests.ps1`, and the five ledger suites: 454 passed, 0 failed.
- `generate_codex_agent_variants --check`: exit 0.
- `git ls-files -s` blob comparison of contract and brief copies.
- `git grep` of the seven sweep tokens at the merge base (30 or more surface files) and of residual per-task wording at head.
- `validate_evidence_locations.py --root <item worktree>`: exit 0.
- Logical line count of the new suite: 499.

## Verdict

**REMEDIATION REQUIRED.** One blocking design finding (F1). CR1 should be folded into the same cycle; CR2 and CR3 are optional.
