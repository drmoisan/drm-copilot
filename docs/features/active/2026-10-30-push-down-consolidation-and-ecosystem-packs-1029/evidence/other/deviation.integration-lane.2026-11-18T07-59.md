# Non-Blocking Deviation: Local Jest Runs Exclude the Integration Lane

Timestamp: 2026-11-18T07-59
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension (and jest)
EXIT_CODE: 0
Output Summary: The plan's `## Conventions` states that `PDT/codex-bundle-publish.integration.test.ts` runs in the default local Jest run. The test-execution launcher excludes the integration lane, and `config/test-execution-policy.json` lists the suffix `.integration.test.ts`, so local gates do not run that file. Under the test-execution-policy skill, CI integration lanes are evidence: the file runs in CI in `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` and `(windows-latest)`, whose `run-jest.cjs` invocation does not pass the launcher's lane exclusion. The X8 disposition (unchanged) is therefore verified in CI, not locally. `PDT/push-down-harness.real-bundle.test.ts` (P4-T4) does not carry an excluded suffix and runs locally.
