# 2026-09-27-ci-gaps-linux-pester-and-kcov-set-u (Plan)

- **Issue:** #743
- **Parent (optional):** none
- **Owner:** drmoisan
- **Branch:** `bug/ci-gaps-linux-pester-and-kcov-set-u-743`
- **Last Updated:** 2026-09-30T09-30
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- Complexity band: C3 (cross-cutting CI change; no floor signal; C3 by judgment)

## Plan Conventions

**Requirements source (sole AC source, full-bug).** `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md`,
section `## Acceptance Criteria`, items AC-1 through AC-22. `user-story.md` is not produced for
full-bug work and its absence is not a blocker. Supporting inputs: `issue.md` and
`research/research.2026-09-30T07-20.md` in the same folder. The orchestrator decisions recorded in
the spec (no `tests/scripts/claude-lib/**` on Linux, no required-check change, no opt-out variable)
are binding.

**Notation.** `<FEATURE>` denotes the literal folder
`docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743`. `<ts>` denotes the
artifact creation time in `yyyy-MM-ddTHH-mm` form. `<MERGE_BASE>` denotes the literal 40-character
SHA recorded by P0-T1; every later command substitutes that literal (never `origin/main` itself, so
a later advance of `main` does not change what a check compares against). `<RUN_ID>` and
`<JOB_ID>` denote GitHub Actions run and job IDs recorded by the task that obtains them.
`<session-scratchpad>` denotes the executor's session scratchpad, which is outside the repository.
`<BATS_DIRECT>` denotes the bats-core script path recorded by P0-T8. No absolute host path is ever
copied into an evidence artifact; a repository-root prefix in recorded output is replaced by the
literal `<REPO_ROOT>`, and a runner workspace prefix by `<RUNNER_ROOT>`.

**Evidence rules.** Every evidence artifact is written under `<FEATURE>/evidence/<kind>/` with kind
`baseline`, `regression-testing`, `qa-gates`, or `other`; nothing is written under `artifacts/`
except the tools' own gitignored output. Every command-step artifact carries `Timestamp:`,
`Command:`, `EXIT_CODE:`, and `Output Summary:`, one artifact per command unless a task states
otherwise. An artifact whose passing outcome is a non-zero exit carries `ExpectedExitCode: <int>`
and holds that one command only. PowerShell test and coverage artifacts record numeric values
(counts and percentages), never placeholders.

**Command route (agent-isolated worktree).** The worktree isolation guard refuses a plain command
that invokes `pwsh` or `bash` as a program, a command whose program or arguments come from a
variable or command substitution, and heredocs (a refused `pwsh` invocation was observed in
preflight round 1 and a refused `bash --version` in round 2; `echo pwsh-word-test` ran, so the
match is on invocation, not on the word). Every
PowerShell command, including P0-T7's, is written verbatim into a `.sh` file in
`<session-scratchpad>` (forward-slash paths) and run as `sh <that file>` (observed working in
preflight); the artifact's `Command:` field records the PowerShell command itself. Shell scripts
run as `sh <script>` (Git Bash `sh` is GNU bash), for example `sh scripts/bash/shell-qc.sh check`; bats runs as `npx --yes bats <named .bats files>`
(bats-core from npm, no repository change). If the guard refuses a command's text, the executor
writes the identical command into a `.sh` file in `<session-scratchpad>` and runs
`sh <that file>`; the artifact's `Command:` field records the command itself. Helper scripts SP1
and SP3 through SP11 below (SP2 is withdrawn) are written verbatim by the Write tool into `<session-scratchpad>` before first
use; they are not repository files.

**PowerShell route.** The PoshQC MCP tools return no command output, so no count or percentage is
read from them. Every PowerShell toolchain step imports the self-hosted module
`scripts/powershell/PoshQC/PoshQC.psd1` directly through SP1 and SP3 through SP7, which read the
in-repository settings.

**Local bats route.** `run_test` resolves `bats` with `command -v`, and bats is not on the Windows
PATH, so a bare `sh scripts/bash/shell-qc.sh test` prints `bats not installed; skipping shell tests.`
and runs nothing. Named suites run through `npx --yes bats`. The full `shell-qc.sh test` run (AC-15)
runs through SP9 with `SHELL_QC_BATS_BIN` set to `<BATS_DIRECT>`, the bats-core script inside the npm
cache, so the bats process is a direct bash child of `run_test` and inherits its trace descriptor.
It is not run through the npx shim, because a Node process in the middle is not expected to pass
descriptors above 2 to its child, so the trace descriptor would likely not reach bats (inferred
from Node child-process behavior, not observed). When P0-T8 cannot record exactly one `<BATS_DIRECT>` path, the
AC-15 evidence comes from the CI job `shell-coverage / Shell Coverage (Bats + kcov)` (P7-T20),
which runs every bats test under real kcov. That is a superset of the simulation: any test the
simulation fails, real kcov also fails.

**CI route.** No local Linux `pwsh` and no local kcov exist. Linux Pester results, kcov coverage,
and the check conclusions for AC-6, AC-7, AC-10, and AC-16 come only from GitHub Actions runs of the
pushed branch head, read with `gh run list`, `gh run view`, `gh run watch`, and `gh run download`.
`ci.yml` triggers on pull requests into `main`, not on pushes to this branch, so every run here is a
`workflow_dispatch`. Discovery runs dispatch `.github/workflows/_poshqc.yml` directly (job names
`PowerShell QC` and `PowerShell hook suites (Linux)`). The final verification run dispatches
`.github/workflows/ci.yml` so the checks carry their `poshqc / ...` and `shell-coverage / ...` names.
Run logs cannot be read until a run completes, so each watch runs in the background.

**Authoritative coverage.** PowerShell: the report-level `LINE` counter of
`artifacts/pester/powershell-coverage.xml` from the local full Windows run (SP4 then SP5). This
design adds no production `.ps1` or `.psm1` file, so the post-change value is expected to equal the
baseline. Bash: the `Bash coverage (lines): NN.N%` headline from the kcov CI job log, plus per-line
`hits` for the added lines of `scripts/bash/shell_qc_lib.sh` and `scripts/bash/kcov_trace_env.sh`
from the run's `shell-coverage` artifact (SP10). Bash coverage is line-only; no branch gate applies.

**Quality tier.** `quality-tiers.yml` is absent from the repository root (verified by P0-T4). The
files in scope are dev tooling, CI scaffolding, and tests, so tier **T4** is assumed. Under T4 no
property-test or mutation obligation applies. The uniform gates apply: format pass, zero lint
findings, line coverage at or above 85%, and no regression on changed lines.

**Merge-order independence.** Edits are located by content anchors, not by line number. New bats
tests are appended after the last existing test in `tests/shell/test_shell_qc_commands.bats`. No task
asserts a total test count for a suite that other items can extend; tests are asserted by name.

**Commit route.** `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` gates `git add`
and `git commit` on the orchestration checkpoint. Every commit uses a pathspec:
`git add -- <paths>` and `git commit -F <message file> -- <paths>`, with the message file written by
the Write tool into `<session-scratchpad>`. If the gate refuses a commit, the task records the
refusal text and the plan stops (BLOCKED, returned to the orchestrator). Pushes never use force.

**Files written by this plan (exhaustive).** Each file is written only by a task whose title
begins with a write verb followed by the file's repository-relative path as its first backticked
token:
`.github/workflows/_poshqc.yml`; `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (new);
`tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1`;
`tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`;
`tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1`;
`scripts/bash/kcov_trace_env.sh` (new); `scripts/bash/shell_qc_lib.sh`;
`tests/shell/test_shell_qc_commands.bats`;
`tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh` (new);
`tests/fixtures/shell_qc/stub-bin/bats-nounset-source` (new);
`tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset` (new);
`.claude/skills/atomic-plan-contract/SKILL.md`;
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`;
`docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md` (AC check-offs only);
this plan (check marks only); and evidence artifacts under `<FEATURE>/evidence/`.
A Linux-only failure reported in any other file is not fixed by this plan. It is recorded as
`REMEDIATION-REQUIRED: <path>` (P5-T7) and triggers a remediation cycle.

**Files this plan must not write (coordination and policy).** `.github/workflows/_quality-checks.yml`
(#734), `.github/workflows/_drm-copilot-extension-tests.yml` (#647), `.github/workflows/ci.yml`
(#658), `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (#527),
`.github/workflows/_shell-coverage.yml`, and every path under `.claude/rules/` or
`.github/instructions/`. P7-T22 verifies this (AC-20).

**Spec reconciliation (verification form and sequencing only; no requirement is dropped).**
1. AC-10 names "the first CI run of `poshqc / PowerShell hook suites (Linux)` on this feature's PR".
   The PR is opened after this plan by the PR-authoring stage. The plan therefore treats the first
   run of that same job against the pushed branch head (P4-T2, a `workflow_dispatch` of
   `_poshqc.yml`, job `PowerShell hook suites (Linux)`) as that run. `ci.yml` calls the same job
   with a bare `uses:`, so the job definition is identical.
2. The spec's implementation strategy fixes S1 to S5 before the first run. This plan runs the first
   Linux job (Phase 4) before the Codex test fixes (Phase 5). That run is the `[expect-fail]`
   evidence for the Linux-only failures and gives the complete AC-10 inventory in one pass.
3. S1 form. The spec design splits the `windows.sandbox="elevated"` assertion into separate
   Windows-only and non-Windows cases. `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1`
   is 469 lines and `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` is 495 lines,
   and the cap is 500. The plan therefore replaces each assertion with the single line of reference
   block R9. That line asserts the argument is present when `$IsWindows` is true and absent
   otherwise, which is the AC-8 condition, with no skip and no added lines. A static re-read also
   found two sites the research did not list. Both are gated by `$IsWindows` in
   `.codex/scripts/launch-epic-child-wave.ps1:153`: `epic-child-launch-hardening.Tests.ps1:245` (S1b)
   and `epic-child-worktree-launcher.Tests.ps1:315` (S1c). They are fixed the same way.
4. The reset stub (AC-14) loads the library through `load_helper() { source "$1"; set +u; }`. A
   bare top-level `set +u` after the source would itself be traced while nounset is still on, and
   would fail. This form is the one `docs/features/completed/cleanup-report-registration-lost-false-positive-706/evidence/qa-gates/ci-shell-coverage.2026-09-27T10-38.md:42`
   records as passing under both the simulation and real kcov.
5. AC-4 and AC-20 name `git diff origin/main`. The plan anchors both to `<MERGE_BASE>` (the
   `origin/main` merge base recorded in P0-T1), so they stay valid if `main` advances. It pairs
   each name-listing diff with `git status --porcelain` so that untracked paths are visible.
6. The Linux job's upload step carries `if: always()` so that the JUnit file is available when the
   Pester step fails. The discovery run (Phase 4) depends on that file. The Pester step also imports
   Pester `5.6.1` or later and creates `artifacts/pester` before the run. The spec's configuration
   keys are unchanged.
7. The spec's `bash scripts/bash/shell-qc.sh <cmd>` commands run locally as
   `sh scripts/bash/shell-qc.sh <cmd>` (the same script under Git Bash GNU bash). CI runs the
   spec's form verbatim, and its results govern (`.claude/rules/shell.md`, CI-vs-Local Version Drift).

## Reference Text

The executor copies these blocks verbatim. Bash production code uses tab indentation (shfmt
default). Bats test code uses the 4-space indentation of the existing bats file. PowerShell uses
4-space indentation.

#### R1 — New file `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`

```powershell
Set-StrictMode -Version Latest

# Workflow-invariant suite for .github/workflows/_poshqc.yml (issue #743).
#
# Location note: the Pester runner discovers tests only under the roots declared in
# scripts/powershell/PoshQC/settings/pester.runsettings.psd1 ('scripts',
# 'tests/powershell', 'tests/scripts'), so this file lives under 'tests/scripts/workflows/'
# beside VerifyPublishedReleasesWorkflow.Tests.ps1.
#
# The workflow is read from disk as text and partitioned into job blocks: a job begins at a
# line of exactly two spaces, an identifier, and a colon under the top-level 'jobs:' key, and
# runs to the line before the next job start. No YAML parser module is imported, and no
# external process, temporary file, or network call is made.

Describe '_poshqc.yml workflow invariants' {
    BeforeAll {
        $workflowPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '../../../.github/workflows/_poshqc.yml')).Path
        $workflowLines = @(Get-Content -LiteralPath $workflowPath)

        $jobLines = @{}
        $inJobs = $false
        $current = $null
        foreach ($line in $workflowLines) {
            if ($line -match '^jobs:[ \t]*$') {
                $inJobs = $true
                continue
            }
            if (-not $inJobs) {
                continue
            }
            if ($line -match '^\S') {
                break
            }
            if ($line -match '^ {2}(?<JobId>[A-Za-z0-9_-]+):[ \t]*$') {
                $current = [System.Collections.Generic.List[string]]::new()
                $jobLines[$Matches['JobId']] = $current
                continue
            }
            if ($null -ne $current) {
                $current.Add($line)
            }
        }

        $script:JobText = @{}
        foreach ($jobId in $jobLines.Keys) {
            $script:JobText[$jobId] = ($jobLines[$jobId] -join "`n")
        }
    }

    It 'declares exactly the poshqc and poshqc-linux-hooks jobs' {
        (@($script:JobText.Keys | Sort-Object) -join ',') | Should -BeExactly 'poshqc,poshqc-linux-hooks'
    }

    It 'keeps the poshqc job on windows-latest running Invoke-PoshQCTest' {
        $job = $script:JobText['poshqc']
        $job | Should -Match '(?m)^ {4}name:[ \t]*PowerShell QC[ \t]*$'
        $job | Should -Match '(?m)^ {4}runs-on:[ \t]*windows-latest[ \t]*$'
        $job | Should -Match 'Invoke-PoshQCTest -Root'
        $job | Should -Match '(?m)^ +name:[ \t]*poshqc-test-results[ \t]*$'
    }

    It 'runs the poshqc-linux-hooks job on ubuntu-latest under its check name' {
        $job = $script:JobText['poshqc-linux-hooks']
        $job | Should -Match '(?m)^ {4}name:[ \t]*PowerShell hook suites \(Linux\)[ \t]*$'
        $job | Should -Match '(?m)^ {4}runs-on:[ \t]*ubuntu-latest[ \t]*$'
    }

    It 'grants the poshqc-linux-hooks job read-only repository contents' {
        $job = $script:JobText['poshqc-linux-hooks']
        $job | Should -Match '(?m)^ {4}permissions:[ \t]*\n {6}contents:[ \t]*read[ \t]*$'
    }

    It 'limits the poshqc-linux-hooks Run.Path to the two hook-suite folders' {
        $job = $script:JobText['poshqc-linux-hooks']
        $pathLines = @($job -split "`n" | Where-Object { $_ -match 'Run\.Path\s*=' })
        $pathLines.Count | Should -Be 1
        $folders = @([regex]::Matches($pathLines[0], "'([^']+)'") | ForEach-Object { $_.Groups[1].Value })
        ($folders -join ',') | Should -BeExactly 'tests/scripts/claude-hooks,tests/scripts/codex-hooks'
    }

    It 'fails the poshqc-linux-hooks job on a failed test and collects no coverage' {
        $job = $script:JobText['poshqc-linux-hooks']
        $job | Should -Match 'Run\.Exit\s*=\s*\$true'
        $job | Should -Match 'CodeCoverage\.Enabled\s*=\s*\$false'
        $job | Should -Match 'Invoke-Pester -Configuration'
        $job | Should -Not -Match 'Invoke-PoshQCTest'
    }

    It 'uploads the poshqc-linux-hooks JUnit result under a distinct artifact name' {
        $job = $script:JobText['poshqc-linux-hooks']
        $job | Should -Match "TestResult\.OutputPath\s*=\s*'artifacts/pester/pester-junit-linux-hooks\.xml'"
        $job | Should -Match '(?m)^ +name:[ \t]*poshqc-linux-hook-test-results[ \t]*$'
        $job | Should -Not -Match '(?m)^ +name:[ \t]*poshqc-test-results[ \t]*$'
    }
}
```

#### R2 — New file `tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh`

```bash
#!/usr/bin/env bash
# Fixture library for the shell-qc kcov-trace regression tests (issue #743). It enables
# strict mode, including nounset, at top level, as the repository's executable scripts do.
# Sourcing it at the top level of bash -c under kcov tracing reproduces the
# BASH_SOURCE unbound-variable failure. It defines nothing else.
set -euo pipefail
```

#### R3 — New file `tests/fixtures/shell_qc/stub-bin/bats-nounset-source`

```bash
#!/usr/bin/env bash
# Stub bats for the shell-qc kcov-trace regression tests (issue #743), wired through the
# SHELL_QC_BATS_BIN seam. It echoes its argv, then runs the pattern that fails only under
# kcov tracing: a bash -c child that sources a library enabling nounset at top level and
# then runs one more command. It exits with that child's status. Writes no files.
stub_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
lib="${stub_dir}/../kcov_trace/nounset_lib.sh"
echo "nounset-stub ran: $*"
rc=0
bash -c 'source "$1"; true' _ "$lib" || rc=$?
exit "$rc"
```

#### R4 — New file `tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset`

```bash
#!/usr/bin/env bash
# Stub bats for the shell-qc kcov-trace regression tests (issue #743), wired through the
# SHELL_QC_BATS_BIN seam. It echoes its argv, then loads the same nounset-enabling library
# through a function that clears nounset before returning (the load_helper form used in
# tests/shell/test_cleanup_worktrees_scan_helper.bats), which passes under kcov tracing.
# It exits with the child's status. Writes no files.
stub_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
lib="${stub_dir}/../kcov_trace/nounset_lib.sh"
echo "nounset-reset-stub ran: $*"
rc=0
bash -c 'load_helper() { source "$1"; set +u; }; load_helper "$1"; true' _ "$lib" || rc=$?
exit "$rc"
```

#### R5 — Three tests appended to `tests/shell/test_shell_qc_commands.bats`

Appended after the last existing test, each preceded by one blank line, in this order:

```bash

