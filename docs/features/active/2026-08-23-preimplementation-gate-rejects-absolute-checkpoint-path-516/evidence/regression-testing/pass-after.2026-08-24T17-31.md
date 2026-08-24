# Pass-After: Both Facet Suites — Issue #516

Timestamp: 2026-08-24T17-31

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1, tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1 -CI"`

EXIT_CODE: 0

Output Summary:

- Discovery found 40 tests in 2 files.
- `Tests Passed: 40, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`. Completed in 1.61s.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1` — 28 of 28 passing.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1` — 12 of 12 passing.

## Fail-before / pass-after cross-reference

| Suite | Fail-before artifact | Fail-before result | Pass-after result |
| --- | --- | --- | --- |
| Claude facet | `fail-before-claude.2026-08-24T10-15.md` | `EXIT_CODE: 28` — Passed 0, Failed 28 | `EXIT_CODE: 0` — Passed 28, Failed 0 |
| Codex facet | `fail-before-codex.2026-08-24T10-38.md` | `EXIT_CODE: 12` — Passed 0, Failed 12 | `EXIT_CODE: 0` — Passed 12, Failed 0 |

Every one of the 40 cases failed before the fix and passes after it. The two fail-before reasons —
`ParameterBindingException` on `-WorkspaceRoot` and `CommandNotFoundException` on
`ConvertTo-WorkspaceRelativePath` — are both resolved by the landed change.

## Deny-side confirmation (non-widening)

The 40 passing cases include the negative half of the matrix, so the suite proves the exemption was
not widened as well as proving the defect was fixed. The named deny cases that pass are:

| Spec decision-table row | Named test (Claude facet) |
| --- | --- |
| 8 — segment-misaligned root prefix | `denies a segment-misaligned root prefix` |
| 11 — `..`-bearing path | `denies a parent-directory segment path` |
| 12 — UNC path under a non-UNC root | `denies a UNC path under a non-UNC root` |
| 14 — checkpoint-shaped path under a different root | `denies a checkpoint-shaped path under a different root` |
| 17 — absolute production source | `denies an absolute production source write under the root` |
| 18 — absolute non-literal orchestration artifact | `denies an absolute non-literal file under the orchestration artifacts folder` |
| 19 — absolute basename match outside its literal path | `denies an absolute checkpoint basename outside its literal path` |
| 20 — drive-relative path | `denies a drive-relative path` |
| 23 — upper-cased `DOCS/` tail | `denies an upper-cased docs tail under the root` |

The Codex facet contributes four further deny cases: `denies an absolute production source write
under the root`, `denies a checkpoint-shaped path under a different root`, `denies a
parent-directory segment path`, and `denies a UNC path under a non-UNC root`.

No deny case was weakened, removed, or reworded to obtain a pass. The 78 pre-existing relative-path
assertions in the two unmodified suites (`enforce-orchestration-preimplementation-gate.Tests.ps1`,
35 tests; `legacy-codex-hook-contracts.Tests.ps1`, 43 tests) also pass unchanged, confirmed in the
full-suite run recorded in `../qa-gates/final-poshqc-test-coverage.2026-08-24T17-31.md`.

The `-CI` flag rewrites the tracked repository-root artifact `testResults.xml`. It was restored with
`git checkout -- testResults.xml` immediately after the run.
