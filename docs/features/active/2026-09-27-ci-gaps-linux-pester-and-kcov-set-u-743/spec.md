# 2026-09-27-ci-gaps-linux-pester-and-kcov-set-u (Spec)

- **Issue:** #743
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-30T07-45
- **Status:** Draft
- **Version:** 0.2

## Context
Two CI coverage gaps surfaced as plan and CI surprises. There is no Linux Pester job, and a bats pattern fails only under CI kcov tracing, with nothing to catch it earlier. A third, related planning defect is that plan checks using `grep -F` with backslash literals behave differently under Git for Windows grep than under CI grep.

This spec is authored from `issue.md` (authoritative requirements) and `research/research.2026-09-30T07-20.md` (findings, citations, and recommended design). The orchestrator's decisions on the research's open questions are binding and are recorded in Scope & Non-Goals and Rollout & Follow-up.

Environment:
- OS/version: GitHub runners (windows-latest for Pester; ubuntu for shell coverage)
- Python version: n/a
- Command/flags used: `.github/workflows/_poshqc.yml` (`runs-on: windows-latest`); `_shell-coverage.yml` (bats + kcov)
- Data source or fixture: #707 (AC-16 "Linux runner" wording), #706 (kcov failures)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. CI's only Pester job runs on windows-latest, so the Codex and Claude hook suites have never run on Linux. Planners keep writing "Linux runner" into Pester acceptance criteria (#707 AC-16, amended as D18).
2. A bats test that sources a `set -u` helper inside `bash -c` fails only under kcov tracing, because kcov reads an unset `BASH_SOURCE`. Local bats and preflight do not catch it (#706 FU-706-3).
3. Git for Windows grep 3.0 reads `\\` in a fixed-string pattern as one backslash, so some plan checks cannot pass locally (#706 FU-706-4).

Expected:
PowerShell suites that must be portable run on Linux as well, and known CI-only failure patterns are caught before CI.

Actual:
As above.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: #707 D18; #706 FU-706-3 and FU-706-4; memory note kcov-bash-c-source-set-u.

Recorded evidence cited by the research:
- `_poshqc.yml:8-10` defines a single job, `poshqc`, on `windows-latest`; no other workflow runs Pester.
- kcov v43 `src/engines/bash-helper.sh` sets `PS4='kcov@${BASH_SOURCE}@${LINENO}@'` and `set -x`, injected into every child bash through `BASH_ENV` (`bash-engine.cc`).
- `docs/features/completed/cleanup-report-registration-lost-false-positive-706/evidence/qa-gates/ci-shell-coverage.2026-09-27T10-38.md:27-42` records the CI failure (run 36325350057) and a local reproduction of it using the same `BASH_ENV`/`PS4` setup.
- `docs/features/completed/cleanup-report-registration-lost-false-positive-706/evidence/regression-testing/predicate-restored.2026-09-27T10-29.md:13-31` records the Git for Windows `grep -F` backslash behavior.


## Scope & Non-Goals
- In scope:
  - Gap 1: a new, separate `ubuntu-latest` job in `.github/workflows/_poshqc.yml` that runs Pester over `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` with code coverage disabled and a distinct test-result artifact name. The job declares `permissions: contents: read`.
  - Gap 1: a new text-based Pester invariant suite, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, asserting the key settings of both `_poshqc.yml` jobs.
  - Gap 1: portable fixes to Codex hook tests that fail on Linux (suspects S1 to S5 in the research), keeping them passing on Windows, plus any further Linux-only failures reported by the first CI run of the new job on this feature's PR.
  - Gap 2: `shell-qc.sh test` (non-coverage mode, `run_test` in `scripts/bash/shell_qc_lib.sh`) runs bats under a kcov-equivalent xtrace setup defined in a new `scripts/bash/kcov_trace_env.sh`, with trace output discarded.
  - Gap 2: bats regression tests in `tests/shell/test_shell_qc_commands.bats`, with fixtures under `tests/fixtures/shell_qc/`.
  - Gap 3: guidance bullets in the "Wrap-Tolerant Assertion Authoring (Mandatory)" section of `.claude/skills/atomic-plan-contract/SKILL.md` and its byte-identical bundle mirror.
- Out of scope / non-goals:
  - `tests/scripts/claude-lib/**` on Linux (orchestrator decision 1; recorded as a follow-up).
  - Making `poshqc / PowerShell hook suites (Linux)` a required status check or any other branch-protection change (orchestrator decision 2; recorded as a follow-up).
  - An opt-out variable for the kcov trace simulation in `shell-qc.sh test` (orchestrator decision 3). No such variable is added.
  - Running the full Pester set, PoshQC format, PoshQC analyze, or PowerShell coverage on Linux.
  - Any change to `run_test_coverage` (`shell-qc.sh test --coverage`); real kcov remains authoritative there.
  - A static `.bats` lint rule, helper `${BASH_SOURCE[0]:-$0}` hardening, or a new plan-gate validator rule (rejected in the research).
  - Edits to `.github/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, or their bundle copies; the Wrap-Tolerant section does not exist in them.
- Explicitly excluded systems, integrations, or datasets:
  - Files owned by concurrent work items, which this feature must not write: `.github/workflows/_quality-checks.yml` (#734), `.github/workflows/_drm-copilot-extension-tests.yml` (#647), `.github/workflows/ci.yml` (#658), and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (#527).
  - `.github/workflows/_shell-coverage.yml`: no change is needed for gap 2.
  - Read-only policy files under `.claude/rules/` and `.github/instructions/`.

## Root Cause Analysis
A Linux Pester leg would also catch Windows-only path assumptions in PowerShell tests (compare the `C:/workspace` class in memory note ci-gate-polling-and-linux-only-test-failures).

- Gap 1: `_poshqc.yml` has one job, on `windows-latest`, so no PowerShell suite has ever executed on Linux. Tests that encode Windows path semantics (drive-letter roots treated as absolute by `[IO.Path]::IsPathRooted`/`GetFullPath`) or that assert `$IsWindows`-gated production behavior pass on Windows and fail on Linux without any signal. The research identified, by static reading:
  - S1 (definite): `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1:335-347` asserts `windows.sandbox="elevated"`, which `.codex/scripts/epic-child-sandbox-preflight.ps1:33` adds only when `$IsWindows` is true.
  - S2 (definite) and S3 (probable): `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1:133-141,164-173,206-214` rely on `C:/repo` being rooted; on Unix it is not, so `GetFullPath` prefixes the current directory.
  - S4 (probable pass, incorrect premise comment): same file, `:45` and `:196-204`.
  - S5 (possible): `C:\...` paths in `epic-child-launch-hardening.Tests.ps1:207-266,427-436` and `epic-child-worktree-launcher.Tests.ps1:191-197,288-304,377,413`.
  - Planners also cite "Linux runner" in Pester acceptance criteria because no guidance states which runner runs which suites.
- Gap 2: the defect is in the interaction with kcov, not in the sourced helper. kcov's PS4 expands `${BASH_SOURCE}` on every traced command. At the top level of `bash -c`, `BASH_SOURCE` is unset; once a sourced file enables `nounset`, the next traced top-level command aborts with `BASH_SOURCE: unbound variable`. Local `shell-qc.sh test` runs plain bats with no tracing, so the condition never reproduces before CI.
- Gap 3: GNU grep 3.0 shipped with Git for Windows interprets `\\` in a `-F` pattern as a single backslash, so a plan check asserting a backslash-containing fixed string returns a different count locally than in CI. The authoring guidance in `atomic-plan-contract` does not warn about this.


## Proposed Fix

### Design summary (what changes where):
- `.github/workflows/_poshqc.yml`: add a second job, `poshqc-linux-hooks`, named `PowerShell hook suites (Linux)`, `runs-on: ubuntu-latest`, `permissions: contents: read`. Steps: `actions/checkout@v7`; import `scripts/powershell/PoshQC/PoshQC.psm1` and run `Install-PoshQCTools`; one `shell: pwsh` step that builds `New-PesterConfiguration` with `Run.Path = @('tests/scripts/claude-hooks','tests/scripts/codex-hooks')`, `Run.Exit = $true`, `CodeCoverage.Enabled = $false`, JUnit output to `artifacts/pester/pester-junit-linux-hooks.xml`, then calls `Invoke-Pester -Configuration $config`; `actions/upload-artifact@v7` with name `poshqc-linux-hook-test-results` (distinct from `poshqc-test-results`). The existing `poshqc` job is byte-unchanged.
- `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (new): text-based invariant suite modeled on `tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1`.
- Codex hook test files: portable fixes for S1 to S5 and any further Linux-only failures reported by CI, using OS-derived synthetic roots (`C:/repo` on Windows, `/repo` elsewhere) or `-Skip:` OS guards following the precedent in `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1:221,233,249,260`. Every OS-guarded Windows case has a non-Windows counterpart asserting the non-Windows behavior where the production code defines one (for S1, the argument is absent).
- `scripts/bash/kcov_trace_env.sh` (new): sets `PS4='kcov@${BASH_SOURCE}@${LINENO}@'` and `set -x`, with a comment citing kcov v43 `src/engines/bash-helper.sh`.
- `scripts/bash/shell_qc_lib.sh` `run_test`: opens a file descriptor on `/dev/null` and invokes bats with `BASH_ENV=<repo>/scripts/bash/kcov_trace_env.sh` and `BASH_XTRACEFD=<that descriptor>`.
- `tests/shell/test_shell_qc_commands.bats` plus new fixtures under `tests/fixtures/shell_qc/`: regression tests through the `SHELL_QC_BATS_BIN` seam.
- `.claude/skills/atomic-plan-contract/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`: two guidance bullets appended to "Wrap-Tolerant Assertion Authoring (Mandatory)".

### Boundaries and invariants to preserve:
- The `poshqc` job in `_poshqc.yml` (steps, `runs-on`, artifact name `poshqc-test-results`, check name `poshqc / PowerShell QC`) is unchanged, so the required-status-check rename procedure in `.github/workflows/README.md:24-65` is not triggered.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and the PoshQC coverage allow-list are unchanged; no production `.ps1`/`.psm1` file is added, so no coverage entry is required.
- Every modified Codex hook test still passes on Windows in the `poshqc / PowerShell QC` job.
- `shell-qc.sh test` keeps its skip markers (`No shell test directories found; skipping.` and `bats not installed; skipping shell tests.`), exit code 0 on skip, and max-exit semantics across test directories.
- `shell-qc.sh test --coverage` (`run_test_coverage`) is unchanged.
- The kcov trace simulation uses a PS4 format identical to kcov's, so it can only fail a test that also fails under real kcov (it is a subset of kcov's behavior).
- Trace output from the simulation is discarded and never reaches bats stdout/stderr.
- Tests create no temporary files, per `.claude/rules/general-unit-test.md`.
- The two `atomic-plan-contract/SKILL.md` copies remain byte-identical.
- No file exceeds 500 lines. `scripts/bash/shell_qc_lib.sh` is 380 lines before this change.

### Dependencies or blocked work:
- No blocking dependency. The design writes none of the files owned by #734, #647, #658, or #527.
- Linux verification depends on GitHub-hosted `ubuntu-latest` runners (PowerShell 7.6.6 and Pester 5.9.0 preinstalled per the runner-images Ubuntu 24.04 readme fetched 2026-09-30).
- Local bats verification requires WSL (`sh file.sh` route in agent worktrees, per repository memory) or CI.

### Implementation strategy (what changes, not sequencing):
No local Linux `pwsh` run is available in the agent environment. The first CI run of `poshqc / PowerShell hook suites (Linux)` on this feature's PR is therefore the authoritative list of Linux failures. The static suspects S1 to S5 are fixed up front; any further Linux-only failure that the first (or any later) CI run reports is fixed within this feature, in a portable way that keeps the test passing on Windows, before merge. The job is re-run until it is green on the branch head.

#### Files/modules to change:
| Path | Action | Change |
|---|---|---|
| `.github/workflows/_poshqc.yml` | Modify | Add job `poshqc-linux-hooks` as specified in the design summary. Existing `poshqc` job unchanged. |
| `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` | Create | Text-based invariant suite for both jobs. |
| `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1` | Modify | S1: split the `windows.sandbox="elevated"` assertion into a Windows-only case and a non-Windows case asserting the argument is absent. S5: fix any cases the Linux run reports. |
| `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` | Modify | S2 to S4: derive the synthetic rooted prefix per OS, or OS-guard the drive-letter-specific cases; correct the `:45` premise comment. |
| `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` | Modify (conditional) | S5: only if the Linux CI run reports failures in this file. |
| Other files under `tests/scripts/claude-hooks/` or `tests/scripts/codex-hooks/` | Modify (conditional) | Only files the Linux CI run reports as failing; each is recorded in the execution evidence. |
| `scripts/bash/kcov_trace_env.sh` | Create | kcov-equivalent `PS4` and `set -x`. |
| `scripts/bash/shell_qc_lib.sh` | Modify | `run_test` runs bats with `BASH_ENV` and `BASH_XTRACEFD` set as specified; header comment for `run_test` updated to describe the simulation. |
| `tests/shell/test_shell_qc_commands.bats` | Modify | New regression tests (see Test Strategy). |
| `tests/fixtures/shell_qc/stub-bin/bats-nounset-source` | Create | Stub bats that runs `bash -c 'source <nounset fixture lib>; true'` and exits with that command's status. |
| `tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset` | Create | Stub bats using the correct `source <lib>; set +u` form; expected to exit 0. |
| `tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh` | Create | Fixture library that runs `set -euo pipefail` at top level. Lives outside the `shell-qc.sh check` discovery roots (`tools`, `scripts`, `.claude/lib/bash`, `.claude/skills`). |
| `.claude/skills/atomic-plan-contract/SKILL.md` | Modify | Two bullets in "Wrap-Tolerant Assertion Authoring (Mandatory)". |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | Modify | Byte-identical copy of the above. |

Exact fixture file names may be adjusted by the planner, provided they stay under `tests/fixtures/shell_qc/` and outside the existing discovery fixture subtrees (`tests/fixtures/shell_qc/scripts/`, `.claude/`, `tools/`) so discovery tests are unaffected.

#### Functions/classes/CLI commands impacted:
- `run_test` in `scripts/bash/shell_qc_lib.sh` (reached through `bash scripts/bash/shell-qc.sh test` and through `scripts/dev_tools/fix_all_branches.py:216-225`).
- GitHub Actions check `poshqc / PowerShell hook suites (Linux)` (new).
- `Invoke-Pester` invoked directly in the new job step; `Invoke-PoshQCTest` is not used by the new job.
- No production PowerShell function signature changes.

#### Data flow and validation changes:
- `run_test` exports `BASH_ENV` and `BASH_XTRACEFD` into the bats process environment. Every non-interactive child bash sources `kcov_trace_env.sh`, enabling xtrace with kcov's PS4 and writing trace lines to the `/dev/null` descriptor.
- The new job writes `artifacts/pester/pester-junit-linux-hooks.xml` and uploads it as `poshqc-linux-hook-test-results`.

#### Error handling and logging updates:
- A bats test that trips the nounset/PS4 condition fails under `shell-qc.sh test` with `BASH_SOURCE: unbound variable` in its output, matching CI kcov behavior; `run_test` returns a non-zero exit code.
- The Linux job fails when any Pester test fails (`Run.Exit = $true`); skipped tests do not fail the job.
- No new logging.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag and no opt-out variable (orchestrator decision 3).
- Rollback is a revert of the `_poshqc.yml` job and the `run_test` change; both are isolated and have no data migration.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `kcov_trace_env.sh` content contract: assigns `PS4='kcov@${BASH_SOURCE}@${LINENO}@'` (single-quoted, byte-identical to kcov v43) and runs `set -x`. It must be sourceable, pass `shell-qc.sh check` (shfmt and shellcheck, with a justified shellcheck directive if SC2016 is reported for the single-quoted expansion), and define nothing else.
- `run_test` contract: bats is invoked with `BASH_ENV` set to the absolute path of `scripts/bash/kcov_trace_env.sh` resolved from the library's own location, and `BASH_XTRACEFD` set to a descriptor opened on `/dev/null`.
- Linux job outputs: JUnit XML at `artifacts/pester/pester-junit-linux-hooks.xml`; artifact name `poshqc-linux-hook-test-results`.

#### Required configuration keys and defaults:
- `_poshqc.yml` job `poshqc-linux-hooks`: `name: PowerShell hook suites (Linux)`, `runs-on: ubuntu-latest`, `permissions: contents: read`; Pester configuration `Run.Path` = `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`; `Run.Exit = $true`; `CodeCoverage.Enabled = $false`; `TestResult.Enabled = $true`, `TestResult.OutputFormat = 'JUnitXml'`, `TestResult.OutputPath = 'artifacts/pester/pester-junit-linux-hooks.xml'`.
- No new environment variables are read by `shell-qc.sh`.

#### Backward-compatibility expectations:
- Check name `poshqc / PowerShell QC` and artifact `poshqc-test-results` unchanged.
- `shell-qc.sh` CLI surface, subcommands, flags, skip markers, and exit codes unchanged; the only behavioral difference is that bats tests exhibiting the kcov nounset pattern now fail locally.
- `ci.yml` needs no edit: it calls `_poshqc.yml` with a bare `uses:` (`ci.yml:23-24`), so the new job runs on every CI trigger.

#### Performance constraints (latency/throughput/memory):
- The xtrace simulation adds overhead to local `shell-qc.sh test`; CI already pays this cost under kcov. No numeric budget is set; the overhead is recorded (wall time before and after) in the execution evidence but is not gated.
- The Linux job runs only the hook suites without coverage and is expected to take less time than the Windows job; no numeric budget is gated.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - `ubuntu-latest` provides `pwsh` and Pester 5.6.1 or later without an install step (runner readme; precedent `.github/workflows/verify-published-releases.yml:27,36-39`). `Install-PoshQCTools` accepts the installed Pester version.
  - bats on WSL and in CI uses bash 4.1 or later, so `BASH_XTRACEFD` is supported.
  - The agent can dispatch and read CI runs with `gh workflow run` and `gh run view --log`.
- Constraints (budget, performance, compatibility):
  - Do not write `_quality-checks.yml`, `_drm-copilot-extension-tests.yml`, `ci.yml`, or `pester.runsettings.psd1`.
  - Do not modify `.claude/rules/**` or `.github/instructions/**`.
  - `.github/instructions/github-actions.instructions.md`: workflows must pass actionlint; keep jobs small and focused. `.claude/rules/ci-workflows.md` feature-review rule `modified-workflow-needs-green-run` requires a green run of the modified workflow against the branch head.
  - Line coverage >= 85% for touched languages; no regression on changed lines. Bash (kcov) has no branch gate.
- External dependencies (services, libraries, releases):
  - GitHub-hosted runners and Actions (`actions/checkout@v7`, `actions/upload-artifact@v7`).
  - kcov v43 behavior, as mirrored by `kcov_trace_env.sh`.

## Data / API / Config Impact
- User-facing or API changes: a new CI check `poshqc / PowerShell hook suites (Linux)` appears on pull requests; it is not a required check. `shell-qc.sh test` now fails locally on the kcov nounset pattern.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none. A new CI artifact, `poshqc-linux-hook-test-results`.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag or schema changes. Existing check and artifact names are unchanged.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: add an ubuntu matrix leg to `_poshqc.yml`, at least for the hook suites; add a shellcheck or custom lint rule, or a preflight check, for the kcov `set -u` + `bash -c` pattern; add planner guidance on the runner matrix and on the Git-for-Windows grep backslash quirk.
- [ ] Integration scenario to retest: the hook suites pass on both runners.
- [ ] Manual verification notes: expect some Windows-only test assumptions to surface on the first Linux run.

Resolution of the seeded items: the Linux leg is a separate job rather than a matrix leg (a matrix would run format, analyze, and the full set with coverage on Linux and collide on the artifact name); the kcov pattern is caught by the trace simulation in `shell-qc.sh test` rather than a static lint rule (the source target cannot be resolved statically); planner guidance is added to the `atomic-plan-contract` skill.

- Regression tests to add or update:
  - `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (new), with `It` blocks asserting: the `poshqc` job uses `windows-latest` and `Invoke-PoshQCTest`; the `poshqc-linux-hooks` job uses `ubuntu-latest`; its `Run.Path` names `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` and no other path; `CodeCoverage.Enabled` is `$false`; its artifact name differs from `poshqc-test-results`; it declares `contents: read`.
  - `tests/shell/test_shell_qc_commands.bats` new tests:
    - "test fails when a bats child sources a nounset library inside bash -c" — `SHELL_QC_BATS_BIN` = `bats-nounset-source` stub; asserts `shell-qc.sh test` exits non-zero and output contains `BASH_SOURCE`. This is the expect-fail test: before the `run_test` change it exits 0.
    - "test passes when a bats child resets nounset after sourcing" — `SHELL_QC_BATS_BIN` = `bats-nounset-source-reset` stub; asserts exit 0.
    - "kcov_trace_env.sh sets the kcov PS4 format" — sources `scripts/bash/kcov_trace_env.sh` in a child bash with xtrace sent to `/dev/null` and asserts `PS4` begins with `kcov@`.
  - Existing tests in `test_shell_qc_commands.bats` (skip markers, max-exit) continue to pass.
- Unit tests (pytest) for the fixed behavior and boundaries:
  - `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (existing) verifies byte identity of the two `atomic-plan-contract/SKILL.md` copies. No new pytest file.
  - Modified Codex hook Pester suites keep their Windows cases passing; OS-guarded counterparts cover non-Windows behavior.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Missing bats: skip marker unchanged, exit 0 (existing test).
  - No test directory: skip marker unchanged, exit 0 (existing test).
  - Sourced library that enables nounset without reset: fails (new test). Same library with `set +u` after sourcing: passes (new test).
  - Trace output must not appear in bats output: the negative-fixture assertion checks for `BASH_SOURCE`, and the passing-fixture test asserts no `kcov@` lines in output.
  - `env -i` children and `sh` (dash) children ignore `BASH_ENV`, as under kcov; not tested, documented only.
- Error handling and logging verification: the nounset regression test asserts the `BASH_SOURCE` error text is surfaced and the exit code is non-zero.
- Coverage impact and targets for changed lines/modules:
  - PowerShell: no production `.ps1`/`.psm1` changes; the Windows job's PoshQC coverage must remain >= 85% line coverage.
  - Bash: `scripts/bash/shell_qc_lib.sh` changed lines and `scripts/bash/kcov_trace_env.sh` covered by kcov via `_shell-coverage.yml` (`shell-qc.sh test --coverage`); overall bash line coverage >= 85%, no regression on changed lines.
- Toolchain commands to run (format → lint → type-check → test):
  - PowerShell: PoshQC format, PSScriptAnalyzer (PoshQC analyze), Pester with coverage (`Invoke-PoshQCTest` or `mcp__drm-copilot__run_poshqc_test`). Type-check is not applicable.
  - Bash: `bash scripts/bash/shell-qc.sh format`, `bash scripts/bash/shell-qc.sh check` (shfmt and shellcheck), `bash scripts/bash/shell-qc.sh test` (bats, now under the simulation), and `test --coverage` in CI.
  - Workflow: `scripts/dev-tools/run-actionlint.ps1` on `.github/workflows/_poshqc.yml`.
  - Python: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
- Manual validation steps (if required):
  - Dispatch `gh workflow run _poshqc.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743` (or use the PR's `ci.yml` run), read both job logs with `gh run view --log`, fix every Linux-only failure reported, and repeat until both jobs are green on the branch head. Record each run ID and the failure list in `<FEATURE>/evidence/qa-gates/`.


## Acceptance Criteria
- [ ] AC-1: `.github/workflows/_poshqc.yml` contains a job `poshqc-linux-hooks` named `PowerShell hook suites (Linux)` with `runs-on: ubuntu-latest` and `permissions: contents: read`. Verified by `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`.
- [ ] AC-2: The `poshqc-linux-hooks` job runs `Invoke-Pester` with `Run.Path` naming `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` and no other path, `Run.Exit = $true`, and `CodeCoverage.Enabled = $false`. Verified by `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`.
- [ ] AC-3: The `poshqc-linux-hooks` job uploads its JUnit result under an artifact name other than `poshqc-test-results` (`poshqc-linux-hook-test-results`). Verified by `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`.
- [ ] AC-4: The existing `poshqc` job is unchanged: `git diff origin/main -- .github/workflows/_poshqc.yml` shows only added lines outside the `poshqc` job, and `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` asserts that `poshqc` still uses `windows-latest` and `Invoke-PoshQCTest`.
- [ ] AC-5: `scripts/dev-tools/run-actionlint.ps1` reports no findings for `.github/workflows/_poshqc.yml`.
- [ ] AC-6: The CI check `poshqc / PowerShell hook suites (Linux)` completes with conclusion `success` on the feature branch head, with no failed Pester tests; the run ID is recorded in `<FEATURE>/evidence/qa-gates/`. Verified by `gh run view <run-id>`.
- [ ] AC-7: The CI check `poshqc / PowerShell QC` completes with conclusion `success` on the same branch head, showing the modified Codex hook tests still pass on Windows. Verified by `gh run view <run-id>`.
- [ ] AC-8: `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1` asserts `windows.sandbox="elevated"` only when `$IsWindows` is true and asserts its absence otherwise (S1). Verified by the Windows and Linux CI runs in AC-6 and AC-7.
- [ ] AC-9: `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` no longer depends on a drive-letter root being absolute on non-Windows hosts (S2 to S4), and its premise comment at the former `:45` states the OS-specific behavior accurately. Verified by the CI runs in AC-6 and AC-7.
- [ ] AC-10: Every Linux-only failure reported by the first CI run of `poshqc / PowerShell hook suites (Linux)` on this feature's PR is listed, with its fix, in `<FEATURE>/evidence/qa-gates/`, and each is fixed in the test file concerned without adding an unconditional skip. Verified by the evidence file and AC-6.
- [ ] AC-11: `scripts/bash/kcov_trace_env.sh` exists, sets `PS4='kcov@${BASH_SOURCE}@${LINENO}@'` and `set -x`, and passes `bash scripts/bash/shell-qc.sh check`. Verified by the bats test "kcov_trace_env.sh sets the kcov PS4 format" and the check command.
- [ ] AC-12: `run_test` in `scripts/bash/shell_qc_lib.sh` invokes bats with `BASH_ENV` set to `scripts/bash/kcov_trace_env.sh` and `BASH_XTRACEFD` set to a descriptor opened on `/dev/null`; `run_test_coverage` is unchanged. Verified by code review of the diff and by AC-13 and AC-14.
- [ ] AC-13: The bats test "test fails when a bats child sources a nounset library inside bash -c" in `tests/shell/test_shell_qc_commands.bats` passes: `shell-qc.sh test` with the `tests/fixtures/shell_qc/stub-bin/bats-nounset-source` stub exits non-zero and its output contains `BASH_SOURCE`. The same test fails (expect-fail) against the pre-change `run_test`.
- [ ] AC-14: The bats test "test passes when a bats child resets nounset after sourcing" in `tests/shell/test_shell_qc_commands.bats` passes: `shell-qc.sh test` with the `tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset` stub exits 0 and its output contains no `kcov@` trace lines.
- [ ] AC-15: The existing skip-marker and exit-code tests in `tests/shell/test_shell_qc_commands.bats` still pass, and the full `bash scripts/bash/shell-qc.sh test` run (WSL or CI) passes with the simulation active, showing no existing bats test regresses.
- [ ] AC-16: `.github/workflows/_shell-coverage.yml` is unchanged (`git diff origin/main -- .github/workflows/_shell-coverage.yml` is empty), and its CI run on the branch head succeeds with bash line coverage >= 85% and changed lines in `scripts/bash/shell_qc_lib.sh` and `scripts/bash/kcov_trace_env.sh` covered.
- [ ] AC-17: The "Wrap-Tolerant Assertion Authoring (Mandatory)" section of `.claude/skills/atomic-plan-contract/SKILL.md` contains a bullet stating that Pester acceptance criteria may cite `ubuntu-latest` only for suites under `tests/scripts/claude-hooks` or `tests/scripts/codex-hooks`, never for coverage, and must name the job (`poshqc / PowerShell QC` or `poshqc / PowerShell hook suites (Linux)`).
- [ ] AC-18: The same section contains a bullet stating that plan checks must not assert a `grep -F` literal containing a backslash, because Git for Windows grep 3.0 reads a doubled backslash in a fixed-string pattern as one backslash, and naming the alternatives (backslash-free substring, named test, or hash/byte-identity check).
- [ ] AC-19: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` is byte-identical to `.claude/skills/atomic-plan-contract/SKILL.md`. Verified by `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
- [ ] AC-20: No file owned by concurrent items or read-only policy is modified: `git diff --name-only origin/main` lists none of `.github/workflows/_quality-checks.yml`, `.github/workflows/_drm-copilot-extension-tests.yml`, `.github/workflows/ci.yml`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, or any path under `.claude/rules/` or `.github/instructions/`.
- [ ] AC-21: The full toolchain passes in a single pass for touched languages: PoshQC format and analyze clean, Pester (Windows) green with PowerShell line coverage >= 85%, `shell-qc.sh format`/`check`/`test` clean, actionlint clean, and the pytest parity test green. Evidence is recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] AC-22: No new or modified file exceeds 500 lines, and no test creates temporary files. Verified by a line count of each changed file and code review of the new tests.

## Risks & Mitigations
- Technical or operational risks:
  - The first Linux run may surface failures beyond S1 to S5 (for example case-sensitive path lookups or Pester 5.9.0 behavior differences).
  - The trace simulation may expose a latent nounset/`bash -c` pattern in an existing bats test that currently passes under kcov only because of ordering; this would appear as a local failure.
  - The trace simulation adds unmeasured xtrace overhead to local `shell-qc.sh test`.
  - Where bats is missing locally, `run_test` skips and the gap remains open until CI (pre-existing limitation).
  - The new Linux check is not required, so a red Linux job does not block merge by itself.
  - A concurrent item may edit `.claude/skills/atomic-plan-contract/SKILL.md`, causing merge contention (not verified).
- Mitigations and rollbacks:
  - The plan budgets a CI-log-driven discover-and-fix loop; AC-6 and AC-10 require the Linux job to be green and every reported failure to be fixed before merge.
  - Any existing bats test exposed by the simulation is a real kcov-class defect and is fixed within this feature (AC-15).
  - Wall time before and after is recorded in evidence.
  - Rebase on `main` before opening the PR and resolve any skill-file conflict while keeping both copies byte-identical (AC-19).
  - Rollback is a revert of the new job and the `run_test` change.

## Rollout & Follow-up
- Release/rollout steps:
  - Merge after AC-1 to AC-22 are met, including green runs of both `_poshqc.yml` jobs and `_shell-coverage.yml` on the branch head.
- Post-fix monitoring or clean-up tasks:
  - Follow-up (orchestrator decision 1): extend Linux Pester coverage to `tests/scripts/claude-lib/**`, starting with the drive-letter assumptions in `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1` and `WorktreeTargetResolution.Tests.ps1`.
  - Follow-up (orchestrator decision 2): after `poshqc / PowerShell hook suites (Linux)` has been green on `main`, add it to required status checks per `.github/workflows/README.md:48-60` (admin-scoped `gh api` PATCH).
  - Optional: add one sentence to `.github/workflows/README.md` noting the Linux hook-suite job (not required by this spec).
- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/743
  - Research: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/research/research.2026-09-30T07-20.md`
  - Related: #706 (FU-706-3, FU-706-4), #707 (AC-16, D18); concurrent owners #734, #647, #658, #527.
