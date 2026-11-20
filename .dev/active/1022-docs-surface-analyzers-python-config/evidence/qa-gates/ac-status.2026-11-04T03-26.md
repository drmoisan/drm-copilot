# [P6-T13] Acceptance criteria status (issue #1022)

Timestamp: 2026-11-04T03-26
Command: check-off per the `acceptance-criteria-tracking` skill (only `- [ ]` changed to `- [x]`, criterion text unchanged), then a count of the checkbox lines inside `## Acceptance Criteria` of `FEATURE/spec.md` and `FEATURE/user-story.md`
EXIT_CODE: 0
Output Summary: spec.md 24 of 25 checked; user-story.md 13 of 14 checked. Remaining: S22 and U14 (per-file Pester line coverage measured by the `poshqc / PowerShell QC shard` jobs on `windows-latest`), pending-CI; checked off by the orchestrator at S9. Local evidence for both: `FEATURE/evidence/qa-gates/coverage-delta.2026-11-04T03-04.md` (every new module at least 99.22%).

## Checked off in this task

| AC | Evidence |
|---|---|
| S17 | `qa-scope.2026-11-04T03-22.md` (numstat 5/0 and 1/0, rows directly under the 1022 anchors, no other 1020 file except the `core.json` append); `p4-registry-rows.2026-11-04T01-18.md` and `p4-dispatch-row.2026-11-04T01-45.md` (`Test-DocsAnalyzerRegistration` and `Test-DocsCommandTable` return no finding); registry and command suites pass in `qa-push-down-contracts.2026-11-04T03-22.md` |
| S20 | `property-census.2026-11-04T03-24.md` (48 of 48 pure exported functions matched, seeded `[System.Random]`, seed in `-Because`) |
| S23 | `qa-test-hygiene.2026-11-04T03-23.md` (no purity decision, no `TestDrive`, no CR in either corpus); `qa-file-size.2026-11-04T03-23.md` (every new production file below 500 lines) |
| S24 | `qa-scope.2026-11-04T03-22.md` (every path in a classification row; no Python, TypeScript, hook, skill, agent, MCP tool or extension command file) |
| U12 | `qa-scope.2026-11-04T03-22.md`; `bundle-mirror.2026-11-04T01-53.md`; `qa-push-down-contracts.2026-11-04T03-22.md` |
| U13 | `qa-push-down-contracts.2026-11-04T03-22.md` (`enforcement-hooks-no-python-invocation.Tests.ps1` 33/33, `ships an empty allowlist` Passed); `qa-scope.2026-11-04T03-22.md` |

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/spec.md`
- Total AC items: 25
- Checked off (delivered): 24
- Remaining (unchecked): 1
- Items remaining: S22 "Pester line coverage is at least 85% for each new `.claude/lib/docs/` file, read from `artifacts/pester/powershell-coverage.xml` produced by the `poshqc / PowerShell QC shard` jobs on `windows-latest` and aggregated by the required check `poshqc / PowerShell QC`, with no production file excluded from measurement." (pending-CI)

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/user-story.md`
- Total AC items: 14
- Checked off (delivered): 13
- Remaining (unchecked): 1
- Items remaining: U14 "Pester line coverage is at least 85% for each new `.claude/lib/docs/` file, measured by the `poshqc / PowerShell QC shard` jobs on `windows-latest` and enforced by the required check `poshqc / PowerShell QC`." (pending-CI)
