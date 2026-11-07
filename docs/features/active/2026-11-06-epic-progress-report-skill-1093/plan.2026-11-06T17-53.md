# epic-progress-report-skill - Plan

- **Issue:** #1093
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-06T17-53
- **Status:** Ready for preflight
- **Version:** 1.0
- **Branch:** feature/epic-progress-report-skill
- **Work Mode:** full-feature
- **AC sources:** `spec.md` (`## Acceptance Criteria`, AC-01 to AC-31) and `user-story.md` (`## Acceptance Criteria`, US-AC-01 to US-AC-15)
- **Design inputs:** `spec.md` (DEC-1 to DEC-11, `## Script Additions`, `## State File Format`, `## Skill Content`, `## Test Inventory`), `research/research.2026-11-06.md` (D1 to D8), `issue.md`, `docs/features/potential/promoted/2026-11-06-epic-progress-report-skill.md`

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md), [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)
- Environment facts (tool routes, PoshQC route, batch budget, CI shape, isolation checks): `.claude/skills/execution-environment/SKILL.md`. Tasks below reference that brief and do not restate it.

**All work must comply with these policies; do not duplicate their content here.**

## Execution Rules

- Commit and push after EVERY completed task, not only at phase ends. Each commit uses a conventional commit message that references `#1093` and ends with the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Commit messages and committed files contain no token, account name, host path or transcript.
- The executor runs non-isolated in the item worktree; its checkpoint selects the `large` route, so the PowerShell batch-budget cap does not apply to edits addressed to the item worktree by absolute path (`## Batch Budget` in the execution-environment brief).
- `SCRATCH` is `<session scratchpad>/issue-1093/`; every scratch file name starts with `issue-1093-`. Artifacts record the token `SCRATCH`, never a host path.
- PowerShell runs follow `## PowerShell Route and PoshQC MCP Limits` of the execution-environment brief: branch-current Pester runs with coverage use the self-hosted PoshQC module from a `sh` launcher under `SCRATCH`; counts come from `artifacts/pester/pester-junit.xml` and per-file line coverage from `artifacts/pester/powershell-coverage.xml`; analyzer findings come from a direct `Invoke-ScriptAnalyzer` run with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`.
- Every evidence artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`, lives under `<FEATURE>/evidence/<kind>/`, and is named `<name>.<timestamp>.md` with the UTC write time; a consumer selects the lexicographically greatest match. `<FEATURE>` is `docs/features/active/2026-11-06-epic-progress-report-skill-1093`.
- No change to the `epic-run`, `epic-plan` or `epic-orchestrate` skills, their agents or mirrors; no new or edited Python; no hard-coded epic number, epic folder name, host path, drive letter, account name or token; tests use no temporary file, network call or wall-clock read.
- Canonical folder below: `CANON` = `.claude/skills/epic-progress-report/scripts`; `SUITES` = `tests/scripts/claude-skills/epic-progress-report`; `BUNDLE` = `extensions/drm-copilot/resources/claude-customizations`.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reads and Baselines

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, and `.claude/skills/execution-environment/SKILL.md`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` exists with `Timestamp:`, `Policy Order:` and the eleven files listed in that order.
- [x] [P0-T2] Capture the pre-change Full-mode golden from the merged tool: a `SCRATCH` script dot-sources `scripts/dev-tools/Get-EpicProgressReport.ps1` (still unmodified), replaces the I/O seams with the fixture values of the `Invoke-EpicProgressReport` Describe in `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` (same kickoff, plans, live plan, checkpoint, gh, cswap, fixed now, explicit `-StartUtc`), adds a state file at the fixture state path holding a legacy JSON array of four samples taken at fixed-now minus 10800, 7200, 3600 and 60 seconds with done counts 0, 1, 2 and 3, and runs `Invoke-EpicProgressReport` in Full mode.
  - Acceptance: `<FEATURE>/evidence/baseline/full-golden-legacy-state.<timestamp>.md` records the four sample offsets, the fixture deviations from the suite fixture (none other than the state file), and the 26 output lines verbatim in a fenced block; its fourth output line is the bounded range form (`hrs to` followed by a clock value, not `no upper bound`); `EXIT_CODE: 0`; no state write occurred (the newest sample is younger than 90 seconds).
- [x] [P0-T3] Record the `It` names of `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` and `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` as they stand at the merge base of `origin/main` and `HEAD` (parsed from the Pester AST, one name per line, grouped by file and `Describe`).
  - Acceptance: `<FEATURE>/evidence/baseline/it-name-inventory.<timestamp>.md` lists every name with a per-file count; the entry-suite list contains `defaults the state path under the temporary root and outside the repository`.
- [x] [P0-T4] Capture the baseline formatter state of the two merged production files and the two merged suites without writing: compare each file's text with the `Invoke-Formatter` output under the PSSA settings file.
  - Acceptance: `<FEATURE>/evidence/baseline/powershell-format.<timestamp>.md` records a per-file `match` or `differs` result for the four files, and `git status --porcelain`, run before the artifact is written, is empty (the comparison wrote no file).
- [x] [P0-T5] Capture baseline analyzer findings for the same four files with a direct `Invoke-ScriptAnalyzer` run under the PSSA settings file.
  - Acceptance: `<FEATURE>/evidence/baseline/powershell-analyze.<timestamp>.md` records the finding count per file (expected 0) and each finding's rule name when nonzero.
- [x] [P0-T6] Run the branch-current Pester route with coverage over `tests/scripts/dev-tools`.
  - Acceptance: `<FEATURE>/evidence/baseline/pester-coverage.<timestamp>.md` records the total, passed and failed counts from `artifacts/pester/pester-junit.xml`, the per-container counts of the two merged suites, and the numeric per-file line coverage of `scripts/dev-tools/Get-EpicProgressReport.ps1` and `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` from `artifacts/pester/powershell-coverage.xml`; failed count is 0 for both merged suites.
- [x] [P0-T7] Run the Python push-down contract modules `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`, `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` and `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
  - Acceptance: `<FEATURE>/evidence/baseline/python-contract-tests.<timestamp>.md` records the passed and failed counts per module; failed count is 0.
