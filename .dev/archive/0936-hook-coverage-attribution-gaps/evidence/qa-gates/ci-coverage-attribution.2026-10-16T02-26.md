# CI coverage attribution for the PR head (AC-5)

Timestamp: 2026-10-16T02-26
Command: poetry run python -I SCRATCH/cov936.py lines SCRATCH/ci-936/powershell-coverage.xml
EXIT_CODE: 1
ExpectedExitCode: 1
KNOWN-EXCEPTION: full-run breakpoint attribution (issue #936)
Output Summary: The `poshqc / PowerShell QC` job passed on the PR head. The `.codex/hooks` package `<line>` elements for the three AC-5 lines read ci=0 in the full CI run, which is the documented breakpoint-binding exception. Exit code 1 is the plan's accepted outcome for this command.

## Procedure and observations

- PR: 947, head `11601af7c5bc4e5b50d567aea30d377b398b589c` (`gh pr view 947 --json number,headRefOid`).
- Check `poshqc / PowerShell QC`: state SUCCESS. All 17 checks on the PR head were SUCCESS at 2026-10-16T02:26Z.
- Run: 38838872223 (`gh run view 38838872223 --json headSha,conclusion`): `headSha` `11601af7c5bc4e5b50d567aea30d377b398b589c` equals the PR `headRefOid`; `conclusion` success.
- Artifact: `gh run download 38838872223 --name poshqc-test-results --dir SCRATCH/ci-936` (new, empty directory). `find SCRATCH/ci-936 -name powershell-coverage.xml` printed exactly one path: `SCRATCH/ci-936/powershell-coverage.xml`.
- Elements below come from the package whose name ends with `/.codex/hooks`; `CODEX-PACKAGE-COUNT=1`.

## LINE output (verbatim)

```text
CODEX-PACKAGE-COUNT=1
LINE enforce-orchestration-preimplementation-gate-modes.ps1:41 mi=1 ci=0 UNATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:183 mi=1 ci=0 UNATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:190 mi=1 ci=0 UNATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:191 mi=1 ci=0 UNATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:201 mi=0 ci=1 ATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:206 mi=1 ci=0 UNATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:207 mi=1 ci=0 UNATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:209 mi=1 ci=0 UNATTRIBUTED
REQUIRED-ATTRIBUTED=False
```

## Interpretation

The three AC-5 lines (modes `:41`, epic-scope `:206` and `:207`) read `ci=0` in the full CI run. This reproduces the issue #936 condition and matches the unscoped baseline recorded in Phase 0. The scoped run recorded in `isolated-coverage-attribution` attributes the same lines (`ci=1`), which supports the breakpoint-binding explanation documented in the two test headers: each Pester 5.x line breakpoint binds to the first compiled instance of a script, so a later recompilation leaves later executions unattributed. This is recorded as the known exception, not as a defect of this change. Switching Pester to the profiler tracer is handled separately by the coordinator.
