# Reproduction-Evidence Audit for AC-1 to AC-3 (issue #673)

Timestamp: 2026-09-19T17-21

Command: existence tests over the four `evidence/baseline/repro-*` artifacts; `grep -c 'REPRODUCTION: CONFIRMED'` over `repro-verdict.md`; `git log --format=%H --diff-filter=A b7c1161655b4b53b0358dc7890a26200207c4b91..HEAD -- docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/repro-verdict.md`; `git log --format=%H b7c1161655b4b53b0358dc7890a26200207c4b91..HEAD -- .claude/hooks`

EXIT_CODE: 0

Existence results (all four paths are relative to `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/`):

| Artifact | Result |
| --- | --- |
| `repro-3-2-control-pair.md` | exists |
| `repro-3-4-control-pair.md` | exists |
| `repro-fixture-manifest.md` | exists |
| `repro-verdict.md` | exists |

Token count of `REPRODUCTION: CONFIRMED` in `repro-verdict.md`: 1

EVIDENCE_COMMIT: 59b08af5805abaed61f32b14f9f82f8ff58e0a13

HOOK_COMMITS_ON_BRANCH: none

Output Summary: All four reproduction artifacts exist under the feature folder's baseline evidence directory. `repro-verdict.md` carries exactly one `REPRODUCTION: CONFIRMED` line. The commit that added `repro-verdict.md` is a single 40-hexadecimal SHA, `59b08af5805abaed61f32b14f9f82f8ff58e0a13`. No commit on the branch since `F5_BASE_SHA` touches `.claude/hooks`, so the reproduction evidence provably precedes every hook edit this plan will make, which is the AC-3 ordering requirement. `[P11-T10]` re-checks the same ordering by commit position after the hook edits land.
