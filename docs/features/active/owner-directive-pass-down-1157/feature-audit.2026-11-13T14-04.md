# Feature Audit: Owner-Directive Pass-Down to Executing Agents (Issue #1157)

**Audit Date:** 2026-11-13
**Branch:** `feature/owner-directive-pass-down-1157` @ `621a6b83df30184693f563b9577a0c4f0a5753d5` (no PR open yet)
**Base:** `main`; merge base `1d62aa292161035aec8058e6c370f133e10a04db`

## Scope and Baseline

- Scope: the full branch diff `1d62aa292..621a6b83d`, 119 files, read through `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated at this head) and direct `git diff`.
- Baseline: the merge base on `main` (resolved base branch `main`, `origin/main` at PR #1168), and the Phase 0 artifacts `evidence/baseline/pester-baseline.2026-11-10T04-02.md`, `pytest-baseline.2026-11-10T04-08.md`, `powershell-static.2026-11-10T03-13.md`, `python-static.2026-11-10T03-14.md`.
- Requirements source and work mode: `issue.md` marker `Work Mode: full-feature`, so the AC sources are `spec.md` `## Acceptance Criteria` (AC-1 to AC-48) with its `## Definition of Done` checkboxes, and `user-story.md` Acceptance Criteria (12 items).
- Final gate evidence: `evidence/qa-gates/pester-final.2026-11-12T13-05.md` (21791 testcases, 0 failed), `coverage-comparison.2026-11-12T13-05.md`, `powershell-static.2026-11-12T12-38.md`, `python-static.2026-11-12T12-38.md`, `pytest-final.2026-11-13T13-47.md` (16598 passed, 0 failed), `evidence/other/scope-check.2026-11-13T13-48.md`.

## Acceptance Criteria Inventory

