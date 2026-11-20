# Acceptance-criteria status summary (Issue #500)

Timestamp: 2026-08-22T00:40:00Z
Issue: #500
Task: [P8-T16]

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`
  (sole AC source; the persisted marker in `issue.md` is `- Work Mode: full-bug`, so `spec.md` is
  authoritative and `user-story.md` is absent by design)
- Total AC items: **17**
- Checked off (delivered): **17**
- Remaining (unchecked): **0**
- Items remaining: none

The three `- [ ]` checkboxes that remain in `spec.md` at lines 44, 46, and 47 are the
`Impact / Severity` radio options `Blocker`, `Medium`, and `Low`. They sit outside the
`## Acceptance Criteria` heading, `High` is checked among them, and they are not acceptance criteria.
No AC item text was modified and no AC item was added.

## Evidence backing each checked criterion

| AC | Subject | Evidence artifact |
| --- | --- | --- |
| AC1 | `PAYLOAD_MODULES` is `{ config: ["config/**"] }`; doc comment rewritten | `evidence/qa-gates/phase2-typescript-verification.2026-08-21T23-25.md` |
| AC2 | `blast-radius-derive-core.test.ts` no longer pins `claude-runtime`; negative assertion added | `evidence/qa-gates/phase2-typescript-verification.2026-08-21T23-25.md`; occurrence inventory at `evidence/baseline/claude-runtime-occurrence-inventory.2026-08-21T23-03.md` |
| AC3 | `blast-radius-derive.test.ts` seeded expectations; `SOURCE_BLAST_RADIUS` and its comment | `evidence/qa-gates/phase2-typescript-verification.2026-08-21T23-25.md`; `evidence/qa-gates/phase4-typescript-verification.2026-08-21T23-38.md` |
| AC4 | Bundled `blast-radius.json` corrected in all four keys | `evidence/other/self-hosted-config-unchanged-keys.2026-08-21T23-30.md`; `evidence/qa-gates/phase6-python-gate.2026-08-22T00-04.md` |
| AC5 | AC8 forbidden-substring list narrowed and rationale rewritten (DD-1) | `evidence/qa-gates/phase4-typescript-verification.2026-08-21T23-38.md` |
| AC6 | Self-hosted `mandate_reads` gains four entries; other keys unchanged | `evidence/other/self-hosted-config-unchanged-keys.2026-08-21T23-30.md`; `evidence/qa-gates/phase3-python-verification.2026-08-21T23-32.md` |
| AC7 | `.claude/rules/parallel-orchestration.md` records (a), (b), (c) | `evidence/qa-gates/phase5-mirror-byte-identity.2026-08-21T23-43.md` |
| AC8 | Bundled rule mirror byte-identical in the same change set | `evidence/qa-gates/phase5-mirror-byte-identity.2026-08-21T23-43.md` |
| AC9 | Three-class key-partition gate | `evidence/qa-gates/phase6-python-gate.2026-08-22T00-04.md`; `evidence/qa-gates/phase6-file-size-check.2026-08-21T23-58.md` |
| AC10 | Five-name umbrella denylist, separator-free wildcard-free, non-vacuity floor | `evidence/qa-gates/phase6-python-gate.2026-08-22T00-04.md` |
| AC11 | PowerShell mirror of the gate, under 500 lines | `evidence/qa-gates/phase6-powershell-gate.2026-08-22T00-04.md`; `evidence/qa-gates/final-file-size-compliance.2026-08-22T00-35.md` |
| AC12 | `BlastRadius.TruthTable.Tests.ps1` comment corrected | `evidence/qa-gates/phase6-powershell-gate.2026-08-22T00-04.md` |
| AC13 | Fail-closed regression, fail-before and pass-after | fail-before: `evidence/regression-testing/python-regression-fail-before.2026-08-21T23-08.md`, `evidence/regression-testing/typescript-regression-fail-before.2026-08-21T23-10.md`, `evidence/regression-testing/powershell-fail-closed-repro.2026-08-21T23-12.md`; pass-after: `evidence/qa-gates/python-regression-pass-after.2026-08-22T00-14.md`, `evidence/qa-gates/typescript-regression-pass-after.2026-08-22T00-14.md`, `evidence/qa-gates/powershell-fail-closed-pass-after.2026-08-22T00-10.md` |
| AC14 | Fail-open regression, fail-before and pass-after | fail-before: `evidence/regression-testing/python-regression-fail-before.2026-08-21T23-08.md`, `evidence/regression-testing/powershell-fail-open-repro.2026-08-21T23-12.md`; pass-after: `evidence/qa-gates/python-regression-pass-after.2026-08-22T00-14.md`, `evidence/qa-gates/powershell-fail-open-pass-after.2026-08-22T00-10.md` |
| AC15 | Coverage obligations met and recorded | `evidence/qa-gates/coverage-delta-verification.2026-08-22T00-33.md`, with the three baseline artifacts and the three final-QC coverage artifacts it compares |
| AC16 | Full toolchain pass in a single run, all three languages | `evidence/qa-gates/final-toolchain-single-pass.2026-08-22T00-36.md` |
| AC17 | Divergence-walk evidence plus the routing byte compare | `evidence/other/divergence-commit-walk.2026-08-21T21-47.md`, `evidence/other/divergence-walk-citation.2026-08-21T23-04.md`, `evidence/other/routing-pair-byte-compare.2026-08-22T00-14.md` |

