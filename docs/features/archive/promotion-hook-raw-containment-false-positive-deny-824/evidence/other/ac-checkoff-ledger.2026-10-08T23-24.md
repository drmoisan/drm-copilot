# Acceptance-Criteria Check-Off Ledger ([P10-T19])

Timestamp: 2026-10-08T23-24
AC source: `FEATURE/spec.md` (Work Mode full-bug; AC-1 through AC-31).
Final clean QC pass: 2 (`evidence/qa-gates/qc-loop-summary.2026-10-08T23-25.md`).

Artifact abbreviations (all paths relative to `FEATURE/evidence/`):
- PA8 = regression-testing/pass-after.2026-10-08T22-42.md ([P8-T1])
- NC8 = regression-testing/negative-controls.2026-10-08T22-43.md ([P8-T2])
- FBPA = regression-testing/fail-before-pass-after-summary.2026-10-08T22-44.md ([P8-T3])
- FB1 = regression-testing/fail-before.2026-10-08T17-50.md ([P1-T2])
- I824 = qa-gates/qc-pass-2-issue824.2026-10-08T23-21.md ([P10-T9])
- FULL = qa-gates/qc-pass-2-pester-full-coverage.2026-10-08T23-19.md ([P10-T6]); RUN = qa-gates/qc-pass-2-pester-full-run.2026-10-08T23-19.md ([P10-T5])
- CHG = qa-gates/qc-pass-2-changed-line-coverage.2026-10-08T23-19.md ([P10-T7]); DELTA = qa-gates/coverage-delta.2026-10-08T23-20.md ([P10-T8])
- PY = qa-gates/qc-pass-2-pytest-parity.2026-10-08T23-22.md; JS = qa-gates/qc-pass-2-jest-parity.2026-10-08T23-22.md
- LINES = qa-gates/qc-pass-2-lines.2026-10-08T23-22.md; NOPY = qa-gates/qc-pass-2-no-python.2026-10-08T23-23.md; PAR = qa-gates/qc-pass-2-parity-pester.2026-10-08T23-23.md
- HASH = qa-gates/qc-pass-2-parity-hashes.2026-10-08T23-24.md; SCOPE = qa-gates/qc-pass-2-scope.2026-10-08T23-24.md; TOK = qa-gates/qc-pass-2-deny-tokens.2026-10-08T23-24.md; VB = qa-gates/qc-pass-2-validate-bash-unchanged.2026-10-08T23-24.md
- LOOP = qa-gates/qc-loop-summary.2026-10-08T23-25.md; FMT = qa-gates/qc-pass-2-format.2026-10-08T23-06.md; PSSA = qa-gates/qc-pass-2-analyze.2026-10-08T23-07.md
- CORPUS = other/prior-run-corpus-coverage.2026-10-08T22-48.md; SMOKE = other/pr-author-hook-live-smoke.2026-10-08T22-52.md; I742 = issue-updates/issue-742.2026-10-08T22-50.md

