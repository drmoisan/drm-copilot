# Policy Audit: subagentstop-envelope-feature-review-coverage (Issue #896)

- Timestamp: 2026-10-12T11-25
- Reviewer: feature-review agent
- Branch: `bug/subagentstop-envelope-feature-review-coverage-exec-896` (reviewed at local `exec-896-ac7`, HEAD `f1dc01c3c528155db68d21056c75dbf1ac014d90`)
- Base: `origin/epic/subagentstop-envelope-integration` @ `486e8c06e52977b83dec5307806c5be8a90ab8f9` (merge-base `486e8c06e52977b83dec5307806c5be8a90ab8f9`)
- Diff command: `git diff origin/epic/subagentstop-envelope-integration...HEAD` (118 files, +8426/-1296; 21 commits in `git log origin/epic/subagentstop-envelope-integration..HEAD`)
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated 2026-10-12 11:17 UTC at head `f1dc01c3c` (current; not regenerated)
- Work mode: `full-bug` (AC source: `spec.md` only)
- Policy reading order applied: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/tonality.md`
- Tier: `.claude/hooks` and `.codex/hooks` are T3 in `quality-tiers.yml` (lines 28-33).

## Executive Summary

The branch converts the Claude feature-review SubagentStop gate (`.claude/hooks/validate-feature-review-coverage.ps1`) to the E1 stdin envelope helper with exit-2 blocking on every block path, adds the per-condition re-entry policy, splits the hook into three files (entry 205 lines, `-metrics` 180, `-rules` 195), makes an unreadable root `CLAUDE.md` fail closed (CR-4), accepts trailing-floor statements in the shared resolver (CR-9), consolidates the Issue824 mock (CR-6), connects the Codex hook to a byte-identical copy of the resolver (85% default line floor instead of the fixed 80%), replaces the fixed 80/90 figures in the feature-review skill and agent texts, and syncs every mirror.

Changed code languages: PowerShell (6 production files, 10 test files, 6 production mirrors) and Python (1 test file, `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; no Python production file).

PowerShell gates verified by the reviewer: format clean (0 diffs over 16 files), PSScriptAnalyzer 0 findings, 1117 targeted Pester tests passed (0 failed), per-file line coverage 98.82% to 100.00% for all six production files, repo-wide line coverage 90.48% (command coverage 89.67%), changed-line coverage 98.67% to 100.00%, every file under 500 lines, mirrors byte-identical, no policy or configuration file changed, no evidence outside the canonical tree.

Python gates verified by the reviewer: Black, Ruff, and Pyright clean on the changed file; the six push-down contract modules pass (87 tests). The Python coverage artifact `artifacts/python/lcov.info` does not exist in the worktree, and no Python coverage measurement is recorded in the feature evidence. Under the mandatory coverage rule, Python coverage is FAIL (finding PA-1).