| ID | Criterion (abbreviated) | Source |
|---|---|---|
| AC-1 to AC-9 | Selection scope, fan-out, step, expiry, B-rule validity, refused classes, conflicts, rendering, module purity | `spec.md` |
| AC-10 to AC-13 | Relay mode for every target and phase, coordinator prompt-only check, non-target inert | `spec.md` |
| AC-14 to AC-22 | Acknowledgement hold and release, grammar, decision rules, decision-file write rules, inert ids and callers, optional record fields, write-on-return doc | `spec.md` |
| AC-23 to AC-26 | Item and parent resolution, inert default, no no-end-turn rule | `spec.md` |
| AC-27, AC-28 | Ledger guard; preimplementation gate path pin | `spec.md` |
| AC-29 | R3 and R6 unchanged; three existing suites pass without edits | `spec.md` |
| AC-30 to AC-35 | Stop-hook running-child and item checks, key gate, guarded import | `spec.md` |
| AC-36 to AC-39 | Registration, `core.json`, bundle copies, dependency and exemption lists | `spec.md` |
| AC-40 to AC-46 | Documentation and mirror parity; orchestrator agents unchanged; digest re-baseline | `spec.md` |
| AC-47, AC-48 | New-file coverage at or above 90% and repo at or above 85%; no new Python | `spec.md` |
| DoD-1 to DoD-5 | AC mapping, toolchain loop, mirror parity, append-only evidence, CI green | `spec.md` |
| US-1 to US-12 | Story-level restatements of the spec criteria | `user-story.md` |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| AC-1 | PASS | `OrchestratorStateOwnerDirectiveSelection.Tests.ps1` case-differing and null-branch rows; 70/0 in the final gate. |
| AC-2 | PASS | Fan-out positive and three negative rows in the selection suite; hook row "holds the worker for an epic fan-out entry in the parent checkpoint". |
| AC-3 | PASS | `S5` against `S5_atomic_execution`, `S51`, `S5x` rows. |
| AC-4 | PASS | `expires_at` at `Now` plus one second, equal to `Now`, before `Now` rows; strict comparison in the module. |
| AC-5 | PASS | Selection rule 1 rows per B2-B8; `OrchestratorStateOwnerDirectives.Entry.Tests.ps1` 17/0. |
| AC-6 | PASS | Six refused-class and five honorable-class rows. |
| AC-7 | PASS | Both conflict rows. |
| AC-8 | PASS | Rendered block compared with the fenced example read from the committed skill; ordering, echo, CRLF, and prompt-coverage rows. |
| AC-9 | PASS | Purity rows in both suites (case-insensitive search of the module text; `-Now` declared on time-dependent functions); reviewer read of `OrchestratorStateOwnerDirectiveDecision.psm1` found no clock, file, or process call. |
| AC-10 | PASS | Hook rows for each of the ten targets under both deny conditions, asserting the block and the JSON entry; 81/0. |
| AC-11 | PASS | `next_step` rows for S2, S3, S4, S5, R1, S7, R4. |
| AC-12 | PASS | Coordinator launch denied without the rendered lines and allowed with them, without a child checkpoint. |
| AC-13 | PASS | `pr-author` row. |
| AC-14 | PASS | Seven acknowledgement-set rows asserting block, refused note, decision paths, grammar, and clock. |
| AC-15 | PASS | Release and re-hold row. |
| AC-16 | PASS | Decision suite parse and reject rows; anchored pattern read in the module. |
| AC-17 | PASS | Decision suite R4, R6 per refused class, R10, future `decided_at`, 19 and 20 character rows. |
| AC-18 | PASS | Valid and invalid decision-file write rows. |
| AC-19 | PASS | Existing file, `Edit`, other `agent_id` rows. |
| AC-20 | PASS | Inert agent-id rows and never-held caller rows. |
| AC-21 | PASS | Entry suite AC-21 rows. |
| AC-22 | PASS | `owner-directives-skill-contract.Tests.ps1` 73/0 with the `decision_source` and `decided_by` row. |
| AC-23 | PASS | `owner-directive-pass-down-target.Tests.ps1` 33/0 covering cwd, both transcript forms, and no root. |
| AC-24 | PASS | Parent-ledger hold row with an unchanged item checkpoint; parent resolver rows for both kinds. |
| AC-25 | PASS | Hook inert matrix rows; stop-hook key-gate rows with counting seams; existing `validate-orchestrator-output*` suites pass. |
| AC-26 | PASS | Contract rows for the epic skill (hook name present, `does not end its turn` absent). |
| AC-27 | PASS | Ledger guard rows pass as specified. The case-sensitivity gap on Windows is recorded as F3, a finding outside the criterion's tested rows. |
| AC-28 | PASS | Registration suite `Test-ImplementationPath` rows. |
| AC-29 | PARTIAL | R3 and R6 strings unchanged and all three suites pass (74/0, 53/0, 22/0). `OrchestratorStateOwnerDirectives.Tests.ps1` and `.Records.Tests.ps1` are unchanged, but `validate-orchestrator-output.OwnerDirectives.Tests.ps1` carries one added mock line, so "pass without edits" is not met (F1). |
| AC-30 | PASS | Stop-hook suite rows for every epic status; 44/0. |
| AC-31 | PASS | Rows for every parallel status. |
| AC-32 | PASS | Compliant, unresolvable, unreadable, not-linked, conflict, and expired rows. |
| AC-33 | PASS | Item-stop rows for ledger, parent checkpoint, and parent ledger; ledger-invalid row; worker-side rows in the hook suite. |
| AC-34 | PASS | Key-gate rows with counting parent and clock seams; fixed clock. |
| AC-35 | PASS | Guarded imports read in the stop-hook diff; `hook-import-failure-exemptions.FailClosed` 28/0, `hook-dependency-guard-completeness` 743/0, `enforcement-hooks-no-python-invocation` 35/0. |
| AC-36 | PASS | Registration suite 10/0; reviewer `cmp` of both settings files. |
| AC-37 | PASS | Five `core.json` entries; `test_push_down_pack_manifest_dependency_closure.py` 18 and `OrchestratorState.Manifest` 6/0 pass. |
| AC-38 | PASS | Reviewer `cmp` of all seven PowerShell `.claude` files with bundle copies; push-down contract tests pass. |
| AC-39 | PASS | Diff lines in `hook-dependency-failure.Claude.Tests.ps1` and `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`. |
| AC-40 | PASS | Reviewer `cmp` of the six owner-directives copies; contract suite passes. |
| AC-41 | PASS | Three skills with byte-identical bundle copies (reviewer `cmp`). |
| AC-42 | PASS | Nine agent files with bundle copies byte-identical; `test_claude_rules_frontmatter.py` 9 passes. |
| AC-43 | PASS | The three orchestrator agent files are absent from the diff (reviewer `git diff --name-only`). |
| AC-44 | PASS | Rule diff read; rule and bundle byte-identical. |
| AC-45 | PASS | Six brief copies byte-identical (reviewer `cmp`); `test_execution_environment_brief_contracts.py` 23 passes. |
| AC-46 | PASS | `evidence/other/frozen-digest.2026-11-11T04-50.md`; only the skill digest moved; frozen-surface test passes in the post-merge gate. The #1167 merge did not edit the epic skill. |
| AC-47 | PASS | Reviewer parse of `artifacts/pester/powershell-coverage.xml`: new files 91.41%, 92.50%, 92.86%, 100.00%, 98.53%; repo 95.79%; leak scan 0 failures. Recorded under `evidence/qa-gates/` per the plan's evidence-location override. |
| AC-48 | PASS | One modified `.py` path, no added `.py`; no Codex, Copilot hook, or validator file changed (reviewer diff listing). |
| DoD-1 | PASS | Every AC maps to a named row or artifact (plan tasks). |
| DoD-2 | PENDING-CI | Toolchain stages 1 to 6 pass locally; stage 7 runs in CI. |
| DoD-3 | PASS | Reviewer `cmp` results. |
| DoD-4 | PASS | `git log --name-status` shows only additions under `evidence/`. |
| DoD-5 | PENDING-CI | No PR exists yet. |
| US-1 to US-12 | PASS | Each restates spec criteria evaluated PASS above. US-8 cites AC-29 to AC-35; its own text (R3 and R6 still block; `OWNER_DIRECTIVE_RELAY_MISSING` blocks running children and item checkpoints) is met, and it carries no "without edits" clause. |

