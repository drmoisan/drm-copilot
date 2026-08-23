# Reviewer toolchain rerun, remediation cycle 1 re-audit (Issue #500)

Timestamp: 2026-08-22T02-58
Issue: #500
Branch: `bug/blast-radius-bundled-config-stale-skeleton-500` @ `a95ae362`
Base: `main` @ `fb30a9a58b8422e610a09b07361421e97367807a`
Working directory: `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-16`

All eleven stages below were executed by the reviewing agent in this order, in one uninterrupted
sequence, against a clean working tree at branch head `a95ae362`. `git status --short` produced no
output immediately before stage 1 and again between stage 9 and stage 10. No stage rewrote a file
and no restart from formatting was required.

EXIT_CODE: 0

## Stages

| # | Language | Command | Result | Exit |
|---|---|---|---|---|
| 1 | Python | `poetry run black --check .` | `440 files would be left unchanged` | 0 |
| 2 | Python | `poetry run ruff check .` | `All checks passed!` | 0 |
| 3 | Python | `poetry run pyright` | `0 errors, 0 warnings, 0 informations` | 0 |
| 4 | Python | `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term --cov-report=json:artifacts/python/coverage.json --cov-report=lcov:artifacts/python/lcov.info` | `4077 passed, 5 skipped in 20.60s` | 0 |
| 5 | TypeScript | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` in `extensions/drm-copilot` | `All matched files use Prettier code style!` | 0 |
| 6 | TypeScript | `npm run lint` in `extensions/drm-copilot` | no output, no findings | 0 |
| 7 | TypeScript | `npm run typecheck` in `extensions/drm-copilot` | no output | 0 |
| 8 | TypeScript | `npm run test:coverage` in `extensions/drm-copilot` | `195 suites, 2656 tests passed` | 0 |
| 9 | PowerShell | `Invoke-PoshQCFormat -Root (Get-Location).ProviderPath` | every file reported `Already formatted`; zero rewritten | 0 |
| 10 | PowerShell | `Invoke-PoshQCAnalyze -Root (Get-Location).ProviderPath` | `PSScriptAnalyzer passed: no findings`, finding count 0 | 0 |
| 11 | PowerShell | `Invoke-PoshQCTest -Root (Get-Location).ProviderPath` | `Tests Passed: 3111, Failed: 0, Skipped: 9` | 0 |

## Coverage figures read from the regenerated artifacts

| Language | Artifact | Line / statement | Branch |
|---|---|---|---|
| Python | `artifacts/python/coverage.json`, `artifacts/python/lcov.info` | 92.60% statements, computed as (14939 - 1105) / 14939 from the TOTAL row | 85.19% from `totals.percent_branches_covered` |
| TypeScript | `extensions/drm-copilot/coverage/lcov.info` | 96.66% lines, 43071/44558 | 90.04% branches, 6122/6799 |
| PowerShell | `artifacts/pester/powershell-coverage.xml` | 96.21% lines, root LINE counter missed=228 covered=5792 | no branch counter emitted by Pester |

Per-file record for the one changed production file, read from
`extensions/drm-copilot/coverage/lcov.info`:

```
SF:src\lib\push-down\claude-blast-radius-derive-core.ts
LF:468 LH:468   -> 100.00% lines
BRF:48 BRH:46   -> 95.83% branches
```

## Scoped verifications run alongside the toolchain

| Command | Result | Exit |
|---|---|---|
| `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py` | `15 passed` | 0 |
| `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py` | `32 passed` | 0 |
| `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `10 passed` | 0 |
| `Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | `Tests Passed: 18, Failed: 0` | 0 |
| `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | no output | 0 |
| `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json` | `orchestrator-state validation passed` | 0 |

## Mutation probes, each restored immediately with a clean tree afterward