Overall verdict: **FAIL** (1 Blocking finding: PA-1, Python coverage artifact absent; Remediability `autonomous`). All other gates PASS. Non-blocking observations are listed in section 8 and in the code review.

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller supplied the base `origin/epic/subagentstop-envelope-integration`, the feature folder, and the PR context paths; none of these narrows the audit. The audit scope is the full three-dot diff against `origin/epic/subagentstop-envelope-integration`, including the Python test file.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` returned exit code 0 with no output.
- Branch-diff scan: `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD` filtered by `^artifacts/(baselines|qa|evidence|coverage)/` printed no path. All 85 evidence files are under `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/{baseline,other,qa-gates,regression-testing}/`.
- Verdict: PASS. No FAIL-level occurrence.

## 1. General Unit Test Policy Compliance

### 1.1 Core principles

| Principle | Verdict | Evidence |
|---|---|---|
| Independence | PASS | `Invoke-ClaudeReviewEntry` (`validate-feature-review-coverage.E4.Helpers.ps1:18-37`) saves and restores `[Console]::In` and `[Console]::Error` in `finally`; fixtures are selected per test through `Use-E4Fixture` and `Set-ReviewArtifactMap`. |
| Isolation | PASS | Rule tests target single functions (`Get-FeatureReviewCoverageThreshold`, `Test-LanguageCoverageRow`, `Get-ReviewArtifactInfo`); file reads are mocked through `Get-ArtifactFileContent`. |
| Fast execution | PASS | Reviewer run of 13 suites (955 tests) and 2 dependency-failure suites (162 tests) completed in one invocation each; the entry point is driven in-process through `&`, with no child process. |
| Determinism | PASS | Reviewer grep for `Start-Sleep`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `TestDrive`, `$env:TEMP` over the changed feature-review suites: zero matches. |
| Readability | PASS | Tests carry descriptive `It` names with stable IDs (`E4-TR1` to `E4-TR10`, `E4-ST1` to `E4-ST7`, `E4-PX1`, `E4-PX2`, `E4-TG4`, `E4-CORPUS-1`, `E4-CORPUS-2`). |

### 1.2 Coverage requirements

- TypeScript baseline coverage artifact: N/A - no TypeScript file changed on the branch.
- TypeScript post-change coverage artifact: N/A - no TypeScript file changed on the branch.
- PowerShell baseline coverage artifact: `evidence/baseline/pester-coverage.2026-10-11T23-30.md` and `evidence/baseline/pester-full-run.2026-10-11T23-30.md` (per-file 98.62%, 100.00%, 99.29%; repo command coverage 88.67%).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (JaCoCo; 26,257 commands, matching the pass 3 full run in `evidence/qa-gates/final-pester-full-run.pass3.2026-10-12T08-31.md`), parsed independently by the reviewer: repo line 90.48% (16254/17964), command 89.67% (23544/26257).
- Python baseline coverage artifact: none recorded in the feature evidence; `artifacts/python/lcov.info` is absent from the worktree.
- Python post-change coverage artifact: none recorded in the feature evidence; `artifacts/python/lcov.info` is absent from the worktree.
- Per-language comparison summary: PowerShell meets the 85% line floor for every changed production file and repo-wide, with no regression on any file and changed lines at 98.67% or higher. Python has one changed test file and no coverage artifact, which is a FAIL under the mandatory coverage rule (PA-1). TypeScript and C# have zero changed files.

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 6 production (3 new), 6 mirrors, 10 test files (3 new) | 1117 reviewer Pester tests (94 E4-tagged) | 1117 passed, 0 failed | 88.67% repo command; files 98.62%, 100.00%, 99.29% | 90.48% repo line, 89.67% command; files 98.82%, 100.00%, 98.88%, 100.00%, 100.00%, 100.00% | 98.67% to 100.00% changed lines |
| Python | 1 test file (no production file) | 87 push-down contract tests | 87 passed, 0 failed | n/a - no Python coverage artifact recorded | n/a - no Python coverage artifact recorded | n/a - no Python production line changed |
| TypeScript | 0 | 0 | none | N/A | N/A | N/A |
| C# | 0 | 0 | none | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 98.62% Claude hook, 100.00% thresholds, 99.29% Codex hook (repo command 88.67%). Post-change: 98.82% Claude entry, 100.00% metrics, 98.88% rules, 100.00% Claude thresholds, 100.00% Codex hook, 100.00% Codex thresholds (repo line 90.48%, command 89.67%). Change: +0.20% Claude entry, +0.71% Codex hook, 0.00% thresholds; no file regressed. New/changed-code coverage: 98.67% entry (74/75), 100.00% metrics (72/72), 98.88% rules (88/89), 100.00% thresholds (1/1), 100.00% Codex hook (9/9), 100.00% Codex thresholds (21/21). Disposition: PASS. Evidence: `evidence/qa-gates/final-pester-coverage.2026-10-12T08-31.md`, `evidence/qa-gates/coverage-delta.2026-10-12T08-38.md`, reviewer parse of `artifacts/pester/powershell-coverage.xml`.
- Python: Baseline: no figure recorded. Post-change: no figure recorded. Change: not computable without an artifact. New/changed-code coverage: no Python production line changed. Disposition: FAIL. Evidence: `artifacts/python/lcov.info` absent (`ls artifacts/python/` reports no such directory); no Python coverage record under `evidence/`.

### 1.2.2 Coverage Verdict per Language

| Language | Verdict | Basis |
|---|---|---|
| PowerShell | PASS | Every changed production file at or above 98.82% line coverage; repo line 90.48% and repo command 89.67%, both above 85%; no regression; Pester measures no branch figure, so the branch threshold is not evaluated. |
| Python | FAIL | Coverage artifact absent for Python; coverage verification is mandatory for all languages with changed files (PA-1). |
| TypeScript | N/A | Zero changed files. |
| C# | N/A | Zero changed files. |

### 1.3 Scenario completeness

| Area | Verdict | Evidence |
|---|---|---|
| Positive flows | PASS | Valid envelope with complete artifacts and PASS rows allows termination (Coverage suite, Issue824 F824 cases). |
| Negative flows | PASS | `E4-TR2` absent artifact; `E4-TR3b` `EmptyPayload` and `UnparseableJson`; missing token, no coverage row, line below floor (`E4-TR10` a). |
| Edge cases | PASS | Absent vs unreadable `CLAUDE.md` (`E4-TR4a`, `E4-TR4`); trailing-floor positive and negative rows including combined-metric and out-of-range figures (`E4-TR5`). |
| Error handling | PASS | Malformed JaCoCo XML yields `validator error` and exit 2 (`E4-TR3`); E1 helper load failure exits 2 (`E4-TG4`). |
| State transitions | PASS | `stop_hook_active` true and false for repairable, non-repairable, and mixed conditions (`E4-TR10` a-d); Codex `continue:false` path (`E4-TR9`). |

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity and separation of concerns | PASS | Pure readers and parsers in `-metrics`, rule functions in `-rules`, decision and entry in the registered file. |
| Reusability | PASS | One resolver shared byte-for-byte by both hook families (`feature-review-coverage-thresholds.ps1`, SHA256 prefix `7c22eda2c4fe` for all four copies). |
| File size limit (500 lines) | PASS | Largest production file 316 lines (Codex hook); largest test file 497 lines (`legacy-codex-hook-contracts.Tests.ps1`, unchanged count); reviewer `wc -l`. |
| Error handling (fail fast, no silent catch) | PASS | Decision body wrapped in try/catch that converts any exception to a fail-closed block; `Get-FeatureReviewClaudeMdText` returns `ReadError` instead of throwing; the entry-point catch blocks through `Exit-SubagentStopBlock`. |
| Public API compatibility | PASS | `-RawPayload` replaced by `-InputText`; all in-repo callers updated (spec Backward-compatibility section); no external caller. |
| Dependencies | PASS | No new dependency. |
| No Python in hooks | PASS | No `.py` file in the hooks diff; `enforcement-hooks-no-python-invocation.Tests.ps1` 32/32 passed (reviewer run). |
| Policy documents unchanged | PASS | `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD -- .github/instructions .claude/rules` printed nothing. |
| Mirror parity | PASS | Reviewer SHA256 comparison: 9 of 9 source and mirror pairs match. |

## 3. Language-Specific Code Change Policy Compliance

### 3.1 PowerShell

| Requirement | Verdict | Evidence |
|---|---|---|
| Formatting (Invoke-Formatter, repo settings) | PASS | Reviewer run over 16 changed files: `FORMAT-DIFF-COUNT: 0`. |
| PSScriptAnalyzer (repo settings) | PASS | Reviewer run: `PSSA-TOTAL: 0`. |
| Comment-based help | PASS | Entry, metrics, rules, thresholds, and Codex hook carry `.SYNOPSIS`/`.DESCRIPTION`; `E4-ST3` and `E4-ST5` pin the required text. |
| Guarded dot-source pattern | PASS | Entry file lines 56-59 and Codex hook line 49; `hook-dependency-guard-completeness.Tests.ps1` 598/598 passed. |

### 3.2 Python

| Requirement | Verdict | Evidence |
|---|---|---|
| Black | PASS | `poetry run black --check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`: 1 file would be left unchanged. |
| Ruff | PASS | `poetry run ruff check ...`: All checks passed. |
| Pyright | PASS | `poetry run pyright ...`: 0 errors, 0 warnings. |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Test location mirrors source tree | PASS | Claude hook tests under `tests/scripts/claude-hooks/`, Codex under `tests/scripts/codex-hooks/`, Python under `tests/scripts/dev_tools/`. |
| No temporary files | PASS | Zero matches for temp-file APIs (section 1.1); stdin through `[Console]::SetIn` restored in `finally`. |
| No mock built with `[scriptblock]::Create` | PASS | `E4-ST6` AST check passes; reviewer grep confirms. |
| Fail-first regression evidence | PASS | `evidence/regression-testing/fail-first.2026-10-12T00-05.md`: 9 regression tests fail on base `ebf4504ae`, pass on head. |
| Python tests parametrized and typed | PASS | `test_feature_review_texts_name_claude_md_floor_source` parametrized over 8 copies; Pyright clean. |

## 5. Test Coverage Detail

| File | Status | Baseline line | Post-change line | Changed-line |
|---|---|---|---|---|
| `.claude/hooks/validate-feature-review-coverage.ps1` | modified | 98.62% (215/218) | 98.82% (84/85) | 98.67% (74/75) |
| `.claude/hooks/validate-feature-review-coverage-metrics.ps1` | new | none (new file) | 100.00% (72/72) | 100.00% |
| `.claude/hooks/validate-feature-review-coverage-rules.ps1` | new | none (new file) | 98.88% (88/89) | 98.88% |
| `.claude/hooks/feature-review-coverage-thresholds.ps1` | modified | 100.00% (21/21) | 100.00% (21/21) | 100.00% (1/1) |
| `.codex/hooks/validate-feature-review-coverage.ps1` | modified | 99.29% (140/141) | 100.00% (146/146) | 100.00% (9/9) |
| `.codex/hooks/feature-review-coverage-thresholds.ps1` | new | none (new file) | 100.00% (21/21) | 100.00% |

Post-change figures were reproduced by the reviewer from `artifacts/pester/powershell-coverage.xml` and match `evidence/qa-gates/final-pester-coverage.2026-10-12T08-31.md` exactly. The 7.30% Codex figure cited in #884 is superseded by the 99.29% baseline measurement.

## 6. Test Execution Metrics

| Run | Scope | Result | Source |
|---|---|---|---|
| Reviewer Pester run 1 | 13 suites: 5 Claude feature-review suites, 4 Codex feature-review suites, legacy Codex contracts, Codex dependency failure, Codex bundle probe, guard completeness, no-python | 955 passed, 0 failed, 0 skipped | Reviewer run, 2026-10-12 |
| Reviewer Pester run 2 | `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1` | 162 passed, 0 failed | Reviewer run, 2026-10-12 |
| Reviewer pytest | Six push-down contract modules from the spec Test Strategy | 87 passed | Reviewer run, 2026-10-12 |
| Executor full Pester (pass 3) | Full population | 10217 passed, 0 failed, 10 skipped | `evidence/qa-gates/final-pester-full-run.pass3.2026-10-12T08-31.md` |

## 7. Code Quality Checks

| Stage | Tool | Result | Verdict |
|---|---|---|---|
| Format | Invoke-Formatter / Black | 0 diffs / unchanged | PASS |
| Lint | PSScriptAnalyzer / Ruff | 0 findings / clean | PASS |
| Type check | Pyright (PowerShell has no type-check stage) | 0 errors | PASS |
| Architecture boundary | `hook-dependency-guard-completeness.Tests.ps1`; no `.codex/hooks` dot-source of `.claude/` (`E4-ST7`) | passed | PASS |
| Unit tests | Pester / pytest | all passed | PASS |
| Contract / schema | Push-down resource, manifest, and closure contracts | 87 passed | PASS |
| Integration | Entry point driven on redirected stdin (`E4-TR1`, `E4-TR3`, `E4-TR3b`, `E4-TR10` d, `E4-TG4`); Codex bundle probe | passed | PASS |
| Coverage | Section 1.2 | PowerShell PASS; Python FAIL | FAIL |

## 8. Gaps and Exceptions

| ID | Severity | Finding | Remediability |
|---|---|---|---|
| PA-1 | Blocking (FAIL) | Python has one changed file on the branch (`tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`) and no Python coverage artifact exists (`artifacts/python/lcov.info` absent; no Python coverage record in `evidence/`). The coverage rule requires an explicit PASS or FAIL backed by an artifact for every language with changed files. Risk is low because no Python production line changed, but the rule is mandatory. Corrective action: run `poetry run pytest --cov` (repo configuration writes `artifacts/python/lcov.info`), record repo-wide Python line and branch figures with baseline comparison under `evidence/qa-gates/`, and confirm line >= 85% and branch >= 75%. | autonomous |
| PA-2 | Info | The operator-mandated corpus gate (plan amendment 2026-10-11) relaxed three existing rules (audit-folder artifact layout; text inside `## Rejected Scope Narrowing`; branch-only rows for the Pester language). The spec Non-Goals still read "no new validation rule beyond the transport, exit-code, and floor-source changes"; the changes are relaxations, are traced in `evidence/other/corpus-rule-changes.2026-10-12T06-02.md`, and are pinned by `E4-CORPUS-1`/`E4-CORPUS-2`. | not blocking |
| PA-3 | Info | AC-29 (PR body `Refs #884`/`Refs #897`) cannot be verified before the PR exists; handoff recorded in `evidence/other/ac-29-handoff.2026-10-12T08-44.md`. | not blocking |
| PA-4 | Info | No CI status is available for the head (`CI status (HEAD): not available`); no workflow file changed, so `modified-workflow-needs-green-run` does not fire. | not blocking |

