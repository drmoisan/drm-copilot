# Remediation Inputs — issue 1016 (dev-docs root migration, epic 1018 child 7)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full

- **Issue:** 1016
- **Branch:** `feature/dev-docs-root-migration-phases-2-3-1016`
- **Timestamp:** 2026-11-20T18-20
- **Reviewed range:** `5f8a76ef9c2dded22bd9128d4f9337fabc6cf6c3..f744ce9e060a98dec1be9d393bba5c644e81ed61`
- **Source artifacts:**
  - `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/policy-audit.2026-11-20T18-20.md`
  - `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/code-review.2026-11-20T18-20.md`
  - `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/feature-audit.2026-11-20T18-20.md`
- **Path rationale:** F2 changes the wording of a user-story acceptance criterion (a recorded supersession), which the light path does not allow; both findings are taken in one full cycle.

## Findings (remediation required)

### F1 — Post-move records lose the in-tree rewrite scope; second run is not empty

- Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The defect and the fix both lie in branch code (`scanRewrites` in migration-plan.ts) and branch evidence; the change, its test and the re-run of the post-apply dry run need no external service, owner answer or CI result.
Finding-Scope: contained
- **Files:** `extensions/drm-copilot/src/lib/development-docs-migration/migration-plan.ts` (`scanRewrites`, lines 571 to 584); `extensions/drm-copilot/test/lib/development-docs-migration/migration-apply.test.ts` or `migration-plan.test.ts`
- **Observed:** after the apply, `mapPath(path)` returns the path unchanged for every record under `.dev/`, so each such record goes to `scan.outside`, and in apply mode to `scan.rewrites` with the full prefix rewrite, regardless of `in_tree_rewrite_scope`. The post-apply dry run (`evidence/other/post-apply-dry-run-check.2026-11-20T16-11.md`) lists 4572 files under `rewrites_outside_moved_trees` (4570 records under `.dev/` with 37610 reference occurrences, plus two discovery test files). Decision D-P4T3-1 records them as non-candidates under `links-only`, which does not match the code. A second apply with a valid decision file would rewrite the historical records that decision A3 protects.
- **Required action:**
  1. In `scanRewrites`, treat a file as in-tree when its path lies under a target prefix of the mapping table (the `.dev/<area>/` targets, `.dev/research/`, `.dev/engineering/`, `.dev/templates/`, the discovery target and `.dev/backlog.md`) as well as when `mapPath` moves it, so the chosen in-tree scope governs moved records on every run.
  2. Add a Jest case: a fixture whose moved record holds an old prefix, applied with `links-only`, then a second plan on the result asserts no moves, no renames, no rewrites and no write.
  3. Re-run the R4 post-apply dry run from a branch build with a derived decision file that also lists `tests/discovery_runtime/initialization_test_support.py` and `tests/scripts/dev_tools/test_build_discovery_runtime_io.py` in `rewrite_exclusions` (A5 Stay rows; the literal is the package resource key), and record a new `evidence/other/post-apply-dry-run-check.<UTC>.md` showing zero moves, zero renames and zero rewrite candidates outside the excluded files. Do not edit the existing evidence artifact.
  4. Keep the per-file `coverageThreshold` (85 lines, 75 branches) for `migration-plan.ts` met and the file below 700 lines.
- **Acceptance criteria affected:** spec "A second dry run after apply reports an empty plan"; spec epic "The TypeScript migration command moves ... and a second run changes nothing"; user-story (d) "A post-apply dry run reports an empty plan".

### F2 — User-story owner-presentation criterion superseded by A14 without a record

- Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Decision A14 and owner directive OD-1 already record the replacement of the owner stop; recording the supersession against the user-story criterion is a planner-authored document change on the branch that needs no further owner input.
Finding-Scope: design
- **Files:** `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/user-story.md` (scenario (c), first criterion); `spec.md` `## Autonomous Decisions` (A14)
- **Observed:** the criterion "The orchestrator presents the dry-run report and OQ-1 to OQ-13 to the owner as questions, and neither plan decides them." is unmet as written; A14 replaced the owner stop with an orchestrator decision step, and the decision file was written without asking the owner. No supersession is recorded against the criterion.
- **Required action (recommended option under OD-1):** the remediation planner records a supersession of this criterion by A14 in `user-story.md` (for example a dated note under the scenario that cites A14 and OD-1 and restates the criterion as "the orchestrator decision step writes the decision file from A2 to A13 and the stage A dry-run JSON, and neither plan decides the owner questions"), adds the matching statement to the A14 entry in `spec.md`, and the re-audit grades the restated criterion against `folder-rename-decisions.2026-11-20T12-24.json`.
- **Acceptance criteria affected:** user-story (c) first criterion.

## Pending-CI criteria (not findings)

The following criteria depend only on CI at the PR head (stage 7 integration tests) and are checked off at S9 by the item's orchestrator under `acceptance-criteria-tracking` `### CI-Dependent Criteria`. They carry no finding block, because a purely CI-dependent criterion cannot be satisfied before the pull request exists. The caller asked for an `awaiting_ci` classification; the review records them as pending-CI instead and discloses this in the policy audit.

- spec stage A: "The seven-stage toolchain passes in a single pass for the changed TypeScript, and no changed production file exceeds 800 lines."
- spec stage B: "The seven-stage toolchain passes in a single pass for TypeScript, Python and PowerShell with the key at `.dev`, recorded under `<FEATURE>/evidence/qa-gates/`, and no changed production file exceeds 800 lines."
- spec epic: "With `development_docs_root` set to `.dev`, the full toolchain passes."
- user-story (d): "The full seven-stage toolchain passes for TypeScript, Python and PowerShell with the key at `.dev`, recorded under `<FEATURE>/evidence/qa-gates/`."

## Non-blocking notes

- The self-review (`evidence/qa-gates/self-review.2026-11-20T18-14.md`) states that no `.sh` or `.bats` file changed; three did. The reviewer ran bats (14 of 14) and kcov (89.8% lines) and recorded them in `evidence/qa-gates/review-coverage-check.2026-11-20T18-28.md`.
- The root `coverage/lcov.info` was produced by the reviewer; the executor's next gate should run the root Jest coverage command so the canonical artifact exists at the new head.

## Orchestrator Supplement (appended 2026-11-20T18:37:00Z)

Remediation-Mode: design

Mode rationale: F2 changes the wording of an acceptance criterion, so the cycle is neither light nor proportionate; it runs one atomic-planner delegation, one preflight, and one execution.

### F3 — CI-only Pester failure on the reviewed head (CI run 44791702384)

- Severity: Blocking
Remediability: autonomous
Finding-Scope: contained
- **Source:** workflow_dispatch run 44791702384 of `CI` on head `f744ce9e060a98dec1be9d393bba5c644e81ed61`; failing job `poshqc / PowerShell QC shard 1` (job 136481013815, https://github.com/drmoisan/drm-copilot/actions/runs/44791702384/job/136481013815); downstream `poshqc / PowerShell QC` and `CI Required Gate` failed.
- **Observed:** `tests/scripts/dev-tools/Get-StageTimingReport.Tests.ps1` test `STR-ENTRY-PRINTS-LABELS-AND-FIXTURE-MEDIANS` throws `Stage timing evidence root not found: <checkout>\docs\features` from `Read-StageTimingEvidence` in `scripts/dev-tools/StageTiming.psm1`, called by `scripts/dev-tools/Get-StageTimingReport.ps1`. Shard 1: 5680 passed, 1 failed. The test passes locally because the worktree still holds an untracked or ignored `docs/features` directory; a clean CI checkout has none after the move to `.dev`.
- **Required action:** make the stage-timing report and its test agree with the moved layout (evidence root resolved through `Resolve-DevelopmentDocsRoot` with the key at `.dev`, or a test fixture that does not depend on a `docs/features` directory on disk), and sweep the test tree for other tests that read `docs/features` from the real checkout and would fail on a clean CI checkout; fix each one found in this cycle.
- **Acceptance criteria affected:** the four pending-CI toolchain criteria.
