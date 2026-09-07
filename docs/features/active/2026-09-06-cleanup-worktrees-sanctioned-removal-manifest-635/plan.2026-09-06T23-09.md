# 2026-09-06-cleanup-worktrees-sanctioned-removal-manifest (Plan)

- **Issue:** #635
- **Parent:** epic `cleanup-merged-worktrees-hardening` (child D; gaps 3 and 9a)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-06T23-09
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** full-bug (marker source: `issue.md` metadata block)
- **Branch:** `bug/cleanup-worktrees-sanctioned-removal-manifest-635`
- **Requirements source:** `spec.md` is the sole acceptance-criteria source. It carries `AC-01`
  through `AC-37` under `## Acceptance Criteria`. `user-story.md` carries narrative and
  non-functional context only and carries zero checkboxes; it is not an AC source.
  `research/2026-09-07-sanctioned-removal-manifest-research.md` is the cited evidence base.

## Reading Conventions For This Plan

- **Feature folder.** The feature folder is
  `docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/`.
  Every `issue.md`, `spec.md`, `user-story.md`, `research/...`, and `evidence/...` path in this
  plan is **relative to that folder**. No task writes a path token longer than this plan's own
  path into any file or message.
- **Evidence locations are non-overridable.** All evidence resolves under
  `evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`,
  `evidence/issue-updates/`, `evidence/other/`, or `evidence/remediation-baseline/`.
  **`evidence/coverage/` is not a canonical sub-path.** `spec.md` AC-25 already records this
  correction and routes coverage output to `evidence/qa-gates/`; this plan carries the same
  routing. No task writes to `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`,
  `artifacts/qa-gates/`, `artifacts/coverage/`, `artifacts/evidence/`,
  `artifacts/regression-testing/`, or `artifacts/post-change/`.
  `EVIDENCE_LOCATION_CORRECTION: spec.md prose that could be read as naming a coverage
  sub-path is executed as evidence/qa-gates/, which is the canonical location.`
- **`artifacts/pester/` is a tool output directory, not an evidence location.** The Pester run
  settings direct the test runner to write `artifacts/pester/pester-junit.xml` and
  `artifacts/pester/powershell-coverage.koverage.xml`. Several tasks in this plan read numeric
  values out of those two files. No task in this plan writes evidence there; every evidence
  artifact resolves under `evidence/<kind>/`.
- **Timestamp token.** Evidence filenames in this plan carry the fixed stem plus the token
  `2026-09-06T23-09`, so every path in this plan is concrete and contains no placeholder
  character. Where a task is re-run after a revision, append a fresh `yyyy-MM-ddTHH-mm` token
  rather than overwriting.
- **Every command-step evidence artifact carries** `Timestamp:`, `Command:`, `EXIT_CODE:`, and
  `Output Summary:`. Baseline and final-QC test artifacts carry numeric coverage headline values,
  never placeholders.
- **Line numbers are re-derived at execution time.** This child executes after sibling epic
  children merge into `epic/cleanup-merged-worktrees-hardening-integration`, so every file may
  have shifted. Insertion points in this plan are expressed as **structural anchors** (function
  name plus the statement the insertion sits after). Phase 0 re-derives and records the current
  line numbers as evidence. No task in this plan may be completed by navigating to a line number
  quoted in `spec.md` or in `research/2026-09-07-sanctioned-removal-manifest-research.md`.

## Fixed Identifiers Introduced By This Work

These are the exact names the plan instructs the executor to create. They are quoted here in
prose, outside every command span, so that an acceptance condition asserting one of them is read
against the executor's instruction rather than against the pre-change tree.

- Module file: `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`
- Manifest path constant value: `artifacts/orchestration/cleanup-worktrees-manifest.json`
- Read seam: `Get-CleanupWorktreeManifestContent`
- Clock seam: `Get-CleanupWorktreeManifestUtcNow`
- Path normalizer: `ConvertTo-CleanupWorktreeManifestNormalizedPath`
- Record lookup: `Find-CleanupWorktreeManifestRemovalRecord`
- Allow predicate: `Test-CleanupWorktreeManifestAuthorizesRemoval`
- Checkpoint-exclusion helper: `Test-CleanupManifestCheckpointCoversPath`
- Disposition constant: `AllowedRemovalDispositions`
- Branch-state constant: `AuthorizedBranchStates`
- New test suites: `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`
  and `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`
- New skill token to be added to `allowed-tools`: `Bash(git worktree remove *)`
- Skill residual-posture token to be added: `cryptographic or security boundary`
- Skill step-9 authorization token to be added: `manifest-authorized removal`
- Split-contingency suite names, used only if a 500-line cap would otherwise be exceeded:
  `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrixValues.Tests.ps1`,
  `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate-manifest-pins.Tests.ps1`, and
  `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate-manifest-pins.Tests.ps1`

**Test-file placement.** `.claude/rules/general-unit-test.md` Test File Location and
`.claude/rules/powershell.md:57` require the test tree to mirror the production tree.
`tests/scripts/claude-lib/` mirrors `.claude/lib/` one directory per module — `blast-radius/`,
`codex-routing/`, `discovery-validation/`, `hook-payload/`, `mermaid/`, `model-routing/`,
`orchestrator-state/`, `requirements/` — and every existing module suite lives in its own
subdirectory, so the module unit surface belongs at
`tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`. The gate-matrix
suite sits under `claude-hooks` instead because it dot-sources and exercises the two hooks rather
than the module alone, so it mirrors the hook tree. `spec.md`'s Test Strategy Placement bullet
records the same two paths and records that no acceptance criterion asserts a test-file location.

## Scope Boundaries (Non-Negotiable)

**Must-not-touch (spec.md D6).** In both gate hooks: the extraction regex strings and their
`.Trim` calls, the trigger guards, the bodies of `Get-EpicWorktreeRemovalCommandPath` and
`Get-ParallelWorktreeRemovalCommandPath`, the two deny reason strings, the decision constructors
`Get-EpicWorktreeGateAllowDecision`, `Get-EpicWorktreeGateBlockDecision` and their parallel
counterparts, the entry points, and the thin tails.

**No edit at all** to `.claude/lib/hook-payload/HookPayload.psm1`,
`scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh`,
`scripts/bash/cleanup_worktrees_enumerate_lib.sh`, `scripts/bash/cleanup-worktrees.sh`,
`.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/validate-bash.ps1`, or
`.codex/hooks/enforce-epic-worktree-removal-gate.ps1`.

**Deliberately absent criteria.** Nothing in this plan asserts that the `bash <file>` indirection
is closed, and nothing asserts a permission-layer block. Both absences are required by `spec.md`
D8 and D3 and must survive review.

**No Python** anywhere in the new module or in either hook.
`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans
`.claude/hooks` and `.claude/lib` for `*.ps1` and `*.psm1` with an AST-based check whose allowlist
ships empty and is asserted empty by `It 'ships an empty allowlist'`.

**No temporary files in tests.** The manifest read boundary and the clock boundary are exercised
exclusively through `Get-CleanupWorktreeManifestContent` and `Get-CleanupWorktreeManifestUtcNow`,
mocked with `-ModuleName 'CleanupWorktreeManifest'`.

## PowerShell Change Budget Batching

`.claude/rules/powershell.md:40` caps a batch at 3 production files and 3 test files. The full
change spans more than that once mirrors are counted, so the implementation phases are batched as
follows and each batch respects the cap:

| Batch | Phase | Production PowerShell files | Test PowerShell files |
| --- | --- | --- | --- |
| A | Phase 1 | 1 (`CleanupWorktreeManifest.psm1`) | 1 (`CleanupWorktreeManifest.Tests.ps1`) |
| B | Phase 2 | 0 | 2 (the two existing gate suites) |
| C | Phase 3 | 2 (the two gate hooks) | 3 (the two gate suites plus `CleanupWorktreeManifestGateMatrix.Tests.ps1`) |
| D | Phase 4 | 0 (Markdown only) | 0 |
| E | Phase 5 | 3 (the three `.claude` PowerShell mirrors) | 0 |
| F | Phase 6 | 2 (the two `pester.runsettings.psd1` files) | 0 |

Phase 4 changes only `SKILL.md`, which is Markdown and consumes no PowerShell budget. Phase 6
additionally changes `core.json` and the `SKILL.md` mirror, neither of which is a PowerShell file.

**Each batch boundary is realized by an explicit counter reset.**
`.claude/hooks/enforce-powershell-batch-budget.ps1:13-15` and :42-45 scope a batch to the current
Claude Code session, persist the running count at
`.claude/state/powershell-batch-budget.<session id>.json` (composed at :366), and state that the
session must delete that state file to start a new batch. The hook counts `.ps1`, `.psm1`, and
`.psd1` (:273 and :348), classifies `tests/**/*.ps1` and `*.Tests.ps1` as test files and everything
else as production (:284), and counts distinct paths cumulatively. The cumulative distinct totals
across this plan are eight production files and four or five test files, so without a reset the
hook denies the fourth distinct file of either class. A batch boundary is therefore not observed
by the hook unless the counter is reset, and Phases 2, 3, 5, and 6 each open with an explicit
reset task.

## PowerShell Toolchain Order

Format then analyze then test. There is no type-check step for PowerShell. Restart from format
whenever a step fails or changes files.

**Coverage command substitution.** `mcp__drm-copilot__run_poshqc_test` reads the **installed
extension's** PoshQC settings, so a `CodeCoverage.Path` entry newly added to the repository's
runsettings can be silently ignored and the new module can stay out of the coverage denominator
while the run still reports success. Every coverage step that has to see the new file therefore
runs the self-hosted module directly:

```text
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
```

`-SettingsPath` is redundant once the module is imported from the repository but makes the binding
explicit in the evidence record.

**Observe-before-assert.** The success-case output shapes of the three PoshQC entry points were
re-derived from the module source for this revision, and every acceptance condition in this plan is
written against an observed shape rather than an inferred one:

- `Invoke-PoshQCFormat` (`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:52-64`) prints **no summary
  line**. It emits `No PowerShell files found under <Root>` when the scan set is empty (:52), and
  otherwise one line per discovered file, either `Formatted: <full path>` (:62) or
  `Already formatted: <full path>` (:64).
- `Invoke-PoshQCAnalyze` prints `PSScriptAnalyzer passed: no findings under <Root>` on a clean run
  (`PoshQC.Analyzer.psm1:185`) and throws `PSScriptAnalyzer reported N issue(s).` when findings
  exist (:181-183). **The finding count appears only on the failing path.**
- `Invoke-PoshQCTest` (`PoshQC.Testing.psm1:423-451`) prints one totals line,
  `Tests Passed: {0}, Failed: {1}, Skipped: {2}, Inconclusive: {3}, NotRun: {4}`, followed by the
  coverage text up to the first line matching `^\s*Missed commands`. Under Pester 5.6.1 that text is
  a single overall coverage line. **The console output carries no per-suite breakdown and no
  per-file coverage table.**

Per-suite and per-file numbers are therefore read from the two machine-readable artifacts the run
settings direct the run to write:

- `artifacts/pester/pester-junit.xml`, from
  `TestResult.OutputFormat = 'JUnitXml'` and `TestResult.OutputPath` in
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:12-16`. Pester writes one `testsuite`
  element per test file, with `name` set to the container path and count attributes that include
  `tests`, `errors`, and `failures`. **The element carries no `passed` attribute.** Wherever this
  plan asks for a per-suite passed count, transcribe that `testsuite` element's complete start tag
  verbatim into the artifact, then derive the passed count by subtracting from `tests` every
  non-passing count the element carries — `failures` and `errors` always, plus `skipped` and
  `disabled` when the element carries them. Recording the start tag beside the derived count makes
  the derivation auditable and keeps it correct without assuming an attribute set rather than
  reading one. Two QA-gate evidence artifacts in the completed feature folder for issue #573
  record `testsuite` attributes extracted from that file and show `name`, `tests`, `errors`, and
  `failures`; no recorded `testsuite` or `testsuites` attribute in this repository is named
  `passed`. A per-suite passed count read directly off the element therefore has no observed
  source, which is why this plan derives it.
