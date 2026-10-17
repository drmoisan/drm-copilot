# Code Review: Issue #794

- Scope: `git diff origin/main...HEAD`, production change in `.claude/lib/bash/parallel-cohorts.sh` (+ identical mirror) and tests in `tests/shell/parallel_cohorts.bats`.
- Blocking findings: 0

## Production code

### `pcoh_split_words` (lines 54-67)

- Correct: `${text//[$'\n\r\v\f']/ }` converts LF, CR, VT, FF to spaces before `read -ra`, which then splits on default IFS (space, tab, newline). Combined separator set is space, tab, LF, CR, VT, FF. `read -ra` retains no-pathname-expansion; the test with `*` and `?` tokens confirms it.
- `local text="${1-}"` keeps the unset-argument default; the direct test calls `pcoh_split_words` with no argument and expects 0 elements.
- Whitespace-only and newline-only input yields an empty array; covered by tests.
- The tokenizing expression is identical to `parallel-lane-assertion.sh:88`, giving one rule across the library. Duplication of one expression is accepted by the spec (shared helper would touch more files).
- The comment block accurately explains the reason (single-record `read`) and states the ASCII equivalence to Python `str.split()`.

### `pcoh_build_adjacency` companion fix (lines 128-138)

- Necessary: `pc_contains_word` matches space-delimited words in the raw `keys` string, so after the tokenizer fix a multi-line `--keys` combined with `--edges` still produced a false "not a member" failure. The before/after reproductions in evidence demonstrate this.
- Implementation reassigns the `keys` parameter local to a rebuilt string ` k1 k2 ...`. Functionally correct and linear. Reuse of the parameter name for a different shape of value is a minor readability cost; the added comment explains it. Not blocking.
- Observation (non-blocking, low): other `pcoh_*` call sites that perform `pc_contains_word` against a raw caller string were not re-audited in the diff. The new library-level test covers `pcoh_compute_cohorts` and `pcoh_compute_concurrency_batches` with multi-line input, which exercises the paths reachable through the two entry scripts.

## Tests

- 15 rows, each prefixed `separator-parity:`; names state scenario and expectation.
- Helpers `cohorts_print` and `batches_print` assert both status and stdout with a diagnostic printed on mismatch. They are bash-quote-safe and avoid fixtures.
- Edge-asserting row "honors an edge after the first newline" includes an edge-omitted control (`1:2` alone yields `[[1,3],[2]]`), proving the edge changes the result.
- The malformed-token row uses a `case` match on `found: 02` to assert the diagnostic and exit 2 for `--keys` and `--edges` and batching.
- Nit (non-blocking): the `$'\v\f'` whitespace-only case relies on both VT and FF being converted; this is covered, and no gap exists.
- Nit (non-blocking): the library-level row combines several `pcoh_split_words` assertions in one `@test`; splitting would improve failure localization but is not required by policy.

## Verification performed

- `shellcheck -x` and `shfmt -d` on the library: exit 0.
- `cmp` library vs mirror: identical.
- CI runs 37896730789 (failure, 15 `not ok`) and 37897674234 (success) confirmed with `gh run view`; head SHAs match evidence.
- Local bats execution was not possible (bats absent on the review host); behavior was verified through CI results and evidence.

## Verdict

No blocking defects. Two non-blocking observations recorded above.
