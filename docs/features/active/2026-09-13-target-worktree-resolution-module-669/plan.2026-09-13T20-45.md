# 2026-09-13-target-worktree-resolution-module - Plan

- **Issue:** #669
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-13T22-00
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** `full-feature` (`issue.md:12`). Acceptance-criteria sources are `spec.md` **and** `user-story.md`.
- **Epic:** `docs/features/epics/worktree-scoped-state-resolution/epic.md` (F1, wave 0, complexity C3, no dependencies)
- **Spec:** `docs/features/active/2026-09-13-target-worktree-resolution-module-669/spec.md`
- **User story:** `docs/features/active/2026-09-13-target-worktree-resolution-module-669/user-story.md`
- **Research:** `docs/features/active/2026-09-13-target-worktree-resolution-module-669/research/2026-09-13T21-15-target-worktree-resolution-module-research.md`

## Required References

- Standing instructions: `CLAUDE.md`
- General code change policy: `.claude/rules/general-code-change.md`
- General unit test policy: `.claude/rules/general-unit-test.md`
- Module rigor tiers: `.claude/rules/quality-tiers.md`
- PowerShell standards: `.claude/rules/powershell.md`
- Tonality: `.claude/rules/tonality.md`
- Plan acceptance gates: `.claude/rules/plan-acceptance-gates.md`

**All work must comply with these policies; do not duplicate their content here.**

## Scope Boundary (non-negotiable)

This feature delivers the resolution primitive and its tests. **No consumer is rewired.** No file under
`.claude/hooks/`, `.codex/hooks/`, or `extensions/drm-copilot/src/` is created, edited, or deleted.
Rewiring is the scope of epic features F4 and F5.

### The exact file set

**Create (repo-side production PowerShell, 2 files):**

1. `.claude/lib/worktree-resolution/WorktreeResolution.psm1`
2. `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`

**Create (bundle mirror, byte-identical, 2 files):**

3. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeResolution.psm1`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`

**Edit (registration and coverage denominator, 3 files):**

5. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
6. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
7. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

**Create (Pester suites, 3 files):**

8. `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1`
9. `tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1`
10. `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`

Verified against the current tree while authoring this plan: `.claude/lib/` holds 32 `*.psm1` files in
eleven module directories and no `worktree-resolution` directory exists; the `paths` array of
`core.json` closes at `core.json:175` and its last `.claude/lib/` entry is `core.json:165`;
`CodeCoverage.Path` closes at `pester.runsettings.psd1:283` and `CoveragePercentTarget = 0` sits at
`pester.runsettings.psd1:285`.

## Decomposition Decision (settled here; do not reopen during execution)

`spec.md:230-243` places `Join-WorktreeResolutionPath` and `Get-WorktreeResolutionAmbiguityReasonCode`
in File 1, and `spec.md:479-483` authorises moving both into File 2 if File 1 approaches the 500-line
cap. The research's File 1 estimate of approximately 380 lines (`research:1050`) predates Ruling C,
which adds a third seam, the worktree enumerator, and the `commondir` indirection — roughly 105
further lines by the research's own 45-60-lines-per-function figure (`research:1025`), projecting
File 1 at approximately 486 lines against a mechanically enforced 500-line cap
(`ClaudeLibModuleConvention.Tests.ps1:123-136`).

**Settled:** `Join-WorktreeResolutionPath` is authored in File 2. `Get-WorktreeResolutionAmbiguityReasonCode`
stays in File 1, because the `$script:AmbiguityReasonCode` constant it returns is also read by File 1's
`ConvertTo-WorktreeResolutionRepoRelativePath`; relocating the accessor alone would create a second
declaration of the same literal. No third module file is created. Both files carry a planning ceiling of
**480 physical lines**, leaving 20 lines of margin against the mechanically enforced 500-line cap. The
File 1 projection and the 480 figure overlap, so `[P1-T10]` carries the single sanctioned remedy — one
comment-based-help reduction pass over the three seams — and records a final count under `500`. That
remedy does not reopen this decision: no third module file is created and
`Get-WorktreeResolutionAmbiguityReasonCode` is not relocated.

Resulting export sets:

- **File 1 (9 exports):** `Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`,
  `Get-WorktreeResolutionDirectoryChildName`, `ConvertTo-WorktreeResolutionNormalizedPath`,
  `Test-WorktreeResolutionRootMarker`, `Find-WorktreeResolutionRoot`,
  `Get-WorktreeResolutionWorktreeRoot`, `ConvertTo-WorktreeResolutionRepoRelativePath`,
  `Get-WorktreeResolutionAmbiguityReasonCode`.
- **File 2 (6 exports):** `New-WorktreeResolutionTargetResult`,
  `Find-WorktreeResolutionFeatureFolderSignal`, `Find-WorktreeResolutionBranchSignal`,
  `Find-WorktreeResolutionFilePathSignal`, `Resolve-WorktreeCallTarget`, `Join-WorktreeResolutionPath`.

## Batch-Budget Scheduling (the most likely execution failure)

`.claude/hooks/enforce-powershell-batch-budget.ps1` gates `PreToolUse` on `Write` and `Edit` for
`.ps1`, `.psm1`, and `.psd1` targets (`:273`), classifies a path matching `(^|/)tests/.*\.ps1$` or
`\.Tests\.ps1$` as test and everything else as production (`:284`), caps each list at 3 distinct paths
per session (`:316-317`), and persists state at
`.claude/state/powershell-batch-budget.<session_id>.json` (`:352` composes the directory). Repeated
edits to an already-counted path consume no further slot (`:289-291`).

This feature touches **six** production PowerShell files against a cap of three, and **exactly three**
test PowerShell files against a cap of three (zero headroom).

Two mechanics govern the schedule:

- **`Copy-Item` does not consume a slot.** The hook is a `PreToolUse` gate on `Write` and `Edit` only.
  The two bundle mirrors are therefore produced with `Copy-Item`, never with `Write` or `Edit`. This
  also guarantees the SHA-256 byte identity the manifest suite asserts. Producing a mirror with
  `Write` is a plan violation.
- **Observed counts can differ from this plan's prediction**, because the state file is keyed on
  session id and may already hold entries from earlier work in the same session. **Standing rule for
  the executor: reset the budget whenever the relevant list is at cap, not only at the reset tasks
  this plan schedules.** Each unscheduled reset is recorded in
  `evidence/other/batch-budget-reset.unscheduled-N.2026-09-13T22-00.md`, where `N` is a 1-based counter
  incremented for each unscheduled reset in this plan's execution, using the same artifact fields as
  the scheduled resets.

Scheduled windows:

| window | opened by | production paths consumed | test paths consumed |
| --- | --- | --- | --- |
| A | `[P1-T1]` reset | File 1, File 2 (2 of 3) | File 1 suite, File 2 suite (2 of 3) |
| B | `[P3-T2]` reset | `extensions/.../PoshQC/settings/pester.runsettings.psd1` (1 of 3) | manifest suite (1 of 3) |
| C | `[P4-T1]` reset | reserved for final-QC repairs (0 of 3 on entry) | reserved for final-QC repairs (0 of 3 on entry) |

`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` is edited at `[P3-T1]`, the last task of
window A, taking it to 3 of 3. `core.json` is `.json` and consumes no slot.

## Evidence Conventions (non-overridable)

All evidence resolves under
`docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/<kind>/`, where
`<kind>` is one of `baseline`, `regression-testing`, `qa-gates`, `issue-updates`, or `other`, per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Any `artifacts/baselines/`,
`artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`,
`artifacts/coverage/`, or `artifacts/regression-testing/` path is prohibited. This plan posts no GitHub
issue update, so it writes no artifact under `evidence/issue-updates/`; acceptance-criteria and
Definition-of-Done records are not issue mirrors and are written under `evidence/other/`.

The spec's Definition of Done at `spec.md:743` already directs coverage evidence to this feature's
`evidence/qa-gates/`, which is a canonical kind. No evidence-path substitution is required by this plan
and none is declared. The hook `enforce-evidence-locations.ps1:64-73` denies only `artifacts/*`
spellings, so a non-canonical `evidence/<kind>/` would not have been caught mechanically; the spec
carries no such spelling.

Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
Baseline and final-QC test artifacts additionally carry numeric coverage headline values.

The timestamp component of every artifact filename in this plan is pinned to `2026-09-13T22-00` so
acceptance conditions can name exact paths. The `Timestamp:` field **inside** each artifact records the
real clock value at run time.

## Diff Anchoring

`[P0-T2]` records the merge-base commit SHA into
`evidence/baseline/baseline-merge-base.2026-09-13T22-00.md`, derived by
`git merge-base HEAD origin/main` at that moment. Every later `git diff` in this plan is anchored to
that recorded SHA, written below as `<MERGE_BASE_SHA>`, and is paired with a
`git status --porcelain -uall` span so files this plan creates are visible. `-uall` is required in every
such span: plain `git status --porcelain` collapses a wholly untracked directory to one entry, and this
plan creates six files inside three untracked directories. `origin/main` is never used directly as a
diff operand, because it advances independently of this feature.

## Unverified Items Carried From Research

These are recorded as unverified. No acceptance condition in this plan assumes any of them is true.

1. **The MCP PoshQC coverage-path gotcha** (`research:1155`, `spec.md:160-186`). Whether
   `mcp__drm-copilot__run_poshqc_test` resolves its run settings from the installed VS Code extension
   rather than from either in-repo copy was not re-verified. `[P4-T6]` determines which behaviour
   actually occurs and records the finding. Per-file coverage for the two new modules is taken from the
   self-hosted invocation in `[P4-T7]`, which reads the self-hosted settings
   (`PoshQC.Testing.psm1:156` defaults `SettingsPath` to a module-root-derived value), so the
   determination does not gate the coverage evidence.
2. **Resolved this round, against the plan's prior assumption.** The MCP PoshQC tools return no script
   output. `repo-automation-execute-script.ts:66` returns the caller-supplied `summary`;
   `repo-automation-args.ts:42-48` composes that summary from a fixed template before the process runs;
   `command-runtime.ts:277-322` writes the child process output to the extension output channel, which
   the caller does not read. The per-file `Formatted: ` and `Already formatted: ` lines at
   `PoshQC.Analyzer.psm1:62` and `:64`, the finding table at `:182`, the clean-run line at `:185`, and
   the replayed Pester summary at `PoshQC.Testing.psm1:453-456` are all real and all discarded by the
   MCP layer. Consequently: the format stage is observed through the tree, not through output; the
   analyze finding set is obtained from a self-hosted `Invoke-PoshQCAnalyze`; the MCP test counts are
   read from the copied `pester-junit.xml`; and the self-hosted test invocation's stdout remains
   directly observable because it runs in the tool session.
