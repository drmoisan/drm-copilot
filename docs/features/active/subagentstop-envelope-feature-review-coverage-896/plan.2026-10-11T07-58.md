# subagentstop-envelope-feature-review-coverage (Plan)

- **Issue:** #896 (Refs #884 Codex half only; Refs #897 feature-review coverage validator only)
- **Parent (optional):** epic `subagentstop-envelope` (epic issue #904), child E4, integration branch `epic/subagentstop-envelope-integration`
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11T09-30
- **Status:** Draft v1.0 (initial authoring; awaiting validator run and executor preflight)
- **Version:** 1.0
- **Work Mode:** full-bug (from `issue.md` metadata; `spec.md` is the sole acceptance-criteria source; `user-story.md` is absent by design)
- **Branch:** `bug/subagentstop-envelope-feature-review-coverage-896`
- **Integration ref:** `origin/epic/subagentstop-envelope-integration` (written `<INT>` below; every `git diff` in this plan carries it as an operand)
- **Feature folder:** `docs/features/active/subagentstop-envelope-feature-review-coverage-896/` (written `<FEATURE>` below)
- **Requirements:** `<FEATURE>/spec.md` (AC-1 through AC-29), `<FEATURE>/issue.md`, `<FEATURE>/research/research.2026-10-11T08-10.md`, `docs/features/epics/subagentstop-envelope/epic.md` (Shared Design, lines 75-90)
- **Upstream dependency:** E1 (#897, branch `bug/subagentstop-envelope-core-897`, folder `docs/features/active/subagentstop-envelope-core-897/`). At authoring time E1 is not merged into `<INT>`; `.claude/hooks/subagentstop-envelope.ps1` does not exist in this tree. This plan is written against the epic Shared Design and defers the exact assistant-text property name, the empty/absent/malformed-stdin behavior, and the stdin read mechanism to E1's merged spec, recorded by Phase 0 (AC-1).

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Scope Summary

In scope (spec Scope & Non-Goals): the Claude feature-review hook transport (E1 helper, exit 2 on every block path), CR-4, CR-6, CR-8, CR-9, the Codex hook floor source (byte-identical thresholds copy, root `CLAUDE.md` line floor, CR-4 within Codex semantics), the feature-review-workflow skill copies and `.codex/agents/feature-review.toml`, their bundled mirrors, both `core.json` pack manifests, `$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, and `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.

Not edited by any task (AC-22, AC-27, spec Scope & Non-Goals): the E2 validators (`validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, `validate-executor-output.ps1`, `validate-planner-output.ps1`, `validate-required-artifact-output.ps1`) and E3 validators (`validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-task-researcher-output.ps1`) and their mirrors; `.claude/settings.json`; `.claude/hooks/subagentstop-envelope.ps1` and its mirror; `.claude/lib/bash/compute-concurrency-batches.sh` and every other bash file; `.codex/config.toml` and its bundle copy; everything under `.github/instructions/` and `.claude/rules/`; the #824 folder `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/`. No Python is added to any hook.

### Files named by this plan

| ID | Repository-relative path | Change |
|---|---|---|
| H1 | `.claude/hooks/validate-feature-review-coverage.ps1` | edit: entry and decision only; transport; CR-4 decision; help |
| H2 | `.claude/hooks/validate-feature-review-coverage-metrics.ps1` | new: artifact reader, CR-4 reader, coverage parsers |
| H3 | `.claude/hooks/validate-feature-review-coverage-rules.ps1` | new: artifact-path rules, language set, coverage-row rule |
| H4 | `.claude/hooks/feature-review-coverage-thresholds.ps1` | edit: CR-9 second alternative and help |
| H5 | `.codex/hooks/validate-feature-review-coverage.ps1` | edit: floor source, `-LineFloor`, help |
| H6 | `.codex/hooks/feature-review-coverage-thresholds.ps1` | new: byte copy of H4 |
| M1-M6 | the six mirrors of H1-H6 under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` (H1-H4) and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` (H5, H6) | byte copies |
| S1 | `.agents/skills/feature-review-workflow/SKILL.md` | edit: lines 111-114 and 148 |
| S2 | `.github/skills/feature-review-workflow/SKILL.md` | edit: line 126 |
| S3 | `.codex/agents/feature-review.toml` | edit: lines 119-123 and 133-135 |
| SM1-SM3 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml` | byte copies of S1-S3 |
| P1 | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | edit: two entries |
| P2 | `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | edit: one entry |
| T1 | `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` | edit: transport conversion, static tests E4-ST1, ST2, ST3, ST4, ST6 |
| T2 | `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` | edit: E4-TR1, TR2, TR3, TR3b, TR4, TR4a, TR4c, TR6; transport conversion |
| T3 | `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` | edit: CR-6 and transport conversion |
| T4 | `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` | edit: TG1 stdin, TG3 result shape |
| T5 | `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` | edit: E4-TR5 rows, E4-ST5 |
| T6 | `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` | edit: E4-TR7, TR8, TR9, ST7; floor row |
| T7 | `tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1` | new: E4-PX2 and resolver rows on the Codex copy |
| T8 | `tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1` | new: E4-PX1 |
| T9 | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | edit: line 30 only (no added line; file stays at 497 lines) |
| T10 | `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | edit: `STEP_EIGHT_COPIES`, `EXPECTED_LISTED_COPY_COUNT`, new parametrized test |

`.claude/skills/feature-review-workflow/SKILL.md` and its mirror are read-only: they already contain `CLAUDE.md`, `85%`, `75%`, `governing thresholds`, and no `80%`/`90%` (verified at lines 111-114 and 149).

## Planned File Split (CR-8)

| File | Functions | Expected lines (target <= 300; hard cap < 500) |
|---|---|---|
| H1 `.claude/hooks/validate-feature-review-coverage.ps1` | comment-based help; guard bootstrap; guarded dot-sources of `feature-review-coverage-thresholds.ps1`, `validate-feature-review-coverage-metrics.ps1`, `validate-feature-review-coverage-rules.ps1`, `subagentstop-envelope.ps1`; `Invoke-FeatureReviewCoverageValidation -AssistantText`; entry point | about 185-200 |
| H2 `.claude/hooks/validate-feature-review-coverage-metrics.ps1` | `Get-ArtifactFileContent`, `Get-FeatureReviewClaudeMdText` (new, CR-4), `Get-LcovRepoCoverage`, `Get-LcovBranchCoverage`, `Get-JacocoBranchCoverage`, `Get-LanguageBranchCoverage`, `Get-JacocoRepoCoverage`, `Get-LanguageRepoCoverage` | about 165-180 |
| H3 `.claude/hooks/validate-feature-review-coverage-rules.ps1` | `Get-ReviewArtifactPathFromOutput`, `Get-ReviewArtifactInfo`, `Get-ChangedLanguageSet`, `Test-LanguageCoverageRow` (adds `-LineSource`, `-BranchSource`) | about 170-185 |
| H4 `.claude/hooks/feature-review-coverage-thresholds.ps1` | `Get-FeatureReviewCoverageThreshold` (CR-9 alternative; help lists accepted forms) | about 85-95 |
| H5 `.codex/hooks/validate-feature-review-coverage.ps1` | unchanged function set; `Test-LanguageCoverageRow -LineFloor`; entry reads root `CLAUDE.md` | about 315-325 (baseline 304; above the 300 design target, recorded by AC-10; below the 500 cap) |
| H6 `.codex/hooks/feature-review-coverage-thresholds.ps1` | byte copy of H4 | same as H4 |

## Evidence Location

All evidence is written under `<FEATURE>/evidence/<kind>/` with kinds `baseline`, `regression-testing`, `qa-gates`, `other`, and `issue-updates` only. No path under `artifacts/` is an evidence location. `<ts>` in an artifact name is the executor's write time in `yyyy-MM-ddTHH-mm` form. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; an artifact whose expected exit code is non-zero also carries `ExpectedExitCode: 1`. Artifacts record repository-relative paths only; replace any absolute worktree prefix a tool prints with `<repo>`.

## Plan Interpretations (PI)

- PI-1 (AC-26 wording). AC-26 says no changed hook file "contains `python`". The base files already contain that token as data, not as an invocation: `.claude/hooks/validate-feature-review-coverage.ps1` lines 23, 142, 224, 261, 281 (the `Python` language label, `'python'`/`'pytest'` audit labels, and the `artifacts/python/lcov.info` coverage path) and `.codex/hooks/validate-feature-review-coverage.ps1` lines 15, 77, 135, 152. A literal reading is unsatisfiable on the base, and removing those tokens would break the Python coverage rule. This plan verifies the intent of AC-26 ("No Python is added to any hook", spec Constraints) by three mechanical checks recorded in the AC-26 artifact: (a) no `.py` file is added under `.claude/hooks/` or `.codex/hooks/`; (b) CR-PY-TOKEN shows the case-insensitive `python` occurrence count of each hook family at the branch head is less than or equal to its count at the merge base; (c) `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes. The interpretation is restated in the AC-26 check-off task so the feature review sees it.
- PI-2 (regression-test ordering). Each regression test carries the Pester tags `E4-Regression` and its own ID tag (`E4-TR1`, `E4-TR4`, `E4-TR5`, `E4-TR7`). Every gate that runs a file containing a regression test before the phase that fixes it excludes that test by tag (Phase 2: `E4-Regression`; Phase 3: `E4-TR1`, `E4-TR4`; Phase 4: `E4-TR4`). From Phase 5 onward no exclusion is used. The tags remain in the files.
- PI-3 (E4-TR4 failure on the base). On the base, `Invoke-FeatureReviewCoverageValidation` has no `-AssistantText` parameter, so E4-TR4 fails at parameter binding before reaching the `CLAUDE.md` read. The fail-first artifact records that failure message verbatim, and cites research Q4 (`research.2026-10-11T08-10.md` lines 152-165) for the behavioral defect (the unwrapped read at base line 444 propagates and ends as exit 1). E4-TR1, the E4-TR5 positive rows, and E4-TR7 fail on the base for behavioral reasons (exit 1 through `Write-Error`; default 85 instead of the stated figure; 80.5% accepted against the 80% floor).
- PI-4 (message prefix). The five decision messages that begin `feature-review hook:` (base lines 355, 362, 370, 433, 457) are re-prefixed `validate-feature-review-coverage:` so that the entry point passes `$result.Message` to `Exit-SubagentStopBlock` unchanged and every stderr reason begins with the prefix the dependency-failure tables pin (`hook-dependency-failure.Claude.Tests.ps1:97`, `hook-dependency-failure.SpecialCases.Tests.ps1:54`). No test asserts the old prefix (only a comment at `validate-feature-review-coverage.Issue824.Tests.ps1:8` contains the words).
- PI-5 (E1 contract fields). Tasks that need an E1-defined value read it from the named field of the AC-1 artifact `<FEATURE>/evidence/other/upstream-merge-check.<ts>.md`: `AssistantTextProperty:` (the envelope property that carries `last_assistant_message`), `MalformedStdinBehavior:` (one of `throws`, `blocks`, `returns`), `EmptyStdinBehavior:`, `AbsentStdinBehavior:`. No task chooses these values.
- PI-6 (line anchors). Line numbers in this plan were verified against the authoring tree (base `ac525c4ef`). P0-T9 records whether the E1 merge touched any file this plan edits; if it did not, the line numbers hold; if it did, the executor locates each edit by the quoted content and records the shifted line numbers in the task's artifact.

## Hermeticity Constraints (every new or edited test)

- No temporary files: no `New-TemporaryFile`, no `TestDrive:`, no write under the temp directory, no `GetTempFileName`. Stdin is supplied through `[System.Console]::SetIn([System.IO.StringReader]::new(...))` and stderr through `[System.Console]::SetError([System.IO.StringWriter]::new())`, both restored in `finally`. File content is supplied through mocks of `Get-ArtifactFileContent`, `Test-Path`, `Get-Content`, and `Get-ChildItem`. Static tests read committed repository files only.
- No child process: the hook entry point is driven in-process through the `&` route, as `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:26-43` does.
- `.claude/hooks/check-powershell-test-purity.ps1` denies a write under `tests/` that contains certain tokens (for example the process-start cmdlet, the sleep cmdlet, the temporary-file cmdlet, or the temp environment variable). No test in this plan needs them; do not write them, including in comments.
- No mock is built with `[scriptblock]::Create`; mock bodies are literal script blocks.
- Every test and production file stays below 500 lines.

## Execution Notes

- `.claude/hooks/enforce-powershell-batch-budget.ps1` denies the fourth distinct production PowerShell file outside the orchestrated large path. This plan edits six production PowerShell files (H1-H6) plus their mirrors and runs under the epic orchestrator's large path. If the hook denies a write, stop with BLOCKED and report the denial text; do not bypass or edit the hook.
- Never force-push. Every push is `git push origin bug/subagentstop-envelope-feature-review-coverage-896`.
- The `mcp__drm-copilot__run_poshqc_*` tools return a summary that does not carry tool output, so no task asserts a count, percentage, or finding from them. Every count and percentage in this plan is read from a CR output below.
- Commit messages end with the session's standard attribution trailer lines.

## Command Reference (CR)

Every CR body runs from the worktree root. Primary route: the PowerShell tool runs the body directly and reads `EXIT_CODE_COMPUTED:`. If the agent-worktree isolation guard denies the text, write the body to a `.ps1` file in the session scratchpad directory (outside the repository, not under any `tests` segment, not named `*.Tests.ps1`), write a scratchpad `.sh` file whose single command line runs the PowerShell host with `-NoProfile -File` on it, and run `sh <that .sh>` from the worktree root; cross-check `EXIT_CODE` against `EXIT_CODE_COMPUTED:` and stop with BLOCKED if they disagree. CR-POSHQC-FULL always runs through the scratchpad route because `Run.Exit = $true` ends its host process. The artifact `Command:` field records the route and the list substituted for each list placeholder.

Success-output observation rule: Phase 0 runs each CR at least once (P0-T10 through P0-T21). Before a later task asserts over a CR's output, the Phase 0 artifact must show the success-case literal named under that CR. If a named literal is absent from a successful run, record the observed output and stop with BLOCKED; do not substitute a different literal.

### Lists

- LIST-PROD: `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `.claude/hooks/validate-feature-review-coverage-rules.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`, `.codex/hooks/feature-review-coverage-thresholds.ps1`.
- LIST-PROD-BASE: `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`.
- LIST-TEST: T1 through T9 paths from the table above.
- LIST-TEST-BASE: T1 through T6 and T9 paths (T7 and T8 do not exist on the base).
- LIST-CLAUDE-SUITES: T1, T2, T3, T4, T5, `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`.
- LIST-CODEX-SUITES: T6, T7, T8, T9, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`, `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`.
- LIST-AUX: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.
- LIST-MIRROR-PAIRS (source then mirror): H1-H4 with `extensions/drm-copilot/resources/claude-customizations/<same path>`; H5, H6, S1, S3 with `extensions/drm-copilot/resources/codex-and-agents-customizations/<same path>`; S2 with `extensions/drm-copilot/resources/customizations/<same path>`.
- PYTEST-SPEC: `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py` (the spec Test Strategy command, verbatim).

### CR-PESTER-LIST (direct Pester over an explicit list, with tag filters)

Adapted from the executed recipe in `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/plan.2026-10-08T13-54.md:120-150`; the two filter lines are the only additions.

```powershell
$Paths = @( <LIST> )
$IncludeTags = @( <TAGS-IN> )    # may be empty
$ExcludeTags = @( <TAGS-OUT> )   # may be empty
$NamePatterns = @( <PATTERNS> )  # wildcard patterns matched against ExpandedName; may be empty
$root = (Get-Location).Path
Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop
$configuration = New-PesterConfiguration
$configuration.Run.Path = $Paths
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Normal'
if ($IncludeTags.Count -gt 0) { $configuration.Filter.Tag = $IncludeTags }
if ($ExcludeTags.Count -gt 0) { $configuration.Filter.ExcludeTag = $ExcludeTags }
$result = Invoke-Pester -Configuration $configuration
function Get-RelativeName([string] $File) { return $File.Substring($root.Length + 1).Replace([string][char]92, '/') }
foreach ($container in $result.Containers) { "CONTAINER: $(Get-RelativeName ([string]$container.Item)) | Result=$($container.Result)" }
foreach ($group in ($result.Tests | Group-Object { Get-RelativeName ([string]$_.ScriptBlock.File) } | Sort-Object Name)) {
    $passed = @($group.Group | Where-Object Result -EQ 'Passed').Count
    $failed = @($group.Group | Where-Object Result -EQ 'Failed').Count
    $skipped = @($group.Group | Where-Object Result -EQ 'Skipped').Count
    $notRun = @($group.Group | Where-Object Result -EQ 'NotRun').Count
    "SUITE: $($group.Name) | Passed=$passed | Failed=$failed | Skipped=$skipped | NotRun=$notRun"
}
foreach ($pattern in $NamePatterns) {
    $hits = @($result.Tests | Where-Object { $_.ExpandedName -like $pattern })
    "NAMED: $pattern | Passed=$(@($hits | Where-Object Result -EQ 'Passed').Count) | Failed=$(@($hits | Where-Object Result -EQ 'Failed').Count) | NotRun=$(@($hits | Where-Object Result -EQ 'NotRun').Count) | Total=$($hits.Count)"
}
foreach ($test in $result.Failed) { "FAILED: $($test.ExpandedPath) :: $((($test.ErrorRecord | Select-Object -First 1).Exception.Message) -replace '\s+', ' ')" }
"TOTAL: Passed=$($result.PassedCount) | Failed=$($result.FailedCount) | Skipped=$($result.SkippedCount) | NotRun=$($result.NotRunCount) | FailedBlocks=$($result.FailedBlocksCount) | FailedContainers=$($result.FailedContainersCount)"
$code = if ($result.FailedCount -eq 0 -and $result.FailedBlocksCount -eq 0 -and $result.FailedContainersCount -eq 0) { 0 } else { 1 }
"EXIT_CODE_COMPUTED: $code"
```

Success-case literals: one `CONTAINER:` line per file with `Result=Passed`, one `SUITE:` line per file, one `NAMED:` line per pattern, a `TOTAL:` line with `Failed=0`, `EXIT_CODE_COMPUTED: 0`.

### CR-POSHQC-FULL (full-population PoshQC run; research Q8, `research.2026-10-11T08-10.md:274-278`)

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

Observed success-case output (`docs/features/active/epic-852-main-sync/evidence/qa-gates/final-pester-coverage.md:11-12`): one line beginning `Tests Passed:` with `Failed: 0,` and one line beginning `Covered` of the form `Covered <x>% / 0%. <n> analyzed Commands in <m> Files.`. This command prints no per-file figure; per-file line coverage is read from `artifacts/pester/powershell-coverage.xml` by CR-COV-FILES, run immediately afterwards with no other Pester run in between. The run also writes `artifacts/pester/pester-junit.xml`, read by CR-JUNIT.

### CR-JUNIT (totals of the full run)

```powershell
[xml] $junit = Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml'
$tests = 0; $failures = 0; $errors = 0
foreach ($suite in @($junit.SelectNodes('//testsuite'))) { $tests += [int]$suite.tests; $failures += [int]$suite.failures; $errors += [int]$suite.errors }
"JUNIT: tests=$tests | failures=$failures | errors=$errors"
foreach ($case in @($junit.SelectNodes('//testcase[failure or error]'))) { "JUNIT-FAILED: $($case.name)" }
"EXIT_CODE_COMPUTED: $([int](($failures + $errors) -gt 0))"
```

Success-case literals: `JUNIT: tests=<n> | failures=0 | errors=0`, `EXIT_CODE_COMPUTED: 0` (same summation as the executed script at `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/observation-scripts.2026-10-08T17-32.md:320-325`).

### CR-COV-FILES (per-file line coverage from the JaCoCo/CoverageGutters XML)

Package/sourcefile resolution copied from the executed script at `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/observation-scripts.2026-10-08T17-32.md:327-347` (handles rooted and relative package names).

```powershell
$Files = @( <LIST> )
$root = (Get-Location).Path
[xml] $cov = Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'
$index = @{}
foreach ($pkg in @($cov.SelectNodes('//package'))) {
    $dir = [string]$pkg.name
    $relDir = if ([System.IO.Path]::IsPathRooted($dir)) { [System.IO.Path]::GetRelativePath($root, $dir) } else { $dir }
    $relDir = $relDir.Replace([string][char]92, '/').TrimEnd('/')
    foreach ($sf in @($pkg.SelectNodes('sourcefile'))) {
        $counter = $sf.SelectSingleNode("counter[@type='LINE']")
        if ($null -ne $counter) { $index["$relDir/$($sf.name)"] = $counter }
    }
}
$below = @()
foreach ($rel in $Files) {
    if (-not $index.ContainsKey($rel)) { "COVERAGE: $rel | ABSENT"; $below += $rel; continue }
    $c = [int]$index[$rel].covered; $m = [int]$index[$rel].missed
    $pct = if (($c + $m) -gt 0) { [math]::Round(100.0 * $c / ($c + $m), 2) } else { 0 }
    'COVERAGE: {0} | covered={1} | missed={2} | pct={3:F2}' -f $rel, $c, $m, $pct
    if ($pct -lt 85.0) { $below += $rel }
}
if ($below.Count -eq 0) { 'COVERAGE-BELOW-85: NONE' } else { "COVERAGE-BELOW-85: $($below -join ', ')" }
"EXIT_CODE_COMPUTED: $([int]($below.Count -gt 0))"
```

Success-case literals: one `COVERAGE:` line per file with numeric `covered=`, `missed=`, `pct=` values, `COVERAGE-BELOW-85: NONE`, `EXIT_CODE_COMPUTED: 0`.

### CR-COV-CHANGED (changed-line coverage against the merge base)

Line-map construction copied from the executed script at `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/observation-scripts.2026-10-08T17-32.md:359-370`. Runs only after the final commit, because the three-dot form compares committed content.

```powershell
$Files = @( <LIST> )
$root = (Get-Location).Path
[xml] $cov = Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'
$lineIndex = @{}
foreach ($pkg in @($cov.SelectNodes('//package'))) {
    $dir = [string]$pkg.name
    $relDir = if ([System.IO.Path]::IsPathRooted($dir)) { [System.IO.Path]::GetRelativePath($root, $dir) } else { $dir }
    $relDir = $relDir.Replace([string][char]92, '/').TrimEnd('/')
    foreach ($sf in @($pkg.SelectNodes('sourcefile'))) {
        $map = @{}
        foreach ($ln in @($sf.SelectNodes('line'))) { $map[[int]$ln.nr] = [int]$ln.ci }
        $lineIndex["$relDir/$($sf.name)"] = $map
    }
}
$below = @()
foreach ($rel in $Files) {
    $changed = [System.Collections.Generic.List[int]]::new()
    foreach ($hunk in @(git diff -U0 'origin/epic/subagentstop-envelope-integration...HEAD' -- $rel | Select-String -Pattern '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@')) {
        $start = [int]$hunk.Matches[0].Groups[1].Value
        $count = if ($hunk.Matches[0].Groups[2].Success) { [int]$hunk.Matches[0].Groups[2].Value } else { 1 }
        for ($n = $start; $n -lt $start + $count; $n++) { $changed.Add($n) }
    }
    $map = $lineIndex[$rel]
    if ($null -eq $map) { "CHANGED-COVERAGE: $rel | ABSENT"; $below += $rel; continue }
    $exec = @($changed | Where-Object { $map.ContainsKey($_) })
    $hit = @($exec | Where-Object { $map[$_] -gt 0 })
    $pct = if ($exec.Count -gt 0) { [math]::Round(100.0 * $hit.Count / $exec.Count, 2) } else { 100 }
    'CHANGED-COVERAGE: {0} | changed={1} | executable={2} | covered={3} | pct={4:F2}' -f $rel, $changed.Count, $exec.Count, $hit.Count, $pct
    if ($pct -lt 85.0) { $below += $rel }
}
if ($below.Count -eq 0) { 'CHANGED-BELOW-85: NONE' } else { "CHANGED-BELOW-85: $($below -join ', ')" }
"EXIT_CODE_COMPUTED: $([int]($below.Count -gt 0))"
```

Success-case literals: one `CHANGED-COVERAGE:` line per file with numeric values, `CHANGED-BELOW-85: NONE`, `EXIT_CODE_COMPUTED: 0`.

### CR-FORMAT-CHECK (read-only; mirrors the comparison in `Invoke-PoshQCFormat`, `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:56-66`)

Copied from the executed recipe at `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/plan.2026-10-08T13-54.md:191-208`.

```powershell
$Paths = @( <LIST> )
Import-Module PSScriptAnalyzer -ErrorAction Stop
$settings = (Resolve-Path 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Path
$drift = 0
foreach ($path in $Paths) {
    $normalized = (Get-Content -Raw -LiteralPath $path) -replace "`r?`n", "`n"
    $formatted = Invoke-Formatter -ScriptDefinition $normalized -Settings $settings
    if ($formatted -ne $normalized) { $drift++; "FORMAT-DRIFT: $path" } else { "FORMAT-CLEAN: $path" }
}
"FORMAT-DRIFT-COUNT: $drift"
"EXIT_CODE_COMPUTED: $([int]($drift -gt 0))"
```

Success-case literals: one `FORMAT-CLEAN:` line per file, `FORMAT-DRIFT-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`. Writes no file.

### CR-FORMAT-APPLY (write mode over an explicit list; same write as `Invoke-PoshQCFormat`)

```powershell
$Paths = @( <LIST> )
Import-Module PSScriptAnalyzer -ErrorAction Stop
$settings = (Resolve-Path 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Path
$applied = 0
foreach ($path in $Paths) {
    $normalized = (Get-Content -Raw -LiteralPath $path) -replace "`r?`n", "`n"
    $formatted = Invoke-Formatter -ScriptDefinition $normalized -Settings $settings
    if ($formatted -ne $normalized) { Set-Content -LiteralPath $path -Value $formatted -Encoding UTF8 -NoNewline; $applied++; "FORMAT-APPLIED: $path" } else { "FORMAT-UNCHANGED: $path" }
}
"FORMAT-APPLIED-COUNT: $applied"
"EXIT_CODE_COMPUTED: 0"
```

Success-case literals for a clean pass: one `FORMAT-UNCHANGED:` line per file and `FORMAT-APPLIED-COUNT: 0`. A non-zero `FORMAT-APPLIED-COUNT` means the tree changed and the QC loop restarts.

### CR-PSSA (PSScriptAnalyzer with repository settings)

Copied from the executed recipe at `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/plan.2026-10-08T13-54.md:210-228`.

```powershell
$Paths = @( <LIST> )
Import-Module PSScriptAnalyzer -ErrorAction Stop
$settings = (Resolve-Path 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Path
$total = 0
foreach ($path in $Paths) {
    $findings = @(Invoke-ScriptAnalyzer -Path $path -Settings $settings -Severity Error, Warning, Information)
    $total += $findings.Count
    "PSSA: $($path) | findings=$($findings.Count)"
    foreach ($finding in $findings) { "PSSA-FINDING: $($path):$($finding.Line) $($finding.RuleName) $($finding.Severity)" }
}
"PSSA-TOTAL: $total"
"EXIT_CODE_COMPUTED: $([int]($total -gt 0))"
```

Success-case literals: one `PSSA:` line per file with `findings=0`, `PSSA-TOTAL: 0`, `EXIT_CODE_COMPUTED: 0`.

### CR-LINES (line counts against the 300-line target and the 500-line cap)

```powershell
$Files = @( <LIST> )
$over = 0
foreach ($rel in $Files) {
    if (-not (Test-Path -LiteralPath $rel -PathType Leaf)) { "LINES: $rel | MISSING"; $over++; continue }
    $count = (Get-Content -LiteralPath $rel).Count
    $band = if ($count -ge 500) { 'OVER-CAP' } elseif ($count -gt 300) { 'OVER-TARGET' } else { 'WITHIN-TARGET' }
    if ($count -ge 500) { $over++ }
    "LINES: $rel | count=$count | $band"
}
"LINES-OVER-CAP: $over"
"EXIT_CODE_COMPUTED: $([int]($over -gt 0))"
```

Success-case literals: one `LINES:` line per file with a numeric `count=`, `LINES-OVER-CAP: 0`, `EXIT_CODE_COMPUTED: 0`. The count is `(Get-Content <path>).Count`, the measure AC-10 names.

### CR-SHA (source and mirror SHA256)

```powershell
$Pairs = @( <PAIRS> )   # each entry: @{ Source = '<path>'; Mirror = '<path>' }
$differ = 0
foreach ($pair in $Pairs) {
    $s = (Get-FileHash -Algorithm SHA256 -LiteralPath $pair.Source).Hash
    $m = (Get-FileHash -Algorithm SHA256 -LiteralPath $pair.Mirror).Hash
    $state = if ($s -eq $m) { 'MATCH' } else { 'DIFFER' }
    if ($s -ne $m) { $differ++ }
    "SHA: $($pair.Source) | $s | $($pair.Mirror) | $m | $state"
}
"SHA-DIFFER-COUNT: $differ"
"EXIT_CODE_COMPUTED: $([int]($differ -gt 0))"
```

Success-case literals: one `SHA:` line per pair ending `MATCH`, `SHA-DIFFER-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`.

### CR-PY-TOKEN (PI-1 check (b))

```powershell
$Mode = '<baseline|final>'
$base = (git merge-base 'origin/epic/subagentstop-envelope-integration' HEAD).Trim()
$Families = @(
    @{ Name = 'claude-hook'; Base = @('.claude/hooks/validate-feature-review-coverage.ps1'); Head = @('.claude/hooks/validate-feature-review-coverage.ps1', '.claude/hooks/validate-feature-review-coverage-metrics.ps1', '.claude/hooks/validate-feature-review-coverage-rules.ps1') }
    @{ Name = 'codex-hook'; Base = @('.codex/hooks/validate-feature-review-coverage.ps1'); Head = @('.codex/hooks/validate-feature-review-coverage.ps1') }
    @{ Name = 'thresholds'; Base = @('.claude/hooks/feature-review-coverage-thresholds.ps1'); Head = @('.claude/hooks/feature-review-coverage-thresholds.ps1', '.codex/hooks/feature-review-coverage-thresholds.ps1') }
)
$worse = 0
foreach ($family in $Families) {
    $baseCount = 0
    foreach ($path in $family.Base) { $baseCount += [regex]::Matches((git show "$($base):$path" | Out-String), '(?i)python').Count }
    if ($Mode -eq 'baseline') { "PY-TOKEN: $($family.Name) | base=$baseCount"; continue }
    $headCount = 0
    foreach ($path in $family.Head) { $headCount += [regex]::Matches((Get-Content -Raw -LiteralPath $path), '(?i)python').Count }
    $state = if ($headCount -le $baseCount) { 'NOT-INCREASED' } else { 'INCREASED' }
    if ($headCount -gt $baseCount) { $worse++ }
    "PY-TOKEN: $($family.Name) | base=$baseCount | head=$headCount | $state"
}
"PY-TOKEN-INCREASED-COUNT: $worse"
"EXIT_CODE_COMPUTED: $([int]($worse -gt 0))"
```

Success-case literals: baseline mode prints three `PY-TOKEN:` lines with numeric `base=`; final mode prints three lines ending `NOT-INCREASED`, `PY-TOKEN-INCREASED-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`.

## Guarded Dot-Source Literals

Each line below is added verbatim (one statement per line) and asserted by the static tests:

- H1, after the existing thresholds line 47: `try { . (Join-Path $PSScriptRoot 'validate-feature-review-coverage-metrics.ps1') } catch { Add-HookDependencyFailure -Name 'validate-feature-review-coverage-metrics.ps1' -ErrorRecord $_ }`
- H1, next line: `try { . (Join-Path $PSScriptRoot 'validate-feature-review-coverage-rules.ps1') } catch { Add-HookDependencyFailure -Name 'validate-feature-review-coverage-rules.ps1' -ErrorRecord $_ }`
- H1, next line (Phase 4): `try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ }`
- H5, after the guard bootstrap at line 43: `try { . (Join-Path $PSScriptRoot 'feature-review-coverage-thresholds.ps1') } catch { Add-HookDependencyFailure -Name 'feature-review-coverage-thresholds.ps1' -ErrorRecord $_ }`

The thresholds dot-source stays the first edge after the guard bootstrap in H1, because `hook-dependency-failure.SpecialCases.Tests.ps1:31-32` selects the first non-guard edge by line.

## Help-Text Tokens (asserted by E4-ST3)

Both the H1 comment-based help and the H5 comment-based help contain the sentences "an absent root CLAUDE.md uses the defaults" and "an unreadable root CLAUDE.md fails closed" (each may wrap; E4-ST3 compares whitespace-normalized text). The H1 help keeps the phrase "falls back independently".

### Phase 0 — Policy Reads, Upstream-Merge Check, and Baseline Capture

- [ ] [P0-T1] Read, in this order, `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/tonality.instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/plan-acceptance-gates.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.claude/skills/acceptance-criteria-tracking/SKILL.md`; write `<FEATURE>/evidence/baseline/phase0-instructions-read.<ts>.md` with `Timestamp:`, `Policy Order:`, and the list of the 19 files read. Acceptance: the artifact lists all 19 paths in this order.
- [ ] [P0-T2] UPSTREAM-MERGE CHECK, step 1 (first gating task; AC-1). Run `git fetch origin epic/subagentstop-envelope-integration` and `git rev-parse origin/epic/subagentstop-envelope-integration`; create `<FEATURE>/evidence/other/upstream-merge-check.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Base: <40-hex SHA>`, and `Branch:` from `git rev-parse --abbrev-ref HEAD`. Acceptance: `Base:` holds a 40-character hexadecimal SHA and `Branch:` reads `bug/subagentstop-envelope-feature-review-coverage-896`; any other value records `Verdict: STOP` and goes to P0-T7.
- [ ] [P0-T3] UPSTREAM-MERGE CHECK, step 2 (E1 merged). Run `gh pr list --repo drmoisan/drm-copilot --state merged --head bug/subagentstop-envelope-core-897 --base epic/subagentstop-envelope-integration --json number,mergeCommit,mergedAt`, then `git merge-base --is-ancestor <mergeCommit.oid> origin/epic/subagentstop-envelope-integration` with the SHA the first command printed; append both outputs and exit codes to the P0-T2 artifact with `E1MergeCommit: <sha>` and `E1Merged: yes|no`. Acceptance: `E1Merged: yes` only when the list holds exactly one PR and the ancestry check exits 0; otherwise `E1Merged: no`.
- [ ] [P0-T4] UPSTREAM-MERGE CHECK, step 3 (helper at base). Run `git cat-file -e origin/epic/subagentstop-envelope-integration:.claude/hooks/subagentstop-envelope.ps1`, `git cat-file -e origin/epic/subagentstop-envelope-integration:extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1`, and `git grep -n -F -e "function Read-SubagentStopEnvelope" -e "function Exit-SubagentStopBlock" origin/epic/subagentstop-envelope-integration -- .claude/hooks/subagentstop-envelope.ps1`; append outputs to the P0-T2 artifact with `HelperPresent: yes|no`, `HelperMirrorPresent: yes|no`, `HelperFunctions: <count>`. The two searched literals are "function Read-SubagentStopEnvelope" and "function Exit-SubagentStopBlock". Acceptance: both `cat-file` commands exit 0 and the grep prints exactly two lines, one per literal; otherwise the corresponding field is `no` or the count is not 2.
- [ ] [P0-T5] UPSTREAM-MERGE CHECK, step 4 (stdin read mechanism). Run `git grep -n -F -e "[Console]::In" origin/epic/subagentstop-envelope-integration -- .claude/hooks/subagentstop-envelope.ps1` and append the output to the P0-T2 artifact with `StdinRedirectable: yes|no`. The searched literal is "[Console]::In". Acceptance: `StdinRedirectable: yes` only when the grep prints at least one line, because the E4 regression harness supplies stdin through `[System.Console]::SetIn`.
- [ ] [P0-T6] UPSTREAM-MERGE CHECK, step 5 (E1 merged spec). Locate E1's spec with `git ls-tree -r --name-only origin/epic/subagentstop-envelope-integration -- docs/features` filtered to paths ending `subagentstop-envelope-core-897/spec.md`, read it with `git show origin/epic/subagentstop-envelope-integration:<that path>`, and append to the P0-T2 artifact: `E1SpecPath:`, `AssistantTextProperty:` (the property of the `Read-SubagentStopEnvelope` result that carries `last_assistant_message`), `EmptyStdinBehavior:`, `AbsentStdinBehavior:`, `MalformedStdinBehavior:` (each one of `throws`, `blocks`, `returns`, with the spec line cited), `ReadContract:` (the parameters of `Read-SubagentStopEnvelope`, marking any mandatory one, and its return shape), `ExitBlockContract:` (parameter name, stream, exit code), and `Divergence:` (each difference from `docs/features/epics/subagentstop-envelope/epic.md` lines 80-87, or `NONE`). Acceptance: every field is filled with a value cited to an E1 spec line; a field E1's spec does not define is recorded `UNDEFINED`.
- [ ] [P0-T7] UPSTREAM-MERGE CHECK, verdict. Append `Verdict: PROCEED` to the P0-T2 artifact only when all hold: `Branch:` correct, `E1Merged: yes`, `HelperPresent: yes`, `HelperMirrorPresent: yes`, `HelperFunctions: 2`, `StdinRedirectable: yes`, `AssistantTextProperty:` defined and derived from `last_assistant_message`, `ReadContract:` shows `Read-SubagentStopEnvelope` callable with no mandatory parameter and reading stdin, `ExitBlockContract:` is `-Message`, stderr, exit 2, and `Divergence:` contains no transport, field, or exit-code difference. Otherwise append `Verdict: STOP` with the failing fields, stage only the artifact (`git add <FEATURE>/evidence/other/upstream-merge-check.<ts>.md`), commit `docs(896): record upstream-merge check STOP`, push, and halt execution with BLOCKED; no production or test file is changed. Acceptance: the artifact ends with exactly one `Verdict:` line, and on STOP `git status --porcelain` prints nothing after the push.
- [ ] [P0-T8] Merge the integration ref (only after `Verdict: PROCEED`). Run `git merge --no-edit origin/epic/subagentstop-envelope-integration`, then `git merge-base --is-ancestor origin/epic/subagentstop-envelope-integration HEAD` and `Test-Path -LiteralPath .claude/hooks/subagentstop-envelope.ps1 -PathType Leaf`; append outputs to the P0-T2 artifact with `MergedHead: <sha>`. Acceptance: the ancestry check exits 0 and `Test-Path` prints `True`; a merge conflict records `Verdict: STOP (merge conflict)` and halts with BLOCKED after `git merge --abort`.
- [ ] [P0-T9] Record whether the E1 merge changed any file this plan edits: run `git diff --name-only ac525c4ef origin/epic/subagentstop-envelope-integration -- .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/feature-review-coverage-thresholds.ps1 .codex/hooks/validate-feature-review-coverage.ps1 tests/scripts/claude-hooks tests/scripts/codex-hooks tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py .agents/skills/feature-review-workflow .github/skills/feature-review-workflow .codex/agents/feature-review.toml extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` together with `git status --porcelain`; append to the P0-T2 artifact as `AnchorDrift: NONE` or the listed paths (PI-6). Acceptance: the field is present and matches the diff output.
- [ ] [P0-T10] Baseline line counts: run CR-LINES with `<LIST>` = LIST-PROD-BASE plus LIST-TEST-BASE plus `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/baseline/file-size.<ts>.md`. Acceptance: one `LINES:` line per file with numeric `count=`, `LINES-OVER-CAP: 0`, and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` at `count=497`.
- [ ] [P0-T11] Baseline targeted Pester: run CR-PESTER-LIST with `<LIST>` = T1, T2, T3, T4, T5, T6, T9, `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`, `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, LIST-AUX; `<TAGS-IN>` empty; `<TAGS-OUT>` = `E4-Regression` (no test carries it yet; the run observes the filter code path); `<PATTERNS>` = `T824-*`, `F824-*`, `TG*`; write `<FEATURE>/evidence/baseline/pester-targeted.<ts>.md` with every `SUITE:` line copied. Acceptance: the artifact records the `TOTAL:` line and `EXIT_CODE_COMPUTED:`; any `FAILED:` line is listed as `PRE-EXISTING:` for comparison in P10-T6.
- [ ] [P0-T12] Baseline full-population run: run CR-POSHQC-FULL through the scratchpad route, then CR-JUNIT; write `<FEATURE>/evidence/baseline/pester-full-run.<ts>.md` with the `Tests Passed:` line, the `Covered` line, and the `JUNIT:` line verbatim. Acceptance: all three literals are present; each `JUNIT-FAILED:` line is listed as `PRE-EXISTING:`.
- [ ] [P0-T13] Baseline per-file coverage (AC-25 baseline half), immediately after P0-T12 with no Pester run in between: run CR-COV-FILES with `<LIST>` = LIST-PROD-BASE; write `<FEATURE>/evidence/baseline/pester-coverage.<ts>.md` with `Output Summary:` stating the three numeric `pct=` values. Acceptance: three `COVERAGE:` lines with numeric `covered=`, `missed=`, `pct=` values and no `ABSENT` line.
- [ ] [P0-T14] Baseline format check: run CR-FORMAT-CHECK with `<LIST>` = LIST-PROD-BASE plus LIST-TEST-BASE; write `<FEATURE>/evidence/baseline/format-check.<ts>.md`. Acceptance: one line per file and a numeric `FORMAT-DRIFT-COUNT:`; any `FORMAT-DRIFT:` file is recorded as pre-existing drift.
- [ ] [P0-T15] Baseline PSScriptAnalyzer: run CR-PSSA with `<LIST>` = LIST-PROD-BASE plus LIST-TEST-BASE; write `<FEATURE>/evidence/baseline/pssa.<ts>.md`. Acceptance: one `PSSA:` line per file and a numeric `PSSA-TOTAL:`.
- [ ] [P0-T16] Baseline Python contract tests: run PYTEST-SPEC; write `<FEATURE>/evidence/baseline/pytest-contracts.<ts>.md` with the final pytest summary line. Acceptance: the summary line carries numeric `passed` and `failed` counts (a missing `failed` word means 0 failed).
- [ ] [P0-T17] Baseline auxiliary Python contract test: run `poetry run pytest tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`; write `<FEATURE>/evidence/baseline/pytest-ci-gate-contracts.<ts>.md`. Acceptance: the summary line is recorded with numeric counts.
- [ ] [P0-T18] Baseline Black check (read-only): run `poetry run black --check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/baseline/python-black-check.<ts>.md`. Acceptance: the artifact records the output line containing `would be left unchanged` or `would reformat`.
- [ ] [P0-T19] Baseline Ruff: run `poetry run ruff check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/baseline/python-ruff.<ts>.md`. Acceptance: the artifact records `All checks passed!` or the listed findings.
- [ ] [P0-T20] Baseline Pyright: run `poetry run pyright tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/baseline/python-pyright.<ts>.md`. Acceptance: the artifact records the summary line with numeric error, warning, and information counts.
- [ ] [P0-T21] Baseline Python-token counts: run CR-PY-TOKEN with `$Mode = 'baseline'`; write `<FEATURE>/evidence/baseline/python-token-count.<ts>.md`. Acceptance: three `PY-TOKEN:` lines with numeric `base=` values.
- [ ] [P0-T22] Check off AC-1 in `<FEATURE>/spec.md` (change `- [ ] AC-1:` to `- [x] AC-1:`) only if the P0-T2 artifact ends with `Verdict: PROCEED`. Acceptance: exactly that one checkbox changed.
- [ ] [P0-T23] Commit and push Phase 0: `git add <FEATURE>/evidence <FEATURE>/spec.md`, `git commit -m "docs(896): record upstream-merge check and baselines"`, `git push origin bug/subagentstop-envelope-feature-review-coverage-896`. Acceptance: `git status --porcelain` prints nothing, and after `git fetch origin bug/subagentstop-envelope-feature-review-coverage-896` the output of `git rev-parse HEAD` equals that of `git rev-parse origin/bug/subagentstop-envelope-feature-review-coverage-896`.

### Phase 1 — Regression Tests First (expect-fail)

- [ ] [P1-T1] [expect-fail] In T2 `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`, add a `Context 'E4 regression (issue #896)'` whose `BeforeAll` defines `Invoke-ClaudeReviewEntry` (parameter `[AllowEmptyString()][string] $Stdin`; saves `[System.Console]::In` and `[System.Console]::Error`, sets a `StringReader` and a `StringWriter`, sets `$global:LASTEXITCODE = 0`, runs `& $script:HookFile`, returns `ExitCode`, `Stdout`, `Stderr`, restores both streams in `finally`) and `ConvertTo-ClaudeEnvelope` (parameter `[string] $AssistantText`; returns `[ordered]@{ session_id = 'e4-896'; hook_event_name = 'SubagentStop'; agent_type = 'feature-review'; stop_hook_active = $false; last_assistant_message = $AssistantText } | ConvertTo-Json -Compress`), and add `It 'E4-TR1: the entry point exits 2 for an envelope without review-artifact tokens' -Tag 'E4-Regression', 'E4-TR1'` that calls `Invoke-ClaudeReviewEntry -Stdin (ConvertTo-ClaudeEnvelope -AssistantText 'Review complete.')` and asserts `ExitCode` is 2 and `Stderr.StartsWith('validate-feature-review-coverage:', [System.StringComparison]::Ordinal)` is true. Acceptance: the file parses (`[System.Management.Automation.Language.Parser]::ParseFile` reports no error) and contains one `It` whose name begins `E4-TR1:`.
- [ ] [P1-T2] [expect-fail] In the same Context of T2, add `It 'E4-TR4: an unreadable root CLAUDE.md blocks with a structured message and exit 2' -Tag 'E4-Regression', 'E4-TR4'`: mock `Get-ArtifactFileContent` with a literal script block that returns an existing result for the three review artifacts under `docs/features/active/foo/` stamped `2026-05-04T08-00`, returns `- src/foo.py (+1/-0)` for `artifacts/pr_context.summary.txt`, and throws `simulated read failure: access denied` for `CLAUDE.md`; build `$text` as the three lines `policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md`, `code-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md`, `feature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md` joined by newlines; assert `(Invoke-FeatureReviewCoverageValidation -AssistantText $text)` has `Ok` false and a `Message` containing `root CLAUDE.md` and `could not be read`; then assert `Invoke-ClaudeReviewEntry -Stdin (ConvertTo-ClaudeEnvelope -AssistantText $text)` returns `ExitCode` 2. Acceptance: the file parses and contains one `It` whose name begins `E4-TR4:`.
- [ ] [P1-T3] [expect-fail] In T5 `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`, add `It 'E4-TR5-P<Id> resolves <Label>' -Tag 'E4-Regression', 'E4-TR5' -ForEach` with six rows (Line, Branch, LineSource, BranchSource): P1 `line coverage: 70% minimum` (70, 75, claude-md, default); P2 `line coverage 80% at least` (80, 75, claude-md, default); P3 `line coverage of 80% or more` (80, 75, claude-md, default); P4 `branch coverage: 60% or higher` (85, 60, default, claude-md); P5 `line coverage 81% or above` (81, 75, claude-md, default); P6 `branch coverage 62% or greater` (85, 62, default, claude-md); and a separate `It 'E4-TR5-N<Id> keeps the defaults for <Label>' -ForEach` (no regression tag) with three rows: N1 `Line coverage was 62% last release`, N2 `Line and branch coverage: 70% minimum`, N3 `line coverage: 150% minimum`, each expecting 85, 75, default, default. Use the existing Arrange/Act/Assert body shape of lines 39-50. Acceptance: the file parses and holds six `E4-TR5-P` rows and three `E4-TR5-N` rows.
- [ ] [P1-T4] [expect-fail] In T6 `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`, inside `Context 'entry point'`, add `It 'E4-TR7: with no CLAUDE.md figure an 80.5% line row fails against the 85% floor' -Tag 'E4-Regression', 'E4-TR7'`: `Mock Test-Path { param($Path) -not ([string]$Path).EndsWith('.xml') }`; `Mock Get-ChildItem` returning the synthetic audit object used at line 183; `Mock Get-Content { param($Path) $p = [string]$Path; if ($p.EndsWith('pr_context.summary.txt')) { @('- src/a.py (+1/-0)') } elseif ($p.EndsWith('lcov.info')) { @('LF:1000', 'LH:805') } elseif ($p.EndsWith('CLAUDE.md')) { 'Project notes without coverage figures.' } else { 'Python coverage PASS' } }`; call `Invoke-CodexReviewEntry -Stdin $script:ReviewStop`; assert `ExitCode` 0, `Stdout` non-empty, `($result.Stdout | ConvertFrom-Json).decision` equals `block`, and the reason contains `below the 85% line coverage floor`. Acceptance: the file parses and contains one `It` whose name begins `E4-TR7:`.
- [ ] [P1-T5] [expect-fail] Run CR-PESTER-LIST with `<LIST>` = T2, T5, T6; `<TAGS-IN>` = `E4-Regression`; `<TAGS-OUT>` empty; `<PATTERNS>` = `E4-TR1:*`, `E4-TR4:*`, `E4-TR5-P*`, `E4-TR7:*`; write `<FEATURE>/evidence/regression-testing/fail-first.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, `Output Summary:`, every `NAMED:` and `FAILED:` line verbatim, a `Base:` line copied from the P0-T2 artifact, and the PI-3 note for E4-TR4. Acceptance: `NAMED: E4-TR1:* | Passed=0 | Failed=1`, `NAMED: E4-TR4:* | Passed=0 | Failed=1`, `NAMED: E4-TR5-P* | Passed=0 | Failed=6`, `NAMED: E4-TR7:* | Passed=0 | Failed=1`, and `EXIT_CODE_COMPUTED: 1`.
- [ ] [P1-T6] Confirm the untagged rows of the three edited files still pass: run CR-PESTER-LIST with `<LIST>` = T2, T5, T6; `<TAGS-IN>` empty; `<TAGS-OUT>` = `E4-Regression`; `<PATTERNS>` = `E4-TR5-N*`, `T824-*`; write `<FEATURE>/evidence/regression-testing/phase1-untagged-rows.<ts>.md`. Acceptance: `NAMED: E4-TR5-N* | Passed=3 | Failed=0`, `NAMED: T824-* | Passed=11 | Failed=0`, `TOTAL:` with `Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P1-T7] Commit and push Phase 1: `git add tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 <FEATURE>/evidence`, `git commit -m "test(896): add expect-fail regression tests E4-TR1, TR4, TR5, TR7"`, `git push origin bug/subagentstop-envelope-feature-review-coverage-896`. Acceptance: `git status --porcelain` prints nothing and `git rev-parse HEAD` equals `git rev-parse origin/bug/subagentstop-envelope-feature-review-coverage-896` after a fetch of that branch.

### Phase 2 — CR-8 Three-File Split (behavior-preserving move)

- [ ] [P2-T1] Create H2 `.claude/hooks/validate-feature-review-coverage-metrics.ps1` with a comment-based file header (synopsis; "Dot-sourced by validate-feature-review-coverage.ps1"; PowerShell 7+) and move, unchanged, `Get-ArtifactFileContent` (H1 lines 51-73), `Get-LcovRepoCoverage` (150-169), `Get-LcovBranchCoverage` (171-194), `Get-JacocoBranchCoverage` (196-216), `Get-LanguageBranchCoverage` (218-229), `Get-JacocoRepoCoverage` (231-251), `Get-LanguageRepoCoverage` (253-266). The file has no `param()` block and no top-level statement other than function definitions. Acceptance: parsing H2 yields exactly those seven `FunctionDefinitionAst` names and no parse error.
- [ ] [P2-T2] Create H3 `.claude/hooks/validate-feature-review-coverage-rules.ps1` with the same header form and move, unchanged, `Get-ReviewArtifactPathFromOutput` (H1 lines 75-104), `Get-ReviewArtifactInfo` (106-129), `Get-ChangedLanguageSet` (131-148), `Test-LanguageCoverageRow` (268-343). Acceptance: parsing H3 yields exactly those four function names and no parse error.
- [ ] [P2-T3] Edit H1 `.claude/hooks/validate-feature-review-coverage.ps1`: delete the eleven moved function bodies and add the two metrics and rules guarded dot-source lines quoted under Guarded Dot-Source Literals immediately after line 47. Acceptance: parsing H1 yields exactly one function name, `Invoke-FeatureReviewCoverageValidation`, and H1 contains both quoted lines verbatim.
- [ ] [P2-T4] Edit P1 `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: insert `".claude/hooks/validate-feature-review-coverage-metrics.ps1",` and `".claude/hooks/validate-feature-review-coverage-rules.ps1",` between the entries at lines 70 (`validate-executor-output.ps1`) and 71 (`validate-feature-review-coverage.ps1`). Acceptance: `Get-Content -Raw <P1> | ConvertFrom-Json` succeeds and `.paths` contains both new strings.
- [ ] [P2-T5] Copy H1, H2, H3 to their mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` with `Copy-Item -LiteralPath <source> -Destination <mirror> -Force`; run CR-SHA over the three pairs; write `<FEATURE>/evidence/other/phase2-mirror.<ts>.md`. Acceptance: three `SHA:` lines ending `MATCH` and `SHA-DIFFER-COUNT: 0`.
- [ ] [P2-T6] In T1 `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`, add `It 'E4-ST4: <File> defines exactly its assigned functions' -ForEach` with three rows: H1 (`Invoke-FeatureReviewCoverageValidation`), H2 (the seven P2-T1 names), H3 (the four P2-T2 names); each row parses the file with `[System.Management.Automation.Language.Parser]::ParseFile` and asserts the sorted `FunctionDefinitionAst` name set equals the sorted assigned list. Acceptance: the file parses and holds three `E4-ST4` rows.
- [ ] [P2-T7] Gate: run CR-PESTER-LIST with `<LIST>` = LIST-CLAUDE-SUITES; `<TAGS-IN>` empty; `<TAGS-OUT>` = `E4-Regression`; `<PATTERNS>` = `E4-ST4*`, `TG1:*`, `TG2:*`, `TG3:*`, `F824-*`, `B1:*validate-feature-review-coverage*`; write `<FEATURE>/evidence/qa-gates/phase2-split-pester.<ts>.md`. Acceptance: `NAMED: E4-ST4* | Passed=3 | Failed=0`, `NAMED: TG1:* | Passed=2 | Failed=0`, `NAMED: TG2:* | Passed=2 | Failed=0`, `NAMED: TG3:* | Passed=2 | Failed=0`, the `B1` pattern shows `Failed=0` and `Passed` at least 3 (thresholds, metrics, rules edges), `TOTAL:` with `Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P2-T8] Run CR-LINES with `<LIST>` = H1, H2, H3; write `<FEATURE>/evidence/qa-gates/phase2-file-size.<ts>.md`. Acceptance: three `LINES:` lines with `count=` below 500 and `LINES-OVER-CAP: 0`.
- [ ] [P2-T9] Commit and push Phase 2: `git add .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/validate-feature-review-coverage-metrics.ps1 .claude/hooks/validate-feature-review-coverage-rules.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 <FEATURE>/evidence`, `git commit -m "refactor(896): split feature-review coverage hook into entry, metrics, and rules files"`, `git push origin bug/subagentstop-envelope-feature-review-coverage-896`. Acceptance: `git status --porcelain` prints nothing and HEAD equals the fetched remote branch head.

### Phase 3 — CR-9 Resolver Form and Floor-Source Messages

- [ ] [P3-T1] Edit H4 `.claude/hooks/feature-review-coverage-thresholds.ps1` line 57: replace the pattern with one that keeps the combined-metric lookbehind and adds the trailing-floor alternative from spec Proposed Fix item 5, in the form `'(?im)(?<!\b(?:line|branch)\s*(?:and|or|&|/)\s*)\b' + $metric + '\s+coverage\b[^\r\n%]*?(?:(?:>=|' + [char]0x2265 + '|\bat\s+least\b|\bminimum(?:\s+of)?\b|\bno\s+less\s+than\b)\s*:?\s*(?<![\d.])(?<pct>\d{1,3}(?:\.\d+)?)\s*%|(?<![\d.])(?<pct>\d{1,3}(?:\.\d+)?)\s*%\s*(?:minimum|at\s+least|or\s+(?:more|higher|above|greater))\b)'`; keep the 0..100 range check and first-valid-match loop (lines 58-66) unchanged. Acceptance: H4 parses, and the regex string contains the token `or\s+(?:more|higher|above|greater)`.
- [ ] [P3-T2] Edit the `Get-FeatureReviewCoverageThreshold` help (H4 lines 22-36) to list the accepted forms: comparator before the figure (`>=`, the U+2265 sign, `at least`, `minimum`, `minimum of`, `no less than`) and trailing floor phrase after the figure (`minimum`, `at least`, `or more`, `or higher`, `or above`, `or greater`), each on the same line as `<metric> coverage`; keep the combined-metric limitation paragraph. Acceptance: the help text, whitespace-normalized, contains each of the tokens `>=`, `U+2265`, `at least`, `minimum of`, `no less than`, `or more`, `or higher`, `or above`, `or greater`.
- [ ] [P3-T3] Edit `Test-LanguageCoverageRow` in H3: add parameters `[string] $LineSource = 'default'` and `[string] $BranchSource = 'default'`; compute the label `(root CLAUDE.md)` when the source is `claude-md` and `(default)` otherwise; append the label after `line coverage floor` and after `branch coverage floor` in the two floor messages (base H1 lines 330 and 338), producing for example `below the 70% line coverage floor (root CLAUDE.md)`. Acceptance: H3 parses and `Test-LanguageCoverageRow` declares `LineSource` and `BranchSource`.
- [ ] [P3-T4] Edit `Invoke-FeatureReviewCoverageValidation` in H1: pass `-LineSource $thresholds.LineSource -BranchSource $thresholds.BranchSource` in the `Test-LanguageCoverageRow` call (base line 450). Acceptance: H1 parses and the call line contains `-LineSource $thresholds.LineSource`.
- [ ] [P3-T5] In T2, inside `Context 'Test-LanguageCoverageRow'`, add `It 'E4-TR6: <Metric> floor message names <Expected>' -ForEach` with four rows: line/claude-md (`-RepoWidePct 60 -LineFloor 70 -LineSource 'claude-md'`, expects `70% line coverage floor (root CLAUDE.md)`), line/default (`-RepoWidePct 60`, expects `85% line coverage floor (default)`), branch/claude-md (`-RepoWidePct 90 -BranchPct 50 -BranchFloor 60 -BranchSource 'claude-md'`, expects `60% branch coverage floor (root CLAUDE.md)`), branch/default (`-RepoWidePct 90 -BranchPct 50`, expects `75% branch coverage floor (default)`); audit text `Python coverage PASS`; assert `.Reason.Contains($Expected)`. Acceptance: the file parses and holds four `E4-TR6` rows.
- [ ] [P3-T6] In T5, add `It 'E4-ST5: the resolver help names every accepted comparator form'` that parses H4, takes the `Get-FeatureReviewCoverageThreshold` `FunctionDefinitionAst`, reads `GetHelpContent().Description`, collapses whitespace runs to one space, and asserts it contains each P3-T2 token. Acceptance: the file parses and holds one `It` whose name begins `E4-ST5:`.
- [ ] [P3-T7] Copy H1, H3, H4 to their mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`; run CR-SHA over the three pairs; write `<FEATURE>/evidence/other/phase3-mirror.<ts>.md`. Acceptance: `SHA-DIFFER-COUNT: 0`.
- [ ] [P3-T8] Gate (CR-9 regression now passing): run CR-PESTER-LIST with `<LIST>` = T5; no tag filters; `<PATTERNS>` = `E4-TR5-P*`, `E4-TR5-N*`, `T824-*`, `E4-ST5:*`; write `<FEATURE>/evidence/qa-gates/phase3-resolver-pester.<ts>.md`. Acceptance: `NAMED: E4-TR5-P* | Passed=6 | Failed=0`, `NAMED: E4-TR5-N* | Passed=3 | Failed=0`, `NAMED: T824-* | Passed=11 | Failed=0`, `NAMED: E4-ST5:* | Passed=1 | Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P3-T9] Gate: run CR-PESTER-LIST with `<LIST>` = LIST-CLAUDE-SUITES; `<TAGS-OUT>` = `E4-TR1`, `E4-TR4`; `<PATTERNS>` = `E4-TR6*`, `E4-ST4*`, `TG*`, `F824-*`; write `<FEATURE>/evidence/qa-gates/phase3-claude-pester.<ts>.md`. Acceptance: `NAMED: E4-TR6* | Passed=4 | Failed=0`, `TOTAL:` with `Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P3-T10] Check off AC-11 in `<FEATURE>/spec.md` (P1-T5 recorded the base failures of the positive rows; P3-T8 shows all rows passing). Acceptance: only the AC-11 checkbox changed.
- [ ] [P3-T11] Check off AC-12 in `<FEATURE>/spec.md` (P3-T8 `E4-ST5`, P3-T9 `E4-TR6`). Acceptance: only the AC-12 checkbox changed.
- [ ] [P3-T12] Commit and push Phase 3: `git add .claude/hooks/feature-review-coverage-thresholds.ps1 .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/validate-feature-review-coverage-rules.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks tests/scripts/claude-hooks <FEATURE>/evidence <FEATURE>/spec.md`, `git commit -m "fix(896): accept trailing-floor coverage statements and name the floor source (CR-9)"`, `git push origin bug/subagentstop-envelope-feature-review-coverage-896`. Acceptance: `git status --porcelain` prints nothing and HEAD equals the fetched remote branch head.

### Phase 4 — Claude Hook Transport Through the E1 Helper

- [ ] [P4-T1] Edit H1: add the `subagentstop-envelope.ps1` guarded dot-source line quoted under Guarded Dot-Source Literals immediately after the rules line. Acceptance: H1 contains the quoted line verbatim, and it is the fourth guarded dot-source after the guard bootstrap.
- [ ] [P4-T2] Edit `Invoke-FeatureReviewCoverageValidation` in H1: replace `[string] $RawPayload` with `[AllowNull()][AllowEmptyString()][string] $AssistantText`; delete the empty-payload, JSON-parse, and `output` property blocks (base lines 354-368) and use `$AssistantText` where `$agentOutput` was used; make the dependency branch (base lines 351-352) return `@{ Ok = $false; Message = $dependencyDecision.Reason }`; re-prefix the remaining messages from `feature-review hook:` to `validate-feature-review-coverage:` (PI-4). Acceptance: H1 parses, contains no `RawPayload`, no `ConvertFrom-Json`, and no `feature-review hook:` text.
- [ ] [P4-T3] Edit the H1 entry point (base lines 471-477): replace the `CLAUDE_HOOK_INPUT` call and the `Write-Error`/`exit 1` block with `try { $envelope = Read-SubagentStopEnvelope; $result = Invoke-FeatureReviewCoverageValidation -AssistantText $envelope.<AssistantTextProperty> } catch { Exit-SubagentStopBlock -Message "validate-feature-review-coverage: validator error: $($_.Exception.Message); the gate fails closed." }`, then `if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }`, then `exit 0`, where `<AssistantTextProperty>` is the value recorded in the AC-1 artifact (PI-5). Keep the guard checks at base lines 464-469 before the `try`. Acceptance: H1 parses, contains `Read-SubagentStopEnvelope` and `Exit-SubagentStopBlock`, and contains no `Write-Error`, no `exit 1`, and no `CLAUDE_HOOK_INPUT`.
- [ ] [P4-T4] Edit the H1 comment-based help `.NOTES` (base lines 40-42): state that the hook reads the SubagentStop envelope from stdin through `Read-SubagentStopEnvelope`, exits 0 to allow, and blocks through `Exit-SubagentStopBlock` (stderr reason, exit 2) on every block path including validator errors; keep the precedence text with "falls back independently" (base lines 29-35). Acceptance: the H1 help contains `Exit-SubagentStopBlock` and `falls back independently` and no `CLAUDE_HOOK_INPUT`.
- [ ] [P4-T5] Convert T1 `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` lines 26-135: each of the four tests passes the former `output` text directly as `-AssistantText` (for example `Invoke-FeatureReviewCoverageValidation -AssistantText 'Review complete.'`), and no `ConvertTo-Json` payload remains. Acceptance: T1 parses and contains no `RawPayload` and no `CLAUDE_HOOK_INPUT`.
- [ ] [P4-T6] Convert T2 `Context 'Invoke-FeatureReviewCoverageValidation'` (lines 200-280): delete `ConvertTo-ReviewPayload` and the two tests at lines 216-222 (empty and malformed payload); change the empty-output test to `-AssistantText ''`; every other call passes the `Get-ReviewOutput` text or literal as `-AssistantText`. Replace the `Context 'entry point'` test at lines 282-295 (which asserts the `Write-Error` exit-1 path at line 292) with `It 'E4-TR2: the entry point exits 2 when the decision returns Ok false'` that uses `Invoke-ClaudeReviewEntry -Stdin (ConvertTo-ClaudeEnvelope -AssistantText '')` and asserts `ExitCode` 2, stderr beginning `validate-feature-review-coverage:`, and stderr containing `agent output is empty`; move `Invoke-ClaudeReviewEntry` and `ConvertTo-ClaudeEnvelope` from the P1-T1 Context `BeforeAll` to the `Describe`-level `BeforeAll` so both Contexts use them. Acceptance: T2 parses, contains no `RawPayload`, no `CLAUDE_HOOK_INPUT`, and no `Should -Be 1` exit assertion, and contains one `It` whose name begins `E4-TR2:`.
- [ ] [P4-T7] In T2, add `It 'E4-TR3: an unhandled exception in the decision blocks with a validator error and exit 2'` (mock `Get-ArtifactFileContent` to return the three review artifacts, `- scripts/foo.ps1 (+1/-0)` for `artifacts/pr_context.summary.txt`, the text `<report` for `artifacts/pester/powershell-coverage.xml`, and an absent result otherwise; drive the entry with the three-token assistant text; assert `ExitCode` 2 and stderr containing `validator error`) and `It 'E4-TR3b: malformed stdin ends in exit 2'` (stdin `{bad`; assert `ExitCode` 2 and non-empty stderr; additionally assert stderr begins `validate-feature-review-coverage:` when the AC-1 artifact records `MalformedStdinBehavior: throws` or `MalformedStdinBehavior: returns`, and record which branch applied in the gate artifact). Acceptance: T2 parses and contains one `It` each beginning `E4-TR3:` and `E4-TR3b:`.
- [ ] [P4-T8] Convert T3 `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` with the CR-6 helper: in the `Describe` `BeforeAll`, replace `ConvertTo-FeatureReviewPayload` (lines 39-52) with `Get-ReviewAssistantText` (returns the three default artifact lines plus any extra lines joined by newlines), and define `Get-ArtifactFileResult -Lines` (as in T2 lines 25-29) and `Set-ReviewArtifactMap -Override <hashtable>` (sets `$script:ReviewArtifactMap` to the three default artifacts — policy audit `Python coverage PASS`, code review `code`, feature audit `feature` — merged with the overrides; values are multi-line strings). In each of the two F824 Contexts (lines 55-127, 129-256) add a `BeforeEach` with one literal mock: `Mock Get-ArtifactFileContent { param([string] $Path) if ($script:ReviewArtifactMap.ContainsKey($Path)) { Get-ArtifactFileResult -Lines @($script:ReviewArtifactMap[$Path] -split "`n") } else { @{ Exists = $false; Text = $null; Lines = @() } } }`. Rewrite F824-1..F824-8 so each calls `Set-ReviewArtifactMap -Override @{ ... }` with exactly its differing entries (policy-audit text, `artifacts/pr_context.summary.txt`, coverage report, `CLAUDE.md`) and then `Invoke-FeatureReviewCoverageValidation -AssistantText (Get-ReviewAssistantText)`, with each test's original assertions unchanged. Move F824-9 (lines 242-255) into its own `Context` whose `BeforeEach` holds `Mock Get-ArtifactFileContent -MockWith $script:RealGetArtifactFileContent`. In the validation-paths Context, delete rows V1 and V2 (JSON-specific), change V3 to `AssistantText = ''`, change V4-V8 to `AssistantText` strings carrying the former `output` text with real newlines, and call `-AssistantText $AssistantText`. Acceptance: T3 parses, contains no `RawPayload`, no `CLAUDE_HOOK_INPUT`, no `[scriptblock]::Create`, and no `ConvertTo-FeatureReviewPayload`.
- [ ] [P4-T9] Convert T4 `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1`: in `Invoke-ThresholdsGuardHookProcess` (lines 32-50) remove the environment-variable save, set, and restore and instead save `[System.Console]::In`, set it to a `StringReader` over `{"session_id":"tg-896","hook_event_name":"SubagentStop","stop_hook_active":false,"last_assistant_message":""}`, and restore it in `finally`; update the comment at line 33 accordingly; change TG3 (lines 101-120) to call `Invoke-FeatureReviewCoverageValidation -AssistantText ''`, rename it `TG3: <Copy> Invoke-FeatureReviewCoverageValidation returns Ok false when the thresholds dependency failure is recorded`, and assert `$decision.Ok` is false and `$decision.Message` is like `*feature-review-coverage-thresholds.ps1*`. Acceptance: T4 parses and contains no `RawPayload` and no `CLAUDE_HOOK_INPUT`.
- [ ] [P4-T10] In T1, add: `It 'E4-ST1: <File> has no legacy transport or exit-1 block path' -ForEach` over H1, H2, H3 and their three mirrors (six rows; each asserts the file text does not contain `CLAUDE_HOOK_INPUT`, the AST holds no `CommandAst` named `Write-Error`, and no `ExitStatementAst` whose pipeline text is `1`); `It 'E4-ST1: <File> dot-sources the E1 helper through the guarded pattern' -ForEach` over H1 and its mirror (two rows; each asserts the file contains the quoted `subagentstop-envelope.ps1` guarded line); `It 'E4-ST2: Invoke-FeatureReviewCoverageValidation takes AssistantText and not RawPayload'` (asserts `(Get-Command Invoke-FeatureReviewCoverageValidation).Parameters.Keys` contains `AssistantText` and not `RawPayload`); `It 'E4-ST6: the Issue824 suite declares no Get-ArtifactFileContent mock inside an It block'` (parses T3; for every `CommandAst` named `It`, finds no descendant `CommandAst` named `Mock` whose elements include `Get-ArtifactFileContent`; asserts the `Describe`-level `BeforeAll` script block defines functions `Get-ArtifactFileResult` and `Set-ReviewArtifactMap`; asserts the file text does not contain `[scriptblock]::Create`). Acceptance: T1 parses and holds eight `E4-ST1` rows, one `E4-ST2`, and one `E4-ST6`.
- [ ] [P4-T11] Copy H1 to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1`; run CR-SHA over the H1, H2, H3 pairs; write `<FEATURE>/evidence/other/phase4-mirror.<ts>.md`. Acceptance: `SHA-DIFFER-COUNT: 0`.
- [ ] [P4-T12] Gate: run CR-PESTER-LIST with `<LIST>` = LIST-CLAUDE-SUITES; `<TAGS-OUT>` = `E4-TR4`; `<PATTERNS>` = `E4-TR1:*`, `E4-TR2:*`, `E4-TR3:*`, `E4-TR3b:*`, `E4-ST1*`, `E4-ST2:*`, `E4-ST6:*`, `TG1:*`, `TG2:*`, `TG3:*`, `F824-*`, `B1:*validate-feature-review-coverage*`, `B3:*validate-feature-review-coverage*`; write `<FEATURE>/evidence/qa-gates/phase4-transport-pester.<ts>.md` recording the E4-TR3b branch applied. Acceptance: `NAMED: E4-TR1:* | Passed=1 | Failed=0`, `NAMED: E4-TR2:* | Passed=1 | Failed=0`, `NAMED: E4-TR3:* | Passed=1 | Failed=0`, `NAMED: E4-TR3b:* | Passed=1 | Failed=0`, `NAMED: E4-ST1* | Passed=8 | Failed=0`, `NAMED: E4-ST2:* | Passed=1 | Failed=0`, `NAMED: E4-ST6:* | Passed=1 | Failed=0`, `NAMED: TG1:* | Passed=2`, `NAMED: TG3:* | Passed=2`, the `B1` pattern `Failed=0` with `Passed` at least 4, `TOTAL:` with `Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P4-T13] AC-6 search: run `git grep -n -e CLAUDE_HOOK_INPUT -e "-RawPayload" -- tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1`; write `<FEATURE>/evidence/qa-gates/claude-suites-transport-grep.<ts>.md` with `ExpectedExitCode: 1`. The searched literals are "CLAUDE_HOOK_INPUT" and "-RawPayload"; all four files are tracked. Acceptance: no output and `EXIT_CODE: 1`.
- [ ] [P4-T14] Check off AC-2 in `<FEATURE>/spec.md` (P4-T12 `E4-ST1` over repository copies and mirrors). Acceptance: only the AC-2 checkbox changed.
- [ ] [P4-T15] Check off AC-3 in `<FEATURE>/spec.md` (P1-T5 base failure; P4-T12 `E4-TR1` passing). Acceptance: only the AC-3 checkbox changed.
- [ ] [P4-T16] Check off AC-4 in `<FEATURE>/spec.md` (P4-T12 `E4-TR2`, `E4-TR3`, `E4-TR3b`; P4-T6 removed the line-292 exit-1 assertion). Acceptance: only the AC-4 checkbox changed.
- [ ] [P4-T17] Check off AC-5 in `<FEATURE>/spec.md` (P4-T12 `E4-ST2`, `TG1`-`TG3` for both copies). Acceptance: only the AC-5 checkbox changed.
- [ ] [P4-T18] Check off AC-13 in `<FEATURE>/spec.md` (P4-T12 `E4-ST6` and `F824-*` passing). Acceptance: only the AC-13 checkbox changed.
- [ ] [P4-T19] Commit and push Phase 4: `git add .claude/hooks/validate-feature-review-coverage.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks tests/scripts/claude-hooks <FEATURE>/evidence <FEATURE>/spec.md`, `git commit -m "fix(896): read the SubagentStop envelope through the E1 helper and block with exit 2"`, `git push origin bug/subagentstop-envelope-feature-review-coverage-896`. Acceptance: `git status --porcelain` prints nothing and HEAD equals the fetched remote branch head.

AC-6 is checked off in P5-T10, after P5-T8 runs all four Claude hook suites with no tag exclusion.

### Phase 5 — CR-4: Unreadable Root CLAUDE.md Fails Closed

- [ ] [P5-T1] Add `Get-FeatureReviewClaudeMdText` to H2 (`[CmdletBinding()]`, `[OutputType([hashtable])]`, no parameters): `try { $file = Get-ArtifactFileContent -Path 'CLAUDE.md'; return @{ Text = $file.Text; ReadError = $null } } catch { return @{ Text = $null; ReadError = ([string]$_.Exception.Message -split "`r?`n")[0] } }`, with comment-based help stating absent means `Text = $null` and `ReadError = $null`. Acceptance: H2 parses and defines `Get-FeatureReviewClaudeMdText`.
- [ ] [P5-T2] Edit `Invoke-FeatureReviewCoverageValidation` in H1 (base lines 444-445): replace the direct `Get-ArtifactFileContent -Path 'CLAUDE.md'` call with `$claudeMd = Get-FeatureReviewClaudeMdText`; when `$claudeMd.ReadError` is not null return `@{ Ok = $false; Message = "validate-feature-review-coverage: root CLAUDE.md exists but could not be read ($($claudeMd.ReadError)); coverage floors cannot be resolved, so the gate fails closed." }`; otherwise pass `$claudeMd.Text` to `Get-FeatureReviewCoverageThreshold`. Acceptance: H1 parses and contains `Get-FeatureReviewClaudeMdText` and `could not be read`.
- [ ] [P5-T3] Edit the H1 comment-based help to add the two Help-Text Tokens sentences ("an absent root CLAUDE.md uses the defaults"; "an unreadable root CLAUDE.md fails closed") next to the precedence text. Acceptance: the H1 help, whitespace-normalized, contains both sentences and `falls back independently`.
- [ ] [P5-T4] In T2, add `It 'E4-TR4a: an absent root CLAUDE.md applies the 85 and 75 defaults with source default'` (mock `Get-ArtifactFileContent` to return the three artifacts, `- src/foo.py (+1/-0)` for the PR summary, `LF:100`, `LH:80`, `BRF:100`, `BRH:70` lines for `artifacts/python/lcov.info`, and an absent result for `CLAUDE.md`; call `-AssistantText` with the three-token text; assert `Ok` false and `Message` contains `85% line coverage floor (default)` and `75% branch coverage floor (default)`) and `It 'E4-TR4c: the CLAUDE.md reader reports a read error without throwing'` (restore the real `Get-ArtifactFileContent` with `Mock Get-ArtifactFileContent -MockWith $script:RealGetArtifactFileContent`, `Mock Test-Path { $true }`, `Mock Get-Content { throw 'simulated read failure: access denied' }`; assert `Get-FeatureReviewClaudeMdText` returns `Text` null and `ReadError` containing `access denied`). Acceptance: T2 parses and contains one `It` each beginning `E4-TR4a:` and `E4-TR4c:`.
- [ ] [P5-T5] In T1, update the H2 row of `E4-ST4` to the eight names (the seven P2-T1 names plus `Get-FeatureReviewClaudeMdText`). Acceptance: the H2 row lists eight names.
- [ ] [P5-T6] Copy H1 and H2 to their mirrors; run CR-SHA over the H1, H2, H3 pairs; write `<FEATURE>/evidence/other/phase5-mirror.<ts>.md`. Acceptance: `SHA-DIFFER-COUNT: 0`.
- [ ] [P5-T7] Run CR-LINES with `<LIST>` = H1, H2, H3; write `<FEATURE>/evidence/qa-gates/phase5-file-size.<ts>.md`. Acceptance: `LINES-OVER-CAP: 0`.
- [ ] [P5-T8] Gate (no tag exclusion): run CR-PESTER-LIST with `<LIST>` = LIST-CLAUDE-SUITES; `<PATTERNS>` = `E4-TR1:*`, `E4-TR4:*`, `E4-TR4a:*`, `E4-TR4c:*`, `E4-ST4*`, `E4-ST1*`, `TG*`, `F824-*`, `E4-TR5-P*`; write `<FEATURE>/evidence/qa-gates/phase5-cr4-pester.<ts>.md`. Acceptance: `NAMED: E4-TR4:* | Passed=1 | Failed=0`, `NAMED: E4-TR4a:* | Passed=1 | Failed=0`, `NAMED: E4-TR4c:* | Passed=1 | Failed=0`, `NAMED: E4-ST4* | Passed=3 | Failed=0`, `NAMED: E4-TR5-P* | Passed=6 | Failed=0`, `TOTAL:` with `Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P5-T9] Check off AC-7 in `<FEATURE>/spec.md` (P5-T8 `E4-TR4a` and `E4-TR4`; P1-T5 base failure). Acceptance: only the AC-7 checkbox changed.
- [ ] [P5-T10] Check off AC-6 in `<FEATURE>/spec.md` (P4-T13 empty search; P5-T8 all four Claude hook suites passing with no exclusion). Acceptance: only the AC-6 checkbox changed.
- [ ] [P5-T11] Commit and push Phase 5: `git add .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/validate-feature-review-coverage-metrics.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks tests/scripts/claude-hooks <FEATURE>/evidence <FEATURE>/spec.md`, `git commit -m "fix(896): fail closed on an unreadable root CLAUDE.md (CR-4)"`, `git push origin bug/subagentstop-envelope-feature-review-coverage-896`. Acceptance: `git status --porcelain` prints nothing and HEAD equals the fetched remote branch head.

### Phase 6 — Codex Hook Floor Source (#884 Codex half)

- [ ] [P6-T1] Create H6 `.codex/hooks/feature-review-coverage-thresholds.ps1` with `Copy-Item -LiteralPath .claude/hooks/feature-review-coverage-thresholds.ps1 -Destination .codex/hooks/feature-review-coverage-thresholds.ps1`; run CR-SHA over that pair; write `<FEATURE>/evidence/other/phase6-thresholds-copy.<ts>.md`. Acceptance: one `SHA:` line ending `MATCH`.
- [ ] [P6-T2] Edit H5 `.codex/hooks/validate-feature-review-coverage.ps1`: add the H5 guarded dot-source line quoted under Guarded Dot-Source Literals immediately after line 43. Acceptance: H5 contains the quoted line verbatim on the line after the guard bootstrap.
- [ ] [P6-T3] Edit `Test-LanguageCoverageRow` in H5 (lines 142-207): add `[double] $LineFloor = 85.0`; replace `-lt 80.0` (line 196) with `-lt $LineFloor`; replace the line-201 message with `("{0} repo-wide coverage is {1}% (below the {2}% line coverage floor) but the policy-audit contains no FAIL verdict on a coverage row for {0}." -f $Language, $RepoWidePct, $LineFloor)`. Acceptance: H5 parses, `Test-LanguageCoverageRow` declares `LineFloor`, and the function body contains no `80.0`.
- [ ] [P6-T4] Edit the H5 entry (lines 264-290): after the `$changedLanguages.Count -eq 0` exit (line 267-269), add `$claudeMdPath = Join-Path $repoRoot 'CLAUDE.md'`, `$claudeMdText = $null`, `if (Test-Path -Path $claudeMdPath) { try { $claudeMdText = Get-Content -Path $claudeMdPath -Raw -ErrorAction Stop } catch { throw "root CLAUDE.md exists but could not be read ($(([string]$_.Exception.Message -split "`r?`n")[0])); coverage floors cannot be resolved, so the gate fails closed." } }`, and `$thresholds = Get-FeatureReviewCoverageThreshold -ClaudeMdText $claudeMdText`; pass `-LineFloor $thresholds.Line` in the line-275 call; replace the line-284 footer text `below 80%` with `below the governing line coverage floor ($($thresholds.Line)%)`. Use `-Path` (not `-LiteralPath`) and no `-PathType` argument, matching the existing Codex reads (for example line 69) and the existing mocks' `param($Path)` binding. Keep the stdin read, `stop_hook_active` handling, continuation output, and catch (lines 237-262, 286-304) unchanged. Acceptance: H5 parses, contains `Get-FeatureReviewCoverageThreshold`, and contains no `80%`.
- [ ] [P6-T5] Edit the H5 comment-based help (lines 22-25): replace the 80-percent text with the governing-floor statement (root `CLAUDE.md` line threshold when stated, otherwise the 85 percent default; the Codex hook enforces the line floor only) including the two Help-Text Tokens sentences. Acceptance: the H5 help, whitespace-normalized, contains both sentences, and H5 contains none of `80.0`, `80%`, `80 percent`.
- [ ] [P6-T6] In T6, change the `low coverage without FAIL` row (line 135) pattern from `below the 80% floor` to `below the 85% line coverage floor`. Acceptance: T6 contains no `80% floor` text.
- [ ] [P6-T7] In T6 `Context 'entry point'`, add `It 'E4-TR8: a CLAUDE.md line floor of 70 lets a 72% row pass'` (mocks as in P1-T4 with `LF:100`, `LH:72` for `lcov.info` and `Line coverage >= 70%` for `CLAUDE.md`; assert `ExitCode` 0 and empty `Stdout`) and `It 'E4-TR9: an unreadable CLAUDE.md <Case>' -ForEach` with two rows: `stop_hook_active false exits 2` (stdin `$script:ReviewStop`; `Get-Content` throws `simulated read failure: access denied` for paths ending `CLAUDE.md`; assert `ExitCode` 2 and `Stderr` containing `root CLAUDE.md` and `could not be read`) and `stop_hook_active true emits continue false` (stdin `$script:ReviewStopActive`; assert `ExitCode` 0 and `Stdout` containing `"continue":false`). Add `It 'E4-ST7: the Codex hook reads the floor from its own thresholds copy'` that reads H5 and asserts: the text contains the H5 guarded line; no dot-source `CommandAst` (invocation operator `Dot`) has an extent containing `.claude`; the text contains neither `subagentstop-envelope.ps1` nor `Exit-SubagentStopBlock`; the text contains none of `80.0`, `80%`, `80 percent`. Acceptance: T6 parses and contains one `E4-TR8:` test, two `E4-TR9:` rows, and one `E4-ST7:` test.
- [ ] [P6-T8] Create T7 `tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1` (Pester 5; `#Requires -Version 7.0`; header help stating the determinism rules): `It 'E4-PX2: the four thresholds copies are byte-identical'` asserting equal `Get-FileHash -Algorithm SHA256` values for `.claude/hooks/feature-review-coverage-thresholds.ps1`, `.codex/hooks/feature-review-coverage-thresholds.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/feature-review-coverage-thresholds.ps1` (located from `$PSScriptRoot` with `Join-Path`); and `It 'E4-PX2-<Id> the Codex copy resolves <Label>' -ForEach` carrying the eleven T824 rows of T5 lines 28-38 and the nine E4-TR5 rows of P1-T3, run against the `.codex/hooks/` copy dot-sourced in `BeforeAll`. Acceptance: T7 parses and holds one hash test and twenty resolver rows.
- [ ] [P6-T9] Edit T9 `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 30: append `, 'feature-review-coverage-thresholds.ps1'` inside the `$script:SharedModuleNames` array on the same line. Acceptance: CR-LINES on T9 reports `count=497`, and line 30 contains `'feature-review-coverage-thresholds.ps1'`.
- [ ] [P6-T10] Edit P2 `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`: insert `".codex/hooks/feature-review-coverage-thresholds.ps1",` after line 46 (`.codex/hooks/feature-folder-resolution.ps1`). Acceptance: the file parses with `ConvertFrom-Json` and `.paths` contains the new string.
- [ ] [P6-T11] Copy H5 and H6 to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, and copy H4 to its Claude mirror if P3-T7 left it unequal; run CR-SHA over the H4, H5, H6 pairs and the `.claude`-to-`.codex` thresholds pair; write `<FEATURE>/evidence/other/phase6-mirror.<ts>.md`. Acceptance: four `SHA:` lines ending `MATCH` and `SHA-DIFFER-COUNT: 0`.
- [ ] [P6-T12] In T1, add `It 'E4-ST3: <File> help states the absent and unreadable CLAUDE.md rules' -ForEach` over H1 and H5: each row reads the file's first comment block (the script-level help), collapses whitespace runs to one space, and asserts it contains "an absent root CLAUDE.md uses the defaults" and "an unreadable root CLAUDE.md fails closed"; the H1 row also asserts "falls back independently". Acceptance: T1 parses and holds two `E4-ST3` rows.
- [ ] [P6-T13] Gate: run CR-PESTER-LIST with `<LIST>` = T6, T7, T9, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`, `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, T1; no tag filters; `<PATTERNS>` = `E4-TR7:*`, `E4-TR8:*`, `E4-TR9:*`, `E4-ST7:*`, `E4-PX2*`, `E4-ST3*`, `uses one SubagentStop continuation*`; write `<FEATURE>/evidence/qa-gates/phase6-codex-pester.<ts>.md`. Acceptance: `NAMED: E4-TR7:* | Passed=1 | Failed=0`, `NAMED: E4-TR8:* | Passed=1 | Failed=0`, `NAMED: E4-TR9:* | Passed=2 | Failed=0`, `NAMED: E4-ST7:* | Passed=1 | Failed=0`, `NAMED: E4-PX2* | Passed=21 | Failed=0`, `NAMED: E4-ST3* | Passed=2 | Failed=0`, the continuation pattern `Passed=1`, `TOTAL:` with `Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P6-T14] AC-17 configuration check: run `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD -- .codex/config.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` and `git status --porcelain -- .codex/config.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`; write `<FEATURE>/evidence/qa-gates/codex-config-unchanged.<ts>.md`. Acceptance: both commands print nothing.
- [ ] [P6-T15] Check off AC-14 in `<FEATURE>/spec.md` (P6-T13 `E4-PX2`). Acceptance: only the AC-14 checkbox changed.
- [ ] [P6-T16] Check off AC-15 in `<FEATURE>/spec.md` (P6-T13 `E4-ST7`). Acceptance: only the AC-15 checkbox changed.
- [ ] [P6-T17] Check off AC-16 in `<FEATURE>/spec.md` (P1-T5 base failure of `E4-TR7`; P6-T13 `E4-TR7`, `E4-TR8`, `E4-TR9`). Acceptance: only the AC-16 checkbox changed.
- [ ] [P6-T18] Check off AC-17 in `<FEATURE>/spec.md` (P6-T13 legacy, dependency-failure, and probe suites passing; P6-T14 empty diff). Acceptance: only the AC-17 checkbox changed.
- [ ] [P6-T19] Commit and push Phase 6: `git add .codex/hooks/validate-feature-review-coverage.ps1 .codex/hooks/feature-review-coverage-thresholds.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json extensions/drm-copilot/resources/claude-customizations/.claude/hooks tests/scripts/codex-hooks tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 <FEATURE>/evidence <FEATURE>/spec.md`, `git commit -m "fix(896): read the Codex feature-review line floor from root CLAUDE.md (Refs #884)"`, `git push origin bug/subagentstop-envelope-feature-review-coverage-896`. Acceptance: `git status --porcelain` prints nothing and HEAD equals the fetched remote branch head.

### Phase 7 — Claude and Codex Floor Parity

- [ ] [P7-T1] Create T8 `tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1` (Pester 5; header help): define `Get-FloorFromReason` (returns the number captured by `below the (?<floor>\d+(?:\.\d+)?)% line coverage floor`); define `Get-ClaudeFloorReason -ClaudeMdText` as `& { param($HookPath, $Text) . $HookPath; $t = Get-FeatureReviewCoverageThreshold -ClaudeMdText $Text; (Test-LanguageCoverageRow -AuditText 'Python coverage PASS' -Language 'Python' -RepoWidePct 60 -LineFloor $t.Line -LineSource $t.LineSource).Reason } <H1 path> $ClaudeMdText` and `Get-CodexFloorReason -ClaudeMdText` with the same shape over the H5 path and `-LineFloor $t.Line` (so each hook loads in its own child scope); add `It 'E4-PX1: <Label> reports line floor <Floor> on both surfaces' -ForEach` with rows `no figure` (`Project notes without coverage figures.`, 85), `comparator form` (`Line coverage >= 70%`, 70), `trailing form` (`line coverage: 92% minimum`, 92), each asserting the Claude floor equals the Codex floor equals the row's `Floor`. Acceptance: T8 parses and holds three `E4-PX1` rows.
- [ ] [P7-T2] Gate: run CR-PESTER-LIST with `<LIST>` = T8; `<PATTERNS>` = `E4-PX1*`; write `<FEATURE>/evidence/qa-gates/phase7-parity-pester.<ts>.md`. Acceptance: `NAMED: E4-PX1* | Passed=3 | Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P7-T3] Check off AC-19 in `<FEATURE>/spec.md`. Acceptance: only the AC-19 checkbox changed.
- [ ] [P7-T4] Commit and push Phase 7: `git add tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1 <FEATURE>/evidence <FEATURE>/spec.md`, `git commit -m "test(896): pin Claude and Codex feature-review floor parity"`, `git push origin bug/subagentstop-envelope-feature-review-coverage-896`. Acceptance: `git status --porcelain` prints nothing and HEAD equals the fetched remote branch head.

### Phase 8 — Skill and Agent Texts

- [ ] [P8-T1] Edit S1 `.agents/skills/feature-review-workflow/SKILL.md` lines 111-114: replace the four threshold lines with "Coverage thresholds: when the repository's root `CLAUDE.md` states a line or branch coverage threshold, that threshold governs; otherwise the defaults govern (line 85%, branch 75% for branch-capable languages). Each metric falls back independently. New files and modified files must meet the governing line threshold (and the branch threshold where measured); modified files must also show no regression on changed lines. Repo-wide coverage per language must meet the governing thresholds. Flag as FAIL otherwise." (research Q9, `research.2026-10-11T08-10.md:312`), keeping the list indentation of line 111. Acceptance: S1 lines in the step-5 block contain `CLAUDE.md`, `85%`, `75%`, and no `80%` or `90%`.
- [ ] [P8-T2] Edit S1 line 148: replace it with "coverage below the governing thresholds defined in step 5 (repo-wide per language, modified files including any regression on changed lines, or new files)", keeping its indentation. Acceptance: S1 contains no `80%` and no `90%`.
- [ ] [P8-T3] Edit S2 `.github/skills/feature-review-workflow/SKILL.md` line 126: replace it with "coverage below the governing thresholds (the root `CLAUDE.md` thresholds when stated, otherwise the defaults: line 85%, branch 75% for branch-capable languages; repo-wide per language, modified files including any regression on changed lines, or new files)", keeping its indentation. Acceptance: S2 contains `CLAUDE.md`, `85%`, `75%`, `governing thresholds`, and no `80%` or `90%`.
- [ ] [P8-T4] Edit S3 `.codex/agents/feature-review.toml` lines 121-123: replace the three bullets with the P8-T1 statement adapted to bullets (root `CLAUDE.md` governs when it states a threshold; otherwise line 85% and branch 75% for branch-capable languages; each metric falls back independently; new and modified files meet the governing line threshold; modified files show no regression on changed lines; repo-wide coverage meets the governing thresholds). Acceptance: S3 lines 119-125 contain `CLAUDE.md`, `85%`, `75%`.
- [ ] [P8-T5] Edit S3 lines 133-135: replace each fixed figure with "below the governing line threshold" wording (repo-wide; each new file; each modified file, including regression from baseline). Acceptance: S3 contains no `80%` and no `90%`.
- [ ] [P8-T6] Copy S1 to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`, S2 to `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`, S3 to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml`; run CR-SHA over the three pairs; write `<FEATURE>/evidence/other/phase8-mirror.<ts>.md`. Acceptance: `SHA-DIFFER-COUNT: 0`.
- [ ] [P8-T7] Edit T10 `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`: extend `STEP_EIGHT_COPIES` (lines 70-73) with `".agents/skills/feature-review-workflow/SKILL.md"`, `CODEX_BUNDLE + ".agents/skills/feature-review-workflow/SKILL.md"`, `".github/skills/feature-review-workflow/SKILL.md"`, `GITHUB_BUNDLE + ".github/skills/feature-review-workflow/SKILL.md"`; set `EXPECTED_LISTED_COPY_COUNT` (line 94) to `40`; add `FEATURE_REVIEW_TEXT_COPIES` (the six `feature-review-workflow/SKILL.md` copies and both `.codex/agents/feature-review.toml` copies), `CLAUDE_MD_FLOOR_SOURCE = "CLAUDE.md"`, `DEFAULT_FLOOR_FIGURES = ("85%", "75%")`, and a fully annotated `@pytest.mark.parametrize("relative_path", FEATURE_REVIEW_TEXT_COPIES)` test `test_feature_review_texts_name_claude_md_floor_source(relative_path: str) -> None` with a docstring and Arrange/Act/Assert sections asserting the file contains neither `80%` nor `90%`, contains `CLAUDE.md`, and contains `85%` and `75%`. Do not add the new tuple to the `listed` tuple of `test_every_follow_up_copy_exists`. Acceptance: the module parses (`poetry run python -m py_compile tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` exits 0) and stays below 500 lines.
- [ ] [P8-T8] Gate: run `poetry run pytest "tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_feature_review_texts_name_claude_md_floor_source"`; write `<FEATURE>/evidence/qa-gates/phase8-texts-pytest.<ts>.md`. Acceptance: the summary line reads `8 passed` with no failure.
- [ ] [P8-T9] Gate: run `poetry run pytest "tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_review_workflow_step_eight_uses_governing_thresholds" "tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_every_follow_up_copy_exists"`; write `<FEATURE>/evidence/qa-gates/phase8-step-eight-pytest.<ts>.md`. Acceptance: the summary line reads `7 passed` with no failure (six step-8 copies plus the existence test).
- [ ] [P8-T10] Gate: run `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`; write `<FEATURE>/evidence/qa-gates/phase8-module-pytest.<ts>.md`. Acceptance: the summary line has a numeric `passed` count and no `failed` count.
- [ ] [P8-T11] AC-22 check: run `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD -- .github/instructions .claude/rules` and `git status --porcelain -- .github/instructions .claude/rules`; write `<FEATURE>/evidence/qa-gates/policy-files-unchanged.<ts>.md`. Acceptance: both commands print nothing.
- [ ] [P8-T12] Check off AC-20 in `<FEATURE>/spec.md` (P8-T8). Acceptance: only the AC-20 checkbox changed.
- [ ] [P8-T13] Check off AC-21 in `<FEATURE>/spec.md` (P8-T9). Acceptance: only the AC-21 checkbox changed.
- [ ] [P8-T14] Check off AC-22 in `<FEATURE>/spec.md` (P8-T11). Acceptance: only the AC-22 checkbox changed.
- [ ] [P8-T15] Check off AC-8 in `<FEATURE>/spec.md` (P6-T13 `E4-ST3`; P8-T10 `test_push_down_issue_824_follow_ups.py` passing; spec Proposed Fix item 4 records the supersession of the #824 spec line 122). Acceptance: only the AC-8 checkbox changed.
- [ ] [P8-T16] Commit and push Phase 8: `git add .agents/skills/feature-review-workflow/SKILL.md .github/skills/feature-review-workflow/SKILL.md .codex/agents/feature-review.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py <FEATURE>/evidence <FEATURE>/spec.md`, `git commit -m "docs(896): name root CLAUDE.md as the feature-review floor source in skill and agent texts"`, `git push origin bug/subagentstop-envelope-feature-review-coverage-896`. Acceptance: `git status --porcelain` prints nothing and HEAD equals the fetched remote branch head.

### Phase 9 — Mirror and Manifest Verification

- [ ] [P9-T1] Run CR-SHA with `<PAIRS>` = all nine LIST-MIRROR-PAIRS entries; write `<FEATURE>/evidence/other/mirror-log.<ts>.md` (AC-23) with every `SHA:` line verbatim, including the `.github/skills/feature-review-workflow/SKILL.md` pair, which has no automated parity test. Acceptance: nine `SHA:` lines ending `MATCH` and `SHA-DIFFER-COUNT: 0`.
- [ ] [P9-T2] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`; write `<FEATURE>/evidence/qa-gates/mirror-parity-pytest.<ts>.md`. Acceptance: numeric `passed` count and no `failed` count.
- [ ] [P9-T3] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py`; write `<FEATURE>/evidence/qa-gates/manifest-pytest.<ts>.md`. Acceptance: numeric `passed` count and no `failed` count.
- [ ] [P9-T4] Check off AC-9 in `<FEATURE>/spec.md` (P5-T8 `E4-ST4`; P9-T3 Claude manifest completeness). Acceptance: only the AC-9 checkbox changed.
- [ ] [P9-T5] Check off AC-18 in `<FEATURE>/spec.md` (P9-T3 Codex manifest completeness; P6-T13 legacy contracts passing; P6-T9 `count=497`). Acceptance: only the AC-18 checkbox changed.
- [ ] [P9-T6] Check off AC-23 in `<FEATURE>/spec.md` (P9-T1, P9-T2). Acceptance: only the AC-23 checkbox changed.
- [ ] [P9-T7] Commit and push Phase 9: `git add <FEATURE>/evidence <FEATURE>/spec.md`, `git commit -m "docs(896): record mirror and manifest verification"`, `git push origin bug/subagentstop-envelope-feature-review-coverage-896`. Acceptance: `git status --porcelain` prints nothing and HEAD equals the fetched remote branch head.

### Phase 10 — Final QC Loop (PowerShell and Python)

Loop rule: run P10-T1 through P10-T9 in order. If any step fails, or P10-T1 reports a non-zero `FORMAT-APPLIED-COUNT`, or P10-T3 reports `reformatted`, fix the cause, re-copy any changed mirrored file to its mirror, and restart from P10-T1. Number each pass in the artifact names (`pass<k>`). The loop is complete only when one pass runs P10-T1 through P10-T9 with no failure and no file change.

- [ ] [P10-T1] PowerShell format (write mode): run CR-FORMAT-APPLY with `<LIST>` = LIST-PROD plus LIST-TEST; write `<FEATURE>/evidence/qa-gates/final-format.pass<k>.<ts>.md`. Acceptance for a clean pass: one `FORMAT-UNCHANGED:` line per file and `FORMAT-APPLIED-COUNT: 0`; also record `git status --porcelain` before and after, which must be identical.
- [ ] [P10-T2] PowerShell lint: run CR-PSSA with `<LIST>` = LIST-PROD plus LIST-TEST; write `<FEATURE>/evidence/qa-gates/final-pssa.pass<k>.<ts>.md`. Acceptance: one `PSSA:` line per file with `findings=0`, `PSSA-TOTAL: 0`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P10-T3] Python format (write mode): run `poetry run black tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/qa-gates/final-python-black.pass<k>.<ts>.md`. Acceptance for a clean pass: the output contains `1 file left unchanged` and does not contain `reformatted`.
- [ ] [P10-T4] Python lint: run `poetry run ruff check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/qa-gates/final-python-ruff.pass<k>.<ts>.md`. Acceptance: the output contains `All checks passed!` and `EXIT_CODE: 0`.
- [ ] [P10-T5] Python type check: run `poetry run pyright tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/qa-gates/final-python-pyright.pass<k>.<ts>.md`. Acceptance: the summary line reports `0 errors` and `EXIT_CODE: 0`.
- [ ] [P10-T6] Targeted Pester over every in-scope suite: run CR-PESTER-LIST with `<LIST>` = LIST-CLAUDE-SUITES plus LIST-CODEX-SUITES plus LIST-AUX; no tag filters; `<PATTERNS>` = `E4-TR*`, `E4-ST*`, `E4-PX*`, `TG*`, `F824-*`, `T824-*`; write `<FEATURE>/evidence/qa-gates/final-pester-targeted.pass<k>.<ts>.md` and compare each `SUITE:` line with P0-T11. Acceptance: `TOTAL:` with `Failed=0`, `EXIT_CODE_COMPUTED: 0`, and every suite present in P0-T11 present here.
- [ ] [P10-T7] Full-population Pester with coverage: run CR-POSHQC-FULL through the scratchpad route, then CR-JUNIT; write `<FEATURE>/evidence/qa-gates/final-pester-full-run.pass<k>.<ts>.md` with the `Tests Passed:`, `Covered`, and `JUNIT:` lines verbatim. Acceptance: the `Tests Passed:` line contains `Failed: 0,`, `JUNIT:` shows `failures=0 | errors=0`, `EXIT_CODE_COMPUTED: 0`; this run includes `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` and `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` through the `tests/scripts` run path (`pester.runsettings.psd1:3`). A failure that P0-T12 listed as `PRE-EXISTING:` with the same test name is recorded, not fixed, and leaves AC-28 unchecked.
- [ ] [P10-T8] Per-file coverage (AC-25 final half), immediately after P10-T7 with no Pester run in between: run CR-COV-FILES with `<LIST>` = LIST-PROD; write `<FEATURE>/evidence/qa-gates/final-pester-coverage.<ts>.md`. Acceptance: six `COVERAGE:` lines with numeric values, each `pct=` at least 85.00, `COVERAGE-BELOW-85: NONE`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P10-T9] Python contract tests: run PYTEST-SPEC, then `poetry run pytest tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`; write `<FEATURE>/evidence/qa-gates/final-pytest-contracts.pass<k>.<ts>.md` with both summary lines. Acceptance: both summary lines have a numeric `passed` count and no `failed` count.
- [ ] [P10-T10] Write `<FEATURE>/evidence/qa-gates/final-qc-loop.<ts>.md` listing each pass number, the artifacts of the clean pass, and the restart causes of earlier passes. Acceptance: the artifact names one pass in which P10-T1 through P10-T9 all met their acceptance with no file change.
- [ ] [P10-T11] Commit and push Phase 10: `git add <FEATURE>/evidence` plus any file changed by a restarted pass (named explicitly in the commit), `git commit -m "docs(896): record final QC loop"`, `git push origin bug/subagentstop-envelope-feature-review-coverage-896`. Acceptance: `git status --porcelain` prints nothing and HEAD equals the fetched remote branch head.

### Phase 11 — Verification Records and Acceptance-Criteria Check-off

- [ ] [P11-T1] File sizes (AC-10): run CR-LINES with `<LIST>` = LIST-PROD plus LIST-TEST plus `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/qa-gates/file-size.<ts>.md`, stating the 300-line design target and the count of each production file. Acceptance: `LINES-OVER-CAP: 0`; each of H1, H2, H3 reports `WITHIN-TARGET`; T9 reports `count=497`; any `OVER-TARGET` production file (expected: H5) is named with its count.
- [ ] [P11-T2] Coverage delta: run CR-COV-CHANGED with `<LIST>` = LIST-PROD (after the Phase 10 commit; `artifacts/pester/powershell-coverage.xml` is the P10-T7 output); write `<FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md` containing a table of baseline `pct=` (P0-T13; `NEW` for H2, H3, H6), post-change `pct=` (P10-T8), and changed-line `pct=` (this task) per file. Acceptance: six `CHANGED-COVERAGE:` lines, `CHANGED-BELOW-85: NONE`, `EXIT_CODE_COMPUTED: 0`, and no post-change figure below 85.00.
- [ ] [P11-T3] Fail-first head run (AC-24): run CR-PESTER-LIST with `<LIST>` = T2, T5, T6; `<TAGS-IN>` = `E4-Regression`; `<PATTERNS>` = `E4-TR1:*`, `E4-TR4:*`, `E4-TR5-P*`, `E4-TR7:*`; write `<FEATURE>/evidence/qa-gates/fail-first-head-run.<ts>.md`, and append a `## Branch-head run` section to the P1-T5 artifact with the command, the `NAMED:` lines, and `HEAD_RUN_EXIT_CODE:`. Acceptance: `NAMED: E4-TR1:* | Passed=1 | Failed=0`, `NAMED: E4-TR4:* | Passed=1 | Failed=0`, `NAMED: E4-TR5-P* | Passed=6 | Failed=0`, `NAMED: E4-TR7:* | Passed=1 | Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P11-T4] Constraints, part 1 (AC-26, PI-1 check (a)): run `git diff --name-only --diff-filter=A origin/epic/subagentstop-envelope-integration...HEAD -- .claude/hooks .codex/hooks` and `git status --porcelain -- .claude/hooks .codex/hooks`; create `<FEATURE>/evidence/qa-gates/constraints.<ts>.md` with both outputs. Acceptance: the diff lists exactly `.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `.claude/hooks/validate-feature-review-coverage-rules.ps1`, `.codex/hooks/feature-review-coverage-thresholds.ps1`, none ending `.py`, and the status command prints nothing.
- [ ] [P11-T5] Constraints, part 2 (PI-1 check (b)): run CR-PY-TOKEN with `$Mode = 'final'`; append to the constraints artifact. Acceptance: three `PY-TOKEN:` lines ending `NOT-INCREASED`, `PY-TOKEN-INCREASED-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P11-T6] Constraints, part 3 (PI-1 check (c)): run CR-PESTER-LIST with `<LIST>` = LIST-AUX; append to the constraints artifact. Acceptance: `TOTAL:` with `Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [ ] [P11-T7] Constraints, part 4 (temporary-file tokens): run `git grep -n -F -e New-TemporaryFile -e GetTempFileName -e TestDrive -e '$env:TEMP' -- tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` (single-quoted so PowerShell does not expand the variable); append to the constraints artifact with `ExpectedExitCode: 1` for this step. Acceptance: no output and exit code 1.
- [ ] [P11-T8] Scope boundary (AC-27): run `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD` and `git status --porcelain`; write `<FEATURE>/evidence/qa-gates/scope-boundary.<ts>.md` with the full list and a check line per forbidden path (the nine E2/E3 validator files under `.claude/hooks/` and their mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `.claude/settings.json`, `.claude/hooks/subagentstop-envelope.ps1` and its mirror, `.claude/lib/bash/compute-concurrency-batches.sh`, and the prefix `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/`). Acceptance: every check line reads `ABSENT` and `git status --porcelain` prints nothing.
- [ ] [P11-T9] Write `<FEATURE>/evidence/other/ac-29-handoff.<ts>.md` stating the AC-29 requirements for the later PR body (`Refs #884` and `Refs #897` present; no closing keyword adjacent to `#884` or `#897`; a closing keyword permitted for `#896` only) and that AC-29 is verified at PR time under the epic orchestrator from `gh pr view <number> --json body` recorded in `<FEATURE>/evidence/issue-updates/`. Acceptance: the artifact exists with those three requirements; AC-29 stays unchecked.
- [ ] [P11-T10] Check off AC-10 in `<FEATURE>/spec.md` (P11-T1). Acceptance: only the AC-10 checkbox changed.
- [ ] [P11-T11] Check off AC-24 in `<FEATURE>/spec.md` (P1-T5 and P11-T3). Acceptance: only the AC-24 checkbox changed.
- [ ] [P11-T12] Check off AC-25 in `<FEATURE>/spec.md` (P0-T13 and P10-T8). Acceptance: only the AC-25 checkbox changed.
- [ ] [P11-T13] Check off AC-26 in `<FEATURE>/spec.md` (P11-T4 through P11-T7 under PI-1; the constraints artifact restates PI-1). Acceptance: only the AC-26 checkbox changed.
- [ ] [P11-T14] Check off AC-27 in `<FEATURE>/spec.md` (P11-T8). Acceptance: only the AC-27 checkbox changed.
- [ ] [P11-T15] Check off AC-28 in `<FEATURE>/spec.md` only if the P10-T10 clean pass shows `FORMAT-APPLIED-COUNT: 0`, `PSSA-TOTAL: 0`, full-run `failures=0 | errors=0`, and PYTEST-SPEC passing with no `PRE-EXISTING:` exception. Acceptance: only the AC-28 checkbox changed, or it stays unchecked with the reason recorded in `<FEATURE>/evidence/qa-gates/final-qc-loop.<ts>.md`.
- [ ] [P11-T16] Write the AC status summary per `acceptance-criteria-tracking` into `<FEATURE>/evidence/other/ac-status.<ts>.md` (source `spec.md`; total 29; checked count; remaining list, expected to be AC-29 only). Acceptance: the counts equal the number of `- [x] AC-` and `- [ ] AC-` lines in `<FEATURE>/spec.md`.
- [ ] [P11-T17] Commit and push Phase 11: `git add <FEATURE>/evidence <FEATURE>/spec.md`, `git commit -m "docs(896): record verification evidence and acceptance-criteria status"`, `git push origin bug/subagentstop-envelope-feature-review-coverage-896`. Acceptance: `git status --porcelain` prints nothing and HEAD equals the fetched remote branch head.

PR authoring, CI monitoring, and feature review are out of this plan's scope; they run later under the epic orchestrator, which verifies AC-29 at PR time.

## Planner Self-Review

SELF-REVIEW: RE-DERIVED THIS PASS

Citations re-derived against the current tree in this pass (file and locator):

1. `.claude/hooks/validate-feature-review-coverage.ps1` — 477 lines; help lines 29-35 ("falls back independently" at 33) and 40-42; guard line 46; thresholds dot-source line 47; `$ErrorActionPreference` line 49; functions at 51, 75, 106, 131, 150, 171, 196, 218, 231, 253, 268, 345; floor messages 330 and 338; `-LineFloor`/`-BranchFloor` defaults 275-276; `feature-review hook:` messages 355, 362, 370, 433, 457; `CLAUDE.md` read 444-445; row call 450; entry 464-477 (`CLAUDE_HOOK_INPUT` 471, `Write-Error` 473, `exit 1` 474); `python` on lines 23, 142, 224, 261, 281.
2. `.claude/hooks/feature-review-coverage-thresholds.ps1` — 77 lines; help 19-41 (forms 22-36); defaults 48; regex 57; match loop 58-66.
3. `.codex/hooks/validate-feature-review-coverage.ps1` — 304 lines; help 22-25 (80 percent); guard 43; `Test-LanguageCoverageRow` 142-207 (`80.0` at 196, message 201); continuation 209-228; entry 237-304 (stdin 238, changed-language exit 267-269, row call 275, footer 284, catch 294-304); `python` on lines 15, 77, 135, 152.
4. `.claude/hooks/hook-dependency-guard.ps1` — lines 8-10 (fail-closed purpose), 104-105 (SubagentStop decision shape `ExitCode`/`Reason`).
5. `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` — 296 lines; `Get-ArtifactFileResult` 25-29; `Test-LanguageCoverageRow` context 170-198; Invoke context 200-280 (empty/malformed tests 216-222); entry test 282-295 (exit-1 comment 292).
6. `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` — 135 lines; tests 26-135 using `-RawPayload`.
7. `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` — 289 lines; comment line 8; helper 39-52; F824-1..8 `It` blocks 56, 79, 103, 130, 153, 176, 198, 220; F824-9 242-255 with an in-`It` mock at 244; V rows 269-287.
8. `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` — 121 lines; process helper 32-50 (env var 36-47); TG1 59-75; TG3 101-120 (`-RawPayload` 113; `ExitCode`/`Reason` 118-119).
9. `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` — 51 lines; T824 rows 28-38; body 39-50.
10. `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` — 199 lines; stdin helper 26-43; `$script:ReviewStop` 45-46; row pattern `below the 80% floor` 135; entry context 150-198 (synthetic audit object 183).
11. `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — 497 lines; `$script:SharedModuleNames` line 30; 500-line check 96-112; hash identity 114-120; `$env:CLAUDE_` check 130-135; manifest presence 137-142; continuation test 285-296.
12. `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` — AST edge discovery 18-33; reason prefix 97; B1 134-164; B3 183-190.
13. `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` — first-edge selection 30-32; `StopPrefix` 53-58.
14. `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` — 357 lines; bundles 27-29; `STEP_EIGHT_COPIES` 70-73; `FALLBACK_COPIES` 78-93 (hook at 91-92); `EXPECTED_LISTED_COPY_COUNT = 36` line 94; existence test 181-197; step-8 test 241-257.
15. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — entries 59 (thresholds), 70 (`validate-executor-output.ps1`), 71 (`validate-feature-review-coverage.ps1`).
16. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` — entries 46 (`feature-folder-resolution.ps1`), 68 (`validate-feature-review-coverage.ps1`).
17. `.agents/skills/feature-review-workflow/SKILL.md` — fixed figures 112, 113, 114, 148; threshold header 111; step 8 at 142.
18. `.github/skills/feature-review-workflow/SKILL.md` — fixed figures 126; step 8 at 120.
19. `.codex/agents/feature-review.toml` — fixed figures 121, 122, 123, 133, 134, 135; section header 119.
20. `.claude/skills/feature-review-workflow/SKILL.md` — `CLAUDE.md` 111; defaults 112-114; step 8 at 143; `governing thresholds` 149; no `80%`/`90%` (search over the six skill copies and two TOML copies returned the 22 lines of research N1 only).
21. `docs/features/epics/subagentstop-envelope/epic.md` — Shared Design 75-90 (helper 80-81, read 82-84, block 85, no env 86-87, governance 89-90).
22. `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` — format comparison and log literals 56-66; analyzer pass literal 185.
23. `scripts/powershell/PoshQC/PoshQC.psm1` — settings path line 2 (`settings/pssa.settings.psd1`).
24. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — run paths line 3; `Exit = $true` line 4; JUnit path 15; coverage output 22.
25. `config/poshqc-coverage.json` — roots 3-9 (`.claude/hooks`, `.codex/hooks` included).
26. `docs/features/active/epic-852-main-sync/evidence/qa-gates/final-pester-coverage.md` — observed success lines 11-12 and per-file figures 20-23.
27. `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/observation-scripts.2026-10-08T17-32.md` — JUnit summation 320-325; coverage index 327-347; line map 359-370.
28. `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/plan.2026-10-08T13-54.md` — CR-PESTER-LIST 120-150; CR-FORMAT-CHECK 191-208; CR-PSSA 210-228.
29. `scripts/dev_tools/plan_gate_observability.py` — `black-write` markers line 166.
30. `.claude/settings.json` — hook registration line 231 (not edited).
31. `.codex/config.toml` — hook registration lines 250-251 (not edited).
32. `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` — exists; purpose lines 3-12.
33. `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` — `AGENTS_REVIEW` copies 31-37 (reason for the auxiliary pytest run).
34. Absence check: no file matching `**/subagentstop-envelope*` exists in the current tree (E1 not merged).

Sibling-region checks performed: the Codex entry-point tests at T6 lines 169-197 were traced against the P6-T4 placement (the `CLAUDE.md` read sits after the changed-language exit, so `exits 0 when no policy audit exists` and `exits 0 when the branch changes no tracked language` never reach it; `requests a continuation` reads a figure-free `CLAUDE.md` and keeps its block decision; `stops the continuation loop` still ends in `continue:false`); the F824 assertions `below the 85% line coverage floor` and `Should -Not -Match 'line coverage floor'` remain true after the P3-T3 suffix; the T824-3..11 rows were traced against the combined P3-T1 pattern (T824-8, T824-9, T824-11 unchanged); the dependency-failure B1 and SpecialCases selection rules hold with the thresholds edge kept first.

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
CITATION: .claude/hooks/validate-feature-review-coverage.ps1 | lines 29-35, 40-49, 51-343 (function starts 51,75,106,131,150,171,196,218,231,253,268), 345-462 (messages 355,362,370,433,457; CLAUDE.md 444-445; call 450), 464-477; 477 lines
CITATION: .claude/hooks/feature-review-coverage-thresholds.ps1 | lines 19-41, 48, 57, 58-66; 77 lines
CITATION: .codex/hooks/validate-feature-review-coverage.ps1 | lines 22-25, 43, 142-207 (196, 201), 209-228, 237-304 (267-269, 275, 284, 294-304); 304 lines
CITATION: .claude/hooks/hook-dependency-guard.ps1 | lines 8-10, 104-105
CITATION: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | lines 25-29, 170-198, 200-280, 282-295 (292)
CITATION: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | lines 26-135
CITATION: tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | lines 8, 39-52, 56-240, 242-255, 269-287
CITATION: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | lines 32-50, 59-75, 101-120
CITATION: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | lines 28-38, 39-50
CITATION: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | lines 26-46, 135, 150-198
CITATION: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | lines 30, 96-142, 285-296; 497 lines
CITATION: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | lines 18-33, 97, 134-164, 183-190
CITATION: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | lines 30-32, 53-58
CITATION: tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py | lines 27-29, 70-73, 78-94, 181-197, 241-257
CITATION: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json | lines 59, 70, 71
CITATION: extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json | lines 46, 68
CITATION: .agents/skills/feature-review-workflow/SKILL.md | lines 111-114, 142, 148
CITATION: .github/skills/feature-review-workflow/SKILL.md | lines 120, 126
CITATION: .codex/agents/feature-review.toml | lines 119-123, 133-135
CITATION: .claude/skills/feature-review-workflow/SKILL.md | lines 111-114, 143, 149
CITATION: docs/features/epics/subagentstop-envelope/epic.md | lines 75-90
CITATION: scripts/powershell/PoshQC/PoshQC.Analyzer.psm1 | lines 56-66, 185
CITATION: scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | lines 3, 4, 15, 22
CITATION: config/poshqc-coverage.json | lines 3-9
CITATION: docs/features/active/epic-852-main-sync/evidence/qa-gates/final-pester-coverage.md | lines 11-12, 20-23
CITATION: docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/observation-scripts.2026-10-08T17-32.md | lines 320-325, 327-347, 359-370
CITATION: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/plan.2026-10-08T13-54.md | lines 120-150, 191-208, 210-228
CITATION: scripts/dev_tools/plan_gate_observability.py | line 166
CITATION: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | lines 3-12
CITATION: tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py | lines 31-37
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
AC-INVENTORY: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-20, AC-21, AC-22, AC-23, AC-24, AC-25, AC-26, AC-27, AC-28, AC-29
AC-MAPPING: AC-1 | IMPLEMENTATION: P0-T2, P0-T3, P0-T4, P0-T5, P0-T6, P0-T7, P0-T8 | TESTS: P0-T7 | EVIDENCE: evidence/other/upstream-merge-check.TS.md
AC-MAPPING: AC-2 | IMPLEMENTATION: P4-T1, P4-T3, P4-T11 | TESTS: P4-T10, P4-T12 | EVIDENCE: evidence/qa-gates/phase4-transport-pester.TS.md
AC-MAPPING: AC-3 | IMPLEMENTATION: P4-T3 | TESTS: P1-T1, P1-T5, P4-T12, P11-T3 | EVIDENCE: evidence/regression-testing/fail-first.TS.md
AC-MAPPING: AC-4 | IMPLEMENTATION: P4-T3 | TESTS: P4-T6, P4-T7, P4-T12 | EVIDENCE: evidence/qa-gates/phase4-transport-pester.TS.md
AC-MAPPING: AC-5 | IMPLEMENTATION: P4-T2 | TESTS: P4-T9, P4-T10, P4-T12 | EVIDENCE: evidence/qa-gates/phase4-transport-pester.TS.md
AC-MAPPING: AC-6 | IMPLEMENTATION: P4-T5, P4-T6, P4-T8, P4-T9 | TESTS: P4-T13, P5-T8 | EVIDENCE: evidence/qa-gates/claude-suites-transport-grep.TS.md
AC-MAPPING: AC-7 | IMPLEMENTATION: P5-T1, P5-T2 | TESTS: P1-T2, P1-T5, P5-T4, P5-T8 | EVIDENCE: evidence/qa-gates/phase5-cr4-pester.TS.md
AC-MAPPING: AC-8 | IMPLEMENTATION: P5-T3, P6-T5 | TESTS: P6-T12, P6-T13, P8-T10 | EVIDENCE: evidence/qa-gates/phase6-codex-pester.TS.md
AC-MAPPING: AC-9 | IMPLEMENTATION: P2-T1, P2-T2, P2-T3, P2-T4, P5-T1 | TESTS: P2-T6, P5-T5, P5-T8, P9-T3 | EVIDENCE: evidence/qa-gates/manifest-pytest.TS.md
AC-MAPPING: AC-10 | IMPLEMENTATION: P2-T1, P2-T2, P2-T3 | TESTS: P11-T1 | EVIDENCE: evidence/qa-gates/file-size.TS.md
AC-MAPPING: AC-11 | IMPLEMENTATION: P3-T1 | TESTS: P1-T3, P1-T5, P3-T8 | EVIDENCE: evidence/qa-gates/phase3-resolver-pester.TS.md
AC-MAPPING: AC-12 | IMPLEMENTATION: P3-T2, P3-T3, P3-T4 | TESTS: P3-T5, P3-T6, P3-T8, P3-T9 | EVIDENCE: evidence/qa-gates/phase3-claude-pester.TS.md
AC-MAPPING: AC-13 | IMPLEMENTATION: P4-T8 | TESTS: P4-T10, P4-T12 | EVIDENCE: evidence/qa-gates/phase4-transport-pester.TS.md
AC-MAPPING: AC-14 | IMPLEMENTATION: P6-T1, P6-T11 | TESTS: P6-T8, P6-T13 | EVIDENCE: evidence/qa-gates/phase6-codex-pester.TS.md
AC-MAPPING: AC-15 | IMPLEMENTATION: P6-T2, P6-T3, P6-T4, P6-T5 | TESTS: P6-T7, P6-T13 | EVIDENCE: evidence/qa-gates/phase6-codex-pester.TS.md
AC-MAPPING: AC-16 | IMPLEMENTATION: P6-T3, P6-T4 | TESTS: P1-T4, P1-T5, P6-T6, P6-T7, P6-T13 | EVIDENCE: evidence/qa-gates/phase6-codex-pester.TS.md
AC-MAPPING: AC-17 | IMPLEMENTATION: P6-T4 | TESTS: P6-T13, P6-T14 | EVIDENCE: evidence/qa-gates/codex-config-unchanged.TS.md
AC-MAPPING: AC-18 | IMPLEMENTATION: P6-T9, P6-T10 | TESTS: P6-T13, P9-T3 | EVIDENCE: evidence/qa-gates/manifest-pytest.TS.md
AC-MAPPING: AC-19 | IMPLEMENTATION: P6-T3, P6-T4 | TESTS: P7-T1, P7-T2 | EVIDENCE: evidence/qa-gates/phase7-parity-pester.TS.md
AC-MAPPING: AC-20 | IMPLEMENTATION: P8-T1, P8-T2, P8-T3, P8-T4, P8-T5, P8-T6 | TESTS: P8-T7, P8-T8 | EVIDENCE: evidence/qa-gates/phase8-texts-pytest.TS.md
AC-MAPPING: AC-21 | IMPLEMENTATION: P8-T7 | TESTS: P8-T9 | EVIDENCE: evidence/qa-gates/phase8-step-eight-pytest.TS.md
AC-MAPPING: AC-22 | IMPLEMENTATION: P8-T1, P8-T3, P8-T4 | TESTS: P8-T11 | EVIDENCE: evidence/qa-gates/policy-files-unchanged.TS.md
AC-MAPPING: AC-23 | IMPLEMENTATION: P2-T5, P3-T7, P4-T11, P5-T6, P6-T11, P8-T6 | TESTS: P9-T1, P9-T2 | EVIDENCE: evidence/other/mirror-log.TS.md
AC-MAPPING: AC-24 | IMPLEMENTATION: P1-T1, P1-T2, P1-T3, P1-T4 | TESTS: P1-T5, P11-T3 | EVIDENCE: evidence/regression-testing/fail-first.TS.md
AC-MAPPING: AC-25 | IMPLEMENTATION: P0-T12, P10-T7 | TESTS: P0-T13, P10-T8, P11-T2 | EVIDENCE: evidence/qa-gates/final-pester-coverage.TS.md
AC-MAPPING: AC-26 | IMPLEMENTATION: P2-T1, P2-T2, P6-T1 | TESTS: P11-T4, P11-T5, P11-T6, P11-T7 | EVIDENCE: evidence/qa-gates/constraints.TS.md
AC-MAPPING: AC-27 | IMPLEMENTATION: P0-T8 | TESTS: P11-T8 | EVIDENCE: evidence/qa-gates/scope-boundary.TS.md
AC-MAPPING: AC-28 | IMPLEMENTATION: P10-T1, P10-T3 | TESTS: P10-T2, P10-T4, P10-T5, P10-T6, P10-T7, P10-T9 | EVIDENCE: evidence/qa-gates/final-qc-loop.TS.md
AC-MAPPING: AC-29 | IMPLEMENTATION: P11-T9 | TESTS: PR-time gh pr view body check under the epic orchestrator | EVIDENCE: evidence/other/ac-29-handoff.TS.md
UNRESOLVED-GAPS: NONE
