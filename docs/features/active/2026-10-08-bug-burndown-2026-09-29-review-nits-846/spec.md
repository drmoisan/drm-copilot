# 2026-10-08-bug-burndown-2026-09-29-review-nits (Spec)

- **Issue:** #846
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-09
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-bug (this `spec.md` is the sole acceptance-criteria source; no `user-story.md` is produced)
- **Research:** `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/research/research.2026-10-08T23-50.md`
- **Closes:** #846 (the PR body must contain `Closes #846`)

## Context

The feature reviews for parallel run `bug-burndown-2026-09-29` recorded non-blocking Minor, Nit, and Info findings that were accepted at merge and not fixed. This item closes the remaining findings, grouped by originating issue (#734, #744, #647, #623, #764, #338, #609, #543, #527, #510, #723), either by a fix or by an explicit, recorded closure. None of the findings changes runtime behavior on its own; the only production behavior change is the additional git stderr text in the QT009 message of `scripts/dev_tools/check_quality_tiers.py`.

Environment:
- OS/version: Windows 11 Pro 10.0.26200 (review host); findings are platform-independent
- Python version: repository Poetry environment
- Command/flags used: code reading of the review artifacts; `wc -l` / `Get-Content | Measure-Object` line counts on main
- Data source or fixture: main at `fb413fce`; review artifacts under `docs/features/active/<item>/` (`code-review.*`, `policy-audit.*`, `feature-audit.*`); research re-verified against `origin/main` `e7d3779b`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Maintainability and documentation accuracy. Test files with zero to five lines of headroom under the 500-line limit must be split before the next edit.

## Repro & Evidence

Steps to Reproduce:
1. Open each cited review artifact at the line given below.
2. Open the cited production, test, or documentation file at the given location on main.
3. Confirm the finding still holds.

Expected:
Each accepted Minor or Nit finding is either fixed or explicitly closed, and the documentation and evidence for each item match the delivered state.

Actual (findings as recorded in `issue.md`; current-state verification in the research document):

**#734 (quality-tiers.yml)**, `docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734/code-review.2026-10-02T03-55.md`
- CR-1: `test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry` (`tests/scripts/dev_tools/test_quality_tiers_contract.py:434`) has no `-> None`.
- CR-2: `scripts/dev_tools/quality_tiers_contract.py` lines 124, 155, and 199 are uncovered.
- CR-3: `tests/scripts/dev_tools/test_quality_tiers_contract.py` is 495 lines against the 500-line limit.
- CR-4: `scripts/dev_tools/check_quality_tiers.py:90-94` captures git stderr, but the QT009 `OSError` message reports only the exit code.

**#744 (completion-gate and tooling friction)**, `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/`
- CR-1: the sentence "Orchestrators do not directly check off AC items." in every acceptance-criteria-tracking `SKILL.md` copy has no cross-reference to `### CI-Dependent Criteria`.
- PA-2: `evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md` and `evidence/other/ac-status-summary-local.2026-09-30T03-18.md` carry no `Command:` / `EXIT_CODE:` rows.
- CR-5: `evidence/regression-testing/pester-doc-contracts.2026-09-30T03-18.md:3` records `Timestamp: 2026-10-02T01-44`, later than the observed file write time 01:43:48.

**#647 (test-tree typecheck)**, `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/code-review.2026-10-02T00-54.md:38`
- CR-3: `extensions/drm-copilot/test/subagent-tree-command.test.ts` is exactly 500 lines. (The other file named by CR-3, `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts`, is delivered by item #844 and is out of scope here.)

**#623 (promotion receipt destination)**, `docs/features/active/promotion-receipt-destination-unverified-623/code-review.2026-09-30T09-09.md`
- Line 41: `test_file_system_protocol_members_declare_no_behavior` exists only to cover the `->exit` arcs of one-line Protocol placeholder methods; the review recommends a repository-wide coverage configuration.
- Line 42: plan P5-T3 (`plan.2026-09-29T19-06.md:228`) says "exactly seven tests" while HEAD has a different count, and the plan header (line 7) still reads Draft / pending preflight round 3.
- Line 43: the Python `PromotionOutcome` docstring and the post-move branch lack the exit-code-1 note and rationale comment present in `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` (line 88, lines 440-442).

**#764 (feature-review skill validator citation)**, `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/code-review.2026-09-30T10-15.md`
- Line 34: `plan.2026-09-30T05-00.md` lines 39, 40, and 66 use `git grep -nxF`; `git grep` has no `-x` option and exits 129.
- Line 35: evidence filenames carry `2026-09-30T05-20` while their `Timestamp:` fields read 09-47 to 09-58.
- Line 36: `issue.md:5` names a folder that does not exist.

**#338 (IDE launcher audit gaps)**, `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/`
- CR-1: AC-3 names `io.test.ts`, but the tests are in `io-launcher.test.ts`, and the AC-3 command does not run that file.
- A1: no whole-repository Python coverage figure was produced.
- CR-3: the issue text refers to bundled mirror copies of the two Python modules; none exist.
- Residual risk: live Windows observation of `code --reuse-window` was never performed (closed as `scope_change` under AC-5).

**#609 (bash lane assertion newline edges)**: four point-in-time evidence files still describe AC-6 and AC-14 as open, and no superseding summary exists.

**#543 (epic planner ready gate)** CR-11: `evidence/other/python-batch-budget.2026-10-02T05-01.md` lines 3-4 give a header time of `2026-10-02T05-18`, later than commit `0c6abb95` (05:14:57) that first contained the row, so the "upper bound on the write time" claim does not hold.

**#527 (PoshQC coverage denominator)**: the coverage-roots change is not recorded under `[Unreleased]` in `extensions/drm-copilot/CHANGELOG.md`.

**#510 (claude resource parity)**: `spec.md` cites stale `.gitignore` line numbers (21/67/68; actual 23/69/70), names `evidence/coverage/coveragerc-helper.ini` instead of `evidence/other/coveragerc-helper.ini`, and reads `Status: Draft` with every criterion checked.

**#723 (npm publish verify window)**: the "publish step success as primary signal" refinement was left open; N1 (runbook lacks the `npm view` command); N3 (the `(?m)^\s*exit 1\s*$` assertion matches any standalone `exit 1` in the step).

Logs / Screenshots:
- Snippet: line counts on main `fb413fce`: `test_quality_tiers_contract.py` 495; `subagent-tree-command.test.ts` 500.

## Scope & Non-Goals

- In scope:
  - #734 CR-1, CR-2, CR-3 (split), CR-4.
  - #744 CR-1 (six skill copies plus a contract test), CR-5 (in-file timestamp correction), PA-2 (summary-artifact note in each cited file).
  - #647 CR-3, second half only: the split of `extensions/drm-copilot/test/subagent-tree-command.test.ts`.
  - #623: `partial_also` coverage pattern, plan text correction, Python documentation parity.
  - #764: plan command correction, superseding filename-timestamp note, `issue.md` line 5 correction.
  - #338: AC-3 text correction, bundled-mirror text correction, A1 closure by this item's whole-repository Python coverage run, residual-risk closure record.
  - #609: new superseding AC status summary.
  - #543 CR-11: header time correction in the single cited evidence file.
  - #527: `[Unreleased]` CHANGELOG entry.
  - #510: stale `spec.md` text and Status line.
  - #723: refinement closure with rationale, new Pester test pinning default `success()` gating, tightened `exit 1` assertions (N3), runbook `npm view` command (N1).
  - A closure-dispositions evidence record for every finding.
- Out of scope / non-goals:
  - Editing `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts` in any way. The #647 CR-3 split of that file is delivered by item #844.
  - Deleting any file, test, branch, or issue. Renaming any evidence file.
  - Removing `test_file_system_protocol_members_declare_no_behavior` (the research option to remove it is not adopted).
  - Adding `Command:` / `EXIT_CODE:` rows to the #744 PA-2 summary artifacts.
  - Any change to `.github/workflows/**` (including `publish-mcp-npm.yml`).
  - Fixing the promoted-folder path generation in `scripts/dev_tools/potential_to_issue_content.py`, or creating a GitHub issue or potential entry for it. It is recorded as a follow-up in the closure-dispositions evidence only.
  - Editing any #543 folder file other than `evidence/other/python-batch-budget.2026-10-02T05-01.md`.
  - Editing the four stale #609 evidence files.
  - Editing GitHub issue bodies for #338, #764, or any other issue.
  - Performing a live Windows `code --reuse-window` observation for #338.
- Explicitly excluded systems, integrations, or datasets: `jest.config.cjs`, `tsconfig.jest.json`, `.gitignore`, pack manifests, and any coverage `omit` / `exclude` / `exclude_lines` / `exclude_also` entry.

## Root Cause Analysis

The items were accepted as non-blocking during review so the run could merge. Several of them (evidence timestamps not read from the clock, stale point-in-time evidence, plan text not updated after a deviation) recur across items and share a process cause rather than a code cause. The #764 `issue.md:5` defect has a code cause: `scripts/dev_tools/potential_to_issue_content.py` (line 209 per research) writes the `Promoted ->` path before the dated, issue-suffixed folder exists. That cause is out of scope and is recorded as a follow-up.

## Proposed Fix

### Design summary (what changes where):

- **#734.** Split `tests/scripts/dev_tools/test_quality_tiers_contract.py` into the kept file (parsing, rendering, discovery tests plus the CR-2 cases) and a new `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` (`SPEC_TIER_ASSIGNMENTS`, entry-error, classification, committed-tree tests). Move the private helpers `_codes` and `_manifest` into a new `tests/scripts/dev_tools/quality_tiers_contract_test_support.py` as public `qt_codes(errors)` and `make_manifest(*entries)`. In the classification file, rename the CR-1 test to `test_find_classification_errors_empty_projects_reports_qt007() -> None`. Add CR-2 cases: `pytest.param` entries `version-bool`, `version-string`, `missing-projects` in the existing QT003 matrix, and a new test `test_parse_quality_tiers_non_scalar_key_reports_qt002` (text such as `"? [a, b]\n: 1\nversion: 1\n"`, asserting codes `["QT002"]` and `manifest is None`). In `scripts/dev_tools/check_quality_tiers.py`, add a read-only `stderr: bytes` property to the `GitRunResult` Protocol and, on non-zero exit, raise `OSError(f"git ls-files exited with code {result.returncode}: {detail}")` where `detail = " ".join(result.stderr.decode("utf-8", errors="replace").split())`; keep the current message when `detail` is empty.
- **#744.** In all six acceptance-criteria-tracking `SKILL.md` copies, replace `Orchestrators do not directly check off AC items. Instead:` with `Orchestrators do not directly check off AC items. The one exception is a CI-dependent criterion, which the item's own orchestrator run checks off at S9 as described in `### CI-Dependent Criteria` above. For every other criterion, orchestrators instead:`. Add a parametrized pin test to `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`. Correct the CR-5 timestamp in place with a `Timestamp-Correction:` line. Add a note to each PA-2 file stating it is a summary artifact with no executed command.
- **#647.** Split `extensions/drm-copilot/test/subagent-tree-command.test.ts` into the kept file (discovery, selection, rendering, error routing tests), a new `extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts` (quick-pick ordering and labels with injected `FileTimes`), and a new `extensions/drm-copilot/test/subagent-tree-command-test-support.ts` (constants, `FakeTerminalWriter`, `FakeFileTimes`, `agentToolUseLine`, `addRootSession`). `jest.mock` blocks and `activateAndGetHandler` stay per test file.
- **#623.** Add to `[tool.coverage.report]` in `pyproject.toml`: `partial_also = ["^\\s*(async\\s+)?def\\s.*:\\s*\\.\\.\\.\\s*(#.*)?$"]`. Keep `test_file_system_protocol_members_declare_no_behavior`. Correct plan P5-T3 and the header Status line with a correction note. Add the exit-code note to the `PromotionOutcome` docstring and a rationale comment above the post-move verification branch in `scripts/dev_tools/potential_to_issue.py`.
- **#764, #338, #609, #543, #510.** Documentation and evidence text corrections or superseding notes, each retaining the original value in the corrected text where a value is replaced.
- **#527.** Add a `### Changed` entry under `## [Unreleased]` in `extensions/drm-copilot/CHANGELOG.md` (text per research section "Item #527").
- **#723.** Add one Pester `It` block pinning that the poll step's `if:` contains none of `always()`, `failure()`, `cancelled()`, that the publish step has no `continue-on-error`, and that the poll step follows the publish step. Replace each `Should -Match '(?m)^\s*exit 1\s*$'` assertion at the cited poll-step and equality-step locations with a count-equals-one assertion plus an error-block-scoped regex. Add the `npm view @danmoisan/drm-copilot-mcp@<version> version` command to the runbook section "Red verify step after a green publish step".
- **Closure record.** `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/other/closure-dispositions.<YYYY-MM-DDTHH-mm>.md` records the disposition of every finding.

### Boundaries and invariants to preserve:

- Byte equality between each source `SKILL.md` and its bundled mirror (`test_edited_surface_matches_bundled_mirror`, `test_bundled_claude_payload_contains_all_repo_runtime_contracts`).
- No production file or line is removed from the coverage denominator (Coverage Exclusion Policy, `.claude/rules/general-unit-test.md`). `partial_also` changes only how the def-line-to-exit arc of a declaration-only body is reported.
- Every QT error line printed to stderr starts with `QTnnn: ` (required by `_assert_failure_output`); git stderr is collapsed to one line.
- The Jest per-file coverage threshold for `./src/subagent-tree-command.ts` (85/75) continues to pass.
- Where a document value is corrected, the earlier value is retained in the correction text.

### Dependencies or blocked work:

- Item #844 owns `orchestration-handoff-authority-service.test.ts`. No ordering dependency exists; the two items touch disjoint files.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

See "Files the Implementation Writes" below.

#### Functions/classes/CLI commands impacted:

- `scripts/dev_tools/check_quality_tiers.py`: `GitRunResult` Protocol (new `stderr` property); the git `ls-files` failure branch that raises the QT009 `OSError`.
- `scripts/dev_tools/potential_to_issue.py`: `PromotionOutcome` docstring; comment above the post-move destination check. No executable change.
- `pyproject.toml`: `[tool.coverage.report] partial_also`.

#### Data flow and validation changes:

None beyond the QT009 message text.

#### Error handling and logging updates:

The QT009 message gains `: <collapsed git stderr>` when git stderr is non-empty. The exit code and error code are unchanged.

#### Rollback/feature-flag considerations (if applicable):

Revert the PR. No data or configuration migration.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- QT009 line format: `QT009: git ls-files exited with code <n>: <stderr collapsed to single spaces>`; unchanged form `QT009: git ls-files exited with code <n>` when stderr is empty or whitespace-only.
- Evidence files: `Timestamp:` read from the host clock, `Command:`, `EXIT_CODE:`, `Output Summary:` where a command was run.

#### Required configuration keys and defaults:

- `[tool.coverage.report] partial_also` (coverage 7.10.0 or later; the lock pins 7.13.2). The default `pragma: no branch` pattern is preserved by coverage when `partial_also` is used.

#### Backward-compatibility expectations:

`GitRunResult` gains a member; the only in-repo implementers are `subprocess.CompletedProcess` (already has `stderr`) and the test `FakeRunResult` (gains `stderr: bytes = b""`).

#### Performance constraints (latency/throughput/memory):

None.

## Files the Implementation Writes

Repository-relative, one per line. Placeholders `<YYYY-MM-DDTHH-mm>` are filled from the host clock at write time. No other repository file is written.

```
tests/scripts/dev_tools/test_quality_tiers_contract.py
tests/scripts/dev_tools/test_quality_tiers_contract_classification.py
tests/scripts/dev_tools/quality_tiers_contract_test_support.py
scripts/dev_tools/check_quality_tiers.py
tests/scripts/dev_tools/test_check_quality_tiers.py
.claude/skills/acceptance-criteria-tracking/SKILL.md
.agents/skills/acceptance-criteria-tracking/SKILL.md
.github/skills/acceptance-criteria-tracking/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md
extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md
tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py
docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/regression-testing/pester-doc-contracts.2026-09-30T03-18.md
docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md
docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/other/ac-status-summary-local.2026-09-30T03-18.md
extensions/drm-copilot/test/subagent-tree-command.test.ts
extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts
extensions/drm-copilot/test/subagent-tree-command-test-support.ts
pyproject.toml
scripts/dev_tools/potential_to_issue.py
docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md
docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md
docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md
docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/evidence/other/evidence-filename-timestamps.<YYYY-MM-DDTHH-mm>.md
docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md
docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/other/ac-status-summary.<YYYY-MM-DDTHH-mm>.md
docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md
extensions/drm-copilot/CHANGELOG.md
docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md
tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
docs/engineering/missed-npm-publish.runbook.md
docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md
docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/plan.<YYYY-MM-DDTHH-mm>.md
docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/<name>.<YYYY-MM-DDTHH-mm>.md
docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/<name>.<YYYY-MM-DDTHH-mm>.md
docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/<name>.<YYYY-MM-DDTHH-mm>.md
docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/other/closure-dispositions.<YYYY-MM-DDTHH-mm>.md
```

Differences from the research file list, by decision: `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py` is not written (the Protocol-stub test is kept); the two #744 PA-2 summary artifacts are written (note added). `artifacts/python/coverage.json` is a gitignored tool output, not a committed repository file.

Not written: `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts`, `extensions/drm-copilot/jest.config.cjs`, `extensions/drm-copilot/tsconfig.jest.json`, any `.github/workflows/**` file, `.gitignore`, `scripts/dev_tools/potential_to_issue_content.py`, the four stale #609 evidence files, any other file in the #543 folder.

## Assumptions, Constraints, Dependencies

### Assumptions

- A1. The research document's current-state findings (line numbers, counts, file contents) hold at the branch base `e7d3779b`. Where a line number has moved, the executor locates the cited text by content and records the observed line.
- A2. The #623 Protocol-stub test is kept per operator decision. With it kept, `potential_to_issue_filesystem.py` branch coverage is expected to be unchanged; the effect of `partial_also` is demonstrated on a module without an arc-covering test (`scripts.dev_tools.new_potential_bug_entry`) and on the whole-repository totals.
- A3. "Count at HEAD" for the #623 P5-T3 correction is the value printed by `grep -c -E "^def test_" tests/scripts/dev_tools/test_potential_to_issue_filesystem.py` on this branch; the research and review report eight.
- A4. The #623 plan line 230 (P5-T5, `7 passed`) is covered by the same correction note appended to line 228, which states the corrected passed-count expectation; no separate correction line is required.
- A5. The #338 A1 advisory is closed by recording this item's whole-repository Python coverage run and the PR CI `Enforce Python coverage thresholds` step result in the #846 closure-dispositions evidence; no file in the #338 folder other than `issue.md` is edited.
- A6. The #543 `### Reset 1` section (lines 32-33) receives the same correction only if `git log --format="%h %ad" -S"### Reset 1 (P2-T4)" -- <file>` shows the first commit containing it predates 05:18; otherwise it is left unchanged and the observation is recorded in the closure-dispositions evidence.
- A7. Local Pester execution may be blocked in the agent worktree (command-text guard on `pwsh`). In that case the CI `poshqc / PowerShell QC` job on the PR head is the authoritative Pester result, and `Invoke-Pester` through the PowerShell tool is attempted first.
- A8. The #723 N3 tightening and new pin test strengthen invariants that already hold; a failing run would require a workflow edit, which is out of scope. A `fail-before-exception.<YYYY-MM-DDTHH-mm>.md` dossier records this. The same applies to documentation-only and coverage-configuration items. The #734 CR-4 stderr-content test has an observed fail-before run against the unchanged `check_quality_tiers.py`.
- A9. The spec's own `Last Updated` value is a date only because this authoring session has no tool that reads the host clock.

### Constraints

- 500-line limit on every production, test, and reusable script file written.
- Line coverage >= 85% and branch coverage >= 75% (branch not applicable to Pester).
- `.claude/hooks/enforce-promotion-mcp-only.ps1`: command text containing `potential_to_issue`, `new_potential_bug_entry`, or `new_active_feature_folder` must place those tokens inside double quotes.
- `.claude/hooks/enforce-python-batch-budget.ps1`: two production Python files are changed (`scripts/dev_tools/check_quality_tiers.py`, `scripts/dev_tools/potential_to_issue.py`).
- `.claude/hooks/check-python-test-purity.ps1` and `.claude/hooks/check-powershell-test-purity.ps1`: no `tempfile`, `subprocess`, `time.sleep`, `.touch(`, `Start-Sleep` literal, `New-TemporaryFile`, or `$env:TEMP` in tests.
- Evidence is written only under `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/<kind>/` (plus the named superseding notes in the #609 and #764 folders, which are corrections of those items' records).
- Hyphen-leading `git grep` patterns use `-e`.

### External dependencies

- coverage.py >= 7.10.0 for `partial_also` (locked 7.13.2).

## Data / API / Config Impact

- User-facing or API changes: the QT009 message of `python -m scripts.dev_tools.check_quality_tiers` includes git stderr. `GitRunResult` Protocol gains `stderr`.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: `pyproject.toml` coverage reporting adds `partial_also`; CI (`.github/workflows/_quality-checks.yml`) reads the same configuration.

## Test Strategy

- Regression tests to add or update:
  - `tests/scripts/dev_tools/test_quality_tiers_contract.py`: `version-bool`, `version-string`, `missing-projects` QT003 cases; `test_parse_quality_tiers_non_scalar_key_reports_qt002`.
  - `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`: moved tests; `test_find_classification_errors_empty_projects_reports_qt007`.
  - `tests/scripts/dev_tools/test_check_quality_tiers.py`: `test_qt009_message_includes_git_stderr`, `test_qt009_message_collapses_multiline_git_stderr`; `FakeRunResult.stderr` default `b""`.
  - `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`: `test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception` (parametrized over the `.claude`, `.agents`, `.github` source copies).
  - `extensions/drm-copilot/test/subagent-tree-command.test.ts` and `subagent-tree-command.quick-pick.test.ts`: moved tests, no behavior change.
  - `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`: new `It` pinning default `success()` gating of the poll step; tightened `exit 1` assertions.
- Edge cases and negative scenarios: non-scalar YAML mapping key; `bool` and string `version`; missing `projects`; empty, single-line, and multi-line git stderr.
- Error handling and logging verification: QT009 output is a single `QT009: `-prefixed line in every stderr case.
- Coverage impact and targets: `scripts.dev_tools.quality_tiers_contract` lines 124, 155, 199 covered; `scripts.dev_tools.check_quality_tiers` new branches covered; whole-repository Python totals >= 85% line and >= 75% branch and not lower than baseline.
- Toolchain commands to run (format, lint, type-check, test):
  - Python (repository root): `poetry run black --check .`; `poetry run ruff check .`; `poetry run pyright`; targeted `poetry run pytest <files> "--cov=scripts.dev_tools.<module>" --cov-branch --cov-report=term-missing` (dotted module form only); whole repository `poetry run pytest --cov --cov-branch --cov-report=term "--cov-report=json:artifacts/python/coverage.json"` then `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`. Architecture, contract, and integration stages: not configured / not applicable for these files.
  - TypeScript (from `extensions/drm-copilot`): `npx prettier --check "src/**/*.ts" "test/**/*.ts"` (after `npm run format`); `npm run lint`; `npm run typecheck` (includes `typecheck:test`); `npm run test:unit -- subagent-tree-command`; `npm run test:coverage`. Dependency-cruiser not configured in the extension.
  - PowerShell (test file only): `Invoke-Formatter` and `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` on `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1`; `Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed` (or the CI `poshqc` job per A7).
  - Restart from formatting when any stage fails or auto-fixes a file.
- Manual validation steps: none required; all checks are commands.

## Acceptance Criteria

### #734 quality-tiers contract

- [x] AC-1: `tests/scripts/dev_tools/test_quality_tiers_contract.py` is split. The kept file holds the parsing, rendering, and discovery tests and the CR-2 cases; `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` holds the `SPEC_TIER_ASSIGNMENTS`, entry-error, classification, and committed-tree tests; `tests/scripts/dev_tools/quality_tiers_contract_test_support.py` defines `qt_codes` and `make_manifest`, and neither test file defines `_codes` or `_manifest`. Verification: `git grep -n -e "^def _codes" -e "^def _manifest" -- tests/scripts/dev_tools/` prints nothing; `git grep -n -e "^def qt_codes" -e "^def make_manifest" -- tests/scripts/dev_tools/quality_tiers_contract_test_support.py` prints both definitions.
- [x] AC-2: All 28 `def test_` functions of the pre-split `tests/scripts/dev_tools/test_quality_tiers_contract.py` (definition lines L48 through L480 per research Claim 3) are present after the split across the kept file and `test_quality_tiers_contract_classification.py`, with only the CR-1 rename changing a name. Verification: the baseline and post-change `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py --collect-only -q` outputs are recorded, and the post-change collected count equals the baseline count plus the CR-2 cases added; a name-by-name comparison of `^def test_` lines before and after is recorded in evidence.
- [x] AC-3: `test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry` is renamed to `test_find_classification_errors_empty_projects_reports_qt007` with a `-> None` annotation in `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`. Verification: `git grep -n -e "test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry" -- tests/` prints nothing; `git grep -n -e "def test_find_classification_errors_empty_projects_reports_qt007() -> None:" -- tests/` prints one line; `poetry run black --check` and `poetry run ruff check` on the file exit 0.
- [x] AC-4: CR-2 cases `version-bool`, `version-string`, `missing-projects` (QT003 matrix) and `test_parse_quality_tiers_non_scalar_key_reports_qt002` exist and pass, and `scripts/dev_tools/quality_tiers_contract.py` lines 124, 155, and 199 are covered. Verification: `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_check_quality_tiers.py --cov=scripts.dev_tools.quality_tiers_contract --cov=scripts.dev_tools.check_quality_tiers --cov-branch --cov-report=term-missing` exits 0 and the `quality_tiers_contract.py` `Missing` column lists none of 124, 155, 199 (or the moved lines holding the same statements).
- [x] AC-5: `scripts/dev_tools/check_quality_tiers.py` declares a read-only `stderr: bytes` property on `GitRunResult`, and on a non-zero `git ls-files` exit the QT009 `OSError` message is `git ls-files exited with code <n>: <detail>` when the whitespace-collapsed stderr is non-empty and `git ls-files exited with code <n>` otherwise. Verification: the tests in AC-6 and the existing non-zero-exit test pass; `poetry run pyright` exits 0.
- [x] AC-6: `tests/scripts/dev_tools/test_check_quality_tiers.py` contains `test_qt009_message_includes_git_stderr` (stderr `b"fatal: not a git repository\n"` yields exactly one stderr line, starting `QT009: ` and containing `fatal: not a git repository`) and `test_qt009_message_collapses_multiline_git_stderr` (multi-line stderr yields exactly one `QT009: ` line). Verification: an observed failing run of `test_qt009_message_includes_git_stderr` against the unchanged production file is recorded under `evidence/regression-testing/`, and the post-change run of `poetry run pytest tests/scripts/dev_tools/test_check_quality_tiers.py` exits 0.
- [x] AC-7: The quality-tiers CLI still passes on the committed tree. Verification: `poetry run python -m scripts.dev_tools.check_quality_tiers` prints one line starting `quality-tiers: OK (` and exits 0.

### #744 completion-gate and tooling friction

- [x] AC-8: All 6 acceptance-criteria-tracking `SKILL.md` copies (`.claude/skills/...`, `.agents/skills/...`, `.github/skills/...`, and the three bundled copies under `extensions/drm-copilot/resources/claude-customizations/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/`, `extensions/drm-copilot/resources/customizations/`) contain the sentence `Orchestrators do not directly check off AC items. The one exception is a CI-dependent criterion, which the item's own orchestrator run checks off at S9 as described in `### CI-Dependent Criteria` above. For every other criterion, orchestrators instead:` and no longer contain the line `Orchestrators do not directly check off AC items. Instead:`. Verification: `git grep -c -F -e "The one exception is a CI-dependent criterion" -- "**/acceptance-criteria-tracking/SKILL.md"` reports 1 for each of the six paths; `git grep -n -F -e "check off AC items. Instead:" -- "**/acceptance-criteria-tracking/SKILL.md"` prints nothing.
- [x] AC-9: Each source copy remains byte-identical to its bundled mirror and the new pin test passes. Verification: `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` exits 0, including `test_acceptance_criteria_tracking_skill_cross_references_ci_dependent_exception` (all three parameter ids), `test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule`, `test_edited_surface_matches_bundled_mirror`, and `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- [x] AC-10: `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/regression-testing/pester-doc-contracts.2026-09-30T03-18.md` line 3 reads `Timestamp: 2026-10-02T01-43` and is immediately followed by a `Timestamp-Correction:` line that retains the original value `2026-10-02T01-44`, cites the observed write time 01:43:48 and `code-review.2026-10-02T02-55.md` (CR-5), and states the correction was made under #846. Verification: `git grep -n -e "^Timestamp" -- <file>` shows both lines at lines 3 and 4.
- [x] AC-11: `evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md` and `evidence/other/ac-status-summary-local.2026-09-30T03-18.md` in the #744 folder each carry an added note stating the file is a summary artifact of other evidence with no executed command (added under #846, policy-audit PA-2); no `Command:` or `EXIT_CODE:` row is added and no existing line is removed. Verification: `git diff --numstat origin/main -- <both files>` shows zero deleted lines per file; `git grep -n -e "^Command:" -e "^EXIT_CODE:" -- <both files>` prints nothing; `git grep -n -F -e "summary artifact" -- <both files>` prints one line per file.

### #647 subagent-tree command test split

- [x] AC-12: `extensions/drm-copilot/test/subagent-tree-command.test.ts` is split into the kept file, `extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts`, and `extensions/drm-copilot/test/subagent-tree-command-test-support.ts`. The support module exports `WORKSPACE_ROOT`, `CLAUDE_PROJECTS_ROOT`, `MATCHING_DIR`, `FakeTerminalWriter`, `FakeFileTimes`, `agentToolUseLine`, and `addRootSession`; it uses `import type` for `TerminalWriter` and `FileTimes` and has no runtime import of `vscode`, `../src/command-runtime`, or `../src/terminal-writer`. Verification: `git grep -n -e "from \"vscode\"" -e "command-runtime\"" -e "terminal-writer\"" -- extensions/drm-copilot/test/subagent-tree-command-test-support.ts` prints only `import type` lines or nothing; `npm run typecheck` exits 0.
- [x] AC-13: The split preserves all 14 `it` blocks of the original suite (original lines L162 through L466 per research Claim 2): the blocks originally at L162-L367 are in the kept file and the blocks originally at L388-L466 are in `subagent-tree-command.quick-pick.test.ts`. Verification: from `extensions/drm-copilot`, the baseline `npm run test:unit -- subagent-tree-command` reports `Tests: 14 passed, 14 total` in 1 suite, and the post-change run reports `Test Suites: 2 passed, 2 total` and `Tests: 14 passed, 14 total`; per-file `it(` title lists before and after are recorded in evidence.
- [ ] AC-14: `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts` is not modified by this item. Verification: `git diff --name-only origin/main...HEAD -- extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts` prints nothing.
- [ ] AC-15: The per-file Jest coverage threshold for `./src/subagent-tree-command.ts` still passes. Verification: `npm run test:coverage` from `extensions/drm-copilot` exits 0 and prints no `coverage threshold` line naming `src/subagent-tree-command.ts`.

### #623 promotion receipt destination

- [ ] AC-16: `pyproject.toml` `[tool.coverage.report]` contains `partial_also = ["^\\s*(async\\s+)?def\\s.*:\\s*\\.\\.\\.\\s*(#.*)?$"]`, and no `omit`, `exclude_lines`, `exclude_also`, or `[tool.coverage.run]` entry is added or changed. Verification: `git diff origin/main -- pyproject.toml` shows only the `partial_also` addition; the closure-dispositions evidence states the Coverage Exclusion Policy reasoning (no file or line leaves the denominator; only the def-to-exit arc of a declaration-only body is treated as fully covered).
- [x] AC-17: The `partial_also` pattern removes one-line Protocol stub `->exit` arcs from the missing-branch report. Verification: `poetry run pytest "tests/scripts/dev_tools/test_new_potential_bug_entry.py" "--cov=scripts.dev_tools.new_potential_bug_entry" --cov-branch --cov-report=term-missing` is recorded before and after the change; the before run lists `->exit` arcs on one-line Protocol stub `def` lines in `Missing` and the after run lists none of them.
- [x] AC-18: `test_file_system_protocol_members_declare_no_behavior` remains in `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py`, the file is unchanged, and the module coverage holds. Verification: `git diff --name-only origin/main...HEAD -- "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py"` prints nothing; `poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py" "--cov=scripts.dev_tools.potential_to_issue_filesystem" --cov-branch --cov-report=term-missing` exits 0 with line >= 85% and branch >= 75%.
- [x] AC-19: `docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md` is corrected: the header Status line no longer reads Draft / pending preflight round 3 and states a completed status, `Last Updated` is updated, and P5-T3 carries an appended correction note stating the test count at HEAD (per A3), naming `test_file_system_protocol_members_declare_no_behavior` as the test added during execution, stating that #846 kept it and added the repository-wide `partial_also` setting, and stating the corrected P5-T5 passed-count expectation. The original text "exactly seven tests" is retained. Verification: `git grep -n -F -e "pending validator and executor preflight round 3" -- <plan>` prints nothing; `git grep -n -F -e "#846" -- <plan>` prints the header and P5-T3 lines.
- [x] AC-20: `scripts/dev_tools/potential_to_issue.py` `PromotionOutcome` docstring documents `exit_code` as 0 on success, the gh create exit code when issue creation fails, and 1 when the promoted file is missing after the move; a comment above the post-move destination check states why a missing destination is a non-zero outcome rather than a raised error, matching `promotion.ts` line 88 and lines 440-442. No executable line changes. Verification: `poetry run black --check`, `poetry run ruff check`, and `poetry run pyright` on `"scripts/dev_tools/potential_to_issue.py"` exit 0; `poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue_move_verification.py"` exits 0; `git diff` of the file shows only docstring and comment lines.

### #764 feature-review skill validator citation

- [x] AC-21: `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md` lines 39 and 40 use the anchored form `git grep -n -e "^- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding and route it through the standard remediation handoff\.$" -- <path>` with an appended correction note that retains the original `-nxF` form and states why it is invalid; line 66 names the anchored `git grep -n -e "^...$"` check. Verification: the corrected command against `.claude/skills/feature-review-workflow/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` exits 0 and prints one line per file; `git grep -n -e "-nxF" -- <plan>` prints no line other than the correction notes.
- [x] AC-22: A new superseding note `evidence/other/evidence-filename-timestamps.<YYYY-MM-DDTHH-mm>.md` in the #764 folder lists all 11 evidence files whose names carry `2026-09-30T05-20` (baseline-citation-grep, baseline-code-source-diff, baseline-pytest, baseline-rootfolders-diff, minor-audit-preconditions, final-citation-grep, final-pytest, final-rootfolders-diff, final-toolchain-applicability, edit-diff, targeted-parity-test; research Claim 4) with each file's name stamp and recorded `Timestamp:` value, and states that the `Timestamp:` field is the authoritative run time. No file is renamed. Verification: `git diff --name-status --diff-filter=R origin/main...HEAD` prints nothing; the note's table is compared against `git grep -n -e "^Timestamp:" -- <#764 folder>/evidence/` output recorded in the note.
- [x] AC-23: `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md` line 5 reads `- Status: Promoted -> docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/ (Issue #764)`. Verification: `git grep -n -F -e "Promoted -> docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/" -- <issue.md>` prints line 5.

### #338 IDE launcher audit gaps

- [x] AC-24: In `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md`, AC-3 names `extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts` as the location of the default-helper tests, its command includes `test/lib/new-active-feature-folder/io-launcher.test.ts`, it carries an appended correction note citing `evidence/regression-testing/ac3-jest-new-tests.2026-10-08T02-45.md`, and its checkbox stays checked. Verification: the corrected AC-3 command run from `extensions/drm-copilot` exits 0 and its output is recorded in #846 evidence.
- [x] AC-25: The same `issue.md` no longer claims bundled mirror copies of the two Python modules (the cited text at lines 38, 66, and 68 is corrected; line 66 lists `new_potential_bug_entry.py`, `new_active_feature_folder_io.py`, `new-potential-bug-entry.ts`, `io-launcher.ts`), and a note `Correction (#846): no bundled mirror copies of the two Python modules exist (code-review.2026-10-08T07-05.md CR-3).` is present under `## Actual Behavior`. Verification: `git grep -n -i -e "bundled" -- <issue.md>` prints only the correction note.

### #609, #543, #527, #510

- [x] AC-26: A new `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/other/ac-status-summary.<YYYY-MM-DDTHH-mm>.md` records `Timestamp:` (host clock), `Command:` `git grep -c -e "^- \[x\] " -- docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md`, `EXIT_CODE:`, `Output Summary:`, a `Supersedes:` list naming `evidence/other/ac-gaps.2026-09-29T18-45.md`, `evidence/other/ac-status-summary.2026-09-29T18-45.md`, `evidence/qa-gates/coverage-comparison.2026-09-29T18-45.md`, and `evidence/regression-testing/fail-before-exception.2026-09-29T18-45.md`, an `### Acceptance Criteria Status` block, and a resolution table mapping AC-6 and AC-14 to their satisfying evidence. Verification: `git diff --name-only origin/main...HEAD -- <the four superseded files>` prints nothing; the recorded command output matches the status block.
- [x] AC-27: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md` line 3 reads `Timestamp: 2026-10-02T05-14` and line 4 is a `Timestamp-Correction:` line that retains both prior values (`2026-10-02T05-01`, `2026-10-02T05-18`), cites commit `0c6abb95` and `code-review.2026-10-07T09-34.md` CR-11, and states the correction was made under #846. The `### Reset 1` section is handled per A6. Verification: `git log -1 --format="%H %ad %cd" 0c6abb95` output is recorded; `git diff --name-only origin/main...HEAD -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/` prints only this file.
- [x] AC-28: `extensions/drm-copilot/CHANGELOG.md` has a `### Changed` subsection directly under `## [Unreleased]` describing the PoshQC coverage-roots change (issue #527): roots declared in `config/poshqc-coverage.json`, the shipped settings `CodeCoverage.Path` ignored and logged, `-SettingsPath` override honored, fallback to scan folders, and the migration step. Verification: reading the file shows heading order `## [Unreleased]`, `### Changed`, `## [0.0.1] - 2026-05-02`; `git grep -n -F -e "config/poshqc-coverage.json" -- extensions/drm-copilot/CHANGELOG.md` prints at least one line.
- [x] AC-29: `docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md` cites `.gitignore` lines 23, 69, and 70 at the former lines 45 and 61, names `evidence/other/coveragerc-helper.ini` in acceptance criterion 11, has an updated `Last Updated`, and its Status line reads `Implemented` with reference to `code-review.2026-10-07T15-30.md`. Verification: `git grep -n -e "line 68" -e "line 67" -e "line 21" -e "evidence/coverage/" -e "Status:\*\* Draft" -- <spec>` prints nothing (exit 1 expected).

### #723 npm publish verify window

- [ ] AC-30: `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` contains a new `It` block asserting that the poll step's `if:` expression contains none of `always()`, `failure()`, `cancelled()`, that the "Publish to npm" step has no `continue-on-error`, and that the poll step follows the publish step. Verification: `Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed` (or the CI `poshqc` job per A7) reports zero failures and lists the new `It` as passed.
- [ ] AC-31: Each `Should -Match '(?m)^\s*exit 1\s*$'` assertion on the poll step and the tag/manifest equality step is replaced by an assertion that the step text contains exactly one standalone `exit 1` line and an assertion that `exit 1` occurs inside the step's `::error::` failure block. The generic all-pwsh-steps rule is unchanged. Verification: `git grep -n -F -e "Should -Match '(?m)^\s*exit 1\s*$'" -- tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` prints no poll-step or equality-step assertion; the Pester run in AC-30 passes.
- [x] AC-32: `docs/engineering/missed-npm-publish.runbook.md` section "Red verify step after a green publish step" contains a fenced `npm view @danmoisan/drm-copilot-mcp@<version> version` command and a sentence instructing the reader to substitute the version under investigation. Verification: `git grep -n -F -e "npm view @danmoisan/drm-copilot-mcp@" -- docs/engineering/missed-npm-publish.runbook.md` prints a line inside that section.
- [x] AC-33: No workflow file is changed. Verification: `git diff --name-only origin/main...HEAD -- .github/workflows/` prints nothing; `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py` exits 0.

### Closure, scope, and toolchain

- [ ] AC-34: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/other/closure-dispositions.<YYYY-MM-DDTHH-mm>.md` records a disposition (fixed, corrected, superseded, or closed without change) with rationale and evidence path for every finding listed under "Actual" above, including: #744 PA-2 (summary-artifact note, no command rows); #647 CR-3 first half (delivered by #844); #623 Protocol-stub approach (Coverage Exclusion Policy reasoning, test retained); #764 upstream path-generation defect in `scripts/dev_tools/potential_to_issue_content.py` (out-of-scope follow-up, no issue created); #338 A1 (closed by this item's whole-repository Python coverage evidence path and the PR CI `Enforce Python coverage thresholds` result); #338 residual live-Windows observation (remains closed as `scope_change`, citing `evidence/other/ac1-ac2-scope-change-closure.2026-10-08T02-44.md`); #723 refinement (closed: the poll step's `if:` has no status-check function, so the default `success()` applies and the "publish step succeeded" message is true by construction; pinned by the AC-30 test). Verification: review of the file against the finding list in this spec; each entry cites an existing path.
- [x] AC-35: The whole-repository Python coverage meets thresholds and does not regress. Verification: `poetry run pytest --cov --cov-branch --cov-report=term "--cov-report=json:artifacts/python/coverage.json"` exits 0, then `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75` exits 0; baseline and post-change `TOTAL` line and branch figures are recorded under `evidence/baseline/` and `evidence/qa-gates/`, and the post-change figures are not lower than baseline.
- [x] AC-36: The Python toolchain passes in a single pass. Verification: `poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`, and the targeted pytest runs in AC-4, AC-6, AC-9, AC-18, and AC-20 (each with dotted `--cov=` and `--cov-report=term-missing`, line >= 85% and branch >= 75% for every changed production module) all exit 0, recorded under `evidence/qa-gates/`.
- [ ] AC-37: The TypeScript toolchain passes in a single pass from `extensions/drm-copilot`. Verification: `npx prettier --check "src/**/*.ts" "test/**/*.ts"`, `npm run lint`, `npm run typecheck`, `npm run test:unit -- subagent-tree-command`, and `npm run test:coverage` all exit 0, recorded under `evidence/qa-gates/`.
- [ ] AC-38: The PowerShell test file passes formatting and analysis. Verification: `Invoke-Formatter` produces no change and `Invoke-ScriptAnalyzer -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` reports no findings; result recorded under `evidence/qa-gates/` (or the CI `poshqc` job per A7).
- [ ] AC-39: Every production, test, and reusable script file written by this item is at most 500 lines. Verification: a line count of each `.py`, `.ts`, and `.ps1` file in the "Files the Implementation Writes" list is recorded under `evidence/qa-gates/`, each value at most 500.
- [ ] AC-40: The change set matches the declared file list and deletes or renames nothing. Verification: `git diff --name-status origin/main...HEAD` lists only paths in "Files the Implementation Writes" (with placeholders resolved); `git diff --name-status --diff-filter=DR origin/main...HEAD` prints nothing.

## Risks & Mitigations

- Technical or operational risks:
  - R1. The `partial_also` pattern could match a non-stub one-line `def` whose `...` body is not a declaration (for example a one-line function with a real body ending in `...`). Mitigation: the pattern requires the body to be exactly `...`; the whole-repository before/after comparison (AC-35) detects any unexpected change in totals.
  - R2. The #744 sentence edit can break mirror byte-equality if one copy is missed or line endings differ. Mitigation: AC-8 enumerates all six paths; AC-9 runs the mirror equality tests.
  - R3. The non-scalar-key YAML case may raise a different error class than expected. Mitigation: AC-4 asserts only the `QT002` code and `manifest is None`; the message substring is asserted only after it is observed.
  - R4. Duplicated `jest.mock` wiring in the two subagent-tree test files can drift. Mitigation: mocks must be per file in Jest; all other helpers are shared through the support module.
  - R5. Local Pester execution may be denied in the agent worktree. Mitigation: A7 (PowerShell tool first, CI `poshqc` job as authority).
  - R6. Commands that name `potential_to_issue` or `new_potential_bug_entry` unquoted are denied by `enforce-promotion-mcp-only.ps1`. Mitigation: double-quote those paths and `--cov=` arguments.
  - R7. Correcting historical records could be read as rewriting evidence. Mitigation: every correction retains the original value and names #846; stale point-in-time files (#609, #764 filenames) are superseded rather than edited.
- Mitigations and rollbacks: revert the PR; no data migration.

## Rollout & Follow-up

- Release/rollout steps: merge the PR (`Closes #846`). The CHANGELOG entry ships with the next extension release.
- Post-fix monitoring or clean-up tasks:
  - Follow-up candidate (not filed by this item): `scripts/dev_tools/potential_to_issue_content.py` writes the `Promoted ->` path before the dated, issue-suffixed folder exists, so promoted `issue.md` files (including this item's `issue.md` line 5) name a non-existent folder.
  - The process cause shared by several findings (evidence timestamps not read from the clock, stale point-in-time evidence, plan text not updated after a deviation) is not addressed by this item.
- Links: issue #846; originating issues #734, #744, #647, #623, #764, #338, #609, #543, #527, #510, #723; sibling item #844; research `research/research.2026-10-08T23-50.md`.
