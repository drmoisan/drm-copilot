# Policy Audit: orchestrator-stop-hook-validates-wrong-worktree-checkpoint (issue #1145)

- Branch: `bug/orchestrator-stop-hook-target-worktree`
- Head reviewed: `ee88894af970ed6c6455aac6df826fed2872a553`
- Base: merge base of `origin/main` and `HEAD` = `70e66be7566f4c7259acce97449c769f7ff3854a` (fetched at review time)
- Work mode: `full-bug` (AC source: `spec.md`)
- Timestamp: 2026-11-08T23-06
- Reviewer: feature-review agent

## Executive Summary

The branch adds a dot-sourced sibling, `.claude/hooks/validate-orchestrator-output-target.ps1`, that resolves the item worktree of an `orchestrator-state` stop from the delegation prompt through the existing `Resolve-SubagentStopTargetWorktree` seam, and routes the item checkpoint, routing-contract, runbook, and feature-folder checks through that root. The main hook edit is limited to two guarded load lines, two optional seam parameters, one resolver call, the fallback note, and one allow-note call. Bundle mirrors are byte-identical, the pack manifest gains the new sibling, and the six execution-environment brief copies share one content hash. Only PowerShell production code changed; no Python or TypeScript file changed.

Coverage from the pre-existing `artifacts/pester/powershell-coverage.xml` (re-parsed by the reviewer): new sibling 100% (38/38), main hook 99.30% (141/142, baseline 99.19%), resolution sibling 98.95% (94/95, baseline 98.94%), repo-wide 95.71% (36656/38300, baseline 95.67%). The reviewer ran a mutant probe that disables the item-target call site; 14 of 17 rows of the new hook-level suite fail under the mutant and all 17 pass on the unmodified copy, so the tests discriminate the fix. No blocking finding was identified. CI has not run because no pull request exists yet; CI results are pending and are not a blocking finding.

Verdict: PASS.

## Rejected Scope Narrowing

The caller instruction "Do not re-run format/lint/type checks; read the poshqc-static artifacts." is consistent with the evidence-inspection model of this agent and is not a scope narrowing; the full branch diff against the merge base was audited. No narrowing was rejected.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no reported path.
- The branch diff adds no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence lives under `<FEATURE>/evidence/{baseline,qa-gates,regression-testing,other}/`.
- Result: PASS.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence and determinism | PASS | Both new suites use in-memory seams (`-InputText`, `-ReadTranscriptHead`, `-WorktreeListInvoker`, a path-keyed `Get-CheckpointFileContent` mock, recording routing and git invokers); no clock, process, or file access. |
| No temporary files | PASS | Synthetic `/synthetic-worktrees/...` roots; no `New-TemporaryFile`, `TestDrive`, or file writes in either suite. |
| Arrange-Act-Assert and naming | PASS | Rows H1-H13 carry descriptive names and AAA comments. |
| Scenario completeness | PASS | Positive (H1, H7, H11, H12), negative (H2), fallback (H3, H4, H8, H13), NoTarget (H5 x2), Ambiguous (H6 x2), re-entry (H9), epic/parallel unchanged (H10 x2). |
| Test location mirrors source | PASS | `tests/scripts/claude-hooks/validate-orchestrator-output-target.Tests.ps1` and `validate-orchestrator-output.TargetWorktree.Tests.ps1`, beside the existing hook suites. |
| Parallel-only runs | PASS | Gates ran through `Invoke-PoshQCParallelTest` and `pytest -n auto`. |

### 1.1 Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A - zero changed TypeScript files in the branch diff
- TypeScript post-change coverage artifact: N/A - zero changed TypeScript files in the branch diff
- PowerShell baseline coverage artifact: `evidence/baseline/pester-parallel.2026-11-08T21-38.md` (figures read from `artifacts/pester/powershell-coverage.xml` of the Phase 0 run, repo-wide 95.67%)
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (re-parsed by the reviewer, repo-wide 95.71%) and `evidence/qa-gates/pester-parallel.2026-11-08T22-44.md`
- Python baseline and post-change artifact: N/A - zero changed Python files in the branch diff
- Per-language comparison summary: PowerShell repo-wide 95.67% to 95.71%, new file 100%, both modified hook files rise; no drop for any file.

