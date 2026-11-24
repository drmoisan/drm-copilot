# Preflight Fixes (round three, after the OD-11 revision)

Timestamp: 2026-11-23T06-55
Plan: .dev/active/1219-docs-prose-markdown-lint/plan.2026-11-23T00-38.md
Command: single-pass preflight review, round three (DIRECTIVE: PREFLIGHT VALIDATION ONLY); validators `env -u VIRTUAL_ENV poetry -C <worktree> run python scripts/dev_tools/validate_orchestration_artifacts.py plan .dev/active/1219-docs-prose-markdown-lint/plan.2026-11-23T00-38.md` and MCP `validate_orchestration_artifacts` (artifact_type plan)
EXIT_CODE: 0
Output Summary: The three round-two defects are resolved in the task text of P2-T2 and P1-T3. Four trivial defects were fixed in place in task text. No task was added, removed, or reordered. Both validators passed after the fixes. No substantive defect remains. The earlier fix records are unchanged.

## Fixes

1. [P1-T3] | validator-blind: non-discriminating assertion | The key-position assertion read `$result.Keys` of the parsed JSON envelope. `ConvertTo-DocsCanonicalJson` (`.claude/lib/docs/DocsJson.psm1`) sorts keys, and `placeholders` sorts directly after `parity`, so that assertion passed for any insertion position. It now reads the keys of the `Result` of a direct `Invoke-DocsCoverageCommand` call on the same fixture, where `Get-DocsCoverageReport` returns an ordered dictionary. The asserted rule (the key follows `parity`) is unchanged.
2. [P2-T2] | literal formatting | The last-line assertion of the Vale run block now states that the line is trimmed; block lines carry YAML indentation. What is asserted is unchanged.
3. [P2-T2] | AC traceability wording | `It 'pins every uses: reference to a commit SHA with a version comment'` now names the spec AC conjunct that the `actions/checkout` and `actions/upload-artifact` references equal the `### Workflow pins` commits; the task acceptance already bound the test to the spec AC literals.
4. [P3-T2] | AC traceability wording | The new `It 'states the issue #1219 lint and placeholder statements'` now also asserts that `## Linting` of `consumer-onboarding.md` lacks `No workflow step runs Vale or markdownlint`, which the task's "update the token list the same way" and the `Review checklists` Pre-Mortem bullet already state and the user-story AC requires.