- `artifacts/pester/powershell-coverage.koverage.xml`, the repo-relative copy `Invoke-PoshQCTest`
  derives from `CodeCoverage.OutputPath` (`pester.runsettings.psd1:17-22`; derivation at
  `PoshQC.Testing.psm1:402-418`, relativization by `Convert-PoshQCCoverageToRelative` at :42-127).
  With `CodeCoverage.OutputFormat = 'CoverageGutters'` the document is JaCoCo-shaped:
  `<report>` holds `<package name="<directory>">` elements, each holding `<sourcefile name="<file
  name>">` elements with per-line coverage entries. The fixture at
  `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1:294-306` shows that shape and shows that the
  `sourcefile` `name` attribute carries the **file name only**, with the directory on the enclosing
  `package` element. **A measured file's repo-relative path is therefore the enclosing `package`
  `name` joined to the `sourcefile` `name` with `/`**, and a search for a full repo-relative path in
  a `sourcefile` `name` attribute alone would match nothing. P0-T7 transcribes one complete
  `sourcefile` element before any later task computes a percentage from these entries, so the exact
  per-line attribute names are observed rather than inferred.

---

### Phase 0 — Baseline Capture And Structural Anchor Re-Derivation

- [ ] [P0-T1] Read the policy files in the order defined by `policy-compliance-order`: `CLAUDE.md`,
      `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
      `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`,
      `.claude/rules/plan-acceptance-gates.md`, `.claude/rules/tonality.md`, and write
      `evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:`, and
      an explicit list of every file read. Acceptance: the artifact exists and its file list names
      all seven files.
- [ ] [P0-T2] Re-derive the structural anchors in `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
      and record them in `evidence/baseline/structural-anchors-epic-gate.2026-09-06T23-09.md` with
      `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Record the current line number
      of: the `Import-Module` statement, the `$script:AllowedMergeStatuses` assignment, the
      `$worktreePath` assignment inside `Invoke-EpicWorktreeRemovalGateDecision`, the
      `$featureRecord` assignment, the `Test-ParallelCheckpointAllowsWorktreeRemoval` call, and the
      final `Get-EpicWorktreeGateBlockDecision` return.

      **Three** of the six patterns match more than one line in the pre-change tree, so record
      every matching line number for those patterns and mark which one is the anchor. For
      `AllowedMergeStatuses` the anchor is the `$script:` assignment; for
      `Test-ParallelCheckpointAllowsWorktreeRemoval` the anchor is the **call** inside
      `Invoke-EpicWorktreeRemovalGateDecision`, not the function definition; and for
      `Get-EpicWorktreeGateBlockDecision -Reason` the anchor is the **last** occurrence, which is
      the function's final return. Re-derive the full match lists in this task rather than reusing
      any list quoted elsewhere.

      Record additionally, in a `Deny Reason Verbatim:` block, the complete **source** text of the
      reason string passed to the last `Get-EpicWorktreeGateBlockDecision -Reason` occurrence,
      which is the final return of `Invoke-EpicWorktreeRemovalGateDecision`, exactly as it appears
      in the pre-change file including the `$worktreePath` token and any doubled quote characters.
      The earlier occurrence constructs the payload-anomaly reason and is not this block's subject;
      both reasons begin with the same `EPIC_WORKTREE_REMOVAL_BLOCKED` code token, so naming the
      occurrence rather than the token is what makes the recorded value unambiguous. That block is
      the reference value P3-T10 constructs its expected reason from, and P3-T3 compares against
      directly.

      Acceptance: the artifact records six anchor line numbers, the full match list for every
      pattern that matched more than once, the file's total line count, and a non-empty
      `Deny Reason Verbatim:` block, all produced by this run.

      `pwsh -NoProfile -Command "Select-String -Path .claude/hooks/enforce-epic-worktree-removal-gate.ps1 -Pattern 'Import-Module','AllowedMergeStatuses','worktreePath =','featureRecord =','Test-ParallelCheckpointAllowsWorktreeRemoval','Get-EpicWorktreeGateBlockDecision -Reason' | Select-Object LineNumber,Line"`

- [ ] [P0-T3] Re-derive the structural anchors in `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`
      and record them in `evidence/baseline/structural-anchors-parallel-gate.2026-09-06T23-09.md`
      with the four schema fields. Record the current line number of: the `Import-Module` statement,
      the `$script:AllowedMergeStatuses` assignment, the `$worktreePath` assignment inside
      `Invoke-ParallelWorktreeRemovalGateDecision`, the `$itemRecord` assignment, the
      `Test-ParallelWorktreeRemovalAllowed` call, and the final
      `Get-ParallelWorktreeGateBlockDecision` return.

      Apply the same multi-match rule as P0-T2, and expect the same shape: **three** of the six
      patterns match more than one line in the pre-change tree, so record every matching line
      number for those patterns and mark the anchor. For `AllowedMergeStatuses` the anchor is the
      `$script:` assignment; for `Test-ParallelWorktreeRemovalAllowed` the anchor is the **call**
      inside `Invoke-ParallelWorktreeRemovalGateDecision`, not the function definition; and for
      `Get-ParallelWorktreeGateBlockDecision -Reason` the anchor is the last occurrence, which is
      the function's final return.

      Record additionally, in a `Deny Reason Verbatim:` block, the complete **source** text of the
      reason string passed to the last `Get-ParallelWorktreeGateBlockDecision -Reason` occurrence,
      which is the final return of `Invoke-ParallelWorktreeRemovalGateDecision`, exactly as it
      appears in the pre-change file including the `$worktreePath` token and any doubled quote
      characters. The earlier occurrence constructs the payload-anomaly reason and is not this
      block's subject; both reasons begin with the same `PARALLEL_WORKTREE_REMOVAL_BLOCKED` code
      token, so naming the occurrence rather than the token is what makes the recorded value
      unambiguous. That block is the reference value P3-T10 constructs its expected reason from,
      and P3-T5 compares against directly.

      Acceptance: the artifact records six anchor line numbers, the full match list for every
      pattern that matched more than once, the file's total line count, and a non-empty
      `Deny Reason Verbatim:` block, all produced by this run.

      `pwsh -NoProfile -Command "Select-String -Path .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 -Pattern 'Import-Module','AllowedMergeStatuses','worktreePath =','itemRecord =','Test-ParallelWorktreeRemovalAllowed','Get-ParallelWorktreeGateBlockDecision -Reason' | Select-Object LineNumber,Line"`

- [ ] [P0-T4] Capture the pre-change line count of every file this work will change or create, into
      `evidence/baseline/line-counts.2026-09-06T23-09.md` with the four schema fields. The measured
      set is the two gate hooks, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`,
      `.claude/skills/cleanup-merged-worktrees/SKILL.md`, and
      `.claude/lib/hook-payload/HookPayload.psm1`.

      Record additionally the pre-change occurrence count of the token `396` and of the token
      `manifest-authorized removal` in `.claude/skills/cleanup-merged-worktrees/SKILL.md`. A
      fixed-string search that matches nothing prints no line and exits non-zero, so record an
      absence as the absence of output rather than as a printed zero. These two recorded
      before-states are what make P4-T2's presence assertion and P4-T4's absence assertion
      falsifiable.

      Acceptance: six numeric line counts recorded; the artifact records that
      `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` does not exist yet; the artifact
      records the `396` occurrence count as an integer; and the artifact records the
      `manifest-authorized removal` search as having printed no output line.

      `git grep -c -F "396" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`
      `git grep -c -F "manifest-authorized removal" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`

      `pwsh -NoProfile -Command "Get-ChildItem .claude/hooks/enforce-epic-worktree-removal-gate.ps1, .claude/hooks/enforce-parallel-worktree-removal-gate.ps1, tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1, tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1, .claude/skills/cleanup-merged-worktrees/SKILL.md, .claude/lib/hook-payload/HookPayload.psm1 | Select-Object FullName, @{ n = 'Lines'; e = { (Get-Content -LiteralPath $_.FullName).Count } }"`