### 1.2 Coverage Metrics

| Language | Framework | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | Pester 5 (parallel) | 20872 | 20862 passed, 0 failed, 10 skipped | 95.67% | 95.71% | 100% |
| Python | pytest -n auto | 16596 | 16590 passed, 0 failed, 6 skipped | N/A - zero changed Python files | N/A - zero changed Python files | N/A - zero changed Python files |
| TypeScript | Jest | N/A | N/A | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files | N/A - zero changed TypeScript files |

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.67% repo-wide line; Post-change: 95.71% repo-wide line; Change: +0.04 points; Disposition: PASS; New/changed-code coverage: 100% (new sibling 38/38; changed lines of the main hook and resolution sibling covered, the single missed line of each file is unchanged code); Evidence: `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/coverage-comparison.2026-11-08T22-49.md`.

### 1.3 Per-File Coverage (PowerShell, line)

| File | Status | Baseline | Post-change | Threshold | Verdict |
|---|---|---|---|---|---|
| `.claude/hooks/validate-orchestrator-output-target.ps1` | added | none (new) | 100% (38/38) | >= 90% (spec), >= 85% default | PASS |
| `.claude/hooks/validate-orchestrator-output.ps1` | modified | 99.19% (122/123) | 99.30% (141/142) | >= 85%, no drop | PASS |
| `.claude/hooks/validate-orchestrator-output-resolution.ps1` | modified | 98.94% (93/94) | 98.95% (94/95) | >= 85%, no drop | PASS |
| `.claude/hooks/subagentstop-target-worktree.ps1` | unchanged dependency | 100% (92/92) | 100% (92/92) | no drop | PASS |

Branch figure: Pester measures line and command metrics only, so no branch threshold is evaluated for this language (rule exemption in `.claude/rules/general-unit-test.md`).

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity and separation of concerns | PASS | New logic in a separate sibling of four small functions; main hook diff is 27 lines including doc text. |
| Reuse, no duplication | PASS | Wraps `Resolve-SubagentStopTargetWorktree` (which wraps `Resolve-HookTargetWorktree`); fallback reuses `Resolve-WorktreeOperandTarget`; no resolver logic duplicated. |
| Fail fast; no silent fallback to an unrelated checkpoint | PASS | NoTarget and Ambiguous return an unresolved target and block before any read (H5, H6 assert zero reads). Fallback is limited to no-identity and resolver-exception cases, as the spec states, and is announced by `ORCHESTRATOR_CHECKPOINT_FALLBACK:`. |
| File size tiers | PASS | Logical line counts: main hook 430, resolution 317, target 170, test files 308 and 280. None at or above 700. `config/file-size-baseline.json` unchanged. |
| No new dependencies | PASS | No package or module added. |
| No absolute paths in committed artifacts | PASS | Reviewer scan of added diff lines for drive-letter roots, user-profile paths, and scratchpad paths found only the regex text inside the scope-check evidence. |
| No new Python | PASS | `git diff --name-only` lists no `.py` file. |
| Tier classification | PASS | `quality-tiers.yml` exists and classifies `.claude/hooks` as T3; no new project root. |

## 3. Language-Specific Code Change Policy Compliance

PowerShell (`.claude/rules/powershell.md`):

