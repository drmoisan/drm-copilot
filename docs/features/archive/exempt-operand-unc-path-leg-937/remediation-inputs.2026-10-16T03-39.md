# Remediation Inputs — Cycle 1

- Timestamp: 2026-10-16T03-39
- Issue: #937
- Branch: bug/exempt-operand-unc-path-leg-937 (HEAD `d8ad225b2b05011e45acfe11f3e8df19825ff908`)
- Source audits: `policy-audit.2026-10-16T03-39.md` (PA-0), `code-review.2026-10-16T03-39.md` (CR-0), `feature-audit.2026-10-16T03-39.md`
- Blocking count at entry: 1

Review-Verdict: REMEDIATION_REQUIRED

## Findings Requiring Remediation

### RI-1 (PA-0 / CR-0) — BLOCKING: canonical PowerShell coverage artifact below the 85% line floor

Remediability: autonomous
Remediability-Evidence: The shortfall comes from a scoped local test run; a full-suite PoshQC test run in the item worktree regenerates the artifact with no external dependency, policy change, or operator decision.

- Artifact: `artifacts/pester/powershell-coverage.xml` (gitignored; the feature-review contract's canonical PowerShell coverage path, also read by `.claude/hooks/validate-feature-review-coverage.ps1`).
- Observed: report LINE counter covered 8110, missed 4170 = 66.04% repo-wide. The paired `artifacts/pester/pester-junit.xml` reports 6335 tests, 0 failures. Both were written 2026-10-16 03:03 UTC by P3-T3 `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]`.
- Cause: the coverage population (`config/poshqc-coverage.json` roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`) spans all PowerShell production code, while only the two hook test folders ran.
- Reference: the full-suite CI artifact for the same code (run 38844097853, job `poshqc / PowerShell QC`, 10422 testcases) reads 90.41%, so no production or test change is expected.
- Rule: feature-review contract, Coverage Verification step 3 (repo-wide line coverage below the governing floor, 85% default, is FAIL and a remediation trigger).
- Required outcome:
  1. Produce a full-suite PowerShell coverage artifact at `artifacts/pester/powershell-coverage.xml`, for example `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = the item worktree and no `scan_folders` restriction, so that all suites under `tests/scripts` and `tests/powershell` run. The MCP result carries no counts, so read the values from the XML, not the MCP summary.
  2. Write `docs/features/active/exempt-operand-unc-path-leg-937/evidence/qa-gates/coverage-canonical.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, the report LINE counter, the junit test count, and the per-copy values and `ci` for lines 40, 228, 229 of both measured targets copies.
  3. Acceptance: repo-wide line coverage >= 85.00; lines 40, 228, 229 covered on both measured copies; junit failures 0.
- Verification commands: read the `<counter type="LINE" .../>` element at report level of `artifacts/pester/powershell-coverage.xml`; read the `tests=` and `failures=` attributes of `artifacts/pester/pester-junit.xml`.

## Included Non-Blocking Items (same change surface; optional in this cycle)

### RI-2 (CR-1) — leading-whitespace non-local path-leg spelling still maps to the session root

- File: `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` line 228, and its three byte-identical copies.
- Observation (source reading): `' \\server\share\a.ps1'` does not match the `^`-anchored `OrchestrationTargetNonLocalPattern`, normalizes to `' //server/share/a.ps1'`, fails the absolute pattern, and is mapped to the session root. The Claude Write leg passes `FilePath` untrimmed (`enforce-orchestration-preimplementation-gate-epic-scope.ps1` line 250). The Codex marker leg trims and is unaffected.
- Suggested outcome: fail closed on surrounding whitespace in the R1 loop (for example a `\s*` prefix in the pattern, or a guard when `$rawPath -cne $rawPath.Trim()`). Add a U27-style row with a leading-space UNC spelling on both surfaces, with expect-fail evidence first. Re-copy the three mirrors byte-for-byte and re-run the Parity suite and the push-down contract tests.

### RI-3 (CR-3) — U30 assertion completeness

- File: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`, U30.
- Suggested outcome: also assert that `@($result.Targets).Count` is 0, that `ReasonCode` is `target-unresolvable`, and that `Detail` is exactly `'path-not-local: \\server\share\..\x'`.

## Not Required in This Cycle (orchestrator dispositions)

- PA-1: plan task P3-T12 is unchecked (report row 90.42% -> 90.41%, caused by coverage attribution on the unchanged `WorktreeTargetResolution.psm1` lines 116 and 335, whose direct tests passed in both runs). The reviewer classifies it as Non-blocking. Record the deviation as accepted, and track the attribution variance as a separate follow-up.
- AC-15 is checked off at S9 against the PR head.
- Rebase on `origin/main` (23 commits ahead, no in-scope overlap) before opening the PR.

## Do Not Do

- Do not edit `config/poshqc-coverage.json`, any PoshQC settings, or coverage populations to raise the figure.
- Do not hand-edit or copy a coverage XML into `artifacts/pester/` without recording its provenance (run id or command) in the evidence artifact.
- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not widen the production change beyond the R1 loop of the targets copies.

## Exit Condition

- The canonical artifact `artifacts/pester/powershell-coverage.xml` comes from a full-suite run, reads >= 85.00% repo-wide, and is recorded under `evidence/qa-gates/`.
- The re-review artifacts (policy-audit, code-review, feature-audit) report a blocking count of 0.

## Orchestrator Scope Dispositions (cycle 1)

Per the run rule that related non-blocking findings are fixed inside the item, the orchestrator sets the cycle 1 scope as follows.

- RI-1: required (blocking, autonomous).
- RI-2 (CR-1): required. Fail closed on surrounding whitespace in the R1 path leg.
- RI-3 (CR-3): required. Complete the U30 assertions.
- RI-4 (CR-2): required. `file:` URI spellings (`file:///C:/wt/a.ps1`, `file://server/share/a.ps1`) and `~`-prefixed spellings (`~/wt/a.ps1`, `~\wt\a.ps1`) take the relative fallback to the session root, which is the misresolution class #937 fixes. Extend the non-local check in the R1 loop so these deny with `path-not-local`, with expect-fail rows first on both surfaces.
- RI-5 (CR-4): required. A single-backslash root-relative spelling (`\wt\a.ps1`, current-drive-rooted on Windows) cannot be resolved to a local absolute path deterministically. Deny it with `path-not-local` through the non-local check, without editing `OrchestrationTargetAbsolutePattern` (spec Non-Goal kept). A single forward-slash POSIX absolute path (`/wt/a.ps1`) stays resolvable.
- RI-6 (CR-6): required. Wrap the 11 added test lines that exceed 120 characters, without altering row names or values.
- spec.md: add acceptance criteria for RI-2, RI-4, and RI-5 behavior (planner-authored), and keep AC-1 through AC-15 text unchanged.
- PA-1 / CR-5 (P3-T12 report-row variance in the unchanged `WorktreeTargetResolution.psm1`): accepted plan deviation; unrelated to the #937 change surface; not fixed in this item.
- CR-7 (single-feature fallback in `Resolve-WorktreeOperandTarget`): unrelated module with documented fallback semantics; not fixed in this item.
