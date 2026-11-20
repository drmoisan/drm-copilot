# Task Check [P1-T3]

Timestamp: 2026-11-19T20-53
Plan: remediation-plan.2026-11-19T19-58.md
Command: sh SCRATCH/issue-1032-c2-ts-static.sh (in extensions/drm-copilot: npx prettier --check <two TS tests>; npx eslint --max-warnings 0 <two TS tests>; npm run --silent typecheck); sh SCRATCH/issue-1032-c2-ps-static.sh tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.RepoGate.Tests.ps1 (Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 and an Invoke-Formatter comparison); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension test/packaging/push-down-integration-skill.test.ts test/lib/push-down/push-down-ci-contract.test.ts (then the same with --json --outputFile=SCRATCH/issue-1032-c2-p1t3-jest.json); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.RepoGate.Tests.ps1 tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1
EXIT_CODE: 0
Output Summary: three tests updated to the four remaining brief or skill copies. Prettier printed "All matched files use Prettier code style!"; ESLint 0, typecheck 0; PSScriptAnalyzer findings=0 and the formatter left the file unchanged; Jest 2 suites, 16 tests passed (S51 positive, S51 negative and the brief-copy case passed); Pester 61 passed, 0 failed.

## Updated tests

| Test file | Change | Reason | Result |
| --- | --- | --- | --- |
| `extensions/drm-copilot/test/packaging/push-down-integration-skill.test.ts` | `COPIES` reduced to `.agents/${SKILL}`, `.claude/${SKILL}`, `${RESOURCES}/codex-and-agents-customizations/.agents/${SKILL}`, `${RESOURCES}/claude-customizations/.claude/${SKILL}`; titles `S51 positive: the four copies are byte-identical` and the S51 negative case; the negative case mutates `texts[3]`; module comment says four tracked copies | the two Copilot copies (IncomingRetiredAdds) are deleted by P1-T1 | passed: `S51 positive: the four copies are byte-identical`, `S51 negative: a copy that differs by one byte is detected`, and every other case in the file |
| `extensions/drm-copilot/test/lib/push-down/push-down-ci-contract.test.ts` | the `copies` list of `every brief copy names the CI data file after the refresh rule` drops both RETIRED-BRIEF-COPIES, leaving the four REMAINING-BRIEF-COPIES | the retired brief copies are deleted by P1-T1 | passed |
| `tests/scripts/powershell/PoshQC/PoshQC.VendoredCoverage.RepoGate.Tests.ps1` | `$script:BriefCopies` drops both RETIRED-BRIEF-COPIES, leaving the four REMAINING-BRIEF-COPIES | the retired brief copies are deleted by P1-T1 | passed: the four `every brief copy names the vendored push-down exception: <copy>` cases and the rest of the file |

No updated test holds RETIRED-PATH as a literal or lists a retired-tree copy (Grep for `.github/skills`, `.github/${` and `customizations/.github` over the three files: the one match is `customizations/.github/instructions/general-unit-test.instructions.md`, a REMAINING-COPILOT-ROOTS path, not a retired tree).

## Selection and rule

Named by the task: static steps scoped to each edited file; the Jest selection of each edited TypeScript test through the launcher `jest-extension` suite; the edited Pester test and `tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1` through the launcher `pester` suite with `-TestPath`.

## Results

| Step | Exit | Result |
| --- | --- | --- |
| Prettier check (2 files) | 0 | All matched files use Prettier code style! |
| ESLint, `--max-warnings 0` (2 files) | 0 | 0 findings |
| `npm run typecheck` (extension and test tsconfigs) | 0 | 0 errors |
| PSScriptAnalyzer (1 file) | 0 | findings=0 |
| Invoke-Formatter comparison (1 file) | 0 | unchanged=True |
| Jest selection | 0 | 2 suites, 16 tests passed, 0 failed |
| Jest selection with `--json` (to name the cases) | 0 | the three named cases above report `passed` |
| Pester selection (2 shards) | 0 | 22 + 39 = 61 passed, 0 failed |
