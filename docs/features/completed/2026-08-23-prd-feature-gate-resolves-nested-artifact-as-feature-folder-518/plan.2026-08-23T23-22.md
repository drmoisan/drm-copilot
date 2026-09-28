# 2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder (Plan)

- **Issue:** #518
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-23T23-22
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** `full-bug` — the acceptance-criteria source is `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md`. `user-story.md` is correctly absent and must remain absent.

**Fail-closed evidence rule:** Baseline artifacts, final-QC artifacts, and the coverage-comparison artifact are mandatory. If any required artifact is missing or carries a placeholder in place of a numeric coverage value, the outcome is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Every evidence-producing task names its artifact location. No evidence-backed task is checked off without the artifact on disk.

**Evidence location (non-overridable):** Every artifact this plan produces resolves under `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/evidence/` in one of the sub-trees `baseline/`, `regression-testing/`, `qa-gates/`, `issue-updates/`, or `other/`, per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No path under `artifacts/` is a valid evidence location. Each command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Artifact file names carry an execution-time ISO-8601 `yyyy-MM-ddTHH-mm` segment between the stem named in the task and the `.md` extension.

---

## Declared write set

The diff produced by this plan writes exactly these repository files, plus evidence artifacts under the feature folder's `evidence/` tree:

1. `.claude/hooks/enforce-prd-feature-before-planner.ps1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`
3. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`
4. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` — created only if the measured line-count decision in [P1-T1] requires it
5. `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md`
6. `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/plan.2026-08-23T23-22.md`

Nothing else. No file under `.claude/rules/`, no file under `.github/instructions/`, no tier map, no PoshQC runsettings file, no hook-registration file, no pack manifest. The three sibling prompt-scanning hooks and the feature-folder-order hook named in the Scope Containment section of spec.md are out of scope and must not be edited.

## Toolchain reference

PowerShell has no type-checking stage. The loop is format, then analyze, then test, restarting from format on any failure or auto-fix.

1. `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the workspace root.
2. `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the workspace root.
3. `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the workspace root. Coverage output lands at `artifacts/pester/powershell-coverage.xml` in CoverageGutters format; test results land at `artifacts/pester/pester-junit.xml`.
4. Bundle parity, executed unmodified: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`

The second Python parity test named at line 320 of spec.md, `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`, is deliberately omitted from this plan's toolchain because its `POSHQC_PARITY_PATHS` tuple covers only files under `scripts/powershell/PoshQC/` and their mirrors under `extensions/drm-copilot/resources/powershell/PoshQC/`, and no such file appears in the Declared write set above. It therefore cannot observe any change this plan makes, and running it would add a step whose result is fixed before execution begins.

Per `.claude/rules/quality-tiers.md`, PowerShell carries a line-coverage threshold of 85 percent and no branch-coverage gate.

## Named regression cases

The tasks below create these `It` names. Each name is quoted here verbatim so acceptance conditions can reference a stable test identifier rather than a wrap-fragile prose phrase.

Folder resolution by four-segment truncation:

- `resolves the same folder when the prompt cites the feature folder alone`
- `resolves the same folder when the prompt cites a research artifact path`
- `resolves the same folder when the prompt cites an evidence artifact path`
- `resolves the folder from a nested artifact path with no folder citation`
- `rejects a token that truncates to fewer than four segments`
- `yields one distinct candidate when one folder is cited at three depths`

Deterministic selection among two feature folders:

- `prefers the checkpoint folder when it occurs later in the prompt`
- `uses the earliest candidate when the checkpoint folder is absent`
- `uses the earliest candidate when the checkpoint folder is not a candidate`

Decision equivalence and the reproduction differential:

- `returns the same decision for all four prompt forms`
- `returns the same decision for folder-relative and repo-relative research paths`
- `allows full-bug with spec present and user-story absent citing a nested research artifact`

Preserved gate behavior:

- `denies full-feature when spec.md is missing`
- `denies full-bug when spec.md is missing`
- `denies full-feature when user-story.md is missing and names it`
- `allows minor-audit when neither prerequisite file is present`
- `normalizes the legacy full marker to the full-feature prerequisite set`

Indeterminate work-mode marker:

