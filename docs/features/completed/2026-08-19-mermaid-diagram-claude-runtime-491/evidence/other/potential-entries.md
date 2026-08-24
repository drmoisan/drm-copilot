# Potential entries verified (not created, not fixed) — issue #491

## [P0-T11] MCP PoshQC coverage defect

Timestamp: 2026-08-19T10-31

Verified path (present on disk):
`docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md`

Verification command: `ls -la docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md`
Result: file present, 4042 bytes, modified 2026-08-19 10:02.

Content subject (as recorded by the orchestrator): the MCP-published PoshQC resolves its own
bundled `settings/pester.runsettings.psd1`, so repo-level `CodeCoverage.Path` registration is inert
under the MCP path. This affects every module registered there, not just this feature.

Disposition in this plan: the entry is NOT created here and the defect is NOT fixed here. The plan
works around it by taking every coverage figure from the repo-module `Invoke-PoshQCTest` run.

## [P5-T12] Parity suite enumerates gitignored session state

Timestamp: 2026-08-20T11-27

Verified path (present on disk):
`docs/features/potential/2026-08-19-claude-resource-parity-enumerates-gitignored-state.md`

Verification command: `ls -l docs/features/potential/2026-08-19-claude-resource-parity-enumerates-gitignored-state.md`
Result: file present, 4042 bytes, modified 2026-08-19 10:03. Header reads
"claude-resource-parity-enumerates-gitignored-state (Potential Bug)", Status Draft, Severity
Medium.

Content subject (as recorded by the orchestrator):
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
enumerates repository `.claude/**` with `Path.rglob("*")` and does not read `.gitignore`, so the
gitignored, session-scoped `.claude/state/powershell-batch-budget.<session_id>.json` is treated as a
distributable repo file with no bundle counterpart. It should be excluded the same way
`.claude/agent-memory/**` is.

Disposition in this plan: the entry is NOT created here and the test is NOT fixed here. The plan
works around it by deleting the state file before each run of that suite ([P5-T1], [P5-T11],
[P7-T7] preconditions), which is the same deletion the batch-reset tasks perform.

Observed during execution: the workaround was necessary and sufficient. Every run of that suite in
this execution was preceded by the deletion and none failed for the state-file reason.
