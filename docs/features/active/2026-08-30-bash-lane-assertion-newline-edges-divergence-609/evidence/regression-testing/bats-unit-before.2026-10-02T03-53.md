# Fail-first bats run through CI at commit 1524e2d2 (AC-6)

Timestamp: 2026-10-02T03-53
Command: git push origin 1524e2d2:refs/heads/tmp/609-fail-first; gh workflow run ci.yml --repo drmoisan/drm-copilot --ref tmp/609-fail-first; gh run view 36961456506 --repo drmoisan/drm-copilot --job 110695853236 --log; git push origin --delete tmp/609-fail-first
ExpectedExitCode: 0
EXIT_CODE: 0
Output Summary: At commit 1524e2d2 (new edges-parity cases and the corpus fixture present, library fix absent) the CI job `shell-coverage / Shell Coverage (Bats + kcov)` concluded `failure`. The bats plan was `1..507`. Exactly four of the six new `edges-parity:` cases in `tests/shell/parallel_lane_assertion.bats` reported `not ok` (119, 121, 122, 124); the tab case (120) and the undeclared-vertices case (123) reported `ok`, as designed. One further `not ok` (128) was the corpus parity test in `tests/shell/parallel_lane_assertion_parity.bats` reporting fixture `edges_newline_separated` (the fixture added in the same commit). Total `not ok` lines in the job log: 5. The `EXIT_CODE: 0` above is the exit code of the evidence-collection commands; the gated job itself failed, which is the expected fail-first outcome.

Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/36961456506/job/110695853236
Run workflow: `CI` dispatched with `workflow_dispatch` on branch `tmp/609-fail-first` (commit 1524e2d2).
Pass-after counterpart: https://github.com/drmoisan/drm-copilot/actions/runs/36960736942 (PR head 5e854239, `shell-coverage` success; see `evidence/qa-gates/ci-shell-coverage.2026-10-02T03-40.md`).

## Failing case lines (verbatim from the job log)

```
not ok 119 edges-parity: a newline-separated value matches the single-line control
#   `edges_header_is "$EDGES_MERGED_HEADER" $'999:998\n101:202'' failed
ok 120 edges-parity: a tab-separated value matches the single-line control
not ok 121 edges-parity: a CR-separated value matches the single-line control
#   `edges_header_is "$EDGES_MERGED_HEADER" $'999:998\r101:202'' failed
not ok 122 edges-parity: a CRLF-terminated final token is kept
#   `edges_header_is "$EDGES_MERGED_HEADER" $'999:998\r\n101:202\r\n' $'101:202\r\n'' failed
ok 123 edges-parity: newline-separated edges naming only undeclared vertices are skipped
not ok 124 edges-parity: mixed separators with a trailing newline match the single-line control
#   `edges_header_is "$EDGES_MERGED_HEADER" $'999:998\n\t101:202\r\n'' failed
not ok 128 the bash lane reproduces every lane-assertion corpus fixture
# fixture edges_newline_separated: actual=[Lane assertion: 2 derived conflict component(s); 0 disagreement(s). ...] expected=[Lane assertion: 1 derived conflict component(s); 0 disagreement(s). ...]
```

## Temporary branch
`tmp/609-fail-first` was deleted after the run (`git push origin --delete tmp/609-fail-first` printed `[deleted]`; `git ls-remote --heads origin tmp/609-fail-first` returned no rows).

## Acceptance criterion decision
AC-6: satisfied. The new bats regression tests fail on the unmodified library (commit 1524e2d2, four expected `edges-parity:` failures plus the corpus fixture) and pass after the fix (PR head 5e854239).