## 9. Summary of Changes

- Claude hook transport: E1 helper dot-source (line 59), `-InputText` pass-through (line 72), payload-anomaly block (lines 73-75), try/catch validator-error path (lines 185-187), re-entry policy (lines 189-192), entry exits through `Exit-SubagentStopBlock` (lines 202-205). `CLAUDE_HOOK_INPUT`, `Write-Error`, and `exit 1` are absent from all three Claude hook files.
- CR-8 split into `-metrics` and `-rules`; function bodies are unchanged except `Test-LanguageCoverageRow` (source labels, `Repairable`, corpus exemptions) and `Get-ReviewArtifactInfo` (audit-folder layout).
- CR-4: `Get-FeatureReviewClaudeMdText` (metrics lines 41-62) and the fail-closed finding (entry lines 161-165); Codex equivalent at hook line 280.
- CR-9: second resolver alternative (thresholds line 65) and help listing accepted forms.
- Codex: guarded dot-source of the resolver copy (line 49), `-LineFloor` replaces the fixed 80 (lines 154, 203-208, 287), footer names the governing floor.
- Texts: `.agents` and `.github` feature-review skills and `.codex/agents/feature-review.toml` name root `CLAUDE.md` and the 85%/75% defaults.
- Manifests: Claude `core.json` +2 entries, Codex `core.json` +1 entry; `legacy-codex-hook-contracts.Tests.ps1` `$script:SharedModuleNames` +1 name on the existing line.

