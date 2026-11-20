# Task Check P1-T6 (Remediation Cycle 1)

Timestamp: 2026-11-17T13-17
Command: sh SCRATCH/issue-1035-pscheck.sh p1t6 write tests/scripts/dev-tools/link-feature-docs.Tests.ps1 -- tests/scripts/dev-tools/link-feature-docs.Tests.ps1
EXIT_CODE: 0
Output Summary: Changed file: tests/scripts/dev-tools/link-feature-docs.Tests.ps1. Selection rule: the mirrored test file of scripts/dev-tools/link-feature-docs.ps1 (unchanged). Formatter `Already formatted:`; analyzer 0 findings; launcher pester selection exit code 0 (workers=1, wall-clock 190.31 s): 25 tests (23 existing plus 2 new), 0 failures, 0 errors.

- New cases: `Context "Invoke-GhCli"` / `returns the injected process output and the native exit code` (the injected -InvokeProcess sets `$global:LASTEXITCODE`; the prior value is restored in a `finally` block), and `Context "Invoke-LinkFeatureDocument"` / `throws when gh CLI is not on PATH` (Get-Command for `gh` mocked to return nothing; Invoke-GhCli is not called). The edit-failure branch stays untested per D-R3.
- `git diff --stat <Baseline-Head> -- scripts/dev-tools/link-feature-docs.ps1`: empty (exit 0).
