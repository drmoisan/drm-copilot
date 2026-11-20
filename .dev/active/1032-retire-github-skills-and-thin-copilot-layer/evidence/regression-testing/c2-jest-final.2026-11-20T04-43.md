# Cycle-2 Final Jest Gate ([P1-T7], GATE-RUN)

Timestamp: 2026-11-20T04-43
Plan: remediation-plan.2026-11-19T19-58.md
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage --coverageReporters=json-summary --coverageReporters=text-summary --coverageDirectory=SCRATCH/issue-1032-c2-jest-cov --json --outputFile=SCRATCH/issue-1032-c2-jest.json (Jest of extensions/drm-copilot through its normal parallel workers, started 2026-11-20T04-42 UTC); named-suite summary by sh SCRATCH/issue-1032-c2-run.sh issue-1032-c2-jestsum.ps1
EXIT_CODE: 0
Output Summary: 394 suites passed, 0 failed; 6450 tests passed, 0 failed (21.555 s).
  Repository-wide coverage: lines 97.51% (71883/73715), branches 94.83% (11414/12036); BASELINE-REF (h3-jest-final.2026-11-19T16-55.md): lines 97.42% (68402/70212), branches 94.63% (10595/11196); no drop. The suite, test and denominator increases come from INCOMING-DELTA (#1049, #1050, #1051).
  Failing tests: none.

## Named suites

| Suite | Passed | Failed | Note |
| --- | --- | --- | --- |
| `push-down-bundle-manifest-completeness.test.ts` | 6 | 0 | includes `lists every Copilot bundle file` |
| `copilot-customizations-engine.test.ts` | 15 | 0 | |
| `push-down-integration-skill.test.ts` (updated by P1-T3) | 8 | 0 | `S51 positive: the four copies are byte-identical` passed; `S51 negative: a copy that differs by one byte is detected` passed |
| `push-down-ci-contract.test.ts` (updated by P1-T3) | 8 | 0 | `every brief copy names the CI data file after the refresh rule` passed |
| `push-down-pack-resolver.test.ts` | 20 | 0 | |