| Requirement | Verdict | Evidence |
|---|---|---|
| Comment-based help on functions | PASS | All four new functions carry `.SYNOPSIS`, `.DESCRIPTION`, and `.PARAMETER` help. |
| `[CmdletBinding()]`, typed params, `OutputType` | PASS | Present on all new functions. |
| StrictMode compatibility | PASS | The main hook sets `Set-StrictMode -Version Latest`; new code reads only properties it constructs or that the resolver returns. |
| Formatter and analyzer clean | PASS | `evidence/qa-gates/poshqc-static.2026-11-08T22-43.md`: 0 format differences, 0 analyzer findings across 341 files, leak scan 0 failures. |
| ShouldProcess for state-changing functions | PASS | No new function changes system state; `Write-OrchestratorOutputAllowNote` writes to a text writer only. |
| Hook dependency guard | PASS | New dot-sources use the `Add-HookDependencyFailure` guard pattern; `hook-dependency-guard-completeness.Tests.ps1` 731 passed. |

Python, TypeScript, C#: no changed files; not applicable.

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Pester 5 structure, `BeforeAll` dot-source | PASS | Both suites dot-source the hook under `BeforeAll`. |
| Epic-state baseline mocks | PASS | `Register-EpicStateBaselineMock` names the required seams; the interception probe row passes. |
| Closure mocks declare parameters | PASS | Commit `0ac824ee8` added `param()` declarations to closure mocks. |
| Existing suites unchanged | PASS | `git diff` shows no edit to any existing `validate-orchestrator-output*.Tests.ps1`; 292 rows across those files pass. |
| Test discrimination | PASS | Reviewer mutant probe (call site replaced by `if ($false)`) in a `git archive` copy: 14 of 17 rows of `validate-orchestrator-output.TargetWorktree.Tests.ps1` fail; control copy 17 of 17 pass; `validate-orchestrator-output-target.Tests.ps1` control 31 of 31 pass. |

## 5. Test Coverage Detail

- New file `.claude/hooks/validate-orchestrator-output-target.ps1`: 38 of 38 lines covered.
- Main hook: 141 of 142 lines; the missed line lies in `Test-HumanInteractionShape` (unchanged code, missed at baseline as well).
- Resolution sibling: 94 of 95 lines; the missed line lies in `Test-OrchestratorOutputCheckpointLeafShape` (unchanged code).
- First coverage comparison pass (`coverage-comparison.2026-11-08T22-32.md`) recorded a drop in the resolution sibling; the executor added two rows covering both item branches of `Resolve-OrchestratorOutputCheckpointPath` and the second pass is clean.

## 6. Test Execution Metrics

| Gate | Result | Count | Evidence |
|---|---|---|---|
| Pester parallel (Phase 0) | exit 0 | 20484 testcases, 0 failed | `evidence/baseline/pester-parallel.2026-11-08T21-38.md` |
| Pester parallel (fail-before) | exit 1 (expected) | 16 failures, all in the new suite | `evidence/regression-testing/fail-before.2026-11-08T22-05.md` |
| Pester parallel (final) | exit 0 | 20872 testcases, 0 failed, 10 skipped | `evidence/qa-gates/pester-parallel.2026-11-08T22-44.md` |
| pytest -n auto (final) | exit 0 | 16590 passed, 6 skipped | `evidence/qa-gates/pytest-parallel.2026-11-08T22-49.md` |
| Reviewer mutant probe | discriminating | 14 of 17 fail under mutant; 17 of 17 pass on control | reviewer scratch run (not committed) |

## 7. Code Quality Checks

- Format: PASS (0 differences, `poshqc-static.2026-11-08T22-43.md`).
- Lint (PSScriptAnalyzer): PASS (0 findings).
- Type checking: the toolchain loop skips this stage for the hook language (`.claude/rules/general-code-change.md`).
- Leak scan: PASS (0 failures).
- Codex generator `--check`: PASS (exit 0).
- Bundle mirror parity: PASS (reviewer `cmp` of the three hooks and two skills against `extensions/drm-copilot/resources/claude-customizations/`).
- Brief parity: PASS (six copies, one md5 `23bc16fc9cf3b43b4e4e6a4534e11383`).
- Pack manifest: PASS (`core.json` lists `.claude/hooks/validate-orchestrator-output-target.ps1`; push-down contract tests pass in the pytest gate).
- Documentation surface check: not applicable (`docs/documentation-estate/docs-profile.json` absent at head).

