# Task Check P1-T3 (advisory-fix plan: copy-mode tests-directory guard)

Timestamp: 2026-11-19T12-50
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down/push-down-ci-contract.test.ts test/lib/push-down/push-down-ci-layer.test.ts test/lib/push-down/push-down-harness.ci-workflows.test.ts test/mcp-tool-inputs.push-down-ci-workflows.test.ts
EXIT_CODE: 0
Output Summary: 4 suites passed, 44 tests passed, 0 failed (attempts 1-5 exit 75, queue timeout; attempt 6 exit 0). actionlint 1.7.12: 0 findings on both workflow copies. Prettier, ESLint, tsc: exit 0.

Changed files:
- .github/workflows/harness-powershell.yml (step `Run Pester tests with coverage` fails with `Copy mode requires a top-level tests directory.` and `exit 1` when `tests` is absent)
- extensions/drm-copilot/resources/ci-workflows/workflows/harness-powershell.yml (byte copy; both hash 2fcf236c2aaf23e24aab252d11ec4a66477d5532)
- extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test-helpers.ts (`findPowerShellHarnessViolations` reports `powershell: copy-mode Pester step does not fail when tests is absent`)
- extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts (negative case in `harness workflows are destination-generic`)

Selection rule: the contract test that reads the changed workflow and its helper, plus the three test files that name `harness-powershell.yml` or the CI bundle (`push-down-ci-layer.test.ts`, `push-down-harness.ci-workflows.test.ts`, `mcp-tool-inputs.push-down-ci-workflows.test.ts`).

Steps:
1. actionlint 1.7.12 over both workflow copies: exit 0, 0 findings.
2. npx prettier --check over the two TS files: exit 0 ("All matched files use Prettier code style!").
3. npx eslint over the two TS files: exit 0.
4. npm run typecheck (tsc, src and test projects): exit 0.
5. Jest selection: exit 0, 44/44 passed, including `harness workflows are destination-generic`, `rendered PowerShell job inputs match harness-powershell.yml declarations`, and `CI bundle is complete and copies match`.