- [x] [P0-T8] Record physical line counts (`@(Get-Content -LiteralPath <path>).Count`) of the four merged files.
  - Acceptance: `<FEATURE>/evidence/baseline/file-size.<timestamp>.md` records each count; the Logic suite count is above 700, which is the split obligation of this plan.

### Phase 1 — Relocate and Split the Canonical Files

- [x] [P1-T1] Relocate with `git mv`: `scripts/dev-tools/Get-EpicProgressReport.ps1` and `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` to `CANON/`, and `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` and `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` to `SUITES/`; repoint the suites' `$script:scriptPath`, `$script:logicPath` and Logic dot-source paths to `CANON` with `Join-Path`, and change the path named in each suite's first-line header comment from `scripts/dev-tools/` to the `CANON` path (otherwise the relocated Logic suite keeps the old Logic path and the P6-T10 search cannot return zero). No other edit.
  - Tests: both relocated suites, unchanged otherwise.
  - Acceptance: the two relocated suites pass with the per-suite passed counts recorded in P0-T6; immediately after the commit, `git show --find-renames --name-status HEAD` lists four `R` entries (production files at `R100`), recorded in `<FEATURE>/evidence/other/relocation-renames.<timestamp>.md`.
- [x] [P1-T2] Create `CANON/Get-EpicProgressReport.Metrics.ps1` holding `Format-EpicProgressHour`, `Format-EpicProgressClock`, `Format-EpicProgressNumber`, `Get-EpicProgressAverageVelocity`, `Get-EpicProgressRecentVelocityInterval`, `Get-EpicProgressStandardDeviation`, `Get-EpicProgressCriticalPath`, `Get-EpicProgressRangeText` and `Get-EpicProgressWeeklyText`, moved verbatim from the Logic file with a file header; the Logic hub dot-sources it with the named form `. (Join-Path -Path $PSScriptRoot -ChildPath 'Get-EpicProgressReport.Metrics.ps1')`. Move the matching `Describe` blocks verbatim into `SUITES/Get-EpicProgressReport.Metrics.Tests.ps1`, which dot-sources the hub.
  - Tests: the moved Metrics `Describe` blocks; the remaining Logic suite.
  - Acceptance: the Metrics and Logic suites pass with 0 failures, and the union of their `It` names equals the P0-T3 Logic list (no case lost or renamed).
- [x] [P1-T3] Create `CANON/Get-EpicProgressReport.Render.ps1` holding `Get-EpicProgressSummary`, `Get-EpicProgressTldrLine` and `Get-EpicProgressFullLine`, moved verbatim; the hub dot-sources it with the named form. Move the `Get-EpicProgressSummary, Get-EpicProgressTldrLine, and Get-EpicProgressFullLine` Describe (including its `non-finite values print n/a` context) verbatim to `SUITES/Get-EpicProgressReport.Render.Tests.ps1`.
  - Tests: `composes the four TL;DR lines`, `composes the Full lines in recovered order` and the `non-finite values print n/a` cases, with unchanged expected strings.
  - Acceptance: the Render, Metrics and Logic suites pass; the union of their `It` names equals the P0-T3 Logic list.
- [x] [P1-T4] Create `CANON/Get-EpicProgressReport.State.ps1` holding `Select-EpicProgressSample`, moved verbatim; the hub dot-sources it with the named form. Move the `Select-EpicProgressSample` Describe verbatim to `SUITES/Get-EpicProgressReport.State.Tests.ps1`.
  - Acceptance: the four split suites pass; the union of their `It` names equals the P0-T3 Logic list; the hub now holds only the dot-sources and the nine parsing functions listed for it in spec DEC-5, and each split production file is below 500 physical lines.
