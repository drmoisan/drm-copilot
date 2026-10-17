# Code Review: Orchestration Completion-Gate and Tooling Friction (#744)

- **Branch:** `bug/orchestration-completion-gate-and-tooling-friction-744` @ `45506adcb0506261aaf897d0993da9532d791146`
- **Base:** `main`, merge base `b080a69ecb60b65d016362b21fffed0a34be9144`
- **Diff:** `git diff b080a69ecb60b65d016362b21fffed0a34be9144..HEAD` (92 files, +2520/-25)
- **Review date:** 2026-10-02
- **Work mode:** full-bug

## Executive Summary

The code change is small and correct. `parse_verification_evidence_markdown` in `scripts/dev_tools/pr_context/verification_evidence.py` previously assigned `Timestamp`, `Command`, and `EXIT_CODE` unconditionally (last occurrence wins) while guarding `ExpectedExitCode` (first occurrence wins), so a multi-gate artifact paired its last command with its first expectation (#708). The branch merges both conditions into one guarded assignment, `if (key in REQUIRED_FIELDS or key == EXPECTED_EXIT_CODE_FIELD) and key not in parsed:`, which matches the TypeScript parser's behaviour field for field. The TypeScript change is comment-only and removes the inaccurate "dict-first-write" parity claim (AC-14 code-review confirmation: verified; reviewer grep for `dict-first-write`, `RUNTIME-SPECIFIC`, `LAST occurrence wins`, and `EXCLUDED from the AC8` across the three files returned no match).

The documentation edits are internally consistent across the Claude, Codex, and Copilot surfaces. The CI-dependent rule appears with the same owner, timing, and push-and-re-verify semantics in the three acceptance-criteria-tracking skills, the Claude orchestrate PR Creation Gate and S9, the Codex CI Green Gate, the parallel-orchestrate merge procedure and completion requirements, and the parallel-orchestrator agent. The Codex `ci_gate`/`pr_gate` key lists match `CI_GATE_KEYS` and `PR_GATE_KEYS`, and the contract tests import those tuples rather than restating them, so a future validator key change will fail the documentation test. All 11 mirrors are byte-identical.

The one blocking issue is in evidence rather than code: 27 Phase 0-4 evidence artifacts share one `Timestamp:` value that does not match when their commands ran (policy audit PA-1). Code findings below are Minor or Informational.

Findings: 1 Blocking (evidence, cross-referenced from the policy audit), 0 Major, 1 Minor, 3 Informational.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/{baseline,regression-testing,other}/` | 27 of the 29 artifacts with `Timestamp: 2026-10-02T01-17` | CR-0 (PA-1). The Phase 0-4 artifacts all state 01-17, but file modification times run from 01:17:43 to 01:31:18 and the runs they record straddle commits dated 01:24:54 to 01:31:46 (for example, a post-fix pass-after run stamped earlier than the fix commit `c768450a` at 01:27:41). The values were not read from the clock at command run time. | Correct each affected artifact per `remediation-inputs.2026-10-02T02-02.md` and add a plan deviation entry; do not add a second `Timestamp:` row (the parser keeps the first). | The plan's Execution Conventions and this branch's R5.1 rule both require the clock reading at run time; inaccurate evidence metadata undermines audit trust and repeats the #706 FU-706-6 defect this item documents. | Policy audit PA-1; `ls -l --time-style=+%H:%M:%S` on the evidence folders; `git log` commit dates |
| Minor | `.claude/skills/acceptance-criteria-tracking/SKILL.md` (and the `.agents` and `.github` copies) | `### When Orchestrators Enforce AC Tracking` | CR-1. The new `### CI-Dependent Criteria` subsection states that S9 check-off is "the one case in which an orchestrator run checks off AC", but the later orchestrator subsection still opens with "Orchestrators do not directly check off AC items." without a cross-reference. A reader of that subsection alone sees an unqualified prohibition. | In a follow-up (or this remediation cycle if convenient), append "except CI-dependent criteria, per `### CI-Dependent Criteria`" to that sentence in all three copies and their mirrors. | Reduces the chance that an orchestrator declines the S9 check-off; the current text is not contradictory because the new subsection names itself as the exception. | `.claude/skills/acceptance-criteria-tracking/SKILL.md:91` |
| Informational | `tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py` | lines 105-106, 119, 144, 157 | CR-3. Some asserts carry no failure message (`expected_exit_code == 1`, `normalized_result == "pass"`/`"fail"`). pytest's assertion rewriting still prints both operands. | Optional: add messages for consistency with the first two asserts. | Readability only. | File lines cited |
| Informational | `tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py` | lines 17-19 | CR-2. The module imports `SHAPE_CASES` from another test module. This couples two test modules but avoids duplicating the pinned table, and no test function is re-collected by the import. | None required. A shared fixture module would be the alternative if more consumers appear. | Reuse over duplication; the plan specified this import. | File lines cited |
| Informational | `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | lines 110-114 | CR-4. The JSDoc reads "Mirrors Python `parse_verification_evidence_markdown`: parse `Key: value` rows with the first occurrence winning ... in both the Python and TypeScript parsers". The sentence is accurate; the "in both" clause repeats the "Mirrors Python" lead-in. | None required. | Wording only; R4.4 is satisfied. | `git diff` hunk `@@ -108,9 +108,10 @@` |

## Detailed Review

### Python parser (`scripts/dev_tools/pr_context/verification_evidence.py`)

- Correctness: the guarded condition keeps the first value of each of the four accepted keys and ignores later values, including empty ones. An empty first value still yields `unparseable` through the existing `if not timestamp or not command` check, which matches the TypeScript parser (`!timestamp || !command`).
- Backward compatibility: for inputs where each key appears at most once, the old and new loops assign identical values (verified by 10 parametrized single-occurrence cases and the unchanged `test_collect_pr_context_expected_exit.py`).
- Coverage: the old unconditional branch had an uncovered line (124); the merged condition is fully covered (`verification_evidence.py` 56/56 lines, 15/16 branches; the remaining partial `98->97` is in unchanged discovery code).
- Typing and style: unchanged signature; Black, Ruff, and Pyright clean.

### TypeScript (`verification-evidence.ts`, `verification-evidence.test.ts`)

- Comment-only diff (two hunks in production, one in test). No test body or expectation changed; shape-06 already expected `fail`/`1`/`0`.
- The Python shape-06 tuple now equals the TypeScript case, so the two transcribed tables agree on all eleven shapes. No automated cross-runtime comparison test exists; agreement is by textual transcription, as before this branch.

### Documentation contract tests (`test_completion_gate_documentation_contracts.py`)

- Uses section extraction plus whitespace collapse, so re-wrapping the Markdown does not break the tests, while heading renames do.
- Imports `CI_GATE_KEYS` and `PR_GATE_KEYS` from the validator modules; the `_english_list` helper renders them in document order, which ties the documentation to the validator definition.
- `test_feature_review_agent_grants_mcp_artifact_validator` pins the full `tools:` sequence, which also detects accidental removal of existing entries (R3.1).
- Mirror test reads bytes, so line-ending drift would be detected.

### Documentation surfaces

- Codex `## CI Green Gate` (A2-A4) and `## Hard Enforcement Boundary` (A1): accurate against `scripts/dev_tools/validate_orchestrator_state.py` and `scripts/dev_tools/_orchestrator_state_routing.py`.
- Claude orchestrate B1 is appended as a continuation of item 2 and states it adds no condition; B2 is placed after step 6 and states that in epic mode the check-off completes before step 6 merges, which resolves the ordering question for epic children.
- Parallel-orchestrate C1 follows the pinned "not modified by this feature" paragraph without editing it; C2 blocks `merge_status: ci_green` and `gh pr merge` on a head-SHA mismatch or pending CI-dependent criteria; C3 and D1 restate the child ownership in the completion requirements. Pinned fragment, heading, epic-literal, and frozen-digest tests pass.
- D-COMPLETED-ATTEMPTS: the adapted last sentences of A4 and B2 reference `remediation_loop.completed_attempts` and "halt after three completed attempts", which is the wording both orchestrate skills use at the merge base. Accepted.
- Feature-review agent: G1 adds the tool as the last `tools:` entry; G2 instructs per-type validation and reporting only after validation passes.

### Plan deviation D-V8-COMMENT-LINES

Accepted. The two [P14-T6] clauses assumed an instrumenting coverage provider; under `coverageProvider: "v8"` every source line, comments included, receives a `DA:` entry, so any comment edit that changes the line count changes the line ratio. The substituted evidence (equal branch and function counts, identical uncovered set shifted by +2, all changed lines hit, comment-only diff) establishes no regression. Reviewer confirmed the lcov `DA:` entries and the provider setting directly.

## Verification Performed

- `poetry run pytest` targeted run (new modules, `tests/scripts/dev_tools/pr_context/`, parallel-surface contracts, both push-down modules, collector expected-exit contract): 257 passed.
- lcov parse of both coverage artifacts; per-file and repo-wide figures match the executor's evidence.
- PR context regenerated; 38 verification-evidence rows all `pass`.