- [ ] [P0-T5] Capture the baseline PowerShell **format** state, **running the formatter to
      convergence**. Record `git status --porcelain` into the artifact, run
      `mcp__drm-copilot__run_poshqc_format`, record `git status --porcelain` again, and repeat the
      pair until two consecutive porcelain records are identical. Write
      `evidence/baseline/poshqc-format-baseline.2026-09-06T23-09.md` with the four schema fields.

      `Invoke-PoshQCFormat` prints no summary line: it emits one line per discovered file, either
      `Formatted: <full path>` or `Already formatted: <full path>`. The observable difference
      between a repairing run and a clean run is therefore the presence of lines beginning with the
      literal `Formatted: `, not a summary string. This is a write-mode command whose exit code is
      identical on a clean run and on a repairing run, so the acceptance is a tree observation plus
      a recorded line inventory, not the exit code.

      The formatter's scan root is the whole repository root when no `ScanFolders` argument is
      supplied (`PoshQC.FileDiscovery.psm1:60-64`), and `$script:DefaultExcludedDirs`
      (`PoshQC.psm1:5-9`) excludes neither `.claude` nor `.codex`. An invocation in this task can
      therefore rewrite a file this plan pins as carrying no diff:
      `.claude/hooks/validate-bash.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`,
      `.claude/lib/hook-payload/HookPayload.psm1`,
      `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`, or any file under `scripts/bash/`.
      A formatter rewrite of any of those paths is a **blocking precondition**: record the path and
      the printed line in the `Pre-Existing Drift:` block, restore the file with `git checkout --`,
      and halt the plan at this task reporting remediation-required. Restoring the file and
      continuing is not an option, because P8-T1 requires the final format pass to print no
      `Formatted: ` line while AC-26, AC-29, and AC-30 require the same file to carry no diff, and
      a file that is currently unformatted cannot satisfy both. Run the convergence loop first and
      perform any restoration only **after** two consecutive identical porcelain records; restoring
      inside the loop changes the tree on every pass and prevents convergence.

      Acceptance: the artifact contains a `Porcelain Before:` block, a `Porcelain After:` block that
      is identical to it, a `Formatted Lines:` block listing every line of the final invocation's
      output that begins with the literal `Formatted: `, or the word `none`, a `Line Count:` integer
      recording how many lines the final invocation printed in total, and a `Pre-Existing Drift:`
      block listing every path any invocation in this task rewrote, together with the restoration
      and the halt when a pinned path is among them, or the word `none`.

      `git status --porcelain`

- [ ] [P0-T6] Capture the baseline PowerShell **analyze** state by running
      `mcp__drm-copilot__run_poshqc_analyze` and writing
      `evidence/baseline/poshqc-analyze-baseline.2026-09-06T23-09.md` with the four schema fields.
      `Invoke-PoshQCAnalyze` prints the finding count only on the failing path, so the clean-run and
      failing-run shapes differ and the artifact records whichever occurred. Acceptance:
      `Output Summary:` transcribes the result text verbatim. A clean run prints the sentence
      beginning `PSScriptAnalyzer passed: no findings under`, which the artifact records as finding
      count 0; a run with findings fails with a message of the form
      `PSScriptAnalyzer reported N issue(s).`, whose N the artifact records.
- [ ] [P0-T7] Capture the baseline PowerShell **test and coverage** state through the self-hosted
      PoshQC invocation, and write `evidence/baseline/poshqc-coverage-baseline.2026-09-06T23-09.md`
      with the four schema fields. `Output Summary:` must record these seven values, all produced by
      this run and none of them a placeholder:

      1. the total passed count and 2. the total failed count, both read from the single console
      totals line `Tests Passed: {0}, Failed: {1}, Skipped: {2}, Inconclusive: {3}, NotRun: {4}`;
      3. the passed count for `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`
      and 4. the passed count for
      `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`, each
      **derived** from the `testsuite` element in `artifacts/pester/pester-junit.xml` whose `name`
      attribute ends with that suite's file name, by the subtraction rule stated in the toolchain
      preamble, with that element's complete start tag transcribed into the artifact beside the
      derived count, because the element carries no `passed` attribute and the console output
      carries one totals line and no per-suite breakdown; 5. the overall coverage headline
      percentage, read from the single overall
      coverage line the run prints; and 6. and 7. the per-file line-coverage percentages for the two
      gate hooks, computed from the `sourcefile` entries in
      `artifacts/pester/powershell-coverage.koverage.xml` written by this run, recorded as decimals
      beside their paths, because the console output carries no per-file coverage table. Resolve
      each `sourcefile` entry to a repo-relative path by joining the enclosing `package` element's
      `name` to the `sourcefile` element's `name` with `/`.

      The two per-suite passed counts are the reference values P3-T11 compares against for the
      non-widening pin.

      The artifact must additionally carry a `Console Coverage Line:` block transcribing verbatim
      the single overall coverage line the run printed, and a `Coverage XML Shape:` block
      transcribing one complete `sourcefile` element from
      `artifacts/pester/powershell-coverage.koverage.xml` together with its enclosing `package`
      start tag, so every later coverage assertion in this plan is written against an observed
      format rather than an inferred one. Also record `git status --porcelain` before and after the
      run into the artifact.

      Acceptance: all seven values are integers or decimals, the `Console Coverage Line:` and
      `Coverage XML Shape:` blocks are both non-empty, the recorded total failed count is zero, and
      the artifact records for each of values 6 and 7 whether it is at least 85.
      **A non-zero baseline failed count is a blocking precondition**: the plan halts at this task
      and reports remediation-required rather than proceeding to Phase 1, because every later
      absolute-zero suite gate in this plan would otherwise be unsatisfiable for a reason this
      change did not cause. A value below 85 for value 6 or for value 7 is recorded as a
      pre-existing coverage shortfall on that gate hook, and the plan halts at this task reporting
      remediation-required, because `spec.md` AC-25 requires that file to reach 85 and P8-T5
      asserts it, so a shortfall this change did not cause would otherwise surface only after every
      implementation phase has run.

      `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"`

- [ ] [P0-T8] Capture the baseline push-down and no-Python guard state into
      `evidence/baseline/delivery-guards-baseline.2026-09-06T23-09.md` with the four schema fields,
      running `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`,
      `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, and
      `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.

      Record additionally whether `.claude/state/` exists at baseline and, if
      `test_push_down_claude_resource_contracts.py` fails, whether every reported missing path is
      under `.claude/state/`. That directory is gitignored (`.gitignore:68`) and is written during
      execution by `persist-session-id.ps1:161` and `enforce-powershell-batch-budget.ps1:366`,
      registered as hooks at `.claude/settings.json:84` and `:144`, while the enumeration at
      `test_push_down_claude_resource_contracts.py:39-48` walks the whole `.claude` tree with
      `rglob("*")` and the payload comparison at `:106-131` exempts only
      `.claude/settings.local.json` and `.claude/agent-memory/**`. A baseline failure whose
      reported paths all sit under `.claude/state/` is pre-existing, is tracked separately, and is
      out of scope for this change; a baseline failure reporting any other path is a **blocking
      precondition** and the plan halts at this task. This plan's own batch-reset tasks re-create
      that state file after each reset, so the condition recurs later and P6-T6 and P8-T7 are
      written against the set recorded here.

      Acceptance: `Output Summary:` records a pass or fail verdict and a numeric test count for
      each of the three suites, records whether `.claude/state/` exists, and, for any
      `test_push_down_claude_resource_contracts.py` failure, records the complete list of reported
      paths so a later task can compare against it.
- [ ] [P0-T9] Record the anchored base ref for every no-diff acceptance condition in this plan into
      `evidence/baseline/no-diff-base-ref.2026-09-06T23-09.md` with the four schema fields. Later
      tasks express the comparison as `git diff --merge-base main`, which compares the merge base of
      `main` and `HEAD` against the **working tree**; this task records the resolved merge-base SHA
      so that comparison point is auditable. Acceptance: the artifact records the resolved
      merge-base commit SHA and the current `HEAD` SHA, both produced by this run.

      `git merge-base main HEAD`

---

### Phase 1 — Manifest Module And Its Unit Suite (Batch A)

Batch A touches 1 production PowerShell file and 1 test PowerShell file, within the 3-and-3 cap.

- [ ] [P1-T1] Create `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` carrying only the
      module header, the manifest path constant whose value is
      `artifacts/orchestration/cleanup-worktrees-manifest.json`, the script-scope constant
      `AllowedRemovalDispositions` whose value is exactly the single member `SAFE_TO_DELETE`, and
      the script-scope constant `AuthorizedBranchStates` whose value is exactly `NOT_MERGED` and
      `HAS_UNIQUE_RESIDUALS`, following the `$script:AllowedMergeStatuses` precedent in both gate
      hooks. The file contains no Python invocation and no `Invoke-Expression`.

      `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` discovers every
      `.claude/lib/**/*.psm1` from disk with `Get-ChildItem -Recurse` and never restates the module
      list, so the new module enters that suite's scope the moment it is written and must keep all
      **five** of its convention properties green from the first save. Four of the five iterate the
      whole discovered set and therefore take the new module as a subject directly; the fifth,
      `It 'leaves the caller error preference unchanged after import'`, imports only the first
      discovered module, so it is named in the acceptance below as a regression pin rather than as
      a property the new module is the subject of. Author the file to these requirements:

      - it carries a `Set-StrictMode -Version Latest` line, and the line immediately following it is
        `$ErrorActionPreference = 'Stop'`;
      - every column-0 `Import-Module` line contains `-ErrorAction Stop`;
      - the leading comment-based-help block that precedes the `Set-StrictMode` line contains the
        literal token `imports its siblings with -ErrorAction Stop`;
      - the file is at most 500 lines.

      Acceptance: the file exists, `git status --porcelain` lists it as untracked or added, and the
      named tests
      `It 'sets the fail-fast error preference at module scope in every discovered module'`,
      `It 'guards every load-time sibling import with an explicit stop preference'`,
      `It 'states the fail-fast convention in the module help block'`,
      `It 'leaves the caller error preference unchanged after import'`, and
      `It 'keeps every claude library module within the five hundred line limit'` in
      `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` pass with the new module in the
      discovered set.

      `git status --porcelain -- .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`

- [ ] [P1-T2] Add the injectable read seam `Get-CleanupWorktreeManifestContent` and the injectable
      clock seam `Get-CleanupWorktreeManifestUtcNow` to
      `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`, each an advanced function with
      `CmdletBinding()`, following the seam precedent `Get-EpicWorktreeGateCheckpointContent`. The
      read seam returns the manifest file's raw text or `$null` when the file is absent; the clock
      seam returns the current UTC time and is the only wall-clock read in the module. Acceptance:
      both functions are exported by the module and each is resolvable after
      `Import-Module .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 -Force`.