- `denies with the indeterminate-marker reason when the marker line is absent`
- `denies with the indeterminate-marker reason when issue.md is unreadable`
- `denies with the indeterminate-marker reason when the marker value is unrecognized`
- `names the resolved folder and the issue.md path in the indeterminate reason`
- `omits spec.md and user-story.md from the indeterminate reason`
- `does not invoke the file-existence probe in the indeterminate branch`

Block message:

- `names the resolved folder ahead of the prd-feature remedy phrase`
- `retains the PRD_FEATURE_BLOCKED prefix on every deny reason`

Total: 25 new `It` blocks.

The acceptance conditions below also reference the literal `Sort-Object -Property Length -Descending`, which the fix deletes from both hook copies, and the literal `could not be determined`, which the fix retains in the indeterminate-marker reason so the three existing indeterminate `It` blocks continue to pass unmodified.

## Pre-existing `It` blocks invalidated by the indeterminate-marker branch

Seven `It` blocks in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` mock `Get-PrdFeatureFileExistence` but not `Get-PrdFeatureIssueContent`, and their prompt folders do not exist on disk. They reach the indeterminate path today and pass only because the current fail-closed set is satisfied by the `$true` existence mock. Once [P2-T4] makes that path deny without probing, all seven break. [P1-T10] repairs them:

| `It` name | Lines |
| --- | --- |
| `allows when both spec.md and user-story.md exist in the target folder (prompt path)` | 48-55 |
| `blocks when spec.md is missing` | 57-70 |
| `blocks when user-story.md is missing` | 72-84 |
| `falls back to orchestrator-state.json when prompt has no folder reference` | 98-106 |
| `prefers the prompt-derived folder over the checkpoint folder` | 108-123 |
| `treats a path ending in .md as a file and uses its parent directory` | 125-142 |
| `accepts backslash separators inside the prompt path` | 144-151 |

---

### Phase 0 — Baseline Capture and Policy Compliance

- [x] [P0-T1] Read the policy files in the order fixed by CLAUDE.md and `.claude/rules/powershell.md`: the repository tone policy at .github/copilot-instructions.md, then .github/instructions/general-code-change.instructions.md, then .github/instructions/general-unit-test.instructions.md, then .github/instructions/powershell-code-change.instructions.md and .github/instructions/powershell-unit-test.instructions.md, then the mirrored rule files `.claude/rules/tonality.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, and `.claude/rules/plan-acceptance-gates.md`. Acceptance: an artifact with stem `phase0-instructions-read` exists under `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/evidence/baseline/` carrying `Timestamp:`, `Policy Order:`, and the explicit list of every file read in that order.
- [x] [P0-T2] Record the pre-change line count of `.claude/hooks/enforce-prd-feature-before-planner.ps1`, of `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`, and of `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`. Acceptance: an artifact with stem `baseline-line-counts` exists under the feature folder's `evidence/baseline/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and three numeric line counts, one per file path listed above.
- [x] [P0-T3] Run `mcp__drm-copilot__run_poshqc_format` against the unmodified tree to capture the formatting baseline. Acceptance: an artifact with stem `baseline-poshqc-format` exists under the feature folder's `evidence/baseline/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` stating whether any file was reformatted and, if so, which.
- [x] [P0-T4] Run `mcp__drm-copilot__run_poshqc_analyze` against the unmodified tree to capture the PSScriptAnalyzer baseline. Acceptance: an artifact with stem `baseline-poshqc-analyze` exists under the feature folder's `evidence/baseline/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording the numeric finding count by severity.
- [x] [P0-T5] Run `mcp__drm-copilot__run_poshqc_test` against the unmodified tree to capture the Pester baseline with coverage. Acceptance: an artifact with stem `baseline-poshqc-test` exists under the feature folder's `evidence/baseline/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording the numeric passed, failed, and skipped test counts, the numeric passed count for `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` alone read from `artifacts/pester/pester-junit.xml`, the numeric overall line-coverage percentage, and the numeric per-file line-coverage percentage for `.claude/hooks/enforce-prd-feature-before-planner.ps1` read from `artifacts/pester/powershell-coverage.xml`. Placeholder text in place of any of those numbers fails this task.
- [x] [P0-T6] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` against the unmodified tree to capture the bundle-parity baseline. Acceptance: an artifact with stem `baseline-bundle-parity` exists under the feature folder's `evidence/baseline/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording the numeric passed and failed counts.

