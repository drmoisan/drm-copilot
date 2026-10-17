# CI per-file line coverage for the two files named in issue #884

Timestamp: 2026-10-15T11-47
Command: gh run download 38683717593 --repo drmoisan/drm-copilot -n shell-coverage; gh run download 38683717593 --repo drmoisan/drm-copilot -n poshqc-test-results; per-file counters read from cov.xml (Cobertura, kcov) and powershell-coverage.xml (JaCoCo, Pester) with Python xml.etree.ElementTree
EXIT_CODE: 0
Output Summary: CI run 38683717593 (workflow ci.yml, branch main, head f6915d429b5156783d1ee7eacbbe432de0f2700b, conclusion success). `.claude/lib/bash/compute-concurrency-batches.sh` LINE 44/44 = 100.00% (kcov). `.codex/hooks/validate-feature-review-coverage.ps1` LINE covered=146 missed=0 = 100.00% (Pester). Both files are at or above the 85% line floor. COVERAGE-BELOW-85: NONE.

Captured by: orchestrator (the atomic-executor tool set has no `gh` access).

## Run identity

- Run ID: 38683717593
- Workflow: ci.yml
- Branch: main
- Head SHA: f6915d429b5156783d1ee7eacbbe432de0f2700b (the base of branch `bug/untouched-files-coverage-verification-884`)
- Created: 2026-10-15T04:52:04Z
- Conclusion: success
- Coverage jobs: `shell-coverage / Shell Coverage (Bats + kcov)` (job 116253715771, success); `poshqc / PowerShell QC` (job 116253715765, success)

## Per-file measurements

| File | Tool | Artifact | Counter | Line coverage | Floor | Result |
|---|---|---|---|---|---|---|
| `.claude/lib/bash/compute-concurrency-batches.sh` | kcov | `shell-coverage` / `cov.xml` | `<class filename=".claude/lib/bash/compute-concurrency-batches.sh" line-rate="1.000">`; 44 `<line>` elements, 44 with hits > 0 | 100.00% (44/44) | 85% | PASS |
| `.codex/hooks/validate-feature-review-coverage.ps1` | Pester | `poshqc-test-results` / `powershell-coverage.xml` | `<sourcefile name="validate-feature-review-coverage.ps1">` in package `.codex/hooks`, `LINE missed="0" covered="146"` | 100.00% (146/146) | 85% | PASS |

Repository kcov aggregate on the same run: line-rate 0.952 (3256/3421).

## Production-file history

`git log -- .codex/hooks/validate-feature-review-coverage.ps1 .claude/lib/bash/compute-concurrency-batches.sh` on origin/main at f6915d429 shows the latest commits touching these files as 5e79b589c (2026-10-12, Codex hook, #896) and the PR #917 merge commit 88946d10a (2026-10-12, bats tests only). No later commit modifies either production file, so run 38683717593 measures the current content of both files.
