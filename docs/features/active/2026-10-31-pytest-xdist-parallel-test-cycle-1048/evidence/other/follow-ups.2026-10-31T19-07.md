# Follow-ups recorded by #1048

Timestamp: 2026-10-31T19-07
Command: follow-up register written by P2-T11 and extended by P7-T6
EXIT_CODE: 0
Output Summary:
Each entry is a candidate follow-up for promotion; none is filed by this item.

## FU-1: adopt warnings-as-errors for pytest after a CI-matrix probe

- Source: P2-T11 (`filterwarnings = ["error"]` deferred).
- Evidence: `-W error` passed the full suite locally on Python 3.13 (15875 passed, 0 failed); the 3.10, 3.11, and 3.12 CI legs were not probed.
- Proposed work: run the `quality-checks7` matrix once with `-W error` (for example on a throwaway branch), fix or filter each version-specific warning at its source, then add `filterwarnings = ["error"]` to `[tool.pytest.ini_options]`.

## FU-2: evaluate `--import-mode=importlib`

- Source: P2-T11 (`--import-mode=importlib` deferred).
- Evidence: one failure, `tests/test_pytest_collection.py::test_repo_root_on_sys_path_allows_scripts_import`, which asserts that the repository root is on `sys.path`.
- Proposed work: decide how `scripts.*` and `tests.*` imports resolve without prepend mode (for example a `pythonpath = ["."]` setting), update that regression test to assert the chosen wiring, and re-run the full suite with `--import-mode=importlib`.

## FU-3: parse each Pester suite once in the suite-discovery guards (P7-T6)

- Files: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (184.9 s local, 188.7 s CI) and `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` (16.2 s local).
- Cost driver: each per-suite case parses the suite and the closure of modules it loads, and shared modules are parsed again for every suite.
- Proposed work: build the parsed AST and closure of every file once per run in `BeforeAll` and give each case its own read-only view. This file alone is the floor of any shard.

## FU-4: compute repository scans once per guard file (P7-T6)

- Files: `claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` (93.0 s), `claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1` (56.2 s), `claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` (14.3 s), `claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (12.9 s).
- Cost driver: several cases in each file scan the repository or the mirror again (N2 repeats both N1 scans).
- Proposed work: run each scan once in `BeforeAll`, assert per case against the stored result, and compare stored results for the mirror-parity case.

## FU-5: build the hook dependency graph once (P7-T6)

- Files: `claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (74.4 s, 671 cases) and `claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (23.6 s, 183 cases).
- Cost driver: every case walks one hook's transitive closure, or imports its modules, from the source again.
- Proposed work: compute the dependency graph of all registered hooks once per file and derive each case's edges from it.

## FU-6: profile blast-radius detection on the historical backlogs (P7-T6)

- File: `claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1` (74.2 s local, 34.1 s CI; one case 36.9 s).
- Cost driver: the production detection code itself on the recorded `followups-2026-09-27` backlog.
- Proposed work: profile the detection run on that backlog and remove repeated work in the production module, following the brief's `## Test Runtime` order (fix repeated production work first).

## FU-7: reduce process starts in hook transport and parity suites (P7-T6)

- Files: `codex-hooks/codex-pretooluse-integration.Tests.ps1` (65.3 s), `codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1` (54.7 s), `codex-hooks/codex-pretooluse-transport.Tests.ps1` (49.1 s), `codex-hooks/codex-bundle-hook-probe.Tests.ps1` (25.2 s), `codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (17.3 s).
- Cost driver: one `pwsh` (and, for routing parity, one Python CLI) process per handler, payload, or corpus case.
- Proposed work: keep one end-to-end process probe per contract and cover the remaining payload matrix through the pure decision functions in process, or send several payloads to one process per handler.