## Substitution recorded for AC9 and AC10

Spec AC9 and AC10 name `tests/scripts/dev_tools/test_blast_radius_config.py` as the file that
carries the three-class key-partition gate, the five-name umbrella denylist, the separator-free
wildcard-free assertion, and the non-vacuity floor. **The gate did not land in that file.**

That file stands at **499** of a permitted **500** lines, so one added line would breach the ceiling
in `.claude/rules/general-code-change.md`, which explicitly covers test code. It is unmodified by
this change set, confirmed by an empty `git status --porcelain` for that path in
`evidence/qa-gates/final-file-size-compliance.2026-08-22T00-35.md`.

The gate landed instead in the sibling module
**`tests/scripts/dev_tools/test_blast_radius_config_parity.py`** (387 lines), with its declared
constants and read-only accessors in
**`tests/scripts/dev_tools/blast_radius_parity_test_support.py`** (172 lines) after the [P6-T13]
split. The sibling imports `load_config_file`, `load_module_globs`, `COMMITTED_CONFIGS`,
`CONFIG_PATH`, `BUNDLED_CONFIG_PATH`, and `BUNDLED_CONFIG_LABEL` from the 499-line module rather than
duplicating them, so no logic is copied.

The naming follows the two-copy config-parity convention already used by
`test_orchestration_routing_config_parity.py`, `test_codex_topology_policy_config_parity.py`, and
`test_codex_model_policy_config_parity.py`. The support-module naming follows the
`*_test_support.py` convention already used by `parallel_drift_test_support.py` and its siblings.

Every assertion the two criteria describe is present and passing; only the file that carries them
differs. This substitution was authorized in advance by plan constraint C2 and by [P8-T15], and the
further split was authorized by [P6-T13]. AC4 also names `test_blast_radius_config.py` in its
verification clause and is covered by the same substitution.

## Coverage figures recorded against AC15

| Language | Statement / line | Threshold | Branch | Threshold |
| --- | --- | --- | --- | --- |
| Python | 92.60% | >= 85% | 85.19% | >= 75% |
| TypeScript | 96.66% | >= 85% | 90.04% | >= 75% |
| PowerShell | 96.21% | >= 85% | not measurable by Pester | exempt |

No coverage figure regressed against the Phase 0 baseline, no coverage reduction occurred on the
changed lines (the single edited production module is at 100.00% line coverage), and no `exclude`
entry was added to any coverage configuration.
