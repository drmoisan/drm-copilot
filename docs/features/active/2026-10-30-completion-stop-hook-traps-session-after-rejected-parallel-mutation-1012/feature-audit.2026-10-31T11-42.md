# Feature Audit: Completion stop hook mutation rejection signal (#1012)

**Audit Date:** 2026-10-31
**Feature Folder:** `docs/features/active/2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation-1012`
**Base Branch:** `main`
**Head Branch:** `bug/completion-stop-hook-rejected-mutation-1012`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `52d818c3fc93288e1133f7d36fe76857f3c879a4`)
- **Head branch/commit:** `bug/completion-stop-hook-rejected-mutation-1012` (commit `53bdea616163ef327d95d600489c4283ea08d11d`)
- **Merge base:** `52d818c3fc93288e1133f7d36fe76857f3c879a4` (`origin/main` was merged into the branch at `7654423b8`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated 2026-10-31 11:41:38 UTC; Head SHA `53bdea616163ef327d95d600489c4283ea08d11d`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (same invocation)
  - Feature evidence: `evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, `evidence/other/`
  - Additional evidence: reviewer inspection of the diff, the three test files, `artifacts/pester/powershell-coverage.xml`, and `git hash-object` on the seven source/bundle pairs
- **Feature folder used:** `docs/features/active/2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation-1012`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` line 12 carries `- Work Mode: full-bug`; per acceptance-criteria tracking, `full-bug` uses `spec.md` only.
- **Scope note:** Full branch diff `52d818c3f..53bdea616`. AC-20 is CI-dependent; it is evaluated as awaiting CI and left unchecked, per the `### CI-Dependent Criteria` rule.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` - only source (`## Acceptance Criteria`, 20 checkbox items)

### Acceptance criteria

1. AC-1: For each code `kickoff_artifact_missing`, `run_not_started`, `items_in_flight`, and `unknown_item`, a `parallel-orchestrator-state` stop whose final line is `PARALLEL_MUTATION_REJECTED: <code>`, with no live parallel checkpoint, returns `Ok` through `Invoke-OrchestratorOutputValidation` with `stop_hook_active` false and with `stop_hook_active` true (rows in `tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1`).
2. AC-2: A script-tail row in `validate-orchestrator-output.MutationRejection.Tests.ps1` shows the hook exits 0 for a valid signal with no live parallel checkpoint.
3. AC-3: A valid signal with a resolved parallel checkpoint runs full validation: `Get-CheckpointFileContent` and the routing seam are invoked, and a structurally invalid checkpoint still blocks.
4. AC-4: With no signal and no checkpoint, the parallel stop blocks as `NoTarget` on both stops; the existing test `R8 blocks a parallel validation as NoTarget when no live parallel checkpoint exists` passes without modification, and the block message carries one appended hint line naming `PARALLEL_MUTATION_REJECTED: <code>` and `## Mutation Rejection Signal (issue #1012)`.
5. AC-5: No allow occurs for a non-conforming signal: token on an earlier line, token followed by text, lowercase prefix, uppercase code, backtick-wrapped, bold-wrapped, double space after the colon, unknown code, or empty output (unit rows in `validate-orchestrator-output-rejection.Tests.ps1`); trailing CRLF and trailing blank lines after a valid line are tolerated.
6. AC-6: A final line with the `PARALLEL_MUTATION_REJECTED:` prefix and a code outside the closed set produces a repairable block whose message lists the allowed codes.
7. AC-7: A valid signal with resolver `Status` `Ambiguous`, or with a `Rejected` leaf, blocks as today.
8. AC-8: A valid signal with no resolvable checkpoint blocks when any live root holds non-blank parallel checkpoint text that is unparseable, has a non-object root, is off-route, lacks a slug, or records the slug the output names; other-slug and blank text do not defeat the allow.
9. AC-9: A valid signal on `orchestrator-state` and on `epic-orchestrator-state` produces the same decision as without the signal; `O-5 epic target not derivable blocks always`, `E-ORC-2 blocks with exit 2 when the checkpoint cannot be resolved`, R9, R10, R11, `H5 does not run the port for the parallel checkpoint type`, `denies a missing parallel checkpoint (fail closed)`, and `S2-6 passes the cross-check for every existing SubagentStop registration unchanged` pass without modification.
10. AC-10: `.claude/rules/parallel-orchestration.md` contains `## Mutation Rejection Signal (issue #1012)` immediately after `## Enum Ownership (F6/F7/F8 consume, never extend)` and before `## F7 Seam`, defining the line grammar and the closed code set exactly once, stating it is an output signal and not one of the nine enums, and stating the hook behavior and the consume-never-redefine rule.
11. AC-11: A Pester parity row reads the rule section and asserts its code set equals the script-scope array in `validate-orchestrator-output-rejection.ps1`.
12. AC-12: `test_parallel_mutation_rejection_signal_contracts.py` passes, asserting that `parallel-run`, `parallel-add`, `parallel-close`, and `parallel-remove` each emit only their mapped code on each mapped STOP path in the emission table, cite `## Mutation Rejection Signal (issue #1012)` by heading, and do not restate the full member set.
13. AC-13: `parallel-add`, `parallel-close`, and `parallel-remove` each state that the run-existence check is evaluated first, and the affected skills state that the unmapped STOP paths listed in this spec emit no signal; all pinned fragments listed under Boundaries and invariants remain byte-stable and their tests pass.
14. AC-14: The changed or new source files listed as items 1-7 under Files/modules to change are byte-identical to their bundle copies (items 8-14), `pack-manifests/core.json` lists `.claude/hooks/validate-orchestrator-output-rejection.ps1`, and `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`, and `test_claude_rules_frontmatter.py` pass.
15. AC-15: `hook-dependency-guard-completeness.Tests.ps1` (S1-S6) and the no-Python-in-hooks suite pass; the new sibling is loaded by a single-statement guarded `try` with `Add-HookDependencyFailure`, imports no module, and starts no process.
16. AC-16: `.claude/settings.json`, `.claude/agents/parallel-orchestrator.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, the execution-environment brief, and every `.codex/`, `.agents/`, and `.github/` file are unchanged in the branch diff.
17. AC-17: `validate-orchestrator-output-rejection.ps1` and `validate-orchestrator-output.ps1` each report at or above 85% line coverage in `artifacts/pester/powershell-coverage.xml`.
18. AC-18: The full toolchain passes in a single pass (format, lint, type-check, architecture, unit, contract, integration) for the changed PowerShell and Python files, the new suites satisfy `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` AC-6, and three seeded shuffled runs plus one single-process run over `tests/scripts` pass, with evidence under `evidence/qa-gates/` and `evidence/regression-testing/`.
19. AC-19: No changed or new file exceeds 800 logical lines.
20. AC-20 (CI-dependent): The CI run on the PR head, including the Linux `poshqc / PowerShell hook suites` job, concludes `success`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 allow for each code, both `stop_hook_active` values | PASS | `MutationRejection.Tests.ps1` lines 147-184 (8 rows, `Ok` true, `Get-CheckpointFileContent` invoked 0 times); `evidence/qa-gates/pester-coverage.2026-10-31T11-13.md` (28 of 28 suite rows passed) | Reviewer read of the test file and JUnit summary in evidence | Expect-fail record shows these 8 rows failed before the fix. |
| 2 | AC-2 script-tail exit 0 | PASS | `MutationRejection.Tests.ps1` lines 369-387; suite passed in the full run | Reviewer read of the test file | Row asserts no throw, exit 0, empty stderr. |
| 3 | AC-3 resolved checkpoint validates fully | PASS | Lines 186-222: read seam invoked once at the resolved path, routing seam called once, missing `next_step` blocks | Reviewer read; `hook-suites.2026-10-31T10-50.md` | Code inspection confirms the decision call is unreachable when `Resolved` is true. |
| 4 | AC-4 no signal, no checkpoint: NoTarget block with hint; R8 unmodified | PASS | Lines 224-240; `hook-suites.2026-10-31T10-50.md` (R8 PASSED); `assertion-preservation.2026-10-31T10-57.md` (no existing test file modified) | `git diff --name-status 52d818c3f HEAD` (only three test files, all added) | Message prefix unchanged, so `StartsWith` assertions hold. |
| 5 | AC-5 non-conforming signals rejected; CRLF and trailing blanks tolerated | PASS | `validate-orchestrator-output-rejection.Tests.ps1` lines 80-118 (9 negative cases, 2 tolerance rows) | Reviewer read | All nine listed forms present as rows. |
| 6 | AC-6 invalid code lists allowed codes, repairable | PASS | `MutationRejection.Tests.ps1` lines 242-257; hint helper lines 166-170 | Reviewer read | Repairable flag comes from the unchanged `NoTarget` computation. |
| 7 | AC-7 Ambiguous and Rejected block | PASS | Lines 259-292; decision helper line 131 (`-cne 'NoTarget'`) | Reviewer read | Both rows assert the original message prefix and zero checkpoint reads. |
| 8 | AC-8 contradicting live text blocks; other-slug and blank allow | PASS | Lines 294-344; unit rows lines 121-156 | Reviewer read | Five defeating forms and two non-defeating forms covered. |
| 9 | AC-9 orchestrator-state and epic-orchestrator-state unchanged; named regression rows pass unmodified | PASS | Lines 346-367 (message equality with and without signal); `hook-suites.2026-10-31T10-50.md` (O-5, E-ORC-2, R9-R11, H5, fail-closed dispatch, S2-6 PASSED) | Reviewer read | Artifact-type gate is the first check in the decision helper. |
| 10 | AC-10 rule section position and content | PASS | `.claude/rules/parallel-orchestration.md` diff: section inserted after `## Enum Ownership ...` and before `## F7 Seam`; grammar, four-code table, "not one of the nine enums", hook table, ownership paragraph | `git diff 52d818c3f HEAD -- .claude/rules/parallel-orchestration.md`; `python-contracts.2026-10-31T10-56.md` | The codes appear in the rule exactly once each (table rows). |
| 11 | AC-11 Pester parity row | PASS | `MutationRejection.Tests.ps1` lines 389-411 compare the rule table with `$script:ParallelMutationRejectionCodes` and assert count 4 | Reviewer read | Sibling array is the only other definition (grep over `.claude/`). |
| 12 | AC-12 Python emission contract test | PASS | `test_parallel_mutation_rejection_signal_contracts.py`; `python-contracts.2026-10-31T10-56.md` (235 passed) | Grep of skill files: run 1, add 1, close 2, remove 3 code occurrences | No skill names all four codes. |
| 13 | AC-13 run-existence first, unmapped no-signal statements, pinned fragments stable | PASS | Skill diffs (Prerequisites bullets; "emits no rejection signal" statements); pinned-fragment modules within the 235 passing contract tests | `git diff 52d818c3f HEAD -- .claude/skills` | See code-review CR-4 on the spec's mention of `parallel-orchestrate` (no AC impact). |
| 14 | AC-14 byte parity, manifest entry, push-down tests | PASS | Reviewer `git hash-object` on 7 pairs: identical blob ids; `core.json` diff adds the entry; `mirror-parity.2026-10-31T10-57.md` (7 of 7 equal; 104 passed) | `git hash-object <source> <bundle>` | Codex generator check reports no drift. |
| 15 | AC-15 dependency guard, no-Python, guarded load, no import or process | PASS | Main-hook diff line 60 (single-statement guarded `try`); AST row in the unit suite; `pester-coverage.2026-10-31T11-13.md` (671 and 33 rows passed) | Reviewer read | |
| 16 | AC-16 excluded surfaces unchanged | PASS | `git diff --stat 52d818c3f HEAD -- config/ .codex/ .agents/ .github/ .claude/settings.json .claude/agents/ .claude/skills/parallel-orchestrate/ .claude/skills/execution-environment/` returned no output | Same command | |
| 17 | AC-17 per-file line coverage at or above 85% | PASS | `artifacts/pester/powershell-coverage.xml` class counters: sibling LINE missed 0, covered 43 (100.00%); hook LINE missed 1, covered 122 (99.19%) | Reviewer read of the class counters | The artifact's repo-wide counters come from a later targeted run (policy-audit PA-1); the per-file figures match `coverage-comparison.2026-10-31T11-13.md` exactly. |
| 18 | AC-18 full toolchain single pass, epic-state isolation, isolation runs | PASS | `poshqc-format.2026-10-31T10-56.md`, `pssa.2026-10-31T10-56.md`, `python-black/ruff/pyright.2026-10-31T10-56.md`, `pester-coverage.2026-10-31T11-13.md` (13601 passed, 0 failed), `python-contracts.2026-10-31T10-56.md`, `mirror-parity.2026-10-31T10-57.md`, `isolation.2026-10-31T11-33.md` (3 seeds, 1564 of 1564 each) | Reviewer read of evidence | `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` passed 427 rows. |
| 19 | AC-19 no file above 800 logical lines | PASS | Reviewer counts: 172, 376, 251, 412, 280 (and 172, 376 for bundle copies) | `awk 'END{print NR}' <file>` | No file at or above 700 lines. |
| 20 | AC-20 CI on the PR head concludes `success` | UNVERIFIED | No PR exists yet (`artifacts/pr_context.summary.txt`: "no PR exists yet for this branch") | Pending S9 CI gate | Awaiting CI; not a failure. Left unchecked; the item's orchestrator run checks it off at S9. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION (awaiting CI only; no code change required)

**Criteria summary:**
- **PASS:** 19 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-20, awaiting CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC-20: the CI run on the PR head, including the Linux `poshqc / PowerShell hook suites` job, has not run because no PR exists. Classified `awaiting_ci`.
2. Policy-audit PA-1 and PA-2 (coverage figures recorded from CI) are tracked in the policy audit and the remediation inputs; neither affects an AC verdict.

**Recommended follow-up verification steps:**

1. Open the PR and, at the S9 CI gate, record the CI conclusion for the PR head and check off AC-20 in `spec.md`.
2. Record the `poshqc` job's `Merged PowerShell line coverage` line and the `Enforce Python coverage thresholds` step conclusion under `evidence/qa-gates/`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- AC-1 through AC-19 were already checked off by the executor; each was re-verified as PASS above, so no source-file change was needed.
- AC-20 is UNVERIFIED (awaiting CI) and remains unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation-1012/spec.md`
- Total AC items: 20
- Checked off (delivered): 19
- Remaining (unchecked): 1
- Items remaining: AC-20 (CI-dependent): The CI run on the PR head, including the Linux `poshqc / PowerShell hook suites` job, concludes `success`.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 20 | 19 | 1 | Checkbox-backed; AC-20 awaiting CI |

No source-file checkbox change was made by this review: the 19 PASS items were already checked, and AC-20 must stay unchecked until CI succeeds.
