# PowerShell Test Baseline (Issue #931)

Timestamp: 2026-10-16T01-26
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = <worktree>, scan_folders = ["tests/scripts/dev-tools"])
EXIT_CODE: 0
Output Summary: Scoped call returned "ok":true. Two full-suite calls (no scan_folders) were aborted by the client-side MCP idle timeout before returning an ok value; this is recorded as a deviation below. No count, percentage, or finding is asserted from the MCP result.

Call result (scoped call): `"ok":true`
Summary (verbatim, host path replaced with `<worktree>`): `Ran bundled PoshQC test against '<worktree>' with 1 selected scan folder(s).`

## Deviation: full-suite calls exceeded the MCP idle timeout

| Attempt | Call | Disposition |
|---|---|---|
| 1 | `run_poshqc_test` with `workspace_root` only | aborted by the client: "sent no response or progress for 1802s"; no `ok` value returned |
| 2 | `run_poshqc_test` with `workspace_root` only | aborted by the client: "sent no response or progress for 1814s"; no `ok` value returned |
| 3 | `run_poshqc_test` with `scan_folders = ["tests/scripts/dev-tools"]` | `"ok":true` (recorded above) |

Cause (observed): the full Pester suite takes about 1774 s of test time on this host, with several concurrent `pwsh` workloads from other sessions running. With setup and coverage overhead, each run exceeds the 1800 s client idle timeout. The plan's Decision 4 states that the MCP tools cannot target a subset; the tool does accept an optional `scan_folders` argument, which was used for attempt 3. The scoped folder contains every release-flow Pester suite. The full-suite result of record for this item is the PR CI job `poshqc / PowerShell QC`.

## Supplementary local observation (not an acceptance basis)

The aborted attempt 2 still ran to completion in the background and wrote `<worktree>/artifacts/pester/pester-junit.xml` (git-ignored). Its root element read: `tests="10376" errors="0" failures="0" disabled="10" time="1773.697"`. The scoped attempt 3 then overwrote that file; its root element read `tests="624" errors="0" failures="0" disabled="2" time="34.901"`. These values are recorded for transparency only. The plan reads no count from PoshQC runs.
