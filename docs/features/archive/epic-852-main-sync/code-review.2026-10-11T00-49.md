# Code Review: epic-852-main-sync (issue #852)

- Timestamp: 2026-10-11T00-49
- Branch: `chore/epic-852-main-sync-852` @ `e0cbb9bc9`; base `origin/epic/enforcement-hook-precision-integration` @ `8ee1b76e6`
- Reviewed in depth: merge commit `0ac05da8f` (combined diff), `git diff 0ac05da8f e0cbb9bc9` (31 files: 2 hook copies, 2 test suites, 27 feature-folder documents)
- Not reviewed in depth: content inherited from `origin/main` (`daa6436cd`), which is byte-identical to `main` (see `git diff-tree --cc` result below). Coverage for that content is addressed in the policy audit.

## Executive Summary

The branch-authored change is small and consistent with the established 786 import-guard pattern. The merge commit introduces no line absent from both parents; the only resolved conflict (`pack-manifests/core.json`) keeps the full union of both sides in sorted order. The guard change is placed before `$ErrorActionPreference = 'Stop'`, which keeps the guard-load-failure path fail-closed. The new ThresholdsGuard suite exercises the failure through the process route, the dot-source route, and the decision function, for both the Claude copy and the bundle mirror, and was shown to fail before the fix. No blocking code-quality finding was identified. Three informational observations are listed.

## Merge Commit Review

- Parents: `9add694e4` (integration tip plus Phase 0 evidence) and `daa6436cd` (`origin/main`). Two parents, no rebase.
- `git diff-tree --cc 0ac05da8f | grep -c '^++[^+]'` = 0: no line in the merge result is new relative to both parents.
- Files with combined hunks: both Claude hook copies (adjacent-line auto-merge of the 786 guard line from the integration side and the thresholds dot-source from `main`), `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/parallel-plan/SKILL.md` and their mirrors (auto-merged; no `--cc` hunks emitted), and `core.json`.
- `core.json` against `9add694e4`: adds `feature-review-coverage-thresholds.ps1`, `parallel-mutation.sh`, `remove-parallel-item.sh` (the three main-only entries). Against `daa6436cd`: adds the eleven integration-only entries. Each insertion is at its sorted position. Executor evidence reports union 216 = merged 216, 0 missing, 0 extra (`evidence/other/p1-conflict-resolution.md`); the reviewer's two parent diffs are consistent with that result.

## Post-Merge Change Review

- `.claude/hooks/validate-feature-review-coverage.ps1:47` and bundle mirror: the unguarded `. (Join-Path $PSScriptRoot 'feature-review-coverage-thresholds.ps1')` after `$ErrorActionPreference = 'Stop'` is replaced by a single-statement `try { . ... } catch { Add-HookDependencyFailure -Name 'feature-review-coverage-thresholds.ps1' -ErrorRecord $_ }` placed immediately after the guard dot-source. This matches the form used in other guarded hooks (for example `.claude/hooks/enforce-completion-consistency.ps1:55`). Before the change, a thresholds load failure would throw a terminating error under `Stop`, which for a SubagentStop hook exits 1 (non-blocking), i.e. fail open. After the change, the failure is recorded and both the decision function (line 351) and the script tail (lines 468-469) return exit 2.
- `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` (new, 121 lines): TG1 runs the hook through `&` with stderr captured and checks exit 2, reason prefix, and dependency name; TG2 dot-sources and asserts no throw plus the recorded failure name; TG3 asserts the decision function returns ExitCode 2. State and console redirection are restored in `finally`.
- `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`: the hook dot-source moves to a file-level `BeforeAll` with `$null` default mocks; the `Describe`-level `BeforeAll` restores three real implementations through `-MockWith` and F824-9 restores the real `Get-ArtifactFileContent`. No `It` name or `Should` line changed (`evidence/other/p2-issue824-isolation.md`).

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/hooks/validate-feature-review-coverage.ps1` (and mirror) | lines 46-49 | The fail-closed behavior on a guard-load failure depends on line 47 executing before `$ErrorActionPreference = 'Stop'` (line 49): with the guard absent, `Add-HookDependencyFailure` raises a statement-terminating error that does not stop the script, so execution reaches the line-467 exit 2. The ordering is correct but not commented. | No change required; this is the repository-wide 786 convention. Consider a shared comment in `hook-dependency-guard.ps1` documenting the ordering dependency. | Prevents a future edit from moving the guarded lines below the `Stop` assignment. | `git diff 0ac05da8f e0cbb9bc9 -- .claude/hooks/validate-feature-review-coverage.ps1` |
| Info | `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` | lines 59-121 | The same two-row `-ForEach` table is repeated for TG1, TG2 and TG3. | Optional: hoist to a discovery-time `BeforeDiscovery` variable. | Reduces duplication; current form is readable and passes. | file lines 59-62, 78-81, 101-104 |
| Info | `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` | lines 21-38 | The restore-by-`-MockWith ${function:...}` pattern keeps every `Describe` test on a mock wrapper rather than the bare function. Behavior is equivalent and all cases pass. | No change required. | Consistent with the #737 reference isolation shape. | `evidence/qa-gates/p2-isolation-guard.md`, `evidence/qa-gates/final-ac3-pester.md` |

Blocking findings in this code review: 0. (The three blocking coverage-artifact findings are recorded in the policy audit.)

## Best-Practice Checklist

- Single responsibility and minimal diff: PASS.
- Error handling (no silent swallow): PASS; the catch records and the gate blocks.
- Mirror parity (Claude, bundle): PASS (blob `814104838` for both).
- Codex copies: unchanged and pair-equal (blob `49f8f70ea`); they do not reference the thresholds file, so no guard is required there.
- Tests: deterministic, no temp files, no network, AAA structure: PASS.
- File size cap: PASS (max 477 lines).
- Tone of documentation: professional and factual; no absolute host paths in the feature folder.
