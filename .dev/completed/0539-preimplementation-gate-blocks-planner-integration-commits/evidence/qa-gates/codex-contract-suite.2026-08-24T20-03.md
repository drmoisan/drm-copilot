# Codex Contract Suite and Command-Exemption Suite — issue #539 [P5-T5]

Timestamp: 2026-08-24T20-03

Command:

```
mcp__drm-copilot__run_poshqc_test
  workspace_root: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5
  scan_folders:
    - tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
    - tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
```

Preceded in this batch by `mcp__drm-copilot__run_poshqc_format` and
`mcp__drm-copilot__run_poshqc_analyze` over `tests/scripts/codex-hooks`, `.codex/hooks`, and
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks`. Format changed no
file (verified by `git status` and by recomputing the two Codex pair hashes after the run) and
analyze reported no findings, so the loop was not restarted.

EXIT_CODE: 0

## Counts, extracted from `artifacts/pester/pester-junit.xml`

| Suite | Tests | Failures |
| --- | --- | --- |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 58 | 0 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 43 | 0 |
| **Total** | **101** | **0** |

Errors: 0. Elapsed: 17.284s.

## Checks this run newly exercises

The `legacy-codex-hook-contracts` suite could not run in Phase 3, because its byte-identity check
compares the canonical `.codex` copies against bundle copies that Phase 5 supplies. With [P5-T1],
[P5-T2], [P5-T3], and [P5-T4] landed, the suite runs and passes, which exercises:

- **Parse and 500-line cap** over both the canonical and the bundled copy of every name in
  `$script:StaticCheckNames`, which now includes `enforce-orchestration-preimplementation-gate-helpers.ps1`.
- **Byte-identity** of the canonical and bundled Codex helper (`45C339FD...`) and of the canonical
  and bundled Codex hook (`F1243BC5...`).
- **No legacy `$env:CLAUDE_` read** in the new Codex helper.
- **Pack-manifest listing**: `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
  is asserted present in
  `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- **Unchanged in-process classification table**, in which the pathless message-only commit fixture
  still classifies as an implementation command.

## Coverage observation (not an acceptance condition of this task)

The per-file line-coverage rows extracted from `artifacts/pester/powershell-coverage.xml` for this
run are:

| Package | Source file | Covered | Missed | Total | Line % |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 0 | 112 | 112 | 0.0 |
| `.codex/hooks` | `enforce-orchestration-preimplementation-gate.ps1` | 123 | 1 | 124 | 99.2 |

The `.claude` row is 0% because only the two Codex suites ran; that file is instrumented but not
executed by this scan set.

**Neither new helper appears as a coverage row.** See the Deviation section of the executor
completion report and the accompanying analysis below.

## Why the [P4-T3] mirror edit did not place the helpers in the coverage denominator

The [P4-T3] acceptance conditions are met — both helper entries are present in
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, and the
pre-change byte-equality relation between the two runsettings copies is preserved (both now
`B63302F2...`) — and [P4-T6] passes on that basis. The coverage expectation carried into Phase 4,
however, is not met, and the reason was measured rather than inferred:

`mcp__drm-copilot__run_poshqc_test` resolves its settings from the INSTALLED extension, not from
either copy in this repository. The effective file is

```
C:\Users\DanMoisan\.vscode-insiders\extensions\danmoisan.drm-copilot-1.1.0\resources\powershell\PoshQC\settings\pester.runsettings.psd1
```

Two grep counts against that file settle it:

- `enforce-parallel-drift-gate-helpers.ps1` — 1 occurrence. That precedent helper sibling DOES
  appear as a coverage row in this run's report, confirming the file is the effective allow-list.
- `enforce-orchestration-preimplementation-gate-helpers.ps1` — 0 occurrences. The two new helpers
  are therefore absent from the effective allow-list and are silently omitted from the JaCoCo
  report rather than reported at 0%.

The installed extension is outside this repository and outside the change scope of this plan; it is
refreshed by an extension rebuild and reinstall, not by a source edit. Both repository-side
registrations ([P2-T3], [P3-T3] self-hosted; [P4-T3] bundled mirror) are nonetheless correct and
required: they are what a rebuilt extension will publish, and the mirror edit is what restores the
parity gated by `test_poshqc_bundled_module_files_match_repo_root_sources` (spec AC 9).

Output Summary: PASS. 101 tests, 0 failures, 0 errors, exit code 0. Both Codex suites pass,
including the byte-identity check over the canonical and bundle Codex hook and helper, the
pack-manifest listing check for the helper, and the unchanged in-process classification table.
Format and analyze were clean and changed no file. Coverage rows were recorded for the two gate
hooks (`.claude` 0.0% not-executed, `.codex` 99.2%); neither new helper appears as a coverage row,
because the MCP runner reads the installed extension's runsettings, which no repository-side edit
in this plan can reach.
