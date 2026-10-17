# Research: CI gaps — Linux Pester leg, kcov `set -u` pattern, Git for Windows grep quirk (Issue #743)

- Timestamp: 2026-09-30T07-20
- Issue: #743 (work mode `full-bug`)
- Branch: `bug/ci-gaps-linux-pester-and-kcov-set-u-743`
- Sources read: `issue.md`, `spec.md`, `plan.2026-09-30T03-15.md` (template only, no content), the workflow, PoshQC, shell-qc, bats, hook-suite, and policy files cited below. External sources: kcov v43 `src/engines/bash-helper.sh` and `src/engines/bash-engine.cc`, and the GitHub runner-images Ubuntu 24.04 readme.
- Tool limitation: this research pass had read, search, and fetch tools only. No command was executed. Every claim about runtime behavior is marked as verified from source text, verified from a recorded run, or inferred.

## Summary

1. **Gap 1 (no Linux Pester run).** `_poshqc.yml` defines one job, on `windows-latest`. It runs the full Pester set with coverage through `Invoke-PoshQCTest`. `ci.yml` calls the reusable workflow with a bare `uses:`, so a job added to `_poshqc.yml` runs on every CI trigger without editing `ci.yml`. The recommended fix is a separate `ubuntu-latest` job in `_poshqc.yml`. It runs Pester directly on `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` with coverage disabled, so the PoshQC coverage file set and `pester.runsettings.psd1` stay unchanged. pwsh 7.6.6 and Pester 5.9.0 come preinstalled on the image. Static review found definite and probable Linux failures, concentrated in the Codex epic-child and worktree-removal suites. The same bug must fix them in the tests.
2. **Gap 2 (kcov `set -u` pattern).** The root cause is in kcov, not in the helper. kcov traces every child bash through `BASH_ENV` with `PS4='kcov@${BASH_SOURCE}@${LINENO}@'`. `BASH_SOURCE` is unset at the top level of `bash -c`, so once a sourced file enables `nounset`, the next traced top-level command aborts. Option (a), `${BASH_SOURCE[0]:-$0}` in helpers, does not reach the expansion that fails. The recommended fix makes `shell-qc.sh test` (non-coverage mode, the mode `fix_all` runs) run bats under a checked-in kcov trace simulation: `BASH_ENV` points to a file that sets kcov's `PS4` and `set -x`, and `BASH_XTRACEFD` is sent to `/dev/null`. The #706 evidence already used this method to reproduce the failure locally. No workflow file changes.
3. **Gap 3 (grep backslash quirk) and runner guidance.** The `.claude/rules/` files are read-only policy. The allowed location is the "Wrap-Tolerant Assertion Authoring (Mandatory)" section of `.claude/skills/atomic-plan-contract/SKILL.md`. That section is where `.claude/rules/plan-acceptance-gates.md` routes authoring guidance its rules do not cover. A byte-identical mirror is required at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`.
4. **Coordination.** The recommended design writes none of `_quality-checks.yml` (#734), `_drm-copilot-extension-tests.yml` (#647), `ci.yml` (#658), or `pester.runsettings.psd1` (#527).
5. **Automation.** No step needs a human.

## Findings — Gap 1: Linux Pester leg

### 1.1 `_poshqc.yml` structure (verified by reading)

- `.github/workflows/_poshqc.yml:3-5`: triggers are `workflow_call` and `workflow_dispatch`, with no inputs.
- `.github/workflows/_poshqc.yml:8-10`: a single job, `poshqc`, named `PowerShell QC`, with `runs-on: windows-latest`. There is no `strategy:` or `permissions:` block.
- Steps:
  - `:13-14`: `actions/checkout@v7`.
  - `:16-20`: import `scripts/powershell/PoshQC/PoshQC.psm1`, then `Install-PoshQCTools`.
  - `:22-30`: `Invoke-PoshQCFormat` plus a `git status --porcelain` drift check.
  - `:32-36`: `Invoke-PoshQCAnalyze`.
  - `:38-42`: `Invoke-PoshQCTest -Root "${{ github.workspace }}"`.
  - `:44-52`: `actions/upload-artifact@v7`, artifact name `poshqc-test-results`, uploading `artifacts/pester/pester-junit.xml`, `powershell-coverage.xml`, and `powershell-coverage.koverage.xml`.
- Actions are pinned by major tag (`@v7`), not by commit SHA. The same holds for `_shell-coverage.yml:14,28,58` and `verify-published-releases.yml:30,52`.

### 1.2 Caller (verified)

- `.github/workflows/ci.yml:23-24`: `poshqc: uses: ./.github/workflows/_poshqc.yml`, with no `with:`, `secrets:`, or `permissions:`. A new job in `_poshqc.yml` therefore runs under `ci.yml` without any edit to `ci.yml`, and its check name is `poshqc / <job name>`.
- The existing check name `poshqc / PowerShell QC` stays unchanged, so the required-status-check rename procedure in `.github/workflows/README.md:24-65` is not triggered.

### 1.3 How Pester is invoked (verified)

- `scripts/powershell/PoshQC/PoshQC.psm1:3`: the default settings file is `settings/pester.runsettings.psd1`.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:3`: `Run.Path = @('scripts', 'tests/powershell', 'tests/scripts')`, with `Run.Exit = $true` at `:4`. Coverage is enabled at `:17-23` and is an explicit per-file allow-list running from `:23` to `:337`.
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1:151-463` (`Invoke-PoshQCTest`):
  - An explicit `-ScanFolders` replaces `Run.Path` (`:308-318`).
  - `-SettingsPath` must name an existing file (`:296-298`).
  - Coverage paths absent under the root are pruned (`:347-366`).
  - Pester runs through a global-session trampoline (`:261-281`, issue #392).
- `Install-PoshQCTool` (`PoshQC.psm1:17-80`) accepts an installed Pester at version 5.6.1 or later (`:55-65`).

### 1.4 Hook suites and how to scope a Linux leg

- Claude hook suites live in `tests/scripts/claude-hooks/*.Tests.ps1`: 92 files (search for `Describe`, count mode).
- Codex hook suites live in `tests/scripts/codex-hooks/*.Tests.ps1`: 43 files (glob enumeration).
- These counts are informational and are not proposed as acceptance-criterion values. See "Numeric Derivation Evidence".
- Hook library suites live in `tests/scripts/claude-lib/**`. They are outside the issue's "hook suites" wording. `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1` and `WorktreeTargetResolution.Tests.ps1` each contain 66 drive-letter literals (count mode), so including them would raise the first-run failure surface considerably. See Open questions.
- Scoping options that leave the PoshQC coverage file set unchanged:
  - (i) An inline `New-PesterConfiguration` in the workflow step: `Run.Path` limited to the two hook folders, `CodeCoverage.Enabled = $false`, and a distinct JUnit path. No new repository file.
  - (ii) `Invoke-PoshQCTest -ScanFolders ... -SettingsPath <new psd1>`. This needs a new settings file. Placed under `scripts/powershell/PoshQC/settings/`, it would sit beside the #527 file and drift from the bundled PoshQC mirror. `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:9-18` lists parity paths explicitly, so the parity test would not fail, but the bundle would be incomplete.
  - (iii) `Invoke-PoshQCTest -ScanFolders` with the default settings. Coverage would then run on Linux against the full allow-list, adding time and a second coverage artifact, which conflicts with "without changing the coverage set" in spirit.
  - Option (i) is recommended. Running Invoke-Pester directly in the step's global scope matches the "passing direct run" that the #392 trampoline comment describes (`PoshQC.Testing.psm1:263-270`).

### 1.5 Runner availability (verified)

- The GitHub runner-images Ubuntu 24.04 readme (fetched 2026-09-30) lists PowerShell 7.6.6, Pester 5.9.0, PSScriptAnalyzer 1.25.0, and bash 5.2.21.
- Repository precedent: `.github/workflows/verify-published-releases.yml:27,36-39` uses `shell: pwsh` on `ubuntu-latest` with no install step.
- The Linux leg would run Pester 5.9.0, because `Install-PoshQCTool` accepts any version from 5.6.1 up. The Windows image version was not checked.

### 1.6 Windows-only assumptions in the hook suites (static; estimated failure surface)

Searches run over `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`:
- Drive-letter literals: 74 lines in 23 claude-hooks files and 94 lines in 15 codex-hooks files. The drive-letter pattern also matches URL `https://` text; those matches are noise.
- No matches in either folder for `$IsWindows`, `$IsLinux`, `powershell.exe`, `cmd.exe`, registry drives, CIM/WMI, or `$env:TEMP`/`USERPROFILE`/`APPDATA`/`LOCALAPPDATA`. The exception is `check-powershell-test-purity.Tests.ps1:97-98`, where the matches are test-data strings.
- No `Join-Path` with backslash literals in the hook folders. Those occur only in `tests/scripts/dev-tools/` (for example `activate.Tests.ps1:28` and `run-actionlint.Tests.ps1:8`), which is one reason the full suite should not run on Linux.
- Production code with branches on `$IsWindows` sits only on the Codex epic-child surface (`.codex/scripts/*`, `.codex/hooks/codex-authority-store.ps1:33,93`, `codex-epic-child-launch-attestation.ps1:80`).

Concrete suspects:

| # | Test location | Mechanism | Assessment |
|---|---|---|---|
| S1 | `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1:335-347`, assertion at `:346` for `windows.sandbox="elevated"` | `.codex/scripts/epic-child-sandbox-preflight.ps1:33` adds that argument only when `$IsWindows` is true. | Definite failure on Linux, established by reading the code. |
| S2 | `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1:133-141` | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1:75-80` uses `[IO.Path]::IsPathRooted` and `GetFullPath`. On Unix, `C:/repo` is not rooted, so `GetFullPath` prefixes the current directory and the expected `C:/repo/...` string is not produced. | Definite failure; inferred from .NET path semantics on Unix. |
| S3 | Same file, `:164-173` (feature match) and `:206-214` (allow when `worktree_removed`) | The same normalization joins `C:/repo` with a `C:/...` target that is not rooted on Unix, so the normalized target and checkpoint paths do not match. | Probable failure. |
| S4 | Same file, `:45` and `:196-204` | Assumes `C:/nonexistent-.../worktree-9f2a1c` is absolute ("the deny holds wherever the suite runs"). The deny outcome probably still holds, but the stated premise is false on Linux. | Probable pass; the comment needs correction. |
| S5 | `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1:207-266,427-436` and `epic-child-worktree-launcher.Tests.ps1:191-197,288-304,377,413` | `C:\...` paths are fed to functions that call `GetFullPath` or compare paths (`.codex/scripts/epic-child-launch-runtime.ps1:278-307,423-427`; `epic-child-launch-contract.ps1:30,333`). On Unix a backslash is a filename character. | Possible failures; the exact assertions were not traced. |
| S6 | `tests/scripts/claude-hooks/*` with drive-letter literals, for example `enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1:32-34` and `CleanupWorktreeManifestGateMatrix.Tests.ps1:179` | These suites feed synthetic strings to string-level predicates. The absolute-paths suite states at `:26-31` that its prefixes are OS-independent. | Probable pass. |

- Case sensitivity: no test that depends on case-insensitive path lookup was found statically. This risk class stays unverified.
- Precedent for Windows-only assertions: `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1:221,233,249,260` uses `-Skip:(-not $IsWindows)` and `-Skip:$IsWindows`.
- Estimate: the first Linux run likely fails in a small number of Codex suites (S1 to S3 definite or probable, S5 possible) and passes the claude-hooks folder. This is an estimate from static reading. The first CI run is the authoritative enumeration.
- Reference point: the Windows full-set run for #707 recorded 5416 passed, 0 failed, and 9 skipped (`docs/features/completed/codex-gates-4-5-lack-epic-scope-707/spec.md:151`).

### 1.7 Workflow tests and policy constraints (verified)

- No existing test reads `_poshqc.yml` or `_shell-coverage.yml`, per a repository-wide search excluding fixtures.
- Precedent for workflow-invariant suites: `tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1` and `PublishMcpNpmWorkflow.Tests.ps1`. They read the YAML as text without a YAML parser and live under `tests/scripts/workflows/` so the Windows Pester run discovers them (`VerifyPublishedReleasesWorkflow.Tests.ps1:5-12`).
- `.github/instructions/github-actions.instructions.md` (read-only):
  - `:7-9`: do not change job structure unless explicitly requested. The issue requests the new leg.
  - `:12-15`: workflows must pass `actionlint`; locally, `scripts/dev-tools/run-actionlint.ps1`. Note that `ci.yml` currently has no `actionlint` job, despite `:15`.
  - `:21-23`: keep jobs small and focused.
  - There is no pinned-SHA or mandatory-`permissions:` rule.
- `.claude/rules/ci-workflows.md:11-27`: `pwsh` steps that deliberately run a failing command must reset `$LASTEXITCODE`. This does not apply here, because Pester failure must fail the job. `:37` points to the feature-review rule `modified-workflow-needs-green-run`, which requires a green run of the modified workflow against the branch head.

## Findings — Gap 2: kcov `set -u` + `bash -c` + `source`

### 2.1 Invocation (verified)

- `.github/workflows/_shell-coverage.yml`:
  - `:10`: runs on `ubuntu-latest`.
  - `:16-24`: installs shellcheck and bats from apt, plus shfmt 3.8.0.
  - `:26-49`: builds kcov v43.
  - `:51-52`: `bash scripts/bash/shell-qc.sh check`.
  - `:54-55`: `bash scripts/bash/shell-qc.sh test --coverage`.
- `scripts/bash/shell_qc_lib.sh`:
  - `run_check` (`:164-202`) runs shfmt and shellcheck, so shellcheck is already wired into CI.
  - `run_test` (`:226-254`) runs plain bats per directory.
  - `run_test_coverage` (`:294-379`) runs `kcov ... bats <dir>`.
- `scripts/dev_tools/fix_all_branches.py:216-225`: the local toolchain runs `bash scripts/bash/shell-qc.sh test` in non-coverage mode.

### 2.2 Root cause (verified from kcov source and a recorded run)

- kcov v43 `src/engines/bash-helper.sh` contains exactly `PS4='kcov@${BASH_SOURCE}@${LINENO}@'` and `set -x`.
- kcov v43 `src/engines/bash-engine.cc` exports `BASH_ENV=<helper>` and `BASH_XTRACEFD=<fd>` for the PS4 method. It falls back to a DEBUG-trap helper based on the bash version, and bash 5.2 on the runner uses the PS4 method.
- Every non-interactive child bash, including `bash -c` inside a bats test, sources that helper. At the top level of `bash -c`, `BASH_SOURCE` is empty. After a sourced file runs `set -u` (for example `set -euo pipefail`), the next traced top-level command expands `${BASH_SOURCE}` in PS4 and aborts with `BASH_SOURCE: unbound variable`.
- The recorded run is `docs/features/completed/cleanup-report-registration-lost-false-positive-706/evidence/qa-gates/ci-shell-coverage.2026-09-27T10-38.md:27-42`: run 36325350057 failed tests 427, 429, and 430. The same file records a local reproduction using `PS4='kcov@${BASH_SOURCE}@${LINENO}@'` and `set -x` via `BASH_ENV`: the `bash -c` plus `source` form exited 1, and the script form exited 0.

### 2.3 Existing instances

- The only current instance is `tests/shell/test_cleanup_worktrees_scan_helper.bats:47-52,73-80,89-98`. It is already worked around with `load_helper() { source "$1"; set +u; }`. The sourced helper runs `set -euo pipefail` at `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh:42`.
- Other `bash -c` bodies that `source` a file: about 80 sites in 20 files, including `test_cleanup_worktrees_enumeration.bats`, `test_cleanup_worktrees_deletion.bats`, `test_shell_qc_discovery.bats:13-47`, and `test_shell_qc_commands.bats:137,143`. They pass under kcov because the sourced libraries do not enable nounset at top level.
- Files that enable nounset at top level (search `^set -[a-z]*u`) include the five `.claude/lib/bash/*.sh` entry scripts, `cleanup-worktrees.sh`, `cleanup_worktrees_scan_helper.sh`, `scripts/bash/shell-qc.sh`, `coverage_lib.sh`, and `coverage_demo.sh`. bats tests source several of these directly in `setup()` (for example `tests/shell/report_lane_assertion_dispatch.bats:37` and `test_coverage_demo.bats:22`). That is safe, because bats functions have a set `BASH_SOURCE`.

### 2.4 Fix options

- **(a) Harden the helpers with `${BASH_SOURCE[0]:-$0}`.** This does not fix the defect. The failing expansion is in kcov's PS4, not in helper code. The variant that would work, enabling strict mode only when a file is executed rather than sourced, conflicts with `.claude/rules/shell.md:82` ("Begin executable scripts with `set -euo pipefail`") and would touch production scripts and their bundle mirrors. Rejected.
- **(b) Static lint of `.bats` files.** A precise rule must know whether the sourced file enables nounset. The target is usually a variable (`${LIB}`, `"$1"`) set in `setup()` or passed as an argument, so it cannot be resolved statically without a small interpreter. A conservative rule ("`bash -c` + `source` without `set +u`") would flag about 80 correct sites. The false-positive rate is unacceptable. Rejected.
- **(c) Plan-preflight guidance only.** It depends on reviewer recall, which is the mechanism that already failed in #706. It is suitable only as a supplement.
- **(d) Recommended: kcov trace simulation in `shell-qc.sh test`.** `run_test` runs bats with `BASH_ENV` pointing to a checked-in file that sets `PS4='kcov@${BASH_SOURCE}@${LINENO}@'` and `set -x`, and with `BASH_XTRACEFD` pointing at a descriptor opened on `/dev/null`. This mirrors kcov's own mechanism, verified in 2.2.
  - It catches the whole class, whatever file or variable form is involved.
  - It cannot flag a test that passes under real kcov, because it is a subset of kcov's behavior.
  - It runs wherever bats runs locally, including `fix_all`.
  - It needs no workflow edit.
  - Custom check-script precedent in the same library: `run_check` already composes tool invocations, and the `SHELL_QC_<TOOL>_BIN` seam (`shell_qc_lib.sh:122-148`) gives the test seam.

## Findings — Gap 3: planner guidance location and mirrors

- Evidence for the quirk: `docs/features/completed/cleanup-report-registration-lost-false-positive-706/evidence/regression-testing/predicate-restored.2026-09-27T10-29.md:13-31`. Under local GNU grep 3.0 (Git for Windows), `grep -c -F '...[/\\]...'` returned 0 against a file containing `[/\\]`. `printf 'a[/\]b' | grep -c -F '[/\\]'` returned 1. Doubling each backslash matched. The quirk was not re-run in this pass.
- Candidate locations:
  - `.claude/rules/plan-acceptance-gates.md` and `.claude/rules/*`: read-only policy. That file also routes authoring-only guidance to the skill (`:189`, `:203`, `:250`).
  - `.claude/skills/atomic-plan-contract/SKILL.md:196-214` "Wrap-Tolerant Assertion Authoring (Mandatory)": the allowed and intended location. It already holds search-literal guidance (`:203-207`).
- Mirrors:
  - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` must be byte-identical. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:37-41,146-156` asserts byte identity for this file, and the module docstring at `:5-6` describes a whole-tree `.claude/**` byte-identical mirror check.
  - `.github/skills/atomic-plan-contract/SKILL.md` and `.agents/skills/atomic-plan-contract/SKILL.md`, plus their bundle copies, do not contain the Wrap-Tolerant section (section headings compared). The section is currently Claude-only, so no mirror edit is required there.
- A validator rule (a "G10") was considered and rejected. `.claude/rules/plan-acceptance-gates.md:44` declares G1 through G9 the complete shipped set, and that file cannot be edited to document a new rule. `:25` also requires a false-positive measurement before a new rule.
- `.claude/skills/atomic-plan-contract/SKILL.md` is listed as a read-by-mandate path in the blast-radius normalization tests (`tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1:48`). Whether any concurrently planned item edits it is unknown. See Open questions.

## Recommended fix design

### Files to create or modify

| Path | Change |
|---|---|
| `.github/workflows/_poshqc.yml` | Add a second job, `poshqc-linux-hooks`, named `PowerShell hook suites (Linux)`, on `ubuntu-latest`. Steps: checkout `@v7`; import PoshQC and `Install-PoshQCTools`; one `pwsh` step building `New-PesterConfiguration` with `Run.Path = @('tests/scripts/claude-hooks','tests/scripts/codex-hooks')`, `Run.Exit = $true`, `CodeCoverage.Enabled = $false`, and JUnit output to `artifacts/pester/pester-junit-linux-hooks.xml`, then `Invoke-Pester -Configuration $config`; `upload-artifact@v7` with a distinct name (`poshqc-linux-hook-test-results`). The existing `poshqc` job stays byte-unchanged. A separate job is chosen over a matrix, because a matrix would run format, analyze, and the full set with coverage on Linux and would collide on the artifact name. |
| `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (new) | Text-based invariant suite following `VerifyPublishedReleasesWorkflow.Tests.ps1`. It asserts: the `poshqc` job still uses `windows-latest` and `Invoke-PoshQCTest`; the new job uses `ubuntu-latest`; its `Run.Path` names exactly the two hook folders; coverage is disabled; its artifact name differs from `poshqc-test-results`. |
| `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1` | S1: split the `windows.sandbox="elevated"` assertion into a Windows-only case and a non-Windows case asserting the argument is absent, following the `-Skip:` precedent. Also address S5 cases the first Linux run reports. |
| `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` | S2 to S4: derive the synthetic rooted prefix per OS (`C:/repo` on Windows, `/repo` elsewhere), or skip the drive-letter-specific cases on non-Windows. Correct the `:45` premise comment. |
| `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` | S5, only if the first Linux run reports failures. |
| `scripts/bash/shell_qc_lib.sh` | `run_test`: open a descriptor on `/dev/null` and invoke bats with `BASH_ENV=<trace-sim file>` and `BASH_XTRACEFD=<fd>`. `run_test_coverage` is unchanged, because real kcov is authoritative there. The file is currently 380 lines against the 500-line cap. |
| `scripts/bash/kcov_trace_env.sh` (new) | Two statements, `PS4='kcov@${BASH_SOURCE}@${LINENO}@'` and `set -x`, with a comment citing kcov v43 `bash-helper.sh`. Under `scripts/`, it is discovered by `shell-qc.sh check` and falls within the kcov include pattern (`shell_qc_lib.sh:335`). A bats test that sources it inside a kcov-traced child records its lines. The PS4 format is identical to kcov's, so kcov's trace parsing is unaffected. |
| `tests/shell/test_shell_qc_commands.bats` plus new fixtures under `tests/fixtures/shell_qc/` | Regression tests through the `SHELL_QC_BATS_BIN` seam. A new stub runs `bash -c 'source <fixture nounset lib>; true'` and must make `shell-qc.sh test` exit non-zero with `BASH_SOURCE` in the output. A companion stub using the `load_helper`/`set +u` form must exit 0. A test sourcing `kcov_trace_env.sh` in a child asserts that `PS4` begins with `kcov@`. No temporary files. |
| `.claude/skills/atomic-plan-contract/SKILL.md` | Two bullets in "Wrap-Tolerant Assertion Authoring": (i) runner OS for Pester acceptance criteria, and (ii) the Git for Windows fixed-string backslash quirk. Optionally a third: a `bash -c` body in a bats test must not leave nounset on at top level after sourcing, and `shell-qc.sh test` now detects this. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md` | Byte-identical copy of the above. |
| `.github/workflows/README.md` (optional) | One sentence noting that `_poshqc.yml` now has a Linux hook-suite job. |

Content of the two guidance bullets:
- (i) A Pester acceptance criterion may cite `windows-latest` for any suite and for coverage numbers. It may cite `ubuntu-latest` only for suites under `tests/scripts/claude-hooks` or `tests/scripts/codex-hooks`, and never for coverage, which the Linux job does not collect. Name the job (`poshqc / PowerShell QC` or `poshqc / PowerShell hook suites (Linux)`).
- (ii) Do not assert a `grep -F` literal containing a backslash. Git for Windows grep 3.0 reads `\\` in a fixed-string pattern as one backslash, so the check behaves differently locally and in CI. Assert a backslash-free substring, a named test, or a hash or byte-identity check.

### Files deliberately not written

`ci.yml` (#658), `_quality-checks.yml` (#734), `_drm-copilot-extension-tests.yml` (#647), `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (#527), and `_shell-coverage.yml`. None needs to change. `pester.runsettings.psd1` needs no new coverage entry, because the design adds no production `.ps1` or `.psm1` file.

## Behavior semantics

- Linux job success means Pester exits 0 over the two hook folders (`Run.Exit = $true`). Any failed test fails the job. Skipped tests (`-Skip:` on OS guards) do not fail it.
- The Windows job's behavior, artifacts, and check name stay unchanged.
- `shell-qc.sh test`:
  - The existing skip markers (`shell_qc_lib.sh:236,241`) and the max-exit semantics stay unchanged.
  - When bats is present, every child bash runs with kcov-equivalent tracing sent to `/dev/null`.
  - A test that trips the nounset/PS4 condition fails locally with `BASH_SOURCE: unbound variable`, the same as under CI kcov.
  - `test --coverage` stays unchanged.
- Edge cases for the simulation:
  - `env -i` children drop `BASH_ENV`; kcov does too.
  - `sh` (dash) ignores `BASH_ENV`; kcov does too.
  - Bash older than 4.1 cannot use `BASH_XTRACEFD`. This is not relevant on current hosts.

## Test strategy

- Pester (Windows CI job, and locally via `mcp__drm-copilot__run_poshqc_test` or `Invoke-PoshQCTest`):
  - the new `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`;
  - the modified Codex suites, whose Windows cases must keep passing.
- Linux verification: dispatch `gh workflow run _poshqc.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743`, then read the job log. The first run is the discovery step for S5 and any unlisted failures. Fix and re-dispatch until both jobs are green. This also satisfies `modified-workflow-needs-green-run`.
- bats:
  - the new `test_shell_qc_commands.bats` cases. The expect-fail regression is the nounset stub under the simulation, which fails before the `run_test` change in the sense that `shell-qc.sh test` exits 0.
  - Full `shell-qc.sh test` locally under WSL, which shows that no existing test regresses under the simulation.
  - `_shell-coverage.yml` dispatch for kcov line coverage (85% or more; no regression on changed lines). There is no bash branch gate (`.claude/rules/shell.md:69-71`).
- Workflow lint: `scripts/dev-tools/run-actionlint.ps1` on `_poshqc.yml`.
- Python: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` for skill mirror byte identity.

## Risks

- The first Linux run may surface failures beyond S1 to S5, for example case-sensitive paths or Pester 5.9.0 against the 5.6.1 minimum. Mitigation: the plan budgets a discover-and-fix loop driven by CI logs.
- The trace simulation adds xtrace overhead to local `shell-qc.sh test`. CI already pays that cost under kcov. The overhead was not measured.
- The simulation depends on bats being available locally. Where bats is missing, `run_test` prints its skip marker and the gap stays open until CI. That limitation predates this issue.
- The new Linux check is not a required status check unless branch protection is updated. It fails visibly but does not block merge by itself.
- A concurrent item may edit `atomic-plan-contract/SKILL.md`, creating merge contention. Not verified.

## Open questions

1. Should the Linux job also cover `tests/scripts/claude-lib/**`, the portable libraries the hooks load? This research recommends a follow-up issue instead, given 132 drive-letter literal lines in two worktree-resolution suites alone.
2. Should `poshqc / PowerShell hook suites (Linux)` be added to required status checks? Doing so is a `gh api` PATCH per `.github/workflows/README.md:48-60`. This research recommends deferring it until the job has been green on `main`.
3. Should `run_test` offer an opt-out variable, for example `SHELL_QC_KCOV_TRACE_SIM=0`? It is not required. Omitting it keeps local and CI semantics aligned.
4. Should the new job declare `permissions: contents: read`? Neither the existing job nor its caller declares permissions, and the policy file does not require it.

## Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed for an acceptance criterion in `spec.md`. The counts in this artifact (92 claude-hooks suites, 43 codex-hooks suites, drive-letter line counts, about 80 `bash -c` plus `source` sites) are informational, each from a single search. They must not become acceptance-criterion values without a full primary and cross-check derivation.

## Rejected alternatives

- Matrix leg on the existing `poshqc` job: it runs the full set, with Windows-only dev-tools suites, format, analyze, and coverage, on Linux, and collides on the artifact name.
- A new PoshQC settings `.psd1` for the Linux leg: it sits beside the #527 file and drifts from the bundled PoshQC mirror.
- Helper `${BASH_SOURCE[0]:-$0}` hardening: it does not reach kcov's PS4 expansion.
- A static `.bats` lint: the source target cannot be resolved statically, and the conservative form has about 80 false positives.
- A plan-gate validator rule for backslash `-F` literals: the governing rule file declares G1 through G9 complete and is read-only.

## Automation Feasibility

All steps can be automated.
- Workflow edit, test edits, and bats/library edits: file writes.
- Linux discovery and verification: `gh workflow run` and `gh run view --log`, as used in #706 evidence.
- actionlint: `scripts/dev-tools/run-actionlint.ps1`.
- Mirror parity: pytest.

No step requires a human. The only admin-scoped action, adding the Linux job to required status checks, is excluded from scope (Open question 2).