### Phase 1 — Regression Cases That Fail Against the Unfixed Hook

- [x] [P1-T1] Decide the placement of the 25 new `It` blocks against the measured count from [P0-T2] plus the estimated size of the new cases. If the existing test file would reach or exceed 500 lines, the new cases go into the new companion file `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` and the edits to `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` are limited to the assertions invalidated by [P2-T4] and [P2-T5], enumerated in [P1-T9] and [P1-T10]. Acceptance: an artifact with stem `test-placement-decision` exists under the feature folder's `evidence/other/` tree carrying `Timestamp:` and recording the measured pre-change line count, the estimated added line count, the resulting projected total, and the chosen placement file path.
- [x] [P1-T2] [expect-fail] Add the four equivalence-set resolution cases named `resolves the same folder when the prompt cites the feature folder alone`, `resolves the same folder when the prompt cites a research artifact path`, `resolves the same folder when the prompt cites an evidence artifact path`, and `resolves the folder from a nested artifact path with no folder citation`, each calling `Find-PrdFeatureFolderFromPrompt` directly, in the file chosen by [P1-T1]. Acceptance: `mcp__drm-copilot__run_poshqc_test` reports those four `It` names as present, and at least the last three as failing.
- [x] [P1-T3] [expect-fail] Add the two boundary cases named `rejects a token that truncates to fewer than four segments` and `yields one distinct candidate when one folder is cited at three depths` in the file chosen by [P1-T1]. The first drives a degenerate token that truncates short of four segments; the second asserts that a prompt citing one folder at three depths produces exactly one distinct candidate. Acceptance: `mcp__drm-copilot__run_poshqc_test` reports both `It` names as present and failing.
- [x] [P1-T4] [expect-fail] Add the three selection cases named `prefers the checkpoint folder when it occurs later in the prompt`, `uses the earliest candidate when the checkpoint folder is absent`, and `uses the earliest candidate when the checkpoint folder is not a candidate`, mocking `Get-PrdFeatureCheckpointFolder`, in the file chosen by [P1-T1]. Acceptance: `mcp__drm-copilot__run_poshqc_test` reports all three `It` names as present and failing.
- [x] [P1-T5] [expect-fail] Add the three decision-level cases named `returns the same decision for all four prompt forms`, `returns the same decision for folder-relative and repo-relative research paths`, and `allows full-bug with spec present and user-story absent citing a nested research artifact`, each driving `Invoke-PrdFeatureBeforePlannerDecision` with an in-line `ConvertTo-Json` envelope and mocked `Get-PrdFeatureIssueContent`, `Get-PrdFeatureFileExistence`, and `Get-PrdFeatureCheckpointFolder`, in the file chosen by [P1-T1]. Acceptance: `mcp__drm-copilot__run_poshqc_test` reports all three `It` names as present and failing.
- [x] [P1-T6] [expect-fail] Add the five preserved-behavior cases named `denies full-feature when spec.md is missing`, `denies full-bug when spec.md is missing`, `denies full-feature when user-story.md is missing and names it`, `allows minor-audit when neither prerequisite file is present`, and `normalizes the legacy full marker to the full-feature prerequisite set` in the file chosen by [P1-T1]. Acceptance: `mcp__drm-copilot__run_poshqc_test` reports all five `It` names as present, and the run's `Output Summary:` records the pass or fail status of each of the five by name.
- [x] [P1-T7] [expect-fail] Add the six indeterminate-marker cases named `denies with the indeterminate-marker reason when the marker line is absent`, `denies with the indeterminate-marker reason when issue.md is unreadable`, `denies with the indeterminate-marker reason when the marker value is unrecognized`, `names the resolved folder and the issue.md path in the indeterminate reason`, `omits spec.md and user-story.md from the indeterminate reason`, and `does not invoke the file-existence probe in the indeterminate branch` in the file chosen by [P1-T1]. The last case asserts zero invocations of the `Get-PrdFeatureFileExistence` mock on that path. Acceptance: `mcp__drm-copilot__run_poshqc_test` reports all six `It` names as present and failing.
- [x] [P1-T8] [expect-fail] Add the two block-message cases named `names the resolved folder ahead of the prd-feature remedy phrase` and `retains the PRD_FEATURE_BLOCKED prefix on every deny reason` in the file chosen by [P1-T1]. Acceptance: `mcp__drm-copilot__run_poshqc_test` reports both `It` names as present, with the first failing.
- [x] [P1-T9] [expect-fail] Update the two invalidated assertions in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`: the two `Get-PrdFeatureRequiredFile` expectations for an absent mode and for an unrecognized mode string change from the spec-plus-user-story pair to a single-element set containing `spec.md`, and the marker-absent decision case drops its assertion on the user-story file name in favor of an assertion on the new indeterminate-marker reason. Acceptance: `mcp__drm-copilot__run_poshqc_test` reports those three `It` blocks as failing against the unfixed hook, and reports no other pre-existing `It` in that file as newly failing.
- [x] [P1-T10] [expect-fail] Repair the seven pre-existing `It` blocks in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` that [P2-T4] would otherwise invalidate, by adding a `Get-PrdFeatureIssueContent` mock supplying the work-mode marker each case was written to exercise so the case reaches the determined-mode path rather than the new indeterminate branch. The seven, with their line ranges, are `allows when both spec.md and user-story.md exist in the target folder (prompt path)` at lines 48-55, `blocks when spec.md is missing` at lines 57-70, `blocks when user-story.md is missing` at lines 72-84, `falls back to orchestrator-state.json when prompt has no folder reference` at lines 98-106, `prefers the prompt-derived folder over the checkpoint folder` at lines 108-123, `treats a path ending in .md as a file and uses its parent directory` at lines 125-142, and `accepts backslash separators inside the prompt path` at lines 144-151. Each receives the `full-feature` marker, which is the mode whose prerequisite set is the spec-plus-user-story pair the seven were written against; two of them require that mode specifically, since `blocks when user-story.md is missing` asserts the user-story file name in the reason and `treats a path ending in .md as a file and uses its parent directory` asserts a probe of both prerequisite paths. Every one of the seven keeps its existing `It` name and its existing assertion intent; the added mock is the only change. Acceptance: `mcp__drm-copilot__run_poshqc_test` reports all seven `It` names as present, and an artifact with stem `invalidated-test-inventory` exists under the feature folder's `evidence/other/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` listing each of the seven `It` names together with the work-mode marker added to it.
- [x] [P1-T11] [expect-fail] Run `mcp__drm-copilot__run_poshqc_test` and record the failing run as the fail-before evidence. Acceptance: an artifact with stem `fail-before-regression-run` exists under `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/evidence/regression-testing/` carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode:` set to the observed non-zero value, and an `Output Summary:` listing the exact `It` names that failed and the numeric failed count.

### Phase 2 — Minimal Fix

- [x] [P2-T1] In `.claude/hooks/enforce-prd-feature-before-planner.ps1`, rewrite the body of `Find-PrdFeatureFolderFromPrompt` to normalize each regex match to forward slashes, trim a trailing separator, split on the separator, keep the first four segments, and reject any candidate yielding fewer than four segments. The regex itself is unchanged. Acceptance: the function contains a four-segment truncation step and no length-based ordering, and the file remains under 500 lines.
- [x] [P2-T2] In `.claude/hooks/enforce-prd-feature-before-planner.ps1`, replace the `[hashtable]` deduplication with an order-preserving collection so first-occurrence order is deterministic, delete the `Sort-Object -Property Length -Descending` call, and delete the branch that treats a match ending in the Markdown extension as a file and returns its parent. Acceptance: `git grep -n -F "Sort-Object -Property Length -Descending" -- .claude/hooks/enforce-prd-feature-before-planner.ps1` exits 1.
- [x] [P2-T3] In `.claude/hooks/enforce-prd-feature-before-planner.ps1`, implement the multi-candidate selection rule: one distinct candidate is used directly; otherwise the candidate equal to the value returned by `Get-PrdFeatureCheckpointFolder` is preferred; otherwise the earliest-occurring candidate wins; a null value is returned when no candidate survives. Acceptance: the three selection `It` names listed under Deterministic selection above pass when `mcp__drm-copilot__run_poshqc_test` runs.
- [x] [P2-T4] In `.claude/hooks/enforce-prd-feature-before-planner.ps1`, add a distinct indeterminate-work-mode decision path in `Invoke-PrdFeatureBeforePlannerDecision` that denies without calling the required-file probe and whose reason names the resolved folder and the probed issue file path and states adding or correcting the work-mode marker as the remedy, mentioning neither prerequisite document. The new reason retains the literal phrase `could not be determined`, so the three existing `It` blocks at lines 372-383, 385-395, and 397-406 of `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`, each of which matches on that phrase, continue to pass unmodified. Acceptance: the six indeterminate `It` names listed above pass when `mcp__drm-copilot__run_poshqc_test` runs, and `git grep -n -F "could not be determined" -- .claude/hooks/enforce-prd-feature-before-planner.ps1` exits 0.
- [x] [P2-T5] In `.claude/hooks/enforce-prd-feature-before-planner.ps1`, change the `default` arm of `Get-PrdFeatureRequiredFile` to return a single-element set containing `spec.md`, so no reachable path returns a fail-closed set containing the user-story document, and re-lead the missing-prerequisite reason with the resolved folder ahead of the prd-feature remedy text while keeping the `PRD_FEATURE_BLOCKED:` prefix. Acceptance: the two block-message `It` names listed above and the two updated `Get-PrdFeatureRequiredFile` `It` blocks from [P1-T9] pass when `mcp__drm-copilot__run_poshqc_test` runs.
- [x] [P2-T6] In `.claude/hooks/enforce-prd-feature-before-planner.ps1`, rewrite the comment-based help so it no longer describes longest-match selection or the Markdown-parent rule, and instead states the truncation rule in the wording spec.md uses at line 392 — truncation to two segments past the `docs/features/active/` prefix, that is, to exactly four path segments — together with the checkpoint-then-earliest-occurrence selection rule, the distinct indeterminate-marker block reason, and the known version-folder limitation. Acceptance: `git grep -n -F "The longest match wins" -- .claude/hooks/enforce-prd-feature-before-planner.ps1` exits 1.
- [x] [P2-T7] Copy the finished self-hosted hook over `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` so the two files are textually identical. Acceptance: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` exits 0.
- [x] [P2-T8] Verify every changed file is under the 500-line limit: `.claude/hooks/enforce-prd-feature-before-planner.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`, and, if created, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`. Acceptance: an artifact with stem `post-change-line-counts` exists under the feature folder's `evidence/qa-gates/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` recording a numeric line count below 500 for each of those files.

### Phase 3 — Verification

- [x] [P3-T1] Run `mcp__drm-copilot__run_poshqc_test` and confirm every one of the 25 new `It` names, the three updated `It` blocks from [P1-T9], and the seven repaired `It` blocks from [P1-T10] now pass, and that the total passed count for `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` is not lower than the baseline passed count for that file recorded in [P0-T5]. Acceptance: an artifact with stem `pass-after-regression-run` exists under the feature folder's `evidence/regression-testing/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:` equal to 0, and an `Output Summary:` recording the numeric passed and failed counts, the per-file passed count for that test file alongside its baseline passed count from [P0-T5], and confirmation of zero failures among the named cases.
- [x] [P3-T2] Run `mcp__drm-copilot__run_poshqc_format`. If it reformats any file, re-run this task after the reformat and treat Phase 3 as restarted from this task. Acceptance: an artifact with stem `verify-poshqc-format` exists under the feature folder's `evidence/regression-testing/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:` equal to 0, and an `Output Summary:` stating that no file required reformatting on the recorded run.
- [x] [P3-T3] Run `mcp__drm-copilot__run_poshqc_analyze`. Acceptance: an artifact with stem `verify-poshqc-analyze` exists under the feature folder's `evidence/regression-testing/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:` equal to 0, and an `Output Summary:` recording zero PSScriptAnalyzer findings.
- [x] [P3-T4] Confirm the deleted selection rule is gone from both hook copies by running `git grep -n -F "Sort-Object -Property Length -Descending" -- .claude/hooks/enforce-prd-feature-before-planner.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`. Acceptance: an artifact with stem `verify-selection-rule-removed` exists under the feature folder's `evidence/regression-testing/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:` equal to 1, `ExpectedExitCode: 1`, and an `Output Summary:` recording zero matching lines.
- [x] [P3-T5] Confirm the declared write set is exactly what changed by running `git status --porcelain` and comparing the reported paths against the Declared write set section above. Acceptance: an artifact with stem `verify-write-set` exists under the feature folder's `evidence/regression-testing/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` listing every reported path and stating that no path outside the declared write set appears.

### Phase 4 — Final QC Loop

The four steps below run in the stated order in a single consecutive pass with no file edit between them. Any failure or auto-fix restarts the phase at [P4-T1].

- [x] [P4-T1] Run `mcp__drm-copilot__run_poshqc_format` as final-QC step 1. Acceptance: an artifact with stem `qc-poshqc-format` exists under `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/evidence/qa-gates/` carrying `Timestamp:`, `Command:`, `EXIT_CODE:` equal to 0, and an `Output Summary:` stating that no file required reformatting.
- [x] [P4-T2] Run `mcp__drm-copilot__run_poshqc_analyze` as final-QC step 2. Acceptance: an artifact with stem `qc-poshqc-analyze` exists under the feature folder's `evidence/qa-gates/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:` equal to 0, and an `Output Summary:` recording zero PSScriptAnalyzer findings.
- [x] [P4-T3] Run `mcp__drm-copilot__run_poshqc_test` as final-QC step 3, in coverage mode. Acceptance: an artifact with stem `qc-poshqc-test` exists under the feature folder's `evidence/qa-gates/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:` equal to 0, and an `Output Summary:` recording the numeric passed, failed, and skipped counts, the numeric overall line-coverage percentage, and the numeric per-file line-coverage percentage for `.claude/hooks/enforce-prd-feature-before-planner.ps1` read from `artifacts/pester/powershell-coverage.xml`. Placeholder text in place of any of those numbers fails this task.
- [x] [P4-T4] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` as final-QC step 4. Acceptance: an artifact with stem `qc-bundle-parity` exists under the feature folder's `evidence/qa-gates/` tree carrying `Timestamp:`, `Command:`, `EXIT_CODE:` equal to 0, and an `Output Summary:` recording the numeric passed and failed counts with zero failures.
- [x] [P4-T5] Compare coverage against the baseline. Acceptance: an artifact with stem `coverage-comparison` exists under the feature folder's `evidence/qa-gates/` tree recording `Timestamp:` and five numeric values — the baseline overall line coverage from [P0-T5], the post-change overall line coverage from [P4-T3], the baseline per-file line coverage for `.claude/hooks/enforce-prd-feature-before-planner.ps1`, the post-change per-file figure for the same file, and the line-coverage percentage of the lines changed by this plan — together with an explicit statement that the post-change overall figure is at or above 85 percent and that the changed-line figure shows no regression against the baseline. The artifact states that no branch-coverage threshold applies to PowerShell per `.claude/rules/quality-tiers.md`.
- [x] [P4-T6] Record the consecutive-pass attestation. Acceptance: an artifact with stem `qc-consecutive-pass` exists under the feature folder's `evidence/qa-gates/` tree carrying `Timestamp:` and the ordered list of the four [P4-T1] through [P4-T4] artifact file names, together with a statement that no repository file was edited between those four runs.

### Phase 5 — Acceptance Criteria and Follow-Up

- [x] [P5-T1] File the four follow-up issues required by the Scope Containment section of spec.md — one each for the three sibling prompt-scanning hooks and one for the two feature-folder-order hook defects — using `gh issue create`, writing no repository file other than the evidence mirror. Acceptance: an artifact with stem `follow-up-issues` exists under `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/evidence/issue-updates/` carrying `Timestamp:`, `PostedAs: body`, the four created issue URLs, and the exact body text submitted for each.
- [x] [P5-T2] Check off every acceptance criterion in the `## Acceptance Criteria` section of `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md`, citing for each the artifact path or the `It` name that evidences it. Acceptance: all 38 acceptance-criteria checkboxes in that section are marked checked, and an artifact with stem `acceptance-criteria-checkoff` exists under the feature folder's `evidence/qa-gates/` tree mapping each of the 38 criteria to its evidence. Any criterion without evidence leaves its checkbox unchecked and makes the plan outcome BLOCKED rather than PASS.