## 10. Compliance Verdict

| Area | Verdict |
|---|---|
| General unit test policy | PASS (except coverage) |
| General code change policy | PASS |
| PowerShell policies | PASS |
| Python policies (format, lint, type, tests) | PASS |
| Coverage: PowerShell | PASS |
| Coverage: Python | FAIL (PA-1) |
| Evidence location | PASS |
| Overall | FAIL - 1 Blocking finding (PA-1, `autonomous`) |

## Appendix A: Test Inventory

| Suite | Tests (reviewer run) | Result |
|---|---|---|
| `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` | 27 | Passed |
| `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` | 72 | Passed |
| `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` | 17 | Passed |
| `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` | 8 | Passed |
| `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` | 21 | Passed |
| `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` | 34 | Passed |
| `tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1` | 21 | Passed |
| `tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1` | 3 | Passed |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 43 | Passed |
| `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` | 76 | Passed |
| `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` | 3 | Passed |
| `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | 598 | Passed |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 32 | Passed |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` | 148 | Passed |
| `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` | 14 | Passed |
| Six push-down pytest modules (spec Test Strategy) | 87 | Passed |

## Appendix B: Toolchain Commands Reference

- Pester (reviewer): scratchpad script `rev896-pester.ps1` run through `sh rev896-pester.sh`; `New-PesterConfiguration` with `Run.Path` set to the 13 suites above, `Run.PassThru = $true`; then `rev896-qc.ps1` for the two dependency-failure suites.
- PSScriptAnalyzer (reviewer): `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over 16 changed PowerShell files.
- Format (reviewer): `Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`, compared with the file text.
- Coverage parse (reviewer): `python -I <scratchpad>/cov.py artifacts/pester/powershell-coverage.xml` (JaCoCo LINE and INSTRUCTION counters at report and source-file level).
- Mirror parity (reviewer): `python -I <scratchpad>/mirror.py` (SHA256 of 9 source and mirror pairs).
- Python: `poetry run pytest -q tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py`; `poetry run black --check`, `poetry run ruff check`, `poetry run pyright` on the changed test file.
- Evidence locations: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`.
- Scope checks: `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD -- .github/instructions .claude/rules`; the same with `.codex/config.toml` and its bundle copy; the same with `.claude/settings.json`, `.claude/hooks/subagentstop-envelope.ps1`, `.claude/lib/bash/compute-concurrency-batches.sh`, the #824 folder, and the eight E2/E3 validators. Each printed nothing.
- Executor toolchain (evidence): PoshQC `Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`evidence/qa-gates/final-pester-full-run.pass3.2026-10-12T08-31.md`).
