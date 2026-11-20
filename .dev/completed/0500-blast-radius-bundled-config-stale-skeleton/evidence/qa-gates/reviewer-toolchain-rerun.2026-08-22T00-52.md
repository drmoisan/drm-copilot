# Reviewer independent toolchain and coverage rerun (Issue #500)

Timestamp: 2026-08-22T00:52:49Z
Issue: #500
Produced by: feature-review
Scope: full branch diff `fb30a9a58b8422e610a09b07361421e97367807a..59425465740957cd35fdae599146f81ed707f1a5`

EXIT_CODE: 0

Output Summary: every runnable toolchain stage in all three coverage languages passed in one
uninterrupted sequence with no restart and no file rewritten. Coverage figures reproduce the
executor's recorded figures exactly in all three languages. `git status --short` produced no output
before the sequence and after every stage.

## Stage results

| # | Language | Stage | Command | Exit | Observed output |
| --- | --- | --- | --- | --- | --- |
| 1 | Python | Format | `poetry run black --check .` | 0 | `440 files would be left unchanged.` |
| 2 | Python | Lint | `poetry run ruff check .` | 0 | `All checks passed!` |
| 3 | Python | Type check | `poetry run pyright` | 0 | `0 errors, 0 warnings, 0 informations` |
| 4 | Python | Test + coverage | `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json` | 0 | `4076 passed, 5 skipped in 28.49s`; TOTAL row `14939 1105 5488 559 91%` |
| 5 | TypeScript | Format | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | 0 | `All matched files use Prettier code style!` |
| 6 | TypeScript | Lint | `npm run lint` | 0 | no diagnostics |
| 7 | TypeScript | Type check | `npm run typecheck` | 0 | no diagnostics |
| 8 | TypeScript | Test + coverage | `npm run test:coverage` | 0 | 195 suites, 2656 tests; `Statements 96.66% (43071/44558)`, `Branches 90.04% (6122/6799)` |
| 9 | PowerShell | Format | `Invoke-PoshQCFormat -Root <worktree>` | 0 | 382 files already formatted, 0 rewritten |
| 10 | PowerShell | Lint | `Invoke-PoshQCAnalyze -Root <worktree>` | 0 | `PSScriptAnalyzer passed: no findings` |
| 11 | PowerShell | Test + coverage | `Invoke-PoshQCTest -Root <worktree>` | 0 | `Tests Passed: 3110, Failed: 0, Skipped: 9`; `Covered 96.05% ... 8,449 analyzed Commands in 70 Files` |

Stages 5 through 8 ran with working directory `extensions/drm-copilot`. All other stages ran from
the worktree root.

## Coverage figures, reviewer-observed

| Language | Line / statement | Threshold | Branch | Threshold | Source | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| Python | 92.6032532298012% | >= 85% | 85.18586005830903% | >= 75% | `artifacts/python/coverage.json` `totals.percent_statements_covered` and `totals.percent_branches_covered` | PASS |
| TypeScript | 96.66% | >= 85% | 90.04% | >= 75% | Jest text-summary reporter over `extensions/drm-copilot` | PASS |
| PowerShell | 96.21% | >= 85% | no figure exists | not applicable | `artifacts/pester/powershell-coverage.xml` root `<counter type="LINE" missed="228" covered="5792"/>` | PASS |

The PowerShell coverage XML emits `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS` counters and no
`BRANCH` counter, so no branch percentage exists to evaluate. Per `.claude/rules/powershell.md` the
absent figure is not a failure.

## Changed-file coverage

| File | Kind | Line coverage | Branch coverage |
| --- | --- | --- | --- |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | the only changed production file | `LF:468 LH:468` = 100.00% | `BRF:48 BRH:46` = 95.83% |
| `tests/scripts/dev_tools/test_blast_radius_config_parity.py` | new test module | outside the denominator | not applicable |
| `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | new test-support module | outside the denominator | not applicable |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | test file | outside the denominator | not applicable |
| four files under `extensions/drm-copilot/test/lib/push-down/` | test and test-helper files | outside the denominator | not applicable |

Zero Python production lines and zero PowerShell production lines were changed, so the
no-regression-on-changed-lines requirement is satisfied trivially for those two languages and by the
100.00% line figure for the one changed TypeScript production module.

The Python coverage denominator is `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`. The
only tracked non-test Python file outside that source is `scripts/__init__.py`, a namespace marker,
so the denominator is effectively repo-wide. No `omit` or `exclude` entry was added by the branch.

## Fail-before reproductions performed by the reviewer

Each probe reverted exactly one committed file, ran the named selection, and restored the file.
`git status --short` produced no output after every restore.

| Probe | Mutation | Selection | Exit | Result |
| --- | --- | --- | --- | --- |
| Python fail-closed and fail-open | bundled `blast-radius.json` reverted to `fb30a9a5` | the two regression node IDs | 1 | both FAILED with the assertion messages recorded in `evidence/regression-testing/python-regression-fail-before.2026-08-21T23-08.md` |
| PowerShell mirror | bundled `blast-radius.json` reverted to `fb30a9a5` | `BlastRadius.TruthTable.Tests.ps1` | 1 | 13 passed, 4 failed: the umbrella-denylist, payload-subset, separator-free, and Class 1 equality cases |
| Class 1 drift | `.claude/skills/new-mandate/SKILL.md` appended to the self-hosted `mandate_reads` | parity module | 1 | `test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]` FAILED |
| Class 2 drift | `Directory.Build.props` appended to the self-hosted `shared_surfaces` | parity module plus `test_blast_radius_config.py` | 0 | 48 passed — the gate does NOT detect a self-hosted-side portable addition |

## Headline measurement reproduction

Command shape: derive a radius for every folder under `docs/features/active/` carrying a `plan*.md`,
supplying that folder's `spec.md` as the `spec_text` argument, then evaluate `conflicts` over all
`C(n,2)` pairs, against each configuration in turn.

| Configuration | Items | Pairs | Edges | Density |
| --- | --- | --- | --- | --- |
| pre-change, `fb30a9a5:config/blast-radius.json` | 56 | 1540 | 1199 | 77.86% |
| post-change, working tree | 56 | 1540 | 1182 | 76.75% |

These reproduce the commit message and
`evidence/other/post-fix-conflict-graph.2026-08-22T00-20.md` exactly. Omitting `spec_text` yields
1199 -> 954 over the same item set; the recorded evidence command description does not state that
`spec.md` was supplied, which is recorded as reviewer finding CR-4.

## Validator gates

| Gate | Command | Exit |
| --- | --- | --- |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | 0 |
| Plan artifact | `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/plan.2026-08-21T22-05.md` | 0 |
| Orchestrator state | `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json` | 0 |
| Mirror byte-identity, rules file | `diff` of the two `parallel-orchestration.md` copies | 0 |
| Mirror byte-identity, routing file | `diff` of both `orchestration-routing.json` pairs | 0 |

## Stage that could not be executed

The architecture-boundary stage named by `.claude/rules/general-code-change.md` step 4 and by
`.claude/rules/typescript.md` requires `dependency-cruiser` with a `.dependency-cruiser.cjs`
configuration file. `git ls-files | grep -i dependency-cruiser` returns one documentation artifact
recording the tool's absence and no configuration file or npm script. The stage is therefore not
runnable. The condition is present at the merge base and is not attributable to this branch.