3. **Byte identity of the `model-routing` bundle mirror** (`research:1150`). Not relevant to this
   feature's correctness; it is the reason this feature follows
   `DiscoveryValidation.Manifest.Tests.ps1`, which asserts SHA-256 identity
   (`DiscoveryValidation.Manifest.Tests.ps1:61-75`), rather than the thinner
   `ModelRouting.Manifest.Tests.ps1`.

## Coverage Reading Rule

`CoveragePercentTarget = 0` (`pester.runsettings.psd1:285`). A passing PoshQC run is **not** evidence
that the 85% line-coverage floor was met. Every coverage acceptance condition in this plan reads
numeric values out of `artifacts/pester/powershell-coverage.xml`, keyed on the enclosing `package`
element (the full directory path), never on a bare `sourcefile` name alone. The file-name attribute is
compared under the semantics `[P0-T8]` records, which is a bare-name comparison when `[P0-T8]` observed
a bare name and a trailing-path-segment comparison when it observed a full path. `CodeCoverage.Path` is an
explicit per-file allow-list (`pester.runsettings.psd1:23-283`), so an unregistered file sits outside
the denominator entirely rather than reporting zero.

`[P0-T8]` records the observed element structure of the baseline coverage XML before any later task
asserts over it.

## Mock-Coverage Note For Reviewers

The three seams are the module's only filesystem contact (`spec.md:486-494`). Mocking all three is
therefore correct rather than a blanket mock: every other line in both modules is a pure function of
its arguments and still executes under the mocks. The seams' own default bodies would otherwise be the
only uncovered region, so `[P1-T6]` adds three tests that call each default body directly against
existing tracked repository paths, creating nothing and reading no temporary file.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy reading and baseline capture

- [x] [P0-T1] Read the policy files in the required order and write `evidence/baseline/phase0-instructions-read.md`
  - Read, in this order: `CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/quality-tiers.md`; `.claude/rules/powershell.md`; `.claude/rules/tonality.md`; `.claude/rules/plan-acceptance-gates.md`.
  - Acceptance: `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/phase0-instructions-read.md` exists and contains a `Timestamp:` field, a `Policy Order:` field, and one bullet per file above naming its repository-relative path.

- [x] [P0-T2] Record the merge base and the pre-change worktree state
  - Run `git merge-base HEAD origin/main` and `git status --porcelain -uall`.
  - Acceptance: `evidence/baseline/baseline-merge-base.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records the 40-character merge-base SHA on its own line and the complete `git status --porcelain -uall` output (or the literal `none` when that output is empty). Every later `<MERGE_BASE_SHA>` in this plan is that recorded SHA.

- [x] [P0-T3] Record the current PowerShell batch-budget state
  - Run `Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName; Get-Content -LiteralPath $_.FullName -Raw }`. `-ErrorAction SilentlyContinue` is mandatory: `.claude/state` does not exist in this worktree, and `Get-ChildItem` raises `PathNotFound` against a missing directory. The hook creates that directory only on the first `Write` or `Edit` of a `.ps1`, `.psm1`, or `.psd1` target (`enforce-powershell-batch-budget.ps1:362-364`), which no Phase 0 task performs.
  - Acceptance: `evidence/baseline/baseline-batch-budget-state.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records either the literal `none` or, for each matching file, its path and the integer counts of its `prodFiles` and `testFiles` arrays. A missing `.claude/state` directory is the expected state before the first PowerShell write of the session and is recorded as the literal `none`.

- [x] [P0-T4] Capture the baseline PowerShell format stage and the tree it produces
  - Run `git status --porcelain -uall` and record it as the before-listing. Then run the MCP tool `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the workspace absolute path and `scan_folders` set to exactly `[".claude/lib", "tests/scripts/claude-lib", "scripts/powershell/PoshQC/settings", "extensions/drm-copilot/resources/claude-customizations/.claude/lib", "extensions/drm-copilot/resources/powershell/PoshQC/settings"]`. Then run `git status --porcelain -uall` again and record it as the after-listing. `-uall` is used in both spans so this listing is the same kind of listing `[P4-T2]` compares against.
  - This is a write-mode command whose exit code is identical on a clean run and on a repairing run, so the before/after tree listing is the observation, not the exit code. Any path present in the after-listing and absent from the before-listing is pre-existing formatting drift that this feature did not cause; restore each such path with `git restore -- <path>` and record the restored paths, so the baseline represents `HEAD`.
  - The MCP result carries no script output. `repo-automation-execute-script.ts:66` returns the caller-supplied `summary`, and `repo-automation-args.ts:46-48` composes that summary from a fixed template before the process runs, so the only text the call returns is `Ran bundled PoshQC format against '<workspace absolute path>' with 5 selected scan folder(s).` together with the boolean `ok` field. Record the returned object verbatim. Record, clearly labelled `Source-derived, not observed`, that `PoshQC.Analyzer.psm1:62` emits one `Formatted: ` line per rewritten file and `:64` one `Already formatted: ` line per unchanged file, both to the child process stdout, which the MCP layer discards. The before/after listing in the bullet above is therefore the sole observation of which files were rewritten. Do not run the formatter a second time: the restore reinstates exactly the content the run rewrote, so a second run reproduces the rewrite and leaves the tree dirty.
  - Compute the intersection of the drift set with the ten paths in this plan's Scope Boundary section. Record it under the heading `Scope-Boundary drift paths:`, or the literal `none`. Every path in that intersection is excluded from the `Pre-existing drift paths:` set that `[P4-T2]` restores, because restoring it there would revert this feature's own edit to that file; `[P4-T2]` instead accepts the rewrite for those paths and re-verifies parity. `[P0-T4]` itself restores every drift path, including those in the intersection, because at this point the feature has edited none of the ten and `HEAD` is the correct baseline for all of them. The intersection is excluded from the recorded `Pre-existing drift paths:` set only, not from the restore, so that `[P4-T2]` does not restore it and `[P4-T11]` does not remove it from the reduced union. The restored set and the recorded set are therefore different sets: the restore covers every drift path, and the record covers every drift path except the intersection.
  - Acceptance: `evidence/baseline/baseline-poshqc-format.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and contains the before-listing, the after-listing, the verbatim MCP result object including its `ok` field, a `Pre-existing drift paths:` line naming each restored path that is not in the `Scope-Boundary drift paths:` intersection, one per line, or the literal `none`, a `Scope-Boundary drift paths:` line naming the intersection or the literal `none`, and the labelled source-derived note on the two line kinds. The recorded result text contains the literal `Ran bundled PoshQC format against `. After the restore, the after-listing must equal the before-listing. The `Pre-existing drift paths:` set is the only set later tasks may exclude; a path not named there and not named under `Scope-Boundary drift paths:` is a change this feature caused.

- [x] [P0-T5] Capture the baseline PowerShell analyze stage and its baseline finding set
  - Run the MCP tool `mcp__drm-copilot__run_poshqc_analyze` with the same `workspace_root` and the same five `scan_folders` values as `[P0-T4]`. This call is the policy gate. It returns a fixed template summary and an `ok` field and no analyzer output, for the reason recorded in `[P0-T4]`.
  - Then, to obtain the finding set itself, run `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; try { Invoke-PoshQCAnalyze -Root (Get-Location).Path -ScanFolders @('.claude/lib','tests/scripts/claude-lib','scripts/powershell/PoshQC/settings','extensions/drm-copilot/resources/claude-customizations/.claude/lib','extensions/drm-copilot/resources/powershell/PoshQC/settings') } catch { $_ | Out-String }`. `Invoke-PoshQCAnalyze` reads no files and writes none, so running it in addition to the gate changes nothing. `PoshQC.Analyzer.psm1:182-183` prints the finding table and then throws `PSScriptAnalyzer reported N issue(s).`, which the `catch` captures; `:185` prints `PSScriptAnalyzer passed: no findings under ` on a clean run. The settings file this invocation reads is byte-identical to the bundled one, because `pssa.settings.psd1` is in `POSHQC_PARITY_PATHS` at `test_poshqc_bundled_parity.py:17`.
  - Acceptance: `evidence/baseline/baseline-poshqc-analyze.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; it records the MCP result object verbatim including its `ok` field, and, when that `ok` field is `true`, that text contains the literal `Ran bundled PoshQC analyze against `; and, under a heading `Baseline finding set`, it records the verbatim stdout of the self-hosted invocation together with every analyzer finding that run reported, one per line, or the literal `none`. When the self-hosted stdout contains the literal `PSScriptAnalyzer passed: no findings under `, the recorded `Baseline finding set` is `none` and the MCP `ok` field must be `true`. When the MCP `ok` field is `false`, the fixed template summary is not produced at all — `mcp-tools.ts:139` substitutes the error message and `mcp-tools.ts:140` adds `stderr_excerpt` — so the artifact records that returned object verbatim instead, and the `Baseline finding set` must be non-empty. `[P4-T3]` compares against the recorded `Baseline finding set`.

- [x] [P0-T6] Capture the baseline MCP test stage with repository-wide numeric coverage
  - Run the MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the workspace absolute path and `scan_folders` omitted, so the scan set resolves from `config/poshqc-scan.json` (`scripts`, `tests/powershell`, `tests/scripts`).
  - Then copy the produced coverage file: `Copy-Item -LiteralPath 'artifacts/pester/powershell-coverage.xml' -Destination 'docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/baseline-powershell-coverage.mcp.2026-09-13T22-00.xml' -Force`. The copy is mandatory and must precede any later run, because every run overwrites the same output path (`pester.runsettings.psd1:22`). Copy the produced test-result file in the same step: `Copy-Item -LiteralPath 'artifacts/pester/pester-junit.xml' -Destination 'docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/baseline-pester-junit.2026-09-13T22-00.xml' -Force`. This copy is mandatory and must precede any later run for the same reason as the coverage copy: every run overwrites the same output path.
  - The MCP call returns no Pester summary line, for the reason recorded in `[P0-T4]`, so the counts are read from the copied JUnit file, which is the same source the `Baseline failure set` below is already composed from.
  - Acceptance: `evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the `Output Summary:` field records the MCP result object verbatim including its `ok` field, that text containing the literal `Ran bundled PoshQC test against ` when the `ok` field is `true` and, when the `ok` field is `false`, the error message `mcp-tools.ts:139` substitutes together with the `stderr_excerpt` `mcp-tools.ts:140` adds; the total, failure, error, and skipped counts read from `evidence/other/baseline-pester-junit.2026-09-13T22-00.xml` using the element and attribute names that file actually carries, recorded as observed; and the repository-wide baseline **line** coverage as three numbers — covered lines, missed lines, and the percentage rounded to two decimals; and `evidence/other/baseline-powershell-coverage.mcp.2026-09-13T22-00.xml` exists. `evidence/other/baseline-pester-junit.2026-09-13T22-00.xml` exists. The artifact additionally records, under a heading `Baseline failure set`, the element and attribute names observed in that file that identify a failing test, quoting one complete failing element verbatim, and one line per failing test composed from those observed names, or the literal `none` when the file records no failure. The names are recorded from the file as observed rather than assumed, for the same reason `[P0-T8]` records the coverage structure before any task asserts over it. `[P4-T5]` compares its own failure set against this one.

