# 2026-08-07-blast-radius-under-reporting-gaps — v2 Regression Cycle (Plan)

- **Issue:** #452
- **Branch:** bug/blast-radius-under-reporting-regression-452
- **Owner:** drmoisan
- **Baseline:** main at beae3f02, re-synchronized with the current main tip in P0-T16
- **Last Updated:** 2026-09-27T12-15
- **Status:** Draft (pending executor preflight, revision 2)
- **Version:** 2.0
- **Work Mode:** full-bug (the v2 spec is the sole acceptance-criteria source; no user-story.md exists)
- **Plan path:** `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/plan.2026-09-27T12-15.md`
- **AC source:** `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md`, section "Acceptance Criteria", 22 items. This plan numbers them AC-1 through AC-22 in source order (AC-1 is the corpus-file item, AC-22 is the "Fixes #452" pull-request-body item).

## Scope Recap

This cycle pins the two issue #452 corrections with one shared, two-direction regression corpus consumed by the Python authority and the PowerShell port, re-verifies both corrections by execution, and closes issue #452.

Files this plan writes (the only non-evidence write targets):

- Create `tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json` (P2-T1).
- Create `tests/scripts/dev_tools/test_blast_radius_regression_452.py` (P3-T1).
- Create `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1` (P4-T1).
- Edit `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md` (acceptance-criteria check-offs only, P9-T1 and P9-T6).
- Edit `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/plan.2026-09-27T12-15.md` (checkbox state only, during execution).
- Evidence artifacts under the v2 evidence tree, named in plain prose below.

Read-only inputs, referenced in plain prose and never written by this plan: the Python blast-radius modules under scripts/dev_tools (compute_blast_radius.py, _blast_radius_conflicts.py, _blast_radius_extraction.py, _blast_radius_glob.py, _blast_radius_validation.py); the PowerShell modules under .claude/lib/blast-radius; the bundled PowerShell copy under extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius; the root configuration config/blast-radius.json; the bundled configuration extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json; every existing test file and every existing file of the blast-radius fixture corpus; the PoshQC module and its runsettings under scripts/powershell/PoshQC; pyproject.toml; the CI workflows under .github/workflows; the v1 documents in the feature root; and the v2 research artifact v2/research/2026-09-27T12-15-blast-radius-regression-corpus-research.md.

## Radius Hygiene (governs how this plan is written)

The parallel scheduler derives this item's blast radius from this plan's text: every inline-code span is split on whitespace and each token is classified as a path. To keep the derived radius equal to the write set above:

- Only the five concrete write targets listed under Scope Recap appear as path tokens inside inline code. Read-only files are named in plain prose.
- Evidence artifact paths are written in plain prose; they fall under this feature folder, which the derivation adds as a feature-folder glob automatically.
- Command spans contain only the write targets, dotted module names, git ref expressions, directory operands (the extractor rejects a wildcard-free token that names no file), and `<scratchpad>` placeholders (the extractor rejects any token carrying a placeholder marker). No command span names a read-only file.
- The corpus plan lines contain inline-code spans around shared root surfaces. Those spans must never appear in this plan, because a harvested root surface would add a shared-surface edge to every item touching it. This plan therefore writes the marker {BT} in place of the backtick character inside the P0-T30 case table, the helper scripts replace {BT} with chr(96) (Python) or [char]0x60 (PowerShell) when they read the table, the corpus author writes the literal backtick into the corpus file (which is not a plan and is never harvested), and plan-line shapes are described in prose as "the path wrapped in a pair of backtick characters".

## Execution Conventions (apply to every task)

- **Evidence location.** The v2 evidence tree is docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/evidence, with the canonical kinds baseline, regression-testing, qa-gates, and other. Filenames below are relative to that tree. Replace <timestamp> with the run time in yyyy-MM-ddTHH-mm form. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; test-step artifacts carry numeric coverage headlines in `Output Summary:`. No evidence is written under the repository artifacts directory. No delegation input supplied a non-canonical evidence path, so no override record is required.
- **No absolute host paths.** Evidence records `<scratchpad>` and `<worktree root>` literally in place of host paths (MCP `workspace_root` values included).
- **Scratchpad.** `<scratchpad>` denotes the executing session's own scratchpad directory, outside the repository. Helper scripts live there, are never committed, and are not tests. Their exact bodies are fixed in this plan so a third party can recreate them. The Python batch-budget hook discards candidate paths outside the worktree root, so scratchpad scripts consume no batch-budget slot; the two new test files are the only budgeted files.
- **Shell route.** The worktree isolation guard refuses any Bash command whose text contains the words for the PowerShell, bash, or WSL executables, or a heredoc. Every PowerShell script therefore runs as `sh <scratchpad>/run-ps.sh <scratchpad>/<script>.ps1 <arguments>`; the runner body (written in P0-T18) invokes PowerShell. Python helper scripts run as `poetry run python <scratchpad>/<script>.py <arguments>`. A multi-line `poetry run python -c` invocation is a silent no-op in this repository and is never used; single-line `-c` invocations are used only where stated. All commands run from the worktree root.
- **Import provenance.** Python helper scripts insert the worktree root at the front of the module search path before importing `scripts.dev_tools`, and the repository's tests/conftest.py (read-only) does the same for pytest, so both exercise this worktree's source. P0-T17 verifies this.
- **Pester evidence derivation (fixed, not left to the executor).** The PoshQC MCP tools return a summary composed before the child process runs and carry no exit code, counts, or findings, and the MCP test tool resolves the installed extension's runsettings rather than the repository copy. Therefore: (a) each MCP call is made as the policy route-compliance step and recorded with `EXIT_CODE: 0` when the call returned and non-zero when it raised; (b) every asserted count, per-test status, and coverage value is read from the JUnit and coverage XML written by the self-hosted PoshQC module, which loads the repository runsettings (scripts/powershell/PoshQC/settings/pester.runsettings.psd1, read-only: Run.Path includes tests/scripts, TestResult writes artifacts/pester/pester-junit.xml, CodeCoverage writes artifacts/pester/powershell-coverage.xml); (c) the helper deletes both XML files before each run so a stale file cannot satisfy a check; (d) a filtered per-test check that matches zero testcases is a FAILURE. Analyzer findings are read from a direct PSScriptAnalyzer count with the repository settings. This governs P0-T25 through P0-T28, P4-T2, P7-T1, P7-T2, and P7-T3.
- **Baseline-relative gating.** Local-only failures can exist because some suites read gitignored orchestration state. For every repository-wide test gate, the final failed-test name set must be a subset of the baseline failed-test name set captured in Phase 0, the final collected count must equal the baseline collected count plus the 26 tests this plan adds per language, and no test added by this plan may fail. For every repository-wide format, lint, or type gate, the final finding set must be a subset of the baseline finding set and must contain no finding in a file this plan writes.
- **Toolchain restart rule.** In Phases 6 and 7, if any step fails or changes a file, fix the cause and restart that language's loop from its first task; record each iteration number in the artifact. A loop is complete only when every step passes in one iteration.
- **Stop-and-return steps.** The execution child does not delegate. Every step that needs a planner revision or pull-request authoring stops at that task and returns to the orchestrator with the stated reason; the orchestrator performs the step and resumes the plan at the task named in that step. P9-T4 defines the pull-request case.
- **Hook denials.** If a PreToolUse hook denies a staging, commit, or push command, record the denial text verbatim in that phase's commit artifact (for P9-T6, which writes no artifact, in the completion report) and return to the orchestrator for the documented workaround. Do not bypass a hook.
- **Commit and push after every phase.** Each phase ends with a commit-and-push task. Commit messages are written to a scratchpad file and committed with `git commit -F`.
- **Linux CI is authoritative for Python; windows-latest is the only CI Pester job.** A local Windows pass does not prove CI. The consumers load everything relative to their own file location, use no Windows-only path, drive letter, or backslash-separated path literal, read no gitignored state, and do not reference origin/main. The Python consumer must import and run on every CI matrix version, Python 3.10 through 3.13 (no syntax newer than 3.10).
- **Merge-order independence with #722.** Every verdict assertion is made on the Python `conflicts(a, b, config)` result or the PowerShell `Test-BlastRadiusConflict` result. No assertion targets cohort scheduling, edge construction, coloring, or tolerance, except in the pre-authorized FOUND branch of P0-T29. Do not assume #722 has or has not merged; P0-T16 and P0-T29 establish it by observation.
- **No bats test** is added by this plan. If one ever becomes necessary it must not source a helper that uses set -u inside bash -c, because that fails only under CI kcov.

## Acceptance Criteria Traceability

AC numbers follow the source order of the v2 spec's Acceptance Criteria section. Evidence names are relative to the v2 evidence tree; each timestamp field is filled at run time.

- AC-1 (corpus file exists and conforms to the contract): tasks P2-T1, P2-T2, P3-T2; evidence regression-testing/phase2-corpus-structure.<timestamp>.md and regression-testing/phase3-python-consumer-run.<timestamp>.md.
- AC-2 (pairing rules, both consumers): tasks P3-T2, P4-T2; evidence regression-testing/phase3-python-consumer-run.<timestamp>.md and regression-testing/phase4-pester-consumer-run.<timestamp>.md.
- AC-3 (both directions per gap, direction consistency): tasks P3-T2, P4-T2; evidence as for AC-2.
- AC-4 (quality-tiers doctrine pin and declared-radius case): tasks P3-T2, P4-T2; evidence as for AC-2.
- AC-5 (plan-line intent rule): tasks P3-T2, P4-T2; evidence as for AC-2.
- AC-6 (Phase 0 Python execution evidence): tasks P0-T30, P0-T31; evidence baseline/phase0-python-runtime-verdicts.<timestamp>.md.
- AC-7 (Phase 0 PowerShell execution evidence and three-way comparison): tasks P0-T32, P0-T33; evidence baseline/phase0-powershell-runtime-verdicts.<timestamp>.md and baseline/phase0-three-way-comparison.<timestamp>.md.
- AC-8 (conditional production correction resolved): tasks P1-T1, P8-T1, drawing on P0-T33 and P0-T34; evidence regression-testing/phase1-correction-resolution.<timestamp>.md, baseline/phase0-bundled-root-surfaces.<timestamp>.md, and qa-gates/final-non-goals-scope-diff.<timestamp>.md.
- AC-9 (Python consumer passes): task P3-T2; evidence regression-testing/phase3-python-consumer-run.<timestamp>.md.
- AC-10 (Python mutation demonstration): task P3-T3; evidence regression-testing/phase3-python-mutation-demonstration.<timestamp>.md.
- AC-11 (Pester consumer passes with the repository runsettings): tasks P4-T2, P7-T3; evidence regression-testing/phase4-pester-consumer-run.<timestamp>.md and qa-gates/final-powershell-pester-coverage.<timestamp>.md.
- AC-12 (Pester mutation demonstration): task P4-T3; evidence regression-testing/phase4-pester-mutation-demonstration.<timestamp>.md.
- AC-13 (bundled-configuration parity in both consumers): tasks P3-T2, P7-T3, P8-T6; evidence qa-gates/final-bundled-parity.<timestamp>.md.
- AC-14 (merge-order independence): task P8-T4; evidence qa-gates/final-merge-order-independence.<timestamp>.md.
- AC-15 (tolerance branch resolved and recorded): tasks P0-T29, P5-T1; evidence baseline/phase0-tolerance-detection.<timestamp>.md and regression-testing/phase5-tolerance-branch.<timestamp>.md.
- AC-16 (loading constraints): task P8-T3; evidence qa-gates/final-loading-constraints.<timestamp>.md.
- AC-17 (non-goals untouched): task P8-T1; evidence qa-gates/final-non-goals-scope-diff.<timestamp>.md.
- AC-18 (500-line limit): task P8-T5; evidence qa-gates/final-line-counts.<timestamp>.md.
- AC-19 (Python toolchain in a single pass): tasks P6-T1 through P6-T8; evidence the qa-gates artifacts named final-python-black, final-python-black-check, final-python-ruff, final-python-pyright, final-python-pytest-coverage, final-python-pytest-targeted-coverage, final-python-consumer-coverage, and final-python-no-new-suppression, plus qa-gates/final-coverage-delta.<timestamp>.md from P8-T2.
- AC-20 (PowerShell toolchain in a single pass): tasks P7-T1 through P7-T3; evidence the qa-gates artifacts named final-powershell-format, final-powershell-analyze, and final-powershell-pester-coverage, plus qa-gates/final-coverage-delta.<timestamp>.md from P8-T2.
- AC-21 (required CI checks green on the pull-request head): tasks P9-T5, P9-T7; evidence qa-gates/final-ci-pr-head.<timestamp>.md, and the final-head results returned in the P9-T7 completion report.
- AC-22 (pull-request body contains "Fixes #452"): task P9-T4; evidence qa-gates/final-pr-body.<timestamp>.md.

