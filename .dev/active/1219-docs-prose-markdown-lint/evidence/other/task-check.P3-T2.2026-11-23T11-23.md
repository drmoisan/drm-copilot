# Task Check P3-T2

Timestamp: 2026-11-23T11-23
Command: (1) sh SCRATCH/issue-1219-static.sh -FolderList tests/scripts/claude-lib/docs; (2) sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1 tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
EXIT_CODE: 0
Output Summary:
- Changed files: .dev/engineering/documentation-estate/consumer-onboarding.md (`## Linting`: the five DocsTonality style destinations listed, the old sentence replaced by a statement beginning `The written workflow runs markdownlint`, the `init -Write -Force` route stated; `## Consumer CI`: the lint-scope, markdownlint, checksum-verified Vale install and Vale run steps described, and the statement that PowerShell is the only runtime removed); .dev/engineering/documentation-estate/command-reference.md (`### coverage`: the `placeholders` key, its two text lines, the token `SME input required`, and that the count does not change the exit code); tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1 (`## Linting` token list updated; new test 'states the issue #1219 lint and placeholder statements').
- Selection rule: the test file that reads both engineering pages (the other repository references to a consumer-onboarding.md concern the legacy-discovery page) and the name-uniqueness guard.
- Static: EXIT_CODE 0; 133 files already formatted; 0 findings.
- Pester selection: EXIT_CODE 0 (attempt 1); 23 test cases, 23 passed, 0 failed (unchanged dispositions held: 'states that linting is optional and check is the required page gate', 'documents every Get-DocsCommandTable row with a heading and an example', 'fails the statement check for an in-memory <Page> with its first token removed').