## CI Cross-check

| Check | Claimed outcome | Claimed figure | Head | Source |
|---|---|---|---|---|
| Invoke-PoshQCParallelTest | pass | 20872 testcases, 0 failed; repo-wide 95.71% | c365cdf71 (production files unchanged through ee88894af) | `evidence/qa-gates/pester-parallel.2026-11-08T22-44.md` |
| pytest -n auto | pass | 16590 passed; line 97.11%, branch 94.37% | aa2efbca4 (no Python change through ee88894af) | `evidence/qa-gates/pytest-parallel.2026-11-08T22-49.md` |
| PoshQC static | pass | 0 format, 0 analyzer findings | c365cdf71 | `evidence/qa-gates/poshqc-static.2026-11-08T22-43.md` |
| Enforce Python coverage thresholds | pass | local totals above thresholds; no Python file changed | aa2efbca4 | `evidence/qa-gates/pytest-parallel.2026-11-08T22-49.md` |

The final merge commit `ee88894af` changes only `.codex/config.toml`, `extensions/drm-copilot/package.json`, and `extensions/drm-copilot/package-lock.json` (release 1.2.1 version bump), none of which is in the branch diff, so the evidence describes the reviewed production and test content. No pull request exists yet, so no remote CI run exists for this head; remote CI is pending and is not graded here.

## 8. Gaps and Exceptions

- Remote CI pending (no pull request yet). Non-blocking; the orchestrator CI green gate covers it.
- Fail-before evidence for H1 and H2 records a parameter-binding failure rather than a behavioral failure; the reviewer mutant probe closes this by showing behavioral discrimination.
- No other gap identified.

## 9. Summary of Changes

- Added `.claude/hooks/validate-orchestrator-output-target.ps1` (four functions: `Resolve-OrchestratorOutputItemTarget`, `Resolve-OrchestratorOutputItemOperandTarget`, `Get-OrchestratorOutputFallbackNote`, `Write-OrchestratorOutputAllowNote`).
- `.claude/hooks/validate-orchestrator-output.ps1`: guarded dot-source of `subagentstop-target-worktree.ps1` and the new sibling; optional `-ReadTranscriptHead` and `-WorktreeListInvoker`; item-target resolution; fallback note on block and stderr on allow.
- `.claude/hooks/validate-orchestrator-output-resolution.ps1`: optional `-ItemTarget`; item kind routes through the item target.
- Bundle mirrors, `pack-manifests/core.json`, orchestrate skill step 7, six brief copies.
- Two new Pester suites; feature folder documents and evidence.

## 10. Compliance Verdict

PASS. No blocking finding. Coverage for the only changed language (PowerShell) is PASS at file and repo-wide level; Python and TypeScript have zero changed files.

## Appendix A: Test Inventory

- `tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1`: interception probe, H1-H13 (17 rows).
- `tests/scripts/claude-hooks/validate-orchestrator-output-target.Tests.ps1`: 31 rows covering the pure functions and both item branches of `Resolve-OrchestratorOutputCheckpointPath`.
- Existing `validate-orchestrator-output*.Tests.ps1` suites: unchanged, passing.

## Appendix B: Toolchain Commands Reference

- `Invoke-PoshQCParallelTest -Root <worktree root>` (executor gate).
- `Invoke-PoshQCFormat`, `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`, `Invoke-PoshQCLeakScan` (executor static loop).
- `poetry run pytest -n auto --cov --cov-branch` (executor gate).
- Reviewer: `git diff --name-status <merge-base>..HEAD`, JaCoCo parse of `artifacts/pester/powershell-coverage.xml`, `cmp` and `md5sum` parity checks, `validate_evidence_locations.py --root`, Pester `Run.PassThru` run on a `git archive` copy for the mutant probe.