- [x] [P0-T7] Capture the baseline self-hosted PoshQC test invocation with numeric coverage
  - Run `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib')`. `Invoke-PoshQCTest` is defined at `PoshQC.Testing.psm1:151` and defaults `SettingsPath` to the module-root-derived `$script:PesterSettings` (`:156`), so it reads the self-hosted run settings.
  - Note for the executor: `Run.Exit = $true` (`pester.runsettings.psd1:4`). Pester terminates the host process only when the run has failures. If the tool session terminates during this task, that termination is itself the observation that the run had failures; re-open a session, record the termination in the artifact, and re-run.
  - Then copy the coverage file to `evidence/other/baseline-powershell-coverage.selfhosted.2026-09-13T22-00.xml` with `Copy-Item -Force`.
  - Acceptance: `evidence/baseline/baseline-poshqc-selfhosted-test.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the `Output Summary:` field records the verbatim replayed summary lines, including the numeric failed count read from the `Tests Passed: {0}, Failed: {1}, Skipped: {2}, Inconclusive: {3}, NotRun: {4}` line that `PoshQC.Testing.psm1:423-428` composes and `:456` replays, the covered/missed/percentage line-coverage triple for this scoped run, and the explicit statement that the two new module paths produce **zero** rows at baseline because they do not yet exist; and `evidence/other/baseline-powershell-coverage.selfhosted.2026-09-13T22-00.xml` exists.

- [x] [P0-T8] Record the observed element structure of the baseline coverage XML
  - Read `evidence/other/baseline-powershell-coverage.selfhosted.2026-09-13T22-00.xml` and record: the name of the root element; the element path from the root down to a per-directory grouping element and a per-file element; the attribute that carries the directory path; the attribute that carries the file name; and the exact element and attribute names that carry the line counters, quoting one complete counter element verbatim. A source-derived cross-check exists at `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1:296-303`, whose fixtures show a `report` element named `Pester`, a `package` element carrying the directory path in `name`, and a `sourcefile` element carrying the bare file name in `name`. Record that cross-check, labelled `Source-derived, not observed`, alongside the observed structure, and state which governs where they differ.
  - Acceptance: `evidence/qa-gates/coverage-xml-structure.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records all six items above with one verbatim counter element, plus the labelled source-derived cross-check and the statement of which governs. Every later per-file coverage extraction in this plan uses the element and attribute names recorded here.

- [x] [P0-T9] Consolidate the recorded PoshQC baseline stage records
  - Copy, verbatim, into one artifact under a heading naming its stage: from `[P0-T4]`, the recorded MCP result object and the labelled source-derived note on the two format line kinds; from `[P0-T5]`, the recorded MCP result object and the `Baseline finding set`, including the self-hosted stdout it was composed from; from `[P0-T6]`, the recorded MCP result object and the counts read from the JUnit file; and from `[P0-T7]`, the verbatim replayed summary lines of the self-hosted test invocation.
  - Record alongside them, clearly labelled `Source-derived, not observed`, the summary-line composition at `PoshQC.Testing.psm1:422-428` and the replay statements at `PoshQC.Testing.psm1:454-456`, and state that the observed blocks are authoritative where the two differ.
  - Acceptance: `evidence/qa-gates/poshqc-observed-success-output.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and carries four stage headings, each followed by a non-empty block; the format, analyze, and MCP-test headings each carry the verbatim MCP result object for that stage, and the self-hosted test heading carries the verbatim replayed summary lines; plus the labelled source-derived section.

- [x] [P0-T10] Capture the baseline result of the PoshQC bundled-parity Python test
  - Run `poetry run python -m pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`. This test requires `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror under `extensions/drm-copilot/resources/powershell/PoshQC/` to be text-identical (`test_poshqc_bundled_parity.py:9-18`, path rewrite at `:56-59`), and this feature edits both copies.
  - Acceptance: `evidence/baseline/baseline-poshqc-parity-pytest.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and the `Output Summary:` field records the passed and failed counts printed by the run.

- [x] [P0-T11] Record the baseline acceptance-criteria checkbox counts in both AC source files
  - For `spec.md`, slice the lines strictly between the line `## Acceptance Criteria` and the line `## Definition of Done`. For `user-story.md`, slice strictly between `## Acceptance Criteria` and `## Non-Goals`. In each slice count lines satisfying `$_.StartsWith('- [ ] ')` and lines satisfying `$_.StartsWith('- [x] ')`.
  - Acceptance: `evidence/baseline/baseline-acceptance-criteria-counts.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records for each of the two files a total of **51** checkbox lines in the sliced section and a checked count of **0**.

### Phase 1 — WorktreeResolution.psm1 and its Pester suite

- [ ] [P1-T1] Reset the PowerShell batch budget to open window A
  - Run `Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' -File -ErrorAction SilentlyContinue | Remove-Item -Force`, then `@(Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' -File -ErrorAction SilentlyContinue).Count`. `-ErrorAction SilentlyContinue` is required in both spans because `.claude/state` may not exist.
  - Acceptance: `evidence/other/batch-budget-reset.window-a.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and the recorded post-reset count is `0`. A missing `.claude/state` directory is the expected state before the first PowerShell write of the session and is recorded as a post-reset count of 0.

- [ ] [P1-T2] Create `.claude/lib/worktree-resolution/WorktreeResolution.psm1` with its convention header, constants, and the three filesystem seams
  - The leading comment-based-help block must contain the exact sentence token `imports its siblings with -ErrorAction Stop` on a line **before** the strict-mode line, and a `.NOTES` sentence stating the file is mirrored byte-identically under `extensions/drm-copilot/resources/claude-customizations/`. `Set-StrictMode -Version Latest` must be immediately followed on the very next line by `$ErrorActionPreference = 'Stop'`. These are asserted by `ClaudeLibModuleConvention.Tests.ps1:53-67` and `:88-107`.
  - Declare the script-scoped constants: the `.git-entry` name, the `gitdir:` line prefix, the `commondir` file name, the maximum ascent depth, and `$script:AmbiguityReasonCode` holding the literal `TARGET_WORKTREE_AMBIGUOUS`. Each constant carries a prose comment explaining why the set is narrow, following `CleanupWorktreeManifest.psm1:42-59`.
  - Author the three seams. `Get-WorktreeResolutionGitEntryKind -Path` returns `Directory`, `File`, or `None` using `Test-Path -LiteralPath -PathType Container` then `-PathType Leaf`. `Get-WorktreeResolutionGitFileText -Path` returns the raw text or `$null` using `Get-Content -LiteralPath -Raw`. `Get-WorktreeResolutionDirectoryChildName -Path` returns a `string[]` (always an array, possibly empty) using `Get-ChildItem -LiteralPath -Directory -Name`. Each seam carries `[CmdletBinding()]`, `[OutputType(...)]`, and a `.SYNOPSIS` naming it as the module's only probe, only content read, or only directory enumeration respectively.
  - Acceptance: the file exists; `Select-String -LiteralPath '.claude/lib/worktree-resolution/WorktreeResolution.psm1' -SimpleMatch -Pattern 'imports its siblings with -ErrorAction Stop'` returns exactly one match; and `Select-String -LiteralPath '.claude/lib/worktree-resolution/WorktreeResolution.psm1' -SimpleMatch -Pattern 'function Get-WorktreeResolutionDirectoryChildName'` returns exactly one match. The literals `imports its siblings with -ErrorAction Stop` and `function Get-WorktreeResolutionDirectoryChildName` are the exact strings this task writes into that file.

- [ ] [P1-T3] Add the pure path helpers and the upward worktree locator to `WorktreeResolution.psm1`
  - `ConvertTo-WorktreeResolutionNormalizedPath -Path` converts every backslash to a forward slash, collapses repeated separators, removes a trailing slash, removes a leading `./`, and returns `$null` for a null or whitespace input.
  - `Test-WorktreeResolutionRootMarker -Path` returns `$true` when the level's `.git` child is a directory, or is a file whose first line matches `^gitdir:\s*(.+)$`; `$false` otherwise. It reaches the filesystem only through the two read seams.
  - `Find-WorktreeResolutionRoot -Path [-MaximumDepth]` ascends from the normalised input, returning the first level satisfying `Test-WorktreeResolutionRootMarker`, and returning `$null` when the ascent reaches the drive or filesystem root or exhausts `MaximumDepth`.
  - Acceptance: `Select-String -LiteralPath '.claude/lib/worktree-resolution/WorktreeResolution.psm1' -SimpleMatch -Pattern 'function Find-WorktreeResolutionRoot'` returns exactly one match, and the same search for `function Test-WorktreeResolutionRootMarker` and for `function ConvertTo-WorktreeResolutionNormalizedPath` each returns exactly one match. All three function-declaration literals are written into the file by this task.

- [ ] [P1-T4] Add the worktree enumerator `Get-WorktreeResolutionWorktreeRoot` to `WorktreeResolution.psm1`
  - Given `-SessionRoot`, return a `string[]` (always an array) of candidate worktree roots, derived with no `git-subprocess` call: when the session root's `.git` child is a **directory**, the session root is the main checkout; when it is a **file**, read its `gitdir:` line to reach `<main>/.git/worktrees/<name>/`, then read that directory's `commondir` file to reach the main `.git` directory. Enumerate `<main>/.git/worktrees/*/gitdir`, read each file as the path to that worktree's own `.git` file, and take that file's parent directory as the worktree root. **Include the main checkout itself** in the returned set, not only the linked worktrees. Deduplicate on the normalised form.
  - A worktree root may be a sibling of the main checkout rather than a descendant (`spec.md:424-437`). Containment must never be tested by string-prefix comparison against a single known root; compare normalised forms segment by segment.
  - Acceptance: `Select-String -LiteralPath '.claude/lib/worktree-resolution/WorktreeResolution.psm1' -SimpleMatch -Pattern 'function Get-WorktreeResolutionWorktreeRoot'` returns exactly one match, and `Select-String -LiteralPath '.claude/lib/worktree-resolution/WorktreeResolution.psm1' -SimpleMatch -Pattern 'commondir'` returns at least two matches (the constant declaration and its use). Both literals are written into the file by this task and by `[P1-T2]`.

