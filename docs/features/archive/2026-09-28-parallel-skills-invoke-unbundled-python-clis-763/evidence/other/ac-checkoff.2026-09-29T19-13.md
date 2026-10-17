# Acceptance-Criteria Check-Off (P12-T1 through P12-T19)

Timestamp: 2026-09-29T19-13
Source: docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/spec.md (work mode full-bug; spec.md is the sole AC source)

Each AC was checked off individually (only `- [ ]` changed to `- [x]`) after confirming that every
cited artifact exists with passing acceptance. Paths are relative to FEATURE/evidence/.

- P12-T1, AC1: regression-testing/drift-modules-after.2026-09-29T18-00.md (P3-T14),
  regression-testing/drift-entry-after.2026-09-29T18-00.md (P3-T20),
  qa-gates/drift-line-counts.2026-09-29T18-00.md (P3-T22),
  qa-gates/ac1-ac8-pester.2026-09-29T18-44.md (P6-T5), qa-gates/powershell-test-coverage.2026-09-29T18-44.md (P8-T5).
- P12-T2, AC2: other/drift-corpus-generation.2026-09-29T18-00.md (P3-T3),
  regression-testing/drift-python-lane.2026-09-29T18-00.md (P3-T6; both floor tests PASSED),
  regression-testing/drift-entry-after.2026-09-29T18-00.md (P3-T20; Pester floor test PASSED).
- P12-T3, AC3: regression-testing/drift-entry-before.2026-09-29T18-00.md (P3-T18, fail-before),
  regression-testing/drift-entry-after.2026-09-29T18-00.md (P3-T20; every B19 It name PASSED),
  regression-testing/drift-process-smoke.2026-09-29T18-00.md (P3-T21).
- P12-T4, AC4: regression-testing/abandon-bats-before-script.2026-09-29T18-00.md (P2-T6, fail-before),
  regression-testing/abandon-bats-after-script.2026-09-29T18-00.md (P2-T8),
  qa-gates/shell-test-local.2026-09-29T18-44.md (P7-T3).
- P12-T5, AC5: regression-testing/abandon-python-lane.2026-09-29T18-00.md (P2-T13),
  qa-gates/shell-coverage-ci.2026-09-29T19-13.md (P11-T3; CI bash parity lane, three `ok` lines).
- P12-T6, AC6: regression-testing/bats-after-bundle.2026-09-29T18-37.md (P5-T10),
  qa-gates/shell-coverage-ci.2026-09-29T19-13.md (P11-T3; the three B29 tests `ok`).
- P12-T7, AC7: regression-testing/abandon-token-seam.2026-09-29T18-37.md (P4-T13; every B26 test PASSED).
- P12-T8, AC8: qa-gates/ac1-ac8-pester.2026-09-29T18-44.md (P6-T5),
  qa-gates/ac8-hook-diff.2026-09-29T18-44.md (P6-T6). DV2 anchor note: the diff is anchored to
  BASE_SHA `12db46245ba7683b5d6ccb676312a4b22a39b0ce` instead of `main`, because this branch is cut
  from the integration branch and `main` lacks sibling-feature commits.
- P12-T9, AC9: regression-testing/surface-tokens.2026-09-29T18-37.md (P4-T14),
  other/bundle-mirrors-and-manifest.2026-09-29T18-37.md (P5-T3; bundle counts equal repo counts),
  qa-gates/ac9-invocation-sweep.2026-09-29T18-44.md (P6-T3).
- P12-T10, AC10: regression-testing/surface-contracts.2026-09-29T18-37.md (P4-T15),
  qa-gates/python-regression.2026-09-29T19-13.md (P9-T6; the named set includes
  `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`, all PASSED).
- P12-T11, AC11: regression-testing/surface-tokens.2026-09-29T18-37.md (P4-T7 counts T3/T4/T5 = 1,
  re-recorded by P4-T14), qa-gates/ac11-agent-diff.2026-09-29T18-44.md (P6-T7). DV2 anchor note: the
  diff is anchored to BASE_SHA, not `main`.
- P12-T12, AC12: other/bundle-mirrors-and-manifest.2026-09-29T18-37.md (P5-T1 to P5-T4),
  regression-testing/bats-after-bundle.2026-09-29T18-37.md (P5-T10),
  regression-testing/drift-suites-after-bundle.2026-09-29T18-37.md (P5-T11),
  regression-testing/bundle-contracts.2026-09-29T18-37.md (P5-T12; KL-510 STATE-ONLY),
  regression-testing/jest-pack-manifest.2026-09-29T18-37.md (P5-T13).
- P12-T13, AC13: regression-testing/guard-units-after-registry.2026-09-29T18-00.md (P1-T6),
  regression-testing/guard-repo-before-port.2026-09-29T18-00.md (P1-T7, fail-before),
  regression-testing/guard-cli-before-port.2026-09-29T18-00.md (P1-T8, fail-before),
  regression-testing/abandon-token-seam.2026-09-29T18-37.md (P4-T13;
  `test_bundle_guard_extracts_the_skill_invocation` PASSED),
  regression-testing/guard-repo-after-port.2026-09-29T18-44.md (P6-T1),
  regression-testing/guard-cli-after-port.2026-09-29T18-44.md (P6-T2),
  qa-gates/python-test-coverage.2026-09-29T19-13.md (P9-T5).
- P12-T14, AC14: other/runsettings-registration.2026-09-29T18-37.md (P5-T6, P5-T7),
  regression-testing/bundle-contracts.2026-09-29T18-37.md (P5-T12;
  `test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources` PASSED),
  qa-gates/powershell-test-coverage.2026-09-29T18-44.md (P8-T5).
- P12-T15, AC15: qa-gates/python-test-coverage.2026-09-29T19-13.md (P9-T5),
  qa-gates/shell-coverage-files.2026-09-29T19-13.md (P11-T4; abandon script line-rate 0.946).
- P12-T16, AC16: qa-gates/ac16-python-reference.2026-09-29T18-44.md (P6-T4).
- P12-T17, AC17: qa-gates/ac17-scope.2026-09-29T18-44.md (P6-T8),
  qa-gates/ac17-no-temp.2026-09-29T18-44.md (P6-T9), qa-gates/final-commit.2026-09-29T19-13.md
  (P11-T1). DV2 anchor note: the name-only diff is anchored to BASE_SHA, not `main`.
- P12-T18, AC18: every Phase 7 through 11 artifact exists with passing acceptance
  (qa-gates/shell-format, shell-lint, shell-test-local; powershell-format, powershell-analyze,
  powershell-mcp-test-route, powershell-test-coverage; python-format, python-lint, python-typecheck,
  python-test-coverage, python-regression, line-counts-final; ts-push-down-jest; final-commit,
  shell-coverage-ci, shell-coverage-files, coverage-comparison), and the P11-T5 overall
  `Disposition:` is `PASS`.

## Direct count (P12-T19)

Command: sh SCRATCH/ac-count.sh docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/spec.md
EXIT_CODE: 0
Output Summary:
AC-CHECKED=18 AC-UNCHECKED=0
(`git diff --numstat HEAD -- spec.md` printed `18 18`: exactly the 18 AC lines changed, each only
from `- [ ]` to `- [x]`.)
