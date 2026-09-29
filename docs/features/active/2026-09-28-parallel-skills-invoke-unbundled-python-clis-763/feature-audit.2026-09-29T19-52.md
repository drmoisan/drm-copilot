# Feature Audit: parallel-skills-invoke-unbundled-python-clis (#763)

- Timestamp: 2026-09-29T19-52
- Branch: `bug/parallel-skills-invoke-unbundled-python-clis-exec-763`
- Head: `416327768ff7cefe83c7f22bdfbad84971ddc90b`

## Scope and Baseline

- Base branch: `origin/epic/push-down-payload-correctness-integration`; merge-base `12db46245ba7683b5d6ccb676312a4b22a39b0ce`. The spec's AC8, AC11, and AC17 name `git diff main`; the plan (DV2) anchors those diffs to the integration merge-base so sibling-feature commits are not attributed to this item. This audit uses the same anchor, which is the review base supplied by the caller.
- Work mode: `full-bug` (from `issue.md` line 12). AC source: `spec.md` `## Acceptance Criteria` only; no `user-story.md` applies.
- Scope source: `git diff --name-only` and `git log` over the review range (PR-context artifacts are absent in this worktree and the collector tool is not exposed to this session).
- Baseline evidence: `evidence/baseline/*.2026-09-29T17-39.md` (P0), including the pre-existing failure set (`enforce-pr-author-skill.Tests.ps1` one case; KL-510 state-only).
- Reviewer verification performed at HEAD: targeted pytest run (227 passed, 1 KL-510), Black/Ruff/Pyright check-only, evidence-location validator, AC9 `rg` sweep, bundle byte-identity `cmp`, hook token and heading-count checks, JaCoCo and JUnit parse of `artifacts/pester/*`, lcov parse of `artifacts/python/lcov.info`, and download and parse of the CI `shell-coverage` artifact of run 36645685724.

## Acceptance Criteria Inventory