## Findings Outside the Criterion Text

- F2 (blocking, contained): the Python post-change coverage artifact is absent although the branch changes one Python file.
- F3 (blocking, contained): the ledger guard's path test is case-sensitive, so a subagent `Write` with a case-variant ledger path is not denied on Windows.
- Details: `code-review.2026-11-13T14-04.md`, `remediation-inputs.2026-11-13T14-04.md`.

## Summary

Spec: 47 of 48 criteria PASS, AC-29 PARTIAL (F1); Definition of Done 3 PASS and 2 pending CI. User story: 12 of 12 PASS. Three blocking findings, all autonomous; verdict REMEDIATION_REQUIRED.

### Acceptance Criteria Status
- Source: `docs/features/active/owner-directive-pass-down-1157/spec.md`, `docs/features/active/owner-directive-pass-down-1157/user-story.md`
- Total AC items: 65 (spec 48 criteria and 5 Definition of Done items; user story 12)
- Checked off (delivered): 62
- Remaining (unchecked): 3
- Items remaining: AC-29 (PARTIAL, F1); Definition of Done "Toolchain loop passes in a single pass" (pending CI); Definition of Done "CI green on the PR head after the final `origin/main` merge and digest recompute" (pending CI).

## Acceptance Criteria Check-off

The executor had already checked every item this review evaluates as PASS (spec 47 criteria and 3 Definition of Done items; user story 12); this review confirms each and makes no new check-off. AC-29 stays unchecked as PARTIAL, and the two CI-dependent Definition of Done items stay unchecked for check-off at S9 by the item's orchestrator run. No item was unchecked by this review.