- [x] [P1-T5] Move `Resolve-EpicProgressSetting` from the canonical entry to `CANON/Get-EpicProgressReport.State.ps1`, remove its `-TempRoot` parameter, and change the default `StatePath` to `<RepositoryRoot>/.claude/state/epic-progress-<EpicFolder>.json` built with `Join-Path`; update the call in `Invoke-EpicProgressReport`. Move the `Resolve-EpicProgressSetting` Describe to the State suite, remove `-TempRoot` from each call, and replace `defaults the state path under the temporary root and outside the repository` with `defaults the state path under .claude/state of the repository root` (expected path built with `Join-Path`). In the entry suite, `reads the raw text of an existing file` matches `function Invoke-EpicProgressReport` instead.
  - Tests disposition: the four other `Resolve-EpicProgressSetting` cases keep their assertions; every other entry-suite case is unaffected because each passes `-StatePath`.
  - Acceptance: the State suite case `defaults the state path under .claude/state of the repository root` and all five relocated and split suites pass; the entry script no longer defines `Resolve-EpicProgressSetting`.

### Phase 2 — Pure State, Baseline and Pairing Functions

- [x] [P2-T1] Add `ConvertFrom-EpicProgressStateText` and `ConvertTo-EpicProgressStateJson` to the State file per spec `## State File Format`: the reader accepts the legacy sample array, the version-1 object, blank or unparseable text (empty state), treats a version other than 1 as unparseable and missing fields as absent; the writer emits the version-1 object with integer epoch seconds.
  - Tests (State suite): `reads a legacy sample array`, `reads a version-1 document`, `treats blank text as empty state`, `treats unparseable text as empty state`, `treats an unknown version as empty state`, `treats missing fields as absent`, `round-trips integer epoch seconds`.
  - Acceptance: the seven named cases pass.
- [x] [P2-T2] Add `Resolve-EpicProgressBaseline` (pure) to the State file, implementing the resolution rules of spec `## Script Additions`. Inputs: the passed values with their presence (from `$PSBoundParameters.ContainsKey`), the parsed state, the reset switch and the current instant. It returns `StartUtc`, `BaselineDone`, `BaselineWeeklyPct` and `UseCurrentDone`. `UseCurrentDone` is true only when the run resets and `-BaselineDone` was not passed; in that case the entry substitutes the done count after its git calls. The function raises a terminating error that names `-StartUtc` and `-ResetBaseline` when no start is passed, none is stored, and no reset is requested.
  - Tests (State suite): `prefers passed values`, `uses stored values`, `resets to now and the current done count`, `keeps a passed start on reset`, `throws without a start and without reset`, `keeps the weekly baseline on reset`.
  - Acceptance: the six named cases pass; the thrown message matches both `-StartUtc` and `-ResetBaseline`.
- [x] [P2-T3] Add `Merge-EpicProgressSamplePair` (pure) to the State file: keep the newest sample and every second older sample (indices n-1, n-3, ...), preserving chronological order.
  - Tests (State suite): `keeps s13, s11, s9, s7, s5, s3 and s1 of 14 samples`, `reduces 13 samples to 7`, `reduces 2 samples to 1`, `leaves 1 and 0 samples unchanged`, `leaves 4 samples after two applications to 14`.
  - Acceptance: the five named cases pass.
- [x] [P2-T4] Add the State-suite case `reproduces the recorded 5-minute to 10-minute example` using the 14-sample fixture of `research/research.2026-11-06.md` (`#### Reproduction of the pairing example from recorded samples (hand-computed)`, offsets from a fixed base epoch): the interval mean and SD from `Get-EpicProgressRecentVelocityInterval` and `Get-EpicProgressStandardDeviation` are within 0.001 of 26.1875 and 31.4495 before pairing and of 27.3430 and 23.2316 after `Merge-EpicProgressSamplePair`, and `Format-EpicProgressNumber -Digits 1` prints `26.2`, `31.4`, `27.3` and `23.2`.
  - Acceptance: the named case passes.
- [x] [P2-T5] Add Metrics-suite cases `prints n/a hrs to no upper bound for zero-rate intervals` (three or more zero-rate intervals, average 0, SD 0, asserting the exact text `n/a hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)`) and `returns NaN for exactly 2 intervals and a finite value for 3 or more`.
  - Acceptance: both named cases pass with no production change (spec DEC-6).
- [x] [P2-T6] Add the Render-suite case `prints no NaN or Infinity before the first task completes`: done equals baseline, elapsed above 0, zero-rate samples; neither the TL;DR nor the Full lines contain `NaN` or `Infinity`, and the estimate values print `n/a`.
  - Acceptance: the named case passes with no production change.

### Phase 3 — Entry Wiring of State, Reset and Pairing