| Probe | Observed | Exit |
|---|---|---|
| Bundled `blast-radius.json` reverted to the merge-base version, then the parity pytest module | 8 failed, 7 passed; the failures include `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle`, both regression cases, `test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]`, both Class 2 cases, Class 3, the umbrella denylist on the bundled copy, and the separator-free wildcard case | 1 |
| `Directory.Build.props` appended to the self-hosted `shared_surfaces`, then the same pytest selection | 1 failed, 14 passed; only `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle` fails, with `assert not ['Directory.Build.props']` | 1 |
| The same injection, then `Invoke-Pester` on `BlastRadius.TruthTable.Tests.ps1` | Tests Passed: 17, Failed: 1; the failing case is `requires every separator-free self-hosted shared surface to reach the bundled copy`, reporting `Expected $null or empty, but got 'Directory.Build.props'` | 1 |
| Four self-hosted-only additions at once, namely `config/new-portable-surface.json` in `shared_surfaces`, `config/newfam_*.json` in `shared_surface_globs`, a `newsub` module, and a `new_top_level_key` top-level key, then both pytest modules | 50 passed, no case fires | 0 |

The fourth probe is the residual drift direction recorded as finding CR-2 in the code review.

## Independent reproduction of the recorded headline measurement

A reviewer-authored throwaway script re-derived the conflict graph over the 56 folders under
`docs/features/active/` carrying a `plan*.md`, passing each folder's `plan*.md` content as
`plan_text`, each folder's `spec.md` content as `spec_text`, the bare folder name as
`feature_folder`, the parsed truth table as `config`, and a fixed `computed_at` constant, then
`conflicts()` over all C(n,2) pairs and a greedy lowest-index colouring. The script was created in
the session scratchpad and reads committed files only.

| Configuration | Items | Pairs | Edges | Density | Cohorts | Max width | Exit |
|---|---|---|---|---|---|---|---|
| Post-change, `config/blast-radius.json` at head | 56 | 1540 | 1182 | 76.8% | 31 | 5 | 0 |
| Pre-change, `git show fb30a9a5:config/blast-radius.json` | 56 | 1540 | 1199 | 77.9% | 33 | 5 | 0 |

Both rows match `evidence/other/post-fix-conflict-graph.2026-08-22T00-20.md` exactly, which
discharges remediation item R5: the corrected command description now reproduces its own figures.

## Byte-identity checks

| Pair | Result | Exit |
|---|---|---|
| `.claude/rules/parallel-orchestration.md` against `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` | `cmp` produced no output; SHA256 `59e7693cdc3dbe7a45e972f8a1f231a09974d5d854fd2013a6221475354b21c9` on both | 0 |
| `config/orchestration-routing.json` against `extensions/drm-copilot/resources/config/orchestration-routing.json` | `cmp` produced no output | 0 |
| `config/orchestration-routing.json` against `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` | `cmp` produced no output; SHA256 `D9C6657CBDBE15413E0FB9BC1BE700CE1A8F892D0DB413C3BBC253EA24EA7BDA` on both, matching the recorded figure | 0 |

## Post-fix contention behaviour, both directions, verified directly against the published table

```
root surfaces        : package-lock.json, poetry.lock, quality-tiers.yml
m paths              : docs/features/active/2026-08-21-item-m/**, package-lock.json
conflict             : True
  path_overlap : package-lock.json ~ package-lock.json
  shared_surface_overlap : package-lock.json
fail-closed conflict : False
```

The final line is the fail-closed pair, a hook citation against a skill-document citation, reporting
`False`. The block above it is the fail-open pair, two items citing `package-lock.json`, reporting
`True` with both reasons.

## ConvertTo-Json comparison-form probe, remediation item R6

```
PIPELINE  singleList -> ["x"]   scalar -> ["x"]  equal=True
INPUTOBJ  singleList -> [["x"]] scalar -> "x"    equal=False
PIPELINE  emptyList  -> <no output>  absent -> null  equal=False
INPUTOBJ  emptyList  -> []      absent -> null   equal=False
```

The pipeline form conflated a single-element list with a bare scalar; the `-InputObject` form does
not. The empty-list against absent-key case was already distinguished under the pipeline form, so
only the first half of the recorded R6 rationale held. The correction is sound in either reading.