---

### Phase 0 — Policy Reads, Branch Sync, Baselines, and Runtime Verification

- [ ] [P0-T1] Read CLAUDE.md at the repository root in full. Acceptance: the file is listed in the P0-T15 artifact.
- [ ] [P0-T2] Read .claude/rules/general-code-change.md in full. Acceptance: listed in the P0-T15 artifact.
- [ ] [P0-T3] Read .claude/rules/general-unit-test.md in full. Acceptance: listed in the P0-T15 artifact.
- [ ] [P0-T4] Read .claude/rules/python.md in full (Python is in scope: the Python consumer). Acceptance: listed in the P0-T15 artifact.
- [ ] [P0-T5] Read .claude/rules/python-suppressions.md in full. Acceptance: listed in the P0-T15 artifact.
- [ ] [P0-T6] Read .claude/rules/powershell.md in full (PowerShell is in scope: the Pester consumer). Acceptance: listed in the P0-T15 artifact. TypeScript policy files are not read, because TypeScript is excluded by the spec; they are read only inside the P1-T1 CORRECTION-REQUIRED branch if that branch names a TypeScript file.
- [ ] [P0-T7] Read .claude/rules/quality-tiers.md in full (referenced by the general code-change policy for the coverage thresholds). Acceptance: listed in the P0-T15 artifact.
- [ ] [P0-T8] Read .claude/rules/tonality.md in full. Acceptance: listed in the P0-T15 artifact.
- [ ] [P0-T9] Read .claude/rules/self-explanatory-code-commenting.md in full (docstring and intent-comment rules for the Python consumer). Acceptance: listed in the P0-T15 artifact.
- [ ] [P0-T10] Read .claude/rules/plan-acceptance-gates.md in full (G1 through G9). Acceptance: listed in the P0-T15 artifact.
- [ ] [P0-T11] Read .claude/rules/parallel-orchestration.md in full, including the "Read-by-mandate classification" doctrine that the doctrine-pin case records. Acceptance: listed in the P0-T15 artifact.
- [ ] [P0-T12] Read the v1 feature-root issue.md of this feature folder in full (read-only background; not edited). Acceptance: listed in the P0-T15 artifact.
- [ ] [P0-T13] Read `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md` in full (the AC source). Acceptance: listed in the P0-T15 artifact.
- [ ] [P0-T14] Read the v2 research artifact v2/research/2026-09-27T12-15-blast-radius-regression-corpus-research.md in full (read-only). Acceptance: listed in the P0-T15 artifact.
- [ ] [P0-T15] Write baseline/phase0-instructions-read.md containing `Timestamp:`, `Policy Order:` (CLAUDE.md, general-code-change, general-unit-test, python, python-suppressions, powershell, then the supplementary reads in P0-T7 through P0-T11), and the explicit list of the 14 files read in P0-T1 through P0-T14. Acceptance: the artifact exists with all three fields and 14 listed files.
- [ ] [P0-T16] Bring the branch up to date with main before any detection or verification. Run `git fetch origin main`, then `git merge --no-edit origin/main`, then `git merge-base --is-ancestor origin/main HEAD`, then `git rev-parse HEAD origin/main`. Acceptance: every command exits 0 (the ancestry check exits 0 only when the current main tip is contained in HEAD); a merge conflict is a stop condition reported to the orchestrator. Record both SHAs and the one-line subject of the current main tip from `git log -1 --format=%s origin/main`. Write baseline/phase0-branch-sync.<timestamp>.md. All later scope diffs use the three-dot form `origin/main...HEAD`, which is anchored to the merge base and stays valid if main advances.
- [ ] [P0-T17] Verify import provenance. Run `poetry run python -c "import pathlib, scripts.dev_tools.compute_blast_radius as m; print('UNDER_CWD=' + str(pathlib.Path(m.__file__).resolve().is_relative_to(pathlib.Path.cwd().resolve())))"` (single line). Acceptance: EXIT_CODE 0 and the output is exactly `UNDER_CWD=True`; `UNDER_CWD=False` is a stop condition (a stale editable install would make every Python result describe another checkout). Write baseline/phase0-import-provenance.<timestamp>.md.
- [ ] [P0-T18] Write the PowerShell-side scratchpad helpers with exactly these bodies, then smoke-test the runner. Files:
      run-ps.sh:
      ```sh
      #!/bin/sh
      set -eu
      pwsh -NoProfile -NonInteractive -File "$@"
      ```
      line-counts.ps1:
      ```powershell
      param([Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)][string[]] $Path)
      foreach ($file in $Path) { Write-Output "$file LineCount=$(@(Get-Content -LiteralPath $file).Count)" }
      ```
      file-hashes.ps1:
      ```powershell
      param([Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)][string[]] $Path)
      foreach ($file in $Path) { Write-Output "$file Hash=$((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash)" }
      ```
      clear-pester-artifacts.ps1:
      ```powershell
      $ErrorActionPreference = 'Stop'
      $repoRoot = (Resolve-Path -LiteralPath '.').Path
      foreach ($name in @('pester-junit.xml', 'powershell-coverage.xml')) {
          $target = Join-Path (Join-Path $repoRoot 'artifacts/pester') $name
          if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target }
          Write-Output "$name PRESENT_AFTER_CLEAR=$(Test-Path -LiteralPath $target)"
      }
      ```
      poshqc-test.ps1 (self-hosted module, so the repository runsettings are used):
      ```powershell
      param([string] $ScanFolder = '')
      $ErrorActionPreference = 'Stop'
      $repoRoot = (Resolve-Path -LiteralPath '.').Path
      foreach ($name in @('pester-junit.xml', 'powershell-coverage.xml')) {
          $target = Join-Path (Join-Path $repoRoot 'artifacts/pester') $name
          if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target }
      }
      Import-Module (Join-Path $repoRoot 'scripts/powershell/PoshQC/PoshQC.psd1') -Force
      if ($ScanFolder) { Invoke-PoshQCTest -Root $repoRoot -ScanFolders @($ScanFolder) } else { Invoke-PoshQCTest -Root $repoRoot }
      ```
      junit-report.ps1:
      ```powershell
      param([string] $NameFilter = '')
      $ErrorActionPreference = 'Stop'
      $junitPath = Join-Path (Resolve-Path -LiteralPath '.').Path 'artifacts/pester/pester-junit.xml'
      if (-not (Test-Path -LiteralPath $junitPath)) { Write-Output 'JUNIT_PRESENT=False'; exit 2 }
      [xml] $junit = Get-Content -LiteralPath $junitPath -Raw
      function Get-CaseStatus([System.Xml.XmlElement] $Case) {
          if ($null -ne $Case.SelectSingleNode('failure') -or $null -ne $Case.SelectSingleNode('error')) { return 'FAIL' }
          if ($null -ne $Case.SelectSingleNode('skipped')) { return 'SKIP' }
          return 'PASS'
      }
      $all = @($junit.SelectNodes('//testcase'))
      $status = @($all | ForEach-Object { Get-CaseStatus $_ })
      Write-Output "ALL total=$($all.Count) pass=$(@($status | Where-Object { $_ -eq 'PASS' }).Count) fail=$(@($status | Where-Object { $_ -eq 'FAIL' }).Count) skip=$(@($status | Where-Object { $_ -eq 'SKIP' }).Count)"
      foreach ($case in $all) { if ((Get-CaseStatus $case) -eq 'FAIL') { Write-Output "FAILED_ANY: $($case.name)" } }
      if ($NameFilter) {
          $matched = @($all | Where-Object { $_.name -like "*$NameFilter*" })
          Write-Output "FILTER matched=$($matched.Count)"
          foreach ($case in $matched) { Write-Output "$(Get-CaseStatus $case) $($case.name)" }
      }
      ```
      coverage-line.ps1:
      ```powershell
      $ErrorActionPreference = 'Stop'
      [xml] $report = Get-Content -LiteralPath (Join-Path (Resolve-Path -LiteralPath '.').Path 'artifacts/pester/powershell-coverage.xml') -Raw
      $line = @($report.report.counter | Where-Object { $_.type -eq 'LINE' })[0]
      $covered = [int] $line.covered
      $missed = [int] $line.missed
      Write-Output ('LINE covered={0} missed={1} percent={2:N2}' -f $covered, $missed, (100.0 * $covered / ($covered + $missed)))
      ```
      pssa-count.ps1:
      ```powershell
      param([Parameter(Mandatory = $true)][string] $Path)
      $ErrorActionPreference = 'Stop'
      $settings = Join-Path (Resolve-Path -LiteralPath '.').Path 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
      $findings = @(Invoke-ScriptAnalyzer -Path $Path -Recurse -Settings $settings -Severity Error, Warning, Information)
      Write-Output "PSSA_FINDINGS=$($findings.Count)"
      foreach ($finding in $findings) { Write-Output "FINDING: $($finding.RuleName) $($finding.ScriptName):$($finding.Line)" }
      ```
      poshqc-format.ps1 (the repository's own formatter entry point, the one the CI format check calls):
      ```powershell
      param([Parameter(Mandatory = $true)][string] $ScanFolder)
      $ErrorActionPreference = 'Stop'
      $repoRoot = (Resolve-Path -LiteralPath '.').Path
      Import-Module (Join-Path $repoRoot 'scripts/powershell/PoshQC/PoshQC.psd1') -Force
      Invoke-PoshQCFormat -Root $repoRoot -ScanFolders @($ScanFolder)
      Write-Output 'SELF_HOSTED_FORMAT_DONE=True'
      ```
      Smoke test: run `sh <scratchpad>/run-ps.sh <scratchpad>/line-counts.ps1 docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/plan.2026-09-27T12-15.md`. Acceptance: EXIT_CODE 0 and exactly one output line ending in `LineCount=` followed by an integer greater than 0, which proves the route executes PowerShell against a repository file. Write baseline/phase0-scratchpad-helpers.<timestamp>.md recording the nine file names under `<scratchpad>` and the smoke-test output. If the guard refuses the smoke-test command, stop at this task and return to the orchestrator for a planner revision, because every PowerShell evidence step depends on this route.
- [ ] [P0-T19] Write the Python-side scratchpad helper coverage_totals.py with exactly this body:
      ```python
      """Print coverage totals for issue #452 evidence (scratchpad only, never committed)."""
      import json
      import pathlib

      report = json.loads((pathlib.Path.cwd() / "artifacts" / "python" / "coverage.json").read_text(encoding="utf-8"))
      totals = report["totals"]
      line_percent = 100.0 * totals["covered_lines"] / totals["num_statements"]
      branch_percent = 100.0 * totals["covered_branches"] / totals["num_branches"]
      print(f"GENERATED_AT={report['meta']['timestamp']}")
      print(f"TOTAL_LINE={totals['covered_lines']}/{totals['num_statements']}={line_percent:.2f}")
      print(f"TOTAL_BRANCH={totals['covered_branches']}/{totals['num_branches']}={branch_percent:.2f}")
      # Report each blast-radius module separately so the targeted delta can be read per file.
      for name, entry in sorted(report["files"].items()):
          if "blast_radius" in name:
              summary = entry["summary"]
              file_line = 100.0 * summary["covered_lines"] / summary["num_statements"] if summary["num_statements"] else 100.0
              file_branch = 100.0 * summary["covered_branches"] / summary["num_branches"] if summary["num_branches"] else 100.0
              print(f"FILE {pathlib.PurePath(name).name} line={file_line:.2f} branch={file_branch:.2f}")
      ```
      Branch coverage is read from the JSON report because the terminal Cover column is a combined statement-plus-branch figure and the BrPart column counts partial branches, not missing ones. Acceptance: the file exists with this body; it is exercised in P0-T23. Record it in the P0-T18 artifact.
- [ ] [P0-T20] Baseline Python formatting, check mode (read-only, so the baseline is not altered by a repair): run `poetry run black --check .`. Acceptance: the command completes and its EXIT_CODE and the list of any "would reformat" files are recorded (baseline capture; any exit code is recorded as observed). Write baseline/phase0-python-black-check.<timestamp>.md.
- [ ] [P0-T21] Baseline Python lint: run `poetry run ruff check --no-fix .` (read-only). Acceptance: EXIT_CODE and the finding count are recorded; on a clean tree the tool prints "All checks passed!" (observed in the v1 final-QA record). Write baseline/phase0-python-ruff.<timestamp>.md.
- [ ] [P0-T22] Baseline Python type check: run `poetry run pyright`. Acceptance: EXIT_CODE and the summary line of the form "0 errors, 0 warnings, 0 informations" (observed in the v1 final-QA record) are recorded with the error count. Write baseline/phase0-python-pyright.<timestamp>.md.
- [ ] [P0-T23] Baseline Python tests with repository-wide coverage: run `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`, then `poetry run python <scratchpad>/coverage_totals.py`. Acceptance: the pytest summary line (for example "2886 passed in 10.41s" in the v1 record) gives collected, passed, failed, skipped, and error counts, which are recorded with the full list of failed node IDs (the baseline failed set); the helper prints numeric `TOTAL_LINE=` and `TOTAL_BRANCH=` values and a `GENERATED_AT=` value later than the task start. Output Summary records the counts, the baseline line percent, and the baseline branch percent. Write baseline/phase0-python-pytest-coverage.<timestamp>.md.
- [ ] [P0-T24] Baseline targeted coverage of the five blast-radius modules using the dotted form: run `poetry run pytest tests --cov=scripts.dev_tools._blast_radius_conflicts --cov=scripts.dev_tools._blast_radius_glob --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_validation --cov=scripts.dev_tools.compute_blast_radius --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`, then `poetry run python <scratchpad>/coverage_totals.py`. Acceptance: the term-missing table lists exactly the five modules; the helper prints numeric targeted `TOTAL_LINE=` and `TOTAL_BRANCH=` values and five `FILE` lines, all recorded. Write baseline/phase0-python-pytest-targeted-coverage.<timestamp>.md.
- [ ] [P0-T25] Baseline PowerShell formatting over the folder that will hold the new Pester file. Run `git status --porcelain -- tests/scripts/claude-lib/blast-radius` (expected: no output, because tracked files are clean after P0-T16), then call the MCP tool mcp__drm-copilot__run_poshqc_format with workspace_root set to the worktree root and scan_folders set to the single folder tests/scripts/claude-lib/blast-radius, then run the same porcelain command again. Acceptance: the MCP call returns (call disposition recorded as `EXIT_CODE: 0`) and both porcelain captures are empty, which shows the formatter left every tracked file in that folder unchanged. If the second capture lists a file, the formatter repaired pre-existing drift: record the file list, restore each listed file with `git restore -- tests/scripts/claude-lib/blast-radius`, confirm the porcelain capture is empty again, and record the drift as a pre-existing condition outside this plan's write set. Write baseline/phase0-powershell-format.<timestamp>.md.
- [ ] [P0-T26] Baseline PowerShell analysis over the same folder. Call the MCP tool mcp__drm-copilot__run_poshqc_analyze with the same workspace_root and scan_folders, and record its call disposition. Then run `sh <scratchpad>/run-ps.sh <scratchpad>/pssa-count.ps1 -Path tests/scripts/claude-lib/blast-radius`. Acceptance: the helper prints a numeric `PSSA_FINDINGS=` value and one `FINDING:` line per finding; the value and lines are recorded as the baseline finding set. Write baseline/phase0-powershell-analyze.<timestamp>.md.
- [ ] [P0-T27] Baseline PowerShell tests with coverage, repository-wide. First run `sh <scratchpad>/run-ps.sh <scratchpad>/clear-pester-artifacts.ps1`, call the MCP tool mcp__drm-copilot__run_poshqc_test with workspace_root set to the worktree root and no scan_folders override, and record its call disposition. Then run `sh <scratchpad>/run-ps.sh <scratchpad>/poshqc-test.ps1`, then `sh <scratchpad>/run-ps.sh <scratchpad>/junit-report.ps1`, then `sh <scratchpad>/run-ps.sh <scratchpad>/coverage-line.ps1`. Acceptance: junit-report prints an `ALL total=` line and one `FAILED_ANY:` line per failing test (the baseline PowerShell failed set, recorded verbatim; the self-hosted run's own exit code is recorded as observed and is non-zero whenever that set is non-empty); coverage-line prints a numeric `LINE ... percent=` value, recorded as the baseline PowerShell line coverage. Write baseline/phase0-powershell-pester-coverage.<timestamp>.md.
- [ ] [P0-T28] Baseline PowerShell tests scoped to the blast-radius suites: run `sh <scratchpad>/run-ps.sh <scratchpad>/poshqc-test.ps1 -ScanFolder tests/scripts/claude-lib/blast-radius`, then `sh <scratchpad>/run-ps.sh <scratchpad>/junit-report.ps1`. Acceptance: the `ALL total=` count and the `fail=` count are recorded; `fail=0` is expected for this folder (any failure is recorded with its name and becomes part of the baseline set for this scope). Write baseline/phase0-powershell-pester-blast-radius-scope.<timestamp>.md.
- [ ] [P0-T29] Tolerance-layer detection (after the P0-T16 sync). Run the decisive search over runtime code and configuration only, excluding documents so that this plan, the spec, and the research cannot match themselves: `git grep -n -E "conflict_tolerance|overlap_tolerance|integration_cost|conflictTolerance|overlapTolerance|integrationCost" -- scripts .claude/lib .claude/hooks .codex extensions/drm-copilot/src config packages`. Then run the informational search `git grep -n -i -E "tolerance" -- scripts .claude/lib .claude/hooks config` and record its matches without using them for the decision. Then run the positive control `grep -c -E "conflict_tolerance" docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md`, which must print a count of at least 1 and proves the pattern syntax matches its target. Acceptance and branch selection (both branches pre-authorized by the spec): branch NOT FOUND when the decisive search prints no match line (git grep exits 1 in that case, which is the expected exit code for this branch); branch FOUND when it prints at least one match line. Write baseline/phase0-tolerance-detection.<timestamp>.md recording all three commands, their exit codes, their outputs, and the line `TOLERANCE_BRANCH: NOT FOUND` or `TOLERANCE_BRANCH: FOUND`. In branch NOT FOUND the consumers take the skip branch defined in P3-T1 and P4-T1. In branch FOUND, complete Phase 0 and Phase 1, then stop before Phase 2 and return synchronously to the orchestrator for a planner revision that names the discovered key or function and adds the strictest-tolerance scheduling-edge assertions for every must-conflict case to P3-T1 and P4-T1; the per-consumer test count stays 26 and the tolerance test is then expected to pass rather than skip. At main beae3f02 the research recorded no such layer, so NOT FOUND is expected unless #722 merged before P0-T16.
- [ ] [P0-T30] Write the case table `<scratchpad>/phase0-cases.json` with exactly this content (the spec's Case List). Each plan line carries the marker {BT} where the backtick character belongs; P0-T31 and P0-T32 replace the marker when they read the table, and P2-T1 writes the literal backtick into the corpus. This table is also the input half of the corpus authored in P2-T1:
      ```json
      {
        "schema_version": 1,
        "issue": 452,
        "description": "Shared two-direction regression corpus for issue #452. It pins the separator-free root-surface correction (gap 1) and the listed-directory prefix correction (gap 2) at the detection level for the Python authority and the PowerShell port.",
        "cases": [
          {
            "id": "g1-plan-poetry-lock", "gap": 1, "kind": "plan_pair", "direction": "must-conflict",
            "paired_case_id": "g1-plan-different-surfaces", "config_ref": "self_hosted",
            "input": {"plan_a": "- [ ] [P1-T1] Edit {BT}poetry.lock{BT}.", "plan_b": "- [ ] [P1-T1] Edit {BT}poetry.lock{BT}.",
                      "feature_folder_a": "2026-09-27-regression-452-left", "feature_folder_b": "2026-09-27-regression-452-right", "computed_at": "2026-09-27T12-15"}
          },
          {
            "id": "g1-plan-package-lock", "gap": 1, "kind": "plan_pair", "direction": "must-conflict",
            "paired_case_id": "g1-plan-unconfigured-root-file", "config_ref": "self_hosted",
            "input": {"plan_a": "- [ ] [P1-T1] Edit {BT}package-lock.json{BT}.", "plan_b": "- [ ] [P1-T1] Edit {BT}package-lock.json{BT}.",
                      "feature_folder_a": "2026-09-27-regression-452-left", "feature_folder_b": "2026-09-27-regression-452-right", "computed_at": "2026-09-27T12-15"}
          },
          {
            "id": "g1-plan-different-surfaces", "gap": 1, "kind": "plan_pair", "direction": "must-not-conflict",
            "paired_case_id": "g1-plan-poetry-lock", "config_ref": "self_hosted",
            "input": {"plan_a": "- [ ] [P1-T1] Edit {BT}poetry.lock{BT}.", "plan_b": "- [ ] [P1-T1] Edit {BT}package-lock.json{BT}.",
                      "feature_folder_a": "2026-09-27-regression-452-left", "feature_folder_b": "2026-09-27-regression-452-right", "computed_at": "2026-09-27T12-15"}
          },
          {
            "id": "g1-plan-unconfigured-root-file", "gap": 1, "kind": "plan_pair", "direction": "must-not-conflict",
            "paired_case_id": "g1-plan-package-lock", "config_ref": "self_hosted",
            "input": {"plan_a": "- [ ] [P1-T1] Edit {BT}pyproject.toml{BT}.", "plan_b": "- [ ] [P1-T1] Edit {BT}pyproject.toml{BT}.",
                      "feature_folder_a": "2026-09-27-regression-452-left", "feature_folder_b": "2026-09-27-regression-452-right", "computed_at": "2026-09-27T12-15"}
          },
          {
            "id": "g1-plan-quality-tiers-mandate-read", "gap": 1, "kind": "plan_pair", "direction": "must-not-conflict", "doctrine_pin": true,
            "paired_case_id": "g1-radius-quality-tiers", "config_ref": "self_hosted",
            "input": {"plan_a": "- [ ] [P1-T1] Read {BT}quality-tiers.yml{BT}.", "plan_b": "- [ ] [P1-T1] Read {BT}quality-tiers.yml{BT}.",
                      "feature_folder_a": "2026-09-27-regression-452-left", "feature_folder_b": "2026-09-27-regression-452-right", "computed_at": "2026-09-27T12-15"}
          },
          {
            "id": "g1-radius-quality-tiers", "gap": 1, "kind": "radius_pair", "direction": "must-conflict",
            "paired_case_id": "g1-radius-quality-tiers-vs-poetry-lock", "config": {"version": 1},
            "input": {
              "radius_a": {"paths": ["quality-tiers.yml"], "modules": [], "shared_surfaces": ["quality-tiers.yml"], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"},
              "radius_b": {"paths": ["quality-tiers.yml"], "modules": [], "shared_surfaces": ["quality-tiers.yml"], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"}
            }
          },
          {
            "id": "g1-radius-quality-tiers-vs-poetry-lock", "gap": 1, "kind": "radius_pair", "direction": "must-not-conflict",
            "paired_case_id": "g1-radius-quality-tiers", "config": {"version": 1},
            "input": {
              "radius_a": {"paths": ["quality-tiers.yml"], "modules": [], "shared_surfaces": ["quality-tiers.yml"], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"},
              "radius_b": {"paths": ["poetry.lock"], "modules": [], "shared_surfaces": ["poetry.lock"], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"}
            }
          },
          {
            "id": "g2-dir-vs-glob", "gap": 2, "kind": "radius_pair", "direction": "must-conflict",
            "paired_case_id": "g2-dir-vs-sibling-glob", "config": {"version": 1},
            "input": {
              "radius_a": {"paths": ["scripts/dev_tools"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"},
              "radius_b": {"paths": ["scripts/dev_tools/**"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"}
            }
          },
          {
            "id": "g2-glob-vs-dir", "gap": 2, "kind": "radius_pair", "direction": "must-conflict",
            "paired_case_id": "g2-sibling-glob-vs-dir", "config": {"version": 1},
            "input": {
              "radius_a": {"paths": ["scripts/dev_tools/**"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"},
              "radius_b": {"paths": ["scripts/dev_tools"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"}
            }
          },
          {
            "id": "g2-dir-vs-sibling-glob", "gap": 2, "kind": "radius_pair", "direction": "must-not-conflict",
            "paired_case_id": "g2-dir-vs-glob", "config": {"version": 1},
            "input": {
              "radius_a": {"paths": ["scripts/dev_tools"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"},
              "radius_b": {"paths": ["scripts/dev_tools_extra/**"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"}
            }
          },
          {
            "id": "g2-sibling-glob-vs-dir", "gap": 2, "kind": "radius_pair", "direction": "must-not-conflict",
            "paired_case_id": "g2-glob-vs-dir", "config": {"version": 1},
            "input": {
              "radius_a": {"paths": ["scripts/dev_tools_extra/**"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"},
              "radius_b": {"paths": ["scripts/dev_tools"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"}
            }
          },
          {
            "id": "g2-artifacts-dir-vs-glob", "gap": 2, "kind": "radius_pair", "direction": "must-conflict",
            "paired_case_id": "g2-artifacts-dir-vs-sibling-glob", "config": {"version": 1},
            "input": {
              "radius_a": {"paths": ["artifacts/orchestration"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"},
              "radius_b": {"paths": ["artifacts/orchestration/**"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"}
            }
          },
          {
            "id": "g2-artifacts-glob-vs-dir", "gap": 2, "kind": "radius_pair", "direction": "must-conflict",
            "paired_case_id": "g2-artifacts-sibling-glob-vs-dir", "config": {"version": 1},
            "input": {
              "radius_a": {"paths": ["artifacts/orchestration/**"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"},
              "radius_b": {"paths": ["artifacts/orchestration"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"}
            }
          },
          {
            "id": "g2-artifacts-dir-vs-sibling-glob", "gap": 2, "kind": "radius_pair", "direction": "must-not-conflict",
            "paired_case_id": "g2-artifacts-dir-vs-glob", "config": {"version": 1},
            "input": {
              "radius_a": {"paths": ["artifacts/orchestration"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"},
              "radius_b": {"paths": ["artifacts/orchestration-archive/**"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"}
            }
          },
          {
            "id": "g2-artifacts-sibling-glob-vs-dir", "gap": 2, "kind": "radius_pair", "direction": "must-not-conflict",
            "paired_case_id": "g2-artifacts-glob-vs-dir", "config": {"version": 1},
            "input": {
              "radius_a": {"paths": ["artifacts/orchestration-archive/**"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"},
              "radius_b": {"paths": ["artifacts/orchestration"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"}
            }
          },
          {
            "id": "g2-empty-modules-dir-vs-glob", "gap": 2, "kind": "radius_pair", "direction": "must-conflict",
            "paired_case_id": "g2-empty-modules-dir-vs-sibling-glob", "config": {"version": 1, "modules": {"poshqc": ["scripts/powershell/**"]}},
            "input": {
              "radius_a": {"paths": ["scripts/powershell/PoshQC"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"},
              "radius_b": {"paths": ["scripts/powershell/PoshQC/**"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"}
            }
          },
          {
            "id": "g2-empty-modules-dir-vs-sibling-glob", "gap": 2, "kind": "radius_pair", "direction": "must-not-conflict",
            "paired_case_id": "g2-empty-modules-dir-vs-glob", "config": {"version": 1, "modules": {"poshqc": ["scripts/powershell/**"]}},
            "input": {
              "radius_a": {"paths": ["scripts/powershell/PoshQC"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"},
              "radius_b": {"paths": ["scripts/powershell/PoshQCExtra/**"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15"}
            }
          }
        ]
      }
      ```
      Acceptance: `poetry run python -c "import json, pathlib, sys; d = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding='utf-8')); print('CASES=' + str(len(d['cases'])))" <scratchpad>/phase0-cases.json` prints `CASES=17`. Record the output in the P0-T31 artifact.
- [ ] [P0-T31] Python runtime verification of both gaps (spec Phase 0 requirement 1). Write `<scratchpad>`/phase0_python_verdicts.py with exactly this body (the research's proposed confirmation script, extended to every Case List case):
      ```python
      """Phase 0 runtime confirmation for issue #452 (scratchpad only, never committed)."""
      import json
      import pathlib
      import sys

      ROOT = pathlib.Path.cwd().resolve()
      sys.path.insert(0, str(ROOT))

      import scripts.dev_tools._blast_radius_conflicts as conflicts_module
      from scripts.dev_tools._blast_radius_extraction import classify_path_token
      from scripts.dev_tools._blast_radius_glob import _entries_overlap
      from scripts.dev_tools._blast_radius_validation import config_root_surfaces
      from scripts.dev_tools.compute_blast_radius import BlastRadius, conflicts, derive_blast_radius, extract_plan_paths

      BT = chr(96)
      print(f"MODULE_UNDER_ROOT={pathlib.Path(conflicts_module.__file__).resolve().is_relative_to(ROOT)}")
      self_hosted = json.loads((ROOT / "config" / "blast-radius.json").read_text(encoding="utf-8"))
      bundled_path = ROOT / "extensions" / "drm-copilot" / "resources" / "claude-customizations" / "config" / "blast-radius.json"
      bundled = json.loads(bundled_path.read_text(encoding="utf-8"))
      roots = config_root_surfaces(self_hosted)
      print(f"ROOT_SURFACES_SELF_HOSTED={','.join(sorted(roots))}")
      print(f"ROOT_SURFACES_BUNDLED={','.join(sorted(config_root_surfaces(bundled)))}")
      # Gap 1 at token level, in both directions: admitted with the configured roots, rejected without them.
      for token in ("poetry.lock", "package-lock.json", "quality-tiers.yml", "Poetry.lock", "pyproject.toml"):
          print(f"TOKEN {token} with_roots={classify_path_token(token, root_surfaces=roots)} without_roots={classify_path_token(token)}")
      # Gap 1 at plan-extraction level for one write line per surface, plus the unconfigured control.
      for token in ("poetry.lock", "package-lock.json", "pyproject.toml"):
          line = f"- [ ] [P1-T1] Edit {BT}{token}{BT}."
          print(f"EXTRACT {token} with_roots={extract_plan_paths(line, root_surfaces=roots)} without_roots={extract_plan_paths(line)}")
      # Gap 2 at entry level, both argument orders, with the sibling-prefix negative controls.
      pairs = (
          ("scripts/dev_tools", "scripts/dev_tools/**"), ("scripts/dev_tools", "scripts/dev_tools_extra/**"),
          ("artifacts/orchestration", "artifacts/orchestration/**"), ("artifacts/orchestration", "artifacts/orchestration-archive/**"),
          ("scripts/powershell/PoshQC", "scripts/powershell/PoshQC/**"), ("scripts/powershell/PoshQC", "scripts/powershell/PoshQCExtra/**"),
      )
      for left, right in pairs:
          print(f"ENTRY {left} | {right} forward={_entries_overlap(left, right)} reverse={_entries_overlap(right, left)}")
      # Every Case List case: verdict and ordered reasons from the contention relation.
      cases = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))["cases"]
      for case in cases:
          config = self_hosted if case.get("config_ref") == "self_hosted" else case["config"]
          data = case["input"]
          if case["kind"] == "radius_pair":
              radius_a = BlastRadius.from_dict(data["radius_a"])
              radius_b = BlastRadius.from_dict(data["radius_b"])
          else:
              plan_a = data["plan_a"].replace("{BT}", BT)
              plan_b = data["plan_b"].replace("{BT}", BT)
              radius_a = derive_blast_radius(plan_a, "", data["feature_folder_a"], config, computed_at=data["computed_at"])
              radius_b = derive_blast_radius(plan_b, "", data["feature_folder_b"], config, computed_at=data["computed_at"])
              print(f"RADIUS {case['id']} A paths={','.join(radius_a.paths)} surfaces={','.join(radius_a.shared_surfaces)} B paths={','.join(radius_b.paths)} surfaces={','.join(radius_b.shared_surfaces)}")
          result = conflicts(radius_a, radius_b, config)
          reasons = "; ".join(f"{reason.kind}|{reason.detail}" for reason in result.reasons)
          print(f"CASE {case['id']} conflict={result.conflict} reasons=[{reasons}]")
      ```
      Run `poetry run python <scratchpad>/phase0_python_verdicts.py <scratchpad>/phase0-cases.json` and save the output to `<scratchpad>`/phase0-python-output.txt. Acceptance: EXIT_CODE 0; `MODULE_UNDER_ROOT=True`; 17 `CASE` lines; the TOKEN lines show `concrete` for the three configured surfaces with roots and `None` for every token without roots and for Poetry.lock and pyproject.toml with roots; the EXTRACT lines show a one-element tuple for poetry.lock and package-lock.json with roots, an empty tuple without roots, and an empty tuple for pyproject.toml; the six ENTRY lines read True/True for the three directory-versus-own-glob pairs and False/False for the three sibling controls; the RADIUS line for g1-plan-poetry-lock lists poetry.lock in both paths and surfaces, and the RADIUS line for g1-plan-quality-tiers-mandate-read lists no quality-tiers.yml entry (the mandate-read removal). A deviation from any expectation is recorded verbatim and is resolved by P1-T1, not here. Branch SIGNATURE-CHANGED (pre-authorized): if the script raises a TypeError or an unexpected-keyword error from `conflicts`, `derive_blast_radius`, or `BlastRadius.from_dict` (possible only if #722 merged before P0-T16), record the traceback, mark P0-T33 and P0-T34 as not executable because runtime output is absent, run P0-T35, skip Phase 1, and stop for a synchronous planner revision that updates only the consumer call sites. Write baseline/phase0-python-runtime-verdicts.<timestamp>.md containing the full output.
- [ ] [P0-T32] PowerShell runtime verification of both gaps against the root modules (spec Phase 0 requirement 2). Write `<scratchpad>`/phase0-powershell-verdicts.ps1 with exactly this body:
      ```powershell
      param([Parameter(Mandatory = $true)][string] $CasesPath)
      $ErrorActionPreference = 'Stop'
      $repoRoot = (Resolve-Path -LiteralPath '.').Path
      $libRoot = Join-Path $repoRoot '.claude/lib/blast-radius'
      # The module that force-imports the most siblings is imported first, because Import-Module -Force removes an earlier global copy of any module it re-imports.
      Import-Module (Join-Path $libRoot 'BlastRadius.psm1') -Force
      Import-Module (Join-Path $libRoot 'BlastRadiusConfig.psm1') -Force
      Import-Module (Join-Path $libRoot 'BlastRadiusExtraction.psm1') -Force
      Import-Module (Join-Path $libRoot 'BlastRadiusGlob.psm1') -Force
      $requiredCommands = @('Get-ConfigRootSurface', 'Get-PathTokenKind', 'Get-PlanPaths', 'Test-EntryOverlap', 'Get-BlastRadius', 'Test-BlastRadiusConflict')
      $missingCommands = @($requiredCommands | Where-Object { $null -eq (Get-Command -Name $_ -ErrorAction SilentlyContinue) })
      Write-Output "COMMANDS_MISSING=$($missingCommands -join ',')"
      function Format-Kind([object] $Kind) { if ($null -eq $Kind) { return 'None' } return [string] $Kind }
      $bt = [char]0x60
      Write-Output "MODULE_UNDER_ROOT=$((Get-Module -Name 'BlastRadius').Path.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase))"
      $selfHosted = Get-Content -LiteralPath (Join-Path $repoRoot 'config/blast-radius.json') -Raw | ConvertFrom-Json -AsHashtable
      $bundled = Get-Content -LiteralPath (Join-Path $repoRoot 'extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json') -Raw | ConvertFrom-Json -AsHashtable
      $roots = [string[]] @(Get-ConfigRootSurface -Config $selfHosted)
      Write-Output "ROOT_SURFACES_SELF_HOSTED=$((@($roots) | Sort-Object) -join ',')"
      Write-Output "ROOT_SURFACES_BUNDLED=$((@(Get-ConfigRootSurface -Config $bundled) | Sort-Object) -join ',')"
      foreach ($token in @('poetry.lock', 'package-lock.json', 'quality-tiers.yml', 'Poetry.lock', 'pyproject.toml')) {
          Write-Output "TOKEN $token with_roots=$(Format-Kind (Get-PathTokenKind -Token $token -RootSurface $roots)) without_roots=$(Format-Kind (Get-PathTokenKind -Token $token))"
      }
      foreach ($token in @('poetry.lock', 'package-lock.json', 'pyproject.toml')) {
          $line = "- [ ] [P1-T1] Edit $bt$token$bt."
          Write-Output "EXTRACT $token with_roots=($(@(Get-PlanPaths -PlanText $line -RootSurface $roots) -join ',')) without_roots=($(@(Get-PlanPaths -PlanText $line) -join ','))"
      }
      $pairs = @(
          @('scripts/dev_tools', 'scripts/dev_tools/**'), @('scripts/dev_tools', 'scripts/dev_tools_extra/**'),
          @('artifacts/orchestration', 'artifacts/orchestration/**'), @('artifacts/orchestration', 'artifacts/orchestration-archive/**'),
          @('scripts/powershell/PoshQC', 'scripts/powershell/PoshQC/**'), @('scripts/powershell/PoshQC', 'scripts/powershell/PoshQCExtra/**')
      )
      foreach ($pair in $pairs) {
          Write-Output "ENTRY $($pair[0]) | $($pair[1]) forward=$(Test-EntryOverlap -EntryA $pair[0] -EntryB $pair[1]) reverse=$(Test-EntryOverlap -EntryA $pair[1] -EntryB $pair[0])"
      }
      $cases = (Get-Content -LiteralPath $CasesPath -Raw | ConvertFrom-Json -AsHashtable)['cases']
      foreach ($case in $cases) {
          $config = if ($case.ContainsKey('config_ref')) { $selfHosted } else { $case['config'] }
          $data = $case['input']
          if ($case['kind'] -eq 'radius_pair') {
              $radiusA = $data['radius_a']
              $radiusB = $data['radius_b']
          }
          else {
              $planA = ([string] $data['plan_a']).Replace('{BT}', [string] $bt)
              $planB = ([string] $data['plan_b']).Replace('{BT}', [string] $bt)
              $radiusA = Get-BlastRadius -PlanText $planA -SpecText '' -FeatureFolder $data['feature_folder_a'] -Config $config -ComputedAt $data['computed_at']
              $radiusB = Get-BlastRadius -PlanText $planB -SpecText '' -FeatureFolder $data['feature_folder_b'] -Config $config -ComputedAt $data['computed_at']
              Write-Output "RADIUS $($case['id']) A paths=$(@($radiusA['paths']) -join ',') surfaces=$(@($radiusA['shared_surfaces']) -join ',') B paths=$(@($radiusB['paths']) -join ',') surfaces=$(@($radiusB['shared_surfaces']) -join ',')"
          }
          $result = Test-BlastRadiusConflict -RadiusA $radiusA -RadiusB $radiusB -Config $config
          $reasons = (@($result['reasons']) | ForEach-Object { "$($_['kind'])|$($_['detail'])" }) -join '; '
          Write-Output "CASE $($case['id']) conflict=$($result['conflict']) reasons=[$reasons]"
      }
      ```
      Run `sh <scratchpad>/run-ps.sh <scratchpad>/phase0-powershell-verdicts.ps1 -CasesPath <scratchpad>/phase0-cases.json` and save the output to `<scratchpad>`/phase0-powershell-output.txt. Acceptance: EXIT_CODE 0; the output contains the `COMMANDS_MISSING=` line with an empty value (a non-empty value is a plan defect and a stop for planner revision); and the same expectations as P0-T31, line for line (17 `CASE` lines, `MODULE_UNDER_ROOT=True`, TOKEN, EXTRACT, ENTRY, and RADIUS expectations). The runner route is proven by the P0-T18 smoke test; code reading alone does not satisfy this task. The SIGNATURE-CHANGED branch of P0-T31 applies equally to `Get-BlastRadius` and `Test-BlastRadiusConflict`: record the traceback, mark P0-T33 and P0-T34 as not executable because runtime output is absent, run P0-T35, skip Phase 1, and stop. Write baseline/phase0-powershell-runtime-verdicts.<timestamp>.md containing the full output.
- [ ] [P0-T33] Three-way comparison (spec Phase 0 requirement 3). Write `<scratchpad>`/compare_verdicts.py with exactly this body; TRACE holds the research trace as restated in the spec's Case List:
      ```python
      """Three-way verdict comparison for issue #452 Phase 0 (scratchpad only, never committed)."""
      import pathlib
      import sys

      NONE = "conflict=False reasons=[]"
      TRACE = {
          "g1-plan-poetry-lock": "conflict=True reasons=[path_overlap|poetry.lock ~ poetry.lock; shared_surface_overlap|poetry.lock]",
          "g1-plan-package-lock": "conflict=True reasons=[path_overlap|package-lock.json ~ package-lock.json; shared_surface_overlap|package-lock.json]",
          "g1-plan-different-surfaces": NONE,
          "g1-plan-unconfigured-root-file": NONE,
          "g1-plan-quality-tiers-mandate-read": NONE,
          "g1-radius-quality-tiers": "conflict=True reasons=[path_overlap|quality-tiers.yml ~ quality-tiers.yml; shared_surface_overlap|quality-tiers.yml]",
          "g1-radius-quality-tiers-vs-poetry-lock": NONE,
          "g2-dir-vs-glob": "conflict=True reasons=[path_overlap|scripts/dev_tools ~ scripts/dev_tools/**]",
          "g2-glob-vs-dir": "conflict=True reasons=[path_overlap|scripts/dev_tools ~ scripts/dev_tools/**]",
          "g2-dir-vs-sibling-glob": NONE,
          "g2-sibling-glob-vs-dir": NONE,
          "g2-artifacts-dir-vs-glob": "conflict=True reasons=[path_overlap|artifacts/orchestration ~ artifacts/orchestration/**]",
          "g2-artifacts-glob-vs-dir": "conflict=True reasons=[path_overlap|artifacts/orchestration ~ artifacts/orchestration/**]",
          "g2-artifacts-dir-vs-sibling-glob": NONE,
          "g2-artifacts-sibling-glob-vs-dir": NONE,
          "g2-empty-modules-dir-vs-glob": "conflict=True reasons=[path_overlap|scripts/powershell/PoshQC ~ scripts/powershell/PoshQC/**]",
          "g2-empty-modules-dir-vs-sibling-glob": NONE,
      }


      def case_lines(path: str) -> dict[str, str]:
          """Map each case id to the verdict text of its CASE line in one runtime's output."""
          found: dict[str, str] = {}
          # Keep only CASE lines; every other diagnostic line is evidence, not a verdict.
          for line in pathlib.Path(path).read_text(encoding="utf-8").splitlines():
              if line.startswith("CASE "):
                  case_id, _, rest = line[5:].partition(" ")
                  found[case_id] = rest.strip()
          return found


      python_lines = case_lines(sys.argv[1])
      powershell_lines = case_lines(sys.argv[2])
      branch = "AGREE"
      # Compare every Case List case across the two runtimes and the trace.
      for case_id, trace in TRACE.items():
          python_text = python_lines.get(case_id, "MISSING")
          powershell_text = powershell_lines.get(case_id, "MISSING")
          status = "AGREE" if python_text == powershell_text == trace else "DIFF"
          if status == "DIFF":
              branch = "DIVERGENT"
          print(f"COMPARE {case_id} python=[{python_text}] powershell=[{powershell_text}] trace=[{trace}] {status}")
      print(f"CASES_COMPARED={len(TRACE)} PYTHON_CASES={len(python_lines)} POWERSHELL_CASES={len(powershell_lines)}")
      print(f"BRANCH={branch}")
      ```
      Run `poetry run python <scratchpad>/compare_verdicts.py <scratchpad>/phase0-python-output.txt <scratchpad>/phase0-powershell-output.txt`. Acceptance: EXIT_CODE 0; `CASES_COMPARED=17 PYTHON_CASES=17 POWERSHELL_CASES=17`; 17 `COMPARE` lines; and a final `BRANCH=AGREE` or `BRANCH=DIVERGENT` line, which P1-T1 consumes. Write baseline/phase0-three-way-comparison.<timestamp>.md containing the full output and, for each case, whether all three agree.
- [ ] [P0-T34] Record the bundled-configuration subsets (spec Phase 0 requirement 5) from the `ROOT_SURFACES_SELF_HOSTED=` and `ROOT_SURFACES_BUNDLED=` lines of the P0-T31 and P0-T32 outputs. Acceptance: all four lines are recorded verbatim, and the self-hosted and bundled values are equal within each runtime and across runtimes (expected value package-lock.json,poetry.lock,quality-tiers.yml per research claims N1 and N2). An inequality is recorded and routed to P1-T1 as DIVERGENT. Write baseline/phase0-bundled-root-surfaces.<timestamp>.md.
- [ ] [P0-T35] Commit and push Phase 0. Write the commit message to `<scratchpad>`/commit-phase0.txt (summary line "test(452): record v2 phase 0 baselines and runtime verification"). Run `git add docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2`, `git status --porcelain`, `git commit -F <scratchpad>/commit-phase0.txt`, and `git push -u origin HEAD`. Acceptance: every command exits 0; the porcelain capture before the commit lists only paths under the v2 folder; after the push `git rev-parse HEAD` equals `git rev-parse @{upstream}`. Record the four outputs and the pushed SHA in regression-testing/phase0-commit.<timestamp>.md, then include that artifact in the next phase's commit.

### Phase 1 — Conditional Production Correction Resolution

- [ ] [P1-T1] Classify the P0-T33 result and select exactly one pre-authorized branch; write regression-testing/phase1-correction-resolution.<timestamp>.md naming the branch in a line `CORRECTION_BRANCH: NO-CORRECTION-REQUIRED` or `CORRECTION_BRANCH: CORRECTION-REQUIRED`. The classification is mechanical:
      - `BRANCH=AGREE` in P0-T33 and equal subsets in P0-T34: branch NO-CORRECTION-REQUIRED. The artifact states "no correction required" and cites the P0-T31, P0-T32, P0-T33, and P0-T34 artifacts. Corpus expected values are the P0-T33 trace values.
      - `BRANCH=DIVERGENT` where, for some case, a runtime's verdict is False while the trace is True, or a runtime omits a reason the trace lists (an under-report per the spec's Conditional production correction rule): branch CORRECTION-REQUIRED. Name the runtime and case in the artifact, then stop and return synchronously to the orchestrator for a planner revision. The revision adds a correction phase whose write targets are, conditionally and only for the runtime named: for Python, the extraction, glob, or conflicts module under scripts/dev_tools that owns the missing behaviour; for PowerShell, the owning module under .claude/lib/blast-radius together with its text-identical bundled copy under extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius, with the existing bundled-payload content-identity test (test_bundled_claude_payload_contains_all_repo_runtime_contracts, read-only) required to pass; and, only if the named runtime is mirrored in TypeScript, the TypeScript policy reads plus the mirrored file. Those files are deliberately not listed as write targets in this plan; the planner will be asked to add them to the plan text if this branch fires, so the derived radius changes only when a correction is actually required. The fail-before evidence is the recorded P0-T31 or P0-T32 output plus the relevant consumer test failing before the correction; the pass-after evidence is the same test passing after it.
      - `BRANCH=DIVERGENT` where the Python and PowerShell `CASE` texts differ from each other for any case (a parity defect), or a must-not-conflict case conflicts in either runtime: stop and return synchronously for a planner revision; record the differing lines. The artifact still names `CORRECTION_BRANCH: CORRECTION-REQUIRED`.
      - `BRANCH=DIVERGENT` where both runtimes agree with each other and differ from the trace only by an additional reason on a must-conflict case: branch NO-CORRECTION-REQUIRED; record the investigation (which extra reason, and why it is not an under-report) and use the executed reasons as that case's expected value in P2-T1.
      Acceptance: the artifact exists, carries exactly one `CORRECTION_BRANCH:` line, and cites the evidence it was derived from.
- [ ] [P1-T2] Commit and push Phase 1 with the same four commands as P0-T35 (message file `<scratchpad>`/commit-phase1.txt, summary "test(452): record v2 correction resolution"). Acceptance: as in P0-T35. Record in regression-testing/phase1-commit.<timestamp>.md.

### Phase 2 — Shared Regression Corpus

- [ ] [P2-T1] Create `tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json`. Content: the P0-T30 case table, with one `expected` object added to every case, pretty-printed with two-space indentation so that each case's `"id"` key sits on its own line. In branch NO-CORRECTION-REQUIRED the expected values are the executed values of P0-T33, which equal these trace values unless P1-T1 recorded an additional reason:
      - g1-plan-poetry-lock: conflict true; reasons path_overlap "poetry.lock ~ poetry.lock", then shared_surface_overlap "poetry.lock".
      - g1-plan-package-lock: conflict true; reasons path_overlap "package-lock.json ~ package-lock.json", then shared_surface_overlap "package-lock.json".
      - g1-radius-quality-tiers: conflict true; reasons path_overlap "quality-tiers.yml ~ quality-tiers.yml", then shared_surface_overlap "quality-tiers.yml".
      - g2-dir-vs-glob and g2-glob-vs-dir: conflict true; reason path_overlap "scripts/dev_tools ~ scripts/dev_tools/**".
      - g2-artifacts-dir-vs-glob and g2-artifacts-glob-vs-dir: conflict true; reason path_overlap "artifacts/orchestration ~ artifacts/orchestration/**".
      - g2-empty-modules-dir-vs-glob: conflict true; reason path_overlap "scripts/powershell/PoshQC ~ scripts/powershell/PoshQC/**" (no module_overlap).
      - The nine must-not-conflict cases: conflict false; reasons empty.
      Each reason is an object with keys kind and detail. Every {BT} marker from the case table is replaced by one literal backtick character in the corpus file, so each corpus plan line reads as a checkbox task line whose path is wrapped in a pair of backtick characters; no {BT} marker remains in the corpus. No other file in the fixture corpus is created, modified, or deleted. Acceptance: verified by P2-T2.
- [ ] [P2-T2] Structural check with two independent reads. Run `poetry run python -c "import json, pathlib; d = json.loads(pathlib.Path('tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json').read_text(encoding='utf-8')); print('CASES=' + str(len(d['cases'])) + ' SCHEMA=' + str(d['schema_version']) + ' ISSUE=' + str(d['issue']))"` and `grep -c -e '"id": ' tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json`, then `grep -c -F -e "{BT}" tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json` and `grep -c -e '"plan_a": ' tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json`, then `git status --porcelain --untracked-files=all -- tests/fixtures/blast_radius` (the flag lists an untracked file individually instead of collapsing its new directory into one entry). Acceptance: the first command prints `CASES=17 SCHEMA=1 ISSUE=452`; the {BT} count is 0 (grep exits 1 on zero matches, the expected exit code here); the plan_a count is 5 (the five plan_pair cases), and each plan_pair case's plan lines are confirmed by the P3-T2 plan-line intent test; the grep count is 17 (the `"paired_case_id": ` key does not match, because its `id` is preceded by an underscore rather than a quote); the porcelain capture lists exactly one line, the new corpus file with status `??`, which shows no existing fixture was modified or deleted. Write regression-testing/phase2-corpus-structure.<timestamp>.md.
- [ ] [P2-T3] Commit and push Phase 2: `git add tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2`, `git status --porcelain`, `git commit -F <scratchpad>/commit-phase2.txt` (summary "test(452): add shared under-reporting regression corpus"), `git push -u origin HEAD`. Acceptance: as in P0-T35, with the porcelain capture listing only the corpus file and paths under the v2 folder. Record in regression-testing/phase2-commit.<timestamp>.md.

### Phase 3 — Python Consumer

- [ ] [P3-T1] Create `tests/scripts/dev_tools/test_blast_radius_regression_452.py` with this fixed structure:
      - Module constants: REPO_ROOT resolved as the file's own resolved path, parents index 3 (the pattern of the existing Python parity driver, read-only); the corpus path, the self-hosted configuration path (config/blast-radius.json), and the bundled configuration path (extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json), each joined from REPO_ROOT with the path-join operator over separate string segments; EXPECTED_CASE_IDS, a tuple of the 17 case ids in the spec's Case List order.
      - Imports only from the standard library, pytest, `scripts.dev_tools.compute_blast_radius` (BlastRadius, conflicts, derive_blast_radius), and `scripts.dev_tools._blast_radius_validation` (config_root_surfaces). No import from any sibling test-support module, so the file can be loaded standalone by P3-T3.
      - The corpus is read once at import time for parametrization. The per-case test takes the raw case mapping as its only parameter, named `case`, and uses no fixture, so it can be called directly with an in-memory mapping.
      - Exactly these ten test functions (26 collected items: nine plain tests plus 17 parametrized items):
        1. test_corpus_top_level_shape_matches_the_contract (schema_version 1, issue 452, non-empty description, non-empty cases list).
        2. test_every_case_matches_the_case_shape_contract (field types; gap in {1, 2}; kind in {radius_pair, plan_pair}; direction in {must-conflict, must-not-conflict}; exactly one of config_ref and config; config_ref value self_hosted; doctrine_pin only on a must-not-conflict case; radius_pair inputs carry exactly the six radius keys; plan_pair inputs carry plan_a, plan_b, feature_folder_a, feature_folder_b, computed_at; every computed_at matches four digits, hyphen, two digits, hyphen, two digits, T, two digits, hyphen, two digits; expected carries conflict and reasons with kind and detail).
        3. test_corpus_case_ids_are_unique_and_equal_the_spec_case_list.
        4. test_every_expected_verdict_matches_its_direction.
        5. test_every_pairing_resolves_to_an_opposite_direction_case_of_the_same_gap (every paired_case_id resolves; opposite direction; same gap; every must-conflict case is named back by its control; the doctrine-pin case names a must-conflict case and is the only must-not-conflict case not reciprocally paired).
        6. test_each_gap_has_a_must_conflict_and_a_must_not_conflict_case.
        7. test_every_plan_line_follows_the_plan_line_intent_rule: each plan_a and plan_b is one line matching, with the backtick built as chr(96), the pattern start, hyphen, space, "[ ]", space, "[P" digits "-T" digits "]", space, then Edit or Create (Read for the doctrine-pin case only), space, a backtick, one or more non-backtick characters, a backtick, a period, end.
        8. test_case_verdict_matches_corpus, parametrized over the corpus cases with ids equal to the case id. For radius_pair it builds both radii with BlastRadius.from_dict; for plan_pair it derives both with derive_blast_radius (spec text empty) under the self-hosted configuration; it calls conflicts. It asserts the verdict first, with an assertion message that begins with the case id, then asserts the exact ordered list of (kind, detail) pairs, with a message that also contains the case id.
        9. test_bundled_separator_free_shared_surfaces_equal_the_self_hosted_subset: the two sets computed at test time with config_root_surfaces over both committed configurations are equal and non-empty (no hardcoded list or count).
        10. test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case. Branch NOT FOUND (P0-T29): decorated with a pytest skip mark whose reason is exactly "Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead." Branch FOUND: the assertions named by the P0-T29 planner revision.
      - Prohibited anywhere in the file, including comments and docstrings, so that the P8-T3 and P8-T4 searches cannot be satisfied or defeated by prose: the strings os.getcwd, cwd(, Get-Location, origin/main, subprocess, tmp_path, TestDrive, New-TemporaryFile, compute_cohorts, parallel_cohort, parallel_drift, parallel_mutation, recompute_conflicts_with_observed, noqa, type: ignore, any URL, and any letter-colon-slash or letter-colon-backslash sequence.
      - Docstrings on every function and intent comments above every loop and non-trivial branch per the commenting policy; Pyright-strict clean through isinstance narrowing followed by typing.cast to the narrowed type (the pattern of the existing Python parity driver), with no Any annotation and no suppression; syntax compatible with Python 3.10; no temporary file, subprocess, or git invocation; at most 500 lines.
      Acceptance: verified by P3-T2 and P6.
- [ ] [P3-T2] Run the Python consumer: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_regression_452.py -v` (the repository addopts value already carries -ra, which reports the skip in the short test summary). Acceptance (branch NOT FOUND): EXIT_CODE 0; the summary line reads "25 passed, 1 skipped"; the verbose progress section contains exactly 17 lines containing "::test_case_verdict_matches_corpus[" and "PASSED", one per case id, including g1-plan-quality-tiers-mandate-read and g1-radius-quality-tiers (the test function name is the one P3-T1 item 8 prescribes); the short test summary contains exactly one line beginning with "SKIPPED" whose reason contains "#722". Branch FOUND: EXIT_CODE 0 and "26 passed". Record the full output in regression-testing/phase3-python-consumer-run.<timestamp>.md.
- [ ] [P3-T3] [expect-fail] Python mutation demonstration, in memory only (no file on disk is modified, and no temporary file is created). Write `<scratchpad>`/python_mutation_demo.py with exactly this body:
      ```python
      """In-memory mutation demonstration for issue #452 (scratchpad only, never committed)."""
      import copy
      import importlib.util
      import json
      import pathlib
      import sys

      ROOT = pathlib.Path.cwd().resolve()
      sys.path.insert(0, str(ROOT))
      consumer_path = ROOT / "tests" / "scripts" / "dev_tools" / "test_blast_radius_regression_452.py"
      spec = importlib.util.spec_from_file_location("regression_452_consumer", consumer_path)
      module = importlib.util.module_from_spec(spec)
      sys.modules["regression_452_consumer"] = module
      spec.loader.exec_module(module)
      corpus_path = ROOT / "tests" / "fixtures" / "blast_radius" / "regression-452" / "under-reporting-corpus.json"
      cases = {case["id"]: case for case in json.loads(corpus_path.read_text(encoding="utf-8"))["cases"]}
      not_raised = 0
      # For each named case: prove the unflipped case passes, then flip only the verdict expectation in a deep copy.
      for case_id in sys.argv[1:]:
          original = cases[case_id]
          module.test_case_verdict_matches_corpus(copy.deepcopy(original))
          print(f"CONTROL {case_id} unflipped passed")
          flipped = copy.deepcopy(original)
          if flipped["direction"] == "must-conflict":
              flipped["direction"] = "must-not-conflict"
              flipped["expected"] = {"conflict": False, "reasons": []}
          else:
              paired = cases[flipped["paired_case_id"]]
              flipped["direction"] = "must-conflict"
              flipped["expected"] = {"conflict": True, "reasons": copy.deepcopy(paired["expected"]["reasons"])}
          try:
              module.test_case_verdict_matches_corpus(flipped)
          except AssertionError as error:
              text = str(error)
              print(f"MUTATION {case_id} raised AssertionError names_case={case_id in text} message={text.splitlines()[0] if text else ''}")
          else:
              not_raised += 1
              print(f"MUTATION {case_id} did not raise")
      sys.exit(not_raised)
      ```
      Run `poetry run python <scratchpad>/python_mutation_demo.py g1-plan-poetry-lock g1-plan-different-surfaces g2-glob-vs-dir g2-dir-vs-sibling-glob` (one must-conflict and one must-not-conflict case per gap, flipped one at a time), then `git status --porcelain -- tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json` and `git diff --exit-code HEAD -- tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json`. Acceptance: the driver exits 0 (every flip raised); it prints four `CONTROL` lines and four `MUTATION ... raised AssertionError names_case=True` lines, each message beginning with the flipped case id; the porcelain capture is empty and the anchored diff exits 0, so git reports no difference in the corpus file. Write regression-testing/phase3-python-mutation-demonstration.<timestamp>.md with the full output and an `[expect-fail]` note stating that the consumer's per-case assertion is expected to fail for each flipped copy.
- [ ] [P3-T4] Commit and push Phase 3: `git add tests/scripts/dev_tools/test_blast_radius_regression_452.py docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2`, `git status --porcelain`, `git commit -F <scratchpad>/commit-phase3.txt` (summary "test(452): add Python consumer of the regression corpus"), `git push -u origin HEAD`. Acceptance: as in P0-T35. Record in regression-testing/phase3-commit.<timestamp>.md.

### Phase 4 — Pester Consumer

- [ ] [P4-T1] Create `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1` with this fixed structure:
      - Comment-based help describing the corpus, the detection-level scope, and the optional override parameter.
      - A file-level parameter block declaring one optional hashtable parameter named CorpusOverride. The mutation demonstration passes an in-memory corpus through it with New-PesterContainer -Data; normal runs leave it unset.
      - Discovery-time section, outside BeforeAll (the pattern of the existing Pester parity driver, read-only): resolve the repository root from $PSScriptRoot four levels up with Resolve-Path; use CorpusOverride when supplied, otherwise read the corpus file with Get-Content -Raw and ConvertFrom-Json -AsHashtable; build $caseList as one hashtable per case with keys CaseId and Case (not the raw case, because its input key would collide with the automatic $input variable); build $corpusData as a one-element array holding a hashtable with key Corpus.
      - BeforeAll: resolve the repository root again from $PSScriptRoot four levels up with Resolve-Path (discovery-time variables are not visible at run time in Pester 5), then import BlastRadius.psm1 first and BlastRadiusConfig.psm1 second from .claude/lib/blast-radius under that root, and read both committed configurations as hashtables.
      - Describe named exactly "BlastRadius regression corpus for issue 452", with 26 It blocks:
        - Context "Corpus contract": seven It blocks, each using -ForEach $corpusData, mirroring Python tests 1 through 7 (top-level shape; case shape; id set equals the 17 spec ids and ids are unique; direction consistency; pairing rules; both directions per gap; plan-line intent rule with the backtick built as [char]0x60).
        - Context "Detection-level verdicts": It "reports the corpus verdict for <CaseId>" -ForEach $caseList. radius_pair calls Test-BlastRadiusConflict on the two input radii; plan_pair derives both radii with Get-BlastRadius (SpecText empty) under the self-hosted configuration first. The verdict is read from the conflict key of the returned hashtable (the hashtable itself is always truthy) and asserted with Should -Be and a -Because text containing the case id; the ordered reasons are compared as the joined "kind|detail" sequence with a -Because text containing the case id.
        - Context "Bundled configuration parity": one It asserting that the sorted Get-ConfigRootSurface results over the two committed configurations are equal and non-empty.
        - Context "Tolerance branch": one It. Branch NOT FOUND: the body calls Set-ItResult -Skipped -Because with exactly the Python skip reason from P3-T1. Branch FOUND: the assertions named by the P0-T29 planner revision.
      - The corpus reaches every It only through -ForEach data, never through a BeforeAll re-read, so CorpusOverride governs every assertion.
      - The prohibited-string list of P3-T1 applies to this file as well; additionally, no scope-qualified variable is written immediately before a slash or backslash. No TestDrive, temporary file, git invocation, or external process; at most 500 lines.
      Acceptance: verified by P4-T2 and Phase 7.
- [ ] [P4-T2] Run the Pester consumer. First call the MCP tool mcp__drm-copilot__run_poshqc_test with workspace_root set to the worktree root and scan_folders set to tests/scripts/claude-lib/blast-radius, and record the call disposition (route compliance). Then run `sh <scratchpad>/run-ps.sh <scratchpad>/poshqc-test.ps1 -ScanFolder tests/scripts/claude-lib/blast-radius` (repository runsettings through the self-hosted module) and `sh <scratchpad>/run-ps.sh <scratchpad>/junit-report.ps1 -NameFilter "regression corpus for issue 452"`. Acceptance (branch NOT FOUND): `FILTER matched=26`, with 25 PASS lines and one SKIP line whose name contains "Tolerance branch", and no FAIL line; 17 PASS lines contain "reports the corpus verdict for", including the g1-plan-quality-tiers-mandate-read and g1-radius-quality-tiers names; the folder's `ALL total=` equals the P0-T28 total plus 26 and its `fail=` equals the P0-T28 value. Zero matched testcases is a failure. Branch FOUND: 26 PASS lines. Write regression-testing/phase4-pester-consumer-run.<timestamp>.md.
- [ ] [P4-T3] [expect-fail] Pester mutation demonstration, in memory only. Write `<scratchpad>`/pester-mutation.ps1 with exactly this body:
      ```powershell
      param([Parameter(Mandatory = $true)][string] $CaseId, [switch] $NoFlip)
      $ErrorActionPreference = 'Stop'
      Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop
      $repoRoot = (Resolve-Path -LiteralPath '.').Path
      $corpusPath = Join-Path $repoRoot 'tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json'
      $testPath = Join-Path $repoRoot 'tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1'
      $corpus = Get-Content -LiteralPath $corpusPath -Raw | ConvertFrom-Json -AsHashtable
      $target = @($corpus['cases'] | Where-Object { $_['id'] -eq $CaseId })
      if ($target.Count -ne 1) { throw "Case $CaseId was not found exactly once." }
      if (-not $NoFlip) {
          $flip = $target[0]
          if ($flip['direction'] -eq 'must-conflict') {
              $flip['direction'] = 'must-not-conflict'
              $flip['expected'] = @{ conflict = $false; reasons = @() }
          }
          else {
              $paired = @($corpus['cases'] | Where-Object { $_['id'] -eq $flip['paired_case_id'] })[0]
              $flip['direction'] = 'must-conflict'
              $flip['expected'] = @{ conflict = $true; reasons = @($paired['expected']['reasons']) }
          }
      }
      $container = New-PesterContainer -Path $testPath -Data @{ CorpusOverride = $corpus }
      $result = Invoke-Pester -Container $container -PassThru -Output None
      Write-Output "CaseId=$CaseId Flipped=$(-not $NoFlip) TotalCount=$($result.TotalCount) PassedCount=$($result.PassedCount) FailedCount=$($result.FailedCount) SkippedCount=$($result.SkippedCount)"
      foreach ($failed in $result.Failed) { Write-Output "FAILED: $($failed.ExpandedPath)" }
      ```
      Run the control `sh <scratchpad>/run-ps.sh <scratchpad>/pester-mutation.ps1 -CaseId g1-plan-poetry-lock -NoFlip`, then one flip at a time: `sh <scratchpad>/run-ps.sh <scratchpad>/pester-mutation.ps1 -CaseId g1-plan-poetry-lock`, the same with -CaseId g1-plan-different-surfaces, with -CaseId g2-glob-vs-dir, and with -CaseId g2-dir-vs-sibling-glob. Then run `git status --porcelain -- tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json` and `git diff --exit-code HEAD -- tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json`. Acceptance: the control prints `FailedCount=0` with TotalCount 26 (proving the override path runs the full suite unchanged); each of the four flips prints `FailedCount=` of at least 1 and a `FAILED:` line containing "reports the corpus verdict for" followed by the flipped case id (additional failures from the "Corpus contract" context, caused by the flipped direction breaking the pairing and direction meta-tests, are recorded and expected); the porcelain capture is empty and the anchored diff exits 0. Write regression-testing/phase4-pester-mutation-demonstration.<timestamp>.md with all outputs and an `[expect-fail]` note.
- [ ] [P4-T4] Commit and push Phase 4: `git add tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1 docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2`, `git status --porcelain`, `git commit -F <scratchpad>/commit-phase4.txt` (summary "test(452): add Pester consumer of the regression corpus"), `git push -u origin HEAD`. Acceptance: as in P0-T35. Record in regression-testing/phase4-commit.<timestamp>.md.

### Phase 5 — Tolerance Branch and Detection-Level Evidence

- [ ] [P5-T1] Record the tolerance-branch resolution (AC-15). Branch NOT FOUND: from the P3-T2 and P4-T2 outputs, record (a) the P0-T29 search result, (b) the Python SKIPPED line and the Pester SKIP line, both carrying the reason that contains "#722", and (c) for each of the eight must-conflict cases (g1-plan-poetry-lock, g1-plan-package-lock, g1-radius-quality-tiers, g2-dir-vs-glob, g2-glob-vs-dir, g2-artifacts-dir-vs-glob, g2-artifacts-glob-vs-dir, g2-empty-modules-dir-vs-glob) its Python PASSED node ID, its Pester PASS name, and its corpus expected verdict and reasons, as the detection-level evidence recorded in place of the tolerance assertion. Also run `grep -c -F -e "#722" tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`, which must report at least 1 for each file. Branch FOUND: record the passing tolerance test in both consumers. Acceptance: the artifact regression-testing/phase5-tolerance-branch.<timestamp>.md exists with all listed items and names the branch taken.
- [ ] [P5-T2] Commit and push Phase 5 with the P0-T35 command sequence (message file `<scratchpad>`/commit-phase5.txt, summary "test(452): record tolerance branch evidence"). Acceptance: as in P0-T35. Record in regression-testing/phase5-commit.<timestamp>.md.

### Phase 6 — Python Final QA Loop

Loop order: P6-T1 through P6-T7. If any step fails or changes a file, fix the cause and restart from P6-T1; record the iteration number in every artifact.

- [ ] [P6-T1] Format the Python consumer: `poetry run black tests/scripts/dev_tools/test_blast_radius_regression_452.py`. Acceptance: EXIT_CODE 0 and the output contains "1 file left unchanged." and does not contain "reformatted" (black prints "All done!" and "N files left unchanged." on a clean run, as observed in the v1 final-QA record); a "1 file reformatted." line means the formatter changed the file and the loop restarts from P6-T1 after recommitting. Write qa-gates/final-python-black.<timestamp>.md.
- [ ] [P6-T2] Repository-wide format check: `poetry run black --check .`. Acceptance: the set of "would reformat" files is a subset of the P0-T20 set and does not contain the consumer file; an empty baseline set requires EXIT_CODE 0. Write qa-gates/final-python-black-check.<timestamp>.md.
- [ ] [P6-T3] Lint: `poetry run ruff check .`. Acceptance: the finding set is a subset of the P0-T21 set and contains no finding in the consumer file; with a clean baseline the output is "All checks passed!" with EXIT_CODE 0. If ruff reports "Fixed" or "fixes applied", a file changed and the loop restarts from P6-T1. Write qa-gates/final-python-ruff.<timestamp>.md.
- [ ] [P6-T4] Type check: `poetry run pyright`. Acceptance: the error set is a subset of the P0-T22 set and contains no diagnostic in the consumer file; with a clean baseline the summary reads "0 errors". Write qa-gates/final-python-pyright.<timestamp>.md.
- [ ] [P6-T5] Repository-wide tests with coverage: `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`, then `poetry run python <scratchpad>/coverage_totals.py`. Acceptance: collected count equals the P0-T23 collected count plus 26; the failed node-ID set is a subset of the P0-T23 failed set; skipped count equals the P0-T23 skipped count plus 1 (branch NOT FOUND) or plus 0 (branch FOUND); `TOTAL_LINE=` percent is at least 85.00 and `TOTAL_BRANCH=` percent is at least 75.00, both read from the helper output and neither lower than the P0-T23 values; `GENERATED_AT=` is later than the task start. Write qa-gates/final-python-pytest-coverage.<timestamp>.md with the numeric values in Output Summary.
- [ ] [P6-T6] Targeted coverage with the dotted form: `poetry run pytest tests --cov=scripts.dev_tools._blast_radius_conflicts --cov=scripts.dev_tools._blast_radius_glob --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_validation --cov=scripts.dev_tools.compute_blast_radius --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`, then `poetry run python <scratchpad>/coverage_totals.py`. Acceptance: targeted `TOTAL_LINE=` at least 85.00, `TOTAL_BRANCH=` at least 75.00, and each of the five `FILE` line and branch values not lower than its P0-T24 value. Write qa-gates/final-python-pytest-targeted-coverage.<timestamp>.md.
- [ ] [P6-T7] Consumer-only coverage, recording what the new tests exercise on their own: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_regression_452.py --cov=scripts.dev_tools._blast_radius_conflicts --cov=scripts.dev_tools._blast_radius_glob --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_validation --cov=scripts.dev_tools.compute_blast_radius --cov-branch --cov-report=term-missing`. Acceptance: EXIT_CODE 0; the summary reads "25 passed, 1 skipped" (NOT FOUND) or "26 passed" (FOUND); the term-missing table lists the five modules with numeric Stmts and Miss values, recorded as informational per-module figures (no threshold is applied to a single-file run). Write qa-gates/final-python-consumer-coverage.<timestamp>.md.
- [ ] [P6-T8] No new suppression and no coverage exclusion: run `grep -c -E "noqa|type: ignore|pragma: no cover" tests/scripts/dev_tools/test_blast_radius_regression_452.py` and `git diff --name-only origin/main...HEAD` together with `git status --porcelain`. Acceptance: the grep prints 0 (grep exits 1 on zero matches, the expected exit code here); neither the diff nor the porcelain capture lists pyproject.toml or any other coverage configuration. Write qa-gates/final-python-no-new-suppression.<timestamp>.md.
- [ ] [P6-T9] Commit and push Phase 6 with the P0-T35 command sequence plus the consumer file if P6-T1 reformatted it (message file `<scratchpad>`/commit-phase6.txt, summary "test(452): record Python final QA"). Acceptance: as in P0-T35. Record in qa-gates/phase6-commit.<timestamp>.md.

### Phase 7 — PowerShell Final QA Loop

Loop order: P7-T1 through P7-T3. If any step fails or changes a file, fix the cause and restart from P7-T1; record the iteration number in every artifact. Numeric evidence follows the fixed Pester evidence derivation in Execution Conventions.

- [ ] [P7-T1] Format. Run `sh <scratchpad>/run-ps.sh <scratchpad>/file-hashes.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`, call the MCP tool mcp__drm-copilot__run_poshqc_format with workspace_root set to the worktree root and scan_folders set to tests/scripts/claude-lib/blast-radius, then run the same hash command again. Then run the repository's own formatter entry point, which the CI format check calls: `sh <scratchpad>/run-ps.sh <scratchpad>/poshqc-format.ps1 -ScanFolder tests/scripts/claude-lib/blast-radius`, then the hash command a third time, then `git status --porcelain -- tests/scripts/claude-lib/blast-radius`. Acceptance: the MCP call returns (disposition `EXIT_CODE: 0`); all three hashes are identical, meaning the file was left unchanged by both formatters; the helper prints `SELF_HOSTED_FORMAT_DONE=True`; the porcelain capture lists nothing except the new Pester file before its commit. A changed hash means the file was formatted and the loop restarts from P7-T1 after recommitting. Any existing file listed by the porcelain capture is restored with `git restore -- tests/scripts/claude-lib/blast-radius` as in P0-T25, after any formatter change to the Pester file has been committed under the restart rule so the restore cannot revert it, and is recorded as pre-existing drift outside this plan's write set. Write qa-gates/final-powershell-format.<timestamp>.md.
- [ ] [P7-T2] Analyze. Call the MCP tool mcp__drm-copilot__run_poshqc_analyze with the same workspace_root and scan_folders and record the disposition; then run `sh <scratchpad>/run-ps.sh <scratchpad>/pssa-count.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1` and `sh <scratchpad>/run-ps.sh <scratchpad>/pssa-count.ps1 -Path tests/scripts/claude-lib/blast-radius`. Acceptance: the MCP call returns; the first helper run prints `PSSA_FINDINGS=0`; the folder run's finding set is a subset of the P0-T26 set. Write qa-gates/final-powershell-analyze.<timestamp>.md.
- [ ] [P7-T3] Test with coverage, repository-wide. Run `sh <scratchpad>/run-ps.sh <scratchpad>/clear-pester-artifacts.ps1`, call the MCP tool mcp__drm-copilot__run_poshqc_test with workspace_root set to the worktree root and no scan_folders override (record disposition), then run `sh <scratchpad>/run-ps.sh <scratchpad>/poshqc-test.ps1`, `sh <scratchpad>/run-ps.sh <scratchpad>/junit-report.ps1 -NameFilter "regression corpus for issue 452"`, and `sh <scratchpad>/run-ps.sh <scratchpad>/coverage-line.ps1`. Acceptance: `ALL total=` equals the P0-T27 total plus 26; the `FAILED_ANY:` name set is a subset of the P0-T27 set; `FILTER matched=26` with no FAIL line (25 PASS and one SKIP in branch NOT FOUND); the `LINE ... percent=` value is at least 85.00 and not lower than the P0-T27 value. Write qa-gates/final-powershell-pester-coverage.<timestamp>.md with the numeric values in Output Summary.
- [ ] [P7-T4] Commit and push Phase 7 with the P0-T35 command sequence plus the Pester file if P7-T1 changed it (message file `<scratchpad>`/commit-phase7.txt, summary "test(452): record PowerShell final QA"). Acceptance: as in P0-T35. Record in qa-gates/phase7-commit.<timestamp>.md.

### Phase 8 — Cross-Cutting Gates and Coverage Delta

- [ ] [P8-T1] Scope and non-goals (AC-8 no-correction half, AC-17). Run `git diff --name-status origin/main...HEAD` and `git status --porcelain`. Acceptance (branch NO-CORRECTION-REQUIRED): the diff lists exactly three added (A) files, the corpus and the two consumers, plus added or modified paths under docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2, and nothing else: no path under scripts, .claude/lib, extensions, config, or .github; no v1 feature-root document; no existing file of the fixture corpus; no existing test file; no TypeScript file. The porcelain capture lists no path outside the v2 folder. Write qa-gates/final-non-goals-scope-diff.<timestamp>.md with both outputs.
- [ ] [P8-T2] Coverage delta. From the P0-T23, P0-T24, P0-T27, P6-T5, P6-T6, and P7-T3 artifacts, tabulate baseline versus final for Python repository-wide line and branch percent, Python targeted line and branch percent and the five per-module values, and PowerShell repository-wide line percent. Record new or changed production-code coverage as not applicable, with the reason that P8-T1 shows zero changed production lines (branch NO-CORRECTION-REQUIRED). Acceptance: every value is numeric; no final value is below its baseline; the Python thresholds of 85% line and 75% branch and the PowerShell threshold of 85% line hold. A missing value makes this task remediation-required, never PASS. Write qa-gates/final-coverage-delta.<timestamp>.md.
- [ ] [P8-T3] Loading constraints (AC-16). Run `grep -c -E 'os\.getcwd|cwd\(|Get-Location|origin/main|subprocess|tmp_path|TestDrive|New-TemporaryFile|[A-Za-z]:[\\/]' tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`, then the positive control `grep -c -E '__file__|PSScriptRoot' tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`. Acceptance: the first command prints a count of 0 for each file (exit code 1, expected); the positive control prints at least 1 for each file, proving the search reads both files and that each loads relative to its own location. Write qa-gates/final-loading-constraints.<timestamp>.md.
- [ ] [P8-T4] Merge-order independence (AC-14). Run `grep -c -E 'compute_cohorts|pcoh_compute_cohorts|parallel_cohort|parallel_drift|parallel_mutation|recompute_conflicts_with_observed' tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`, then the positive control `grep -c -E 'conflicts\(|Test-BlastRadiusConflict' tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`. Acceptance: 0 for each file in the first command; at least 1 for each file in the second, which shows the verdict assertions are made on the contention result. Write qa-gates/final-merge-order-independence.<timestamp>.md.
- [ ] [P8-T5] Line counts (AC-18): `sh <scratchpad>/run-ps.sh <scratchpad>/line-counts.ps1 tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`. Acceptance: EXIT_CODE 0 and both `LineCount=` values are at most 500 (physical line count, not the non-empty count). Write qa-gates/final-line-counts.<timestamp>.md.
- [ ] [P8-T6] Bundled-configuration parity evidence (AC-13). From P3-T2, record the PASSED node ID ending in test_bundled_separator_free_shared_surfaces_equal_the_self_hosted_subset; from P7-T3, record the PASS line whose name contains "Bundled configuration parity". Acceptance: both are present. Write qa-gates/final-bundled-parity.<timestamp>.md.
- [ ] [P8-T7] Commit and push Phase 8 with the P0-T35 command sequence (message file `<scratchpad>`/commit-phase8.txt, summary "test(452): record cross-cutting gates and coverage delta"). Acceptance: as in P0-T35. Record in qa-gates/phase8-commit.<timestamp>.md.

### Phase 9 — Acceptance-Criteria Check-Off, Pull Request, and CI

The execution child owns every acceptance-criterion check-off in this phase, including the CI-dependent ones (AC-21, CI green on the pull request head; AC-22, the pull-request body containing "Fixes #452"), and must commit and push those check-offs before reporting done, because the parent cannot commit from the coordinator root.

- [ ] [P9-T1] Edit `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md`: change only the checkbox marker of AC-1 through AC-20 from "- [ ]" to "- [x]", leaving each criterion's text unchanged; evidence pointers are recorded only in the P9-T2 traceability artifact. Do not check AC-21 or AC-22 here. Run `grep -c -e '^- \[x\] ' docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md` and `grep -c -e '^- \[ \] ' docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md`. Acceptance: the counts are 20 and 2. An AC whose evidence is missing stays unchecked and the phase is remediation-required.
- [ ] [P9-T2] Write other/ac-traceability.<timestamp>.md mapping AC-1 through AC-22 to task IDs and evidence paths, following the Acceptance Criteria Traceability section of this plan, re-read from the updated spec and cross-checked against the artifacts on disk. Acceptance: 22 entries; each of AC-1 through AC-20 names at least one task ID and one existing evidence path; AC-21 and AC-22 are marked pending P9-T4 and P9-T5.
- [ ] [P9-T3] Commit and push the check-offs with the P0-T35 command sequence (message file `<scratchpad>`/commit-phase9a.txt, summary "docs(452): check off v2 acceptance criteria AC-1 to AC-20"). Acceptance: as in P0-T35. Record in qa-gates/phase9-commit-a.<timestamp>.md.
- [ ] [P9-T4] Pull request and body (AC-22). Run `gh pr view --json number,url,body,headRefOid,baseRefName`. If no pull request exists for the branch, stop and return to the orchestrator with the line PR_REQUIRED: bug/blast-radius-under-reporting-regression-452; the orchestrator authors the pull request through the pr-author skill, targeting main, with a body containing the literal text "Fixes #452", and then resumes this plan at P9-T4. Do not create it with a raw gh pr create command. On resumption, re-run the view command. Acceptance: EXIT_CODE 0; baseRefName is main (the CI workflow triggers only on pull requests into main or development); the body contains "Fixes #452"; the headRefOid equals `git rev-parse HEAD`. Write qa-gates/final-pr-body.<timestamp>.md (pull-request number and URL are recorded; no host path).
- [ ] [P9-T5] CI on the pull-request head (AC-21). Run `gh pr checks --watch --interval 60` until it returns, then `gh pr checks --required`. Acceptance: every required check reports pass; the listing includes passing checks whose names contain "Code Quality & Tests" (the pytest job, ubuntu-latest) and "PowerShell QC" (the Pester job, windows-latest); the head SHA from P9-T4 is recorded. A failing check is diagnosed from its log, fixed, committed, pushed, and re-watched; zero checks after the push is investigated as a merge conflict, an Actions outage, or a trigger mismatch before any other cause. Write qa-gates/final-ci-pr-head.<timestamp>.md.
- [ ] [P9-T6] Edit `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md` changing only the checkbox markers of AC-21 and AC-22 from "- [ ]" to "- [x]" (criterion text unchanged), update other/ac-traceability.<timestamp>.md accordingly, then commit and push with the P0-T35 command sequence (message file `<scratchpad>`/commit-phase9b.txt, summary "docs(452): check off CI-dependent acceptance criteria"). Acceptance: `grep -c -e '^- \[x\] ' docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md` prints 22 and `grep -c -e '^- \[ \] ' docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md` prints 0; the push succeeds and `git rev-parse HEAD` equals `git rev-parse @{upstream}`. Write no artifact for this commit; return the four command outputs and the pushed SHA in the completion report together with the P9-T7 results.
- [ ] [P9-T7] Re-verify CI on the new head created by P9-T6: run `gh pr view --json headRefOid`, then `gh pr checks --watch --interval 60`, then `gh pr checks --required`. Acceptance: the headRefOid equals the SHA pushed in P9-T6 and every required check passes on it, including the "Code Quality & Tests" and "PowerShell QC" checks. If any required check fails on this head, uncheck AC-21, commit and push that change, and report the failure instead of completion. Only after this task passes does the execution child report done. This task writes no repository file: committing a new artifact here would create a further head that CI has not yet verified, so the check-offs committed in P9-T6 (with the P9-T5 artifact) are the final committed state, and the final-head SHA and check results from this task are returned in the completion report to the orchestrator.
