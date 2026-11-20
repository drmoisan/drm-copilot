# Non-Blocking Deviation: Integration-Lane Jest Suite (H3 Plan)

Timestamp: 2026-11-19T15-15
Plan: plan-h3-sync-writer-retirement.md
Deviation: P1-T2 and P2-T2 name `extensions/drm-copilot/test/extension.integration.test.ts` among the suites that pass. That file matches the `.integration.test.ts` pattern of the integration lane in config/test-execution-policy.json, so the local launcher excludes it from every local Jest run and a local selection of it is a lane selection that the launcher refuses. Its pass evidence is the CI run of the branch (`drm-copilot-extension-tests / drm-copilot Extension Tests (<os>)`).
Change made to the suite: one test deleted (`syncAgentsFromInstructions runs the bundled PowerShell template against the active workspace root`); no other test in the file names the removed command. Prettier, ESLint and typecheck (which covers the test tsconfig) pass over the edited file.
Classification: non-blocking (the atomic-plan-contract states that local test gates exclude the integration and golden lanes and that CI lanes are evidence).
