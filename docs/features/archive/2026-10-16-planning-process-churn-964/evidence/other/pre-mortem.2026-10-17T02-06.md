# Pre-Mortem Before Review — Issue #964 (directive D4)

Timestamp: 2026-10-17T02-06
Task: [P6-T12] (orchestrator directive D4)
Command: one verification per item, listed in the table (all run on the merged tree after `origin/main` was merged)
EXIT_CODE: 0
Output Summary:
- 17 failure modes for the next feature review and the first CI run were checked locally; every item passes. Failures found while preparing this pre-mortem were fixed before it was written: a skill-bundle contract failure, an unformatted test file, a Jest order dependence, an unreachable executor-hook branch, an uncovered new hook line, an over-limit test file, and a stale CI fact in the brief (see `## Failures Found and Fixed`).

## Verification Table

| # | Failure mode | Verification command | Result |
|---|---|---|---|
| 1 | Policy-audit, code-review, or feature-audit template item not satisfied | Template walk in `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` ([P6-T12]) | PASS: no FAIL row (see that artifact) |
| 2 | Acceptance criterion unmet or unchecked | `sh SCRATCH/issue-964-ac.sh` check-off log; spec checkbox count | PASS: AC-1 to AC-31 verified and checked; AC-32 checked with the self-review; AC-33 and AC-34 are orchestrator-owned |
| 3 | Per-file Python coverage below 85% line or 75% branch | `sh SCRATCH/issue-964-pytest.sh` (JSON report) | PASS: `plan_gate_document.py` 100/100; `plan_gate_discrimination.py` 99.26/98.08; `generate_codex_agent_variants.py` 94.53/89.13; `codex_native_converter/rewrites.py` 91.30/85.71 |
| 4 | Per-file TypeScript coverage below 85% line or 75% branch | Jest `--coverage` json-summary | PASS: `plan-gate-document.ts` 100/95.08; `plan-gate-discrimination.ts` 100/98.27; `rewrites-rules.ts` 100/100 |
| 5 | Per-file PowerShell line coverage below 85% | Final single-process Pester run, `artifacts/pester/powershell-coverage.xml` | PASS: `premortem-section.ps1` 100; `validate-planner-output.ps1` 99.52; `validate-task-researcher-output.ps1` 98.17; `validate-executor-output.ps1` 100 |
| 6 | A bundled mirror or `.codex`/`.agents`/`.github` copy differs | `sh SCRATCH/issue-964-mirror-copy.sh` (byte compare); generator `--check`; contract set | PASS: `COPIED=36 MISMATCH=0`; generator exit 0; resource-contract, pack-manifest, handoff-parity, brief byte-identity tests pass |
| 7 | A non-Markdown file above 500 lines | `poetry run python SCRATCH/issue-964-scope.py` (`NON_MD_OVER_500`) | PASS: 0; highest are `repo-automation-dispatch.test.ts` 500 and `extension-test-harness.ts` 495 |
| 8 | Test order dependence | Seeded Jest (3 seeds), Python reversed run, seeded shuffled Pester (3 seeds), single-process Pester | PASS on the merged tree: 4103/4103 per Jest seed; 88/88 reversed; 897/897 per Pester seed; 11055 tests, 0 failures |
| 9 | Linux hook-suite job (`poshqc / PowerShell hook suites (Linux)`) fails on paths | Static scan of the new and modified `tests/scripts/claude-hooks` suites for drive letters, backslash literals, and CR; `git ls-files --eol` | PASS: no match; `i/lf w/lf`; every path uses `Join-Path` with forward slashes, exact file-name case, and `$HOME` with `/` |
| 10 | A new test file is not run by any PoshQC shard | `Get-PoshQCShardSlice` over `tests/scripts` with 3 shards | PASS: 396 files sliced, 396 unique; each of the four new suites is in exactly one shard |
| 11 | `poshqc / PowerShell QC static` reformats or flags a file | Whole-repo `Invoke-PoshQCFormat` with porcelain before and after; whole-repo `Invoke-PoshQCAnalyze` | PASS: format rewrote nothing; "PSScriptAnalyzer passed: no findings" |
| 12 | `quality-checks7` fails (Black, Ruff, Pyright, generator check, tier check, coverage floors) | `black --check .`, `ruff check`, `pyright`, generator `--check`, `check_quality_tiers`, JSON totals | PASS: 620 files unchanged; 0 findings; 0 errors; exit 0; "quality-tiers: OK"; totals 94.11 line / 88.78 branch (floors 85/75) |
| 13 | Extension or root TypeScript jobs fail | `tsc` source and test projects, ESLint, Prettier, full Jest; root package untouched | PASS: 0 diagnostics; 0 problems; formatted; 281 suites pass. No file under the root TypeScript project changed (N/A for `root-typescript-tests`) |
| 14 | `merge_group`, skipped checks, or required-check names break the gate | `.github/workflows/ci.yml` read after the merge; ruleset 15241672 contexts as confirmed by the orchestrator | PASS: `merge_group` is a trigger on the merged tree; no job was renamed or made conditional by this item; the eleven required contexts are unchanged and named in the brief |
| 15 | `docs-validation / Documentation Validation` fails | `.github/workflows/_docs-validation.yml` rules: `README.md` present and non-empty, `LICENSE` present | PASS: neither file is touched; both exist |
| 16 | Evidence artifact missing a required field or carrying host data | `poetry run python SCRATCH/issue-964-evidence-check.py FEATURE/evidence` | PASS: 54 artifacts, 0 problems |
| 17 | Plan fails its own new rules or the branch-current validator | `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`; G11 to G13 on the plan | PASS: "plan validation passed"; 0 findings |

## Failures Found and Fixed

1. `test_every_skill_script_reference_is_bundled` failed: the brief and the contract copies wrote the plan validator and the Codex generator in `python -m` invocation form, which a pushed skill cannot carry. Rewritten as citations; mirrors re-copied.
2. `tests/scripts/dev_tools/test_plan_gate_document_docs.py` had not been formatted; Black applied.
3. The seeded Jest run exposed an order dependence in `extensions/drm-copilot/test/extension.test.ts`; fixed on the leaker and victim sides (`jest-seeded.2026-10-17T01-21.md`).
4. `Test-HasCanonicalBlockedText` could never return `$false`, because the canonical phrase itself carries `[P0-T1]`; the phrase is now excluded before the plan-delta check, with a test.
5. The new `Test-PreflightFixRecord` body was uncovered because every test mocked it; a direct case was added (executor hook now 100% line coverage).
6. `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` reached 502 lines after the isolation fix; reduced to 500 by removing a comment and the now-unused registry-resetting helper.
7. PR #965 (issue #952) merged into `main` and added the `merge_group` trigger; `origin/main` was merged into this branch without conflicts and the brief's CI section was refreshed.
