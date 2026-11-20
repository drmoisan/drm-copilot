# Final QA loop — outcome per language

Timestamp: 2026-09-07T19-32

## Python

| Order | Step | Artifact | EXIT_CODE |
| --- | --- | --- | --- |
| 1 | Formatting — `poetry run black .` | `evidence/qa-gates/final-python-black.2026-09-07T18-25.md` | 0 |
| 2 | Linting — `poetry run ruff check .` | `evidence/qa-gates/final-python-ruff.2026-09-07T18-27.md` | 0 |
| 3 | Type checking — `poetry run pyright` | `evidence/qa-gates/final-python-pyright.2026-09-07T18-29.md` | 0 |
| 4 | Tests with coverage — `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json` | `evidence/qa-gates/final-python-pytest-coverage.2026-09-07T18-40.md` | 1 (C4-exempt) |

Restarts: **2**.

1. Restart after iteration 1's test step, which reported two failures. One was the C4-exempt node;
   the other,
   `tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources`,
   was a genuine regression: the plan appends every new PowerShell production file to
   `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (constraint C3), and that settings
   file has a byte-parity mirror at
   `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` that the
   plan does not name. The mirror was refreshed with the constraint C9 `Copy-Item` form and the test
   passed.
2. Restart after the PowerShell loop's iteration-3 fix changed tracked source under `.claude/lib/`
   and `tests/`. Iteration 3 of the Python loop re-ran all four steps against the final tree and
   reproduced iteration 2's values exactly.

### C4 exemption for step 4

`EXIT_CODE: 1` is accepted under constraint C4 only, and all three of its conditions hold against the
[P0-T7] record `evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md`:

1. The failing node ID set is exactly the set P0-T7 recorded — the single node
   `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
2. The run reports exactly that many failures: one.
3. The sole assertion message names a path under `.claude/state/` (`.claude/state/current-session-id`).

No other failure is exempt and none remains.

## TypeScript

| Order | Step | Artifact | EXIT_CODE |
| --- | --- | --- | --- |
| 1 | Formatting — `npm run format` | `evidence/qa-gates/final-typescript-prettier.2026-09-07T18-46.md` | 0 |
| 2 | Linting — `npm run lint` | `evidence/qa-gates/final-typescript-eslint.2026-09-07T18-48.md` | 0 |
| 3 | Type checking — `npm run typecheck` | `evidence/qa-gates/final-typescript-typecheck.2026-09-07T18-50.md` | 0 |
| 4 | Tests with coverage — `npm run test:coverage -- --coverageReporters=text` | `evidence/qa-gates/final-typescript-jest-coverage.2026-09-07T18-54.md` | 0 |

Restarts: **2**.

1. Restart at the format step of iteration 1: Prettier rewrote
   `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-core.test.ts`, wrapping one
   over-width assignment in the `describe` block [P7-T4] added. The exit code was 0 on both runs;
   the marker count (415 versus 416 `(unchanged)` lines) is what detected the rewrite.
2. Restart after the PowerShell loop's iteration-3 source change, for the same reason as Python.
   Iteration 3 re-ran all four steps and reproduced iteration 2's values exactly.

## PowerShell

| Order | Step | Artifact | EXIT_CODE |
| --- | --- | --- | --- |
| 1 | Formatting — `mcp__drm-copilot__run_poshqc_format` | `evidence/qa-gates/final-powershell-poshqc-format.2026-09-07T19-20.md` | 0 |
| 2 | Linting — `mcp__drm-copilot__run_poshqc_analyze` | `evidence/qa-gates/final-powershell-poshqc-analyze.2026-09-07T19-22.md` | 0 |
| 3 | Tests with coverage — `mcp__drm-copilot__run_poshqc_test` and `Invoke-PoshQCTest -Root` | `evidence/qa-gates/final-powershell-poshqc-test.2026-09-07T19-25.md` | 0 |

There is no type-check step for PowerShell; `.claude/rules/general-code-change.md` skips stage 3 for
this language.

Restarts: **3**.

1. The formatter rewrote `ProjectFileMerge.psm1` and `Resolve-MergeableConflict.ps1` (whitespace
   alignment inside two `[ordered]@{ ... }` literals) together with their mirrors.
2. The analyzer reported ten findings: `PSProvideCommentHelp` on two relocated helpers in
   `BlastRadiusConflict.psm1`, `PSUseOutputTypeCorrectly` on `Invoke-GitExe`, and
   `PSReviewUnusedParameter` on four unused Pester mock parameters — three unique findings, six of
   the ten being the self-hosted and mirror copies of the same two files.
3. The test step reported `Resolve-MergeableConflict.ps1` at 84.62% line coverage, below the 85
   floor. A committed invalid-UTF-8 fixture and one `It` covering the `DecoderFallbackException`
   path raised it to 86.15%.

## Ordering statement

The recorded pass of every step listed above occurred after the last source change. The last source
change of this plan was the PowerShell iteration-3 fix (the invalid-UTF-8 fixture and the `It` that
consumes it). After it, the PowerShell loop ran format, analyze, and test to a clean pass, and the
Python and TypeScript loops were each re-run in full and reproduced their recorded values; the
re-verification is appended to each of those eight artifacts under
"## Post-final-change re-verification".
