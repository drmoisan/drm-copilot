# Correction Baseline (remediation P0-T1)

Timestamp: 2026-11-10T02-34
Command: git diff --name-only 31be4b9778049c83f1da6d4052694f92b8c19f6e HEAD -- scripts .claude/lib extensions/drm-copilot/src tests; git status --porcelain -- scripts .claude/lib extensions/drm-copilot/src tests; wc -l <the ten Phase 1 files>
EXIT_CODE: 0
Output Summary:
- Head ref recorded in the newest shell-ci artifact (shell-ci.2026-11-10T02-07.md): 31be4b9778049c83f1da6d4052694f92b8c19f6e. The diff from it to HEAD over scripts, .claude/lib, extensions/drm-copilot/src, and tests is empty, and the porcelain listing over the same paths is empty, so the referenced gate runs measured the current code.
- Phase 0 baseline sources: python-static.2026-11-10T01-30.md, powershell-static.2026-11-10T01-06.md, typescript-static.2026-11-10T01-30.md, pytest-gate.2026-11-10T01-35.md, pester-gate.2026-11-10T01-17.md, jest-gate.2026-11-10T01-35.md, shell-ci.2026-11-10T02-07.md, coverage-comparison.2026-11-10T02-09.md (all under evidence/qa-gates/).
- Static: Black 0, Ruff 0, Pyright 0; Invoke-Formatter 0 changed, PSSA 0, leak scan 0 failures; Prettier 0, ESLint 0, tsc 0; shfmt and shellcheck 0.
- pytest: 16659 passed, 0 failed, 6 skipped; repo-wide line 97.13% (34525/35546), branch 94.41% (12758/13514).
  - _parallel_state_records.py 100.00% / 100.00% (191/191, 96/96); parallel_manifest_contract.py 100.00% / 100.00% (168/168, 82/82); _blast_radius_scheduling.py 100.00% / 100.00% (171/171, 40/40); _parallel_drift_scheduling.py 100.00% / 100.00% (47/47, 18/18).
- Pester: 21486 tests, 21476 passed, 0 failed, 10 skipped; repo-wide line 95.81% (37624/39271).
  - BlastRadiusAccess.psm1 100.00% (53/53); ParallelDriftAccess.psm1 100.00% (14/14); ParallelAdmissionPrecedenceGate.psm1 97.62% (41/42); Invoke-ParallelAdmission.ps1 96.79% (241/249).
- Jest: 341 suites, 5499 tests, 0 failed; repo-wide lines 97.16% (63964/65830), branches 93.91% (9785/10419); parallel-state-records.ts line 100.00% (643/643), branch 100.00% (141/141).
- Bats (CI run 42737591848): 799 ok, 0 not ok; kcov repo-wide 94.9% (3457/3644); parallel-manifest-pairs.sh 100.00% (68/68).
- Logical line counts: _parallel_state_records.py 500; parallel_manifest_contract.py 580; _blast_radius_scheduling.py 641; _parallel_drift_scheduling.py 190; BlastRadiusAccess.psm1 242; ParallelDriftAccess.psm1 53; ParallelAdmissionPrecedenceGate.psm1 128; Invoke-ParallelAdmission.ps1 678; parallel-manifest-pairs.sh 130; parallel-state-records.ts 643.
