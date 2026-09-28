# Evidence-Location Validation — Final QC, Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P8-T9]

Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`

EXIT_CODE: 0

## Output Summary

The validator exits 0 with no output, meaning **no evidence-location violation was found anywhere in
the repository**.

### Every artifact this cycle produced resolves under the canonical feature evidence root

All 25 artifacts written by this cycle resolve under
`docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/<kind>/`.

**`evidence/remediation-baseline/` — 17 artifacts** (cycle-entry baselines and mid-cycle verification):

`phase0-instructions-read.2026-08-09T00-01.md`, `python-format-baseline.2026-08-09T00-01.md`,
`python-lint-baseline.2026-08-09T00-01.md`, `python-typecheck-baseline.2026-08-09T00-01.md`,
`python-test-baseline.2026-08-09T00-01.md`, `powershell-format-baseline.2026-08-09T00-01.md`,
`powershell-analyze-baseline.2026-08-09T00-01.md`, `powershell-test-baseline.2026-08-09T00-01.md`,
`coverage-floor.2026-08-09T00-01.md`, `file-size-headroom.2026-08-09T00-01.md`,
`shared-file-reference.2026-08-09T00-01.md`, `split-parity.2026-08-09T00-01.md`,
`f8-b1-verification.2026-08-09T00-01.md`, `f8-b2-verification.2026-08-09T00-01.md`,
`f8-n4-verification.2026-08-09T00-01.md`, `f8-n3-verification.2026-08-09T00-01.md`,
`shared-file-edit-confinement.2026-08-09T00-01.md`.

**`evidence/qa-gates/` — 8 artifacts at this point, plus the three this phase still writes**
(`coverage-delta`, `acceptance-criteria-checkoff`, `remediation-cycle-summary`):

`python-format-final.2026-08-09T00-01.md`, `python-lint-final.2026-08-09T00-01.md`,
`python-typecheck-final.2026-08-09T00-01.md`, `python-test-final.2026-08-09T00-01.md`,
`powershell-format-final.2026-08-09T00-01.md`, `powershell-analyze-final.2026-08-09T00-01.md`,
`powershell-test-final.2026-08-09T00-01.md`, `f5-surface-contract-final.2026-08-09T00-01.md`, and this
artifact.

**`evidence/other/` — 1 artifact amended** (not newly created): the IC-6a amendment appended to the
existing `upstream-contract-reconciliation.2026-08-08T21-19.md` by [P6-T3].

One artifact this cycle produced lies outside the evidence tree by design rather than by drift: the
`docs/features/potential/` entry created by [P6-T1],
`docs/features/potential/2026-08-09-parallel-drift-gate-typescript-parity-divergence.md`. That is a
repository-level potential-feature record, not evidence, and
`docs/features/potential/` is its prescribed home; the validator does not flag it.

### No path under `artifacts/` was used for evidence

`artifacts/` contains exactly three sub-paths, and none is an evidence location:

- `artifacts/orchestration/` — the allowed non-evidence orchestration checkpoint path.
- `artifacts/pester/` — tool output (`pester-junit.xml`, `powershell-coverage.xml`), written by the
  Pester run itself, not by this agent as evidence.
- `artifacts/python/` — tool output (`lcov.info`), written by pytest-cov, not by this agent as
  evidence.

Every forbidden evidence sub-path was checked for existence and **none exists**:
`artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`,
`artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, and
`artifacts/post-change/` all return "No such file or directory".

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record was required in this cycle: neither the plan nor the
delegation prompt supplied a non-canonical evidence path. Both named
`evidence/remediation-baseline/` for cycle-entry and mid-cycle artifacts and `evidence/qa-gates/` for
the final QC pass, which are canonical.
