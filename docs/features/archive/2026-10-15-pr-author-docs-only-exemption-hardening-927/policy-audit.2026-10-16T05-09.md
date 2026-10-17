# Policy Audit: pr-author docs-only exemption hardening and merge-side docs-only exemption (Issue #927)

- Timestamp: 2026-10-16T05-09
- Reviewer: feature-review agent (initial review after plan execution, Phases 0 to 7)
- Branch: `bug/pr-author-docs-only-exemption-hardening-927`, HEAD `e4521e5a8e1ef211d8e81e686e8f9bcaf4dbf9f9`
- Base: `main` (resolved `origin/main`); merge-base `afa951ac0207eae934ac695e7340f18b3cf77522`.
- Diff command: `git diff afa951ac0..HEAD` (97 files, +8520/-290). Outside `docs/`: 40 files (7 canonical hook files, 7 bundled hook mirrors, 2 pack manifests, 24 Pester suites of which 7 are new).
- Work mode: `full-bug` (`issue.md` line 9). AC source: `spec.md` `## Acceptance Criteria` only (47 items: AC-M1 to AC-M25, AC-1 to AC-22).
- Policy reading order applied: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`.
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were generated at 2026-10-16 05:01:43 UTC for head `e4521e5a8` and merge base `afa951ac0`, matching this audit; they were not regenerated. No pull request exists for the branch (`gh pr list --head bug/pr-author-docs-only-exemption-hardening-927 --state all` returned `[]`), so no PR-head CI run exists.

## Executive Summary

The branch implements the spec as written: create-side CR-1 (base and repository override detection) and CR-2 (NUL-termination guard and `-GitInvoker` seam injection), the shared helper `hook-docs-only-diff.ps1` at four byte-identical locations, the merge-side docs-only branch in the Claude and Codex merge gates (conditions M1 to M9), manifest registration, and the PA-N3 / PA-N2 corrections to the #901 evidence record. The reviewer verified mirror parity (git object hashes), file sizes, scope constraints, test purity, and evidence locations directly.

One blocking finding remains:

- PA-1 (Blocking, autonomous): the contract-designated PowerShell coverage artifact `artifacts/pester/powershell-coverage.xml` was produced by a scoped PoshQC MCP run. It reports repo-wide LINE 8128/12298 (66.09%), below the 85% floor, and has no `sourcefile` entry for the new helper (`.claude/hooks/hook-docs-only-diff.ps1`, `.codex/hooks/hook-docs-only-diff.ps1`) or for the modified `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`. PowerShell coverage is therefore FAIL. The same defect class was remediated in #901 cycle 2 by a direct `Invoke-PoshQCTest -Root <worktree>` run.

Six criteria (AC-9, AC-18 analyzer half, AC-19, AC-21, AC-M23 analyzer half, AC-M24) are pending the PR-head CI run by design and are tracked as pending-CI in the feature audit, not as separate findings.

Overall verdict: **FAIL** (1 Blocking finding, classified autonomous). Non-blocking observations: 10 (listed in section 8).

## Rejected Scope Narrowing

No scope narrowing was detected. The caller prompt supplies the base branch, merge-base, head, feature folder, PR-context paths, and AC source, and asks for the full feature-review contract. The caller statement "Six criteria are CI-dependent per the plan ... and are listed pending-CI" was evaluated on the evidence rather than accepted as a coverage exemption: PowerShell has changed files on the branch, so the PowerShell coverage verdict below is an explicit FAIL from the contract-designated artifact. The caller statement "PowerShell verification in this repository follows Option A (PoshQC MCP tools plus CI results)" was likewise not treated as a waiver of the artifact inspection required by the reviewer contract. Python, TypeScript, and C# have zero changed files (`git diff --name-only afa951ac0..HEAD` filtered on `.py`, `.ts`, `.tsx`, `.cs` returns no path), so N/A is used only for those languages.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported path.
- Branch-diff scan: `git diff --name-only afa951ac0..HEAD -- artifacts/` returned zero paths, so no file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All #927 evidence is under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/{baseline,other,qa-gates,regression-testing}/`.
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Seam mocks are registered per test (`BeforeEach` or inside the `It`); `$global:LASTEXITCODE` is reset in `BeforeEach` and `AfterEach` in both seam contexts (`hook-docs-only-diff.Tests.ps1:40-46`, `enforce-pr-author-skill.DocsOnly.Tests.ps1:185-191`). |
| Isolation | PASS | Each `It` targets one condition; process seams are mocked by name (`Invoke-DocsOnlyGhExe`, `Invoke-DocsOnlyGitExe`, `Invoke-PrAuthorDocsOnlyGitExe`) with `-ParameterFilter` on `$GitArgs`. |
| Fast execution | PASS | No process start, network call, or sleep in the new rows; seam bodies run through test-local scriptblocks. |
| Determinism | PASS | Reviewer search over the seven new or relocated suites for `Mock git`, `Mock gh`, `Start-Process`, `New-TemporaryFile`, `GetTempFileName`, `TestDrive`, `function git`, `function gh`, and `Start-Sleep` returned no match; `evidence/qa-gates/p6-test-purity.2026-10-16T04-46.md` records the same. |
| Readability | PASS | Descriptive `-ForEach` row names and `-Because` messages. Some rows omit an explicit `# Arrange` section (PA-N9). |