| ID | Criterion (abbreviated) | Initial state |
|---|---|---|
| AC1 | Drift module and entry script exist, <= 500 lines, reuse blast-radius; unit and no-Python suites pass | checked |
| AC2 | Drift corpus covers every listed case; Python and Pester parity lanes pass and fail on an empty corpus | checked |
| AC3 | Entry-script suite asserts no Mandatory, exit codes, JSON shape, timestamp round-trip, arrays, clock defaults, no writes | checked |
| AC4 | Abandon script exists; `parallel_abandon.bats` passes with shims and asserts refusals, ordering, failures, -1, usage errors | checked |
| AC5 | Abandon corpus covers every case; Python and bats parity lanes pass and fail on an empty corpus | checked |
| AC6 | Payload-only bats case runs the bundle copy with a shim-only PATH and no interpreter | checked |
| AC7 | Token seam test anchored on `abandon-parallel-item.sh` binds bash, Python, hook, and SKILL | checked |
| AC8 | Abandon-gate Pester suites pass; hook diff is comment-only; token lines unchanged | checked |
| AC9 | SKILL invocations use the new entry points; `rg` sweep for Python CLI invocations returns no match | checked |
| AC10 | Surface-contracts test passes; `##` heading count unchanged | checked |
| AC11 | Agent allowlist has both entry points; `poetry run python -m` grant unchanged | checked |
| AC12 | `core.json` lists the new files; bundle copies byte-identical; four contract suites pass | checked |
| AC13 | `KNOWN_UNBUNDLED_REFERENCES` empty; evaluation, repo, and CLI guard tests pass; stale branch still executed | checked |
| AC14 | Both runsettings list the new PowerShell files; each new file >= 85% line | checked |
| AC15 | kcov >= 85% for the abandon script; Python changed lines not regressed, >= 85% line and >= 75% branch | checked |
| AC16 | Python CLIs and modules remain; their four test modules pass | checked |
| AC17 | Constrained files absent from the diff; no test creates a temporary file | checked |
| AC18 | Full toolchain passes in a single pass for every changed language | checked |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC1 | PASS | `ParallelDrift.psm1` 467 lines, `Invoke-ParallelDriftDetection.ps1` 336 lines (reviewer `wc -l`). Lines 32-35 import `BlastRadius.psm1`, `BlastRadiusGlob.psm1`, `BlastRadiusValidation.psm1`; calls at lines 194, 310, 314-315, 338. `ParallelDrift.Tests.ps1` 26/26 and `enforcement-hooks-no-python-invocation.Tests.ps1` 27/27 passed (`artifacts/pester/pester-junit.xml`). The third file `ParallelDriftHalt.psm1` (388 lines) is a declared split (DV1) and does not affect this criterion. |
| AC2 | PASS | 18 fixtures in `tests/fixtures/parallel_drift/` named for every listed case (reviewer listing). Both lanes assert a floor of 18 and the required-name set. `test_parallel_drift_parity.py` passed in the reviewer run; `ParallelDrift.Parity.Tests.ps1` 20/20 passed. Parity compares parsed JSON values and the stderr prefix for error fixtures. |
| AC3 | PASS | `Invoke-ParallelDriftDetection.Tests.ps1` 21/21 passed. Reviewer read confirms each listed assertion: AST scan for `Mandatory` (line 48), missing/non-integer `-ItemKey` exit 2 (lines 88-101), data error exit 1 with prefix (110-127), single JSON object (129-137), one-element arrays (139-154), ISO timestamp round-trip via `System.Text.Json` (156-175), mocked clock default and `ComputedAt` default (191-206), file hashes unchanged (266-283). |
| AC4 | PASS | `.claude/lib/bash/abandon-parallel-item.sh` exists (176 lines). `tests/shell/parallel_abandon.bats` (14 tests) asserts each listed behavior using `tests/fixtures/parallel_abandon_path{,_git_only}` shims; CI run 36645685724 reports 498 ok, 0 not ok (`evidence/qa-gates/shell-coverage-ci.2026-09-29T19-13.md`); local run 34/34 ok. |
| AC5 | PASS | 9 fixtures in `tests/fixtures/parallel_abandon/` covering every listed case. `test_parallel_abandon_bash_parity.py` passed (reviewer run) and `parallel_abandon_parity.bats` 3/3 ok in CI. Both lanes assert exit code, stderr line (or usage class), and ordered argv, with a floor of 9. |
| AC6 | PASS | `parallel_payload_only.bats` adds three tests; the abandon case runs `${PAYLOAD_LIB}/abandon-parallel-item.sh` under `env -i PATH=tests/fixtures/parallel_abandon_path` and a companion test asserts `python`, `python3`, and `poetry` are not resolvable. CI: tests 168-170 ok. |
| AC7 | PASS | `test_parallel_abandon_token_seam.py`: `INVOCATION_ANCHOR = "abandon-parallel-item.sh"`, `bash_token_pair()` reads the three `readonly` lines, `test_bash_token_pair_equals_the_cli_pair`, `test_bash_token_pair_equals_the_hook_pair`, `test_all_four_extractions_agree`; `skill_invocation_line()` asserts exactly one option-bearing anchor line. All passed in the reviewer run. |
| AC8 | PASS | `enforce-parallel-abandon-gate.Tests.ps1` 24/24 and `TriggerScoping.Tests.ps1` 7/7 passed. Reviewer diff against the merge-base shows changes only in the `.NOTES` comment (lines 27-31); lines 41-42 hold the unchanged assignments and each literal appears exactly once (reviewer `grep -c`). |
| AC9 | PASS | `parallel-orchestrate/SKILL.md` line 886 invokes `pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1`; `parallel-remove/SKILL.md` step 5 invokes the exact `bash .claude/lib/bash/abandon-parallel-item.sh --item <key> --disposition abandon --confirm-abandon --pr <pr-number> --worktree <worktree-path>` line. Reviewer `rg` sweep over `.claude` and the bundle `.claude` returned no match (exit 1). |
| AC10 | PASS | `test_parallel_orchestrator_surface_contracts.py` passed in the reviewer run. `^## ` count is 16 at both the merge-base and HEAD (reviewer grep). |
| AC11 | PASS | Frontmatter lines 21 and 23 add `Bash(bash .claude/lib/bash/abandon-parallel-item.sh*)` and `Bash(pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1*)`; line 17 `Bash(poetry run python -m *)` is unchanged (diff shows only additions in the tool list). |
| AC12 | PASS | `core.json` lists all four new files (diff). `cmp` of 8 new or edited `.claude/**` files against bundle copies: identical. `ParallelDrift.Manifest.Tests.ps1` 5/5, `parallel_bash_manifest_membership.bats` ok (CI test 23), Jest push-down 262/262 including `claude-pack-manifest-completeness.test.ts`. `test_push_down_claude_resource_contracts.py` passes except the KL-510 node, which fails only on the gitignored `.claude/state/powershell-batch-budget.*.json` file and is in the declared pre-existing failure set; no "Bundle content differs" line was produced. |
| AC13 | PASS | `KNOWN_UNBUNDLED_REFERENCES: tuple[...] = ()` (diff). `test_known_unbundled_references_registry_is_empty`, `test_skill_bundle_contract_repo.py` (including `test_every_skill_script_reference_is_bundled` and `test_known_unbundled_references_are_not_stale`), and `test_skill_bundle_contract_cli.py` (including `test_main_returns_one_for_stale_exception`) passed in the reviewer run. The stale branch is executed through the injected `exceptions` registry. |
| AC14 | PASS | Both runsettings files register the three files and are byte-identical; `test_poshqc_bundled_parity.py` passed (reviewer run). JaCoCo (reviewer parse): ParallelDriftHalt.psm1 100.00%, ParallelDrift.psm1 100.00%, Invoke-ParallelDriftDetection.ps1 94.79%. |
| AC15 | PASS | CI `cov.xml` (reviewer download): `abandon-parallel-item.sh` line-rate 0.946. `artifacts/python/lcov.info`: skill_bundle_contract.py 96.45% line / 95.00% branch; skill_bundle_contract_cli.py 93.10% line / 77.27% branch; baseline 96.45/95.00 and 92.98/77.27; changed executable lines 2 of 2 covered. |
| AC16 | PASS | Both CLIs and their modules remain (not in the diff as deletions). `test_parallel_drift_detection_cli.py`, `test_parallel_drift_detection_cli_halt.py`, `test_parallel_mutation_abandon_cli.py`, and `test_parallel_mutation_protocol.py` passed in the reviewer run. |
| AC17 | PASS | Reviewer `git diff --name-only` over the review range lists none of the five constrained paths. Reviewer grep for temporary-file APIs over all changed tests: 0 matches. |
| AC18 | PASS | PowerShell: format 0 changed, PSSA 0 diagnostics, Pester pass except the baseline case. Bash: shfmt and shellcheck exit 0, bats 498/498 in CI. Python: Black, Ruff, Pyright clean (reviewer re-run), pytest 5287 passed with only KL-510 failing. Jest push-down 262/262. The last code change (`0e41ad84`, SKILL prose) was followed by reruns of every suite that reads it; later commits change only feature-folder documents. The two remaining failures are the declared pre-existing set. |

