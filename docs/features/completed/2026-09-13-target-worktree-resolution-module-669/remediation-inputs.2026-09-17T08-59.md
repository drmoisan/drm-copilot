# Remediation Inputs: Target Worktree Resolution Module (#669)

- **Produced by:** feature-review agent, 2026-09-17T08:59-04:00
- **Feature folder:** `docs/features/active/2026-09-13-target-worktree-resolution-module-669`
- **Base / head:** `origin/epic/worktree-scoped-state-resolution-integration` @ `79fd5a95c00cd99238b69a3195788206ae96f4cd` .. `feature/2026-09-13-target-worktree-resolution-module-669` @ `8f82ffbf091e4b1485219ebd2d3aac6a726f3cfb`
- **Blocking finding count:** 1
- **Source audit artifacts:**
  - `docs/features/active/2026-09-13-target-worktree-resolution-module-669/policy-audit.2026-09-17T08-59.md`
  - `docs/features/active/2026-09-13-target-worktree-resolution-module-669/code-review.2026-09-17T08-59.md`
  - `docs/features/active/2026-09-13-target-worktree-resolution-module-669/feature-audit.2026-09-17T08-59.md`
- **PR context artifacts:** `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`
- **Acceptance criteria status:** 51 of 51 PASS in each of `spec.md` and `user-story.md`; no criterion is reopened by this remediation.

---

## Remediation-Required Findings

### R1 — Repo-wide PowerShell coverage has not been measured with the new modules

- Severity: Blocking
- Category: coverage evidence (policy audit Section 1.2 "No Coverage Regression"; Section 1.2.1 PowerShell disposition FAIL)
- Affected artifact: `artifacts/pester/powershell-coverage.xml`
- Finding: The canonical PowerShell coverage artifact was last written at 2026-09-17 08:41:47 by `Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib')`. Its report-level LINE counter is covered=3243, missed=6336 (33.86%), because only the `tests/scripts/claude-lib` suites ran against the full in-repo coverage denominator of 9579 lines. The only repo-wide run on the branch (`mcp__drm-copilot__run_poshqc_test`, 95.48%, 8914/9336) used installed-extension runsettings whose denominator leaves out both new modules (Ruling D). No run measures repo-wide PowerShell line coverage with `.claude/lib/worktree-resolution/WorktreeResolution.psm1` and `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` in the denominator. The expected value of about 95.57% is arithmetic and cannot replace a measurement under the fail-closed evidence rule.
- Not in question: Per-file coverage of the new modules (98.59% and 100.00%) is measured and meets the 85% threshold. Acceptance criterion 42 remains PASS.
- Expected behaviour after remediation: `artifacts/pester/powershell-coverage.xml` is produced by a repo-wide self-hosted run using the in-repo runsettings. Its report-level LINE percentage is at or above 85%, and it contains a `package` whose `name` ends with `worktree-resolution` with both `sourcefile` rows at or above 85%.
- Required actions:
  1. From the worktree root, run the self-hosted PoshQC test stage with no scan-folder restriction: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path`.
  2. Leave the resulting `artifacts/pester/powershell-coverage.xml` in place; it is the canonical artifact the review reads.
  3. Write `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/repo-wide-powershell-coverage.<timestamp>.md` with the command, the exit code, the verbatim Pester summary line, the report-level `counter[@type='LINE']` (covered, missed, percentage), and the two `worktree-resolution` per-file LINE rows.
  4. Record the failing-test set of that run and confirm it is a subset of the baseline failure set (`enforce-pr-author-skill.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`).
- Verification commands:
  - `[xml]$x = Get-Content -Raw artifacts/pester/powershell-coverage.xml; $x.report.counter | Where-Object type -eq 'LINE'`, which must yield covered / (covered + missed) >= 0.85.
  - `$x.report.package | Where-Object { $_.name -like '*worktree-resolution' } | ForEach-Object { $_.sourcefile } | ForEach-Object { $_.name; $_.counter | Where-Object type -eq 'LINE' }`, which must show both modules at 85% or above.
- Acceptance for closure: the evidence file in step 3 exists and both thresholds hold. If the repo-wide figure is below 85%, report that result as found rather than restricting the run.

---

## Non-Blocking Findings (for awareness; not required for this cycle)

These are recorded in `code-review.2026-09-17T08-59.md`. They do not block F1 and are listed so the planner does not treat them as in scope for R1.

- Major (F4 input): absolute-path placement in `Get-WorktreeResolutionSignalCandidate` does not check candidate-set membership or path existence, so a path under a removed nested worktree resolves to the main checkout.
- Major (F4 input): `-Text` scanning extracts Branch signals from any `...branch: <name>` prose and FilePath signals from any absolute path, which can turn whole delegation prompts into fail-closed `Ambiguous` results.
- Minor: read seams suppress I/O errors with `-ErrorAction SilentlyContinue`.
- Minor: enumeration includes prunable worktrees in branch matching.
- Minor: scope-boundary and inventory evidence name `d93e2916` rather than the resolved merge base `79fd5a95`. The conclusions still hold.
- Minor: the single-pass toolchain criterion was satisfied under a baseline-relative reading; the repository-wide test stage exits 2 on base and head because of two pre-existing failures.

---

## Do-Not-Do List

- Do not modify `.claude/lib/worktree-resolution/*.psm1`, the bundle mirrors, `core.json`, or either runsettings copy for R1. R1 is an evidence gap, not a code defect.
- Do not add `-ScanFolders`, exclusions, or any narrowing to the R1 test run, and do not add any `CodeCoverage.Path` exclusion.
- Do not substitute the MCP runner's figure or the arithmetic estimate for the self-hosted repo-wide measurement.
- Do not edit any file under `.claude/hooks/`, `.codex/hooks/`, or `extensions/drm-copilot/src/`. The feature's scope boundary forbids consumer changes.
- Do not change the text of any acceptance criterion, and do not uncheck or re-check criteria for R1.
- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not write evidence outside `docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/<kind>/`.
- Do not attempt to fix the two pre-existing failing tests in this cycle; they are outside the feature's scope.
