# Acceptance Criteria Traceability (P5-T5)

Timestamp: 2026-11-08T18-08
Command: sh SCRATCH/issue-1138-scope.sh (env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; git diff --name-status BASE..HEAD; git status --porcelain)
EXIT_CODE: 0
Output Summary:
- Codex generator --check: exit 0
- git diff --name-status BASE..HEAD: 53 paths; 0 added `.py` files; 0 paths under `.codex/`
- git status --porcelain: 3 entries, all under this feature folder (the plan check-offs and the two final-gate artifacts awaiting this task's commit); no `.py` file and no `.codex/` path

AC source: `spec.md` `## Acceptance Criteria` (Work Mode: full-bug).

| AC | Verified by | Result |
| --- | --- | --- |
| AC1 | `NestingDepthContract.Tests.ps1` "agent files carry the Agent-tool preflight" (evidence/qa-gates/pester-final.*.md) | PASS |
| AC2 | `NestingDepthContract.Tests.ps1` "coordinators halt on child AGENT_TOOL_UNAVAILABLE" | PASS |
| AC3 | `NestingDepthContract.Tests.ps1` "preflight names both remedies" (plus "preflight names the three causes") | PASS |
| AC4 | `epic-invocation-nesting-depth.Tests.ps1` "guarded import failure denies"; B1 row for the `epic-invocation-nesting-depth.ps1` edge | PASS |
| AC5 | `epic-invocation-nesting-depth.Tests.ps1` "allows when unset" and "allows at or above 3" | PASS |
| AC6 | `epic-invocation-nesting-depth.Tests.ps1` "denies below 3 with remedy text" | PASS |
| AC7 | `epic-invocation-nesting-depth.Tests.ps1` "denies non-integer value" | PASS |
| AC8 | `epic-invocation-nesting-depth.Tests.ps1` "caller and target matrix" | PASS |
| AC9 | `Invoke-PoshQCLeakScan -Root` (the check the `poshqc / PowerShell QC static` job runs): 0 failures (evidence/qa-gates/poshqc-static-final.*.md); the tests mock the seam, set no environment variable, and write no file. CI confirmation of the same job on the PR head is pending. | PASS (local) |
| AC10 | Pester final gate: `epic-invocation-nesting-depth.ps1` 100.00%; `enforce-epic-invocation-origin.ps1` 90.79% vs baseline 90.41%; repo-wide 95.64% vs 95.62% | PASS |
| AC11 | `enforce-epic-invocation-origin.Tests.ps1` (setup-only seam mock, no assertion change) and `PreToolUseSchema.Contract.Tests.ps1` pass in the Pester final gate (0 failures) | PASS |
| AC12 | `NestingDepthContract.Tests.ps1` "coordinator skills document Nesting Depth and fallback" | PASS |
| AC13 | `NestingDepthContract.Tests.ps1` "orchestrate documents Nesting Depth" | PASS |
| AC14 | `test_execution_environment_brief_contracts.py` (including `test_brief_copies_are_byte_identical`) in the pytest final gate; `NestingDepthContract.Tests.ps1` "brief carries nesting-depth line" | PASS |
| AC15 | `test_push_down_claude_resource_contracts.py` in the pytest final gate; "bundle copy matches live file" | PASS |
| AC16 | `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` in the pytest final gate | PASS |
| AC17 | `test_frozen_epic_surface_matches_pinned_baseline_digest` passes with the #1138 re-baseline block | PASS |
| AC18 | Branch diff: 0 added `.py` files, 0 `.codex/` paths | PASS |
| AC19 | P5-T1 and P5-T2 static artifacts (0 findings), Pester final gate exit 0, pytest final gate exit 0, Codex generator check exit 0 | PASS |
