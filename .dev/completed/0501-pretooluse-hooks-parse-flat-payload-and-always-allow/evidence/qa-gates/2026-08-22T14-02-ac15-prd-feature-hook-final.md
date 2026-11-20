# QA gate — Final work-mode-aware prerequisites for enforce-prd-feature-before-planner.ps1 (AC-15) (#501)

Timestamp: 2026-08-22T14-02

## Scope

Files changed:

- `.claude/hooks/enforce-prd-feature-before-planner.ps1` (production hook)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` (byte-identical mirror)
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` (test suite)
- `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/spec.md` (AC-15 checked off)

Production file count: 2 (hook + its byte-identical mirror), within the direct-mode 2-file cap per
`powershell-change-budget-router`.

## Fix summary

Derives the prerequisite set from the persisted `- Work Mode: ...` marker in `<feature-folder>/issue.md`
instead of the pre-fix hardcoded `@('spec.md', 'user-story.md')`:

- `full-feature` -> both `spec.md` and `user-story.md` required.
- `full-bug` -> `spec.md` only.
- `minor-audit` -> neither required.
- Marker absent, unreadable, or unrecognized -> fails closed to the strictest set (`spec.md`,
  `user-story.md`), with a `PRD_FEATURE_BLOCKED` reason stating the mode could not be determined — a
  distinct reason string from the "prerequisite file missing" case, so the two conditions are
  distinguishable in the block message per AC-15(d).

New/changed functions: `Get-PrdFeatureIssueContent` (Get-Content wrapper, mockable), `Resolve-PrdFeatureWorkMode`
(marker parser, mirrors the regex convention of `scripts/dev_tools/prompt_mode_contract.py`), and
`Get-PrdFeatureRequiredFile` (mode -> required-file-list mapping, fail-closed default case).

## Run 1 — PoshQC format (targeted)

Command: `pwsh -NoProfile -File extensions/drm-copilot/resources/templates/run-poshqc-format.ps1 -WorkspaceRoot . -ScanFoldersJson '[".claude/hooks","tests/scripts/claude-hooks"]'`

EXIT_CODE: 0

Output Summary: all files reported `Already formatted`; no file modified by the format stage.

## Run 2 — PoshQC analyze (targeted)

Command: `pwsh -NoProfile -File extensions/drm-copilot/resources/templates/run-poshqc-analyze.ps1 -WorkspaceRoot . -ScanFoldersJson '[".claude/hooks","tests/scripts/claude-hooks"]'`

EXIT_CODE: 0

Output Summary: `PSScriptAnalyzer passed: no findings under .` — 0 findings. Delta against baseline: 0 -> 0 (no regression).

## Run 3 — PoshQC test (targeted)

Command: `pwsh -NoProfile -File extensions/drm-copilot/resources/templates/run-poshqc-test.ps1 -WorkspaceRoot . -ScanFoldersJson '["tests/scripts/claude-hooks"]'`

EXIT_CODE: 0

Output Summary: `Tests Passed: 1036, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`. Test-count delta against
the [baseline](../baseline/2026-08-22T13-52-ac15-prd-feature-hook-baseline.md): 1010 -> 1036, **+26 tests**
(the new AC-15 branch-coverage suite), 0 failures in both.

## Run 4 — PoshQC format/analyze/test (full repo, final gate)

Command: `pwsh -NoProfile -File extensions/drm-copilot/resources/templates/run-poshqc-format.ps1 -WorkspaceRoot .` — EXIT_CODE: 0, all files `Already formatted`.

Command: `pwsh -NoProfile -File extensions/drm-copilot/resources/templates/run-poshqc-analyze.ps1 -WorkspaceRoot .` — EXIT_CODE: 0, `PSScriptAnalyzer passed: no findings under .`. (First attempt hit a transient PSScriptAnalyzer engine `ParameterBindingException` on the unrelated, untouched `.claude/lib/hook-payload/HookPayload.psm1`; a scoped re-run against just that file reproduced the module's own documented transient-`NullReferenceException` retry path and then passed, confirming this is PSScriptAnalyzer engine flakiness unrelated to this change. The immediate full-repo retry passed cleanly.)

Command: `pwsh -NoProfile -File extensions/drm-copilot/resources/templates/run-poshqc-test.ps1 -WorkspaceRoot .` — EXIT_CODE: 0.

Output Summary: `Tests Passed: 3347, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0` across 142 files / 3356
tests discovered. The 9 skipped tests are pre-existing and unrelated to this change (none live in
`enforce-prd-feature-before-planner.Tests.ps1`). Overall coverage: `Covered 95.44% / 0%. 9,210 analyzed
Commands in 79 Files.`

## Per-file coverage, `.claude/hooks/enforce-prd-feature-before-planner.ps1`

Source: `artifacts/pester/powershell-coverage.xml`, class-level `LINE` counter for this file (identical
across the targeted run and the full-repo run, since coverage is instrumented per source file regardless
of which test files exercise it).

- `<counter type="LINE" missed="9" covered="84" />` = **90.32%** over 93 measured lines.
- Baseline (pre-fix): 86.76% (59/68 lines). **+3.56 percentage points, +25 measured lines** (new functions
  add executable lines; every new line the fix introduces is covered — the 9 missed lines are unchanged
  pre-existing gaps in `Get-PrdFeatureCheckpointFolder`'s exception path and the top-level entry-point
  guard, neither touched by this change).
- Clears the 85% uniform line-coverage threshold (`.claude/rules/quality-tiers.md`) with margin. No branch-
  coverage criterion applies (Pester does not measure branch coverage). No coverage exclusion was added.

## Mirror parity

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`

EXIT_CODE: 0

Output Summary: `1 passed, 9 deselected`. `.claude/state/*.json` was deleted before this run per the
evidence-location and batch-budget housekeeping constraints, since that test's tree walk does not exempt
`.claude/state/`. Direct `diff` between `.claude/hooks/enforce-prd-feature-before-planner.ps1` and
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`
confirmed byte-identical.

## File size

- `.claude/hooks/enforce-prd-feature-before-planner.ps1`: 349 lines.
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`: 408 lines.

Both well under the 500-line ceiling.

## QA Gate Results (delta summary)

- PSScriptAnalyzer delta: 0 -> 0 (no new findings).
- Pester failing-tests delta: 0 -> 0 (no regressions); +26 new passing tests in the targeted suite, +231
  new passing tests repo-wide (3116 baseline per the AC-1..14 [P0-T4] baseline -> 3347 here; the AC-15
  scoped delta is 1010 -> 1036).
- Per-file coverage delta for the touched hook: 86.76% -> 90.32% (improved, no regression).
- Overall coverage: 95.44% (full-repo run), comfortably above the 85% uniform threshold.
- Mirror parity: byte-identical, `1 passed` (0 regressions).

## Scope boundaries held

`git diff --name-only main...HEAD` for this AC-15 change touches only the two hook copies, the test file,
and `spec.md`. No path under `.codex/hooks/` and none of the eight SubagentStop validators named in AC-13
appear in the diff.

Output Summary: All four toolchain stages (format, analyze, test, mirror-parity) pass cleanly with zero
regressions against the pre-fix baseline; per-file line coverage on the touched hook improved from 86.76%
to 90.32%.
