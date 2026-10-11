# Regression: #764 plan residual -nxF form check ([P7-T6], AC-21)

Timestamp: 2026-10-09T21-37
Command: git grep -c -e "-nxF" -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md
EXIT_CODE: 0
Output Summary: `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md:3` (count 3; supplementary `git grep -n` shows lines 39, 40, 66).

## Block 2

Command: git grep -c -e "#846.*-nxF" -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md
EXIT_CODE: 0
Output Summary: `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md:3` (count 3).

Acceptance (AC-21 residual form check): both blocks print the count 3, so every remaining `-nxF` occurrence is inside a #846 correction note (lines 39, 40, 66). PASS.
