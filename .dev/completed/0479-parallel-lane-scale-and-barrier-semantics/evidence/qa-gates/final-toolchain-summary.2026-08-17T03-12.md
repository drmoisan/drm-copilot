# Seven-Stage Toolchain Discharge (Issue #479, [P7-T14], AC41)

Timestamp: 2026-08-17T03-12

EXIT_CODE: 0

All paths below are relative to
`docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/`.

## Stage-to-evidence mapping

| Stage | Language | Command | Evidence | Result |
|---|---|---|---|---|
| 1. Formatting | Python | `poetry run black .` | `evidence/qa-gates/final-python-format.2026-08-17T02-45.md` | exit 0, `419 files left unchanged` |
| 1. Formatting | TypeScript | `npm run format` | `evidence/qa-gates/final-ts-format.2026-08-17T02-50.md` | exit 0, zero files modified |
| 1. Formatting | bash | `shfmt -d` (first stage of `shell-qc check`) | `evidence/qa-gates/final-shell-qc.2026-08-17T03-05.md` | step green in run 31998496925 |
| 1. Formatting | PowerShell | `mcp__drm-copilot__run_poshqc_format` | `evidence/qa-gates/final-powershell-format.2026-08-17T02-55.md` | exit 0, zero `.ps1` modifications |
| 2. Linting | Python | `poetry run ruff check .` | `evidence/qa-gates/final-python-lint.2026-08-17T02-45.md` | exit 0, `All checks passed!` |
| 2. Linting | TypeScript | `npm run lint` | `evidence/qa-gates/final-ts-lint.2026-08-17T02-51.md` | exit 0, zero findings |
| 2. Linting | bash | `shellcheck` (second stage of `shell-qc check`) | `evidence/qa-gates/final-shell-qc.2026-08-17T03-05.md` | step green |
| 2. Linting | PowerShell | `mcp__drm-copilot__run_poshqc_analyze` | `evidence/qa-gates/final-powershell-analyze.2026-08-17T02-56.md` | exit 0, zero errors |
| 3. Type checking | Python | `poetry run pyright` | `evidence/qa-gates/final-python-typecheck.2026-08-17T02-46.md` | exit 0, `0 errors, 0 warnings, 0 informations` |
| 3. Type checking | TypeScript | `npm run typecheck` (`tsc --noEmit`) | `evidence/qa-gates/final-ts-typecheck.2026-08-17T02-51.md` | exit 0, zero diagnostics |
| 3. Type checking | bash | `N/A — bash has no type-check stage` (`.claude/rules/shell.md` step 3) | — | N/A |
| 3. Type checking | PowerShell | `N/A — not applicable for PowerShell` (`powershell-code-change.instructions.md` step 3) | — | N/A |
| 4. Architecture boundary | all | `N/A — no configured stage` | see note below | N/A |
| 5. Unit tests | Python | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | `evidence/qa-gates/final-python-test.2026-08-17T02-47.md` | 3887 passed, 5 skipped, 1 pre-existing environmental failure |
| 5. Unit tests | TypeScript | `npm run test:coverage` | `evidence/qa-gates/final-ts-test.2026-08-17T02-52.md` | 2555 passed, 185 suites |
| 5. Unit tests | bash | `shell-qc test --coverage` (bats) | `evidence/qa-gates/final-shell-qc.2026-08-17T03-05.md` | 251 ok, zero not ok |
| 5. Unit tests | PowerShell | `mcp__drm-copilot__run_poshqc_test` (Pester) | `evidence/qa-gates/final-powershell-test.2026-08-17T02-57.md` | 2740 tests, 0 failures, 0 errors |
| 6. Contract / schema | Python lane | shared manifest parity corpus + surface-contract suites | `evidence/qa-gates/p3-pytest.2026-08-17T02-00.md`, `p1-pytest.2026-08-17T00-45.md`, `p4-pytest.2026-08-17T02-15.md` | `test_parallel_manifest_bash_parity.py` 104 passed; orchestrator surface 36 passed; planner surface 23 passed |
| 6. Contract / schema | bash lane | `tests/shell/parallel_manifest_parity.bats` | `evidence/qa-gates/final-shell-qc.2026-08-17T03-05.md` | `ok 87` corpus floor, `ok 89` bash lane reproduces every manifest corpus fixture |
| 7. Integration | bash | bats suites in run 31998496925 | `evidence/qa-gates/final-shell-qc.2026-08-17T03-05.md` | 251 ok |
| 7. Integration | Python | 13-lane transpose tests | `evidence/qa-gates/p3-lane-assertion-coverage.2026-08-17T01-30.md` | `test_the_thirteen_lane_transpose_yields_thirteen_components`, `test_the_transpose_assertion_is_confirmed_with_no_disagreement` |

## Architecture-boundary stage: `N/A — no configured stage`

`.claude/rules/architecture-boundaries.md` names `dependency-cruiser` (TypeScript, configured
by `.dependency-cruiser.cjs`) and `NetArchTest.Rules` (.NET) as the enforcement tools. No .NET
project exists in this repository, and no architecture-boundary runner is wired into any
package script or CI workflow that this feature's languages could invoke. This feature's
TypeScript change is a one-line constant in each of two existing files under
`src/lib/validate/`; it adds no import, no module, and no layer crossing. The stage is
therefore recorded as `N/A — no configured stage`, as the plan's Phase 7 preamble authorizes.

## Single clean pass per language on the final iteration

| Language | Loop restarts during the feature | Final iteration |
|---|---|---|
| Python | Several during authoring, plus one inside Phase 7 (the `[P7-T4]` coverage restoration on `parallel_manifest_contract.py`) | format -> lint -> type-check -> test all passed in ONE pass with zero file modifications |
| TypeScript | One during Phase 2 authoring | format -> lint -> type-check -> test all passed in ONE pass with zero file modifications |
| bash | None | check (shfmt + shellcheck) -> test all green in ONE CI run at the branch head |
| PowerShell | None | format -> analyze -> test all passed in ONE pass with zero `.ps1` modifications |

## Single acknowledged non-green item

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
fails in this working copy and only in this working copy. It is:

- **Pre-existing** — reproduced at the untouched baseline commit `a43deb73` with a clean
  tracked tree, before any change (`evidence/baseline/python-test-baseline.2026-08-16T23-55.md`).
- **Environmental** — caused by a live gitignored `git worktree` at
  `.claude/worktrees/agent-afc9f4fd25ec235a5/` (branch
  `feature/enforcement-hooks-must-not-invoke-python-475`) whose agent log files fall inside the
  `.claude` tree the test enumerates with `rglob`. The directory does not exist in CI.
- **Not masking anything** — the assertion iterates sorted paths, and `.claude/worktrees/...`
  sorts after every real payload path, so all 161 tracked `.claude` files passed both the
  presence and the byte-identity assertions before the loop reached it. Mirror parity was
  additionally verified by direct per-pair byte comparison at every phase: zero missing, zero
  differing.
- **Not weakened** — no assertion, threshold, or exclusion was changed to accommodate it.