- [ ] [P1-T3] Create `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`,
      creating the `cleanup-manifest` directory so the suite mirrors the production module path.
      The suite carries the suite header, the module import, the two seam mocks
      `Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest'`
      and `Mock -CommandName Get-CleanupWorktreeManifestUtcNow -ModuleName 'CleanupWorktreeManifest'`,
      and the two vocabulary-constant tests
      `It 'exposes exactly SAFE_TO_DELETE as the allowed removal disposition'` and
      `It 'exposes exactly NOT_MERGED and HAS_UNIQUE_RESIDUALS as the authorized branch states'`.
      The suite sits one directory deeper than `tests/scripts/claude-lib/`, so it resolves the
      repository root four levels up from `$PSScriptRoot`, matching
      `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1:18`. Every fixture is a literal
      JSON string injected through the mocked read seam and every clock value through the mocked
      clock seam. No test creates, writes, or reads a temporary file. This task creates the suite
      file before any later Phase 1 task asserts a test inside it. Acceptance: both named tests are
      present in the run results with a passed outcome. (Satisfies AC-19 and AC-20.)
- [ ] [P1-T4] Add `ConvertTo-CleanupWorktreeManifestNormalizedPath` to the module, implementing the
      `spec.md` condition-5 normalization exactly: replace backslashes with forward slashes, then
      trim a trailing slash. Add the named test
      `It 'normalizes trailing-slash, Windows-separator, and POSIX paths to one value'` to
      `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`. Acceptance:
      that named test is present in the run results with a passed outcome.
- [ ] [P1-T5] Add `Find-CleanupWorktreeManifestRemovalRecord` to the module. It parses the raw
      manifest text with a fail-closed `try`/`catch` that yields `$null`, iterates the `removals`
      array, skips with `continue` any record whose `worktree_path` key is absent, and returns the
      **first** record whose normalized `worktree_path` equals the normalized target. Add the named
      tests `It 'returns the first matching removals record'` and
      `It 'skips a record whose worktree_path key is absent and continues the scan'` to
      `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`. Acceptance:
      both named tests are present in the run results with a passed outcome.
- [ ] [P1-T6] Add `Test-CleanupWorktreeManifestAuthorizesRemoval` to the module, implementing
      `spec.md` allow-predicate conditions 1 through 9 in the stated order: parse, `tool` equals
      `cleanup-merged-worktrees` and `schema_version` equals `1`, freshness against the injected
      clock with a 24-hour bound and no future timestamp, `removals` present and a non-empty array,
      first normalized path match, `removal_disposition` in `AllowedRemovalDispositions`, non-empty
      `evidence`, `verdict` in vocabulary and neither `GENUINELY_NEW` nor `STILL_RELEVANT`, and
      `branch_state` in `AuthorizedBranchStates`. The function returns `$true` or `$false` and
      raises nothing. It never reads the `preserved_files` array. Add the named test
      `It 'authorizes a fully conforming manifest record'` to
      `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`. Acceptance:
      that named test is present in the run results with a passed outcome.
- [ ] [P1-T7] Add `Test-CleanupManifestCheckpointCoversPath` to the module, implementing `spec.md`
      condition 10's presence test. It accepts a parsed checkpoint object, the name of the record
      array to scan, and the target path, and returns `$true` when any record in that array has a
      `worktree_path` whose normalized value equals the normalized target, **regardless of that
      record's `merge_status`**. Add the named test
      `It 'reports coverage for a checkpoint record whose merge_status is outside the allow-set'`
      to `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`. This is the
      behavior AC-03 and AC-04 depend on. Acceptance: that named test is present in the run results
      with a passed outcome.
- [ ] [P1-T8] Run the full PowerShell suite through the self-hosted PoshQC invocation and record
      `evidence/qa-gates/batch-a-suite.2026-09-06T23-09.md` with the four schema fields.
      Acceptance: `EXIT_CODE: 0`, and `Output Summary:` records the passed and failed counts as
      integers with a failed count of zero, read from the console totals line. This gate is
      satisfiable because Phase 1 adds only passing tests; the deliberately failing tests are added
      in Phase 2 and made passing in Phase 3.

      `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"`

- [ ] [P1-T9] Confirm the new module keeps the no-Python guard green by running
      `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` and writing
      `evidence/qa-gates/no-python-guard-after-module.2026-09-06T23-09.md` with the four schema
      fields. Acceptance: the suite passes and its named test `It 'ships an empty allowlist'` is
      present with a passed outcome. (Contributes to AC-23.)
- [ ] [P1-T10] Confirm `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` and
      `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1` are each at most
      500 lines and record both counts in
      `evidence/qa-gates/line-counts-batch-a.2026-09-06T23-09.md` with the four schema fields.
      Acceptance: both recorded counts are at most 500. (Contributes to AC-27.)

---

### Phase 2 — Fail-Before Regression Tests Against The Unfixed Hooks (Batch B)

Batch B touches 0 production PowerShell files and 2 test PowerShell files. Every test task in this
phase is expected to fail; no green-suite gate may be asserted before Phase 3.

- [ ] [P2-T1] Reset the PowerShell batch-budget counter before Batch B begins, by deleting the
      current session's `.claude/state/powershell-batch-budget` state file, and record the reset in
      `evidence/qa-gates/batch-b-budget-reset.2026-09-06T23-09.md` with the four schema fields.
      `.claude/hooks/enforce-powershell-batch-budget.ps1` scopes the 3-production and 3-test cap to
      the session and counts distinct paths cumulatively, so a batch boundary is not observed unless
      the counter is reset. The state-file name embeds the resolved session id, so the artifact
      records the resolved path rather than a token containing a placeholder. Acceptance: the
      artifact records the resolved state-file path and that the file is absent after the reset.
- [ ] [P2-T2] `[expect-fail]` Add to `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`
      the named test `It 'allows removal when a fresh manifest record authorizes the target'`. It
      imports `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`, mocks
      `Get-CleanupWorktreeManifestContent` and `Get-CleanupWorktreeManifestUtcNow` with
      `-ModuleName 'CleanupWorktreeManifest'` to supply a manifest satisfying conditions 1 through
      10, mocks both existing checkpoint seams to return no matching record, and asserts
      `Invoke-EpicWorktreeRemovalGateDecision` returns `permissionDecision` equal to `allow`.
      Acceptance: the named test is present in the file.
- [ ] [P2-T3] `[expect-fail]` Add to `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`
      the named test `It 'allows removal when a fresh manifest record authorizes the target'`, built
      the same way, asserting `Invoke-ParallelWorktreeRemovalGateDecision` returns
      `permissionDecision` equal to `allow`. Acceptance: the named test is present in the file.
- [ ] [P2-T4] `[expect-fail]` Run both gate suites against the **unfixed** hooks and record the
      failing output in `evidence/regression-testing/fail-before-manifest-allow.2026-09-06T23-09.md`
      with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 2`, and `Output Summary:`.

      The run settings set `Run.Exit = $true`
      (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:4`) and `Invoke-PoshQCTest` does
      not override it, so the process exit code equals the Pester failed count. P0-T7 established a
      baseline failed count of zero as a blocking precondition, so exactly the two tests added by
      P2-T2 and P2-T3 fail and the expected exit code is 2. An observed exit code other than 2
      means the run is not the expected fail-before state; record the observed value and the
      failing test names, and do not proceed to Phase 3 until the discrepancy is explained.

      `Output Summary:` must record that both instances of
      `It 'allows removal when a fresh manifest record authorizes the target'` failed, and must
      transcribe the observed `permissionDecision` value each one received. Acceptance: the artifact
      records exactly two failures with that test name, and the observed decision recorded for each
      is `deny`, which proves the failure is the missing manifest branch rather than a missing
      command or a fixture error. (Satisfies the fail-before half of AC-01 and AC-02.)

      `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"`

---

### Phase 3 — Gate Hook Manifest Branches And Deny Pins (Batch C)

Batch C touches 2 production PowerShell files and 3 test PowerShell files, at the 3-and-3 cap.
Every insertion point below is a structural anchor; use the line numbers recorded by P0-T2 and
P0-T3 for navigation only.

Every `git diff` in this phase is anchored with `--merge-base main`, which compares the merge base
of `main` and `HEAD` against the **working tree** and therefore reports uncommitted edits. The
three-dot form `main...HEAD` diffs the merge base against the **commit** `HEAD`, so it reports
nothing until the work is committed and this plan defines no commit point.

- [ ] [P3-T1] Reset the PowerShell batch-budget counter before Batch C begins, by deleting the
      current session's `.claude/state/powershell-batch-budget` state file, and record the reset in
      `evidence/qa-gates/batch-c-budget-reset.2026-09-06T23-09.md` with the four schema fields.
      `.claude/hooks/enforce-powershell-batch-budget.ps1` scopes the 3-production and 3-test cap to
      the session and counts distinct paths cumulatively, so a batch boundary is not observed unless
      the counter is reset. The state-file name embeds the resolved session id, so the artifact
      records the resolved path rather than a token containing a placeholder. Acceptance: the
      artifact records the resolved state-file path and that the file is absent after the reset.
- [ ] [P3-T2] In `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, add one `Import-Module`
      statement for `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`, placed immediately
      after the existing `Import-Module` for `HookPayload.psm1`, and one script-scope constant
      holding the manifest path, placed immediately after the `$script:AllowedMergeStatuses`
      assignment. No other statement in the file changes. Acceptance: the anchored diff of this file
      reports **zero deleted lines** and at least two added lines, and `git status --porcelain`
      lists the file as modified. The deleted-line count is the falsifiable part and it holds
      cumulatively, so a later Phase 3 task adding further lines to the same file does not
      invalidate it.

      `git diff --numstat --merge-base main -- .claude/hooks/enforce-epic-worktree-removal-gate.ps1`
      `git status --porcelain -- .claude/hooks/enforce-epic-worktree-removal-gate.ps1`

- [ ] [P3-T3] In `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, insert the manifest
      authorization branch inside `Invoke-EpicWorktreeRemovalGateDecision`, strictly **after** the
      `$worktreePath` assignment and the two existing positive-predicate returns, and **before** the
      existing `Get-EpicWorktreeGateBlockDecision` return. The branch returns the existing allow
      decision only when `Test-CleanupManifestCheckpointCoversPath` reports `$false` for the epic
      checkpoint's `features` array **and** `$false` for the parallel checkpoint's `items` array,
      **and** `Test-CleanupWorktreeManifestAuthorizesRemoval` reports `$true`. In every other state
      control falls through to the unchanged final deny. Acceptance: the file's final statement in
      that function is still the unchanged `Get-EpicWorktreeGateBlockDecision` return, and the deny
      reason string in this file is byte-identical to the `Deny Reason Verbatim:` block recorded by
      P0-T2, compared directly in this task.
