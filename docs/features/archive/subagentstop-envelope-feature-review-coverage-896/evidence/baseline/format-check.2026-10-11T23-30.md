# Baseline PowerShell Format Check (P0-T15)

Timestamp: 2026-10-11T23-54
Command: CR-FORMAT-CHECK (scratchpad route) with <LIST> = LIST-PROD-BASE plus LIST-TEST-BASE (10 files); then CR-FORMAT-APPLY (scratchpad route) with <LIST> = the 10 files reported FORMAT-CLEAN (observation run), with git status --porcelain recorded before and after
EXIT_CODE: 0
Output Summary: FORMAT-DRIFT-COUNT: 0 (all 10 files FORMAT-CLEAN; no pre-existing drift). Apply run: 10 FORMAT-UNCHANGED lines, FORMAT-APPLIED-COUNT: 0; the before and after status outputs are byte-identical (cmp reported no difference).

## CR-FORMAT-CHECK output

```
FORMAT-CLEAN: .claude/hooks/validate-feature-review-coverage.ps1
FORMAT-CLEAN: .claude/hooks/feature-review-coverage-thresholds.ps1
FORMAT-CLEAN: .codex/hooks/validate-feature-review-coverage.ps1
FORMAT-CLEAN: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1
FORMAT-CLEAN: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
FORMAT-CLEAN: tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1
FORMAT-CLEAN: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1
FORMAT-CLEAN: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1
FORMAT-CLEAN: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
FORMAT-CLEAN: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
FORMAT-DRIFT-COUNT: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```

## CR-FORMAT-APPLY output

```
FORMAT-UNCHANGED: .claude/hooks/validate-feature-review-coverage.ps1
FORMAT-UNCHANGED: .claude/hooks/feature-review-coverage-thresholds.ps1
FORMAT-UNCHANGED: .codex/hooks/validate-feature-review-coverage.ps1
FORMAT-UNCHANGED: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1
FORMAT-UNCHANGED: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
FORMAT-UNCHANGED: tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1
FORMAT-UNCHANGED: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1
FORMAT-UNCHANGED: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1
FORMAT-UNCHANGED: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1
FORMAT-UNCHANGED: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
FORMAT-APPLIED-COUNT: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```

## git status --porcelain before apply

```
 M docs/features/active/subagentstop-envelope-feature-review-coverage-896/plan.2026-10-11T07-58.md
?? docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/baseline/
?? docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/upstream-merge-check.2026-10-11T23-30.md
```

## git status --porcelain after apply

```
 M docs/features/active/subagentstop-envelope-feature-review-coverage-896/plan.2026-10-11T07-58.md
?? docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/baseline/
?? docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/upstream-merge-check.2026-10-11T23-30.md
```
