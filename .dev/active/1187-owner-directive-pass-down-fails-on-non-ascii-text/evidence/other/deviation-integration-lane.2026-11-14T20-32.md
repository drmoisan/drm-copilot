# Non-Blocking Deviation: Integration-Lane Suite Not Run Locally

Timestamp: 2026-11-14T20-32
Severity: non-blocking
Plan task: P2-T2 (task check names tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1)

The launcher refused a local selection containing tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 with `TEST_EXECUTION_POLICY_BLOCKED: local integration lane is CI-only evidence (test-execution policy).` The file name ends in the integration lane suffix listed in config/test-execution-policy.json, and the atomic plan contract states that local test gates exclude the integration and golden lanes, that CI integration lanes are the evidence, and that a step that would run a lane locally records a non-blocking deviation under evidence/other/.

The suite therefore runs in CI only. The plan's Design Notes list it as unchanged (registration and path text only), and the remaining P2-T2 selection passed (231 passed, 0 failed). Its CI result is part of AC-20's CI part, checked at S9.