- [x] [P3-T1] In `Invoke-EpicProgressReport`, read and parse the state file through `Read-EpicProgressFile` and `ConvertFrom-EpicProgressStateText` before the first git call, and write the version-1 document through `ConvertTo-EpicProgressStateJson` and `Write-EpicProgressState`, persisting the resolved start, baseline done, baseline weekly percentage and samples.
  - Tests updated (entry suite): `treats an unparseable state file as empty` asserts `samples.Count` of the written object is 1; `writes only the state file at -StatePath` reads `samples[0].ts` and `samples[0].done` and asserts `startUnixSeconds` and `baselineDone` are persisted. Unaffected: `does not write the state file within 90 seconds of the last sample` (legacy array still read), the git and gh argument cases, the golden mode cases.
  - Acceptance: the full entry suite passes.
- [x] [P3-T2] Make `-StartUtc` optional in the canonical `param()` block and in `Invoke-EpicProgressReport`; resolve the start through `Resolve-EpicProgressBaseline` before the first git call; use the resolved baseline values in `Get-EpicProgressSummary`.
  - Tests (entry suite): `throws before any git call without a passed or stored start` (no `-StartUtc`, no state file; `Invoke-GitExe` invoked 0 times; message matches `-StartUtc` and `-ResetBaseline`), `uses the stored start when -StartUtc is absent` (version-1 state with the fixture start and no samples; output equals the existing expected TL;DR lines).
  - Acceptance: both named cases and the full entry suite pass.
- [x] [P3-T3] Add `[switch] $ResetBaseline` to the canonical `param()` block and `Invoke-EpicProgressReport`: discard stored samples, resolve the baseline (substituting the current done count when `UseCurrentDone` is true), apply the sample rule, and always write the state.
  - Tests (entry suite): `clears stored samples and writes the resolved baseline with -ResetBaseline` (stored samples present; no `-StartUtc`; written document holds one sample at the fixed now with the fixture done count, `startUnixSeconds` equal to the fixed now, `baselineDone` equal to the fixture done count, and the stored `baselineWeeklyPct` unchanged).
  - Acceptance: the named case and the full entry suite pass.
- [x] [P3-T4] Add `[switch] $PairSamples`: applied after the sample rule through `Merge-EpicProgressSamplePair`, always writing the state; combining it with `-ResetBaseline` raises a terminating error before any I/O.
  - Tests (entry suite): `rewrites the stored samples in pairs with -PairSamples` (stored samples at fixed-now minus 1200, 900, 600 and 300 seconds; written samples are fixed-now minus 1200, fixed-now minus 600 and fixed-now), `throws before any I/O when -ResetBaseline and -PairSamples are combined` (`Read-EpicProgressFile`, `Test-EpicProgressPath` and `Invoke-GitExe` invoked 0 times; message matches both switch names).
  - Acceptance: both named cases and the full entry suite pass.
- [x] [P3-T5] In `Write-EpicProgressState`, create the parent directory with `New-Item -ItemType Directory` when it is missing, inside the existing `ShouldProcess` block. Update the entry-suite constraints `Describe` so `$script:productionPaths` holds the five canonical files (entry first); `confines file writes to Write-EpicProgressState` expects exactly `Set-Content` and `New-Item`, both in `Write-EpicProgressState`; `confines native commands to their wrappers` scans five files with the native count unchanged at 3.
  - Tests disposition: `writes nothing when the state write runs with WhatIf` unchanged (passes because both writes sit inside `ShouldProcess`).
  - Acceptance: the two updated cases, the WhatIf case and the full entry suite pass.
- [x] [P3-T6] Update the canonical entry's comment-based help: `.PARAMETER` entries for `ResetBaseline` and `PairSamples`, `StartUtc` described as optional with its resolution order, the new `StatePath` default, both examples rewritten to the `CANON` path with `-EpicFolder example-epic`, and a `-ResetBaseline` example; `.NOTES` keeps the read-only statement.
  - Tests updated: `documents every parameter in comment-based help` expects 15 parameters; `carries at least one example` unchanged in assertion.
  - Acceptance: both cases pass.
- [x] [P3-T7] Add the entry-suite case `prints the Full golden for a legacy four-sample state` using the P0-T2 fixture, with the 26 expected lines pasted verbatim from `<FEATURE>/evidence/baseline/full-golden-legacy-state.<timestamp>.md`.
  - Acceptance: the named case passes, the four existing golden cases (`composes the four TL;DR lines`, `composes the Full lines in recovered order`, `prints the four TL;DR lines in TLDR mode`, `prints the TL;DR block followed by the Full sections in Full mode`) pass with expected strings unchanged from the merge base, and the entry suite stays below 700 physical lines.

### Phase 4 — Forwarder