## Summary

All 18 acceptance criteria are satisfied by the code on the branch and by evidence that the reviewer re-verified at HEAD where check-only commands were available (Python toolchain and tests, sweeps, byte identity, coverage artifacts). PowerShell format, analyze, and test results and bash format and lint results are taken from executor evidence and the committed artifacts because this agent session cannot start `pwsh` or `bash` directly; the Pester JUnit and JaCoCo artifacts and the CI kcov artifact were parsed independently.

Non-blocking observations relevant to feature completeness (details in the policy audit section 8 and the code review):

- `/parallel-remove` steps 2, 3, and 6 still reference `scripts/dev_tools/parallel_mutation_protocol.py` (spec D7 follow-up), so that skill is not yet fully Python-free in consumers.
- The skill-bundle guard regex defect (FU-763-5) is worked around, not fixed.
- The PowerShell artifact-total coverage figure (70.21%) reflects a subset run and is pre-existing.

Verdict: all acceptance criteria PASS; no blocking finding; ready to merge.

## Acceptance Criteria Check-off

- All 18 items in `spec.md` `## Acceptance Criteria` were already checked (`- [x]`) by the executor (commit `41632776`).
- Each item was evaluated as PASS above, so every checkbox is left checked. No item was unchecked and no item was newly checked by this review. `spec.md` was not modified.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/spec.md`
- Total AC items: 18
- Checked off (delivered): 18
- Remaining (unchecked): 0
- Items remaining: none
