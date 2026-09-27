# Phase 0 Formatter Baseline (issue #673)

Timestamp: 2026-09-19T17-26

Command: `git status --porcelain`; then `pwsh -NoProfile -File <SCRATCHPAD>/r3-format.ps1` (route `a`), whose body is `$ErrorActionPreference = 'Stop'` / `$root = (Get-Location).Path` / `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force` / `Invoke-PoshQCFormat -Root $root`; then `git status --porcelain` again.

EXIT_CODE: 0

Formatted count (lines beginning `Formatted: `): 0
Already-formatted count (lines beginning `Already formatted: `): 496

The formatter emitted no output line other than the 496 `Already formatted: ` lines. No tracked file was rewritten, so no `git checkout -- <path>` revert was required and no third porcelain output exists.

Tree Delta:

Porcelain before:

```
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/r3-execution-route.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/r3-phase0-base-ref.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/r3-phase0-feature-documents-read.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/r3-phase0-instructions-read.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/other/r3-ac19-row-audit.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/other/r3-current-tree-facts.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/other/r3-reproduction-evidence-audit.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-18T13-30.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-18T16-00.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-19T09-00.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/remediation-inputs.2026-09-19T10-30.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/remediation-inputs.2026-09-19T14-45.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/remediation-inputs.2026-09-19T18-20.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/remediation-inputs.2026-09-19T22-10.md
```

Porcelain after:

```
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/r3-execution-route.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/r3-phase0-base-ref.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/r3-phase0-feature-documents-read.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/r3-phase0-instructions-read.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/other/r3-ac19-row-audit.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/other/r3-current-tree-facts.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/other/r3-reproduction-evidence-audit.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-18T13-30.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-18T16-00.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-19T09-00.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/remediation-inputs.2026-09-19T10-30.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/remediation-inputs.2026-09-19T14-45.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/remediation-inputs.2026-09-19T18-20.md
?? docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/remediation-inputs.2026-09-19T22-10.md
```

The two outputs are identical, line for line, and every path in both is under the feature folder.

Output Summary: The baseline tree carries zero PowerShell format drift. The formatter reported 496 files already formatted and rewrote none, and the porcelain output is byte-identical before and after the run. This is the observation `[P11-T1]` must reproduce at the end of the plan; because the baseline is already clean, a non-zero `Formatted: ` count in `[P11-T1]` would name drift this change set introduced rather than pre-existing drift the formatter repaired.
