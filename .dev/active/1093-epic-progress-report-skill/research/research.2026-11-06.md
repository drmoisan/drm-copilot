# Research: epic-progress-report skill (Issue #1093)

- Issue: #1093
- Branch: feature/epic-progress-report-skill
- Feature folder: docs/features/active/2026-11-06-epic-progress-report-skill-1093
- Inputs read: `docs/features/potential/promoted/2026-11-06-epic-progress-report-skill.md`, the feature `issue.md` and `spec.md`, the merged tool and its two Pester suites, the recovered coordinator script (outside every repository, read-only), the local gitignored epic-orchestrator velocity memory and its CSV, the push-down bundle, manifests and contract tests, the issue #762 feature record, and the Claude Code scheduled-task and tools reference pages.
- Tool limits: this researcher cannot run `git`, `gh`, or PowerShell. Every arithmetic result below was computed by hand from recorded values and is marked as such; facts that need a command are marked ORCHESTRATOR-CONFIRM.

## Summary of Decisions

- D1: the canonical script files move into `.claude/skills/epic-progress-report/scripts/`. `scripts/dev-tools/Get-EpicProgressReport.ps1` becomes a one-statement forwarder that runs the canonical entry with the caller's arguments. No logic exists twice in the repository; the only byte copy is the bundle mirror, already pinned by the Python contract tests.
- D2: the skill folder is mirrored under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/` and every file is listed in the `core` pack manifest; a destination receives it on the next push-down after a rebuild and reinstall of the extension.
- D3: the default state file becomes `<RepositoryRoot>/.claude/state/epic-progress-<EpicFolder>.json`. `.claude/state/` is gitignored in this repository and is merged into a destination's `.gitignore` by the push-down.
- D4: `-ResetBaseline` and `-PairSamples` are added as switches; the state file becomes a versioned JSON object that persists `StartUtc` (epoch seconds), `BaselineDone`, `BaselineWeeklyPct`, and the samples, so later runs may omit `-StartUtc` and `-BaselineDone`. The merged tool already prints `n/a` for every non-finite value; one unverified path is covered by a new test.
- D5: `Get-EpicProgressReport.Logic.ps1` is split into four files (Logic hub with the parsing functions, State, Metrics, Render); the hub dot-sources the other three, so every existing `. Logic.ps1` consumer keeps all functions.
- D6: the skill outline, exact templates, prompts, and procedures are given below.
- D7: no cross-reference in `epic-run`, `epic-plan`, or `epic-orchestrate`; `epic-orchestrate` is hash-pinned.
- D8: the merged tool uses average plus and minus 2.05 SD; kept, documented, and listed for owner confirmation.

## Findings per Reference

### Requirements document and feature folder

- The promoted requirements document and `issue.md` carry identical requirement text. `spec.md` is a Draft (Version 0.1) seeded from the same text with empty Inputs/Outputs, API/CLI, and Data & State sections.
- The owner's TL;DR example and CLI example name a specific epic (issue number and folder name). The no-hard-coded-epic constraint applies to the skill and the script, so the skill must restate both examples with placeholder or fictional values (the existing tests use `example-epic` and epic issue `42`).

### The merged tool (issue #1080)

Files: `scripts/dev-tools/Get-EpicProgressReport.ps1` (entry, 477 lines) and `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` (688 lines).

- Entry script: a 13-parameter `param()` block (`EpicFolder` and `StartUtc` mandatory), the pure `Resolve-EpicProgressSetting`, seven I/O seams (`Invoke-GitExe`, `Invoke-GhExe`, `Invoke-CswapExe`, `Test-EpicProgressCommand`, `Test-EpicProgressPath`, `Read-EpicProgressFile`, `Write-EpicProgressState`, plus the clock seam `Get-EpicProgressUtcNow` and `Get-EpicProgressLastExitCode`), the wiring function `Invoke-EpicProgressReport`, and an entry block guarded by `$MyInvocation.InvocationName -ne '.'` that pushes to the repository root and calls `Invoke-EpicProgressReport @PSBoundParameters`.
- The Logic file is dot-sourced with `. (Join-Path -Path $PSScriptRoot -ChildPath 'Get-EpicProgressReport.Logic.ps1')`, which is the named form F2 recognized by `tests/scripts/dev_tools/pack_manifest_dependency_scan.py`.
- State today: `Resolve-EpicProgressSetting` defaults `StatePath` to `epic-progress-<EpicFolder>.json` under `[System.IO.Path]::GetTempPath()`; the state file is a JSON array of `{ts, done}` samples; it is written only when `Select-EpicProgressSample` reports `Changed`.
- Range rule (`Get-EpicProgressRangeText`): below 3 intervals prints `<HH:MM> hrs (range needs 3 or more check-in intervals)`; otherwise fast hours = critical-path tasks / (average + 2.05 x SD) + overhead, slow velocity = average - 2.05 x SD, bounded when slow velocity is above 0.5, otherwise `<HH:MM> hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)`.
- Non-finite handling: `Format-EpicProgressHour`, `Format-EpicProgressClock`, and `Format-EpicProgressNumber` each return `n/a` for NaN or infinity; `Get-EpicProgressWeeklyText` returns `n/a`; the weekly delta prints `n/a` and receives `+` only when finite and non-negative. Every numeric value printed by `Get-EpicProgressTldrLine` and `Get-EpicProgressFullLine` passes through one of these functions. The test context `non-finite values print n/a` in `Get-EpicProgressReport.Logic.Tests.ps1` asserts `n/a` for straight-line hours, wave-parallel hours, hours-left, the range, the weekly quota and delta, and zero elapsed time.
- One path is not covered by any test: three or more intervals with average velocity 0 and SD 0 (no task completed since the baseline). The bounded branch then divides the critical-path task count by 0.0. In .NET this yields infinity (or NaN when the task count is also 0), which `Format-EpicProgressClock` prints as `n/a`, giving `n/a hrs to no upper bound (...)`. Whether PowerShell's `/` operator returns infinity for a `[double]` divisor of zero rather than raising is ORCHESTRATOR-CONFIRM (verified by the new test proposed under D4).
- Two further edge behaviors that are not NaN but are worth documenting: a negative average velocity (done count below `-BaselineDone`, for example after a plan revision removed tasks) makes the straight-line and wave-parallel estimates `n/a` while a range with 3 or more intervals can print negative or very large clock values; and `Format-EpicProgressNumber` uses the default (to-even) rounding, so `Avg Velocity` prints `1` rather than `1.0` for an integral value.

### The #1080 Pester suites

- `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` (702 lines, above the 700-line advisory tier) dot-sources `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` and holds sixteen `Describe` blocks, one per function group (listed in the Test Inventory).
- `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` dot-sources the entry script with `-EpicFolder` and `-StartUtc` bound, mocks every seam, and contains four `Describe` blocks: `Resolve-EpicProgressSetting`, `I/O seams without side effects`, `Invoke-EpicProgressReport`, and `Get-EpicProgressReport.ps1 repository constraints`. The constraints block pins: exactly one write command (`Set-Content` in `Write-EpicProgressState`), exactly three native commands each inside its wrapper, no forbidden token (`documentation-estate-tooling`, `1019`, `/workspaces`, `2026-11-04T13:55`, drive-letter paths) in the two production files, exactly 13 documented parameters, and an example containing `-EpicFolder example-epic`.
- Golden assertions already exist: `composes the four TL;DR lines`, `composes the Full lines in recovered order`, `prints the four TL;DR lines in TLDR mode`, and `prints the TL;DR block followed by the Full sections in Full mode` compare exact joined lines. These are the byte-for-byte regression anchors.

### The recovered coordinator script (read-only, outside the repository)

Compared with the merged tool:

| Requirement | Recovered script | Merged tool |
|---|---|---|
| Baseline reset | Done by editing two hard-coded constants (`$startUtc`, `$baselineDone`) with a comment recording the resume after the restart; earlier samples were not cleared by the script | Parameters `-StartUtc` and `-BaselineDone`; samples are never cleared; no reset switch |
| Pairing | Absent; pairing was done by hand in the session | Absent |
| State location | `epic-progress-state.json` next to the script file (one file for every epic) | Per-epic file under the system temporary directory; overridable with `-StatePath` |
| n/a instead of NaN | Recent velocity and SD print `n/a`; the hours-left figure (`[math]::Round` of NaN), the range clock, the weekly quota (`NaN%`), and the weekly delta could print NaN | Every printed number passes through an `n/a`-returning formatter |
| Hard-coded values | Coordinator path, integration branch, kickoff path, epic number in output text, a kickoff-row regex that accepts only issues 1000-1099 | All parameterized; a constraints test forbids the recovered values |
| Formatting | Host-culture formatting; minutes computed separately from hours (could print `60 min`) | Invariant culture; minutes derived from rounded total minutes |

Conclusion: the four script additions in the requirements are absent from both scripts. The `n/a` requirement is already met by the merged tool and needs only a regression test.

### Local gitignored velocity memory (summarized; not a dependency of the skill)

Source: the epic-orchestrator memory note on epic velocity history and its CSV of 106 TL;DR readings (columns: reading time UTC, done, total, pct, featuresDone, elapsedH, weeklyPct, avgVel, recentVel, sd). Useful content for the skill, stated without naming the epic:

- Aggregate throughput with three or four features in parallel: about 25 to 30 tasks per hour (30.5 over one 7.1-hour stretch; 23.5 over a 3.6-hour stretch whose first hour was plan revisions and Phase 0 baselines, then 30 per hour).
- Per-feature execution pace: about 9 to 13 tasks per hour; a feature running alone, including its review and PR tail, about 4 tasks per hour.
- Interval velocity is bursty because plan checkboxes are ticked at batch boundaries: 5-minute readings ranged 0 to 154 tasks per hour with SD 31 to 46 around a mean of about 26.
- Flat stretches of 20 to 60 minutes recur at phase boundaries (final QA, feature review, PR, CI, merge).
- The wave-parallel estimate swung between 35 and 110 hours in the first hour after a baseline reset; it is not reliable before about 2 hours of data. At one wave launch it estimated 26 to 30 hours for work that took about 10 active hours.
- Task totals drift as planners revise plans (516, 517, 520, 521 observed); the percentage must be read against the live total.
- Tail from plan complete to merge: 0.8 to 4 hours per feature; each remediation cycle adds 45 to 90 minutes.
- Weekly quota burn: 3 to 7 points per hour depending on concurrency; 4.3 to 7.6 tasks per weekly point.
- Pitfall recorded in the memory and visible in the CSV: readings at about 25 minutes past each hour (the hourly Full run) fall 4 to 52 seconds or about 4 minutes from a TL;DR reading, so the hourly run adds an extra, shorter interval to the sample set whenever it is more than 90 seconds from the previous sample.

#### Reproduction of the pairing example from recorded samples (hand-computed)

The 5-minute readings before the cadence change end at the CSV reading taken at `01:12:49` UTC on the second day of the run. Applying the tool's retention rule (a sample is kept only when at least 90 seconds after the previous one; the newest 14 are kept) to the CSV readings gives the 14 samples below. The reading 27 seconds after `00:25:09` (`00:25:36`) is not a sample under the 90-second rule. Offsets are seconds from the oldest retained reading; the CSV holds reading times, which may differ by a few seconds from the script's own sample timestamps.

| Index | CSV reading (UTC) | ts offset (s) | done |
|---|---|---|---|
| s0 | 00:10:53 | 0 | 131 |
| s1 | 00:15:39 | 286 | 132 |
| s2 | 00:20:25 | 572 | 140 |
| s3 | 00:25:09 | 856 | 141 |
| s4 | 00:29:57 | 1144 | 142 |
| s5 | 00:34:41 | 1428 | 144 |
| s6 | 00:39:27 | 1714 | 145 |
| s7 | 00:44:12 | 1999 | 145 |
| s8 | 00:48:55 | 2282 | 147 |
| s9 | 00:53:41 | 2568 | 154 |
| s10 | 00:58:27 | 2854 | 155 |
| s11 | 01:03:12 | 3139 | 156 |
| s12 | 01:07:57 | 3424 | 158 |
| s13 | 01:12:49 | 3716 | 158 |

- Thirteen 5-minute intervals (tasks per hour): 12.587, 100.699, 12.676, 12.500, 25.352, 12.587, 0, 25.442, 88.112, 12.587, 12.632, 25.263, 0. Mean 26.1875 (prints 26.2). Sample SD (n-1) 31.4495, which prints 31.4, not 31.5. The CSV itself records `sd` 31.4 at the `01:12:49` reading, which corroborates the computation. The requirement's 31.5 is therefore not reproducible from the recorded timestamps (ORCHESTRATOR-CONFIRM, owner item).
- Pairing newest first keeps s13, s11, s9, s7, s5, s3, s1 and drops s0 (13 intervals is odd, so the oldest interval is discarded). Six 10-minute intervals: 56.842, 18.881, 6.305, 56.942, 12.609, 12.478. Mean 27.3430 (prints 27.3); SD 23.2316 (prints 23.2). Both match the requirement.
- The CSV shows the SD falling from 31.4 to 21.3 between the `01:12:49` and `01:21:13` readings, consistent with the pairing having been applied there.
- These 14 `(ts offset, done)` pairs are the fixed input of the pairing unit test. Assertions use a tolerance of 0.001 on the unrounded values and exact equality on the one-decimal text from `Format-EpicProgressNumber -Digits 1`.

### Precedent: skills that ship scripts, the push-down, and issue #762

- `.claude/skills/cleanup-merged-worktrees/` ships eleven bash files under `scripts/`; each is listed in `core.json` and mirrored byte-identically under the bundle. The skill invokes `bash .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh` in both its body and its `allowed-tools`.
- Issue #762 (feature record `docs/features/archive/2026-09-28-skill-referenced-scripts-not-bundled-762/`) moved the cleanup scripts into the skill folder with `git mv` and moved `Invoke-CiGateParser.ps1` to `.claude/lib/ci-gate/`, then added the guard `scripts/dev_tools/skill_bundle_contract.py` with its I/O boundary `scripts/dev_tools/skill_bundle_contract_cli.py` and the repository test `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`. The convention it established:
  - Every script a skill invokes, and every file inside a skill folder, must exist in the bundle under a published root (`PUBLISHED_ROOT_FOLDERS = (".claude", "config")`, pinned equal to the TypeScript `ROOT_FOLDERS`) and be listed in `core` or in every pack that installs the skill. Violation reasons: `missing-file`, `not-in-bundle`, `not-in-skill-pack`. Folder location is never itself a reason.
  - Invocation forms extracted: `bash|sh|source <path>`, `pwsh ... -File <path>`, `& <path>`, `. <path>`, `Import-Module <path>`, `python <path>.py`, and `python -m <module>`, from the body and from each `allowed-tools` entry (a `Bash(...)` wrapper is unwrapped). A token containing `*`, `<`, `>`, `{`, `}`, or `$` is a placeholder and is ignored; a backticked path without an invocation form is a citation and is ignored.
  - `test_every_skill_script_reference_is_bundled` and `test_every_skill_folder_file_is_carried_by_skill_packs` run in CI through pytest. `KNOWN_UNBUNDLED_REFERENCES` is empty.
  - Consequence for this skill: any `pwsh -NoProfile -File scripts/dev-tools/...` text in the skill body or `allowed-tools` fails the guard with `not-in-bundle`. The skill must invoke only `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1`.
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) requires every distributable `.claude/**` file to exist in the bundle with equal text; `.claude/state/**`, `.claude/agent-memory/**`, `.claude/worktrees/**`, and `.claude/settings.local.json` are exempt.
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` (`test_bundled_claude_files_are_listed_in_some_pack_manifest`) requires every bundled file to be listed in a pack manifest.
- `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` (`test_claude_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized`, `test_scanned_source_floor`) requires each `$PSScriptRoot` dependency of a manifested `.ps1` to be in core plus the owning pack, and each `$PSScriptRoot` occurrence to match a recognized form. The F2 named form `Join-Path -Path $PSScriptRoot -ChildPath '<file>'` is recognized.
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` scans every pushed `SKILL.md` for the consuming product names `TaskMaster` and `No-COM`; the new skill must contain neither.
- `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` is the Pester precedent for a core-manifest membership test (`lists the CI gate parser path in core.json paths`, `lists the CI gate parser path exactly once`). `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1` is the Pester precedent for skill-text assertions.
- Push-down mechanics: `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts` merges `.claude/state/` into the destination `.gitignore`, and `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts` lists `.claude/state` among its local-only paths.

### make-skill-template and skill-canonical-location-audit

- `make-skill-template` requires `name` (lowercase, hyphenated, equal to the folder name) and a single-quoted `description` stating what the skill does and when to use it; it recommends `## When to Use This Skill`, prerequisites, step-by-step workflows, troubleshooting, and references; body under 500 lines; optional `scripts/` folder.
- `skill-canonical-location-audit` flags an item whose canonical location is defined by two skills. The state-file location defined by this skill is defined nowhere else. The 93 percent stop rule is coordinator policy stated by the owner; `quota-throttling` states the 95 percent viability gate and the commit-before-the-wall procedure. The new skill cross-references `quota-throttling` rather than restating its procedure.
- Repository practice for user-invocable skills: frontmatter carries `name`, `description`, optionally `argument-hint`, and `allowed-tools`; skills that must run in the main session omit `context: fork` (for example `cleanup-merged-worktrees`, `quota-throttling`). Claude Code skills are invocable as `/<name>` unless `user-invocable: false` is set, so no extra key is needed for `/epic-progress-report`.
- Mirrors: `quota-throttling` is a Claude-only skill (no `.agents/skills` or `.github/skills` copy), which is accepted by every contract test. The new skill depends on Claude Code tools (`CronCreate`, `CronList`, `CronDelete`, `PushNotification`), so it is Claude-only as well.

### Places that enumerate skills or pin counts

Searched the whole worktree for files outside `docs/features/**` and the skill folders that name an existing Claude-only skill (`quota-throttling`, `cleanup-merged-worktrees`, `show-my-agent-tree`, `identify-session-id`):

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: the only registry the new skill must be added to.
- `.claude/settings.json` `permissions.allow` lists some `Skill(...)` entries but not `cleanup-merged-worktrees` or `quota-throttling`; registration there is not required and is not recommended (it is a core file with its own closure tests).
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` scans skills by glob; no count changes.
- `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` asserts only the migration-research reference and the `.github/skills/README.md` rule; it pins no skill list or count.
- No README or architecture document enumerates the Claude skills.

### Coverage and Pester scan configuration

- `config/poshqc-coverage.json` roots: `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.github/hooks`, `.codex/scripts`, `scripts`. `.claude/skills` is absent, and no `.ps1` or `.psm1` file exists under `.claude/skills` today. Under the Coverage Exclusion Policy the new canonical PowerShell files must be measured, so `.claude/skills` must be added as a root. No test pins the real root list (`PoshQC.CoverageConfig.Tests.ps1` and `PoshQC.Coverage.Tests.ps1` use in-memory configurations).
- `config/poshqc-scan.json` scan folders: `scripts`, `tests/powershell`, `tests/scripts`. Tests placed under `tests/scripts/claude-skills/epic-progress-report/` are discovered and assigned to a shard automatically.
- `_poshqc.yml` runs `Invoke-PoshQCFormat` and `Invoke-PoshQCAnalyze` over the whole workspace root, so the canonical files and their bundle copies are formatted and analyzed.

### Claude Code scheduling and notification tools (verified from the public documentation)

- `CronCreate` takes a 5-field cron expression, the prompt, and whether it recurs; `CronList` lists tasks with IDs, schedules, next run times, and prompts; `CronDelete` cancels a task by its 8-character ID. A session holds up to 50 tasks.
- Tasks are session-scoped. They fire only while the session runs and is idle; a missed run fires once, not once per missed interval. `claude --resume` or `--continue` restores unexpired `CronCreate` tasks. Recurring tasks expire 7 days after creation (one final fire, then deletion).
- Cron times are local time, not UTC.
- Jitter: an every-10-minutes task runs a constant 0 to 5 minutes late; an hourly task runs a constant 0 to 30 minutes late; only `*/5 * * * *` runs early (4 minutes 45 seconds after the previous run).
- `PushNotification` sends a desktop notification from a local session and a phone push with Remote Control or in a cloud session.

## Decision Record

### D1. Single source of truth for the script

Choice: canonical files in `.claude/skills/epic-progress-report/scripts/`; `scripts/dev-tools/Get-EpicProgressReport.ps1` becomes a forwarder; `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1` is removed by `git mv` into the skill folder.

Forwarder content (the entire executable body, with a comment-based help block whose synopsis states that it forwards and names the canonical path):

```powershell
& (Join-Path -Path $PSScriptRoot -ChildPath '../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1') @args
```

The forwarder has no `param()` block, so every argument reaches the canonical script's binder unchanged, including new switches, and the forwarder never drifts from the canonical parameter surface.

Alternatives:

- Byte-identical copies in both locations with a Pester parity test. Rejected: the logic would exist twice in the repository (three times with the bundle), both copies sit in coverage roots, so every test would have to run against both, and the 700-line split would be duplicated.
- Forwarder with a duplicated `param()` block that dot-sources or invokes the canonical file depending on `$MyInvocation.InvocationName`. Rejected: the parameter surface would exist twice, and the branch not taken by tests (one of two statements) would stay uncovered.
- Removing `scripts/dev-tools/Get-EpicProgressReport.ps1`. Rejected: the requirement keeps that path working.
- Keeping the canonical file in `scripts/dev-tools/` and invoking it from the skill. Rejected: `scripts/**` is not published, so the skill-bundle guard reports `not-in-bundle` and the skill fails in a destination (the #762 defect).

Rationale and constraints checked:

- `$PSScriptRoot` dot-sourcing: the canonical entry and the Logic hub dot-source siblings in the same folder with the F2 form, which resolves identically in this repository, in the bundle, and in a destination, where `scripts/dev-tools` does not exist.
- Dependency closure: the canonical files are all listed in `core`, so `test_claude_manifest_powershell_dependency_closure` holds; the forwarder is not manifested and is not scanned.
- Coverage: the forwarder is under the `scripts` root and is measured. Its single statement is executed by the forwarder tests (binding-failure invocations, see Test Inventory), so it is fully covered without running git. The canonical files are measured once `.claude/skills` is added to `config/poshqc-coverage.json`.
- Tests: the #1080 test cases keep passing, repointed to the canonical files; because the tested files move, the suites move with them to `tests/scripts/claude-skills/epic-progress-report/` under the mirror rule in `.claude/rules/general-unit-test.md` (precedent: `.claude/lib/ci-gate` is tested from `tests/scripts/claude-lib/ci-gate/`). A new `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` covers the forwarder.

Risks:

- Named-argument forwarding through `@args` when the forwarder is started with `pwsh -NoProfile -File ... -EpicFolder x`. PowerShell tags arguments that were written as `-Name` so that `@args` re-splats them by name; this is believed to hold for `-File` invocation but is ORCHESTRATOR-CONFIRM. Verification without I/O: `pwsh -NoProfile -File scripts/dev-tools/Get-EpicProgressReport.ps1 -EpicFolder example-epic -StartUtc 2026-01-05T09:00:00Z -SampleCap 0` must fail with the `ValidateRange` error naming `SampleCap` from the canonical script, not with a positional-binding error. Fallback if it does not hold: give the forwarder a `param()` block identical to the canonical one, forward `@PSBoundParameters`, and add an AST parity test comparing the two blocks.
- A user who dot-sources the forwarder runs the report instead of loading functions. Dot-sourcing is a test technique only; the forwarder's help says to dot-source the canonical file.

### D2. Delivery to a destination repository

Choice:

- Bundle copies at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/SKILL.md` and `.../scripts/Get-EpicProgressReport.ps1`, `.Logic.ps1`, `.State.ps1`, `.Metrics.ps1`, `.Render.ps1`, byte-identical to the canonical files.
- Six new entries in `pack-manifests/core.json`, next to the existing `cleanup-merged-worktrees` block: the `SKILL.md` and the five scripts.
- The push-down publishes `.claude/**` from the installed extension's bundled payload. A repository-side change reaches a destination only after the extension is rebuilt and reinstalled (execution-environment brief, `## MCP Surfaces Run the Installed Extension`). The skill states this in its notes.
- Destination prerequisites the skill must list: PowerShell 7 (the code uses `Test-Json`, `Join-Path -AdditionalChildPath`, and `ConvertFrom-Json -NoEnumerate` if adopted), `git`, an epic kickoff with a feature-summary table, and optionally `gh` and `cswap` (the report prints empty PR state and `n/a` quota without them).

Alternatives: a separate pack instead of `core`. Rejected: the epic skills it serves (`epic-run`, `epic-plan`, `epic-orchestrate`) are in `core`, and a pack-only skill would need every pack that installs it to carry the scripts.

### D3. Persistent default state location

Choice: default `StatePath` = `Join-Path -Path <RepositoryRoot> -ChildPath '.claude' -AdditionalChildPath 'state', "epic-progress-<EpicFolder>.json"`. `-StatePath` still overrides it. `Write-EpicProgressState` creates the `.claude/state` directory when it is missing, inside its `ShouldProcess` block.

Candidates evaluated:

| Candidate | Survives container stop | Never committed | Portable, no host path | Verdict |
|---|---|---|---|---|
| System temporary directory (current) | No (observed loss) | Yes | Yes | Rejected: the observed failure |
| `<RepositoryRoot>/.claude/state/` | Yes where the checkout persists (Codespaces keep the workspace folder; a local devcontainer uses a host bind mount) | Yes: `.gitignore` has `.claude/state/`; the push-down merges `.claude/state/` into destination `.gitignore`; the bundle contract exempts `.claude/state/**` | Yes, derived from the repository root | Selected |
| `<RepositoryRoot>/artifacts/` | Yes | Yes (`/artifacts` is gitignored here) | Yes | Rejected: `artifacts/` is the orchestration area governed by evidence-location rules and checkpoint hooks, and it is not guaranteed to be gitignored in a destination by the push-down |
| User profile (for example a state folder under the home directory) | Not in a Codespace rebuild; differs per operating system | Yes | Requires per-OS path derivation | Rejected |
| Explicit `-StatePath` only, no default | Depends on caller | Depends on caller | Yes | Rejected as the only option; retained as an override |

Trade-offs to document in the skill: the state is per checkout, so running from a different worktree or with a different `-RepositoryRoot` starts a separate sample history (always run from the same root, or pass `-StatePath`); `git clean -fdX` deletes it; an existing state file under the temporary directory is not migrated (pass `-StatePath` to it once, or reset the baseline).

### D4. Script additions

Parameter surface after the change (15): the 13 existing parameters, with `StartUtc` no longer mandatory, plus `-ResetBaseline` and `-PairSamples` (both `[switch]`). Types and defaults of the existing parameters are unchanged; "was a value passed" is read from `$PSBoundParameters.ContainsKey(...)` in `Invoke-EpicProgressReport`, which receives the entry block's bound parameters.

State document (new, written by `ConvertTo-EpicProgressStateJson`):

```json
{
  "version": 1,
  "startUnixSeconds": 1767603600,
  "baselineDone": 0,
  "baselineWeeklyPct": 0,
  "samples": [ { "ts": 1767614400, "done": 3 } ]
}
```

- Epoch seconds for the start instant, for the same reason the samples use them: `ConvertFrom-Json` converts ISO strings into local-time `DateTime` values.
- `ConvertFrom-EpicProgressStateText` (pure) accepts the legacy JSON array (samples only, no baseline), the version-1 object, and blank or unparseable text (empty state, as today). A version other than 1 is treated as unparseable.

Baseline resolution (`Resolve-EpicProgressBaseline`, pure):

- `StartUtc`: the passed value, else the stored value, else, with `-ResetBaseline`, the current instant from the clock seam. With none of these the run stops with a terminating error that names `-StartUtc` and `-ResetBaseline`, raised before any git call (the state is read first).
- `BaselineDone`: the passed value, else, with `-ResetBaseline`, the current done count, else the stored value, else 0.
- `BaselineWeeklyPct`: the passed value, else the stored value, else 0. `-ResetBaseline` does not capture the current quota, because the Full line says "points since the epic started" and that wording must not change (ORCHESTRATOR-CONFIRM, owner item).
- A passed value overrides a stored one and is persisted on the next write. Consequence for the skill: scheduled prompts omit `-StartUtc` and `-BaselineDone`, so a reset is never overridden by a stale scheduled argument.

`-ResetBaseline` semantics: discard every stored sample, resolve the baseline as above, then apply the normal sample rule (which adds the first sample, `(now, done)`), and write the state. Typical use after a pause: one manual run with `-ResetBaseline` (optionally `-StartUtc <resume instant> -BaselineDone <done at resume>`). The first reports after a reset show `0 h 00 min` elapsed and `n/a` estimates, which is expected.

`-PairSamples` semantics (`Merge-EpicProgressSamplePair`, pure):

- Applied after the normal sample rule, so the current check-in is part of the newest pair.
- Keeps the newest sample and every second older sample (indices n-1, n-3, ...). With k = n-1 intervals the result has floor(k/2) intervals, each spanning two original intervals; when k is odd the oldest interval is discarded. 14 samples become 7 (13 intervals become 6, as in the requirement); 13 become 7; 2 become 1; 1 and 0 are unchanged.
- It rewrites the stored samples, so later runs see the doubled spacing. It is not idempotent by design: each application doubles the spacing again. The skill presents it as a one-shot command that must never appear in a scheduled prompt. A unit test documents that applying it twice to 14 samples leaves 4.
- `-ResetBaseline` and `-PairSamples` in the same run raise a terminating error before any I/O, because a reset leaves nothing to pair.

Write rule: the state is written when the sample rule added a sample, or `-ResetBaseline` or `-PairSamples` was given. A run within 90 seconds of the last sample with neither switch writes nothing (unchanged behavior, keeps `does not write the state file within 90 seconds of the last sample` valid). A passed baseline value is persisted with the next write, at most one check-in later.

`n/a` instead of NaN: already met by the merged tool (see Findings). Work for this issue: (a) a Metrics test for three or more zero-rate intervals with average 0 (`n/a hrs to no upper bound (...)`), and (b) a Render test asserting that neither the TL;DR nor the Full lines contain the substring `NaN` or `Infinity` in the before-first-task scenario. If (a) shows that PowerShell raises on the zero divisor, `Get-EpicProgressRangeText` gains a guard that returns the `n/a` text when `average + 2.05 x SD` is not above 0; that guard changes output only for inputs that currently fail.

Byte-identical output for unchanged inputs:

- The moved functions (`Format-*`, velocity, critical path, range, summary, TL;DR, Full) are moved verbatim; no output-producing code changes.
- Regression design: (1) keep the four existing golden tests with their expected strings unchanged; (2) add one golden test through `Invoke-EpicProgressReport` with a legacy-array state of four samples (three intervals, bounded range) in Full mode. Its expected 26 lines are captured from the pre-change code in Phase 0 by dot-sourcing the merged `scripts/dev-tools` files from a `SCRATCH` script with the same mocked inputs, recorded under `<FEATURE>/evidence/baseline/`, and then pasted into the test. Injected seams: `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-CswapExe`, `Test-EpicProgressCommand`, `Test-EpicProgressPath`, `Read-EpicProgressFile`, `Write-EpicProgressState`, `Get-EpicProgressUtcNow`, `Get-EpicProgressLastExitCode`. No temporary files, no network, no wall clock.

### D5. Split of Get-EpicProgressReport.Logic.ps1

| New file (in `.claude/skills/epic-progress-report/scripts/`) | Functions | Approximate lines |
|---|---|---|
| `Get-EpicProgressReport.Logic.ps1` (hub, `git mv` of the current file, then trimmed) | header; dot-sources of State, Metrics, Render (F2 form); `Test-EpicProgressJsonText`, `ConvertFrom-EpicProgressKickoffRow`, `Get-EpicProgressIssueFromKickoff`, `ConvertFrom-EpicProgressWorktreeList`, `ConvertFrom-EpicProgressPrList`, `Get-EpicProgressWeeklyQuota`, `Get-EpicProgressTaskCount`, `Get-EpicProgressCurrentPhase`, `Get-EpicProgressFeatureState` | about 250 |
| `Get-EpicProgressReport.State.ps1` (new) | `Resolve-EpicProgressSetting` (moved from the entry script, `-TempRoot` removed), `Select-EpicProgressSample` (moved verbatim), new `ConvertFrom-EpicProgressStateText`, `ConvertTo-EpicProgressStateJson`, `Resolve-EpicProgressBaseline`, `Merge-EpicProgressSamplePair` | about 280 |
| `Get-EpicProgressReport.Metrics.ps1` (new) | `Format-EpicProgressHour`, `Format-EpicProgressClock`, `Format-EpicProgressNumber`, `Get-EpicProgressAverageVelocity`, `Get-EpicProgressRecentVelocityInterval`, `Get-EpicProgressStandardDeviation`, `Get-EpicProgressCriticalPath`, `Get-EpicProgressRangeText`, `Get-EpicProgressWeeklyText` (all moved verbatim) | about 230 |
| `Get-EpicProgressReport.Render.ps1` (new) | `Get-EpicProgressSummary`, `Get-EpicProgressTldrLine`, `Get-EpicProgressFullLine` (moved verbatim) | about 190 |
| `Get-EpicProgressReport.ps1` (entry, `git mv`) | seams, `Invoke-EpicProgressReport`, entry block; `Resolve-EpicProgressSetting` moved out | about 470 after the D4 wiring |

The hub keeps the existing single dot-source line in the entry script valid, and any test that dot-sources the hub receives every function. Each file stays below the 500-line guidance tier. The State file keeps the pure state logic apart from the I/O seams (separation of concerns), which is also why `Resolve-EpicProgressSetting`, a pure function, moves there from the entry script.

Effect on existing tests (each named test and its disposition is listed in the Test Inventory). Two existing assertions depend on the move itself: `reads the raw text of an existing file` matches `function Resolve-EpicProgressSetting` in the entry script's text and must match `function Invoke-EpicProgressReport` instead; the repository-constraints suite must scan all five canonical files instead of two.

### D6. Skill content outline

Frontmatter:

```yaml
---
name: epic-progress-report
description: 'Start, read, reset, re-pace, and stop the recurring progress reports of a running epic: a four-line TL;DR every 10 minutes and an hourly full status update with a push notification, produced by the bundled Get-EpicProgressReport.ps1. Use when a coordinator runs an epic and needs task progress, velocity, time-remaining, and weekly-quota reporting, after a pause or a session restart, or when changing the check-in cadence.'
argument-hint: "[epic-folder] [start|reset|pair|stop]"
allowed-tools:
  - Read
  - Glob
  - "Bash(pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 *)"
  - "Bash(cswap list*)"
  - CronCreate
  - CronList
  - CronDelete
  - PushNotification
---
```

No `context: fork`: the cron jobs and notifications belong to the coordinator's main session.

Sections and required content:

1. `# Epic Progress Report` and `## When to Use This Skill`.
2. `## Prerequisites`: PowerShell 7, `git`; optional `gh` and `cswap`; the kickoff at `docs/features/epics/<epic-folder>/epic-kickoff.md` on `origin/epic/<epic-folder>-integration` with a feature-summary table and an `Epic issue: #<n>` line (or pass `-EpicIssue`); the epic checkpoint `artifacts/orchestration/epic-orchestrator-state.json`; run from the coordinator's repository root. Inside an agent-isolated worktree the runtime refuses command text containing `pwsh`; run from the main session.
3. `## Inputs`: one row per parameter (15), with defaults, including the new state default and the two switches.
4. `## Report Formats`: the exact TL;DR template taken from `Get-EpicProgressTldrLine`:

   ```text
   **TL;DR:** Epic #<issue> is at <done> of <total> tasks (<pct>%). <done-sentence> <running-sentence>
   **Elapsed:** <H h MM min>, with about <hours> hours left on the wave-parallel estimate. **Weekly** quota is at <pct>%.
   **Avg Velocity:** <avg> tasks / hr. **Recent Velocity:** <recent> tasks / hr since last check-in. (SD of recent velocity: <sd>, from <n> intervals)
   **Estimated time remaining:** <range>
   ```

   with the variants: done-sentence `None of the <N> features is done yet.` or `<K> of <N> features are done.`; running-sentence `No feature is running.`, `#<i> is running (<d> of <t>).`, or `#<a> (<d> of <t>), #<b> (<d> of <t>) are running.`; range `<HH:MM> hrs (range needs 3 or more check-in intervals)`, `<HH:MM> hrs to <HH:MM> hrs`, or `<HH:MM> hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)`; any non-finite figure prints `n/a` (the quota prints `n/a` without `%`). Note that the merged output adds the SD clause and prints integral values without a decimal, which differs from the owner's first draft; the merged tool is the reference. The Full report contents from `Get-EpicProgressFullLine`: a blank line; `## Epic #<issue> <epic-folder>: status at HH:mm UTC, MMM d`; the Elapsed and Progress line; the State table (Completed, one Running row per running feature with wave, band, done of total, percentage, current phase and PR, one Pending row per wave); the Wave table with a bold Total row; the Velocity and Remaining line; the straight-line estimate (upper bound); the wave-parallel estimate with its chain length and per-wave overhead; the weekly-quota line with the delta since the start and the note that the pool covers other runs.
5. `## Calculation Rules`: every rule in the requirements, restated from the code (task counting, feature states, elapsed, average, straight-line, wave-parallel, samples and the 90-second rule, the 14-sample cap, epoch seconds, interval velocity with the 2-minute minimum and clamp at 0, recent velocity, sample SD with n-1 and the 3-interval minimum, the range formula, the 0.5 threshold, `HH:MM` and `N h MM min`, the weekly quota source). State the range as "average plus and minus 2.05 SD" and note it as an owner-confirmation item (D8).
6. `## Starting the Reports`: first run (`-StartUtc` and `-BaselineDone`, or `-ResetBaseline` to start from now); then create the two jobs with `CronCreate`.
7. `## Scheduling Prompts`, parameterized by `<epic-folder>`:
   - TL;DR job, cron `*/10 * * * *`, recurring: "Run `pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder <epic-folder> -Mode TLDR` from the repository root and post its output verbatim as the TL;DR epic update (no push notification). Do not add commentary unless a run is blocked or a child has finished and needs relaying."
   - Hourly job, cron `7 * * * *`, recurring: "Run `pwsh -NoProfile -File .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1 -EpicFolder <epic-folder>` (full mode) from the repository root and post its output as the hourly epic update, then send a PushNotification with the TL;DR line (under 200 characters). Check `cswap list` for the weekly pool; stop and commit at 93%."
   - Notification text rule: the first output line with the `**` markers removed; if it is 200 characters or longer, drop the running-features sentence (ORCHESTRATOR-CONFIRM, owner item).
   - Notes: cron times are local; jitter delays each job by a constant amount (0 to 5 minutes for the 10-minute job, 0 to 30 minutes for the hourly job); prompts deliberately omit `-StartUtc` and `-BaselineDone` (read from state).
8. `## Resetting the Baseline After a Pause`: whenever work resumes after a pause or outage, run once with `-ResetBaseline` (with `-StartUtc` and `-BaselineDone` when the resume instant is in the past); earlier measures are discarded; do not change the scheduled prompts.
9. `## Changing the Cadence`: run once with `-PairSamples`, then delete the TL;DR job and recreate it at the new interval; never put `-PairSamples` in a prompt.
10. `## Stopping the Reports`: `CronList`, then `CronDelete` for each report job ID; the state file may be kept for a later restart or deleted.
11. `## After a Restart`: run `CronList`; `claude --resume` or `--continue` restores unexpired jobs, so recreate only missing ones; a recurring job expires 7 days after creation, so recreate both before then; if work paused during the restart, reset the baseline first; the state file survives because it is under `.claude/state/`.
12. `## State File`: location, never committed, per-checkout trade-offs (D3), the document format.
13. `## Known Behaviors and Measured Rates`: the summarized rates and pitfalls from the velocity memory (without naming the epic), plus: an hourly run more than 90 seconds from the last TL;DR sample adds a shorter interval, which raises the SD; estimates are unreliable for about 2 hours after a baseline; totals drift with plan revisions; flat stretches of 20 to 60 minutes are normal.
14. `## Notes`: push-down delivery requires an extension rebuild and reinstall; the stop-at-93% rule is coordinator policy, and `.claude/skills/quota-throttling/SKILL.md` governs the commit-before-the-wall procedure; the tool is read-only toward git and GitHub.