- [x] [P4-T1] Recreate `scripts/dev-tools/Get-EpicProgressReport.ps1` as the forwarder: comment-based help with `.SYNOPSIS` (forwards to the canonical entry and names its path) and `.DESCRIPTION` (dot-source the canonical file, not the forwarder); no `param()` block; executable statements exactly in this order: `$ErrorActionPreference = 'Stop'`; `$global:LASTEXITCODE = 0`; `& (Join-Path -Path $PSScriptRoot -ChildPath '../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1') @args`; `if ($?) { exit 0 }`; `exit $(if ($LASTEXITCODE) { $LASTEXITCODE } else { 1 })`. In the same task, update `spec.md`: the DEC-1 forwarder code block and rationale, the `R1` row of `## Risks`, AC-10's statement sequence, the forwarder line of `## Test Inventory`, and OQ-1 marked resolved with the four probe outcomes (validation failure 1, leftover native failure after a successful run 0, explicit `exit 3` in the target 3, normal run 0).
  - Acceptance: the forwarder parses with zero errors and holds no `param()` block; the spec's DEC-1, `R1`, AC-10, Test Inventory and OQ-1 text state the settled shape and no longer present a trailing `exit $LASTEXITCODE` as the design.
- [x] [P4-T2] Create `tests/fixtures/dev-tools/Get-EpicProgressReport.ForwarderTarget.Fixture.ps1` (a committed stub target: `-Behavior Normal` writes one line and returns; `-Behavior LeftoverNative` runs the current PowerShell executable with `-NoProfile -Command 'exit 128'`, writes one line and returns; `-Behavior Exit3` runs `exit 3`; a `[ValidateRange(1, 10)] [int] $Count` parameter supplies a binding failure) and the forwarder suite `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`. In-process cases invoke the real forwarder with `&` while `Join-Path` is mocked with a `-ParameterFilter` on the canonical child path to return the fixture path, and save and restore `$global:LASTEXITCODE` in `BeforeEach`/`AfterEach`. Child-process cases start the current PowerShell executable with `-NoProfile -File` against the real forwarder and real canonical entry, with arguments that fail parameter validation before any git call or file write.
  - Tests: `targets an existing canonical entry`; `holds no param block and the settled statement sequence` (AST); `exits 0 after a normal target run`; `exits 0 when the target leaves a failed native exit code`; `propagates an explicit target exit code` (3); `raises a target parameter-validation error in process`; `exits 1 with the canonical ValidateRange error for -SampleCap 0` (output names `SampleCap`); `exits 1 with the canonical ValidateSet error for -Mode Bogus` (output names `Mode`).
  - Acceptance: the eight named cases pass; the suite and fixture contain no `Start-Process`, no temporary-path API and no network call (the `check-powershell-test-purity.ps1` hook admits both files).

### Phase 5 — Skill, Delivery and Configuration

- [x] [P5-T1] Create `.claude/skills/epic-progress-report/SKILL.md` per spec `## Skill Content`: the frontmatter keys and `allowed-tools` entries listed there, the fifteen required headings in order, `## Report Formats` and `## Calculation Rules` from the spec with fictional values (`example-epic`, epic issue `42`), the two prompts of `## Scheduling Prompts` each in its own fenced `text` block, the procedures, the state-file trade-offs, the known behaviors and measured rates, the owner-confirmation defaults, and the notes; the only script invocation is the `CANON` entry path.
  - Acceptance: the file exists, is below 500 physical lines, and contains no `1019`, `TaskMaster`, `No-COM`, `/workspaces` or `-File scripts/dev-tools` (each checked with a fixed-string search over the file, the hyphen-leading token passed through `-e`, zero matches).
- [ ] [P5-T2] Add six entries to the `paths` array of `BUNDLE/pack-manifests/core.json`: `.claude/skills/epic-progress-report/SKILL.md` and the five `CANON` files, placed in sorted position after the `epic-plan` entry and before the `epic-run` entry.
  - Acceptance: the file parses as JSON and each of the six paths occurs exactly once.
- [ ] [P5-T3] Write byte copies of `SKILL.md` and the five `CANON` files to `BUNDLE/.claude/skills/epic-progress-report/` (same relative layout).
  - Acceptance: each copy's SHA-256 equals its canonical file's, recorded in `<FEATURE>/evidence/other/bundle-hashes.<timestamp>.md`.
- [ ] [P5-T4] Create `SUITES/EpicProgressReport.SkillContract.Tests.ps1` reading the committed skill, manifest and bundle files through `Join-Path` from `$PSScriptRoot`. Prompt assertions scope to the fenced blocks under `## Scheduling Prompts`; fragment lists are the literals named in spec AC-03 to AC-07.
  - Tests: `declares the name epic-progress-report`; `carries a single-quoted non-empty description and an argument-hint`; `grants the canonical script, CronCreate, CronList, CronDelete and PushNotification`; `does not fork context and is not hidden from invocation`; `contains every required heading`; `stays under 500 lines`; `states the report format fragments`; `states the calculation rule values`; `carries both scheduling prompts with their cron expressions`; `keeps baseline and pairing arguments out of the scheduling prompts`; `states the push-notification text rule, local cron time and jitter`; `documents reset, cadence change, stopping and restart recovery`; `documents known behaviors, rates, delivery and quota policy`; `names no forbidden token and no scripts/dev-tools invocation`; `names only existing skill-folder paths`; `lists every skill-folder file exactly once in core.json`; `mirrors every skill-folder file byte-identically in the bundle`.
  - Acceptance: the seventeen named cases pass.
