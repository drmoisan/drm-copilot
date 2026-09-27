# Feature Audit: Codex Gates 4 and 5 Epic Scope (#707)

**Timestamp:** 2026-09-27T07-56
**Branch:** `bug/codex-gates-4-5-lack-epic-scope-707` @ `ff73b905fb832a34db63ccd4e9eda144fc58d732`
**Issue:** #707

## Scope and Baseline

- **Base:** merge-base `daae7f796ebbd87e2170df3c86a9901ce11a4b68`, confirmed equal to `git merge-base HEAD origin/main`. `origin/main` (`736a5007`) has gained 14 commits since the merge-base (issue #714 only), and none touches a file this branch changes. No rebase is required for correctness. Siblings #708, #709, #710, and #713 are not yet on `origin/main`.
- **Diff:** 72 files. Production: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (modified) and two new siblings, plus their three bundle byte copies. Registration: `core.json` and both `pester.runsettings.psd1` copies. Tests: three new suites and five suites with a mock-only change. Documentation: 55 feature-folder Markdown files.
- **Work mode and AC source:** `issue.md` declares `- Work Mode: full-bug`, so the authoritative AC source is `spec.md` `## Acceptance Criteria` only. The five checkbox items in `issue.md` `## Acceptance Criteria` are traced to spec AC-1 to AC-26 by the spec's traceability line. They are not an AC source in `full-bug` mode and were not modified by this review.
- **PR context:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were absent. The reviewer regenerated them with `--base daae7f796ebbd87e2170df3c86a9901ce11a4b68` (range `daae7f79..ff73b905`; no PR exists yet).
- **Plan:** `plan.2026-09-26T22-55.md`, 100 tasks checked, 0 unchecked. The `[P7-T29]` check-off is the one uncommitted change, as the plan's acceptance text requires.
- **Decision context:** D1 to D17 are operator-approved. Each criterion below is evaluated against the approved wording, including the D16 (AC-25) and D17 (AC-7) amendments.

## Acceptance Criteria Inventory

| AC | Topic | Issue AC trace | State in `spec.md` before review |
|---|---|---|---|
| AC-1 | Gate 4 command-leg allow in epic scope | issue AC-1 | checked |
| AC-2 | Path and apply_patch legs allow | issue AC-1 | checked |
| AC-3 | Merge-not-in-progress deny on all legs | issue AC-1 | checked |
| AC-4 | Per-conjunct deny naming | issue AC-1 | checked |
| AC-5 | `-C` selector decides scope | issue AC-1 | checked |
| AC-6 | Resolver reason codes and primitives | issue AC-1, AC-5 | checked |
| AC-7 | Readiness conjunct order and ready result (D17) | issue AC-1, AC-5 | checked |
| AC-8 | Gate 5 does not intercept the epic checkpoint | issue AC-2 | checked |
| AC-9 | Gate 5 still denies an epics feature-folder | issue AC-2 | checked |
| AC-10 | Gate 5 files unchanged | issue AC-2 | checked |
| AC-11 | Single-feature decisions unchanged | issue AC-3 | checked |
| AC-12 | Existing suites pass without assertion changes | issue AC-3 | checked |
| AC-13 | Mode suites unchanged and passing | issue AC-3 | checked |
| AC-14 | D10 mocks in five suites | issue AC-4 | checked |
| AC-15 | Hermeticity scan of new suites | issue AC-4 | checked |
| AC-16 | Linux CI Pester run | issue AC-4 | unchecked (plan RS-6) |
| AC-17 | Seam names resolve; divergences recorded | issue AC-5 | checked |
| AC-18 | 500-line cap | structural | checked |
| AC-19 | Bundle SHA-256 identity | structural | checked |
| AC-20 | Manifest registration | structural | checked |
| AC-21 | Bundle hook probe | structural | checked |
| AC-22 | Coverage registration and >= 85% | structural | checked |
| AC-23 | No `.claude` change | structural | checked |
| AC-24 | Helpers, modes, and push-down script unchanged | structural | checked |
| AC-25 | No interpreter invocation (D16) | policy | checked |
| AC-26 | Toolchain single pass | policy | checked |

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence (reviewer-verified unless noted) |
|---|---|---|
| AC-1 | PASS | Gate suite row "epic scope allows the command leg ..." (`epic-scope.Tests.ps1:113-126`) with a ready epic checkpoint, matching HEAD, merge true, and a not-ready `-CheckpointRaw`; passed in `evidence/qa-gates/final-pester-coverage.md`; failed before the gate insertion in `evidence/regression-testing/fail-before-b2-gate.md`. |
| AC-2 | PASS | Same row for the `apply_patch` (patch text with `*** Begin Patch` / `*** Update File:` in `command`) and `path` legs; no selector, so the session-root HEAD decides (D13). |
| AC-3 | PASS | Rows at `:128-145` assert `deny`, a `PREIMPLEMENTATION_GATE_BLOCKED` prefix, `epic-orchestrator-state.json`, and `'merge-in-progress'` for all three legs. |
| AC-4 | PASS | Rows at `:147-164` (missing `epic_feature_folder`, `epic_manifest_path`, `features` through the gate) and `:166-196` (all five conjuncts through a mocked resolved scope, because `route_id` and `integration_branch` are scope-defining in the resolver). Each asserts the conjunct name and the epic checkpoint. |
| AC-5 | PASS | Row `:198-211` asserts allow and that the HEAD read targets `/synthetic-worktrees/epic-integration`. Row `:213-228` asserts the exact single-feature reason when only the session-root HEAD matches. |
| AC-6 | PASS | Resolution suite `:88-111` returns each of the seven reason codes, each wrapped in `Should -Not -Throw`; unparseable and array rows included. `:128-138` absolute composed path. `:196-235` gitdir file, directory, and relative gitdir. `:237-247` detached HEAD. `:268-296` MERGE_HEAD present and absent. The suite header (`:15-17`) records `no-branch-signal` as unreachable under D3, which the criterion permits. |
| AC-7 | PASS | `:398-420` returns the seven conjuncts in order; `:387-396` ready fixture `Should -BeNullOrEmpty` (D17); `:422-432` earliest-failure precedence. The Codex predicate returns `''` for ready (`epic-scope.ps1:147`), matching `EpicScopeReadiness.psm1:173`. |
| AC-8 | PASS | Gate-5 suite `:78-114`: Write, Edit, and apply_patch Add of the epic path allowed; apply_patch Update with `-GovernedPath` emits 0 records. The checkpoint reader ignores its argument, and no row asserts the reader path. |
| AC-9 | PASS | `:118-133`: a per-feature checkpoint with `feature-folder` `docs/features/epics/sample-epic` is denied with `COMPLETION_CONSISTENCY_BLOCKED`. |
| AC-10 | PASS | Reviewer ran the AC-10 `git diff --name-only` over the four gate-5 paths: no output. |
| AC-11 | PASS | Gate suite `:230-253`: 12 rows (4 fixtures by 3 legs) assert `Should -BeExactly` the literal single-feature reason, which matches gate line 450 on HEAD (line 463 on the base). `:255-268`: 3 ready single-feature allow rows. |
| AC-12 | PASS | Reviewer `git diff -U0` over the nine pre-existing suites named by the criterion: 0 removed lines and 0 added `Should` lines. All nine report failures 0 and errors 0 in `final-pester-coverage.md` (command-exemption 119, mode-resolution 55, mode-routing 11, trigger-scoping 23, absolute-paths 35, transport 56, legacy 43, `enforce-completion-consistency-codex` 4; the remaining base `enforce-orchestration-preimplementation-gate-*` suites are included in the 5416 passed). |
| AC-13 | PASS | Reviewer `git diff --name-only` over both mode suites: no output; both passed (55 and 11). |
| AC-14 | PASS | Reviewer read of the five diffs: each adds `Mock Get-EpicScopeCheckpointText { $null }` to the only Describe's `BeforeAll`, which covers every in-process gate call in the file (single Describe per file verified). `evidence/qa-gates/p5-d10-mock-scope.md` gives an AST-based confirmation. All five suites pass. |
| AC-15 | PASS | Reviewer case-insensitive search of the three new suites for every listed token and the drive-letter regex: no match. Every epic checkpoint, HEAD, root, and MERGE_HEAD read is a named `Mock` (`p5-hermeticity-scan.md` lists the mocked names). |
| AC-16 | UNVERIFIED | Requires the pull-request CI Pester run on the Linux runner, and no PR exists yet. Local proxy: the Linux-shaped synthetic paths, the absence of drive roots and gitignored-state reads, and the full local run passing. Left unchecked, as plan RS-6 intends. Not a defect. |
| AC-17 | PASS | Gate suite `:388-409` resolves all nine D2 names plus both relocated seams as functions. `spec.md` records D1, D3, D13, D14, and D15 as numbered decisions (inspected). |
| AC-18 | PASS | Reviewer `wc -l`: 487, 189, and 493. Bundle copies are identical, hence the same counts. Gate suite rows `:411-427` and the legacy line-cap rows pass. |
| AC-19 | PASS | Reviewer SHA-256: one distinct hash per repository and bundle pair for all three files. Gate suite rows `:429-444` pass; push-down resource-contract pytest passes (17 passed). |
| AC-20 | PASS | `core.json` lists both siblings (diff read). Completeness and closure pytests pass. The dot-source lines use the exact `. (Join-Path $PSScriptRoot '<file>.ps1')` form required by D7 (gate line 25, epic-scope line 34). |
| AC-21 | PASS | `codex-bundle-hook-probe.Tests.ps1`: 3 tests, 0 failures (`final-pester-coverage.md`). |
| AC-22 | PASS | Both runsettings copies list both siblings (diff read; the copies are identical). `test_poshqc_bundled_parity.py` passes. Coverage 100.00, 100.00, and 93.20 comes from a direct self-hosted PoshQC run. The evidence is under `evidence/qa-gates/` rather than `evidence/coverage/`, which is a correct canonical-path substitution recorded as `EVIDENCE_LOCATION_OVERRIDE_REJECTED`. See code review CR-3 on the later overwrite of the on-disk artifact. |
| AC-23 | PASS | Reviewer `git diff --name-only daae7f79 HEAD -- .claude`: no output. |
| AC-24 | PASS | Reviewer ran the AC-24 path set: no output. Helpers parity suite: 2 tests, 0 failures. |
| AC-25 | PASS | Gate suite `:446-463` (`Get-PythonInvocationFinding` returns 0 findings for the three files and their bundle copies) and `:465-478` (siblings contain no `python` or `poetry` token and contain `PowerShell-authoritative`). Reviewer confirmed the header text at `epic-scope.ps1:31` and `epic-resolution.ps1:21`. |
| AC-26 | PASS | `final-poshqc-format.md` (0 formatted), `final-poshqc-analyze.md` (no findings), `final-pester-coverage.md` (0 failed), `final-pytest-guards.md` (17 passed), `final-mcp-poshqc.md` (ok flags true, hashes unchanged), all pass 1 per `final-seven-stage-loop.md`. |

## Summary

- **Verdict: PASS, with one CI-dependent criterion pending.** 25 of 26 acceptance criteria are PASS; AC-16 is UNVERIFIED because it requires the Linux CI Pester run on a PR that does not yet exist. It is not a FAIL.
- Blocking findings (FAIL, plus blocking PARTIAL, across the three review artifacts): **0**.
- Major findings: 0. Minor findings: 4 (code review CR-1 to CR-4). Informational: 5.
- The issue's expected behaviour is met. A Codex epic coordinator whose session root holds a ready epic checkpoint can stage and edit production paths on the integration branch while a merge is in progress. Every other case is denied with a reason that names the epic checkpoint and the failed conjunct, or falls through to the unchanged single-feature decision.
- No remediation inputs are produced, because no Blocking or Major finding exists. The Minor items are recommended for the follow-up list.

### Acceptance Criteria Status
- Source: `docs/features/active/codex-gates-4-5-lack-epic-scope-707/spec.md` (`## Acceptance Criteria`)
- Total AC items: 26
- Checked off (delivered): 25
- Remaining (unchecked): 1
- Items remaining: AC-16 (the new suites of AC-15 and the D10-modified suites of AC-14 pass in the repository CI Pester run on the pull request, on the Linux runner)

## Acceptance Criteria Check-off

- Newly checked off by this review: none. All 25 PASS items were already checked in `spec.md` when the review began; the reviewer confirmed each against the evidence above.
- Left unchecked: AC-16 (UNVERIFIED; CI-dependent, per plan RS-6). The owner for checking it off after the PR CI run is recorded in `evidence/other/follow-ups.md` item 1.
- `issue.md` checkboxes: not an AC source in `full-bug` mode; left unchanged.