@test "test fails when a bats child sources a nounset library inside bash -c" {
    # Issue #743: kcov traces every child bash through BASH_ENV with a PS4 that expands
    # BASH_SOURCE, which is unset at the top level of bash -c. Once a sourced library
    # enables nounset, the next traced command aborts. shell-qc.sh test reproduces that
    # trace environment, so the stub's child fails here as it does under CI kcov.
    run env SHELL_QC_BATS_BIN="${STUB_DIR}/bats-nounset-source" \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' test"
    [ "$status" -ne 0 ]
    [[ "$output" == *"nounset-stub ran: tests/shell"* ]]
    [[ "$output" == *"BASH_SOURCE"* ]]
}

@test "test passes when a bats child resets nounset after sourcing" {
    # Issue #743: the same library loaded through a function that clears nounset before
    # returning passes under the trace environment, and no trace line reaches the output.
    run env SHELL_QC_BATS_BIN="${STUB_DIR}/bats-nounset-source-reset" \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' test"
    [ "$status" -eq 0 ]
    [[ "$output" == *"nounset-reset-stub ran: tests/shell"* ]]
    [[ "$output" != *"kcov@"* ]]
}

@test "kcov_trace_env.sh sets the kcov PS4 format" {
    # Issue #743: the trace environment must use kcov v43's PS4 byte for byte, so the
    # simulation fails only tests that also fail under real kcov. The child's stderr, which
    # carries its own xtrace output, is discarded; PS4 is printed on stdout. The file is
    # also executed once as a script, so kcov records both of its lines in script form.
    run bash "${REPO_ROOT}/scripts/bash/kcov_trace_env.sh"
    [ "$status" -eq 0 ]
    run bash -c 'exec 2>/dev/null; source "$1"; set +x; printf "%s\n" "$PS4"' _ "${REPO_ROOT}/scripts/bash/kcov_trace_env.sh"
    [ "$status" -eq 0 ]
    [ "$output" = 'kcov@${BASH_SOURCE}@${LINENO}@' ]
}
```

#### R6 — New file `scripts/bash/kcov_trace_env.sh`

```bash
#!/usr/bin/env bash
# kcov_trace_env.sh: kcov-equivalent xtrace environment for run_test in
# scripts/bash/shell_qc_lib.sh (issue #743). run_test points BASH_ENV at this file, so every
# non-interactive child bash of a bats run sources it and traces with the PS4 that kcov v43
# installs (src/engines/bash-helper.sh). BASH_SOURCE is unset at the top level of bash -c,
# so a test that sources a nounset-enabling library there fails locally as it fails under
# CI kcov. run_test discards the trace through BASH_XTRACEFD. Defines nothing else.
PS4='kcov@${BASH_SOURCE}@${LINENO}@'
set -x
```

#### R6b — Conditional directive for `scripts/bash/kcov_trace_env.sh`

Inserted immediately above the line `PS4='kcov@${BASH_SOURCE}@${LINENO}@'`, only when P2-T2 records
an SC2016 finding:

```bash
# The single quotes are intentional: PS4 must hold the unexpanded references so bash expands
# them on every traced command, as kcov's helper does.
# shellcheck disable=SC2016
```

#### R7 — Replacement of `run_test` in `scripts/bash/shell_qc_lib.sh`

Replaces the lines from `run_test() {` through the closing `}` that precedes the blank line above
`extract_cobertura_line_rate() {`. No other function changes; `run_test_coverage` is untouched.

```bash
run_test() {
	# Run bats against tests/shell and tests/bash without coverage, under a kcov-equivalent
	# trace environment.
	#
	# No test directory prints the exact skip marker consumed by fix_all.py and
	# returns 0. A missing bats prints the exact non-coverage skip marker and returns
	# 0. Otherwise bats runs once per directory; all directories run even if one
	# fails, and the maximum exit code is returned.
	#
	# Every bats run inherits BASH_ENV set to kcov_trace_env.sh (resolved from this
	# library's own directory) and BASH_XTRACEFD set to a descriptor opened on /dev/null,
	# so each non-interactive child bash traces with kcov v43's PS4 and the trace is
	# discarded. A test that sources a nounset-enabling library at the top level of
	# bash -c therefore fails here with "BASH_SOURCE: unbound variable", as it does under
	# kcov in CI (issue #743). run_test_coverage does not use this environment, because
	# real kcov installs its own.
	local -a test_dirs=()
	mapfile -t test_dirs < <(find_bats_test_dirs)
	if ((${#test_dirs[@]} == 0)); then
		printf 'No shell test directories found; skipping.\n'
		return 0
	fi
	local bats_bin
	if ! bats_bin=$(resolve_tool bats); then
		printf 'bats not installed; skipping shell tests.\n'
		return 0
	fi
	local lib_dir trace_env trace_fd
	lib_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
	trace_env="$lib_dir/kcov_trace_env.sh"
	# bash writes xtrace lines to BASH_XTRACEFD; this descriptor discards them.
	exec {trace_fd}>/dev/null
	local exit_code=0 rc=0 test_dir
	# Run every directory even on failure so all suites report, matching prior behavior.
	for test_dir in "${test_dirs[@]}"; do
		rc=0
		BASH_ENV="$trace_env" BASH_XTRACEFD="$trace_fd" "$bats_bin" "$test_dir" || rc=$?
		if ((rc > exit_code)); then
			exit_code=$rc
		fi
	done
	exec {trace_fd}>&-
	return "$exit_code"
}
```

#### R7b — Conditional fixed-descriptor form for `scripts/bash/shell_qc_lib.sh`

Applied only by P2-T7. It removes the lines `	exec {trace_fd}>/dev/null` and
`	exec {trace_fd}>&-` and the comment line directly above the first of them. It changes
`local lib_dir trace_env trace_fd` to `local lib_dir trace_env`, and it replaces the bats
invocation line with this line, which opens descriptor 19 on `/dev/null` for the bats process
only:

```bash
		BASH_ENV="$trace_env" BASH_XTRACEFD=19 "$bats_bin" "$test_dir" 19>/dev/null || rc=$?
```

#### R8 — Job appended to `.github/workflows/_poshqc.yml`

Appended after the current last line (`          if-no-files-found: ignore`), preceded by one blank
line. The `poshqc` job above it is not modified.

```yaml

  poshqc-linux-hooks:
    name: PowerShell hook suites (Linux)
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - name: Check out repository
        uses: actions/checkout@v7

      - name: Install PoshQC tooling
        shell: pwsh
        run: |
          Import-Module "${{ github.workspace }}/scripts/powershell/PoshQC/PoshQC.psm1"
          Install-PoshQCTools

      - name: Test PowerShell hook suites
        shell: pwsh
        run: |
          Import-Module Pester -MinimumVersion 5.6.1
          New-Item -ItemType Directory -Force -Path artifacts/pester | Out-Null
          $config = New-PesterConfiguration
          $config.Run.Path = @('tests/scripts/claude-hooks', 'tests/scripts/codex-hooks')
          $config.Run.Exit = $true
          $config.CodeCoverage.Enabled = $false
          $config.TestResult.Enabled = $true
          $config.TestResult.OutputFormat = 'JUnitXml'
          $config.TestResult.OutputPath = 'artifacts/pester/pester-junit-linux-hooks.xml'
          Invoke-Pester -Configuration $config

      - name: Upload PowerShell hook-suite test results
        if: always()
        uses: actions/upload-artifact@v7
        with:
          name: poshqc-linux-hook-test-results
          path: artifacts/pester/pester-junit-linux-hooks.xml
          if-no-files-found: ignore
```

#### R9 — One-line replacement for the `windows.sandbox` assertions (S1, S1b, S1c)

In `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1` (two occurrences, S1 and S1b) and
`tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` (one occurrence, S1c), the text
`$arguments | Should -Contain 'windows.sandbox="elevated"'` is replaced, keeping the line's existing
indentation, by:

```powershell
($arguments -contains 'windows.sandbox="elevated"') | Should -Be $IsWindows -Because 'Codex receives the elevated sandbox argument only on Windows hosts'
```

The replacement asserts the argument is present on Windows and absent on other hosts, matching
`.codex/scripts/epic-child-sandbox-preflight.ps1:33` and `.codex/scripts/launch-epic-child-wave.ps1:153`.
Line counts are unchanged.

#### R10 — Edits to `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` (S2, S3, S4)

(a) In `BeforeAll`, the three lines beginning `        # A synthetic absolute path. No epic checkpoint records it, so a`
through `        $script:SyntheticTarget = 'C:/nonexistent-545-fixture/worktree-9f2a1c'` are replaced by:

```powershell
        # Synthetic rooted prefixes chosen per host OS. [System.IO.Path]::IsPathRooted treats a
        # drive-letter path (a letter, a colon, and a slash) as rooted only on Windows; on Linux
        # and macOS it is relative, and GetFullPath would prefix the current directory. Deriving
        # each prefix from $IsWindows keeps every path below rooted on the host that runs the suite.
        $script:SyntheticRoot = if ($IsWindows) { 'C:/repo' } else { '/repo' }
        $script:SyntheticElsewhere = if ($IsWindows) { 'C:/elsewhere' } else { '/elsewhere' }
        # A synthetic path that is absolute on the host OS. No epic checkpoint records it, so a
        # removal aimed at it denies whatever the on-disk checkpoint holds.
        $script:SyntheticTarget = if ($IsWindows) { 'C:/nonexistent-545-fixture/worktree-9f2a1c' } else { '/nonexistent-545-fixture/worktree-9f2a1c' }
```

(b) In the `It` block `falls back to the current location when the payload carries no cwd`, the two
comment lines `            # The target is absolute, so the working directory does not change the` and
`            # normalized target and the deny holds wherever the suite runs from.` are replaced by:

```powershell
            # SyntheticTarget is absolute on the host OS (BeforeAll derives it from $IsWindows),
            # so the working directory does not change the normalized target and the deny holds
            # wherever the suite runs from.
```

(c) Every remaining drive-letter literal is replaced as follows; nothing else in the file changes:

| Old text | New text |
| --- | --- |
| `-WorkingDirectory 'C:/repo'` (every occurrence) | `-WorkingDirectory $script:SyntheticRoot` |
| `Should -Be 'C:/repo/worktrees/child-a'` (both occurrences) | `Should -Be "$script:SyntheticRoot/worktrees/child-a"` |
| `-Path 'C:/repo/worktrees/child-a/' -WorkingDirectory 'C:/elsewhere'` | `-Path "$script:SyntheticRoot/worktrees/child-a/" -WorkingDirectory $script:SyntheticElsewhere` |
| `-TargetPath 'C:/repo/wt'` (every occurrence) | `-TargetPath "$script:SyntheticRoot/wt"` |
| `-TargetPath 'C:/repo/worktrees/child-a'` | `-TargetPath "$script:SyntheticRoot/worktrees/child-a"` |
| `$checkpoint = '{"features":[{"worktree_path":"C:/repo/worktrees/child-a","merge_status":"worktree_removed"}]}'` | `$checkpoint = '{{"features":[{{"worktree_path":"{0}/worktrees/child-a","merge_status":"worktree_removed"}}]}}' -f $script:SyntheticRoot` |
| `-Command 'git worktree remove "C:/repo/worktrees/child-a"'` | `-Command ('git worktree remove "{0}/worktrees/child-a"' -f $script:SyntheticRoot)` |

#### R11 — Two bullets appended to "Wrap-Tolerant Assertion Authoring (Mandatory)"

Inserted in `.claude/skills/atomic-plan-contract/SKILL.md` immediately after the bullet that begins
`- **Check that the task-ordering does not make the condition unsatisfiable.**` (the section's
current last bullet), before the blank line that precedes `## Plan-Path Continuity Contract (Mandatory)`.
Each bullet is exactly one physical line, like the existing bullets:

```markdown
- **Name the runner and job for a Pester acceptance criterion.** CI runs Pester in two jobs of `.github/workflows/_poshqc.yml`: `poshqc / PowerShell QC` runs every suite with coverage on `windows-latest`, and `poshqc / PowerShell hook suites (Linux)` runs only `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` on `ubuntu-latest`, with coverage disabled. A Pester acceptance criterion may cite `ubuntu-latest` only for suites under `tests/scripts/claude-hooks` or `tests/scripts/codex-hooks`, never for coverage, and must name the job it relies on (`poshqc / PowerShell QC` or `poshqc / PowerShell hook suites (Linux)`).
- **Do not assert a fixed-string search literal that contains a backslash.** Git for Windows grep 3.0 reads a doubled backslash in a `grep -F` pattern as one backslash, so the same check returns a different count locally than on a CI runner and cannot pass in both places. Assert a backslash-free substring of the literal, a named test, or a hash or byte-identity check instead.
```

#### Session helper scripts (written to `<session-scratchpad>`, never to the repository)

SP1 `ps-format-check.ps1` (check mode: reports what would change, writes nothing):

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCFormat -Root (Get-Location).Path -WriteFile { param([string] $Path, [string] $Content) $null = $Path, $Content }
```

SP2 — withdrawn (no task runs a write-mode PowerShell formatter).

SP3 `ps-analyze.ps1`:

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCAnalyze -Root (Get-Location).Path
```

SP4 `ps-test-full.ps1` (full Windows set with coverage, self-hosted settings):

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root (Get-Location).Path
```

SP5 `ps-line-coverage.ps1`:

```powershell
$ErrorActionPreference = 'Stop'
[xml] $report = Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'
$counter = @($report.SelectNodes('/report/counter[@type="LINE"]'))
if ($counter.Count -ne 1) { Write-Output "ROOT-LINE-COUNTER-COUNT: $($counter.Count)"; exit 1 }
$covered = [int] $counter[0].covered
$missed = [int] $counter[0].missed
Write-Output ('PS-LINE-COVERAGE: covered={0} missed={1} percent={2:N2}' -f $covered, $missed, (100.0 * $covered / ($covered + $missed)))
```

SP6 `ps-pester-targeted.ps1` (no coverage; exits 1 on any failed test):

```powershell
param([Parameter(Mandatory)][string] $PathList)
$ErrorActionPreference = 'Stop'
Import-Module Pester -MinimumVersion 5.6.1
$config = New-PesterConfiguration
$config.Run.Path = @($PathList -split ',')
$config.Run.PassThru = $true
$config.CodeCoverage.Enabled = $false
$config.Output.Verbosity = 'Detailed'
$result = Invoke-Pester -Configuration $config
Write-Output ('FAILED-COUNT: {0} PASSED-COUNT: {1} SKIPPED-COUNT: {2}' -f $result.FailedCount, $result.PassedCount, $result.SkippedCount)
if ($result.FailedCount -gt 0 -or $result.FailedBlocksCount -gt 0) { exit 1 }
exit 0
```

SP7 `ps-junit-summary.ps1`:

```powershell
param([Parameter(Mandatory)][string] $Path)
$ErrorActionPreference = 'Stop'
[xml] $junit = Get-Content -Raw -LiteralPath $Path
$root = $junit.DocumentElement
Write-Output ('JUNIT-ROOT: tests={0} failures={1} errors={2}' -f $root.tests, $root.failures, $root.errors)
foreach ($suite in @($junit.SelectNodes('//testsuite'))) {
    $file = (([string] $suite.name) -replace '\\', '/') -replace '^.*?(?=tests/scripts/)', ''
    Write-Output ('SUITE: {0} | tests={1} | failures={2} | errors={3} | skipped={4}' -f $file, $suite.tests, $suite.failures, $suite.errors, $suite.skipped)
    foreach ($case in @($suite.SelectNodes('testcase'))) {
        if ($case.SelectSingleNode('failure') -or $case.SelectSingleNode('error')) {
            Write-Output ('FAIL: {0} | {1}' -f $file, $case.name)
        }
    }
}
```

SP8 `locate-bats.sh`:

```sh
cache=$(cygpath -u "$(npm config get cache)")
find "$cache/_npx" -path '*/node_modules/bats/bin/bats' -type f
```

SP9 `shell-qc-test-local.sh` (argument: `<BATS_DIRECT>`):

```sh
SHELL_QC_BATS_BIN="$1"
export SHELL_QC_BATS_BIN
date -u +RUN_START=%Y-%m-%dT%H-%M-%S
rc=0
bash scripts/bash/shell-qc.sh test || rc=$?
date -u +RUN_END=%Y-%m-%dT%H-%M-%S
echo "SHELL_QC_TEST_EXIT=$rc"
exit "$rc"
```

SP10 `kcov-changed-lines.sh` (arguments: path to a downloaded `cov.xml`, then `<MERGE_BASE>`):

```sh
cov="$1"
base="$2"
for file in scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh; do
	name=${file##*/}
	block=$(awk -v n="$name\"" 'index($0, n) && /<class /{p = 1} p {print} p && /<\/class>/{exit}' "$cov")
	echo "CLASS: $file $(printf '%s\n' "$block" | head -n 1 | grep -o 'line-rate="[0-9.]*"')"
	lines=$(git diff -U0 "$base" -- "$file" | awk '/^@@ /{ split($3, a, ","); s = substr(a[1], 2) + 0; c = (a[2] == "" ? 1 : a[2] + 0); for (i = 0; i < c; i++) print s + i }')
	for n in $lines; do
		hit=$(printf '%s\n' "$block" | grep -o "<line number=\"$n\" hits=\"[0-9]*\"" | grep -o 'hits="[0-9]*"' | grep -o '[0-9][0-9]*')
		if [ -z "$hit" ]; then echo "LINE: $file:$n NOT-INSTRUMENTED"; else echo "LINE: $file:$n hits=$hit"; fi
	done
done
```

SP11 `skill-bullet-tokens.sh` (argument: a `SKILL.md` path):

```sh
file="$1"
check() {
	lead="$1"
	shift
	line=$(grep -F -- "$lead" "$file")
	echo "BULLET: $lead | lines=$(printf '%s\n' "$line" | grep -c -F -- "$lead")"
	for token in "$@"; do
		if printf '%s\n' "$line" | grep -q -F -- "$token"; then echo "TOKEN-PRESENT: $token"; else echo "TOKEN-MISSING: $token"; fi
	done
}
check '**Name the runner and job for a Pester acceptance criterion.**' 'windows-latest' 'ubuntu-latest' 'tests/scripts/claude-hooks' 'tests/scripts/codex-hooks' 'never for coverage' 'poshqc / PowerShell QC' 'poshqc / PowerShell hook suites (Linux)'
check '**Do not assert a fixed-string search literal that contains a backslash.**' 'grep -F' 'Git for Windows grep 3.0' 'doubled backslash' 'one backslash' 'backslash-free substring' 'named test' 'byte-identity'
```

---

### Phase 0 — Policy Reads, Base Anchor, Edit-Site Detection, and Baseline Capture

- [x] [P0-T1] Record the base anchor in `<FEATURE>/evidence/baseline/base-anchor.<ts>.md`: run
  `git fetch origin main`, `git rev-parse HEAD`, `git merge-base HEAD origin/main`, and
  `git diff --exit-code --stat <MERGE_BASE> HEAD -- scripts/ tests/ .github/ .claude/skills/ extensions/`,
  each with its own `Command:`/`EXIT_CODE:` pair (the third command's printed SHA is
  `<MERGE_BASE>` for the rest of the plan). Acceptance: the artifact records the HEAD SHA and the
  `<MERGE_BASE>` literal; the scoped diff exits 0 with empty output (the branch carries only
  documentation commits under `<FEATURE>/`). Any other result stops the plan (BLOCKED, returned to
  the planner).
- [x] [P0-T2] Read the policy files in the order of `.claude/skills/policy-compliance-order/SKILL.md`:
  `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, then the
  language rules `.claude/rules/powershell.md` and `.claude/rules/shell.md`, then the supplementary
  rules `.claude/rules/quality-tiers.md`, `.claude/rules/ci-workflows.md`,
  `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/tonality.md`, and
  `.claude/rules/plan-acceptance-gates.md`, then `.github/instructions/github-actions.instructions.md`,
  `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, and
  `.claude/skills/acceptance-criteria-tracking/SKILL.md`. Acceptance: all thirteen files read in
  that order; no file edited.
- [x] [P0-T3] Write `<FEATURE>/evidence/baseline/phase0-instructions-read.md` with `Timestamp:`,
  `Policy Order:` (the P0-T2 order), and the explicit list of the thirteen files read. Acceptance:
  the file exists with all three fields and thirteen listed paths.
- [x] [P0-T4] Record the quality-tier assumption in `<FEATURE>/evidence/baseline/quality-tier.<ts>.md`
  with `ExpectedExitCode: 1`: run `test -e quality-tiers.yml`. Acceptance: `EXIT_CODE: 1`, and the
  artifact states `Tier: T4 (assumed; dev tooling, CI scaffolding, and tests)`. If the command exits
  0, record the tiers the file assigns to `scripts/` and `.github/`; if either is T1 or T2, stop the
  plan (BLOCKED, returned to the planner).
- [x] [P0-T5] Edit-site detection into `<FEATURE>/evidence/baseline/edit-site-detection.<ts>.md`,
  each command with its own pair:
  `grep -c -F 'run_test() {' scripts/bash/shell_qc_lib.sh`;
  `grep -c -F 'extract_cobertura_line_rate() {' scripts/bash/shell_qc_lib.sh`;
  `grep -c -F '@test "an unknown test flag exits 2" {' tests/shell/test_shell_qc_commands.bats`;
  `grep -c -F 'if-no-files-found: ignore' .github/workflows/_poshqc.yml`;
  `grep -c -F 'windows.sandbox="elevated"' tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1`;
  `grep -c -F 'windows.sandbox="elevated"' tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1`;
  `grep -c -F -e 'C:/repo' -e 'C:/elsewhere' -e 'C:/nonexistent' tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`;
  `grep -c -F '**Check that the task-ordering does not make the condition unsatisfiable.**' .claude/skills/atomic-plan-contract/SKILL.md`;
  and the same command against
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`.
  Acceptance: the printed counts are, in order, `1`, `1`, `1`, `1`, `2`, `1`, `15`, `1`, and `1`.
  Any other count means a sibling change moved an anchor; stop the plan (BLOCKED, returned to the
  planner).
- [x] [P0-T6] Absence detection for the new names, each command in its own artifact under
  `<FEATURE>/evidence/baseline/` with `ExpectedExitCode: 1`:
  `test -e scripts/bash/kcov_trace_env.sh` (`new-trace-env-absent.<ts>.md`);
  `test -e tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (`new-workflow-suite-absent.<ts>.md`);
  `test -e tests/fixtures/shell_qc/kcov_trace` (`new-fixture-dir-absent.<ts>.md`);
  `test -e tests/fixtures/shell_qc/stub-bin/bats-nounset-source` (`new-stub-absent.<ts>.md`);
  `grep -n -F 'poshqc-linux-hooks' .github/workflows/_poshqc.yml` (`new-job-absent.<ts>.md`); and
  `grep -n -F 'kcov_trace_env' scripts/bash/shell_qc_lib.sh` (`new-lib-ref-absent.<ts>.md`).
  Acceptance: each command prints nothing and exits 1. Any other result stops the plan (BLOCKED,
  returned to the planner).
- [x] [P0-T7] Record tool availability in `<FEATURE>/evidence/baseline/tool-versions.<ts>.md`, each
  command with its own pair: `shfmt --version`, `shellcheck --version`, `npx --yes bats --version`,
  `gh version` (the subcommand form),
  `pwsh -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'`,
  `pwsh -NoProfile -Command '(Get-Module -ListAvailable Pester | Sort-Object Version -Descending | Select-Object -First 1).Version.ToString()'`,
  and `pwsh -NoProfile -Command '(Get-Command actionlint -ErrorAction SilentlyContinue).Source'`.
  Acceptance: each output recorded. `npx --yes bats --version` prints a line beginning `Bats `; the
  Pester version is `5.6.1` or later. When the actionlint command prints nothing, record
  `ACTIONLINT-ON-PATH: NO`. In that case `scripts/dev-tools/run-actionlint.ps1` downloads a copy
  into `tools/actionlint/bin/` on first use; that untracked directory is never staged and is the
  only untracked path P7-T22 tolerates. If bats cannot be resolved through npx, record the output
  verbatim; every later local bats step then uses the CI fallback named in that step.
- [x] [P0-T8] Locate the direct bats-core script into `<FEATURE>/evidence/baseline/bats-direct.<ts>.md`:
  write SP8 into `<session-scratchpad>` and run `sh <session-scratchpad>/locate-bats.sh`.
  Acceptance: the output lists exactly one path; it is recorded as `<BATS_DIRECT>` in the form
  `<npm-cache>/_npx/<hash>/node_modules/bats/bin/bats` (no absolute host path in the artifact), and
  `<BATS_DIRECT> --version` prints a line beginning `Bats `. When the output lists zero paths or more
  than one, record `BATS-DIRECT: UNAVAILABLE` with the output. P0-T24 and P7-T12 then use their
  stated CI fallback.
- [x] [P0-T9] Start the baseline full local `shell-qc.sh test` run for `scripts/bash/shell-qc.sh`
  (skip this task when P0-T8 recorded `BATS-DIRECT: UNAVAILABLE`, and record that skip reason in
  P0-T24): write SP9 into `<session-scratchpad>` and start
  `sh <session-scratchpad>/shell-qc-test-local.sh <BATS_DIRECT>` in the background with its output
  captured in `<session-scratchpad>/shell-qc-test-baseline.log`. Acceptance: the background process
  started and its start time is recorded in P0-T24. No file under `tests/`, `scripts/`, or
  `.github/` is edited until P0-T24 is complete, because the run reads those files while it
  executes.
- [x] [P0-T10] Baseline PowerShell format check (check mode, no write) into
  `<FEATURE>/evidence/baseline/ps-format-check.<ts>.md`: write SP1 into `<session-scratchpad>` and
  run `pwsh -NoProfile -File <session-scratchpad>/ps-format-check.ps1`. Acceptance: `EXIT_CODE: 0`;
  the artifact records the count of output lines beginning `Already formatted: ` and the count and
  full list of lines beginning `Formatted: ` (each a file that would change). Each recorded path is
  normalized: backslashes are written as forward slashes and the repository-root prefix is replaced
  by `<REPO_ROOT>`. A zero `Formatted: `
  count is recorded as `FORMAT-DRIFT: NONE`, and otherwise as `FORMAT-DRIFT: PRESENT` with the list.
  No file is written by this task: `git status --porcelain` run before and after prints the same
  listing, and both runs are recorded.
- [x] [P0-T11] Baseline PowerShell analyze into `<FEATURE>/evidence/baseline/ps-analyze.<ts>.md`:
  write SP3 into `<session-scratchpad>` and run `pwsh -NoProfile -File <session-scratchpad>/ps-analyze.ps1`.
  Acceptance: the artifact records `EXIT_CODE:` and either the line that begins
  `PSScriptAnalyzer passed: no findings under` or the full findings table and the thrown
  `PSScriptAnalyzer reported <n> issue(s).` message (the baseline finding set).
- [x] [P0-T12] Baseline full Windows Pester run with coverage into
  `<FEATURE>/evidence/baseline/ps-pester-full.<ts>.md`: write SP4 into `<session-scratchpad>` and run
  `pwsh -NoProfile -File <session-scratchpad>/ps-test-full.ps1`. Then write SP7 and run
  `pwsh -NoProfile -File <session-scratchpad>/ps-junit-summary.ps1 -Path artifacts/pester/pester-junit.xml`,
  recording its pair in the same artifact after the run pair. Acceptance: the console line that
  begins `Tests Passed:` is recorded with its Passed, Failed, and Skipped counts; the `JUNIT-ROOT:`
  line is recorded; every `FAIL:` line is recorded under the heading `Local PowerShell baseline failure set:`
  (the word `none` when there is none); the `SUITE:` lines for
  `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1`,
  `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1`, and
  `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` are recorded.
- [x] [P0-T13] Baseline PowerShell line coverage into `<FEATURE>/evidence/baseline/ps-coverage.<ts>.md`:
  write SP5 into `<session-scratchpad>` and run `pwsh -NoProfile -File <session-scratchpad>/ps-line-coverage.ps1`
  against the report P0-T12 produced. Acceptance: `EXIT_CODE: 0` and the `PS-LINE-COVERAGE:` line
  with numeric `covered`, `missed`, and `percent` values is recorded as the PowerShell baseline. A
  `ROOT-LINE-COUNTER-COUNT:` line (exit 1) marks the coverage baseline remediation-required, and the
  plan outcome cannot be PASS without a numeric baseline.
- [x] [P0-T14] Baseline targeted Pester run for the three Codex suites into
  `<FEATURE>/evidence/baseline/ps-pester-codex-targeted.<ts>.md`: write SP6 into `<session-scratchpad>`
  and run
  `pwsh -NoProfile -File <session-scratchpad>/ps-pester-targeted.ps1 -PathList tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1,tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1,tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`.
  Acceptance: `EXIT_CODE: 0`; the `FAILED-COUNT: 0` line is recorded with its passed count; the
  detailed output contains a `[+]` line for each of `preflights the elevated Windows sandbox from an isolated CODEX_HOME`,
  `uses inline project trust, ignores user config, and denies Codex install paths`,
  `builds codex exec with exact model, reasoning, instructions, skills, permissions, and worktree`,
  `resolves a relative path against the supplied working directory`, and
  `keeps a rooted path and trims a trailing separator`.
- [x] [P0-T15] Baseline repo-wide bash check via `scripts/bash/shell-qc.sh` into
  `<FEATURE>/evidence/baseline/shell-qc-check.<ts>.md`: run `sh scripts/bash/shell-qc.sh check`.
  Acceptance: the artifact records `EXIT_CODE:` and every diagnostic line verbatim, and states
  `LOCAL-DRIFT: NONE` when the run prints nothing and exits 0, or `LOCAL-DRIFT: PRESENT` with the
  files named by any shfmt diff otherwise (local shfmt and shellcheck versions differ from CI).
- [x] [P0-T16] Baseline targeted lint and format for `scripts/bash/shell_qc_lib.sh`: run
  `shellcheck -f gcc scripts/bash/shell_qc_lib.sh` into `<FEATURE>/evidence/baseline/shellcheck-lib.<ts>.md`
  and `shfmt -d scripts/bash/shell_qc_lib.sh` into `<FEATURE>/evidence/baseline/shfmt-lib.<ts>.md`.
  Acceptance: each artifact records `EXIT_CODE:` and its output verbatim (expected: no output and exit 0
  for both; a pre-existing finding is recorded, not fixed, here).
- [x] [P0-T17] Baseline syntax step for `scripts/bash/shell_qc_lib.sh` (bash has no type checker):
  run `sh -n scripts/bash/shell_qc_lib.sh` into `<FEATURE>/evidence/baseline/syntax-lib.<ts>.md`.
  Acceptance: `EXIT_CODE: 0` and no output.
- [x] [P0-T18] Baseline local bats run for `tests/shell/test_shell_qc_commands.bats` and
  `tests/shell/test_shell_qc_discovery.bats` into `<FEATURE>/evidence/baseline/bats-shell-qc.<ts>.md`:
  run `npx --yes bats tests/shell/test_shell_qc_commands.bats tests/shell/test_shell_qc_discovery.bats`.
  Acceptance: the full TAP output is recorded, including a `1..N` line and the lines
  `ok <n> test prints the exact bats-missing skip marker and exits 0` and
  `ok <n> test prints the exact no-test-directory skip marker and exits 0`; the names of any
  `not ok` tests are recorded under `Local bats baseline failure set:` (expected `none`).
- [ ] [P0-T19] Baseline actionlint for `.github/workflows/_poshqc.yml` into
  `<FEATURE>/evidence/baseline/actionlint-poshqc.<ts>.md`: run
  `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml`.
  Acceptance: the artifact records `EXIT_CODE:` and the output verbatim; expected `EXIT_CODE: 0`,
  and the output contains the line `Running actionlint...` and no line containing
  `actionlint exited with code`. The wrapper discards actionlint's stdout
  (`scripts/dev-tools/run-actionlint.ps1:128`), so on a non-zero exit the task also runs
  `actionlint .github/workflows/_poshqc.yml` (on PATH per P0-T7; `tools/actionlint/bin/actionlint.exe`
  when P0-T7 recorded `ACTIONLINT-ON-PATH: NO`) into the same artifact to record the findings.
- [x] [P0-T20] Baseline skill-mirror parity for `.claude/skills/atomic-plan-contract/SKILL.md`: run
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` into
  `<FEATURE>/evidence/baseline/pytest-claude-resource-contracts.<ts>.md`, and
  `sha256sum .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`
  into `<FEATURE>/evidence/baseline/skill-hashes.<ts>.md`. Acceptance: pytest exits 0 and its
  summary line reports `passed` with zero `failed`; the two printed hashes are equal. When the only
  failure is `test_bundled_claude_payload_contains_all_repo_runtime_contracts` and its message
  contains `Repo file missing from bundle:` and `batch-budget`, record `KNOWN-ISSUE-510` with the
  output of `git status --porcelain --ignored -- .claude/state`; the baseline then rests on the
  equal hashes and the recorded passed count.
- [x] [P0-T21] Baseline line counts for every file this plan modifies: run
  `wc -l .github/workflows/_poshqc.yml scripts/bash/shell_qc_lib.sh tests/shell/test_shell_qc_commands.bats tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 .claude/skills/atomic-plan-contract/SKILL.md`
  into `<FEATURE>/evidence/baseline/line-counts.<ts>.md`. Acceptance: every count recorded (at
  authoring: 52, 379, 169, 469, 495, and 251 for the first six; the recorded values govern), and
  each of the first six is below 500.
- [x] [P0-T22] Push the branch `bug/ci-gaps-linux-pester-and-kcov-set-u-743` and dispatch the
  baseline CI runs: run `git push -u origin bug/ci-gaps-linux-pester-and-kcov-set-u-743` (no force),
  `git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743`, record the dispatch
  time (UTC), then run `gh workflow run _shell-coverage.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743`
  and `gh workflow run _poshqc.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743`. Poll each with
  `gh run list --workflow=_shell-coverage.yml --branch bug/ci-gaps-linux-pester-and-kcov-set-u-743 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt`
  and the same command with `--workflow=_poshqc.yml`, until each returns a run created after the
  dispatch time. Start `gh run watch <RUN_ID>` for both runs in the background. Record all pairs in
  `<FEATURE>/evidence/baseline/ci-baseline-dispatch.<ts>.md`. Acceptance: the push and ls-remote
  exit 0; the remote head equals the P0-T1 HEAD SHA; both run IDs are recorded and each `headSha`
  equals that SHA.
- [x] [P0-T23] Record the CI baselines after both watches finish, into
  `<FEATURE>/evidence/baseline/ci-baseline-results.<ts>.md`. For the `_shell-coverage.yml` run: run
  `gh run view <RUN_ID> --json conclusion,jobs`, then `gh run view <RUN_ID> --log` filtered by
  `grep -F 'Bash coverage (lines):'`, by `grep -c -E ' not ok [0-9]+ '`, and by
  `grep -E ' not ok [0-9]+ '`; then
  `gh run download <RUN_ID> --name shell-coverage --dir <session-scratchpad>/kcov-baseline-743` and
  `sed -n '/shell_qc_lib\.sh"/,/<\/class>/p' <session-scratchpad>/kcov-baseline-743/cov.xml`
  (or `kcov-merged/cov.xml` in that directory when the root copy is absent). For the `_poshqc.yml`
  run: run `gh run view <RUN_ID> --json conclusion,jobs` and, using the `PowerShell QC` job's
  `databaseId` as `<JOB_ID>`, `gh run view <RUN_ID> --log --job <JOB_ID>` filtered by
  `grep -F 'Tests Passed:'`. Acceptance: the numeric `Bash coverage (lines): NN.N%` headline is
  recorded; the test names from every line the `grep -E` filter prints are recorded under
  `CI bats baseline failure set:` (`none` when it prints nothing); the class element's `line-rate`
  for `scripts/bash/shell_qc_lib.sh` is recorded; the `PowerShell QC` job conclusion and its
  `Tests Passed:` line are recorded, and any failed test names from
  `gh run view <RUN_ID> --log-failed` are recorded under `CI Windows Pester baseline failure set:`.
  When the shell run failed or printed no headline, record `gh run view <RUN_ID> --log-failed` and
  mark the bash coverage baseline remediation-required (the plan outcome cannot be PASS without it).
- [x] [P0-T24] Complete the baseline full local `shell-qc.sh test` record for
  `scripts/bash/shell-qc.sh` into `<FEATURE>/evidence/baseline/shell-qc-test-full.<ts>.md` after the
  P0-T9 background run exits. Acceptance: the artifact records `Command:` (the SP9 command),
  `EXIT_CODE:` (the `SHELL_QC_TEST_EXIT=` value), the `RUN_START=` and `RUN_END=` values and the
  derived wall time in minutes, the TAP `1..N` line, the `not ok` count, and the test names on every
  `not ok` line under `Local full bats baseline failure set:` (`none` when empty). When P0-T8
  recorded `BATS-DIRECT: UNAVAILABLE`, the artifact instead records
  `LOCAL-FULL-RUN: UNAVAILABLE; AC-15 evidence source: shell-coverage / Shell Coverage (Bats + kcov) (P7-T20)`,
  and the P0-T23 CI bats baseline failure set is the comparison baseline.

### Phase 1 — Regression Tests (Fail-Before)

No file under `tests/`, `scripts/`, or `.github/` is edited before P0-T24 is complete.

- [x] [P1-T1] Create `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` with the Write tool, content
  exactly as reference block R1. Acceptance: the file exists and its first line is
  `Set-StrictMode -Version Latest`.
- [x] [P1-T2] [expect-fail] Fail-before run of `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` into
  `<FEATURE>/evidence/regression-testing/fail-before-poshqc-workflow.<ts>.md` with
  `ExpectedExitCode: 1`: run
  `pwsh -NoProfile -File <session-scratchpad>/ps-pester-targeted.ps1 -PathList tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`.
  Acceptance: `EXIT_CODE: 1`; the output line reads `FAILED-COUNT: 6 PASSED-COUNT: 1 SKIPPED-COUNT: 0`;
  the only `[+]` line names `keeps the poshqc job on windows-latest running Invoke-PoshQCTest`; the
  six `[-]` lines name the other six `It` blocks of R1. A failure of the `keeps the poshqc job` test,
  or a discovery or parse error, fails this task.
- [x] [P1-T3] Create `tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh` with the Write tool, content
  exactly as reference block R2. Acceptance: the file exists; no other file exists under
  `tests/fixtures/shell_qc/kcov_trace/`.
- [x] [P1-T4] Create `tests/fixtures/shell_qc/stub-bin/bats-nounset-source` with the Write tool,
  content exactly as reference block R3. Acceptance: the file exists and its first line is
  `#!/usr/bin/env bash`.
- [x] [P1-T5] Create `tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset` with the Write tool,
  content exactly as reference block R4. Acceptance: the file exists and its first line is
  `#!/usr/bin/env bash`.
- [x] [P1-T6] Verify the three new fixture files in `tests/fixtures/shell_qc/` into
  `<FEATURE>/evidence/regression-testing/fixture-check.<ts>.md`: for each of
  `tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh`, `tests/fixtures/shell_qc/stub-bin/bats-nounset-source`,
  and `tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset`, run
  `tr -d -c '\r' < <path> | wc -c` and `git check-attr text eol -- <path>`; then run
  `sh -n` on each of the three paths. Acceptance: each `tr`/`wc` count prints `0` (no carriage
  return); each `git check-attr` prints `text: auto` and `eol: lf` (the repository rule
  `* text=auto eol=lf` covers the paths, so `.gitattributes` is not edited); each `sh -n` exits 0
  with no output.
- [x] [P1-T7] Update `tests/shell/test_shell_qc_commands.bats` by appending the three tests of
  reference block R5 after the test `an unknown test flag exits 2`. Verify with
  `git diff --numstat <MERGE_BASE> -- tests/shell/test_shell_qc_commands.bats` and
  `grep -n -F '@test "' tests/shell/test_shell_qc_commands.bats`. Acceptance: the numstat
  deleted-line column is `0`; the last three printed `@test` lines name, in order,
  `test fails when a bats child sources a nounset library inside bash -c`,
  `test passes when a bats child resets nounset after sourcing`, and
  `kcov_trace_env.sh sets the kcov PS4 format`; the file header, `setup()`, `teardown()`, and every
  existing test are byte-unchanged.
- [x] [P1-T8] [expect-fail] Fail-before run of `tests/shell/test_shell_qc_commands.bats` into
  `<FEATURE>/evidence/regression-testing/fail-before-bats.<ts>.md` with `ExpectedExitCode: 1`: with
  `scripts/bash/shell_qc_lib.sh` still unmodified and `scripts/bash/kcov_trace_env.sh` still absent,
  run `npx --yes bats --print-output-on-failure tests/shell/test_shell_qc_commands.bats`.
  Acceptance: `EXIT_CODE: 1`; the TAP output is recorded verbatim; exactly two `not ok` lines exist,
  naming `test fails when a bats child sources a nounset library inside bash -c` (its failure detail
  names the assertion `[ "$status" -ne 0 ]`, and its printed output contains
  `nounset-stub ran: tests/shell`) and `kcov_trace_env.sh sets the kcov PS4 format`; the line for
  `test passes when a bats child resets nounset after sourcing` and every test in the P0-T18
  baseline begin `ok `. CI fallback, used only when P0-T7 recorded that npx cannot resolve bats:
  commit the P1 files with a pathspec-bearing commit, push, dispatch `_shell-coverage.yml` as in
  P0-T22, and apply the same acceptance to the TAP lines in `gh run view <RUN_ID> --log`. Under CI
  kcov the nounset test can already pass before the fix, because kcov's own trace environment
  reaches the stub. In that fallback only the `kcov_trace_env.sh sets the kcov PS4 format` failure
  is required, and the fail-before evidence for the nounset test is recorded as a
  `fail-before-exception.<ts>.md` dossier stating that reason.

### Phase 2 — kcov Trace Simulation in `run_test`

- [x] [P2-T1] Create `scripts/bash/kcov_trace_env.sh` with the Write tool, content exactly as
  reference block R6. Acceptance: `grep -c -F 'PS4=' scripts/bash/kcov_trace_env.sh` prints `1` and
  `grep -c -x -F 'set -x' scripts/bash/kcov_trace_env.sh` prints `1`. The exact `PS4` value is
  asserted by the bats test `kcov_trace_env.sh sets the kcov PS4 format` in P2-T6.
- [x] [P2-T2] Lint `scripts/bash/kcov_trace_env.sh` into
  `<FEATURE>/evidence/regression-testing/shellcheck-trace-env-initial.<ts>.md`: run
  `shellcheck -f gcc scripts/bash/kcov_trace_env.sh`. Acceptance: `EXIT_CODE:` and the output are
  recorded verbatim, and the artifact states `SC2016: REPORTED` when any output line contains
  `SC2016`, otherwise `SC2016: NOT REPORTED`. Any finding other than SC2016 fails this task; fix it
  in the file and re-run.
- [x] [P2-T3] Update `scripts/bash/kcov_trace_env.sh` with reference block R6b (conditional: only
  when P2-T2 recorded `SC2016: REPORTED`; otherwise record `R6b: NOT APPLIED` in the P2-T2
  artifact and mark this task done). Then run `shellcheck -f gcc scripts/bash/kcov_trace_env.sh`
  into `<FEATURE>/evidence/regression-testing/shellcheck-trace-env-final.<ts>.md`. Acceptance: the
  final run exits 0 with no output.
- [x] [P2-T4] Update `scripts/bash/shell_qc_lib.sh` by replacing `run_test` with reference block R7.
  Acceptance: `grep -c -F 'kcov_trace_env.sh' scripts/bash/shell_qc_lib.sh` prints `2` (one comment
  reference, one assignment); `grep -c -F 'BASH_XTRACEFD="$trace_fd"' scripts/bash/shell_qc_lib.sh`
  prints `1`; `git diff -U0 <MERGE_BASE> -- scripts/bash/shell_qc_lib.sh` shows hunks only between
  the lines `run_test() {` and `extract_cobertura_line_rate() {` (so `run_test_coverage` is
  unchanged, AC-12).
- [x] [P2-T5] Format, lint, and syntax check `scripts/bash/shell_qc_lib.sh` and
  `scripts/bash/kcov_trace_env.sh` into `<FEATURE>/evidence/regression-testing/bash-static-post-edit.<ts>.md`:
  run `shfmt -d scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh`,
  `shellcheck -f gcc scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh`, and
  `sh -n scripts/bash/shell_qc_lib.sh`, each with its own pair. Acceptance: each exits 0 with no
  output. A shfmt diff is fixed by editing the file to match, not by suppressing it.
- [x] [P2-T6] Pass-after run of `tests/shell/test_shell_qc_commands.bats` into
  `<FEATURE>/evidence/regression-testing/pass-after-bats.<ts>.md`: run
  `npx --yes bats --print-output-on-failure tests/shell/test_shell_qc_commands.bats`. Acceptance:
  `EXIT_CODE: 0`; zero `not ok` lines; the lines for the three R5 tests and every P0-T18 baseline
  test in this file begin `ok `. When the only failure is `test passes when a bats child resets nounset after sourcing`
  and its printed output contains `invalid value for trace file descriptor` or a `kcov@` line (the
  descriptor did not reach the bats process), record `TRACE-FD-NOT-INHERITED` and continue to
  P2-T7. Any other failure fails this task. CI fallback when npx cannot resolve bats: as in P1-T8,
  with the run expected to conclude `success`.
- [x] [P2-T7] Update `scripts/bash/shell_qc_lib.sh` with reference block R7b (conditional: only when
  P2-T6 recorded `TRACE-FD-NOT-INHERITED`; otherwise record `R7b: NOT APPLIED` in the P2-T6 artifact
  and mark this task done). Then re-run the P2-T5 commands and the P2-T6 command into new
  timestamped artifacts. Acceptance: the P2-T5 and P2-T6 acceptance conditions hold on the re-run.
- [x] [P2-T8] Update `scripts/bash/shell_qc_lib.sh` temporarily for a negative control of the
  trace-discard assertion in `tests/shell/test_shell_qc_commands.bats`, then restore it byte for
  byte, proving `test passes when a bats child resets nounset after sourcing` can fail, recorded in
  `<FEATURE>/evidence/regression-testing/trace-discard-negative-control.<ts>.md` with
  `ExpectedExitCode: 1`. First run `sha256sum scripts/bash/shell_qc_lib.sh` and record it as the
  pre-mutation hash in `<FEATURE>/evidence/regression-testing/trace-discard-restored.<ts>.md`.
  Temporarily delete the text `BASH_XTRACEFD="$trace_fd" ` (or `BASH_XTRACEFD=19 ` when R7b was
  applied) from the bats invocation line of `scripts/bash/shell_qc_lib.sh`, then run
  `npx --yes bats --print-output-on-failure --filter 'resets nounset after sourcing' tests/shell/test_shell_qc_commands.bats`,
  then restore the line exactly. Acceptance: the filtered run exits 1 with one `not ok` line naming
  that test, and its printed output contains `kcov@`. After the restore, `sha256sum scripts/bash/shell_qc_lib.sh`
  prints the pre-mutation hash (pair appended to the restored artifact).

### Phase 3 — Linux Hook-Suite Job in `_poshqc.yml`

- [x] [P3-T1] Update `.github/workflows/_poshqc.yml` by appending reference block R8 after the line
  `          if-no-files-found: ignore`. Acceptance: `grep -c -F 'poshqc-linux-hooks:' .github/workflows/_poshqc.yml`
  prints `1` and `grep -c -F 'name: poshqc-linux-hook-test-results' .github/workflows/_poshqc.yml`
  prints `1`.
- [x] [P3-T2] Pass-after run of `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` into
  `<FEATURE>/evidence/regression-testing/pass-after-poshqc-workflow.<ts>.md`: run
  `pwsh -NoProfile -File <session-scratchpad>/ps-pester-targeted.ps1 -PathList tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`.
  Acceptance: `EXIT_CODE: 0`; the output line reads `FAILED-COUNT: 0 PASSED-COUNT: 7 SKIPPED-COUNT: 0`;
  seven `[+]` lines name the seven R1 `It` blocks (AC-1, AC-2, AC-3, and the AC-4 `poshqc`
  assertions).
- [ ] [P3-T3] Lint `.github/workflows/_poshqc.yml` with actionlint into
  `<FEATURE>/evidence/regression-testing/actionlint-poshqc.<ts>.md`: run
  `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml`.
  Acceptance: `EXIT_CODE: 0`, and the output contains the line `Running actionlint...` and no line
  containing `actionlint exited with code` (AC-5). The wrapper discards actionlint's stdout
  (`scripts/dev-tools/run-actionlint.ps1:128`), so on a non-zero exit the task also runs
  `actionlint .github/workflows/_poshqc.yml` (on PATH per P0-T7; `tools/actionlint/bin/actionlint.exe`
  when P0-T7 recorded `ACTIONLINT-ON-PATH: NO`) into the same artifact to record the findings.
- [x] [P3-T4] Verify that the `poshqc` job in `.github/workflows/_poshqc.yml` is unchanged (AC-4)
  into `<FEATURE>/evidence/regression-testing/poshqc-job-unchanged.<ts>.md`: run
  `git diff --numstat <MERGE_BASE> -- .github/workflows/_poshqc.yml` and
  `git diff -U0 <MERGE_BASE> -- .github/workflows/_poshqc.yml`. Acceptance: the numstat line's
  deleted-line column is `0`; the `-U0` output has exactly one hunk header, and its old-side range is
  `-<L>,0`, where `<L>` is the P0-T21 line count of `.github/workflows/_poshqc.yml` (52 at authoring).
  Every added line is therefore after the last line of the `poshqc` job.

### Phase 4 — First Linux CI Run (Discovery)

- [x] [P4-T1] Commit and push the Phase 1 to Phase 3 changes of `bug/ci-gaps-linux-pester-and-kcov-set-u-743`:
  run `git add -- .github/workflows/_poshqc.yml tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 scripts/bash/kcov_trace_env.sh scripts/bash/shell_qc_lib.sh tests/shell/test_shell_qc_commands.bats tests/fixtures/shell_qc/kcov_trace/ tests/fixtures/shell_qc/stub-bin/bats-nounset-source tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/`,
  then `git commit -F <message file> --` with the same paths, then `git rev-parse HEAD` (CI_SHA_1),
  then `git push origin bug/ci-gaps-linux-pester-and-kcov-set-u-743` and
  `git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743`. Record all pairs in
  `<FEATURE>/evidence/other/commit-push-discovery.<ts>.md`. Acceptance: every command exits 0 and the
  remote head equals CI_SHA_1. If the preimplementation gate refuses a command, record the refusal
  text and stop (BLOCKED).
- [x] [P4-T2] Dispatch the first run of `.github/workflows/_poshqc.yml` with the new job: record the
  dispatch time (UTC), run `gh workflow run _poshqc.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743`,
  and repeat the P0-T22 `_poshqc.yml` poll until it returns a run created after the dispatch time;
  its `databaseId` is `<RUN_ID>` for this phase. Start `gh run watch <RUN_ID>` in the background.
  Record the pairs in `<FEATURE>/evidence/qa-gates/linux-first-run.<ts>.md`. Acceptance: the run's
  `headSha` equals CI_SHA_1.
- [x] [P4-T3] [expect-fail] Read the first Linux run of `.github/workflows/_poshqc.yml` after the
  background watch finishes, appending to `<FEATURE>/evidence/qa-gates/linux-first-run.<ts>.md`: run
  `gh run view <RUN_ID> --json conclusion,jobs`; with the `PowerShell hook suites (Linux)` job's
  `databaseId` as `<JOB_ID>`, run `gh run view <RUN_ID> --log --job <JOB_ID>` filtered by
  `grep -F 'Tests Passed:'`; run
  `gh run download <RUN_ID> --name poshqc-linux-hook-test-results --dir <session-scratchpad>/linux-first-run-743`
  and `pwsh -NoProfile -File <session-scratchpad>/ps-junit-summary.ps1 -Path <session-scratchpad>/linux-first-run-743/pester-junit-linux-hooks.xml`.
  Acceptance: the `PowerShell hook suites (Linux)` job concluded `failure`, and its failing step is
  `Test PowerShell hook suites`; `JUNIT-ROOT:` reports `tests` greater than 0; the `FAIL:` lines
  include one line each for the testcase names ending in
  `preflights the elevated Windows sandbox from an isolated CODEX_HOME` (S1),
  `uses inline project trust, ignores user config, and denies Codex install paths` (S1b),
  `builds codex exec with exact model, reasoning, instructions, skills, permissions, and worktree` (S1c),
  `resolves a relative path against the supplied working directory` (S2), and
  `keeps a rooted path and trims a trailing separator` (S2). The `PowerShell QC` job conclusion is
  recorded; a failure there whose failed tests are not all in the P0-T23 CI Windows Pester
  baseline failure set fails this task. When the Linux job failed in a step other than
  `Test PowerShell hook suites`, record the `gh run view <RUN_ID> --log-failed` output and go to
  P4-T5. When the job concluded `success`, or any of the five named cases is absent from the
  `FAIL:` lines, record `DISCOVERY-DIVERGENCE: <detail>` and stop the plan (BLOCKED, returned to the
  planner), because the job then did not run the suites as designed. Also write
  `<FEATURE>/evidence/regression-testing/fail-before-linux-hook-suites.<ts>.md` with `Timestamp:`,
  `RUN_ID:`, `CI_SHA:` (CI_SHA_1), the `gh run view <RUN_ID> --json conclusion,jobs`
  `Command:`/`EXIT_CODE:` pair, `Output Summary:` stating the Linux job conclusion, and every
  `FAIL:` line.
- [x] [P4-T4] Write the AC-10 inventory `<FEATURE>/evidence/qa-gates/linux-first-run-failures.<ts>.md`
  from the P4-T3 `FAIL:` lines: `Timestamp:`, `RUN_ID:`, `CI_SHA:`, and one table row per `FAIL:`
  line with the columns `File`, `Testcase`, `Class`, and `Planned disposition`. `Class` is one of
  S1, S1b, S1c, S2, S3, S5, or NEW. `Planned disposition` is `P5-T1`, `P5-T2`, or `P5-T3` for the
  S1/S1b/S1c/S2/S3 rows. It is `P5-T4`, `P5-T5`, or `P5-T6` for S5 and NEW rows in
  `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1`,
  `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1`, or
  `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`
  respectively, and `REMEDIATION-REQUIRED` for a row of any class in any other file. Acceptance: the row count
  equals the number of `FAIL:` lines, and every row has all four columns filled.
- [x] [P4-T5] Fix `.github/workflows/_poshqc.yml` in the `poshqc-linux-hooks` job only (conditional:
  only when P4-T3 recorded a failure outside `Test PowerShell hook suites`; otherwise record
  `P4-T5: NOT REQUIRED` in the P4-T3 artifact and mark this task done). The fix is limited to the
  `poshqc-linux-hooks` job, and the R1 invariants must still hold. Then re-run P3-T2, P3-T3, P3-T4,
  P4-T1, P4-T2, and P4-T3 into new timestamped artifacts. Acceptance: the re-run P4-T3 acceptance
  holds. When the failing step cannot be fixed inside that job (for example a runner-image defect),
  record the diagnostic and stop the plan (BLOCKED, returned to the orchestrator).

### Phase 5 — Portable Codex Hook-Suite Fixes

- [ ] [P5-T1] Fix `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1` (S1 and S1b) by
  replacing both occurrences of `$arguments | Should -Contain 'windows.sandbox="elevated"'` with the
  reference block R9 line, keeping each line's indentation. Acceptance:
  `grep -c -F 'windows.sandbox="elevated"' tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1`
  prints `2`;
  `grep -F 'windows.sandbox="elevated"' tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | grep -c -F 'Should -Be $IsWindows'`
  prints `2`; `wc -l` of the file equals its P0-T21 count (AC-8).
- [ ] [P5-T2] Fix `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` (S1c) by
  replacing the one occurrence of `$arguments | Should -Contain 'windows.sandbox="elevated"'` with
  the reference block R9 line, keeping its indentation. Acceptance:
  `grep -F 'windows.sandbox="elevated"' tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | grep -c -F 'Should -Be $IsWindows'`
  prints `1`; `grep -c -F 'windows.sandbox="elevated"' tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1`
  prints `1`; `wc -l` of the file equals its P0-T21 count.
- [ ] [P5-T3] Fix `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`
  (S2, S3, S4) with reference block R10 parts (a), (b), and (c). Acceptance:
  `grep -c -F -e 'C:/repo' -e 'C:/elsewhere' -e 'C:/nonexistent' tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`
  prints `3` (the three `if ($IsWindows)` definition lines);
  `grep -c -F 'if ($IsWindows)' tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`
  prints `3`; `grep -c -F 'IsPathRooted' tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`
  prints `1` (the corrected premise comment, AC-9); `wc -l` of the file is at most 500.
- [ ] [P5-T4] Fix `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1` for every further
  inventory row that P4-T4 assigned to `P5-T4` (conditional: when there is no such row, record
  `P5-T4: NO ROWS` in the P4-T4 inventory and mark this task done). Each fix is portable: an
  OS-derived synthetic root (the R10 pattern), or an assertion of the host's actual behavior (the
  R9 pattern), or a `-Skip:(-not $IsWindows)` case paired with a `-Skip:$IsWindows` counterpart that
  asserts the non-Windows behavior the production code defines. No unconditional skip is added.
  Acceptance: each row's fix (old text and new text) is recorded in the inventory's
  `Fix` column; `wc -l` of the file is at most 500. A row that cannot be fixed within 500 lines is
  re-marked `REMEDIATION-REQUIRED`.
- [ ] [P5-T5] Fix `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` for every further
  inventory row that P4-T4 assigned to `P5-T5` (conditional: when there is no such row, record
  `P5-T5: NO ROWS` and mark this task done), under the same rules as P5-T4. The file is 495 lines at
  authoring, so a fix that adds lines beyond the 500-line cap is not applied, and its row is
  re-marked `REMEDIATION-REQUIRED`. Acceptance: each applied fix is recorded in the inventory's
  `Fix` column; `wc -l` of the file is at most 500.
- [ ] [P5-T6] Fix `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`
  for every further inventory row that P4-T4 assigned to `P5-T6` (conditional: when there is no
  such row, record `P5-T6: NO ROWS` and mark this task done), under the same rules as P5-T4.
  Acceptance: each fix is recorded in the inventory's `Fix` column; `wc -l` of the file is at most 500.
- [ ] [P5-T7] Record the remediation-required set in `<FEATURE>/evidence/qa-gates/linux-remediation-required.<ts>.md`:
  list every inventory row marked `REMEDIATION-REQUIRED` with its file and testcase, or the line
  `REMEDIATION-REQUIRED: NONE`. Acceptance: the artifact exists, and its row count equals the
  number of `REMEDIATION-REQUIRED` rows in the inventory. A non-empty set leaves AC-6 and AC-10
  unchecked, sets the plan outcome to REMEDIATION-REQUIRED (not PASS), and the plan continues so
  that the remaining acceptance criteria are still evaluated. No file outside the
  `Files written by this plan` list is edited.
- [ ] [P5-T8] Windows pass run of the modified Codex suites into
  `<FEATURE>/evidence/regression-testing/pass-after-codex-windows.<ts>.md`: run
  `pwsh -NoProfile -File <session-scratchpad>/ps-pester-targeted.ps1 -PathList tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1,tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1,tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`.
  Acceptance: `EXIT_CODE: 0`; `FAILED-COUNT: 0`; the passed count is at least the P0-T14 passed
  count; each of the five test names listed in P0-T14 has a `[+]` line.

### Phase 6 — Planner Guidance in `atomic-plan-contract`

- [ ] [P6-T1] Update `.claude/skills/atomic-plan-contract/SKILL.md` by inserting the two bullets of
  reference block R11 immediately after the bullet that begins
  `- **Check that the task-ordering does not make the condition unsatisfiable.**`. Acceptance: the
  two new lines are the last two bullets of the "Wrap-Tolerant Assertion Authoring (Mandatory)"
  section; no other line of the file changes (`git diff --numstat <MERGE_BASE> -- .claude/skills/atomic-plan-contract/SKILL.md`
  prints `2	0`).
- [ ] [P6-T2] Update `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`
  as a byte copy: run
  `cp .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`.
  Acceptance: `cmp .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`
  exits 0 with no output.
- [ ] [P6-T3] Verify the bullet content and placement in `.claude/skills/atomic-plan-contract/SKILL.md`
  into `<FEATURE>/evidence/qa-gates/skill-guidance.<ts>.md`: write SP11 into `<session-scratchpad>`
  and run `sh <session-scratchpad>/skill-bullet-tokens.sh .claude/skills/atomic-plan-contract/SKILL.md`;
  then run
  `grep -n -F -e '## Wrap-Tolerant Assertion Authoring (Mandatory)' -e '**Name the runner and job for a Pester acceptance criterion.**' -e '**Do not assert a fixed-string search literal that contains a backslash.**' -e '## Plan-Path Continuity Contract (Mandatory)' .claude/skills/atomic-plan-contract/SKILL.md`.
  Acceptance: both `BULLET:` lines report `lines=1`; every line begins `TOKEN-PRESENT:` and no
  line begins `TOKEN-MISSING:` (AC-17, AC-18); the `grep -n` output prints four lines, in that
  order, with ascending line numbers, so both bullets lie inside the section.
- [ ] [P6-T4] Verify skill-mirror byte identity for `extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`
  (AC-19): run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
  into `<FEATURE>/evidence/qa-gates/pytest-claude-resource-contracts.<ts>.md`, and
  `sha256sum .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`
  into `<FEATURE>/evidence/qa-gates/skill-hashes.<ts>.md`. Acceptance: pytest exits 0 with zero
  `failed` in its summary and a passed count at least the P0-T20 passed count; the two hashes are
  equal to each other and differ from the P0-T20 hash. When the only failure is
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts` and its message contains
  `Repo file missing from bundle:` and `batch-budget`, record `KNOWN-ISSUE-510` with the output of
  `git status --porcelain --ignored -- .claude/state`; byte identity is then evidenced by the equal
  sha256 values (P6-T4) and `cmp` exit 0, and the loop does not restart for that failure.

### Phase 7 — Final QC Loop, CI Verification, Scope Verification, and Acceptance Check-off

Loop rule. P7-T1 through P7-T11 are one pass of the local toolchain loop: PowerShell format,
analyze, and test; bash format, lint, syntax, and test; workflow lint; and the Python parity test.
If any step fails, or any step or remediation changes a file, fix the cause and restart at P7-T1.
Artifacts from an abandoned pass are kept, and each new pass writes new timestamped artifacts. If
the CI run (P7-T16 to P7-T20) fails in a check this plan owns, fix the cause in a file this plan
may write, restart at P7-T1, and repeat P7-T12 through P7-T21. Exception: a failed test that is in
the matching baseline failure set (P0-T12, P0-T18, P0-T23, or P0-T24) does not restart the loop. It
is recorded as `PRE-EXISTING-FAILURE: <names>`, the acceptance criterion it touches is left
unchecked, and the plan outcome is not PASS. A Linux failure in a file marked
`REMEDIATION-REQUIRED` by P5-T7 does not restart the loop either; it is covered by the remediation
cycle. When a restart changes `.github/workflows/_poshqc.yml`, P3-T2 and P3-T4 are re-run into new
timestamped artifacts before P7-T15. A fix applied under P7-T12 changes a file and restarts the
loop at P7-T1.

- [ ] [P7-T1] QC step 1 (PowerShell format) for the PowerShell files in scope, into
  `<FEATURE>/evidence/qa-gates/qc-ps-format.<ts>.md`. First run `git status --porcelain` as the
  pre-pass observation. Run SP1 (check mode, writes nothing):
  `pwsh -NoProfile -File <session-scratchpad>/ps-format-check.ps1`, then re-run
  `git status --porcelain`. Acceptance (success-case observation): exit 0; no line beginning
  `Formatted: ` ends with the file name `PoshQcWorkflow.Tests.ps1`,
  `epic-child-launch-hardening.Tests.ps1`, `epic-child-worktree-launcher.Tests.ps1`, or
  `enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1` (SP1 prints absolute paths with
  backslash separators, so the match is on the file name alone; each name is unique in the
  repository); the `Formatted: ` set, normalized as in P0-T10, equals the P0-T10 set after every P0-T10 entry ending with one of those four file names is removed; the post-pass
  porcelain listing equals the pre-pass listing. A `Formatted: ` line ending with one of those four
  file names is a failure; the file is corrected
  under the loop rule and the loop restarts at P7-T1.
- [ ] [P7-T2] QC step 2 (PowerShell analyze) for the PowerShell files in scope, into
  `<FEATURE>/evidence/qa-gates/qc-ps-analyze.<ts>.md`: run
  `pwsh -NoProfile -File <session-scratchpad>/ps-analyze.ps1`. The reduced baseline set is the
  P0-T11 baseline finding set after every P0-T11 row naming one of the four file names listed in
  P7-T1 is removed (matched on the file name alone, because the table's script column is not
  expected to carry the directory); when P0-T11 recorded the `PSScriptAnalyzer passed: no findings under`
  line, the reduced baseline set is empty. Acceptance when the reduced baseline set is empty: the
  artifact carries `ExpectedExitCode: 0`, the observed `EXIT_CODE:` is 0, and the output contains
  the line that begins `PSScriptAnalyzer passed: no findings under` (`PoshQC.Analyzer.psm1:185`
  prints it only when no finding remains). Acceptance when the reduced baseline set is non-empty:
  the artifact carries `ExpectedExitCode:` equal to the P0-T11 `EXIT_CODE:` value, the observed
  `EXIT_CODE:` equals that value, the issue count in the thrown `PSScriptAnalyzer reported` message
  (`PoshQC.Analyzer.psm1:183`) equals the P0-T11 count minus the number of rows removed to form the
  reduced baseline set, and the findings table matches the reduced baseline set exactly, so it
  contains no row naming any of the four file names.
- [ ] [P7-T3] QC step 3 (PowerShell test with coverage; type checking does not apply) for the
  PowerShell suites in scope, into `<FEATURE>/evidence/qa-gates/qc-ps-pester-full.<ts>.md`: run
  `pwsh -NoProfile -File <session-scratchpad>/ps-test-full.ps1`, then
  `pwsh -NoProfile -File <session-scratchpad>/ps-junit-summary.ps1 -Path artifacts/pester/pester-junit.xml`,
  then `pwsh -NoProfile -File <session-scratchpad>/ps-line-coverage.ps1`, each with its own pair.
  Acceptance: the `Tests Passed:` line reports `Failed: 0`, or the failed set is a subset of the
  P0-T12 local baseline failure set; the `SUITE:` lines for `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`
  (`tests=7`) and the three modified Codex suites show `failures=0` and `errors=0`; the
  `PS-LINE-COVERAGE:` percent is at least 85.00 and at least the P0-T13 baseline percent (AC-21).
- [ ] [P7-T4] QC step 4 (bash format check) for `scripts/bash/shell_qc_lib.sh` and `scripts/bash/kcov_trace_env.sh`,
  into `<FEATURE>/evidence/qa-gates/qc-bash-format.<ts>.md`. Before the check, run
  `git status --porcelain -- scripts/ tools/ .claude/lib/bash/ .claude/skills/` and
  `sha256sum scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh` as the pre-pass
  observation. Run `shfmt -d scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh` (diff
  mode, writes nothing). Then re-run both observation commands. Acceptance: the shfmt run prints
  nothing and exits 0; the post-pass porcelain listing and the post-pass hashes are unchanged from
  the pre-pass observation. A printed diff is a failure; the file is corrected under the loop rule.
- [ ] [P7-T5] QC step 5 (bash lint) via `scripts/bash/shell-qc.sh` into
  `<FEATURE>/evidence/qa-gates/qc-bash-check.<ts>.md`: run `sh scripts/bash/shell-qc.sh check`.
  Acceptance: no diagnostic line names `scripts/bash/shell_qc_lib.sh` or `scripts/bash/kcov_trace_env.sh`.
  The reduced drift set is the P0-T15 diagnostic record with two kinds of block removed: every
  shfmt diff block whose `---` or `+++` header names `scripts/bash/shell_qc_lib.sh`, and every
  shellcheck finding block whose `In ` header names that file. When P0-T15 recorded
  `LOCAL-DRIFT: NONE`, the reduced drift set is empty. When the reduced drift set is empty, the
  artifact carries `ExpectedExitCode: 0`, and the run prints nothing and exits 0 (AC-11). When it
  is non-empty, the artifact carries `ExpectedExitCode:` equal to the P0-T15 `EXIT_CODE:` value,
  the observed `EXIT_CODE:` equals that value, and every printed diagnostic line is present in the
  reduced drift set. The shfmt diff leg of this run is the
  AC-21 bash format evidence; `shell-qc.sh format` is the write form of the same shfmt pass
  (`scripts/bash/shell_qc_lib.sh:188` runs `-d`, `:222` runs `-w`, over the same discovered file
  list) and is not run.
- [ ] [P7-T6] QC step 6 (targeted bash lint and format check) on `scripts/bash/shell_qc_lib.sh` and
  `scripts/bash/kcov_trace_env.sh` into `<FEATURE>/evidence/qa-gates/qc-bash-targeted.<ts>.md`: run
  `shellcheck -f gcc scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh` and
  `shfmt -d scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh`. Acceptance: both exit 0
  with no output. The only suppression allowed is the R6b directive, when P2-T3 applied it.
- [ ] [P7-T7] QC step 7 (bash syntax; bash has no type checker) on `scripts/bash/shell_qc_lib.sh` and
  `scripts/bash/kcov_trace_env.sh` into `<FEATURE>/evidence/qa-gates/qc-bash-syntax.<ts>.md`: run
  `sh -n scripts/bash/shell_qc_lib.sh` and `sh -n scripts/bash/kcov_trace_env.sh`. Acceptance: both
  exit 0 with no output.
- [ ] [P7-T8] QC step 8 (bash tests, named suites) on `tests/shell/test_shell_qc_commands.bats` and
  `tests/shell/test_shell_qc_discovery.bats` into `<FEATURE>/evidence/qa-gates/qc-bats-shell-qc.<ts>.md`:
  run `npx --yes bats tests/shell/test_shell_qc_commands.bats tests/shell/test_shell_qc_discovery.bats`.
  Acceptance: the lines for the three R5 tests,
  `test prints the exact bats-missing skip marker and exits 0`, and
  `test prints the exact no-test-directory skip marker and exits 0` begin `ok ` (AC-13, AC-14, and
  the AC-15 skip-marker part); the `not ok` set is a subset of the P0-T18 baseline failure set (when
  that set is empty, `EXIT_CODE: 0` and zero `not ok` lines).
- [ ] [P7-T9] QC step 9 (workflow lint) on `.github/workflows/_poshqc.yml` into
  `<FEATURE>/evidence/qa-gates/qc-actionlint.<ts>.md`: run
  `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml`.
  Acceptance: `EXIT_CODE: 0`, and the output contains the line `Running actionlint...` and no line
  containing `actionlint exited with code` (AC-5). The wrapper discards actionlint's stdout
  (`scripts/dev-tools/run-actionlint.ps1:128`), so on a non-zero exit the task also runs
  `actionlint .github/workflows/_poshqc.yml` (on PATH per P0-T7; `tools/actionlint/bin/actionlint.exe`
  when P0-T7 recorded `ACTIONLINT-ON-PATH: NO`) into the same artifact to record the findings.
- [ ] [P7-T10] QC step 10 (Python parity test) for `.claude/skills/atomic-plan-contract/SKILL.md`
  and its mirror, into `<FEATURE>/evidence/qa-gates/qc-pytest-claude-resource-contracts.<ts>.md`: run
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
  Acceptance: exit 0 with zero `failed` in the summary (AC-19). When the only failure is
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts` and its message contains
  `Repo file missing from bundle:` and `batch-budget`, record `KNOWN-ISSUE-510` with the output of
  `git status --porcelain --ignored -- .claude/state`; byte identity is then evidenced by the equal
  sha256 values (P6-T4) and `cmp` exit 0, and the loop does not restart for that failure. In the
  KNOWN-ISSUE-510 branch the artifact keeps its observed `EXIT_CODE:`, adds no `ExpectedExitCode:`
  field, and cites issue #510; this step counts as passed for P7-T11, and the pytest part of AC-21
  is evidenced by P7-T17.
- [ ] [P7-T11] Record the clean loop pass in `<FEATURE>/evidence/qa-gates/qc-loop-pass.<ts>.md`: the
  pass number, the artifact paths of P7-T1 through P7-T10 of that pass, and the output of
  `sha256sum .github/workflows/_poshqc.yml scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh tests/shell/test_shell_qc_commands.bats tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 .claude/skills/atomic-plan-contract/SKILL.md`,
  run immediately after P7-T10. Acceptance: all ten steps passed in the same pass (P7-T10 counts as passed
  when it recorded KNOWN-ISSUE-510) without changing
  a file; the two bash hashes equal the P7-T4 post-pass hashes of that pass.
- [ ] [P7-T12] Full local `shell-qc.sh test` run with the simulation active, for `scripts/bash/shell-qc.sh`
  (AC-15), into `<FEATURE>/evidence/qa-gates/qc-shell-qc-test-full.<ts>.md`: run
  `sh <session-scratchpad>/shell-qc-test-local.sh <BATS_DIRECT>` in the background, with output
  captured to `<session-scratchpad>/shell-qc-test-final.log`, and record after it exits. Acceptance:
  the `SHELL_QC_TEST_EXIT=` value, the `RUN_START=` and `RUN_END=` values, the derived wall time and
  its difference from the P0-T24 wall time (recorded, not gated), the TAP `1..N` line, and every
  `not ok` name are recorded. The `not ok` set is a subset of the P0-T24 local full baseline
  failure set, and the three R5 tests are `ok`. A test that is `ok` in P0-T24 and `not ok` here is a
  kcov-class defect exposed by the simulation. It is recorded as `SIMULATION-EXPOSED: <name>`, and
  the plan outcome is REMEDIATION-REQUIRED for that test file. Only files in the
  `Files written by this plan` list may be fixed here. When P0-T8 recorded `BATS-DIRECT: UNAVAILABLE`,
  record `LOCAL-FULL-RUN: UNAVAILABLE`; the AC-15 evidence is then the P7-T20 CI job
  `shell-coverage / Shell Coverage (Bats + kcov)`.
- [ ] [P7-T13] Verify line counts for every file this plan modifies or creates (AC-22) into
  `<FEATURE>/evidence/qa-gates/line-counts.<ts>.md`: run
  `wc -l .github/workflows/_poshqc.yml scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh tests/shell/test_shell_qc_commands.bats tests/fixtures/shell_qc/kcov_trace/nounset_lib.sh tests/fixtures/shell_qc/stub-bin/bats-nounset-source tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`.
  Acceptance: every listed file is at most 500 lines. The SKILL.md copies are Markdown and exempt.
- [ ] [P7-T14] Verify that the new and modified tests in `tests/` create no temporary files (AC-22)
  into `<FEATURE>/evidence/qa-gates/no-temp-files.<ts>.md` with `ExpectedExitCode: 1`, holding
  only the command
  `git diff -U0 <MERGE_BASE> -- tests/ | grep -c -E '^\+.*(mktemp|BATS_TEST_TMPDIR|BATS_TMPDIR|BATS_FILE_TMPDIR|New-TemporaryFile|GetTempFileName|GetTempPath|TestDrive)'`.
  Separately, run `git status --porcelain -- tests/` into
  `<FEATURE>/evidence/qa-gates/no-temp-files-status.<ts>.md` (no expectation field), which also
  records a code-review statement that the R1, R3, R4, and R5 content writes nothing to disk.
  Acceptance: the count prints `0` and exits 1. The porcelain listing shows no untracked path under
  `tests/` (every new test and fixture file was committed by P4-T1), so the diff covers all of them.
- [ ] [P7-T15] Commit and push the final state of `bug/ci-gaps-linux-pester-and-kcov-set-u-743`: run
  `git add --` and `git commit -F <message file> --` with the paths `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 .claude/skills/atomic-plan-contract/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md .github/workflows/_poshqc.yml scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh tests/shell/test_shell_qc_commands.bats tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 tests/fixtures/shell_qc/kcov_trace/ tests/fixtures/shell_qc/stub-bin/bats-nounset-source tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/`
  (paths without changes are accepted by the pathspec), then `git rev-parse HEAD` (CI_SHA),
  `git status --porcelain -- scripts/ tests/ .github/ .claude/skills/ extensions/`,
  `git push origin bug/ci-gaps-linux-pester-and-kcov-set-u-743`, and
  `git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743`. Record all pairs in
  `<FEATURE>/evidence/other/commit-push-final.<ts>.md`. Acceptance: every command exits 0; the
  porcelain status prints nothing; the remote head equals CI_SHA. If the preimplementation gate
  refuses a command, record the refusal text and stop (BLOCKED).
- [ ] [P7-T16] Dispatch the final verification run of `.github/workflows/ci.yml` on CI_SHA: record
  the dispatch time (UTC), run `gh workflow run ci.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743`,
  and repeat
  `gh run list --workflow=ci.yml --branch bug/ci-gaps-linux-pester-and-kcov-set-u-743 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt`
  until it returns a run created after the dispatch time; its `databaseId` is `<RUN_ID>` for
  P7-T17 to P7-T20. Start `gh run watch <RUN_ID>` in the background. Record the pairs in
  `<FEATURE>/evidence/qa-gates/ci-final-run.<ts>.md`. Acceptance: the run's `headSha` equals CI_SHA.
- [ ] [P7-T17] Record the final check conclusions for `.github/workflows/_poshqc.yml` and
  `.github/workflows/_shell-coverage.yml` after the watch finishes, into
  `<FEATURE>/evidence/qa-gates/ci-final-conclusions.<ts>.md`: run `gh run view <RUN_ID> --json jobs,headSha`.
  Acceptance: `headSha` equals CI_SHA and equals the P7-T15 remote head. The jobs named
  `poshqc / PowerShell hook suites (Linux)` (AC-6), `poshqc / PowerShell QC` (AC-7), and
  `shell-coverage / Shell Coverage (Bats + kcov)` (AC-16) each have conclusion `success`, and their
  job `databaseId` values are recorded. The conclusions of jobs owned by other items are recorded
  but not asserted. A `failure` in the Linux job whose failed tests are all in files marked
  `REMEDIATION-REQUIRED` leaves AC-6 unchecked, and the outcome remains REMEDIATION-REQUIRED.
  When P7-T10 recorded KNOWN-ISSUE-510, also run `gh run view <RUN_ID> --log --job <JOB_ID>`, using
  the `databaseId` of the job `quality-checks7 / Code Quality & Tests (3.12)` as `<JOB_ID>`,
  filtered by `grep -F 'test_push_down_claude_resource_contracts.py'`, into
  `<FEATURE>/evidence/qa-gates/ci-final-parity-pytest.<ts>.md`. Acceptance for that artifact: at
  least one line is printed, and no printed line contains `FAILED` or `ERROR`. When no line is
  printed, the AC-21 pytest part is remediation-required.
- [ ] [P7-T18] Verify the Linux hook-suite results of `.github/workflows/_poshqc.yml` (AC-6, AC-8,
  AC-9, AC-10) into `<FEATURE>/evidence/qa-gates/ci-final-linux.<ts>.md`: run
  `gh run view <RUN_ID> --log --job <JOB_ID>` (the Linux job) filtered by `grep -F 'Tests Passed:'`,
  then `gh run download <RUN_ID> --name poshqc-linux-hook-test-results --dir <session-scratchpad>/linux-final-743`
  and `pwsh -NoProfile -File <session-scratchpad>/ps-junit-summary.ps1 -Path <session-scratchpad>/linux-final-743/pester-junit-linux-hooks.xml`.
  Acceptance: the `Tests Passed:` line reports `Failed: 0`; `JUNIT-ROOT:` reports `failures=0` and
  `errors=0`; no `FAIL:` line is printed; the `SUITE:` lines for the three modified Codex suites show
  `failures=0`. Every P4-T4 inventory row is absent from the `FAIL:` output.
- [ ] [P7-T19] Verify the Windows results of `.github/workflows/_poshqc.yml` (AC-7) into
  `<FEATURE>/evidence/qa-gates/ci-final-windows.<ts>.md`: run
  `gh run view <RUN_ID> --log --job <JOB_ID>` (the `poshqc / PowerShell QC` job) filtered by
  `grep -F 'Tests Passed:'`, then `gh run download <RUN_ID> --name poshqc-test-results --dir <session-scratchpad>/windows-final-743`
  and `pwsh -NoProfile -File <session-scratchpad>/ps-junit-summary.ps1 -Path <session-scratchpad>/windows-final-743/pester-junit.xml`.
  Acceptance: `Failed: 0` in the `Tests Passed:` line; no `FAIL:` line; the `SUITE:` lines for
  `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` and the three modified Codex suites show
  `failures=0` and `errors=0`.
- [ ] [P7-T20] Verify the kcov results of `.github/workflows/_shell-coverage.yml` (AC-16, and AC-15
  when P0-T8 recorded `BATS-DIRECT: UNAVAILABLE`) into `<FEATURE>/evidence/qa-gates/ci-final-shell-coverage.<ts>.md`:
  run `gh run view <RUN_ID> --log --job <JOB_ID>` (the `shell-coverage / Shell Coverage (Bats + kcov)` job)
  filtered by `grep -F 'Bash coverage (lines):'`, by `grep -E ' not ok [0-9]+ '`, and by
  `grep -F -e 'test fails when a bats child sources a nounset library inside bash -c' -e 'test passes when a bats child resets nounset after sourcing' -e 'kcov_trace_env.sh sets the kcov PS4 format'`;
  then `gh run download <RUN_ID> --name shell-coverage --dir <session-scratchpad>/kcov-final-743`;
  write SP10 into `<session-scratchpad>` and run
  `sh <session-scratchpad>/kcov-changed-lines.sh <session-scratchpad>/kcov-final-743/cov.xml <MERGE_BASE>`
  (use `kcov-merged/cov.xml` when the root copy is absent); finally run
  `git diff --exit-code <MERGE_BASE> -- .github/workflows/_shell-coverage.yml`. Acceptance: the
  numeric `Bash coverage (lines): NN.N%` headline is recorded and is at least `85.0`; the `not ok`
  set is a subset of the P0-T23 CI bats baseline failure set; each of the three R5 tests has an
  `ok` TAP line. Every `LINE:` record is either `hits=` with a value greater than 0 or
  `NOT-INSTRUMENTED` (a comment or blank line), and at least one `LINE:` record with `hits=` exists
  for each of the two files. The `git diff --exit-code` exits 0 with no output (`_shell-coverage.yml`
  unchanged).
- [ ] [P7-T21] Close the AC-10 inventory `<FEATURE>/evidence/qa-gates/linux-first-run-failures.<ts>.md`
  (a new timestamped copy of the P4-T4 artifact, with a `Final status` column; the inventory copy
  carries no expectation field), and record
  `git diff -U0 <MERGE_BASE> -- tests/scripts/codex-hooks/ tests/scripts/claude-hooks/ | grep -c -E '^\+.*-Skip([[:space:]]|$|:\$true)'`
  in its own artifact `<FEATURE>/evidence/qa-gates/no-unconditional-skip.<ts>.md` with
  `ExpectedExitCode: 1`. Acceptance: every row's `Final status` is `PASSING IN P7-T18` (with its
  fix and the fixing task) or `REMEDIATION-REQUIRED`; the skip count prints `0` and exits 1, so no
  unconditional skip was added (AC-10).
- [ ] [P7-T22] Scope verification (AC-20) into `<FEATURE>/evidence/qa-gates/scope-check.<ts>.md`: run
  `git diff --name-only <MERGE_BASE>`, `git status --porcelain`, and, in its own artifact
  `<FEATURE>/evidence/qa-gates/scope-forbidden-paths.<ts>.md` with `ExpectedExitCode: 1`,
  `git diff --name-only <MERGE_BASE> | grep -c -E '^(\.github/workflows/(_quality-checks|_drm-copilot-extension-tests|ci|_shell-coverage)\.yml|scripts/powershell/PoshQC/settings/pester\.runsettings\.psd1|\.claude/rules/|\.github/instructions/)'`.
  Acceptance: the forbidden-path count prints `0` and exits 1. Every path in the name listing is in
  the `Files written by this plan` list or under `<FEATURE>/`. The porcelain listing shows no path
  outside that list, except `tools/actionlint/` when P0-T7 recorded `ACTIONLINT-ON-PATH: NO`.
- [ ] [P7-T23] Write the coverage comparison `<FEATURE>/evidence/qa-gates/coverage-comparison.<ts>.md`:
  PowerShell baseline (P0-T13) and post-change (P7-T3) `covered`, `missed`, and `percent`; bash
  baseline (P0-T23) and post-change (P7-T20) headline percentages; the P0-T23 and P7-T20
  `line-rate` values for `scripts/bash/shell_qc_lib.sh`; and the P7-T20 changed-line `LINE:` records
  for both bash files. Acceptance: every value is numeric; the PowerShell post-change percent is at
  least 85.00 and at least the baseline; the bash post-change headline is at least 85.0; no
  changed, instrumented bash line has `hits=0`. A missing value makes the outcome
  remediation-required, not PASS.
- [ ] [P7-T24] Update `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md`
  by checking off each of AC-1 through AC-22 whose evidence artifacts above satisfy it, and nothing
  else. Acceptance: each checked item cites its evidence artifact path in the P7-T25 index. An AC
  whose evidence is missing, failed, or remediation-required stays unchecked; that applies to AC-6
  and AC-10 when P5-T7 listed any row, and to AC-15 when P7-T12 recorded `SIMULATION-EXPOSED`.
  When KNOWN-ISSUE-510 was recorded, AC-19 is evidenced by the P6-T4 equal sha256 values and the
  P6-T2 `cmp` exit 0, and the pytest part of AC-21 by `ci-final-parity-pytest.<ts>.md`; the P7-T25
  index cites issue #510 on both lines.
- [ ] [P7-T25] Write the evidence index `<FEATURE>/evidence/other/ac-evidence-index.<ts>.md`: one
  line per AC-1 through AC-22 naming its satisfying artifact paths and status (`PASS`,
  `REMEDIATION-REQUIRED`, or `PRE-EXISTING-FAILURE`), and the plan outcome (`PASS` only when all
  twenty-two are `PASS`). Then run `git diff --name-only <CI_SHA>` and `git status --porcelain`
  into `<FEATURE>/evidence/other/post-ci-scope.<ts>.md`. Acceptance: twenty-two AC lines and one
  outcome line exist, and the checked state of every AC in `spec.md` matches its status here; every
  path either command lists is under `<FEATURE>/` (the porcelain listing may also show
  `tools/actionlint/` when P0-T7 recorded `ACTIONLINT-ON-PATH: NO`, as in P7-T22); the post-ci-scope artifact states that these
  files are committed by the commit/PR stage in a commit restricted to `<FEATURE>/`, and that
  CI_SHA identifies the code verified in P7-T17 to P7-T20.

## Execution Deviations

Authority: binding operator decision of 2026-10-01 (Option A). No `pwsh` process is run in this execution, in any form. PowerShell format, analyze and Pester run only through the PoshQC MCP tools (`mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`) with `workspace_root` set to the item worktree. Those tools return only an `ok` flag and a summary composed before the child runs; no count, test name, or coverage value is read from them. Where a task asserts Pester output, the evidence is the CI `_poshqc.yml` run on the pushed head, read from the job log and from the downloaded JUnit and coverage XML by a Python helper in `<session-scratchpad>` that prints the SP5/SP7 line shapes (`JUNIT-ROOT:`, `SUITE:`, `FAIL:`, `PS-LINE-COVERAGE:`). Helper scripts SP1 and SP3 to SP7 are not written or run as PowerShell.

| ID | Tasks | Deviation |
| --- | --- | --- |
| D1 | P0-T7 | The three `pwsh -Command` probes are not run. The PowerShell and Pester versions come from the CI `PowerShell QC` job log of the P0-T22 baseline run; the actionlint probe is `command -v actionlint`. |
| D2 | P0-T10, P7-T1 | `mcp__drm-copilot__run_poshqc_format` replaces SP1, with `git status --porcelain` before and after. The `Formatted:` and `Already formatted:` counts are unavailable; the equal before/after listing is the observation, plus the CI `Format PowerShell` step conclusion of the corresponding run. |
| D3 | P0-T11, P7-T2 | `mcp__drm-copilot__run_poshqc_analyze` replaces SP3 and its `ok` flag is recorded; the finding set comes from the CI `Analyze PowerShell` step of the corresponding run. |
| D4 | P0-T12, P7-T3 (test part) | The CI `PowerShell QC` job `Tests Passed:` log line and the JUnit from the `poshqc-test-results` artifact replace SP4/SP7; `mcp__drm-copilot__run_poshqc_test` is also run and its `ok` flag recorded. |
| D5 | P0-T13, P7-T3 (coverage part) | The report-level `LINE` counter of `powershell-coverage.xml` from the CI `poshqc-test-results` artifact replaces SP5. |
| D6 | P0-T14 | Per-testcase results of the three Codex suites come from the CI JUnit; the five named tests must appear as passing testcases. |
| D7 | P1-T2 | Fail-before is evidenced by the CI `PowerShell QC` JUnit for `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` on the Phase 1 boundary push (a `workflow_dispatch` of `_poshqc.yml`), plus `mcp__drm-copilot__run_poshqc_test` with `scan_folders` `["tests/scripts/workflows"]`. |
| D8 | P3-T2 | Pass-after is evidenced by the CI `PowerShell QC` JUnit for `PoshQcWorkflow.Tests.ps1` on the P4-T1 push / P4-T2 run, plus `mcp__drm-copilot__run_poshqc_test`. |
| D9 | P4-T3, P7-T18, P7-T19 | The SP7 summary is produced by the Python JUnit helper. |
| D10 | P5-T8 | The CI `PowerShell QC` JUnit for the three modified Codex suites on the push after Phase 5, plus `mcp__drm-copilot__run_poshqc_test` with `scan_folders` `["tests/scripts/codex-hooks"]`, replaces SP6. |
| D11 | P1-T2 | The `poshqc` job's upload step has no `if: always()`, so CI run 36892883441 (Windows `Test PowerShell` failed as expected) uploaded no `poshqc-test-results` artifact and no JUnit exists. The `poshqc` job may not be modified (AC-4), so the fail-before per-test evidence is the job log: the `Tests Passed:` line and the six `[-]` lines. |
| D12 | P4-T1 | P4-T1's commit is also the Phase 3 boundary commit required by the run constraints; no separate Phase 3 commit is made, so P4-T1's pathspec (which omits the plan file) is used unchanged. Plan check marks for Phases 3 and 4 are committed at the Phase 4 boundary. |

Operator-run blockers (left unchecked; `actionlint` run directly as supplementary evidence only):

| ID | Task | Operator command |
| --- | --- | --- |
| B1 | P0-T19 | `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` |
| B2 | P3-T3 | `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` |
| B3 | P7-T9 | `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` |
