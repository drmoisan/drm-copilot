# Feature Audit: Platform-independent Pester fixtures (#1067)

**Audit Date:** 2026-11-04
**Feature Folder:** `docs/features/active/2026-11-03-pester-fixtures-platform-independent-1067`
**Base Branch:** `main`
**Head Branch:** `bug/pester-fixtures-platform-independent`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (origin/main at 11f188d1b4f3726d854ddc00f8ad4c810138f049)
- **Head branch/commit:** `bug/pester-fixtures-platform-independent` (commit 089e55e5c331889cb98066b436b2416e478d62ed)
- **Merge base:** 11f188d1b4f3726d854ddc00f8ad4c810138f049
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-04 15:22 UTC at head 089e55e5c)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/**`, `evidence/regression-testing/**`, `evidence/qa-gates/**`, `evidence/other/**` in this feature folder
  - Additional evidence: reviewer reruns at HEAD (Pester over the two trees: 953 tests, 0 failed; PSSA 0 findings; formatter 0 differences; mirror `cmp` identical; coverage XML parse)
- **Feature folder used:** `docs/features/active/2026-11-03-pester-fixtures-platform-independent-1067`
- **Requirements source:** `spec.md` `## Acceptance Criteria`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the only acceptance-criteria source.
- **Scope note:** The final merge 089e55e5c brought main's PR #1073 changes (including `HostBootstrap.Versions.Tests.ps1` and additions to the in-scope `HostBootstrap.Invoke.Tests.ps1`) after the executor's last runs; the reviewer's HEAD run covers them.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — only source

### Acceptance criteria

1. A single-process Invoke-Pester run on Linux over the 17 suites listed under Scope reports 0 failures, and a single-process run over the full `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` trees reports 0 failures; both runs are recorded under `evidence/regression-testing/`.
2. The Windows CI shards pass on the final PR head: the required check `poshqc / PowerShell QC` and every shard job `poshqc / PowerShell QC shard <n>` on `windows-latest` report success.
3. D1 regression: `activate.Tests.ps1` `Get-VenvAwarePrompt (prompt decision used by the shim)` / `renders a descendant prompt from the venv parent (light background)` and the new descendant-separator `It` under `Get-RepoRelativePrompt (pure logic)` fail on Linux before the `activate.ps1` change and pass after; Windows prompt output is unchanged.
4. D2 regression: the new relative-path `It` blocks under `HostBootstrapWorkspace.Tests.ps1` `Resolve-WorkspaceRoot` and `Resolve-ProjectRepoRoot` fail on Linux before the `HostBootstrapWorkspace.psm1` change and pass after; each restores the PowerShell location and `[Environment]::CurrentDirectory` in `finally`.
5. D3 regression: the new relative-path `It` blocks under `Enter-DrmCopilotShell.Tests.ps1` `Get-DrmCopilotNormalizedPath` and `Resolve-DrmCopilotActivationScriptPath` fail on Linux before the `DrmCopilotPromptSupport.ps1` change and pass after; each restores the PowerShell location and `[Environment]::CurrentDirectory` in `finally`.
6. D4 regression: `PoshQC.ScanConfig.Tests.ps1` `Get-PoshQCScanConfigFolder` / `throws an error naming the file for an absolute-path entry` with the `C:/absolute/path` entry fails on Linux before the `PoshQC.ScanConfig.psm1` change and passes after, and the added `/absolute/path` case passes; `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1` is byte-identical to `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1`.
7. No test in the 17 suites writes to the real file system, creates temporary files, uses TestDrive, or uses `-Skip`; `PoshQC.ScanFolders.Tests.ps1` and `PoshQC.TestingCommands.Tests.ps1` assert a mocked `New-Item` with the expected coverage directory.
8. Isolation: a seeded shuffled single-process file-order run of the touched suites with at least three recorded seeds, a fresh single-process run over `tests/scripts`, and a concurrent-shard `Invoke-PoshQCParallelTest` run each report 0 failures attributable to the touched suites; any pre-existing unrelated failure is recorded with its suite. `$env:POSHQC_SKIP_SCRIPT_EXECUTION`, the global prompt and `global:` functions, and `$global:LASTEXITCODE` are restored by `sync-agents-from-instructions.Tests.ps1`, `Enter-DrmCopilotShell.Tests.ps1`, and `Test-DiscoveryHostCapability.Entry.Tests.ps1` respectively.
9. Per-file line coverage of each changed source file (`activate.ps1`, `HostBootstrapWorkspace.psm1`, `DrmCopilotPromptSupport.ps1`, `PoshQC.ScanConfig.psm1`) is at least 85% in `artifacts/pester/powershell-coverage.xml`, with no coverage regression on changed lines.
10. The full PowerShell toolchain is clean in one pass (PoshQC format, PSScriptAnalyzer with the repository settings, Pester), and the bundle-mirror contract tests pass for the ScanConfig mirror.
11. No personal user-profile path, host name, or user name remains in any touched fixture, including `Enter-DrmCopilotShell.Tests.ps1`.
12. The open owner decision on adding `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` to the `ubuntu-latest` PowerShell leg is recorded in this spec under Rollout & Follow-up, with its reasons.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Linux 17-suite and two-tree runs report 0 failures, recorded | PASS | `evidence/regression-testing/linux-17-suites.2026-11-04T14-43.md` (317 tests, 0 failed); `evidence/regression-testing/linux-two-trees.2026-11-04T14-44.md`; reviewer HEAD run 953 tests, 944 passed, 0 failed, 9 skipped | `pwsh -File <scratch>/fr1067-pester.ps1 -Root <worktree>` | Reviewer run includes main's merged suites. |
| 2 | Windows CI shards pass on the final PR head | PENDING-CI | No PR exists yet (`pr_context.summary.txt`: "no PR exists yet for this branch") | S9: `gh pr checks` on the final head | CI-dependent; owned by the item's orchestrator run at S9. Left unchecked. |
| 3 | D1 regression fail-before / pass-after; Windows output unchanged | PASS | `evidence/regression-testing/fail-before-d1.2026-11-04T04-00.md`, `pass-after-d1.2026-11-04T04-00.md`; diff: `[System.IO.Path]::DirectorySeparatorChar` is `\` on Windows | `git diff 11f188d1b HEAD -- scripts/dev-tools/activate.ps1` | Byte-identical Windows output follows from the constant. |
| 4 | D2 regression fail-before / pass-after; restore in `finally` | PASS | `fail-before-d2.2026-11-04T04-02.md` (2 new tests fail), `pass-after-d2.2026-11-04T04-02.md`; diff shows `Push-Location`/`[Environment]::CurrentDirectory` restored in `finally` | `git diff 11f188d1b HEAD -- tests/scripts/dev-tools/HostBootstrapWorkspace.Tests.ps1` | |
| 5 | D3 regression fail-before / pass-after; restore in `finally` | PASS | `fail-before-d3.2026-11-04T04-03.md`, `pass-after-d3.2026-11-04T04-04.md`; diff inspection of both new contexts | `git diff 11f188d1b HEAD -- tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1` | `Test-Path` mocked in the activation-path test. |
| 6 | D4 regression; mirror byte-identical | PASS | `fail-before-d4.2026-11-04T04-04.md`, `pass-after-d4.2026-11-04T04-05.md` (3 cases pass); reviewer `cmp` exit 0; `mirror-contracts.2026-11-04T14-47.md` hashes equal | `cmp scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1 extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.ScanConfig.psm1` | |
| 7 | No real writes, temp files, TestDrive, `-Skip`; mocked `New-Item` asserted | PASS | `evidence/qa-gates/prohibited-constructs.2026-11-04T15-16.md` (0 matches); reviewer grep over the changed suites: 0 matches; porcelain empty after reviewer run; `InModuleScope PoshQC` `Should -Invoke -CommandName New-Item -Times 1 -Exactly` in both suites | `git status --porcelain --untracked-files=all` | |
| 8 | Isolation runs and state restores | PASS | `isolation-shuffle.2026-11-04T14-48.md` (seeds 1067, 2026, 7; 0 failed; probes clean); `isolation-fresh-tests-scripts.2026-11-04T15-06.md` (14,153 tests, 0 failed); `isolation-parallel.2026-11-04T15-15.md` (0 failures, 17 suites present); diff shows the three restores | see evidence files | Two out-of-diff suites still leak the environment variable (code-review Info finding); no failure attributable. |
| 9 | Per-file line coverage >= 85%, no changed-line regression | PASS | Reviewer parse of `artifacts/pester/powershell-coverage.xml`: 98.11%, 100%, 86.84%, 91.3%; `coverage-delta.2026-11-04T14-46.md`: 7 of 7 changed lines covered | `python3 -I <scratch>/cov1067.py artifacts/pester/powershell-coverage.xml` | The four sources are unchanged between the coverage run and HEAD. |
| 10 | Toolchain clean in one pass; mirror contracts pass | PASS | `format.2026-11-04T14-42.md`, `pssa.2026-11-04T14-42.md`, `mirror-contracts.2026-11-04T14-47.md` (24 passed); reviewer PSSA 0, formatter 0 differences | `pwsh -File <scratch>/fr1067-qa.ps1 -Root <worktree>` | |
| 11 | No personal path, host name, or user name in touched fixtures | PASS | Reviewer grep for `DanMoisan`, `C:\Users`, `/home/vscode`, `drmoisan` over the 17 changed suites: 0 matches | `grep -l -i -E 'DanMoisan|C:\\Users|/home/vscode|drmoisan'` | |
| 12 | Owner decision on the Linux leg recorded with reasons | PASS | spec.md `## Rollout & Follow-up`, "Open owner decision (Linux leg)" with reasons (a) and (b) | Read of spec.md | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 11 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC2, status PENDING-CI; verifiable only after the PR exists)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None in the branch. AC2 is a CI-dependent criterion owned by the S9 CI green gate.

**Recommended follow-up verification steps:**

1. At S9, confirm `poshqc / PowerShell QC` and every `poshqc / PowerShell QC shard <n>` job on `windows-latest` report success on the final PR head, then check off AC2 in spec.md and re-run the gate on the new head.
2. Decide whether to address the two out-of-diff `$env:POSHQC_SKIP_SCRIPT_EXECUTION` leaks within this item or separately (code-review Info finding).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

The executor had already checked off the 11 PASS criteria; the reviewer verified each independently and made no change to spec.md. AC2 remains unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-11-03-pester-fixtures-platform-independent-1067/spec.md`
- Total AC items: 12
- Checked off (delivered): 11
- Remaining (unchecked): 1
- Items remaining: The Windows CI shards pass on the final PR head: the required check `poshqc / PowerShell QC` and every shard job `poshqc / PowerShell QC shard <n>` on `windows-latest` report success.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 12 | 11 | 1 | Checkbox-backed; no reviewer edit required |
