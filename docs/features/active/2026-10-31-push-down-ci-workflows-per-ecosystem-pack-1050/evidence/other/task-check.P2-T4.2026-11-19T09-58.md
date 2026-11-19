# Task Check P2-T4

Timestamp: 2026-11-19T09-58
Command: sh SCRATCH/issue-1050-tscheck.sh test/lib/push-down/push-down-ci-contract.test-helpers.ts test/lib/push-down/push-down-ci-contract.test.ts; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/lib/push-down/push-down-ci-contract
EXIT_CODE: 0
Output Summary: Prettier check exit 0, ESLint exit 0, typecheck exit 0. Contract test: 6 passed, 0 failed. Inverting the negative case's divergence assertion makes it fail (shown below). The destination-generic and input-agreement cases assert, inside the test, that their in-memory failing variants are reported.

Changed files:
- `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test-helpers.ts` (new, 412 lines): `findCiContractDivergences`, `findHarnessWorkflowViolations`, `findPowerShellInputDivergences`, `parseWorkflowCallInputs`, `workflowSteps`, `findBlock`.
- `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts` (new, 221 lines): `harness workflows are destination-generic`, `caller, data file and consumers agree`, `reports a diverging in-memory template`, `rendered PowerShell job inputs match harness-powershell.yml declarations`, `CI bundle is complete and copies match`, `new push-down CI modules invoke no gh`. Tracked files are read read-only; no file is written.

Selection rule: the new test file (it reads the harness workflows, the CI bundle, the bundled hook texts, the new push-down modules, and `scripts/ci/Set-CiRequiredChecks.ps1`).

Discrimination evidence:
- Negative case inverted: `expect(divergences.length).toBeGreaterThan(0)` in `reports a diverging in-memory template` was changed to `toBe(0)` in place, the launcher run exited 1 with `● destination CI contract › reports a diverging in-memory template` and `Received: 3`, and the file was restored from a SCRATCH copy (`cmp` identical) and re-run green (6 passed).
- Destination-generic case: asserts that an in-memory `harness-powershell.yml` carrying `scripts/ci/` outside the side folder is reported (`powershell: names a scripts/ path outside the side folder`), that one whose checkout names `job.workflow_repository` is reported, that a `push` trigger beside `workflow_call` is reported, and that a legacy .NET job on `ubuntu-latest` is reported.
- Input-agreement case: asserts that an in-memory `harness-powershell.yml` without the `harness_ref` input is reported (`caller passes undeclared input harness_ref`) and that one whose checkout does not read `inputs.harness_repository` is reported (`harness checkout does not read inputs.harness_repository`).

Iteration within this task: the first run failed the input-agreement case because the helper looked for the text `${{ inputs.harness_repository }}` anywhere in the workflow, which the empty-input guard step's environment block also contains, so the in-memory variant was not reported. The helper now reads the side-checkout step only and requires `repository: ${{ inputs.harness_repository }}` and `ref: ${{ inputs.harness_ref }}` there; the next run passed.
