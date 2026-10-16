# ORCH-5 — Linux per-suite results on R_final (AC-6 to AC-11)

Timestamp: 2026-10-16T12-40
Command: gh run download 38899600487 -n poshqc-linux-hook-test-results -D SCRATCH/issue-952-ci-38899600487/linux; D-JUNIT over pester-junit-linux-hooks.xml
EXIT_CODE: 0
Output Summary:
R_final=38899600487 (headSha d039138bad7010475997c09aea1b55b64e0ca9b5); job poshqc / PowerShell hook suites (Linux) = success
Every B-SUITES member under tests/scripts/claude-hooks or tests/scripts/codex-hooks: 0 failing or erroring testcases, Passed count equal to its ORCH-1 Linux value; MergeQueue suites 36 and 34
VERDICT: ORCH-5 PASS (no coverage claim)

| Suite | Passed | Fail/error | Expected | Result |
|---|---|---|---|---|
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | 57 | 0 | 57 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | 16 | 0 | 16 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | 37 | 0 | 37 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1 | 2 | 0 | 2 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1 | 20 | 0 | 20 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | 13 | 0 | 13 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 | 11 | 0 | 11 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | 29 | 0 | 29 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | 14 | 0 | 14 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | 8 | 0 | 8 | PASS |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | 36 | 0 | 36 | PASS |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | 34 | 0 | 34 | PASS |