- [ ] [P3-T4] In `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, add one
      `Import-Module` statement for the new module immediately after the existing `Import-Module`
      for `HookPayload.psm1`, and one script-scope constant holding the manifest path immediately
      after the `$script:AllowedMergeStatuses` assignment. Acceptance: the anchored diff of this
      file reports **zero deleted lines** and at least two added lines, and
      `git status --porcelain` lists the file as modified. The deleted-line count holds cumulatively
      for the same reason stated in P3-T2.

      `git diff --numstat --merge-base main -- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1`
      `git status --porcelain -- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1`

- [ ] [P3-T5] In `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, insert the manifest
      authorization branch inside `Invoke-ParallelWorktreeRemovalGateDecision`, strictly after the
      `$worktreePath` assignment and the existing positive-predicate return, and before the existing
      `Get-ParallelWorktreeGateBlockDecision` return. The branch returns the existing allow decision
      only when `Test-CleanupManifestCheckpointCoversPath` reports `$false` for the parallel
      checkpoint's `items` array **and** `Test-CleanupWorktreeManifestAuthorizesRemoval` reports
      `$true`.

      `spec.md` condition 10 names both the epic `features[]` array and the parallel `items[]`
      array. The parallel hook defines only `Get-ParallelWorktreeRemovalGateCheckpointContent` and
      has no epic-checkpoint seam, and adding one would exceed the `spec.md` D6 scope boundary, so
      the parallel gate's exclusion check covers the `items` array only. AC-03 is satisfied by the
      epic gate and AC-04 by the parallel gate, so no criterion depends on the parallel gate
      reading the epic checkpoint. This narrowing is recorded here rather than left implicit.

      Acceptance: the function's final statement is still the unchanged
      `Get-ParallelWorktreeGateBlockDecision` return, and the deny reason string in this file is
      byte-identical to the `Deny Reason Verbatim:` block recorded by P0-T3, compared directly in
      this task.
- [ ] [P3-T6] Add to `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` the
      named test `It 'denies a manifest-covered removal whose target an epic checkpoint records'`,
      supplying a manifest record satisfying conditions 1 through 9 for the target **and** an epic
      checkpoint `features` record for the same normalized target whose `merge_status` is outside
      the allow-set. Acceptance: the named test passes, `permissionDecision` is `deny`, and the
      reason begins with the token `EPIC_WORKTREE_REMOVAL_BLOCKED`. (Satisfies AC-03.)
- [ ] [P3-T7] Add to `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`
      the named test `It 'denies a manifest-covered removal whose target a parallel checkpoint records'`,
      supplying a manifest record satisfying conditions 1 through 9 **and** a parallel checkpoint
      `items` record for the same normalized target whose `merge_status` is outside the allow-set.
      Acceptance: the named test passes, `permissionDecision` is `deny`, and the reason begins with
      the token `PARALLEL_WORKTREE_REMOVAL_BLOCKED`. (Satisfies AC-04.)
- [ ] [P3-T8] Re-run the full PowerShell suite through the self-hosted PoshQC invocation and
      confirm `It 'allows removal when a fresh manifest record authorizes the target'` in
      `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` now passes.
      Record the pass-after result in
      `evidence/regression-testing/pass-after-manifest-allow-epic.2026-09-06T23-09.md` with the four
      schema fields. Acceptance: the named test is present with a passed outcome, and the artifact
      records the suite's failed count as an integer read from, and its passed count as an integer
      derived from, the `testsuite` element in `artifacts/pester/pester-junit.xml` whose `name`
      attribute ends with `enforce-epic-worktree-removal-gate.Tests.ps1`, by the subtraction rule
      stated in the toolchain preamble and with that element's complete start tag transcribed into
      the artifact, because the element carries no `passed` attribute and the console output
      carries one totals line and no per-suite breakdown. (Satisfies AC-01.)

      The `testsuite` element read here must be the one written by this task's run. A
      `pester-junit.xml` recording the P2-T4 fail-before state is on disk when this task
      begins, so a derivation performed without re-running through the run settings would
      report that earlier run's counts.

      `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"`

- [ ] [P3-T9] Re-run the full PowerShell suite through the self-hosted PoshQC invocation and
      confirm `It 'allows removal when a fresh manifest record authorizes the target'` in
      `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` now
      passes. Record the pass-after result in
      `evidence/regression-testing/pass-after-manifest-allow-parallel.2026-09-06T23-09.md` with the
      four schema fields. Acceptance: the named test is present with a passed outcome, and the
      artifact records the suite's failed count as an integer read from, and its passed count as an
      integer derived from, the `testsuite` element in `artifacts/pester/pester-junit.xml` whose
      `name` attribute ends with `enforce-parallel-worktree-removal-gate.Tests.ps1`, by the
      subtraction rule stated in the toolchain preamble and with that element's complete start tag
      transcribed into the artifact, because the element carries no `passed` attribute.
      (Satisfies AC-02.)

      The `testsuite` element read here must be the one written by this task's run. A
      `pester-junit.xml` written by the P3-T8 run is on disk when this task begins, so a
      derivation performed without re-running through the run settings would report that
      earlier run's counts rather than the state this task asserts.

      `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"`

- [ ] [P3-T10] Add a named test to each gate suite asserting the deny reason string is unchanged
      character for character: `It 'emits the unchanged epic block reason'` and
      `It 'emits the unchanged parallel block reason'`. Each test constructs the expected reason
      from the `Deny Reason Verbatim:` block recorded from the pre-change tree by P0-T2 for the
      epic gate and by P0-T3 for the parallel gate, applying the two substitutions the PowerShell
      double-quoted string performs at run time: `$worktreePath` is replaced by the removal target
      the test supplies, and each doubled quote is replaced by a single quote character. It then
      asserts the reason the gate returns for an unauthorized removal is character-for-character
      equal to that constructed value. The recorded block is source text and the returned reason is
      expanded text, so a direct comparison of the two would never be equal; the substitution is
      what makes the assertion both meaningful and falsifiable. Acceptance:
      both named tests pass. (Satisfies AC-05.)
- [ ] [P3-T11] Verify the non-widening property: every pre-existing `It` in both gate suites passes
      unchanged, with no assertion weakened and no fixture altered. Record the verification in
      `evidence/qa-gates/non-widening-pin.2026-09-06T23-09.md` with the four schema fields,
      including the anchored diff of both suites showing additions only. Acceptance: the anchored
      diff reports zero deleted lines in both suite files, and the artifact records the passed count
      for each suite as an integer, **derived** from the `testsuite` element in
      `artifacts/pester/pester-junit.xml` whose `name` attribute ends with that suite's file name
      by the subtraction rule stated in the toolchain preamble and with that element's complete
      start tag transcribed into the artifact, that is not lower than the corresponding per-suite
      baseline passed count P0-T7 derived for that same suite from the same element by the same
      rule. The two counts are comparable only because both sides use the one derivation rule; the
      element carries no `passed` attribute either side could read directly. (Satisfies AC-06.)

      The per-suite counts are derived from the `pester-junit.xml` this task's run writes, not
      from the file left by an earlier task's run.

      `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"`
      `git diff --numstat --merge-base main -- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`
      `git status --porcelain -- tests/scripts/claude-hooks`

- [ ] [P3-T12] Add the named test `It 'keeps the merge_status allow-set unchanged'` to each gate
      suite, asserting `$script:AllowedMergeStatuses` still equals exactly the two members `merged`
      and `worktree_removed`. Acceptance: both named tests pass. (Satisfies AC-07.)
- [ ] [P3-T13] Create `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`,
      dot-sourcing the epic gate hook in one `Describe` block and the parallel gate hook in a
      separate `Describe` block, each with its own `BeforeAll`, so the two hooks' script-scope state
      does not collide in one scope. Both blocks import the manifest module and mock
      `Get-CleanupWorktreeManifestContent` and `Get-CleanupWorktreeManifestUtcNow` with
      `-ModuleName 'CleanupWorktreeManifest'`. The epic block additionally mocks **both** of that
      hook's checkpoint seams, `Get-EpicWorktreeGateCheckpointContent` and
      `Get-EpicWorktreeGateParallelCheckpointContent`, as the existing epic suite's docstring
      requires of every deny-expecting test; the parallel block additionally mocks that hook's
      single checkpoint seam, `Get-ParallelWorktreeRemovalGateCheckpointContent`. The epic block
      therefore mocks four commands and the parallel block three. Add the condition-1 cases:
      manifest file absent, raw text
      null or whitespace, and `ConvertFrom-Json` throwing. Acceptance: each case has a named `It`
      and each asserts `deny` from **both** gates. (Satisfies AC-08.)
- [ ] [P3-T14] Add the condition-2 cases to
      `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`: `tool` absent, `tool`
      set to another value, `schema_version` absent, `schema_version` non-integer, and
      `schema_version` equal to `2`. Acceptance: each case has a named `It` asserting `deny` from
      both gates. (Satisfies AC-09.)
- [ ] [P3-T15] Add the condition-3 cases: `generated_at` absent, unparseable, in the future,
      exactly at the 24-hour bound, and beyond the 24-hour bound, every one driven through the
      mocked clock seam with no wall-clock read. Acceptance: the absent, unparseable, future, and
      beyond-bound cases each assert `deny` from both gates, and the at-bound case has its own named
      `It` asserting its decision explicitly rather than by implication. (Satisfies AC-10.)
- [ ] [P3-T16] Add the condition-4 cases: `removals` absent, `removals` non-array, and `removals`
      empty. Acceptance: each case has a named `It` asserting `deny` from both gates. (Satisfies
      AC-11.)
