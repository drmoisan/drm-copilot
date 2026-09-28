# Remediation gate 7 — evidence-location validation

Timestamp: 2026-09-17T13-56

Task: `[P4-T8]` of `remediation-plan.2026-09-17T12-29.md`

Command, **C9**:
`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`

EXIT_CODE: 0

Output Summary:

The validator produced **no output at all** on either stdout or stderr, and exited **0**.

Reported path list: **`none`**.

## What this gate establishes

`.claude/skills/evidence-and-timestamp-conventions/SKILL.md` is the non-overridable authority for evidence
paths and forbids `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`,
`artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, and `artifacts/post-change/`
as evidence output locations. A zero exit with no reported path is the validator's statement that no evidence
artifact in the repository sits at a non-canonical location.

Every artifact this remediation wrote is under
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/<kind>/`, across four
canonical kinds:

| kind | artifacts written by this remediation |
| --- | --- |
| `evidence/remediation-baseline/` | 6 — the Phase 0 policy-read artifact and five baseline captures |
| `evidence/other/` | 7 — the scope decisions, the AC reversion, three batch boundaries, the file-size ledger, and the AC status summary |
| `evidence/regression-testing/` | 6 — the fail-before pair, the two integrity checks, and two suite runs |
| `evidence/qa-gates/` | 10 — the four final-QC steps, the four remediation gates, the mirror parity, and the gate summary |

Phase 0 used the canonical `evidence/remediation-baseline/` kind rather than `evidence/baseline/`, as the plan
preamble requires, so its artifacts do not collide with the delivery plan's own baseline artifacts. Both kinds
are canonical under the skill's sub-path list.

`artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` were **read** as inputs by
`[P0-T6]`, `[P4-T3]`, and `[P4-T5]`. They are tool output paths declared by
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lines 15 and 22, and no task in this plan wrote
evidence to them. That is consistent with the validator's silence: `artifacts/pester/` is not an evidence
location and is not in the forbidden list.

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` record was required at any point in this execution. The dispatch
brief and the plan both named canonical evidence paths, so no non-canonical path had to be substituted.

Acceptance: `EXIT_CODE: 0` and no reported path. Satisfied.
