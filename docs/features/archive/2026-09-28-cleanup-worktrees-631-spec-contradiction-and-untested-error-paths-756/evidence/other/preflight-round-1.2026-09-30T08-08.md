# Preflight Round 1 — Issue #756

- Timestamp: 2026-09-30T08-08
- Reviewer: atomic-executor (DIRECTIVE: PREFLIGHT VALIDATION ONLY)
- Plan: plan.2026-09-30T03-38.md (sha256 4bc7562f8f446b7963eb437c48fbc57bb32e79c7dad2fb2ef7d2ce9043ffb568)
- Signal: PREFLIGHT: REVISIONS REQUIRED
- Convergence: CONVERGENCE: FURTHER ROUNDS LIKELY

## Verified by the reviewer

- Plan validator exits 0 with no gate warnings.
- `npx --yes bats` (1.13.0): report_records suite `1..10`, classification suite `1..21`, all ok.
- `child_of_not_merged` holds 18 files; stub pair-key lookup and rung-2 probe key confirmed.
- Scratch copies of the proposed fixtures and tests N1-N8 ran `1..8`, all ok, with return codes 2, 0, 3, 5, 4, 7, 9, 9.
- Spec passages and replacement counts confirmed; no other passage of the same class.
- CI run 36662688885 `shell-coverage` artifact: library line-rate 0.890; target statements currently `hits="0"`.

## Defects

- D1: P2-T6 fallback omits the observed local literal `bats not installed` (exit 127).
- D2: P0-T11 baseline CI run selection is not anchored to the merge-base SHA.
- D3: P2-T11 BLOCKED wording conflicts with the executor contract; the dispatched-run identification and wait are underspecified.
- D4: P2-T12 records several exit codes in one artifact.
- D5: several Phase 1 acceptance conditions depend on later tasks.
- D6: P1-T37 porcelain check is blind to committed state; needs an anchored diff companion.
