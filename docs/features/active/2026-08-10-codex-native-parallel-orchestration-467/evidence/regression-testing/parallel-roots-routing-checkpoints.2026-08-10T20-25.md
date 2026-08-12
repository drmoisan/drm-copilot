# Parallel Roots, Routing, and Checkpoint Regression Receipt

Timestamp: `2026-08-11T03-15-04:00`
EXIT_CODE: `0`
Output Summary: The authoritative PoshQC rerun passed `490/490`; the selected Python suite passed `1,455` with `5` skipped and `2,308` deselected; the TypeScript suite passed `187/187` suites and `2,594/2,594` tests; state, `.claude/`, and diff checks were clean.

- Plan task: `[P2-T9]`
- Baseline HEAD: `fe0413d4aca1e76b2d02d05701fba79a887d5405`
- Verified at: `2026-08-11T03-15-04:00`
- Result: `PASS`

## PowerShell root and persona contracts

Command: `mcp__drm-copilot__run_poshqc_test` with the repository workspace
root and `scan_folders=["tests/scripts/codex-hooks"]`.

- Terminal MCP result: `ok: true`.
- JUnit result: `490` tests, `0` failures, `0` errors, `0` disabled.
- `parallel-provenance.Tests.ps1`: `14` tests, `0` failures, `0` errors.

The first MCP attempt returned exit code `1`. A diagnostic replay established
that `489` tests passed and the only failure was
`codex-pretooluse-integration.Tests.ps1:196`, which requires the ephemeral
`.codex/state` directory to be absent after benign payloads. The only contents
were this execution session's verified Python and PowerShell batch-budget
receipts. Those two receipts and the resulting empty directory were removed;
no other state was changed. The authoritative MCP rerun then passed, and
`.codex/state` remains absent.

The root-provenance suite verifies all six root-only skills, the three forced
delegation routes, all three non-delegating mutation clients, and both forced
personas with `gpt-5.6-sol`, `ultra`, and `orchestrator-workspace`.

## Python routing and checkpoint proof

Command:
`poetry run pytest -q tests/scripts/dev_tools -k "parallel or codex_topology or codex_deployment"`.

- Exit code: `0`.
- Result: `1455 passed, 5 skipped, 2308 deselected in 1.86s`.
- The five skips are manifest fixtures that deliberately declare no accessor
  expectation; they are not routing or readiness skips.

The selected tests verify the exact `parallel-planner` and
`parallel-orchestrator` positive contexts, reject ordinary, epic, absent,
fallback, and cross-wired personas, prohibit model fallback, and exercise the
shared conflict, cohort, batch, mutation, drift, kickoff, and explicit
ready-for-execution contracts.

## TypeScript and MCP parity proof

Command:
`npm --prefix extensions/drm-copilot run test:unit -- --runInBand`.

- Exit code: `0`.
- Test suites: `187 passed, 187 total`.
- Tests: `2594 passed, 2594 total`.
- Snapshots: `0 total`.

The full TypeScript suite includes matching positive and negative topology and
deployment resolution, Python-authoritative mutation and drift corpora,
deterministic cohort and bounded-batch behavior, file-backed readiness evidence,
direct artifact dispatch, in-process service dispatch, and the registered MCP
handler. Ordered normalized decisions and readiness errors therefore remain
identical across the Python and MCP paths.

## Final repository checks

- `.codex/state`: absent after the terminal run.
- Protected `.claude/` diff: `0` paths.
- `git diff --check`: exit code `0`.
