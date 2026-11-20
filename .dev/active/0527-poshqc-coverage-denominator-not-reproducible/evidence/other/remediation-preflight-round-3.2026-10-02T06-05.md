# Remediation Preflight, Round 3

Timestamp: 2026-10-02T06-05
Plan: docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/remediation-plan.2026-10-02T05-08.md
Signal: PREFLIGHT: ALL CLEAR
CONVERGENCE: NO FURTHER ROUNDS EXPECTED (round-2 items are resolved, and no new defect was found on a full re-read)

## Round-2 item status

- N1 closed by orchestrator ruling. The authoritative trailer is `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. P2-T3 carries exactly that trailer. Not re-raised.
- N2 resolved. The P1-T2 sentence now reads "The bare --cov form is retained deliberately: it measures the configured source set, and naming sources explicitly on the command line would alter the measured source set." No code span contains a rejected alternative command.

## Tree re-derivation this pass

- HEAD is 7efd9d8f3044568bd1da627425309e93f5724e46 (prefix `7efd9d8f` matches P0-T2).
- `git status --porcelain` lists three untracked paths, all under `<FEATURE>/`: the plan, the round-1 record, and the round-2 record. No tracked modification.
- `git diff --name-only origin/main...HEAD -- '*.py'` prints exactly `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (P1-T6 expectation).
- `pyproject.toml`: line 116 `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`; line 120 `source = ["src", "scripts/dev_tools"]`; line 121 `data_file = "artifacts/.coverage"`; no `branch` entry (P1-T1, P1-T4 expectations).
- `.gitignore` line 6 is `/artifacts` (P1-T2, P2-T2 expectations).

## Whole-plan review

- Task IDs are sequential per phase; phase headings follow the `### Phase N — <Title>` form.
- Evidence paths are canonical (`evidence/remediation-baseline/`, `evidence/qa-gates/`).
- Phase ordering is satisfiable: Run B is the last writer of `artifacts/python/lcov.info`; `artifacts/` is not staged.
- P1-T6 uses an anchored diff with a porcelain companion (G8, G8b).
- P2-T3 status check precedes the P2 check-off edit, and every untracked file is staged by P2-T1.
- Remaining validator warnings are the bare `--cov` form (G4), retained deliberately and justified in P1-T2.
- No defect found.

## Delta

None.
