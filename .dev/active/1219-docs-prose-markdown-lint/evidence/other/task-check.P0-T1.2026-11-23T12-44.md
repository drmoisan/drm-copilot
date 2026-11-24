# Task check P0-T1 (light remediation cycle 1)

Timestamp: 2026-11-23T12-44
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1 tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest, 2 workers, exit code 0; merged JUnit reports 23 tests, 0 failures, 0 errors. Not gate evidence (selection only, no coverage).

## Changed files

- `.dev/engineering/documentation-estate/consumer-onboarding.md`: first sentence of `## Linting` changed from "Linting is optional." to "Lint steps are part of the written workflow."; the existing "`check` is the required page gate: ..." sentence is kept unchanged.
- `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1`: `It` renamed to 'states that lint steps are part of the written workflow and check is the required page gate'; asserted token changed to 'Lint steps are part of the written workflow'; the assertion that `check` is the required page gate is kept.

## Selection and rule

Mirrored test file of the edited page plus every test naming `consumer-onboarding` (found by search of tests/): DocumentationEstateOnboarding.Tests.ps1, plus test-name-uniqueness.Tests.ps1 as required by the inputs. `test_discovery_documentation_contracts.py` and `copilot-layer-retirement.Tests.ps1` name the page; neither asserts the changed sentence (search for "Linting is optional" over tests/ returned only the one assertion).

## Dispositions of tests asserting the changed behavior

- `It 'states that linting is optional and check is the required page gate'`: updated (renamed, token changed) because its asserted sentence no longer exists.
- `It 'fails the statement check for an in-memory <Page> with its first token removed'`: unchanged; its Linting case uses the first token `--config docs/documentation-estate/.vale.ini`, which the sentence change does not touch.
- `It 'states every issue #1169 token in its named section'` and `It 'states the issue #1219 lint and placeholder statements'`: unchanged; their tokens do not include the replaced sentence, and the forbidden-text assertion is not matched by the new sentence.
- Name uniqueness: the new `It` name is unique (case-insensitive search of tests/ found one occurrence); test-name-uniqueness.Tests.ps1 passed.

## Static checks over tests/scripts/claude-lib/docs

- PoshQC format (MCP `run_poshqc_format`): ok; `git status --porcelain` afterwards shows only the two intended files modified (0 rewrites).
- PoshQC analyze (MCP `run_poshqc_analyze`): ok. The MCP result carries no finding count; invoked only, not a count.
- `Grep 'Linting is optional'` over `.dev/engineering/documentation-estate/` and `tests/scripts/claude-lib/docs/`: no match after the edit.
