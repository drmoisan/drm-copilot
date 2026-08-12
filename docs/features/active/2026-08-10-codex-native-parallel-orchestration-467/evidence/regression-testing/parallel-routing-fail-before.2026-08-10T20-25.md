# Parallel Provenance and Routing Fail-Before Receipt

Timestamp: `2026-08-11T00:55:08-04:00`

- Plan task: `[P2-T2]`
- Baseline HEAD: `fe0413d4aca1e76b2d02d05701fba79a887d5405`
- Expected state: `[expect-fail]`

## PowerShell/Pester

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root="C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-10T19-25"`
and `scan_folders=["tests/scripts/codex-hooks"]`

EXIT_CODE: `15` (expected non-zero)

Output Summary: The bundled PoshQC runner returned `ok: false` and
`Command exited with code 15`. A focused classification run of
`tests/scripts/codex-hooks/parallel-provenance.Tests.ps1` discovered `14`
tests and produced `14 failed, 0 passed, 0 skipped`. All failures are missing
file assertions for the six absent Codex root skills and the two absent forced
persona profiles. No analyzer, syntax, parameter-binding, or existing-hook
failure remains. The first classification exposed an invalid `Set-ItResult`
parameter combination in six new tests; that test-only defect was corrected,
PoshQC format/analyze passed, and the authoritative PoshQC and focused runs
above were rerun after the correction.

## Python

Command: `poetry run pytest -q tests/scripts/dev_tools -k 'codex and (topology or deployment or routing)'`

EXIT_CODE: `1` (expected non-zero)

Output Summary: `20 failed, 94 passed, 3623 deselected in 1.09s`. Every
failure is in the new parallel cases in
`test_resolve_codex_topology.py` or `test_resolve_codex_deployment.py`. The
current authority rejects `parallel_planning` and `parallel_execution` before
it can select `parallel-planner` or `parallel-orchestrator`, enforce the
context/persona match, or exercise Sol/Ultra no-fallback routing. Existing
standalone and epic topology/deployment cases passed.

## TypeScript Topology

Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/codex-topology-resolver.test.ts`

EXIT_CODE: `1` (expected non-zero)

Output Summary: `1` suite failed with `10 failed, 31 passed, 41 total`. All
ten failures are new parallel cases. The current resolver's valid-context set
omits `parallel_planning` and `parallel_execution`, so the expected forced
persona selection and mismatched-persona rejection messages are not yet
available. Existing standalone and epic topology cases passed.

## TypeScript Model-Routing Diagnostic

Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/orchestrator-state-codex-model-routing.test.ts`

EXIT_CODE: `1` (expected non-zero)

Output Summary: `1` suite failed with `4 failed, 25 passed, 29 total`. The
four failures are the two absent forced parallel routes, downgraded-receipt
field diagnostics that cannot yet resolve the parallel context, and the
no-fallback assertion that currently receives the unsupported-context error
before model availability is evaluated. The new absent and mismatched receipt
rejection cases passed, as did every pre-existing model-routing case.

## Attribution Decision

All authoritative rerun failures are attributable only to the absent parallel
root skills, forced persona profiles, execution contexts, and model routes
implemented by `[P2-T3]` through `[P2-T7]`. Formatting, analyzer/lint, and type
checks passed before the expected-failure runs. No unrelated regression remains.
