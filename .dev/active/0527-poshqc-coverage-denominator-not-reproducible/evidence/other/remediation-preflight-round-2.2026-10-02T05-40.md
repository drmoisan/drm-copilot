# Remediation Preflight, Round 2

Timestamp: 2026-10-02T05-40
Plan: docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/remediation-plan.2026-10-02T05-08.md
Signal: PREFLIGHT: REVISIONS REQUIRED
CONVERGENCE: NO FURTHER ROUNDS EXPECTED (both defects are literal text substitutions; no new command or condition is introduced)

## Round-1 defect resolution

- D1 resolved. P0-T2 now requires HEAD prefix `7efd9d8f`, empty `--untracked-files=no` status, and every `??` line under `<FEATURE>/`. Verified against the tree: HEAD is 7efd9d8f3044568bd1da627425309e93f5724e46; the only `??` paths are the plan and the round-1 record, both under `<FEATURE>/`.
- D2 resolved. P1-T4 uses `coverage json --pretty-print` and `-A 14` after `"totals"`.
- D3 resolved. P1-T5 uses `^BRDA:`, `^BRDA:.*,1\s*$`, `^BRDA:.*,(0|-)\s*$`, with the sum check and the description-string note.
- D4 resolved. P2-T1 checks off P0 and P1 only; P2 check-offs are written after P2-T5 and reported as an uncommitted edit; P2-T3 status check precedes them. Verified: remediation-inputs and the other feature files are tracked, so the status is empty after the commit.
- D5 resolved. 600000 ms timeout with background re-run stated in P1-T2 and P1-T3.
- D6 resolved. P1-T3 states mismatch handling.
- D7 NOT fully resolved. See N1.
- D8 resolved. Output redirection fallback stated; target `artifacts/python/run-*-output.txt` is git-ignored (.gitignore `/artifacts`) and not staged (P2-T2).

## New defects

N1 (P2-T3, trailer differs from the delta). The commit command carries `Co-Authored-By: Claude Opus 5.5`. The round-1 delta and the session attribution instruction specify `Claude Sonnet 5.5 <noreply@anthropic.com>`. The plan therefore does not follow the required attribution.

N2 (P1-T2, quoted rejected alternative in a code span). The justification sentence writes the rejected alternative as a code span that looks like a command. This is the source of the validator G9 warning. It cannot be run by the executor unless misread; it is reworded to remove the ambiguity.

## Other checks (no defect)

- G4 warnings on bare `--cov`: not defects (round 1).
- Phase 0 evidence paths use `<FEATURE>/evidence/remediation-baseline/`; all other evidence uses `evidence/qa-gates/`: canonical.
- P1-T6 anchored diff `origin/main...HEAD` with a `git status --porcelain` companion: satisfies G8 and G8b.
- P1-T4 `"totals"` occurs once in a pretty-printed coverage JSON; the 14 context lines cover the 14 listed fields.
- Final QA loop applicability: no code changed; acceptable.

## Delta

1. P2-T3: replace `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.
2. P1-T2: replace the sentence "The bare `--cov` form is retained deliberately: ... whereas `--cov=src --cov=scripts.dev_tools` would alter the measured source set." with: "The bare --cov form is retained deliberately: it measures the configured source set, and naming sources explicitly on the command line would alter the measured source set."

Delta prose checked against tonality policy: no hyperbole, humor, or figurative language.