Text constraints for the skill: no epic number, epic folder name, host path, drive letter, account name, or token; the only invocation form is the canonical script path; no `TaskMaster` or `No-COM`; under 500 lines.

### D7. Cross-reference in epic-run, epic-plan, or epic-orchestrate

Choice: none. The skill is discoverable as `/epic-progress-report` and by its description. `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` are pinned by `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, so a one-line change there would require a documented re-baseline. `epic-run`, `epic-plan`, and `epic-orchestrate` are also mirrored under `.agents/skills/` (and the Codex bundle), so a one-line addition would touch at least five files and the Codex generator check for no functional gain.

### D8. Range wording

The merged `Get-EpicProgressRangeText` computes fast hours with `average + 2.05 x SD` and slow hours with `average - 2.05 x SD`, and prints the unbounded wording when the slow velocity is at or below 0.5. The owner's text says "adding 2.05 x that number to the average velocity", which describes only the fast end. The implemented behavior is kept, documented in the skill, and listed for owner confirmation. A second nuance for the same confirmation: the SD is the sample SD of the interval velocities (the history of recent velocity), and the range applies to the wave-parallel critical path, not to the straight-line estimate.

## Complete File Inventory

| Path | Action | Notes |
|---|---|---|
| `.claude/skills/epic-progress-report/SKILL.md` | Create | D6 |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | `git mv` from `scripts/dev-tools/`, then edit | D4 wiring, help (paths, new parameters, state default), `Resolve-EpicProgressSetting` moved out, example paths updated |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1` | `git mv` from `scripts/dev-tools/`, then trim | D5 hub |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` | Create | D4, D5 |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1` | Create | moved functions; optional zero-divisor guard (D4) |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` | Create | moved functions |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/SKILL.md` | Create | byte copy |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-progress-report/scripts/` (five `.ps1` files) | Create | byte copies, written after formatting |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Modify | six entries |
| `scripts/dev-tools/Get-EpicProgressReport.ps1` | Recreate as forwarder after the `git mv` | D1 |
| `config/poshqc-coverage.json` | Modify | add root `.claude/skills` |
| `.gitignore` | No change | `.claude/state/` already ignored |
| `.claude/settings.json`, `epic-run`, `epic-plan`, `epic-orchestrate` and their mirrors, `.agents/skills`, `.github/skills` | No change | D7; Claude-only skill |
| `.claude/skills/execution-environment/SKILL.md` and its five copies | No change | no stated fact changes (no CI job, required context, tool route, or batch-budget rule changes; the brief names `config/poshqc-coverage.json` without listing its roots) |
| `extensions/drm-copilot/CHANGELOG.md` | ORCHESTRATOR-CONFIRM | whether a resource change needs an entry |

## Test Inventory

### Existing tests and disposition

`tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1` moves (`git mv`) to `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Logic.Tests.ps1`; its dot-source points at the canonical hub. Its `Describe` blocks:

| Describe | Disposition |
|---|---|
| `ConvertFrom-EpicProgressKickoffRow` | Unchanged, stays in Logic tests |
| `Get-EpicProgressIssueFromKickoff` | Unchanged, stays |
| `ConvertFrom-EpicProgressWorktreeList` | Unchanged, stays |
| `ConvertFrom-EpicProgressPrList` | Unchanged, stays |
| `Get-EpicProgressWeeklyQuota` | Unchanged, stays |
| `Get-EpicProgressTaskCount` | Unchanged, stays |
| `Get-EpicProgressCurrentPhase` | Unchanged, stays |
| `Get-EpicProgressFeatureState` | Unchanged, stays |
| `Format-EpicProgressHour, Format-EpicProgressClock, and Format-EpicProgressNumber` | Moved unchanged to Metrics tests |
| `Select-EpicProgressSample` | Moved unchanged to State tests |
| `Get-EpicProgressAverageVelocity` | Moved unchanged to Metrics tests |
| `Get-EpicProgressRecentVelocityInterval` | Moved unchanged to Metrics tests |
| `Get-EpicProgressStandardDeviation` | Moved unchanged to Metrics tests |
| `Get-EpicProgressCriticalPath` | Moved unchanged to Metrics tests |
| `Get-EpicProgressRangeText` | Moved unchanged to Metrics tests |
| `Get-EpicProgressSummary, Get-EpicProgressTldrLine, and Get-EpicProgressFullLine` | Moved unchanged to Render tests (golden regression anchors) |

`tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` moves (`git mv`) to `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1`; script and logic paths repointed to the canonical folder.

| Test | Disposition |
|---|---|
| `Resolve-EpicProgressSetting` Describe (5 tests) | Moved to State tests; `-TempRoot` removed from every call; `defaults the state path under the temporary root and outside the repository` replaced by `defaults the state path under .claude/state of the repository root`; the other four unchanged in assertions |
| `returns false for an absent command name`, `returns false for an absent path`, `writes nothing when the state write runs with WhatIf`, `returns the last native exit code` | Unchanged |
| `reads the raw text of an existing file` | Updated: match `function Invoke-EpicProgressReport` (the moved function is no longer in the entry script) |
| `warns when git fetch fails`, `does not warn when git fetch succeeds`, `prints the four TL;DR lines in TLDR mode`, `prints the TL;DR block followed by the Full sections in Full mode`, `takes the epic issue from the kickoff when -EpicIssue is absent`, `uses -EpicIssue over the kickoff marker`, `throws when no epic issue can be resolved`, `reads a live plan from the feature worktree`, `prints n/a quota when cswap is not installed`, `prints n/a quota when cswap output is unparseable`, `leaves the PR state empty when gh is not installed`, `leaves the PR state empty when gh output is unparseable`, `passes only fetch, show and worktree list to git`, `passes only pr list to gh`, `does not write the state file within 90 seconds of the last sample` | Unchanged in assertions (explicit `-StartUtc` remains in the fixture) |
| `treats an unparseable state file as empty` | Updated: assert `samples.Count` of the written object is 1 |
| `writes only the state file at -StatePath` | Updated: read `samples[0].ts` and `samples[0].done`, and assert `startUnixSeconds` and `baselineDone` are persisted |
| `confines file writes to Write-EpicProgressState` | Updated: scan all five canonical files; allow `Set-Content` and `New-Item` (directory creation), both inside `Write-EpicProgressState` |
| `confines native commands to their wrappers` | Scan all five canonical files; count stays 3 |
| `contains no recovered hardcoded value` | Scan the five canonical files, the forwarder, and `SKILL.md` |
| `documents every parameter in comment-based help` | Read the canonical entry; count 13 becomes 15 |
| `carries at least one example` | Read the canonical entry; unchanged assertion |

### New tests

| File | Cases |
|---|---|
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.State.Tests.ps1` | moved suites above; `ConvertFrom-EpicProgressStateText` (legacy array, version-1 object, blank, unparseable, unknown version, missing fields); `ConvertTo-EpicProgressStateJson` round trip with integer epoch seconds; `Resolve-EpicProgressBaseline` (passed values win, stored values used, reset defaults to now and current done, reset keeps a passed start, missing start without reset throws, weekly baseline not captured on reset); `Merge-EpicProgressSamplePair` (14 to 7 keeps s13, s11, ..., s1; 13 to 7; 2 to 1; 1 and 0 unchanged; twice on 14 leaves 4; the 14-sample fixture gives mean 26.1875 and SD 31.4495 before, and mean 27.3430 and SD 23.2316 after, each within 0.001, printing 26.2, 31.4, 27.3, 23.2) |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Metrics.Tests.ps1` | moved suites; new: three zero-rate intervals with average 0 give `n/a hrs to no upper bound (...)`; SD with exactly 2 intervals is NaN and with 3 or more is finite |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Render.Tests.ps1` | moved suite; new: before-first-task scenario (done equals baseline, elapsed above 0, zero-rate samples) produces no `NaN` or `Infinity` substring in TL;DR or Full lines |
| `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1` (moved) additions | `-ResetBaseline` clears samples and writes the resolved baseline; `-PairSamples` rewrites the stored samples; both switches together throw before any git call; no `-StartUtc` and no stored start throws before any git call; no `-StartUtc` with a stored start uses it (golden TL;DR); the Full-mode golden with a legacy four-sample state (expected lines captured from the merged tool in Phase 0); both modes with mocked git, gh, and cswap |
| `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1` (new, forwarder suite) | the forwarder's target file exists; the forwarder's AST holds exactly one command invocation and no `param()` block; `-SampleCap 0` raises the canonical `ValidateRange` error naming `SampleCap`; `-Mode Bogus` raises the canonical `ValidateSet` error naming `Mode` (both prove named forwarding and execute the forwarder's statement with no git call) |
| `tests/scripts/claude-skills/epic-progress-report/EpicProgressReport.SkillContract.Tests.ps1` | frontmatter: `name` equals the folder name, single-quoted non-empty `description`, `allowed-tools` contains the canonical `pwsh` entry, no `context: fork`; every path under `.claude/skills/epic-progress-report/` named in the skill exists; every file in the skill folder is listed exactly once in `core.json` and exists byte-identically in the bundle; the skill names no `scripts/dev-tools` invocation; no forbidden token (epic number, folder name, `/workspaces`, drive-letter path); the scheduling prompts contain neither `-StartUtc` nor `-PairSamples` |

Python contract tests that run unchanged and must pass: `test_every_skill_script_reference_is_bundled`, `test_every_skill_folder_file_is_carried_by_skill_packs`, `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `test_bundled_claude_files_are_listed_in_some_pack_manifest`, `test_claude_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized`, `test_scanned_source_floor`, and the `test_push_down_issue_824_follow_ups.py` scans. No Python file is added or edited.

## Numeric Derivation Evidence

Claim: the merged entry script declares 13 parameters (used for the test update from 13 to 15).

- Complete Family: parameters of the param block of scripts/dev-tools/Get-EpicProgressReport.ps1
- Exhaustive Search Scope: the entire repository worktree, in which only scripts/dev-tools/Get-EpicProgressReport.ps1 declares this family and only tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 pins its size
- Inclusion Rules: every variable declared inside the top-level param() block of the script file
- Exclusion Rules: parameters of the functions defined inside the script (Resolve-EpicProgressSetting, Invoke-EpicProgressReport, and the I/O seams)
- Primary Search Strategy or Query Expression: read the top-level param() block that declares the parameters of the param block of scripts/dev-tools/Get-EpicProgressReport.ps1 and list every declared variable in order
- Primary Member Set: EpicFolder, StartUtc, EpicIssue, IntegrationBranch, KickoffPath, RepositoryRoot, CheckpointPath, StatePath, BaselineDone, BaselineWeeklyPct, WaveOverheadHours, SampleCap, Mode
- Primary Count: 13
- Cross-check Search Strategy or Query Expression: list every .PARAMETER entry of the comment-based help that documents the parameters of the param block of scripts/dev-tools/Get-EpicProgressReport.ps1, and compare with the count asserted by the test documents every parameter in comment-based help
- Cross-check Member Set: EpicFolder, StartUtc, EpicIssue, IntegrationBranch, KickoffPath, RepositoryRoot, CheckpointPath, StatePath, BaselineDone, BaselineWeeklyPct, WaveOverheadHours, SampleCap, Mode
- Cross-check Count: 13
- Member-set Comparison: the normalized primary and cross-check member sets are equal, and both equal the count 13 asserted by the existing test

## ORCHESTRATOR-CONFIRM

1. ORCHESTRATOR-CONFIRM: `@args` forwarding preserves named parameters when the forwarder runs under `pwsh -NoProfile -File` (verification command in D1; fallback design in D1).
2. ORCHESTRATOR-CONFIRM: PowerShell returns infinity, not an error, for a `[double]` divided by zero in `Get-EpicProgressRangeText` (the new Metrics test settles it; guard described in D4).
3. ORCHESTRATOR-CONFIRM: relocating the two #1080 suites to `tests/scripts/claude-skills/epic-progress-report/` (required by the test-location mirror rule once the production files move) satisfies "the #1080 tests must keep passing"; every test case is kept, and only the dispositions listed above change assertions.
4. ORCHESTRATOR-CONFIRM (owner): range is average plus and minus 2.05 SD (D8).
5. ORCHESTRATOR-CONFIRM (owner): the 5-minute SD from the recorded samples is 31.4 (31.4495 unrounded), not 31.5; mean 26.2, paired mean 27.3, and paired SD 23.2 reproduce.
6. ORCHESTRATOR-CONFIRM (owner): the push-notification text rule (strip `**`; drop the running sentence at 200 characters or more).
7. ORCHESTRATOR-CONFIRM (owner): `-ResetBaseline` does not reset the weekly-quota baseline, so the Full line's "since the epic started" stays accurate.
8. ORCHESTRATOR-CONFIRM (owner): keep two jobs as specified, accepting that the hourly run adds one shorter interval per hour, or use a single 10-minute job that switches to Full mode on its first run of each hour (uniform sampling). The research recommends the specified two jobs and documents the effect.
9. ORCHESTRATOR-CONFIRM: whether `extensions/drm-copilot/CHANGELOG.md` needs an entry for new bundled resources.
10. ORCHESTRATOR-CONFIRM: the worktree's copies of the merged tool equal the files merged by PR #1087 on `main` (this researcher cannot run `git show`).

## Proposed Acceptance Criteria Refinements

- AC1 (skill): the skill exists at `.claude/skills/epic-progress-report/SKILL.md` with `name: epic-progress-report`, a single-quoted description, `argument-hint`, and `allowed-tools` naming the canonical script, `CronCreate`, `CronList`, `CronDelete`, and `PushNotification`; no `context: fork`; it documents every section listed in D6; it carries no epic number, epic folder name, host path, drive letter, account name, or token.
- AC2 (single source and delivery): the canonical script files live in `.claude/skills/epic-progress-report/scripts/`; `scripts/dev-tools/Get-EpicProgressReport.ps1` forwards every argument to the canonical entry and contains no report logic; the skill folder is mirrored byte-identically in the Claude bundle and every file is listed once in `core.json`; the skill-bundle guard, resource-contract, manifest-completeness, and dependency-closure tests pass.
- AC3 (script additions): `-ResetBaseline` discards stored samples and persists the resolved baseline; `-PairSamples` keeps the newest sample and every second older sample and persists the result; the two switches together fail before any I/O; the default state file is `<RepositoryRoot>/.claude/state/epic-progress-<EpicFolder>.json`; later runs may omit `-StartUtc` and `-BaselineDone`; a run with neither a passed nor a stored start fails before any I/O.
- AC4 (arithmetic tests): fixed-input Pester tests cover average and recent velocity, SD with 2 and with 3 or more intervals, the bounded range and the no-upper-bound wording, pairing of the recorded 14-sample fixture (mean 26.2 and SD 31.4 before; mean 27.3 and SD 23.2 after, subject to owner confirmation item 5), reset, `n/a` with no completed task, and both modes, with no temporary file, network call, or wall-clock read.
- AC5 (regression): the existing golden TL;DR and Full tests pass with unchanged expected strings, and a new Full-mode golden captured from the merged tool before the change passes after it.
- AC6 (contract test): a Pester skill-contract test checks the frontmatter, the existence of every skill-folder path the skill names, the byte-identical bundle copy, and single listing in `core.json`.
- AC7 (toolchain): `config/poshqc-coverage.json` includes `.claude/skills`; every new or changed PowerShell production file reaches at least 85 percent line coverage; no file exceeds 700 lines; the full toolchain passes.
- Remove from AC scope: registration in any README or skill list (none exists), and changes to `epic-run`, `epic-plan`, or `epic-orchestrate` (D7).

## Pre-Mortem

- Review checklists: a reviewer can fail the change for logic duplicated between `scripts/dev-tools` and the skill folder, for a `scripts/dev-tools` invocation in the skill text, or for an owner example restated with the real epic number; mitigation: the forwarder holds one statement, the skill-contract test forbids `scripts/dev-tools` invocations and the epic tokens, and the plan names each owner-confirmation item in the final report.
- Coverage: the new canonical files are outside every coverage root until `config/poshqc-coverage.json` gains `.claude/skills`, and the forwarder would be uncovered without a test that executes it; mitigation: a dedicated task adds the root, the forwarder binding-failure tests execute its statement without I/O, and per-file line coverage is read from `artifacts/pester/powershell-coverage.xml` of a branch-current run, not from the PoshQC MCP summary.
- Mirror parity: the bundle copies of six files and the six `core.json` entries must match the canonical files after formatting; mitigation: copy the files to the bundle only after the format stage of the final toolchain pass, then run `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, and `test_skill_bundle_contract_repo.py`; the execution-environment brief needs no update because no fact it states changes.
- File size: the Logic file (688 lines) and its test suite (702 lines) sit at or above the advisory tier; mitigation: the D5 split and the matching test split keep every production and test file under 500 lines, checked with a physical line count (`@(Get-Content -LiteralPath <path>).Count`), not `Measure-Object -Line`.
- Test isolation: the moved suites dot-source functions into script scope and mock seams; new tests that build state documents could leak `$script:` fixtures, and directory creation in `Write-EpicProgressState` could touch the disk; mitigation: per-test fixtures in `BeforeEach`, `Write-EpicProgressState` mocked or run with `-WhatIf`, no temporary files, and the seeded shuffled file-order Pester run of the touched suites with at least three seeds plus a fresh single-process run over `tests/scripts` and an `Invoke-PoshQCParallelTest` run.
- CI-only behavior: the Windows PowerShell shards resolve the forwarder's relative target and the `.claude/state` default with Windows separators, and the Linux hook-suite job does not run these suites; mitigation: every path in production and tests is built with `Join-Path`, expected paths are built the same way, no fixture uses a drive letter or backslash literal, and the fixture timestamps are fixed epoch values.
- Evidence: the byte-identical regression depends on expected lines captured from the merged tool before any edit, and the batch-budget hook denies a fourth distinct production PowerShell file in direct mode (bundle copies count); mitigation: Phase 0 records the pre-change golden output under `<FEATURE>/evidence/baseline/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`, the run uses a `large` route checkpoint, and every artifact records scratch locations as `SCRATCH` with no absolute path.