- [ ] [P5-T5] Extend `contains no recovered hardcoded value` in the entry suite to scan the five canonical files, the forwarder and `SKILL.md` (forbidden list and drive-letter pattern unchanged).
  - Acceptance: the updated case passes and its scan list holds seven paths.
- [ ] [P5-T6] Add `.claude/skills` to the `roots` array of `config/poshqc-coverage.json`, keeping the six existing roots.
  - Acceptance: the file parses as JSON and `roots` holds seven entries including `.claude/skills`.
- [ ] [P5-T7] Add an `### Added` subsection under `## [Unreleased]` in `extensions/drm-copilot/CHANGELOG.md` (before `### Changed`) recording the `/epic-progress-report` skill in the Claude core pack with its bundled scripts, and that delivery needs a rebuild and reinstall of the extension (spec DEC-10: core pack content changes are recorded there, as issue #984 shows).
  - Acceptance: the `## [Unreleased]` section contains `### Added` and the token `epic-progress-report`.

### Phase 6 — Final QA, Verification and Self-Review

- [ ] [P6-T1] Run the PoshQC formatter over the canonical folder, the forwarder, `SUITES`, the forwarder suite and the fixture. A clean pass logs `Already formatted:` for every file and no line beginning with `Formatted:`. When any file is reformatted, re-copy the affected canonical file to `BUNDLE`, re-run P5-T3's hash check, and restart this phase at P6-T1.
  - Acceptance: `<FEATURE>/evidence/qa-gates/powershell-format.<timestamp>.md` records one `Already formatted:` line per file and zero `Formatted:` lines.
- [ ] [P6-T2] Run `Invoke-ScriptAnalyzer` with the PSSA settings file over the same files plus the five bundle copies.
  - Acceptance: `<FEATURE>/evidence/qa-gates/powershell-analyze.<timestamp>.md` records 0 findings; any finding is fixed and the phase restarts at P6-T1.
- [ ] [P6-T3] Run the branch-current Pester route with coverage over `tests/scripts/claude-skills/epic-progress-report` and `tests/scripts/dev-tools`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/pester-coverage.<timestamp>.md` records total, passed and failed counts (failed 0) with per-container counts for the seven touched suites, and per-file line coverage of at least 85 percent for each of the five `CANON` files and `scripts/dev-tools/Get-EpicProgressReport.ps1`.
- [ ] [P6-T4] Write the coverage comparison.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` lists the baseline values from P0-T6, the post-change per-file values from P6-T3, and the new or changed file values, with a PASS verdict only when every listed file is at or above 85 percent.
- [ ] [P6-T5] Run the seven touched Pester suites (`SUITES/*.Tests.ps1` and `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`) in one process in seeded shuffled file order with seeds 7, 41 and 1093.
  - Acceptance: `<FEATURE>/evidence/regression-testing/pester-shuffled-order.<timestamp>.md` records each seed, its file order and its passed and failed counts; failed is 0 for every seed.
- [ ] [P6-T6] Run a fresh single-process Pester run over `tests/scripts`.
  - Acceptance: `<FEATURE>/evidence/regression-testing/pester-single-process.<timestamp>.md` records total, passed and failed counts from the JUnit file, with 0 failures in the seven touched suites and any other failure compared against the merge base and recorded as pre-existing or fixed.
- [ ] [P6-T7] Run a concurrent-shard Pester run through `Invoke-PoshQCParallelTest` over `tests/scripts`.
  - Acceptance: `<FEATURE>/evidence/regression-testing/pester-parallel-shards.<timestamp>.md` records the shard count and per-container results of the seven touched suites with 0 failures.
- [ ] [P6-T8] Re-run the five Python contract modules of P0-T7 unchanged.
  - Acceptance: `<FEATURE>/evidence/qa-gates/python-contract-tests.<timestamp>.md` records 0 failures, including `test_every_skill_script_reference_is_bundled`, `test_every_skill_folder_file_is_carried_by_skill_packs`, `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_bundled_claude_files_are_listed_in_some_pack_manifest`, `test_claude_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized` and `test_scanned_source_floor`.
- [ ] [P6-T9] Record physical line counts of every production and test file created or changed by this branch.
  - Acceptance: `<FEATURE>/evidence/qa-gates/file-size.<timestamp>.md` lists each file and count; every count is below 700.
- [ ] [P6-T10] Record the scope of the branch with `git diff --find-renames --name-status origin/main...HEAD` and `git status --porcelain`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/scope-diff.<timestamp>.md` shows `git status --porcelain` empty; no path under `.claude/skills/epic-run/`, `.claude/skills/epic-plan/`, `.claude/skills/epic-orchestrate/`, `.agents/`, `.github/skills/`, `.claude/agents/`, `.claude/settings.json` or any `.py` file; `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` absent from the tree; and a `git grep` of tracked files outside `docs/features/` for the fixed string `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` returns zero matches. The artifact cites the P1-T1 relocation-renames evidence for AC-09, because the recreated forwarder keeps the old entry path, so the range diff reports the canonical entry as added.
- [ ] [P6-T11] Compare the P0-T3 `It` names with the `It` names of the relocated and split suites under `SUITES`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/it-name-comparison.<timestamp>.md` shows every P0-T3 name present except `defaults the state path under the temporary root and outside the repository`, which maps to `defaults the state path under .claude/state of the repository root`.
- [ ] [P6-T12] Write the AC verification artifact and check off the verified ACs: every AC and US-AC maps to its proving test or evidence; AC-12, AC-30, AC-31, US-AC-11 and US-AC-15 are listed as pending-CI (`CI Required Gate` on the PR head, checked off by the orchestrator) and stay unchecked. Check off the other 28 spec ACs in `spec.md` and the other 13 user-story ACs in `user-story.md`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ac-verification.<timestamp>.md` lists all 46 IDs with status and records the read of `config/poshqc-coverage.json` for AC-13; `spec.md` holds 28 checked and 3 unchecked AC lines and `user-story.md` holds 13 checked and 2 unchecked US-AC lines.
- [ ] [P6-T13] Add a `.NOTES` section to the forwarder's comment-based help stating the exit-status mapping (validation failure 1, an explicit target exit code propagated, a leftover native exit code ignored after a successful run) and issue #1093; re-run the formatter, the analyzer and the forwarder suite on it. Then walk the policy-audit, code-review and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and commit the forwarder edit together with the self-review as the final code-touching head.
  - Acceptance: the forwarder suite passes, the formatter logs `Already formatted:` for the forwarder, the analyzer reports 0 findings; `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` holds one PASS, FAIL or N/A row per checklist item with no FAIL row; after the commit and push, `git diff --name-only HEAD~1 HEAD` lists `scripts/dev-tools/Get-EpicProgressReport.ps1` and `git status --porcelain` is empty.

## Acceptance Criteria Traceability

| AC | Implementing tasks | Proof |
|---|---|---|
| AC-01, US-AC-01 | P5-T1 | P5-T4 frontmatter cases |
| AC-02 | P5-T1 | `contains every required heading`, `stays under 500 lines` |
| AC-03, AC-04, US-AC-02 | P5-T1 | `states the report format fragments`, `states the calculation rule values` |
| AC-05, US-AC-03 | P5-T1 | the three scheduling-prompt cases of P5-T4 |
| AC-06, US-AC-07 (doc), US-AC-08 (doc), US-AC-09 | P5-T1 | `documents reset, cadence change, stopping and restart recovery` |
| AC-07, US-AC-06 | P5-T1 | `documents known behaviors, rates, delivery and quota policy` |
| AC-08, US-AC-12 | P5-T1, P5-T5 | `names no forbidden token and no scripts/dev-tools invocation`, `contains no recovered hardcoded value`, P6-T8 |
| AC-09 | P1-T1 to P1-T4 | relocation-renames and scope-diff evidence |
| AC-10, US-AC-14 | P4-T1 | P4-T2 forwarder cases |
| AC-11, US-AC-13 | P5-T2, P5-T3 | P5-T4 delivery cases, P6-T8 |
| AC-12, US-AC-11 | P5-T2, P5-T3 | P6-T8 locally; `CI Required Gate` (pending-CI) |
| AC-13 | P5-T6 | read of `config/poshqc-coverage.json` in P6-T12 |
| AC-14, US-AC-07 | P2-T2, P3-T3 | `Resolve-EpicProgressBaseline` cases, `clears stored samples and writes the resolved baseline with -ResetBaseline` |
| AC-15, US-AC-08 | P2-T3, P2-T4, P3-T4 | `Merge-EpicProgressSamplePair` cases, `rewrites the stored samples in pairs with -PairSamples` |
| AC-16, US-AC-04 | P3-T2, P3-T4 | the three named throw and stored-start cases |
| AC-17, US-AC-10 | P1-T5, P3-T5 | `defaults the state path under .claude/state of the repository root`, `writes only the state file at -StatePath`, `writes nothing when the state write runs with WhatIf` |
| AC-18, US-AC-10 | P2-T1, P3-T1 | `ConvertFrom-EpicProgressStateText` and `ConvertTo-EpicProgressStateJson` cases |
| AC-19 | P3-T1 | `does not write the state file within 90 seconds of the last sample` |
| AC-20 | P1-T2, P2-T5 | Metrics suite, entry mode cases |
| AC-21, AC-22, AC-23, US-AC-05 | P1-T3, P2-T5, P2-T6, P3-T7 | zero-rate, before-first-task and golden cases |
| AC-24 | P1-T1 to P1-T5 | it-name-comparison evidence |
| AC-25 | P3-T6 | `documents every parameter in comment-based help`, `carries at least one example` |
| AC-26, US-AC-12 | P3-T5 | the four constraint and argument cases |
| AC-27 | P1-T2 to P1-T4 | file-size evidence |
| AC-28 | all | scope-diff evidence |
| AC-29 | P6-T5, P6-T6 | regression-testing evidence |
| AC-30, AC-31, US-AC-15 | Phases 1 to 5 | P6-T3, P6-T4, P6-T9, P6-T11 locally; `CI Required Gate` (pending-CI) |

## Pre-Mortem

- Review checklists: a reviewer can fail the change for duplicated logic, a `scripts/dev-tools` invocation in the skill, a real epic number in examples, or forwarder exit codes that hide failures; prevented by the single forwarder with no `param()` block (P4-T1), the skill-contract and hardcoded-value scans (P5-T4, P5-T5), the eight forwarder cases asserting all four probe outcomes (P4-T2), and the template walk in P6-T13 with no FAIL row.
- Coverage: the canonical files sit outside every coverage root until P5-T6 adds `.claude/skills`, and a forwarder executed only in a child process would show 0 percent; prevented by P5-T6, by in-process forwarder cases that execute all five forwarder statements, and by per-file coverage read from `artifacts/pester/powershell-coverage.xml` of a branch-current run (P6-T3, P6-T4), never from an MCP summary.
- Mirror parity: six bundle copies and six `core.json` entries must equal the canonical files after formatting; prevented by copying in P5-T3, re-copying on any P6-T1 reformat, the byte-identity case of P5-T4 and the Python contract modules in P6-T8. No fact of the execution-environment brief changes (no CI job, required context, tool route or batch-budget rule; the brief names `config/poshqc-coverage.json` without its roots), so no brief-update task exists and the six brief copies stay unchanged.
- File size: the Logic suite starts above 700 lines and the Logic file near it; prevented by the split in P1-T2 to P1-T4 (each split production file below 500), the entry-suite bound in P3-T7, and physical counts in P6-T9 (`Get-Content` count, not `Measure-Object -Line`).
- Test isolation: dot-sourced functions, script-scope fixtures, the forwarder's `$global:LASTEXITCODE` write and the `Join-Path` mock can leak between suites; prevented by per-test fixtures in `BeforeEach`, saving and restoring `$global:LASTEXITCODE`, a `-ParameterFilter` on the `Join-Path` mock, mocked or `-WhatIf` state writes, and the isolation runs: a seeded shuffled file-order run of the seven touched Pester suites with seeds 7, 41 and 1093, each seed and order recorded (P6-T5), a fresh single-process run over `tests/scripts` (P6-T6), and a concurrent-shard run (P6-T7). No Jest or Python test changes, so the Jest shuffle and Python reversed-order runs are not applicable.
- CI-only behavior: the Windows shards resolve the forwarder target and the `.claude/state` default with Windows separators, and the child-process forwarder cases depend on the executable path; prevented by `Join-Path` in every production and test path, expected paths built the same way, the current PowerShell executable path taken from the running process, no drive letter or backslash literal, and fixed epoch values. The suites are not under `tests/scripts/claude-hooks`, so the Linux hook-suite job does not run them.
- Evidence: the byte-identical regression depends on lines captured before any edit, and AC-09's rename proof disappears once the forwarder recreates the old path; prevented by P0-T2 (golden captured from the unmodified merged tool) and P1-T1 (rename evidence recorded from the relocation commit itself), with every artifact under `<FEATURE>/evidence/<kind>/` carrying the four required fields and the token `SCRATCH` for scratch locations.

## Size Justification

- The plan carries 48 tasks because the owner requires a commit and push after every task, so each relocation, split, state function, entry switch, forwarder, skill, manifest, bundle and configuration change is its own verifiable commit, and the final phase must carry one artifact per QA gate and isolation run required by the execution-environment brief.

## Test Plan

- Unit: State, Metrics, Render and Logic suites under `SUITES` (pure functions with fixed inputs); entry suite with every seam mocked.
- Integration: forwarder suite (in-process with the committed stub fixture, and child-process runs that fail parameter validation before any I/O); skill contract suite over committed files.
- Contract: Python push-down modules run unchanged (P0-T7, P6-T8).
- Coverage evidence: baseline `<FEATURE>/evidence/baseline/pester-coverage.<timestamp>.md`; post-change `<FEATURE>/evidence/qa-gates/pester-coverage.<timestamp>.md`; comparison `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md`.

## Open Questions / Notes

- Forwarder testing (settled R1): exit codes 0 after a normal run, 0 after a leftover native failure, and 3 after an explicit `exit 3` need a target that behaves that way without git or file I/O, which the real canonical entry cannot do. The committed stub fixture under `tests/fixtures/dev-tools/` (no file is written at test time) is reached in-process through a `Join-Path` mock, which also gives the forwarder its line coverage. Validation failure exit code 1 is proven in a child process against the real canonical entry.
- `Resolve-EpicProgressBaseline` returns `UseCurrentDone` so that the start rule and its error run before the first git call while the reset baseline can still take the done count measured after the git calls.
- Owner-confirmation items stay in `spec.md` `## Owner Confirmation Items`; the skill implements the stated defaults.