| AC | Evidence | Rows / gate | Status |
|---|---|---|---|
| AC-1 | PA8, I824 | REG-01 (claude, codex); PM-01 (claude, codex) | CHECKED |
| AC-2 | I824 | PM-02..PM-13 (claude, codex) | CHECKED |
| AC-3 | PA8, I824 | REG-02, REG-04, REG-06; EW-01, PW-01, CW-01 | CHECKED |
| AC-4 | I824 | EW-03..07, PW-03..07, CW-03..07 | CHECKED |
| AC-5 | I824 | EW-08..12, PW-08..12, CW-08..12 | CHECKED |
| AC-6 | I824 | EW-13..20, PW-13..20, CW-13..20 (also OP-07, OP-15). Note: the AC-6 clause "the deny names the first unauthorized target" applies only to the derivable-target rows (-13, W5 at -18, W6 at -19); W1-W4 (-14..-17) carry an operand that cannot be derived, so they deny with `TARGET_WORKTREE_NOT_DERIVABLE` under AC-7 and name no target. | CHECKED |
| AC-7 | I824 | EW-21..28, PW-21..28, CW-21..28 | CHECKED |
| AC-8 | PA8, I824 | REG-03, REG-05, REG-07, REG-08; IV-09, IV-10, IV-11 | CHECKED |
| AC-9 | I824 | PM-14..PM-18; IV-06 (18 sink executions); IV-07 | CHECKED |
| AC-10 | I824 | PM-19, EW-21, PW-21, CW-21, AL-25 | CHECKED |
| AC-11 (amended, D10) | CORPUS, I824 | every row ID in the CORPUS mapping passed; X5/X6/X9/Y4 search recorded (EXIT_CODE 0, SearchResult reproduced) | CHECKED |
| AC-12 | I824 | PY-01, PY-02, PY-22, PY-23, IV-01, IV-02, OP-01, OP-10 | CHECKED |
| AC-13 | FULL, I824 | existing pin rows in `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1` (not in the failing set); IV-12, IV-13, IV-24 | CHECKED |
| AC-14 | NC8, I824 | 8 negative-control executions passed; IV-17 | CHECKED |
| AC-15 | PA8, I824 | REG-09..REG-12; PA-01..PA-05 | CHECKED |
| AC-16 | PA8, I824 | REG-13..REG-17; PA-06..PA-15, PA-21 | CHECKED |
| AC-17 | I824, SCOPE | PA-16..PA-19; `.claude/hooks/enforce-pr-author-skill.ps1` unchanged from BASE_SHA | CHECKED |
| AC-18 | PA8, I824 | REG-18; AL-11..AL-31 | CHECKED |
| AC-19 | PA8, I824 | REG-20, REG-21; AL-07, AL-08, AL-34, AL-35 | CHECKED |
| AC-20 | I824 (static AL-33); SMOKE (pending) | AL-33 passed; live `pr-author` delegation smoke not yet run | PENDING-ORCHESTRATOR |
| AC-21 | I742 (POSTING BLOCKED), VB, FULL | comment text written; posting blocked (no PR yet); validate-bash rule and suites unchanged and passing | PENDING-ORCHESTRATOR |
| AC-22 | FULL, I824 | set-`A` suites fail only in `B_FULL`; CN-01..CN-10 | CHECKED |
| AC-23 | HASH | 16 groups DISTINCT=1 | CHECKED |
| AC-24 | PY, JS, PAR (local) | pytest 27 passed; jest 42 passed; legacy-codex-hook-contracts passed; CI result pending | PENDING-ORCHESTRATOR |
| AC-25 | TOK, I824 | NEW_TOKEN_COUNT 2 (permitted set); PM-02, EW-03, PW-03, CW-03, PA-11, PA-16, AL-11 | CHECKED |
| AC-26 | NOPY, PAR | PYTHON_INVOCATION_COUNT 0; no-Python guard rows all Passed | CHECKED |
| AC-27 | LINES | OVER_500: NONE (max 497) | CHECKED |
| AC-28 | FULL, CHG, DELTA | 19 files >= 85.00; UNCOVERED_CHANGED_TOTAL 0; no decrease vs baseline | CHECKED |
| AC-29 | LOOP, FMT, PSSA, RUN | clean pass 2 (format, lint, Pester with coverage) | CHECKED |
| AC-30 | FBPA, FB1, PA8 | 7 named reproductions Failed before, Passed after | CHECKED |
| AC-31 | SCOPE | ADDENDUM2_COUNT 0; OUT_OF_SET_COUNT 0 | CHECKED |

Rows: 31. CHECKED: 28. PENDING-ORCHESTRATOR: 3 (AC-20, AC-21, AC-24). Every CHECKED row names at least one existing artifact.

AC-6 note: the AC-6 clause "the deny names the first unauthorized target" applies only to the derivable-target rows (-13, W5 at -18, W6 at -19); W1-W4 (-14..-17) carry an operand that cannot be derived, so they deny with `TARGET_WORKTREE_NOT_DERIVABLE` under AC-7 and name no target.

AC-20 pending reason: the live smoke requires a `pr-author` delegation, which the orchestrator runs at PR stage per SMOKE; the AC-20 line of spec.md stays unchecked.

AC-21 pending reason: [P9-T4] found no open pull request (`gh pr list ... --json number` printed `[]`), so the #742 comment carries the `POSTING BLOCKED` header; the orchestrator posts it after PR creation. The AC-21 line of spec.md stays unchecked.

AC-24 pending reason: AC-24 requires the parity and manifest-completeness tests to pass in CI; only local results exist. The AC-24 line of spec.md stays unchecked.