- [ ] [P1-T5] Add `ConvertTo-WorktreeResolutionRepoRelativePath`, `Get-WorktreeResolutionAmbiguityReasonCode`, and `Export-ModuleMember` to `WorktreeResolution.psm1`
  - `ConvertTo-WorktreeResolutionRepoRelativePath -Path [-WorktreeRoot]` always returns a `[pscustomobject]`, never `$null`, carrying `IsNormalized`, `RepoRelativePath`, `WorktreeRoot`, `ReasonCode`, and `Detail`. Behaviour by input form follows `spec.md:324-331` exactly: an absolute path inside a locatable worktree normalises to the **full** remainder with no segment discarded; an absolute path whose ascent finds no `.git` entry is unnormalised; a relative path with a supplied `-WorktreeRoot` normalises against it; and a relative path with no `-WorktreeRoot` is **Ruling A** — `IsNormalized = $false`, `RepoRelativePath = $null`, `WorktreeRoot = $null`, `ReasonCode` set to the ambiguity literal. `ReasonCode` is the ambiguity literal exactly when `IsNormalized` is `$false`, and `$null` otherwise. `Detail` is always populated. No fixed segment-count truncation appears anywhere.
  - `Get-WorktreeResolutionAmbiguityReasonCode` takes no parameters and returns `$script:AmbiguityReasonCode`.
  - `Export-ModuleMember -Function` lists exactly the nine File 1 exports named in the Decomposition Decision above, one name per backtick-continued line.
  - Acceptance: `Select-String -LiteralPath '.claude/lib/worktree-resolution/WorktreeResolution.psm1' -SimpleMatch -Pattern 'TARGET_WORKTREE_AMBIGUOUS'` returns at least one match, and `Select-String -LiteralPath '.claude/lib/worktree-resolution/WorktreeResolution.psm1' -SimpleMatch -Pattern 'Export-ModuleMember'` returns exactly one match. The literal `TARGET_WORKTREE_AMBIGUOUS` is written into the file by `[P1-T2]` and read here; it occurs zero times elsewhere in the tree today (`research:1154`).

- [ ] [P1-T6] Create `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1` with the seam tests
  - Open with `#Requires -Version 7.0` and `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`, then a comment-based-help block whose `.DESCRIPTION` states the determinism posture explicitly: no test creates, writes, or reads a temporary file, reads a wall clock, spawns a process, or touches the network.
  - `BeforeAll` imports the module with `Import-Module (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution/WorktreeResolution.psm1").Path -Force`. `Resolve-Path` is required so Pester coverage breakpoints bind to the path the run settings name (`CleanupWorktreeManifest.Tests.ps1:22-26`).
  - Register default seam mocks in a nested `BeforeAll` with `Mock -CommandName <seam> -ModuleName 'WorktreeResolution' -MockWith { ... }`, with mock bodies carrying inline literals rather than test-scope variables (`CleanupWorktreeManifest.Tests.ps1:31-39`).
  - Add three tests that exercise each seam's **default body** with the mocks not in force, using existing tracked repository paths resolved from `$PSScriptRoot`: `Get-WorktreeResolutionGitEntryKind` returns `Directory` for `.claude/lib`, `File` for `.claude/lib/hook-payload/HookPayload.psm1`, and `None` for a non-existent sibling path; `Get-WorktreeResolutionGitFileText` returns text containing `Set-StrictMode` for `.claude/lib/worktree-resolution/WorktreeResolution.psm1`; `Get-WorktreeResolutionDirectoryChildName` for `.claude/lib` returns an array containing `worktree-resolution`. No temporary file is created.
  - Acceptance: the file exists and `Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1' -PassThru` reports `FailedCount` equal to `0` and `PassedCount` greater than `0`. `-PassThru` without a settings file is used here so `Run.Exit` does not terminate the session during iteration; the policy MCP gate runs in Phase 4.

- [ ] [P1-T7] Add path-normalisation and ascent tests to `WorktreeResolution.Tests.ps1`
  - Cover: backslash input, forward-slash input, mixed separators, a trailing slash, a leading `./`, and a null or whitespace input. Cover the ascent hitting a root marker at depth 0, at a depth greater than 0, and reaching the drive root with no marker found, plus the `MaximumDepth` termination case. Cover `Test-WorktreeResolutionRootMarker` for a `.git` directory, a `.git` file with a well-formed `gitdir:` line, a `.git` file with malformed text, a `.git` file with empty text, a `.git` file whose seam returns `$null`, and an absent `.git` entry.
  - The `MaximumDepth` termination test's `It` name must contain the exact phrase `MaximumDepth guard`, so the row is identifiable by name in the run record.
  - Acceptance: `Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1' -PassThru` reports `FailedCount` equal to `0`, and a test whose name contains the phrase `MaximumDepth guard` is present in the passed set; the durable record of the final Phase 1 count is `[P1-T11]`.

- [ ] [P1-T8] Add enumerator tests to `WorktreeResolution.Tests.ps1`
  - Drive `Get-WorktreeResolutionWorktreeRoot` through the three seams to model: a session root that is the main checkout; a session root that is a linked worktree, asserting the main checkout is present in the returned set; a linked worktree that is a **sibling** of the main checkout rather than a descendant of it, asserting it resolves without any prefix comparison against a single root; an admin directory holding two linked worktrees; and an admin directory holding none. Assert the return value is always an array, including in the single-element and empty cases.
  - The sibling-topology test's `It` name must contain the exact phrase `sibling of the main checkout`, so the row is identifiable by name in the run record.
  - Acceptance: `Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1' -PassThru` reports `FailedCount` equal to `0`, and a test whose name contains the phrase `sibling of the main checkout` is present in the passed set.

- [ ] [P1-T9] Add normalisation-result and reason-code tests to `WorktreeResolution.Tests.ps1`
  - Cover each row of the input-form table: absolute inside a locatable worktree; absolute with no `.git` entry on the ascent; relative with `-WorktreeRoot`; relative with no `-WorktreeRoot` (Ruling A). Assert `ReasonCode` is the ambiguity literal exactly when `IsNormalized` is `$false` and `$null` otherwise, that `Detail` is never empty, and that a repo-relative remainder **deeper than four segments** survives normalisation intact with no segment lost. Assert the emitted paths use forward slashes, carry no trailing slash, and carry no leading `./`. Assert `Get-WorktreeResolutionAmbiguityReasonCode` returns the exact literal `TARGET_WORKTREE_AMBIGUOUS` and that the returned string does not end with `_BLOCKED`.
  - The no-truncation test's `It` name must contain the exact phrase `deeper than four segments`, so the row is identifiable by name in the run record.
  - Acceptance: `Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1' -PassThru` reports `FailedCount` equal to `0`, and a test whose name contains the phrase `deeper than four segments` is present in the passed set.

