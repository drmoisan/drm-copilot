Timestamp: 2026-11-08T13-30
Plan: docs/features/active/2026-11-08-runbook-commands-not-checked-against-pinned-tool-versions-1128/plan.2026-11-08T08-08.md

1. P1-T2: Invoke-Pester without exit enabled returns 0 on failures, so the EXIT_CODE acceptance was unsatisfiable. Task text now has the sh launcher exit with FailedCount plus FailedContainersCount.
2. P2-T1: added the ClaudeLibModuleConvention.Tests.ps1 module conventions, which that suite enforces on every module under .claude/lib.
3. P3-T2: added the EpicStateIsolation baseline mock registration required by the enforce-gate-suites.EpicStateIsolation suites (applies to P3-T3).
4. P4-T2: removed hook-dependency-failure.Claude.Tests.ps1 from the edit set. Its ReasonPrefix map is compared (B4) with settings.json registrations only; the new hook is registered in agent frontmatter, so a row there fails B4. The subagentstop-uncaught-error.Tests.ps1 ValidatorRows row (test U2) remains.
