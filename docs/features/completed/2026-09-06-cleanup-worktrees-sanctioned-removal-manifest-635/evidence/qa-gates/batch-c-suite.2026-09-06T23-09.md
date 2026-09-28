# Batch C Full-Suite Gate

Timestamp: 2026-09-08T04-40

Task: [P3-T24]

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the branch worktree and **no
`scan_folders` argument**, so the full configured scan set from `config/poshqc-scan.json` runs.

EXIT_CODE: 2

ExpectedExitCode: 2

## Route

This gate asserts a failing-set inventory rather than a coverage number, so it does not need the new
`CodeCoverage.Path` entry honored and the MCP runner is the valid route. The self-hosted PoshQC
invocation cannot run in this worktree at all, because the runtime worktree-isolation guard refuses
every `pwsh` invocation issued here.

## Whole-run totals

Root `testsuites` start tag from the `artifacts/pester/pester-junit.xml` this run wrote,
transcribed verbatim:

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="4460" errors="0" failures="2" disabled="9" time="144.945">
```

The element carries no `passed` attribute, so the passed count is derived by the subtraction rule in
the plan's toolchain preamble.

- Total tests: 4460
- Failed: 2
- Errors: 0
- Disabled (skipped): 9
- **Passed (derived): 4460 - 2 - 0 - 9 = 4449**

The MCP runner returns a JSON result object and does not relay the module's console totals line, so
no value here is read from console text.

## Failing-node inventory (2 of 2)

| # | Suite file | Node name | Classification |
| --- | --- | --- | --- |
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `enforce-pr-author-skill.ps1` > `allowed commands` > `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | Known-Local-Red Inventory member 1 |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `Every registered Codex PreToolUse handler accepts every tool name its matcher admits` > `allows every registered handler for every tool name its own matcher admits` | Known-Local-Red Inventory member 2 |

The observed `EXIT_CODE` of 2 equals the number of failing nodes this artifact names, that set is
exactly the two-member Known-Local-Red Inventory recorded in the plan's toolchain preamble, and no
other test failed. Both are produced by this run's own `epic_mode: true` orchestration checkpoint
under gitignored `artifacts/` and both pass in the canonical environment on `_poshqc.yml` run
`34186767775`.

This is the first inventory-clean gate that runs after the Phase 2 expect-fail additions. Both of
those tests were made passing by P3-T3 and P3-T5, which ran earlier in this phase, so the gate was
satisfiable at the point it ran.

## Batch C suite composition

| Suite | `testsuite` counts from this run |
| --- | --- |
| `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` | 82 tests, 0 errors, 0 failures — 41 cases exercised against each of the two gates |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | 50 tests, 0 errors, 0 failures |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | 49 tests, 0 errors, 0 failures |

## Toolchain steps preceding this run

| Step | Command | Result |
| --- | --- | --- |
| Format | `mcp__drm-copilot__run_poshqc_format` | Ran twice. The first pass rewrote `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`, so the loop restarted from format per the mandatory order; the second pass left the tree unchanged. Exit status 0 on both. |
| Analyze | `mcp__drm-copilot__run_poshqc_analyze` | `ok: true`; exit status 0. No findings. |
| Test | `mcp__drm-copilot__run_poshqc_test` | exit status 2, recorded above as this artifact's `EXIT_CODE`. |

Each per-step status is transcribed in a form whose text before the first colon is not exactly
`EXIT_CODE`. This file carries exactly one line whose pre-colon text is exactly `EXIT_CODE`, the
`EXIT_CODE: 2` row above, matched by its `ExpectedExitCode: 2` declaration.

Output Summary: Full configured scan set, 4449 passed, 2 failed, 9 skipped, exit code 2. The passed
and failed counts are derived from the root `testsuites` start tag transcribed above. The two
failing nodes are named in full and are exactly the two-member Known-Local-Red Inventory; no other
test failed. The three Batch C suites report zero failures and zero errors between them.