- [ ] [P1-T10] Verify the File 1 physical line count against the plan ceiling
  - Run `@(Get-Content -LiteralPath '.claude/lib/worktree-resolution/WorktreeResolution.psm1').Count`. This is the same counting method as `ClaudeLibModuleConvention.Tests.ps1:129`; `Measure-Object -Line` under-reports and must not be used.
  - If the count exceeds `480`, do not create a third module file and do not relocate `Get-WorktreeResolutionAmbiguityReasonCode`. Reduce the comment-based-help blocks of the three seams to a `.SYNOPSIS` and a `.PARAMETER` entry each, which the research's own ratio prices at 30-35 lines per seam and which no assertion in `ClaudeLibModuleConvention.Tests.ps1` constrains, then re-run the count. Record the before count, the reduction applied, and the after count in the same artifact. The mechanically enforced cap is `500` (`ClaudeLibModuleConvention.Tests.ps1:129`, against `$script:MaximumModuleLine = 500` at `:41`); the `480` figure is this plan's margin, and a recorded count between `481` and `500` after one reduction pass is acceptable provided the artifact states the final count and that it is under `500`.
  - Acceptance: `evidence/qa-gates/module-line-counts.file1.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and the recorded final count is at most `480`, or, when the reduction bullet above was applied, is recorded together with the before count, the reduction applied, and an explicit statement that the final count is under `500`.

- [ ] [P1-T11] Persist the Phase 1 suite run record
  - Run `$r = Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1' -PassThru` and record `$r.PassedCount`, `$r.FailedCount`, `$r.SkippedCount`, and the full name of every test in the passed set.
  - Acceptance: `evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the recorded `FailedCount` is `0`; and the recorded passed-test list contains one name containing the phrase `sibling of the main checkout`, one name containing the phrase `deeper than four segments`, and one name containing the phrase `MaximumDepth guard`. Those three phrases are written into the suite's `It` names by `[P1-T8]`, `[P1-T9]`, and `[P1-T7]` respectively.

### Phase 2 — WorktreeTargetResolution.psm1 and its Pester suite

- [ ] [P2-T1] Create `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` with its convention header, sibling import, constants, and result factory
  - Carry the same convention header requirements as `[P1-T2]`, including the exact sentence token `imports its siblings with -ErrorAction Stop` before the strict-mode line and the `.NOTES` mirror sentence.
  - Import the sibling at column 0 with `-ErrorAction Stop`, as `ClaudeLibModuleConvention.Tests.ps1:69-86` requires: `Import-Module (Join-Path $PSScriptRoot 'WorktreeResolution.psm1') -ErrorAction Stop`.
  - Declare the constants: the four `Status` literals `SessionRoot`, `OtherWorktree`, `NoTarget`, `Ambiguous`; the four `Signal` literals `FeatureFolderPath`, `Branch`, `FilePath`, `SessionRoot`; the feature-folder token pattern; and the branch token pattern. Each carries a prose comment explaining why the set is narrow.
  - `New-WorktreeResolutionTargetResult` is the single factory and always returns a `[pscustomobject]`, never `$null`, carrying `Status`, `WorktreeRoot`, `SessionRoot`, `Signal`, `SignalValue`, `Candidates`, `ReasonCode`, and `Detail`. It enforces the field invariants: `SessionRoot` always populated; `Candidates` always an array, possibly empty; `Detail` always a non-empty string; `ReasonCode` set to the ambiguity literal exactly when `Status` is `Ambiguous` and `$null` in every other state.
  - Acceptance: the file exists; `Select-String -LiteralPath '.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1' -SimpleMatch -Pattern 'imports its siblings with -ErrorAction Stop'` returns exactly one match; and `Select-String -LiteralPath '.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1' -SimpleMatch -Pattern 'function New-WorktreeResolutionTargetResult'` returns exactly one match. Both literals are written into the file by this task.

- [ ] [P2-T2] Add the three signal extractors to `WorktreeTargetResolution.psm1`
  - `Find-WorktreeResolutionFeatureFolderSignal -Text` returns the matched feature-folder token **with any absolute prefix preserved**, or `$null`. It must not anchor at the literal `docs`; that anchoring is the defect corrected at `spec.md:63-68`, where the unanchored pattern at `enforce-prd-feature-before-planner.ps1:252` discards the absolute prefix before any truncation occurs.
  - `Find-WorktreeResolutionBranchSignal -Text` returns the matched branch token or `$null`.
  - `Find-WorktreeResolutionFilePathSignal -Text` returns the matched file-path token or `$null`.
  - Acceptance: `Select-String -LiteralPath '.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1' -SimpleMatch -Pattern 'function Find-WorktreeResolutionFeatureFolderSignal'` returns exactly one match, and the same search for `function Find-WorktreeResolutionBranchSignal` and for `function Find-WorktreeResolutionFilePathSignal` each returns exactly one match. All three literals are written into the file by this task.

- [ ] [P2-T3] Add `Resolve-WorktreeCallTarget`, `Join-WorktreeResolutionPath`, and `Export-ModuleMember` to `WorktreeTargetResolution.psm1`
  - `Resolve-WorktreeCallTarget [-Text] [-Branch] [-FilePath] [-SessionRoot]` derives the four states exactly as `spec.md:281-291` tabulates them. `SessionRoot` defaults to the locator's answer for the process's current directory. The dispatch must never read a checkpoint, an orchestrator-state file, or any other run artifact (Ruling B). Two present signals resolving to **different** worktree roots yield `Ambiguous`; two present signals resolving to the **same** root deduplicate to one candidate and resolve normally. The documented precedence order `FeatureFolderPath`, then `FilePath`, then `Branch` governs only which signal kind is reported in `Signal` and `SignalValue` when the present signals agree; it never suppresses a disagreement.
  - The state-3/state-4 boundary is the presence of a signal, not the success of resolving it: a payload naming nothing is `NoTarget`; a payload naming something the module cannot place in exactly one worktree is `Ambiguous`.
  - `Join-WorktreeResolutionPath -WorktreeRoot -RepoRelativePath` returns an absolute forward-slash path with no trailing slash.
  - `Export-ModuleMember -Function` lists exactly the six File 2 exports named in the Decomposition Decision above.
  - For each of the two module files, run `Select-String -LiteralPath <module> -SimpleMatch -Pattern <token>` for each of these six tokens and record the match count: `Start-Process`, `Invoke-Expression`, `Invoke-WebRequest`, `Invoke-RestMethod`, `Get-Date`, and `$env:`. Every count must be zero. Then, for each of the two module files, run `Select-String -LiteralPath <module> -Pattern '(^\s*|[&|;=(]\s*)git(\.exe)?\s'` and record the match count; both counts must be zero. That expression matches a git invocation in command position — at the start of a statement or after `&`, `|`, `;`, `=`, or `(` — and additionally matches the `git.exe` spelling, which a bare `git ` substring search does not. It does not match `.git`, `gitdir`, `$gitEntry`, or the word `git` in a comment, so it verifies the absence of an invocation without constraining module prose. This is the only verification of `spec.md:701` in this plan; `[P2-T9]`'s Python-invocation guard does not reach these constructs, because its allowlist is authored with zero entries by design (`EnforcementHooksNoPythonInvocation.Helpers.ps1:65`) and its detector covers Python interpreter invocations and `Invoke-Expression` only.
  - Acceptance: `Select-String -LiteralPath '.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1' -SimpleMatch -Pattern 'function Resolve-WorktreeCallTarget'` returns exactly one match; the same search for `function Join-WorktreeResolutionPath` returns exactly one match; and, for each of `.claude/lib/worktree-resolution/WorktreeResolution.psm1` and `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`, `@(Get-Content -LiteralPath <module>) | ForEach-Object { $_ -replace '#.*$', '' } | Select-String -SimpleMatch -Pattern 'orchestrator-state'` returns zero matches and the same pipeline with `-Pattern 'checkpoint'` returns zero matches. The comment strip is what aligns the search with `spec.md:674`, which requires no **functional** reference: a Ruling B comment naming either term is a correct thing for the module to carry and must not fail this gate, while either term surviving in executable text must. All four of those searches, and all fourteen searches from the bullet above, are recorded in `evidence/regression-testing/ruling-b-state-read-absence.2026-09-13T22-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and all eighteen return zero matches.

- [ ] [P2-T4] Create `tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1` with the factory and field-invariant tests
  - Carry the same `#Requires` header and the same explicit determinism-posture `.DESCRIPTION` as `[P1-T6]`.
  - `BeforeAll` imports **both** modules by resolved path, File 1 first and then File 2, each with `Import-Module (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution/<Module>.psm1").Path -Force`. Seam mocks are registered with `-ModuleName 'WorktreeResolution'`, because the seams execute inside File 1's session state even when the call originates in File 2.
  - Assert the factory's field invariants for each of the four `Status` values: `SessionRoot` populated, `Candidates` an array rather than a scalar or `$null`, `Detail` a non-empty string, and `ReasonCode` populated only for `Ambiguous`. Assert `Resolve-WorktreeCallTarget` returns a `[pscustomobject]` and never `$null`, and that its result carries all eight named fields.
  - Assert `Join-WorktreeResolutionPath -WorktreeRoot <root> -RepoRelativePath <rel>` returns an absolute forward-slash path with no trailing slash, for a backslash-separated root, for a root already carrying a trailing slash, and for a repo-relative remainder deeper than four segments. That composition is the criterion at `spec.md:690`, and `[P2-T3]`'s declaration search verifies only that the function exists.
  - The composition test's `It` name must contain the exact phrase `join composes an absolute path`, so the row is identifiable by name in the run record.
  - Acceptance: the file exists and `Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1' -PassThru` reports `FailedCount` equal to `0` and `PassedCount` greater than `0`, and a test whose name contains the phrase `join composes an absolute path` is present in the passed set.

- [ ] [P2-T5] Add signal-extractor tests, including absolute-prefix preservation, to `WorktreeTargetResolution.Tests.ps1`
  - Assert `Find-WorktreeResolutionFeatureFolderSignal` given a prompt containing an absolute Windows-style path to a feature folder returns the token **including** its drive and worktree prefix, and given a prompt containing only the repo-relative form returns the bare token. Assert each extractor returns `$null` for a payload carrying no token of its kind.
  - The absolute-form test's `It` name must contain the exact phrase `preserves the absolute prefix`, so the row is identifiable by name in the run record.
  - Acceptance: `Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1' -PassThru` reports `FailedCount` equal to `0`, and a test whose name contains the phrase `preserves the absolute prefix` is present in the passed set.

- [ ] [P2-T6] Add the table-driven required matrix to `WorktreeTargetResolution.Tests.ps1`
  - One `-ForEach` table whose rows are hashtables of injected `.git` topology plus an expected `Status` and `ReasonCode` pair, spanning the full cross product of cwd (session root versus item worktree) x path form (relative versus absolute) x target (own item versus sibling item versus absent), per `epic.md:314-332`. Currently-passing rows are retained as regression guards rather than omitted. The rows must include the regression guard in which the derived target's containing worktree is the worktree the invoking process is running in, asserting `Status` is `SessionRoot`, `WorktreeRoot` equals `SessionRoot`, `ReasonCode` is `$null`, and `Candidates` holds exactly that one root.
  - Each row's `It` name must begin with the exact phrase `required matrix row`, so the rows are identifiable by name in the run record.
  - Acceptance: `Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1' -PassThru` reports `FailedCount` equal to `0`, and the passed set contains at least twelve tests whose names begin with the phrase `required matrix row`.

- [ ] [P2-T7] Add the `Ambiguous` sub-case, `NoTarget` distinguishability, Ruling B, and deny-reason concatenation tests to `WorktreeTargetResolution.Tests.ps1`
  - One test per documented `Ambiguous` sub-case (`spec.md:298-309`): a repo-relative feature-folder token matching two or more candidate worktrees; the same token matching zero candidate worktrees; an absolute path whose upward walk reaches the filesystem root without finding a `.git` entry; a branch signal matching no worktree; a branch signal matching more than one worktree; and two present signals resolving to different worktree roots.
  - Assert `NoTarget` returns `Signal = $null`, `SignalValue = $null`, `WorktreeRoot = $null`, `ReasonCode = $null`, and an empty `Candidates` array, and that `NoTarget` and `Ambiguous` are distinguishable from the result object alone by `Status` and by `ReasonCode`, with no further filesystem or state read.
  - Assert two present signals resolving to the **same** root deduplicate to a single candidate and resolve to `SessionRoot` or `OtherWorktree`, and that the precedence order governs only the reported `Signal` and `SignalValue` when the signals agree.
  - Assert the concatenated deny form `'PRD_FEATURE_BLOCKED: ' + $result.ReasonCode + ' - ' + $result.Detail` contains both the gate token and the ambiguity literal.
  - Each of the six sub-case tests' `It` names must begin with the exact phrase `ambiguous sub-case`, so the six rows are identifiable by name in the run record.
  - Acceptance: `Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1' -PassThru` reports `FailedCount` equal to `0`, and the passed set contains six tests whose names each begin with the phrase `ambiguous sub-case`.

- [ ] [P2-T8] Verify the File 2 physical line count against the plan ceiling
  - Run `@(Get-Content -LiteralPath '.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1').Count`.
  - If the count exceeds `480`, do not create a third module file and do not relocate any function. Reduce the comment-based-help blocks of the three signal extractors to a `.SYNOPSIS` and a `.PARAMETER` entry each, which no assertion in `ClaudeLibModuleConvention.Tests.ps1` constrains, then re-run the count and record the before count, the reduction applied, and the after count in the same artifact.
  - Acceptance: `evidence/qa-gates/module-line-counts.file2.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and the recorded final count is at most `480`, or, when the reduction bullet above was applied, is recorded together with the before count, the reduction applied, and an explicit statement that the final count is under `500`.

- [ ] [P2-T9] Run the tree-wide convention and Python-invocation guard suites against the two new modules
  - Run `Invoke-Pester -Path 'tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1','tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1' -PassThru`. Both discover files from disk — the convention suite at `ClaudeLibModuleConvention.Tests.ps1:30-33`, the Python guard at `enforcement-hooks-no-python-invocation.Tests.ps1:39-42` scanning `.claude/hooks` and `.claude/lib` recursively — so both already include the new modules.
  - Acceptance: `evidence/regression-testing/convention-and-python-guard.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and the recorded `FailedCount` is `0`.

- [ ] [P2-T10] Persist the Phase 2 suite run record
  - Run `$r = Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1' -PassThru` and record `$r.PassedCount`, `$r.FailedCount`, `$r.SkippedCount`, and the full name of every test in the passed set.
  - Acceptance: `evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the recorded `FailedCount` is `0`; the recorded passed-test list contains one name containing the phrase `preserves the absolute prefix`, six names beginning with the phrase `ambiguous sub-case`, at least twelve names beginning with the phrase `required matrix row`, and one name containing the phrase `join composes an absolute path`. Those names are written into the suite by `[P2-T5]`, `[P2-T7]`, `[P2-T6]`, and `[P2-T4]` respectively; all four phrases are written into the suite's `It` names by those tasks.

### Phase 3 — Registration, mirroring, and the coverage denominator

- [ ] [P3-T1] Add the two module paths to `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  - Insert immediately before the closing parenthesis of the `Path` array at `pester.runsettings.psd1:283`, preceded by a comment block in the style of `:211-215` recording that this feature added the worktree-resolution module, that `CodeCoverage.Path` is an explicit per-file allow-list, and that an unregistered production file would sit outside the coverage denominator, which the Coverage Exclusion Policy forbids. Add exactly these two entries and no others: `'.claude/lib/worktree-resolution/WorktreeResolution.psm1'` and `'.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1'`.
  - Do **not** add any `extensions/drm-copilot/resources/` path; the rule is recorded at `pester.runsettings.psd1:269-271`.
  - Acceptance: `Select-String -LiteralPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1' -SimpleMatch -Pattern '.claude/lib/worktree-resolution/WorktreeResolution.psm1'` returns exactly one match, and the same search for `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` returns exactly one match. Both literals are written into that file by this task.

- [ ] [P3-T2] Reset the PowerShell batch budget to open window B
  - Run `Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' -File -ErrorAction SilentlyContinue | Remove-Item -Force`, then `@(Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' -File -ErrorAction SilentlyContinue).Count`. `-ErrorAction SilentlyContinue` is required in both spans because `.claude/state` may not exist.
  - Acceptance: `evidence/other/batch-budget-reset.window-b.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and the recorded post-reset count is `0`. A missing `.claude/state` directory is the expected state before the first PowerShell write of the session and is recorded as a post-reset count of 0.

- [ ] [P3-T3] Mirror the same two entries into `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
  - Apply the identical insertion, including the identical comment block, so the two copies remain text-identical as `test_poshqc_bundled_parity.py:9-18` requires.
  - Acceptance: `(Get-FileHash -Algorithm SHA256 -LiteralPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1').Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath 'extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1').Hash` evaluates to `True`.

- [ ] [P3-T4] Confirm the PoshQC bundled-parity Python test passes after the runsettings edits
  - Run `poetry run python -m pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`.
  - Acceptance: `evidence/regression-testing/poshqc-parity-pytest.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the recorded `EXIT_CODE:` is `0`; and the recorded passed count equals the passed count recorded in `evidence/baseline/baseline-poshqc-parity-pytest.2026-09-13T22-00.md` by `[P0-T10]`.

- [ ] [P3-T5] Register the two module paths in the core pack manifest
  - Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, adding exactly two elements to the `paths` array: `".claude/lib/worktree-resolution/WorktreeResolution.psm1"` and `".claude/lib/worktree-resolution/WorktreeTargetResolution.psm1"`. Place them immediately after the existing last `.claude/lib/` entry, `".claude/lib/mermaid/MermaidValidation.psm1",` at `core.json:165`, four-space indented, matching the surrounding element style. `core.json` is `.json` and consumes no batch-budget slot.
  - Acceptance: `@((Get-Content -LiteralPath 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json' -Raw | ConvertFrom-Json).paths | Where-Object { $_ -eq '.claude/lib/worktree-resolution/WorktreeResolution.psm1' }).Count` evaluates to `1`, and the same expression with `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` evaluates to `1`. Both literals are written into that file by this task.

- [ ] [P3-T6] Produce the two bundle mirrors with `Copy-Item` and verify byte identity
  - Run `New-Item -ItemType Directory -Path 'extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution' -Force`, then copy both modules with `Copy-Item -LiteralPath '.claude/lib/worktree-resolution/<Module>.psm1' -Destination 'extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/<Module>.psm1' -Force`. `Copy-Item` is mandatory: a `Write` or `Edit` of a mirror consumes a production batch-budget slot and does not guarantee byte identity.
  - Acceptance: for each of the two module file names, `(Get-FileHash -Algorithm SHA256 -LiteralPath '.claude/lib/worktree-resolution/<Module>.psm1').Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath 'extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/<Module>.psm1').Hash` evaluates to `True`, and both hash values are recorded in `evidence/qa-gates/bundle-mirror-hashes.2026-09-13T22-00.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P3-T7] Create `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` following the `DiscoveryValidation` pattern
  - Follow `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1`, not the thinner `ModelRouting.Manifest.Tests.ps1`. Resolve the repository root four levels up (`worktree-resolution` -> `claude-lib` -> `scripts` -> `tests` -> repo root) as at `DiscoveryValidation.Manifest.Tests.ps1:24`, and decode the manifest once in `BeforeAll`.
  - The expected-path list holds both module paths. Carry all four assertions: `-Contain` for each path; exactly-once via `@($script:Manifest.paths | Where-Object { $_ -eq $expected }).Count | Should -Be 1` for each path; every on-disk `*.psm1` in `.claude/lib/worktree-resolution` covered by the expected-path list; and a separate `Describe` asserting SHA-256 byte identity against the bundle mirror for each path, including `Test-Path -LiteralPath $bundleFile | Should -BeTrue`.
  - State the determinism posture in the `.DESCRIPTION`: a file-read-only assertion that creates no temporary file and invokes no external process.
  - The byte-identity `Describe` name must end with the exact phrase `bundle mirror byte identity`, matching the `DiscoveryValidation.Manifest.Tests.ps1:61` naming.
  - Acceptance: the file exists; `evidence/regression-testing/manifest-suite.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, recording the `PassedCount`, `FailedCount`, and `SkippedCount` of `Invoke-Pester -Path 'tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1' -PassThru` together with the full name of every test in the passed set; the recorded `FailedCount` is `0` and the recorded `PassedCount` is at least `4`; and `Select-String -LiteralPath 'tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1' -SimpleMatch -Pattern 'bundle mirror byte identity'` returns exactly one match. That literal is written into the file by this task.

- [ ] [P3-T8] Confirm no `extensions/drm-copilot/resources/` path entered `CodeCoverage.Path` in either runsettings copy
  - For each of the two runsettings files, locate the single line matching the regular expression `^\s*Path\s+= @\(\s*$` inside the `CodeCoverage` hashtable, and slice from that line to the first subsequent line whose trimmed text is `)`. The regular expression is used rather than a whitespace-exact literal because `Invoke-Formatter` aligns assignments within a hashtable and `[P3-T1]` adds entries to that hashtable before this task runs; the `\s*$` anchor is what distinguishes this line from `Run.Path = @('scripts', 'tests/powershell', 'tests/scripts')` at `pester.runsettings.psd1:3`. Assert the slice holds more than one hundred lines, so an anchor that failed to match cannot pass as an empty slice. Then discard from that slice every line whose trimmed text begins with `#`, and count the remaining lines containing the substring `extensions/drm-copilot/resources/`. The comment strip is required, and it is the whole-line counterpart of the inline comment strip `[P2-T3]` applies to its `orchestrator-state` and `checkpoint` searches: `pester.runsettings.psd1:269` carries a pre-existing policy comment naming that prefix inside the `CodeCoverage.Path` array in both copies, so an unstripped count is `1` in each file and a zero assertion could never pass. Record the comment-stripped count and, separately, the number of comment lines discarded, so the gate still fails on a real entry added under that prefix while a prose mention does not fail it. Then, for each of the two runsettings files, run `Select-String -LiteralPath <file> -SimpleMatch -Pattern '.claude/lib/worktree-resolution/WorktreeResolution.psm1'` and the same search for `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`, and record the four match counts. Both literals are written into both files by `[P3-T1]` and `[P3-T3]`.
  - Acceptance: `evidence/qa-gates/coverage-path-exclusion-check.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, both recorded slice lengths exceed one hundred, both recorded comment-stripped counts are `0`, and all four recorded module-path match counts are `1`.

- [ ] [P3-T9] Verify the three Pester suites against the 500-line repository limit
  - Run `@(Get-Content -LiteralPath '<suite>').Count` for each of `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1`, `tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1`, and `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`. This is the same counting method as `ClaudeLibModuleConvention.Tests.ps1:129`; that suite discovers `.claude/lib/**/*.psm1` only (`:26-33`) and does not reach `tests/`, so the limit is not mechanically enforced for these files and is verified here.
  - If any count exceeds `480`, reduce that suite's per-test comment volume to one purpose line per `It` and re-count. If it still exceeds `480`, split it into a second suite file in `tests/scripts/claude-lib/worktree-resolution/`, moving whole `Describe` blocks only, and record the split. A split also adds an eleventh changed path, so record the new suite's repository-relative path under a heading `Split suite path:` in the same artifact, or the literal `none` when no split occurred, so `[P4-T11]` can account for it. A split creates a test path the batch-budget hook has not counted; apply the standing unscheduled-reset rule from the Batch-Budget Scheduling section when the test list is at cap. A split does not alter `[P3-T7]`'s expected-path list, which enumerates `.claude/lib/worktree-resolution/*.psm1` and not test files. The repository limit is `500` lines (`.claude/rules/general-code-change.md`); the `480` figure is this plan's margin.
  - Acceptance: `evidence/qa-gates/suite-line-counts.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records for each suite file present on disk at this moment a final count, each stated to be under `500`, together with any reduction or split applied.

### Phase 4 — Final QC loop, coverage measurement, and scope confirmation

- [ ] [P4-T1] Reset the PowerShell batch budget to open window C
  - Run `Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' -File -ErrorAction SilentlyContinue | Remove-Item -Force`, then `@(Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' -File -ErrorAction SilentlyContinue).Count`. `-ErrorAction SilentlyContinue` is required in both spans because `.claude/state` may not exist.
  - Acceptance: `evidence/other/batch-budget-reset.window-c.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and the recorded post-reset count is `0`. A missing `.claude/state` directory is the expected state before the first PowerShell write of the session and is recorded as a post-reset count of 0. This reset exists so any repair the final QC loop demands has three production and three test slots available.

- [ ] [P4-T2] Run the final format stage and observe the tree, not only the exit code
  - Run `git status --porcelain -uall` and record it as the before-listing, and record the SHA-256 hash of each of the ten paths in this plan's Scope Boundary section that exists at this moment. `-uall` is mandatory, and the hashes are mandatory, because porcelain collapses the three untracked directories this feature creates and would not report a rewrite of any of the seven files inside them. Then run `mcp__drm-copilot__run_poshqc_format` with the same `workspace_root` and the same five `scan_folders` values used in `[P0-T4]`. Then re-run `git status --porcelain -uall` and re-compute the ten hashes, recording both as the after-listing.
  - Restore every path named in the `Pre-existing drift paths:` line of `evidence/baseline/baseline-poshqc-format.2026-09-13T22-00.md`, which by construction excludes the `Scope-Boundary drift paths:` set recorded there, with `git restore -- <path>`, and record the restored set. This is required because `[P0-T4]` restored that drift to `HEAD` and this run reproduces it; leaving it would make `[P4-T9]` and `[P4-T11]` unsatisfiable. For each path in that `Scope-Boundary drift paths:` set, do not restore: accept the rewrite, record it, and re-run `[P3-T3]`'s parity hash comparison and `[P3-T4]`'s parity pytest before continuing.
  - The format tool rewrites tracked PowerShell source and exits 0 whether or not it rewrote anything, so the acceptance condition is the tree-and-hash comparison plus the recorded MCP result object, never the exit code alone.
  - Acceptance: `evidence/qa-gates/final-poshqc-format.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records the before-listing, the after-listing, both hash sets, the restored set, the accepted `Scope-Boundary drift paths:` rewrites with their parity re-verification results, and the verbatim MCP result object including its `ok` field. After the restore, the after-listing must equal the before-listing and each of the ten hashes must equal its before value, except for a path in the `Scope-Boundary drift paths:` set recorded by `[P0-T4]`, whose rewrite is accepted and whose parity is re-verified instead. The recorded MCP result text contains the literal `Ran bundled PoshQC format against ` and its `ok` field is `true`. Because the MCP layer returns no per-file line, the tree-and-hash comparison is the whole of the rewrite observation: a Scope Boundary path whose hash changed and which is not in the `Scope-Boundary drift paths:` set recorded by `[P0-T4]` is a rewrite this stage caused. If any such hash differs, the rewrite is accepted, the mirrors are re-synchronised, and the loop restarts at this task.

- [ ] [P4-T3] Run the final analyze stage
  - Run `mcp__drm-copilot__run_poshqc_analyze` with the same `workspace_root` and the same five `scan_folders` values. Then run the same self-hosted `Invoke-PoshQCAnalyze` command as `[P0-T5]`, wrapped in the same `try`/`catch`, to obtain the finding set.
  - Acceptance: `evidence/qa-gates/final-poshqc-analyze.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the finding set composed from the self-hosted stdout contains no finding whose path is one of the ten Scope Boundary paths; and that finding set is a subset of the `Baseline finding set` recorded by `[P0-T5]`. When that baseline set is `none`, the MCP `ok` field must be `true` and the self-hosted stdout must contain the literal `PSScriptAnalyzer passed: no findings under `. When that baseline set is non-empty, the MCP `ok` field is recorded as observed and the subset comparison is the gate, because a pre-existing finding makes the bundled script exit non-zero and `ok: false` is then the correct unchanged-from-baseline result. If this stage fails on the subset comparison or modifies a file, the loop restarts at `[P4-T2]`.

- [ ] [P4-T4] Re-synchronise the bundle mirrors after the format and analyze stages
  - The format stage may rewrite the repo-side modules. Re-run the two `Copy-Item` commands from `[P3-T6]`, then re-run the SHA-256 comparison for each module.
  - Acceptance: `evidence/qa-gates/bundle-mirror-hashes.post-format.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records for each of the two modules a repo-side hash equal to its bundle hash.

- [ ] [P4-T5] Run the final MCP test stage with repository-wide numeric coverage
  - Run `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the workspace absolute path and `scan_folders` omitted, exactly as in `[P0-T6]`. Then copy `artifacts/pester/powershell-coverage.xml` to `evidence/other/final-powershell-coverage.mcp.2026-09-13T22-00.xml` with `Copy-Item -Force` before any later run overwrites it. Copy `artifacts/pester/pester-junit.xml` to `evidence/other/final-pester-junit.2026-09-13T22-00.xml` with `Copy-Item -Force` in the same step.
  - Acceptance: `evidence/qa-gates/final-poshqc-test-mcp.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the recorded failed count is less than or equal to the failed count recorded by `[P0-T6]`; `evidence/other/final-pester-junit.2026-09-13T22-00.xml` exists; the artifact names every failing test, composed from the element and attribute names recorded by `[P0-T6]`, and states, for each, that its file is not one of the ten Scope Boundary paths and that it also appears in the `Baseline failure set` recorded by `[P0-T6]`; the `Output Summary:` field records the repository-wide post-change covered-lines, missed-lines, and percentage triple, read using the element and attribute names recorded by `[P0-T8]`; and `evidence/other/final-powershell-coverage.mcp.2026-09-13T22-00.xml` exists. A failing test that is not in the `[P0-T6]` baseline failure set fails this gate and the loop restarts at `[P4-T2]`.

- [ ] [P4-T6] Determine whether the MCP runner honoured the newly added `CodeCoverage.Path` entries
  - Inspect `evidence/other/final-powershell-coverage.mcp.2026-09-13T22-00.xml` for a per-file row whose file-name attribute identifies `WorktreeResolution.psm1` under the semantics recorded by `[P0-T8]`, comparing on the bare name when `[P0-T8]` recorded a bare name and on the trailing path segment when it recorded a full path, inside the grouping element whose directory attribute ends with `worktree-resolution`, using the names recorded by `[P0-T8]`. Record `HONOURED` when the row is present and `INSTALLED-EXTENSION-SETTINGS` when it is absent.
  - A missing row is a tooling-path symptom, not a coverage failure, and must not be recorded as a registration defect: `[P3-T1]`, `[P3-T3]`, and `[P3-T8]` already establish that the entries are present in both in-repo copies. This task closes the item recorded as unverified at `research:1155`.
  - Acceptance: `evidence/qa-gates/mcp-coverage-path-determination.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and its `Output Summary:` field records exactly one of the two literals `HONOURED` or `INSTALLED-EXTENSION-SETTINGS`, together with the row count found for each of the two module file names.

- [ ] [P4-T7] Measure per-file line coverage for the two new modules by self-hosted invocation
  - Run `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib')`, the same command as `[P0-T7]`. Then copy `artifacts/pester/powershell-coverage.xml` to `evidence/other/final-powershell-coverage.selfhosted.2026-09-13T22-00.xml`.
  - For each module, locate the per-file element whose file-name attribute identifies the module file under the semantics recorded by `[P0-T8]`, comparing on the bare name when `[P0-T8]` recorded a bare name and on the trailing path segment when it recorded a full path, **within** the grouping element whose directory attribute ends with `worktree-resolution`, read its line counter's covered and missed values, and compute `100 * covered / (covered + missed)` rounded to two decimals. Keying on the enclosing grouping element rather than the bare file name is required by `spec.md:182-185`.
  - Acceptance: `evidence/qa-gates/final-poshqc-selfhosted-coverage.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; the recorded failed count is less than or equal to the failed count recorded by `[P0-T7]`, and no failing test names a file under `tests/scripts/claude-lib/worktree-resolution/`; and the `Output Summary:` field records, for each of the two modules, the covered-lines value, the missed-lines value, and a percentage of at least `85.00`.

- [ ] [P4-T8] Write the coverage delta artifact
  - Report three figures side by side: the repository-wide baseline line coverage from `evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md`; the repository-wide post-change line coverage from `evidence/qa-gates/final-poshqc-test-mcp.2026-09-13T22-00.md`; and the new-code line coverage, which is the per-file pair recorded by `[P4-T7]` together with their combined covered/missed aggregate and percentage.
  - State explicitly that the figures are not inferred from a passing run, because `CoveragePercentTarget = 0` (`pester.runsettings.psd1:285`) means a green run gates no threshold.
  - Acceptance: `evidence/qa-gates/coverage-delta.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records all three figures as numbers, a signed repository-wide delta, and the explicit statement that the new-code aggregate is at or above `85.00`.

- [ ] [P4-T9] Confirm the toolchain completed in a single pass in the required order
  - Compare the `Timestamp:` fields of `evidence/qa-gates/final-poshqc-format.2026-09-13T22-00.md`, `evidence/qa-gates/final-poshqc-analyze.2026-09-13T22-00.md`, and `evidence/qa-gates/final-poshqc-test-mcp.2026-09-13T22-00.md`, and compare the format stage's before-listing, after-listing, and the two hash sets recorded by `[P4-T2]`.
  - Acceptance: `evidence/qa-gates/toolchain-single-pass.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records that the three timestamps are non-decreasing in the order format, analyze, test; that no stage reported a failure beyond the `[P0-T6]` baseline failure set; and that the format stage's after-listing, after the restore of the `Pre-existing drift paths:` set, is identical to its before-listing, and that every one of the ten Scope Boundary hashes recorded by `[P4-T2]` is unchanged across that stage, or, for each path in the `Scope-Boundary drift paths:` set recorded by `[P0-T4]`, that the rewrite was accepted and the parity re-verification recorded by `[P4-T2]` passed.

- [ ] [P4-T10] Confirm the scope boundary: no consumer was rewired
  - Run `git status --porcelain -uall -- .claude/hooks .codex/hooks extensions/drm-copilot/src` and `git diff --name-only <MERGE_BASE_SHA> -- .claude/hooks .codex/hooks extensions/drm-copilot/src`, substituting the SHA recorded by `[P0-T2]`. The porcelain span is required because a name-listing diff cannot report an untracked path, and `-uall` keeps it consistent with every other porcelain span in this plan.
  - Acceptance: `evidence/qa-gates/scope-boundary.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records both command outputs as empty.

- [ ] [P4-T11] Record the complete changed-file inventory against the merge base
  - Run `git status --porcelain -uall` and `git diff --name-only <MERGE_BASE_SHA>`, substituting the SHA recorded by `[P0-T2]`. `-uall` is mandatory: without it git collapses a wholly untracked directory to a single entry, and six of the ten paths this feature creates sit in three such directories.
  - Union the two listings, then remove every path that begins with `docs/features/` and every path named in the `Pre-existing drift paths:` line of `evidence/baseline/baseline-poshqc-format.2026-09-13T22-00.md`. The `docs/features/` removal is required because the feature folder, `docs/features/potential/promoted/2026-09-13-target-worktree-resolution-module.md`, and `docs/features/epics/worktree-scoped-state-resolution/epic.md` are all outside the merge base and none is a code or test change.
  - Acceptance: `evidence/qa-gates/changed-file-inventory.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; it records both raw listings verbatim, the removal set it applied, and the reduced union; and the reduced union contains exactly the ten paths enumerated in this plan's Scope Boundary section, together with any path recorded under `Split suite path:` in `evidence/qa-gates/suite-line-counts.2026-09-13T22-00.md`, and no others.

### Phase 5 — Acceptance-criteria check-off and completion

The 51 acceptance criteria are a single inventory duplicated verbatim across `spec.md:659-730` and
`user-story.md:166-237`. Each task below checks off one criterion group in **both** files, verifying
each criterion individually against named evidence before changing its checkbox, per
`.claude/skills/acceptance-criteria-tracking/SKILL.md`. Only `- [ ]` becomes `- [x]`; criterion text is
never altered; an unverified criterion is left unchecked and its gap is recorded.

- [ ] [P5-T1] Check off the ten `### Contract surface` criteria in `spec.md` and `user-story.md`
  - Evidence: `evidence/regression-testing/convention-and-python-guard.2026-09-13T22-00.md`, `evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md`, `evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md`, and `evidence/qa-gates/scope-boundary.2026-09-13T22-00.md`.
  - Acceptance: in each of the two files, the ten lines between the heading `### Contract surface` and the next `###` heading all begin with `- [x] `, and `evidence/other/ac-checkoff-contract-surface.2026-09-13T22-00.md` records one line per criterion naming the test or artifact that verified it.

- [ ] [P5-T2] Check off the ten `### Rulings A, B, and C` criteria in `spec.md` and `user-story.md`
  - Evidence: `evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md`, `evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md`, and `evidence/regression-testing/ruling-b-state-read-absence.2026-09-13T22-00.md`. The Ruling B criterion at `spec.md:674` is evidenced by the four `orchestrator-state` and `checkpoint` searches recorded in the last of those, covering both module files.
  - Acceptance: in each of the two files, the ten lines between the heading `### Rulings A, B, and C` and the next `###` heading all begin with `- [x] `, and `evidence/other/ac-checkoff-rulings.2026-09-13T22-00.md` records one line per criterion naming the test or artifact that verified it.

- [ ] [P5-T3] Check off the six `### Path normalisation and composition` criteria in `spec.md` and `user-story.md`
  - Evidence: `evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md`, `evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md`, and `evidence/regression-testing/ruling-b-state-read-absence.2026-09-13T22-00.md`.
  - Acceptance: in each of the two files, the six lines between the heading `### Path normalisation and composition` and the next `###` heading all begin with `- [x] `, and `evidence/other/ac-checkoff-path-normalisation.2026-09-13T22-00.md` records one line per criterion naming the test or artifact that verified it.

- [ ] [P5-T4] Check off the three `### Reason code` criteria in `spec.md` and `user-story.md`
  - Evidence: `evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md` and `evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md`.
  - Acceptance: in each of the two files, the three lines between the heading `### Reason code` and the next `###` heading all begin with `- [x] `, and `evidence/other/ac-checkoff-reason-code.2026-09-13T22-00.md` records one line per criterion naming the test or artifact that verified it.

- [ ] [P5-T5] Check off the four `### Seams and determinism` criteria in `spec.md` and `user-story.md`
  - Evidence: `evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md` for the seam-default-body tests added by `[P1-T6]`, `evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md` for the table-driven matrix added by `[P2-T6]`, `evidence/regression-testing/ruling-b-state-read-absence.2026-09-13T22-00.md` for the fourteen searches that verify `spec.md:701`, and the determinism-posture `.DESCRIPTION` block in each of the three suites.
  - Acceptance: in each of the two files, the four lines between the heading `### Seams and determinism` and the next `###` heading all begin with `- [x] `, and `evidence/other/ac-checkoff-seams.2026-09-13T22-00.md` records one line per criterion naming the test or artifact that verified it.

- [ ] [P5-T6] Check off the nine `### Registration, mirroring, and coverage` criteria in `spec.md` and `user-story.md`
  - Evidence: `evidence/regression-testing/poshqc-parity-pytest.2026-09-13T22-00.md`, `evidence/qa-gates/bundle-mirror-hashes.2026-09-13T22-00.md`, `evidence/regression-testing/manifest-suite.2026-09-13T22-00.md`, `evidence/qa-gates/coverage-path-exclusion-check.2026-09-13T22-00.md`, `evidence/qa-gates/bundle-mirror-hashes.post-format.2026-09-13T22-00.md`, and `evidence/qa-gates/final-poshqc-selfhosted-coverage.2026-09-13T22-00.md`. The two `core.json` exactly-once criteria are additionally evidenced by the manifest suite's exactly-once assertions recorded in `evidence/regression-testing/manifest-suite.2026-09-13T22-00.md`.
  - Acceptance: in each of the two files, the nine lines between the heading `### Registration, mirroring, and coverage` and the next `###` heading all begin with `- [x] `, and `evidence/other/ac-checkoff-registration.2026-09-13T22-00.md` records one line per criterion naming the test or artifact that verified it.

- [ ] [P5-T7] Check off the five `### Policy compliance` criteria in `spec.md` and `user-story.md`
  - Evidence: `evidence/regression-testing/convention-and-python-guard.2026-09-13T22-00.md`, `evidence/qa-gates/module-line-counts.file1.2026-09-13T22-00.md`, `evidence/qa-gates/module-line-counts.file2.2026-09-13T22-00.md`, `evidence/qa-gates/suite-line-counts.2026-09-13T22-00.md`, `evidence/qa-gates/toolchain-single-pass.2026-09-13T22-00.md`, `evidence/qa-gates/poshqc-observed-success-output.2026-09-13T22-00.md`, and `evidence/qa-gates/changed-file-inventory.2026-09-13T22-00.md` confirming no Python file changed.
  - Acceptance: in each of the two files, the five lines between the heading `### Policy compliance` and the next `###` heading all begin with `- [x] `, and `evidence/other/ac-checkoff-policy.2026-09-13T22-00.md` records one line per criterion naming the test or artifact that verified it.

- [ ] [P5-T8] Check off the four `### Must not regress (carried verbatim from the epic)` criteria in `spec.md` and `user-story.md`
  - Evidence: `evidence/qa-gates/scope-boundary.2026-09-13T22-00.md` establishes that no gate file changed, which is what makes the first three criteria hold by construction for this feature; the fourth is evidenced by the cwd-equals-target regression-guard row recorded in `evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md`, which `[P2-T6]` writes into the suite and `[P2-T10]` persists.
  - Acceptance: in each of the two files, the four lines between the heading `### Must not regress (carried verbatim from the epic)` and the next heading all begin with `- [x] `, and `evidence/other/ac-checkoff-must-not-regress.2026-09-13T22-00.md` records one line per criterion naming the artifact that verified it.

- [ ] [P5-T9] Record the acceptance-criteria status summary for both source files
  - For `spec.md`, slice the lines strictly between `## Acceptance Criteria` and `## Definition of Done`; for `user-story.md`, slice strictly between `## Acceptance Criteria` and `## Non-Goals`. In each slice count lines satisfying `$_.StartsWith('- [x] ')` and lines satisfying `$_.StartsWith('- [ ] ')`.
  - Acceptance: `evidence/other/ac-status-summary.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records for each file a total of `51`, a checked count of `51`, and an unchecked count of `0`. Any criterion that could not be verified is left unchecked and named in the summary with its gap, in which case the checked count is recorded as it stands and the outcome is reported as remediation-required rather than complete.

- [ ] [P5-T10] Check off the satisfied `## Definition of Done` items in `spec.md`
  - Verify and check off each of the thirteen items at `spec.md:734-746` that this plan's evidence supports, leaving any unsupported item unchecked with its gap recorded. No Definition-of-Done item directs evidence to a non-canonical sub-path, so no substitution is recorded.
  - Acceptance: `evidence/other/dod-checkoff.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records one line per Definition-of-Done item with its verdict and the artifact that supports it.

- [ ] [P5-T11] Write the plan-completion evidence artifact
  - Enumerate every task identifier in this plan with its completion state, every evidence artifact path this plan names with an existence check, and the three unverified items from the Unverified Items section with their closing state (`[P4-T6]` closes item 1; item 2 is recorded as already resolved in this plan's Unverified Items section, and `[P0-T9]` records the per-stage evidence consistent with that resolution; item 3 remains outside this feature's scope).
  - The `evidence/other/batch-budget-reset.unscheduled-N.2026-09-13T22-00.md` family is conditional: it exists only for unscheduled resets that were actually needed. Record the count of such files found, and record `not required` rather than a missing-artifact verdict when the count is `0`. Every other artifact path this plan names is unconditional and must exist.
  - Acceptance: `evidence/qa-gates/plan-completion.2026-09-13T22-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, lists every task identifier in this plan from `[P0-T1]` through `[P5-T11]` inclusive, including this task, and records an existence verdict for every evidence artifact path this plan names.

## Test Plan

- **Unit (Pester):** `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1` covers the three seams in both mocked and default-body form, separator normalisation, the root-marker classifier across all six `.git` entry forms, the ascent at depth 0, at depth greater than 0, at the drive root, and at the `MaximumDepth` guard, the enumerator across main-checkout, linked-worktree, sibling-worktree, two-worktree, and zero-worktree topologies, all four normalisation input forms including Ruling A, and the reason-code accessor.
- **Unit (Pester):** `tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1` covers the result factory's field invariants, the three signal extractors including absolute-prefix preservation, the table-driven required matrix, all four `Status` states, all six `Ambiguous` sub-cases, the `NoTarget`-versus-`Ambiguous` distinguishability, the Ruling B precedence and disagreement behaviour, the `Join-WorktreeResolutionPath` composition, and the deny-reason concatenation.
- **Registration (Pester):** `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` covers `-Contain`, exactly-once registration, on-disk coverage of the expected-path list, and SHA-256 bundle-mirror byte identity.
- **Tree-wide guards already covering the new files:** `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, both of which discover files from disk.
- **Cross-surface regression:** `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`, baselined at `[P0-T10]` and re-run at `[P3-T4]`.
- **Persisted suite run records:** every Phase 5 check-off cites an evidence artifact, never a live run. The durable records are `evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md` (`[P1-T11]`), `evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md` (`[P2-T10]`), `evidence/regression-testing/manifest-suite.2026-09-13T22-00.md` (`[P3-T7]`), `evidence/regression-testing/ruling-b-state-read-absence.2026-09-13T22-00.md` (`[P2-T3]`), and `evidence/regression-testing/convention-and-python-guard.2026-09-13T22-00.md` (`[P2-T9]`).
- **Integration:** none. The module has no consumers at merge time.
- **Coverage evidence:** baseline at `evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md` and `evidence/baseline/baseline-poshqc-selfhosted-test.2026-09-13T22-00.md`; post-change at `evidence/qa-gates/final-poshqc-test-mcp.2026-09-13T22-00.md` and `evidence/qa-gates/final-poshqc-selfhosted-coverage.2026-09-13T22-00.md`; comparison at `evidence/qa-gates/coverage-delta.2026-09-13T22-00.md`. The machine-readable run outputs the failure-set comparison reads are copied aside at `evidence/other/baseline-pester-junit.2026-09-13T22-00.xml` (`[P0-T6]`) and `evidence/other/final-pester-junit.2026-09-13T22-00.xml` (`[P4-T5]`).

## Open Questions / Notes

- The four rulings A, B, C, and D are settled at `spec.md:85-186` and are not reopened by this plan.
- The epic's characterisation of the F4 defect site is corrected at `spec.md:54-76`. That correction is
  an input to F4 and changes nothing in this feature; `[P2-T2]` carries the one consequence that does
  reach F1, namely that the feature-folder extractor preserves an absolute prefix.
- Coverage on the two new modules is measured from the self-hosted invocation regardless of the
  `[P4-T6]` determination, so the outcome of that determination does not gate this feature.