- [ ] [P3-T17] Add the condition-5 cases: a trailing-slash target, a quoted target, and a
      Windows-separator target each compare equal to a recorded POSIX `worktree_path` and are
      allowed; a non-matching path denies; and a record whose `worktree_path` key is absent is
      skipped while the scan continues to a later matching record. Acceptance: each case has a named
      `It` and each asserts the stated decision from both gates. (Satisfies AC-12.)
- [ ] [P3-T18] Add the condition-6 cases: `removal_disposition` absent, set to `PRESERVE`, and set
      to a value outside the single-member allowed set. Acceptance: each case has a named `It`
      asserting `deny` from both gates. (Satisfies AC-13.)
- [ ] [P3-T19] Add the condition-7 cases: `evidence` absent, empty string, and whitespace-only.
      Acceptance: each case has a named `It` asserting `deny` from both gates. (Satisfies AC-14.)
- [ ] [P3-T20] Add the condition-8 cases: `verdict` absent, out of vocabulary, `GENUINELY_NEW`, and
      `STILL_RELEVANT`. Acceptance: each case has a named `It` asserting `deny` from both gates.
      (Satisfies AC-15.)
- [ ] [P3-T21] Add the condition-9 cases: `branch_state` absent, `PROTECTED_CURRENT`, `MERGED_CLEAN`,
      `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, and a value outside the vocabulary each deny;
      and `NOT_MERGED` and `HAS_UNIQUE_RESIDUALS` each allow when conditions 1 through 8 and 10
      hold. Acceptance: each case has a named `It` asserting the stated decision from both gates.
      (Satisfies AC-16.)
- [ ] [P3-T22] Add the named test `It 'never reads preserved_files'` to
      `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`, comparing the
      decision both gates return for a manifest whose `preserved_files` array is malformed against
      the decision they return for the same manifest with `preserved_files` set to an empty array.
      Acceptance: the named test passes and asserts the two decisions are equal for both gates.
      (Satisfies AC-17.)
- [ ] [P3-T23] Add the named test `It 'resolves duplicate worktree_path records on the first match'`
      to `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`: two `removals`
      records sharing a normalized `worktree_path`, first non-authorizing and second authorizing,
      returns `deny`; with the order reversed, returns `allow`. Acceptance: the named test passes
      and covers both orderings. (Satisfies AC-18.)
- [ ] [P3-T24] Run the full PowerShell suite through the self-hosted PoshQC invocation and record
      `evidence/qa-gates/batch-c-suite.2026-09-06T23-09.md` with the four schema fields. Acceptance:
      `EXIT_CODE: 0`, and `Output Summary:` records the passed and failed counts as integers with a
      failed count of zero, read from the console totals line. This is the first green-suite gate
      that runs after the Phase 2 expect-fail additions; both of those tests are made passing by
      P3-T3 and P3-T5, which run before this task, so the gate is satisfiable at the point it runs.

      `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"`

- [ ] [P3-T25] Confirm both gate hooks, both existing gate suites, and
      `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` are each at most 500
      lines, recording all five counts in
      `evidence/qa-gates/line-counts-batch-c.2026-09-06T23-09.md` with the four schema fields.

      Two split contingencies apply, and both open a new batch. Reset the PowerShell batch-budget
      counter before writing any split file, using the procedure in P3-T1, and record the reset in
      this task's artifact.

      1. If `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` would exceed
         500 lines, split the conditions 6 through 9 cases into
         `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrixValues.Tests.ps1` and record
         the split in the artifact.
      2. The existing gate suites stand at 428 and 392 lines, and Phase 2 and Phase 3 add four
         named tests plus JSON fixtures to each. If either existing gate suite would exceed 500
         lines, move that gate's AC-05 reason test and its AC-07 allow-set test into
         `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate-manifest-pins.Tests.ps1` or
         `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate-manifest-pins.Tests.ps1`
         respectively, keeping the test names unchanged, and record the move in the artifact. Moving
         these two tests is permitted because AC-05 and AC-07 require the named tests to exist and
         pass, not to reside in a particular file.

      Acceptance: every recorded count is at most 500, and the artifact records each split or move
      performed together with the counter reset that preceded it, or records that none was needed.
      (Contributes to AC-27.)

---

### Phase 4 — Skill Text Changes (Batch D, Markdown Only)

Batch D changes only `.claude/skills/cleanup-merged-worktrees/SKILL.md`, which is Markdown and
consumes no PowerShell change budget, so this phase opens no new batch and needs no counter reset.
`.claude/rules/general-code-change.md` exempts Markdown from the 500-line cap.

- [ ] [P4-T1] Add a manifest-write step to `.claude/skills/cleanup-merged-worktrees/SKILL.md`
      naming the path `artifacts/orchestration/cleanup-worktrees-manifest.json` and specifying the
      top-level fields, the `removals` record fields, and the `preserved_files` record fields
      exactly as `spec.md` defines them, so a reader of the skill can produce a conforming document
      without reading the hook source. Acceptance: a fixed-string search of the file finds the
      token `cleanup-worktrees-manifest.json` at least once, and finds each of the tokens
      `removal_disposition`, `branch_state`, `preserved_files`, `schema_version`, `generated_at`,
      and `run_id` at least once. (Satisfies AC-32.)

      `git grep -c -F "cleanup-worktrees-manifest.json" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`

- [ ] [P4-T2] Amend step 9 of the Dirty Worktree Triage Procedure in
      `.claude/skills/cleanup-merged-worktrees/SKILL.md` to explicitly authorize a per-worktree
      removal, issued as its own Bash tool call, for a `SAFE_TO_DELETE` verdict on a `NOT_MERGED`
      or `HAS_UNIQUE_RESIDUALS` worktree that the manifest covers, and to carry the token
      `manifest-authorized removal`. Place the authorization inside the existing step-9 paragraph
      that today authorizes clearing the dirty working tree and deleting a disposable branch.

      Acceptance: a fixed-string search of the file finds the token `manifest-authorized removal`
      at least once, and the anchored diff shows that token added inside the numbered step 9. The
      pre-change file contains no occurrence of that token, as P0-T4 records, so the search is
      falsifiable. Author the sentence so the token `manifest-authorized removal` sits entirely on
      one source line. `SKILL.md` is hard-wrapped prose and the search is line-oriented, so a token
      split across a line break returns zero matches even though the text is present.
      Asserting the three vocabulary tokens instead would not be falsifiable: step 9
      already contains `SAFE_TO_DELETE`, `NOT_MERGED`, and `HAS_UNIQUE_RESIDUALS` before this edit.
      (Satisfies AC-33.)

      `git grep -c -F "manifest-authorized removal" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`
      `git diff --merge-base main -- .claude/skills/cleanup-merged-worktrees/SKILL.md`

- [ ] [P4-T3] Add the entry `Bash(git worktree remove *)` to the `allowed-tools` list in the YAML
      frontmatter of `.claude/skills/cleanup-merged-worktrees/SKILL.md`, immediately after the
      existing `Bash(git worktree list*)` entry, with no force spelling, and restate the existing
      force-flag prohibition adjacent to the new step-9 action so the grant is not read as
      permitting a force flag. Restate the prohibition using the existing wording at
      `SKILL.md:236-237`, which names the flag only as "a force flag", rather than a spelling that
      names the flag literally, because the second acceptance search asserts that the file contains
      no occurrence of the flag spelling and a restatement naming it would defeat that search.
      Acceptance: the first search below prints a count of `1` for the
      file, the second search prints no output line at all for the file, and the restated
      prohibition appears within the step-9 text. A fixed-string search that matches nothing prints
      no line and exits non-zero, so the acceptance is stated as an absence of output rather than as
      a printed zero. (Satisfies AC-34.)

      `git grep -c -F "Bash(git worktree remove *)" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`
      `git grep -c -F "worktree remove --force" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`

- [ ] [P4-T4] Replace the hard-coded run number in the pr-author handoff paragraph of
      `.claude/skills/cleanup-merged-worktrees/SKILL.md` with an instruction, per `spec.md` D9. The
      replacement text instructs use of the GitHub issue number the run executes under when one
      exists, defers to `.claude/skills/pr-author/SKILL.md` for the body-file and receipt contract
      rather than restating a value, and for the no-issue-number case states that the identifier is
      an arbitrary run-scoped identifier chosen by the pr-author agent, that it is not a PR number,
      and that the only requirement is agreement between the body-file path, the receipt's `number`
      field, and the body bytes. Acceptance: the fixed-string search for the token `396` below
      prints no output line at all for the file, and the replacement paragraph names
      `.claude/skills/pr-author/SKILL.md`. The pre-change file contains that token exactly once, as
      P0-T4 records, so the search is falsifiable: it prints a line before this task and prints none
      after it. (Satisfies AC-35.)

      `git grep -c -F "396" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`

- [ ] [P4-T5] Record the accepted indirection residual in
      `.claude/skills/cleanup-merged-worktrees/SKILL.md` using the posture `spec.md` D8 requires: a
      policy-level integrity check that prevents accidental bypass and requires a deliberate,
      documented act to circumvent, and that is not a cryptographic or security boundary. The text
      must not claim the indirection is closed. Acceptance: the search below prints a count of at
      least `1` for the file, and the added paragraph contains no sentence asserting that the
      indirection is prevented, blocked, or closed. The asserted token is the short single-line form
      `cryptographic or security boundary` rather than a longer phrase, because a longer phrase
      wraps in the source document and a line-oriented search would then return zero matches even
      though the text is present. Author the sentence so that token sits entirely on one source
      line. `SKILL.md` is hard-wrapped prose and the search is line-oriented, so a token split
      across a line break returns zero matches even though the text is present. (Satisfies AC-36.)

      `git grep -c -F "cryptographic or security boundary" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`