### 1.2 Coverage requirements

Governing thresholds: the root `CLAUDE.md` states no coverage threshold, so the defaults govern (line 85% for new files, modified files, and repo-wide; branch 75% for branch-capable languages). PowerShell has no branch figure under Pester; the branch threshold is not evaluated for PowerShell.

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch.
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch.
- Python baseline coverage artifact: N/A - no Python file changed on the branch.
- Python post-change coverage artifact: N/A - no Python file changed on the branch.
- PowerShell baseline coverage artifact: merge-base CI run `38852748136` (push, success, head `afa951ac0`), artifact `poshqc-test-results` / `powershell-coverage.xml`, downloaded by the reviewer to a session scratch directory and parsed: repo-wide LINE 16381/18116 (90.42%). The executor baseline (`evidence/baseline/p0-ci-coverage-baseline.2026-10-16T00-48.md`, run `38730332356` at `adb9aa5f`) records identical per-file figures for the five modified hook files.
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (local, mtime 2026-10-16 00:40:47 -04:00, after the last code commit `1cfb6a919` at 00:15:21 -04:00). Reviewer parse: repo-wide LINE 8128/12298 (66.09%). The companion `artifacts/pester/pester-junit.xml` reports tests=7155 (the full population measured in #901 cycle 2 was 10322), which confirms a scoped population.
- Per-language comparison summary: PowerShell repo-wide line 90.42% (baseline CI) to 66.09% (local scoped artifact); the drop reflects the scoped measurement population, not a code regression, but the contract-designated artifact is below the floor and omits two changed files. Python, TypeScript, and C# have zero changed files.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 7 canonical production (2 new: the helper at `.claude/hooks` and `.codex/hooks`; 5 modified), 7 byte-identical mirrors, 24 test suites (7 new, 17 modified) | PoshQC MCP test over `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, and related suites | tests=7155, failures=0, errors=0 (`evidence/qa-gates/p6-pester.2026-10-16T04-43.md`; reviewer read of `pester-junit.xml` root counters matches) | 90.42% repo-wide line (16381/18116, CI run 38852748136) | 66.09% repo-wide line (8128/12298, local scoped artifact) | 100.00% of changed executable lines in the four measured modified files (21/21); helper copies and `enforce-pr-author-skill.docs-only.ps1` not measured (absent from the artifact) |
| Python | 0 | 0 | none | N/A | N/A | N/A |
| TypeScript | 0 | 0 | none | N/A | N/A | N/A |
| C# | 0 | 0 | none | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 90.42% repo-wide line (16381/18116, CI run `38852748136`); `enforce-pr-author-skill.docs-only.ps1` 93.44% (57/61), `enforce-pr-author-skill.ps1` 92.98% (53/57), `enforce-epic-merge-gate.ps1` 99.25% (132/133), `enforce-epic-merge-gate-resolution.ps1` 95.24% (40/42), `.codex/hooks/enforce-epic-merge-gate.ps1` 87.90% (138/157); `hook-docs-only-diff.ps1` absent (new file). Post-change: 66.09% repo-wide line (8128/12298, local `artifacts/pester/powershell-coverage.xml`); `enforce-epic-merge-gate.ps1` 99.29% (139/140), `enforce-epic-merge-gate-resolution.ps1` 95.65% (44/46), `enforce-pr-author-skill.ps1` 92.98% (53/57), `.codex/hooks/enforce-epic-merge-gate.ps1` 98.78% (162/164); `enforce-pr-author-skill.docs-only.ps1`, `.claude/hooks/hook-docs-only-diff.ps1`, and `.codex/hooks/hook-docs-only-diff.ps1` have no `sourcefile` entry. Change: the four measured modified files are at or above baseline; repo-wide is not comparable because the population differs. New/changed-code coverage: 100.00% (21/21) of the changed executable lines in the measured modified files (changed-line sets from `evidence/qa-gates/p6-coverage-pending-ci.2026-10-16T04-52.md`, reviewer parse of the local artifact): Claude gate 8/8 (81, 418-422, 424, 430), resolution sibling 4/4 (272-274, 277), Codex gate 9/9 (28, 195-199, 201, 207, 402), `enforce-pr-author-skill.ps1` 0 executable changed lines (header only); the two helper copies and `enforce-pr-author-skill.docs-only.ps1` are not measured. Disposition: FAIL (PA-1). Evidence: reviewer parse of `artifacts/pester/powershell-coverage.xml` and of the CI run `38852748136` artifact; `evidence/baseline/p0-ci-coverage-baseline.2026-10-16T00-48.md`; `evidence/qa-gates/p6-coverage-pending-ci.2026-10-16T04-52.md`.

### 1.2.2 Coverage Verdict per Language

| Language | Verdict | Basis |
|---|---|---|
| PowerShell | FAIL | Coverage FAIL: the contract-designated artifact `artifacts/pester/powershell-coverage.xml` reports repo-wide line 66.09%, below the 85% floor, and omits the new file `hook-docs-only-diff.ps1` (both canonical copies) and the modified file `enforce-pr-author-skill.docs-only.ps1`, so the new-file and modified-file thresholds cannot be shown to hold. PA-1. |
| Python | N/A | Zero changed files. |
| TypeScript | N/A | Zero changed files. |
| C# | N/A | Zero changed files. |

### 1.3 Scenario completeness

| Area | Verdict | Evidence |
|---|---|---|
| Create-side CR-1 reject and accept rows (AC-1, AC-2, AC-4) | PASS | `enforce-pr-author-skill.DocsOnly.Tests.ps1:68-103` (11 reject rows, 4 accept rows); zero-invocation rows in `DocsOnly.Exemption.Tests.ps1:222-246`. The `-B=main` row is not discriminating (PA-N3). |
| Create-side CR-2 guard and seam rows (AC-6, AC-8) | PASS | `DocsOnly.Exemption.Tests.ps1:209-220`; seam rows `DocsOnly.Tests.ps1:163-241` (success, multi-line, non-zero, throw). |
| Shared helper pure functions and seams (AC-M3, AC-M4) | PASS | `hook-docs-only-diff.Tests.ps1:48-287`; Codex copy driven by `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`. |
| Merge conditions M1 to M9 (AC-M6 to AC-M11) | PASS | `hook-docs-only-diff.MergeExemption.Tests.ps1:31-217`: 13 M1 rows, 2 M2 rows, 8 M3 rows plus a match row, 4 M4/M5 rows, 4 diff rows, allow, range, and no-fetch rows. Equals-form `--match-head-commit=`, `--auto=`, and non-object JSON are not exercised (PA-N4). |
| Gate composition (AC-M5, AC-M12 to AC-M15) | PASS | `enforce-epic-merge-gate.DocsOnly.Tests.ps1` (allow, three deny compositions, three resolved/ambiguous no-call rows, bare-command exact text, four truth-table rows); `codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (allow, non-docs deny, two present-checkpoint rows, blank root, `-R`, gh failure, bare text). |
| Error handling and state transitions | PASS | Seam throw rows assert `ExitCode -1` and location restoration; every seam failure row asserts a deny. |

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity and separation of concerns | PASS | Pure classifiers (`ConvertFrom-DocsOnlyNameList`, `Get-DocsOnlyPathViolation`, `Get-DocsOnlyDiffTextViolation`, `Get-DocsOnlyMergeShapeViolation`) are separate from the two process seams and the orchestration function. |
| Reusability | PASS | Pure classifiers moved to one shared helper consumed by the create side and both merge gates. The create-side seam duplicates the shared git seam by explicit spec decision (Design item 3); recorded as PA-N8. |
| File size (500 lines) | PASS | Reviewer `wc -l` at HEAD: largest production file `enforce-epic-merge-gate.ps1` 490 (PA-N7); helper 397; Codex gate 410; largest test file `enforce-epic-merge-gate.Tests.ps1` 467. All edited or new `.ps1` files are under 500. |
| Error handling | PASS | Both new seams return `ExitCode -1` instead of throwing; every M-condition failure returns `Exempt = $false` with a reason; no new throw path. |
| Dependencies | PASS | No new external dependency. The helper imports nothing and dot-sources nothing (AST row `hook-docs-only-diff.Tests.ps1:301-316`). |
| Public API compatibility | PASS | New parameters (`-GitInvoker`, `-GhInvoker`, `-RepositoryRoot`) are optional; existing deny texts keep their prefix and order, and only the explicit-number standalone deny gains an appended suffix. |
| Policy files unchanged | PASS | `git diff --name-only afa951ac0..HEAD -- .claude/rules .github/instructions .claude/settings.json .codex/config.toml` returned zero paths. |
| Mirror parity | PASS | Reviewer `git hash-object`: all seven canonical/mirror pairs identical (helper `b2383fee8` at four paths; Claude gate `9b16c7a5c`; resolution `e83cd0af5`; docs-only `f3e3300e9`; pr-author `c7c8af60b`; Codex gate `1921dafe5`). |
| Tier classification | PASS | `quality-tiers.yml` exists on the base; `.claude/hooks` and `.codex/hooks` are classified T3. No property-test or mutation obligation applies to T3. |

## 3. Language-Specific Code Change Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Format (PoshQC) | PASS | `evidence/qa-gates/p6-poshqc-format.2026-10-16T04-18.md`: porcelain status empty before and after the MCP format call; 0 files rewritten. |
| PowerShell | Analyzer (PoshQC) | PARTIAL | `evidence/qa-gates/p6-poshqc-analyze.2026-10-16T04-18.md`: MCP analyze returned ok=true on loop pass 2 after pass 1 surfaced 9 findings that were fixed in `1cfb6a919`. The finding count of pass 2 is not recorded; the CI `Analyze PowerShell` step is the planned confirmation (pending CI, not a separate finding). |
| PowerShell | Advanced functions and comment-based help | PASS | Every new function carries `[CmdletBinding()]`, `[OutputType()]`, and `.SYNOPSIS`/`.DESCRIPTION`/`.PARAMETER`/`.OUTPUTS`. |
| PowerShell | `&`-invoked variables are `[scriptblock]` parameters of the same file | PASS | `$GitInvoker` and `$GhInvoker` are `[ValidateNotNull()][scriptblock]` parameters (`hook-docs-only-diff.ps1:167,207`; `enforce-pr-author-skill.docs-only.ps1:70`). Guard suite results recorded in `p6-pester.2026-10-16T04-43.md` (J14). |
| PowerShell | Guarded dependency loading | PASS | Claude gate line 81 and Codex gate line 28 use the single-statement `try { . ... } catch { Add-HookDependencyFailure ... }` form; `hook-dependency-guard-completeness` 598 passed and `hook-import-failure-exemptions.Guard` 10 passed. |
| PowerShell | Enforcement hooks without Python | PASS | Zero Python files in the diff. |
| Python | All requirements | N/A | Zero changed files. |
| TypeScript | All requirements | N/A | Zero changed files. |
| C# | All requirements | N/A | Zero changed files. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| PowerShell | Location mirrors source | PASS | `tests/scripts/claude-hooks/` for `.claude/hooks/`; `tests/scripts/codex-hooks/` for `.codex/hooks/`. |
| PowerShell | Mock the wrapper, not the tool | PASS | Mocks target the seam functions; no `Mock git` or `Mock gh`; seam bodies use `${function:...}` scriptblocks of test-local functions not named `git` or `gh`. |
| PowerShell | No temporary files, no sleep or clock APIs | PASS | Reviewer search (section 1.1) and `p6-test-purity.2026-10-16T04-46.md`. |
| PowerShell | Epic-state isolation pattern for suites that dot-source the Claude gate | PASS | Baseline seam mocks added to each derived suite (`p4-merge-gate-suite-set.2026-10-16T03-31.md`); new suites include an interception probe. |

## 5. Test Coverage Detail

| Hook file | Status | Baseline line (CI 38852748136) | Post-change line (local XML) | Changed executable lines covered (local XML) |
|---|---|---|---|---|
| `.claude/hooks/hook-docs-only-diff.ps1` | New | none (new file) | absent from artifact | not measurable |
| `.codex/hooks/hook-docs-only-diff.ps1` | New | none (new file) | absent from artifact | not measurable |
| `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` | Modified | 93.44% (57/61) | absent from artifact | not measurable |
| `.claude/hooks/enforce-pr-author-skill.ps1` | Modified (header only) | 92.98% (53/57) | 92.98% (53/57) | 0/0 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | Modified | 99.25% (132/133) | 99.29% (139/140) | 8/8 |
| `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` | Modified | 95.24% (40/42) | 95.65% (44/46) | 4/4 |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | Modified | 87.90% (138/157) | 98.78% (162/164) | 9/9 |
| Bundled mirrors (7 files) | Mirror | byte-identical to source | byte-identical to source | n/a |
| Repo-wide PowerShell | - | 90.42% (16381/18116) | 66.09% (8128/12298), scoped population | - |

## 6. Test Execution Metrics

| Suite | Runner | Result | Source |
|---|---|---|---|
| Hook-family Pester (loop pass 2) | `mcp__drm-copilot__run_poshqc_test` | tests=7155, failures=0, errors=0; new suites 30, 36, 14, 32, 9 passed; DocsOnly suites 34, 19, 9 passed | `evidence/qa-gates/p6-pester.2026-10-16T04-43.md`; reviewer read of `artifacts/pester/pester-junit.xml` |
| Push-down contract pytest (4 files) | `poetry run pytest ... -q` | 27 passed | `evidence/qa-gates/p6-pytest-contracts.2026-10-16T04-45.md` |
| Jest manifest completeness | `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts` | 16 passed | `evidence/qa-gates/p6-jest-manifest.2026-10-16T04-45.md` |
| PR-head CI | GitHub Actions | not run: no pull request exists | `gh pr list --head <branch> --state all` returned `[]` |

## 7. Code Quality Checks

| Check | Result |
|---|---|
| Scope (AC-22, AC-M21, AC-M25, AC-16) | `git diff --name-status afa951ac0..HEAD`: no `hook-command-invocation*.ps1`, no `enforce-pr-author-skill-helpers.ps1`, no file under `.claude/rules/`, no archive path; the only `.codex/` files are the gate and the helper; #901 folder entries are all `M`. |
| CR-3 pin (AC-10) | `enforce-pr-author-skill.docs-only.ps1:210` keeps `'diff', '--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative', ($commit + '...HEAD')`. |
| Seam call sites (AC-7) | `enforce-pr-author-skill.docs-only.ps1:196,210` call `Invoke-PrAuthorDocsOnlyGitExe` without `-GitInvoker`. |
| Workflow files | No `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` path changed; the `modified-workflow-needs-green-run` rule does not fire. |

## 8. Gaps and Exceptions

- PA-1 (Blocking, autonomous): PowerShell coverage FAIL. `artifacts/pester/powershell-coverage.xml` is a scoped PoshQC MCP output (repo-wide LINE 66.09%; no `sourcefile` for `.claude/hooks/hook-docs-only-diff.ps1`, `.codex/hooks/hook-docs-only-diff.ps1`, or `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`). Required action: regenerate the artifact with a direct `Invoke-PoshQCTest -Root <worktree>` run over the population defined by `config/poshqc-coverage.json` (the CI form in `.github/workflows/_poshqc.yml:38-42`), then record repo-wide and per-file counters in a new `evidence/qa-gates/` file. Pass condition: repo-wide line at or above 85%; each helper copy and `enforce-pr-author-skill.docs-only.ps1` at or above 85%; every changed executable line of the five modified hook files covered. Precedent: #901 remediation cycle 2 (PA-1) closed the same defect class this way.
- PA-N1 (Non-blocking, Medium): hook timeout on the docs-only branch. The merge gates now run `gh pr view` and up to three `git` calls inside a PreToolUse hook (`hook-docs-only-diff.ps1:221` and `:175`) with no bounded timeout. Codex registers the gate with `timeout = 30` (`.codex/config.toml:144`); the Claude registration (`.claude/settings.json:114`) uses the runtime default. The reviewer did not verify how either runtime treats a hook that exceeds its timeout; if a timeout is treated as a non-blocking hook error, a stalled `gh` call would convert this previously fast deny path into an allow. Recommended action: confirm the timeout semantics of both runtimes and, if a timeout does not deny, bound the gh and git calls (or record the behavior as a residual limit in the hook headers).
- PA-N2 (Non-blocking, Medium): undocumented residual limit. The Claude gate runs gh and git in the hook process location (`Get-EpicMergeGateSessionWorktreeRoot`, `enforce-epic-merge-gate-resolution.ps1:111`), while `gh pr merge <N>` runs in the Bash tool's working directory. A `cd` issued in an earlier Bash call into another repository is not visible to M1 (which rejects only an in-command `cd ... &&`), so the exemption could evaluate PR `<N>` of a different repository. The residual-limit lists (`hook-docs-only-diff.ps1:43-46`, `enforce-epic-merge-gate.ps1:36-46`, `.codex/hooks/enforce-epic-merge-gate.ps1:4-16`) name ambient `GH_REPO`/`GH_HOST` but not an ambient working directory. Recommended action: add this limit to the three headers, or bind the lookup root to the payload working directory when the envelope supplies one.
- PA-N3 to PA-N10 (Non-blocking, Low or Info): test-row and documentation observations listed with file and line in `code-review.2026-10-16T05-09.md` (CR-3 to CR-10).
- Pending CI (not findings): AC-9, AC-19, AC-21, AC-M24, and the analyzer halves of AC-18 and AC-M23 require the PR-head CI run; the item's orchestrator checks them off at S9.

## 9. Summary of Changes

- Create side: `Get-PrAuthorDocsOnlyBaseName` denies single-dash tokens containing `B` or `R`, `--repo`/`--repo=`, and `GH_REPO=`; E3 message extended; NUL guard via the shared `Get-DocsOnlyDiffTextViolation`; `Invoke-PrAuthorDocsOnlyGitExe -GitInvoker`; two pure helpers moved to the shared file; header documentation in both pr-author files.
- Shared helper `hook-docs-only-diff.ps1` (397 lines) at `.claude/hooks`, `.codex/hooks`, and both bundle mirrors; registered in both `pack-manifests/core.json`.
- Merge side: `Test-EpicMergeGateNoRecordingTarget`; docs-only branch in `Invoke-EpicMergeGateDecision` and `Invoke-CodexEpicMergeDecision` (new optional `-RepositoryRoot`); header design paragraphs replaced.
- Tests: 7 new suites; baseline seam mocks added to 9 existing Claude suites; new rows in the three DocsOnly suites.
- #901 record: 13 evidence files annotated with reconstructed timestamps; one `EXIT_CODE` corrected to `NOT_OBSERVED`; `## Evidence Checklist` checked with citations.

## 10. Compliance Verdict

**FAIL** - 1 Blocking finding (PA-1, autonomous: PowerShell coverage artifact scoped and incomplete). 10 non-blocking observations (PA-N1, PA-N2 here; CR-3 to CR-10 in the code review). Six criteria are pending the PR-head CI run.

## Appendix A: Test Inventory

- New: `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` (318 lines), `tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1` (218), `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` (199), `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (169), `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` (159).
- Modified with new rows: `enforce-pr-author-skill.DocsOnly.Tests.ps1` (242), `enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1` (261), `enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1` (163).
- Modified with baseline seam mocks only (+2 lines each): `enforce-epic-merge-gate.Tests.ps1`, `.Authorization.Tests.ps1`, `.Coverage.Tests.ps1`, `.ItemResolution.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `hook-command-consumers.Issue824.Tests.ps1`, `hook-command-parser.AcceptanceCases.Tests.ps1`.

## Appendix B: Toolchain Commands Reference

- `git diff --stat afa951ac0..HEAD`; `git diff --name-status afa951ac0..HEAD`; `git log --format="%h %cI %s" afa951ac0..HEAD`
- `git diff afa951ac0..HEAD -- <production hook files>` and `-- <DocsOnly suites>`
- `git hash-object` on the seven canonical/mirror pairs and four helper copies; `wc -l` on every changed `.ps1` and `.json` file
- `git cat-file -e afa951ac0:quality-tiers.yml`
- `gh pr list --head bug/pr-author-docs-only-exemption-hardening-927 --state all --json number,state,headRefOid`
- `gh run list --workflow ci.yml --commit afa951ac0207eae934ac695e7340f18b3cf77522`; `gh run download 38852748136 -n poshqc-test-results -D <scratch>`
- `python -I <scratch>/cov.py <coverage.xml> <file suffixes>` (JaCoCo `LINE` counters per `sourcefile` and report root) and `python -I <scratch>/changed.py` (changed-line `ci` values)
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
