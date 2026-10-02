# Code Review (#609, review pass 1, R5 reaudit)

- Timestamp: 2026-10-02T04-00
- Head: `6a7f5eb565485f151d56269e25282082f5b951f0`; base `origin/main` (`1b1e349f`)
- Reviewed: `git diff origin/main...HEAD` for the four non-documentation files
- Supersedes: `code-review.2026-10-01T23-21.md`

## Verdict

No blocking code finding. Blocking count: 0. The fix is minimal and correct by reading, and its behavior is now confirmed by CI: bats `1..507` with no `not ok` on PR head `5e854239` (run 36960736942), and the fail-first run at `1524e2d2` shows the four expected failures (`evidence/regression-testing/bats-unit-before.2026-10-02T03-53.md`). The source files are byte-unchanged between those CI heads and the review head (`git diff --name-only 757d99f1..HEAD` lists documentation only).

## Fix: `.claude/lib/bash/parallel-lane-assertion.sh` lines 84-88

```
read -ra tokens <<<"${text//[$'\n\r\v\f']/ }"
```

- Correctness: `read -ra` without `-d` consumes one newline-terminated record and splits on default IFS. Replacing newline, CR, VT, and FF with spaces first aligns the bash separator set with Python `str.split()` for ASCII. CI confirms: the newline-separated case (119) fails without the fix and passes with it, and the corpus fixture `edges_newline_separated` pass after the fix.
- Residual risk R-1 from the prior pass (reliance on `$'...'` inside a double-quoted pattern expansion) is closed: the expansion runs correctly on CI bash, as the four fail-first cases pass after the fix.
- Invariants preserved: `read -ra` retained (no pathname expansion of tokens); no new command, so no exit-status effect under `set -euo pipefail`; downstream shape and integer-lexis checks unchanged.
- Size: 497 lines, limit 500.
- Residual (recorded follow-up 2): Python-only whitespace (`\x1c`-`\x1f`, `\x85`, `\xa0`, Unicode spaces) still differs. The comment names only newline, CR, VT, and FF and does not claim full equivalence.

## Mirror

The bundled mirror is byte-identical (`cmp` exit 0, reviewer ran it). Both byte-equality guards are covered: the push-down contract pytest (prior reviewer run, 83 passed) and `parallel_bash_manifest_membership.bats` (inside the green CI bats run).

## Tests: `tests/shell/parallel_lane_assertion.bats` (+37 lines, 495 total)

- Helper `edges_header_is` asserts `"$status:${lines[0]}"` for each value and a single-line `101:202` control, so a failure message names both status and header.
- ANSI-C quoting keeps the file ASCII; no temp files or waits.
- Fail-first design confirmed by CI at `1524e2d2`: newline (119), CR (121), CRLF-terminated (122), mixed (124) fail without the fix; tab (120) and undeclared-only (123) pass by design as boundary guards.
- R-2 (low): file-scope header variables are shell globals; bats re-evaluates the file per test, so no leakage. No action.
- R-4 (low): the helper asserts only the first output line; full output is covered by the parity fixture. Adequate.
- Observation: `shfmt -d` reports whole-file differences on `.bats`; pre-existing, and `shell-qc.sh` does not format `.bats`.

## Fixture: `tests/fixtures/parallel_lane_assertion/edges_newline_separated.json`

Key set and order follow the sibling fixture; `expected_stdout` is Python-authority output (1 derived component, two informational lines); `divergence` is `null`. In the fail-first CI run, the corpus test reported `expected=[... 1 derived ...]` versus `actual=[... 2 derived ...]` on the unfixed library, and it passes after the fix, which demonstrates the fixture discriminates.

## Scope Discipline

No unrelated edits or formatting churn. Follow-ups (`pcoh_split_words` newline truncation, residual Python-only whitespace) remain recorded in `evidence/other/follow-ups.2026-09-29T18-45.md`.

## Non-Blocking Observations

- Stale pre-CI evidence files are listed in `policy-audit.2026-10-02T04-00.md` section 16. None blocks.
- CI on head `6a7f5eb5` was still pending at review time; the delta from the green head is documentation only.

## Blocking Findings

None.