- [ ] [P4-T6] Record the Phase 4 skill-text verification results in
      `evidence/qa-gates/skill-text-verification.2026-09-06T23-09.md` with `Timestamp:`,
      `Command:`, `EXIT_CODE:`, and `Output Summary:`. Re-run the searches named in P4-T1
      through P4-T5 and transcribe each command with its exit code and its printed output, or
      the absence of output where the acceptance is an absence of output. A fixed-string search
      that matches nothing prints no line and exits non-zero, so an absence is recorded as the
      absence of a printed line rather than as a printed zero. `Output Summary:` carries one row
      per criterion, naming the identifier, the search that verifies it, and the observed result.

      Acceptance: the artifact carries five rows, one each for `AC-32`, `AC-33`, `AC-34`,
      `AC-35`, and `AC-36`; the `AC-35` row records that the `396` search printed no output
      line; the `AC-34` row records that the `Bash(git worktree remove *)` search printed a
      count of `1` and that the `worktree remove --force` search printed no output line; and the
      `AC-32`, `AC-33`, and `AC-36` rows each record a count of at least `1`. This artifact is
      the evidence identifier P8-T8's traceability record names for `AC-32` through `AC-36`.

      `git grep -c -F "cleanup-worktrees-manifest.json" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`
      `git grep -c -F "manifest-authorized removal" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`
      `git grep -c -F "Bash(git worktree remove *)" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`
      `git grep -c -F "worktree remove --force" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`
      `git grep -c -F "396" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`
      `git grep -c -F "cryptographic or security boundary" -- .claude/skills/cleanup-merged-worktrees/SKILL.md`

---

### Phase 5 — PowerShell Mirrors (Batch E)

Batch E touches exactly 3 production PowerShell files, at the cap. Parity is UTF-8 text equality,
not byte equality, per `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.

- [ ] [P5-T1] Reset the PowerShell batch-budget counter before Batch E begins, by deleting the
      current session's `.claude/state/powershell-batch-budget` state file, and record the reset in
      `evidence/qa-gates/batch-e-budget-reset.2026-09-06T23-09.md` with the four schema fields.
      `.claude/hooks/enforce-powershell-batch-budget.ps1` scopes the 3-production and 3-test cap to
      the session and counts distinct paths cumulatively, so a batch boundary is not observed unless
      the counter is reset. The state-file name embeds the resolved session id, so the artifact
      records the resolved path rather than a token containing a placeholder. Acceptance: the
      artifact records the resolved state-file path and that the file is absent after the reset.
- [ ] [P5-T2] Mirror `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` into
      `extensions/drm-copilot/resources/claude-customizations/.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`,
      creating the directory. Acceptance: `git status --porcelain` lists the mirror path as
      untracked or added, and a content comparison of the two files reports no difference.

      `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/lib/cleanup-manifest`

- [ ] [P5-T3] Mirror `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` into
      `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1`.
      Acceptance: a content comparison of the two files reports no difference, and
      `git status --porcelain` lists the mirror path as modified.

      `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1`

- [ ] [P5-T4] Mirror `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` into
      `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`.
      Acceptance: a content comparison of the two files reports no difference, and
      `git status --porcelain` lists the mirror path as modified.

      `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`

---

### Phase 6 — Skill Mirror, Pack Manifest, And Coverage Registration (Batch F)

Batch F touches 2 PowerShell files, both `pester.runsettings.psd1`, plus one Markdown mirror and
one JSON file, so it stays within the cap.

- [ ] [P6-T1] Reset the PowerShell batch-budget counter before Batch F begins, by deleting the
      current session's `.claude/state/powershell-batch-budget` state file, and record the reset in
      `evidence/qa-gates/batch-f-budget-reset.2026-09-06T23-09.md` with the four schema fields.
      `.claude/hooks/enforce-powershell-batch-budget.ps1` scopes the 3-production and 3-test cap to
      the session, counts `.psd1` files as production alongside `.ps1` and `.psm1`, and counts
      distinct paths cumulatively, so a batch boundary is not observed unless the counter is reset.
      The state-file name embeds the resolved session id, so the artifact records the resolved path
      rather than a token containing a placeholder. Acceptance: the artifact records the resolved
      state-file path and that the file is absent after the reset.
- [ ] [P6-T2] Mirror `.claude/skills/cleanup-merged-worktrees/SKILL.md` into
      `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
      Acceptance: a content comparison of the two files reports no difference, and
      `git status --porcelain` lists the mirror path as modified.

      `git status --porcelain -- extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`

- [ ] [P6-T3] Add the entry `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` to the
      `CodeCoverage.Path` list in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`,
      adjacent to the existing `.claude/lib` entries, with a short comment recording that the key is
      an explicit per-file allow-list and that an unregistered production file would otherwise sit
      outside the coverage denominator. Acceptance: a fixed-string search finds the token
      `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` exactly once in that file.
      (Contributes to AC-24.)

      `git grep -c -F ".claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1" -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

- [ ] [P6-T4] Add the same `CodeCoverage.Path` entry to
      `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
      Acceptance: a fixed-string search finds the token
      `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` exactly once in that file.
      (Completes AC-24.)

      `git grep -c -F ".claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1" -- extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

- [ ] [P6-T5] Add one module entry for
      `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` to
      `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, alongside
      the existing `.claude/lib` module entries. Acceptance:
      `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` passes and the
      result is recorded in `evidence/qa-gates/pack-manifest-completeness.2026-09-06T23-09.md` with
      the four schema fields and a numeric test count. (Satisfies AC-22.)
- [ ] [P6-T6] Run `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and record
      the result in `evidence/qa-gates/push-down-resource-contracts.2026-09-06T23-09.md` with the
      four schema fields and a numeric test count.

      Acceptance: `EXIT_CODE: 0`, or `EXIT_CODE` non-zero with every reported missing or differing
      path under `.claude/state/` and matching the pre-existing set P0-T8 recorded; and the
      artifact records that the module mirror, both hook mirrors, and the skill mirror are present
      and text-equal. Any reported path outside `.claude/state/` is a failure of this task. The
      `.claude/state/` allowance exists because that directory is gitignored and is re-created
      during execution by the two registered hooks P0-T8 names, including after P6-T1's reset,
      which runs before this task; it is a pre-existing repository defect tracked separately and no
      task in this plan attempts to fix it. (Satisfies AC-21.)
- [ ] [P6-T7] Run `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
      after all production changes and record
      `evidence/qa-gates/no-python-guard-final.2026-09-06T23-09.md` with the four schema fields.
      Acceptance: the suite passes, the named test `It 'ships an empty allowlist'` is present with a
      passed outcome, and the artifact records that no allowlist entry was added. (Satisfies AC-23.)

---

### Phase 7 — Scope-Boundary And Invariant Verification

Every command in this phase is anchored with `--merge-base main`, which compares the merge base of
`main` and `HEAD` against the working tree and therefore reports uncommitted edits. P0-T9 records
the resolved merge-base SHA so the comparison point is auditable. Each name-listing diff is paired
with a porcelain-status companion, because an anchored diff enumerates tracked changes only and
cannot report a path this work creates.

- [ ] [P7-T1] Verify `.claude/lib/hook-payload/HookPayload.psm1` carries no diff, recording the
      result in `evidence/qa-gates/hookpayload-no-diff.2026-09-06T23-09.md` with the four schema
      fields. Acceptance: the anchored diff produces zero output lines and the porcelain companion
      lists the path in no state. (Satisfies AC-26.)

      `git diff --numstat --merge-base main -- .claude/lib/hook-payload/HookPayload.psm1`
      `git status --porcelain -- .claude/lib/hook-payload/HookPayload.psm1`

- [ ] [P7-T2] Verify `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` carries no diff,
      recording the result in `evidence/qa-gates/codex-hook-no-diff.2026-09-06T23-09.md` with the
      four schema fields. Acceptance: the anchored diff produces zero output lines and the porcelain
      companion lists the path in no state. (Satisfies AC-29.)

      `git diff --numstat --merge-base main -- .codex/hooks/enforce-epic-worktree-removal-gate.ps1`
      `git status --porcelain -- .codex/hooks/enforce-epic-worktree-removal-gate.ps1`

- [ ] [P7-T3] Verify all six of `.claude/hooks/validate-bash.ps1`,
      `.claude/hooks/enforce-epic-merge-gate.ps1`, `scripts/bash/cleanup-worktrees.sh`,
      `scripts/bash/cleanup_worktrees_lib.sh`, `scripts/bash/cleanup_worktrees_actions_lib.sh`, and
      `scripts/bash/cleanup_worktrees_enumerate_lib.sh` carry no diff, recording the result in
      `evidence/qa-gates/scope-boundary-no-diff.2026-09-06T23-09.md` with the four schema fields.
      Acceptance: the anchored diff produces zero output lines and the porcelain companion lists
      none of the six paths in any state. (Satisfies AC-30.)

      `git diff --numstat --merge-base main -- .claude/hooks/validate-bash.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 scripts/bash/cleanup-worktrees.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_enumerate_lib.sh`
      `git status --porcelain -- .claude/hooks/validate-bash.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 scripts/bash/`

- [ ] [P7-T4] Verify the `spec.md` D6 must-not-touch list is intact in both gate hooks by reading
      the anchored per-file diff hunks and confirming that no hunk overlaps the extraction regex
      strings, their `.Trim` calls, the trigger guards, the bodies of
      `Get-EpicWorktreeRemovalCommandPath` or `Get-ParallelWorktreeRemovalCommandPath`, the two deny
      reason strings, the decision constructors, the entry points, or the thin tails. Re-derive the
      current line number of each protected construct in this task rather than reusing the P0-T2 and
      P0-T3 values, and record both the P0 values and the re-derived values in
      `evidence/qa-gates/must-not-touch-intact.2026-09-06T23-09.md` with the four schema fields.
      This is the plan's principal scope guard, so it is anchored with `--merge-base main` rather
      than the three-dot form: the three-dot form compares against the commit `HEAD` and would emit
      no hunks at all on an uncommitted tree, which would make the check pass vacuously.
      Acceptance: the artifact lists every protected construct with its re-derived line number, the
      artifact records the number of diff hunks the anchored command produced for each file, and it
      records that no hunk in either file contains any of those lines. (Satisfies AC-31.)

      `git diff --unified=0 --merge-base main -- .claude/hooks/enforce-epic-worktree-removal-gate.ps1 .claude/hooks/enforce-parallel-worktree-removal-gate.ps1`
      `git status --porcelain -- .claude/hooks`

- [ ] [P7-T5] Verify the 500-line cap per file across everything this work changed or added,
      recording all counts in `evidence/qa-gates/line-counts-final.2026-09-06T23-09.md` with the
      four schema fields. The measured set is both gate hooks, the new module, both changed Pester
      suites, `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`,
      `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`, any split suite
      created under the P3-T25 contingencies, and every mirror created in Phase 5. Acceptance: every
      recorded count is at most 500 and the artifact records each count as an integer beside its
      path. (Satisfies AC-27.)
- [ ] [P7-T6] Verify no test added by this work creates, writes, or reads a temporary file, and
      that the manifest read boundary and the clock boundary are exercised exclusively through
      `Get-CleanupWorktreeManifestContent` and `Get-CleanupWorktreeManifestUtcNow`. Record the
      verification in `evidence/qa-gates/no-temp-files.2026-09-06T23-09.md` with the four schema
      fields.

      The single search below covers all four tokens and is scoped to the four files this work adds
      or changes rather than to the whole `tests/scripts/claude-hooks` directory, because
      `tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1` carries
      `New-TemporaryFile` and `GetTempPath` as fixture strings, so a directory-scoped search would
      always print a line for it and the absence assertion could never hold. The search reads the
      working tree with `Select-String` rather than `git grep`: two of the four files are created by
      this plan and are never staged, and `git grep` searches tracked files only, so a `git grep`
      against them would print nothing whatever they contain. None of the four tokens occurs in
      either existing gate suite today, and the two new suites are read directly from disk, so the
      search is falsifiable for every token in every file it covers.

      Acceptance: the command prints no result row, and the artifact records that result together
      with the four token names and the file set searched. If P3-T25's split contingency created an
      additional suite, add its path to the `-Path` list and record the extended set.
      (Satisfies AC-28.)

      `pwsh -NoProfile -Command "Select-String -SimpleMatch -Pattern 'New-TemporaryFile','GetTempPath','TestDrive','Out-File' -Path 'tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1','tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1','tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1','tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1' | Select-Object Path,LineNumber,Pattern"`

---

### Phase 8 — Final QA Loop, Coverage Evidence, And Traceability

The PowerShell toolchain order is format, then analyze, then test. There is no type-check step.
If any step fails or changes files, restart from P8-T1.

- [ ] [P8-T1] Run `mcp__drm-copilot__run_poshqc_format` and record
      `evidence/qa-gates/final-format.2026-09-06T23-09.md` with the four schema fields, a
      `Porcelain Before:` block, a `Porcelain After:` block, a `Formatted Lines:` block listing every
      line of the output that begins with the literal `Formatted: ` or the word `none`, and a
      `Line Count:` integer recording how many lines the run printed in total. This is a write-mode
      command whose exit code is identical on a clean run and on a repairing run, so the acceptance
      is a tree observation plus a recorded line inventory.

      Acceptance: the run printed no line beginning with the literal `Formatted: `, and the
      `Porcelain Before:` and `Porcelain After:` blocks are identical. If either condition fails,
      the formatter rewrote a file on this pass and the loop restarts at P8-T1. A byte-identity
      comparison against the P0-T5 record is deliberately not used: the formatter prints one line
      per discovered file, and by Phase 8 the tree holds files that did not exist at Phase 0, so the
      two outputs necessarily differ even on two clean runs.

      `git status --porcelain`

- [ ] [P8-T2] Re-run the P7-T1, P7-T2, and P7-T3 no-diff verifications after the final format pass
      and record the result in `evidence/qa-gates/post-format-no-diff.2026-09-06T23-09.md` with the
      four schema fields. The repository-wide format pass in P8-T1 scans `.claude` and `.codex`,
      neither of which the formatter excludes, so a pinned file can acquire a diff after Phase 7
      completed. Acceptance: each anchored diff produces zero output lines and each porcelain
      companion lists none of the pinned paths in any state.

      `git diff --numstat --merge-base main -- .claude/lib/hook-payload/HookPayload.psm1 .codex/hooks/enforce-epic-worktree-removal-gate.ps1 .claude/hooks/validate-bash.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 scripts/bash/cleanup-worktrees.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup_worktrees_enumerate_lib.sh`
      `git status --porcelain -- .claude/lib/hook-payload/HookPayload.psm1 .codex/hooks/enforce-epic-worktree-removal-gate.ps1 .claude/hooks/validate-bash.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 scripts/bash/`

- [ ] [P8-T3] Run `mcp__drm-copilot__run_poshqc_analyze` and record
      `evidence/qa-gates/final-analyze.2026-09-06T23-09.md` with the four schema fields.
      Acceptance: `EXIT_CODE: 0`, and the transcribed result text is the sentence beginning
      `PSScriptAnalyzer passed: no findings under`, which the artifact records as finding count 0.
      If the tool instead reports issues it fails with a message of the form
      `PSScriptAnalyzer reported N issue(s).`; fix the findings and restart the loop at P8-T1.
      Before writing any fix, reset the PowerShell batch-budget counter using the procedure in
      P3-T1 and record the reset in this task's artifact: Batch F's counter already holds two
      production files, and `.claude/hooks/enforce-powershell-batch-budget.ps1` counts distinct
      paths cumulatively, so a fix touching more than one further PowerShell file would be denied.
- [ ] [P8-T4] Run `mcp__drm-copilot__run_poshqc_test` and record
      `evidence/qa-gates/final-test-mcp.2026-09-06T23-09.md` with the four schema fields.
      Acceptance: `EXIT_CODE: 0` and `Output Summary:` records the passed and failed counts as
      integers with a failed count of zero, read from the console totals line. This task satisfies
      the `spec.md` AC-37 toolchain sequence; it is **not** the coverage evidence, because the MCP
      runner reads the installed extension's PoshQC settings and can therefore ignore the
      `CodeCoverage.Path` entry P6-T3 added. (Satisfies AC-37, together with P8-T1 and P8-T3.)
- [ ] [P8-T5] Capture the post-change coverage evidence through the self-hosted PoshQC invocation
      and write `evidence/qa-gates/final-coverage.2026-09-06T23-09.md` with the four schema fields.
      `Output Summary:` must record these four values, all produced by this run and none of them a
      placeholder: the overall coverage headline percentage, read from the single overall coverage
      line the run prints; and the per-file line-coverage percentages for
      `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`,
      `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, and
      `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, each computed from the `sourcefile`
      entries in `artifacts/pester/powershell-coverage.koverage.xml` written by this run, because
      the console output carries no per-file coverage table. Resolve each `sourcefile` entry to a
      repo-relative path by joining the enclosing `package` element's `name` to the `sourcefile`
      element's `name` with `/`, using the shape P0-T7's `Coverage XML Shape:` block recorded.

      Acceptance: all four numeric values are present, each of the three per-file percentages is at
      least 85, and a `sourcefile` entry that resolves under that join rule to
      `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` is present in that file, which is
      what proves the new file is inside the denominator. (Satisfies AC-25.)

      `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"`

- [ ] [P8-T6] Write the coverage delta comparison to
      `evidence/qa-gates/coverage-delta.2026-09-06T23-09.md` with the four schema fields, reporting
      the baseline coverage values recorded by P0-T7, the post-change values recorded by P8-T5, and
      the new-file coverage for `CleanupWorktreeManifest.psm1`. Both input sources are the per-file
      `sourcefile` entries of `artifacts/pester/powershell-coverage.koverage.xml`, captured by the
      P0-T7 run and by the P8-T5 run respectively. Acceptance: the artifact records three labelled
      numeric groups and states explicitly whether coverage regressed on either gate hook relative
      to the P0-T7 baseline. A recorded regression on either hook is a blocking finding and the
      phase does not complete.
- [ ] [P8-T7] Re-run the two Python delivery guards and the no-Python guard as a single closing
      check and record `evidence/qa-gates/final-delivery-guards.2026-09-06T23-09.md` with the four
      schema fields.

      Acceptance: `EXIT_CODE: 0` for
      `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` and for the
      no-Python guard, with a numeric test count recorded for each; and for
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, either `EXIT_CODE: 0`
      or a non-zero exit whose reported paths all sit under `.claude/state/` and match the
      pre-existing set P0-T8 recorded. If the resource-contracts test reports a `.claude` path this
      work changed, the final format pass in P8-T1 rewrote a source file without its Phase 5 or
      Phase 6 mirror; re-run the affected mirror task, then restart the loop at P8-T1.
- [ ] [P8-T8] Check off in `spec.md` each of `AC-01` through `AC-37` whose satisfying work has been
      implemented and verified, changing only `- [ ]` to `- [x]` and leaving every criterion's text
      unchanged. Leave unchecked any criterion whose evidence is absent or incomplete. Do not add
      any criterion to `spec.md`. Work mode is `full-bug`, so `spec.md` is the resolved
      acceptance-criteria source and `.claude/skills/acceptance-criteria-tracking/SKILL.md` requires
      the executor to maintain those checkboxes. That skill also directs check-off as each plan task
      passes verification rather than only at the end, so this task is the final reconciliation of
      checkbox state, not the first time any box is set.

      Then write the acceptance-criteria traceability record to
      `evidence/other/ac-traceability.2026-09-06T23-09.md`, mapping each identifier to the plan task
      that satisfies it, to the evidence artifact that proves it, and to its final checkbox state.
      For `AC-32` through `AC-36` the evidence artifact named is
      `evidence/qa-gates/skill-text-verification.2026-09-06T23-09.md`, written by P4-T6, which is
      the only artifact recording the Phase 4 skill-text searches.
      Acceptance: the record contains exactly 37 mapped identifiers, each appearing once; the
      checkbox state recorded for each identifier matches the state of that criterion in `spec.md`;
      and the record states explicitly that no criterion asserts the indirection is closed and no
      criterion asserts a permission-layer block.

      The executor reports the AC Status Summary defined in
      `.claude/skills/acceptance-criteria-tracking/SKILL.md` in its final completion report.
- [ ] [P8-T9] Mirror the issue update to `evidence/issue-updates/issue-635.2026-09-06T23-09.md`
      with `Timestamp:`, the exact text posted, and `PostedAs:` set to `comment` or `body` with the
      corresponding GitHub URL. If posting is blocked, write a `POSTING BLOCKED` header and the
      reason. Acceptance: the artifact exists and carries a `PostedAs:` line.

---

## Deferred And Recorded, Not Executed

These are recorded by `spec.md` as follow-up candidates. No task in this plan opens a GitHub issue
for any of them and no task in this plan changes any of them.

1. Whether `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` must also learn the manifest (D7).
2. The `git reset --hard` block in `.claude/hooks/validate-bash.ps1` (D10).
3. The receipt-check-count docstring discrepancy in the pr-author hook family (D9).
4. The `bash <file>` indirection, accepted rather than closed (D8).
