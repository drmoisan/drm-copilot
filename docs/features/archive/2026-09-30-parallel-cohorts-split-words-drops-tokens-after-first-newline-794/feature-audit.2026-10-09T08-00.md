# Feature Audit: Issue #794

- Work mode: full-bug; AC source: `spec.md` (13 criteria; `user-story.md` not applicable)
- Baseline: `origin/main` (merge base e7d3779b)
- Plan: `plan.2026-10-08T17-25.md` (61 checked items, 0 unchecked)
- Blocking findings (FAIL + blocking PARTIAL): 0

## AC Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | Bats rows "newline-separated --keys" and "batching --keys" compare `$'1\n2\n3'` with `"1 2 3"` for both entry scripts; pass in CI run 37897674234, fail in 37896730789. |
| AC-2 | PASS | Row "--edges honors an edge after the first newline" includes control without the edge (`[[1,3],[2]]`) versus with it (`[[2],[1,3]]`). Requires the companion `pcoh_build_adjacency` fix for combined input; present in tree. |
| AC-3 | PASS | Rows for tab, CR, VT, FF (keys, edges, both, batching) and CRLF-terminated final token. |
| AC-4 | PASS | Mixed-separator row and whitespace/newline-only row (five values, both scripts) expecting `[]`. |
| AC-5 | PASS | Malformed-token row: exit 2 for `$'1\n02'`, `$'1:2\n2-3'`, `$'1:2\n2:03'`, and batching. |
| AC-6 | PASS | Row "pcoh_split_words splits on every ASCII whitespace separator" asserts count 7 and each element, plus empty, glob, and unset-argument cases. |
| AC-7 | PASS | Comment block (lines 54-66) verified in tree: "whitespace-separated", LF/CR/VT/FF conversion, Python `str.split()` equivalence. |
| AC-8 | PASS | `cmp` identical in this review. The membership bats suite is part of the full CI test step that concluded success on run 37897674234. |
| AC-9 | PASS | `regression-testing/ci-fail-first-*`: run 37896730789 failure with exactly 15 `separator-parity:` `not ok` lines, check step success; pass run 37897674234 on head 5cbd8485. Confirmed via `gh run view`. |
| AC-10 | PASS | CI check step success; `shellcheck`/`shfmt` exit 0 locally; no added suppressions; CI test step success includes parity and payload-only suites. Local bats absent and declared non-evidence. |
| AC-11 | PASS | kcov: total 94.2%, `parallel-cohorts.sh` 99.3% (baseline 99.3%); changed lines 67 and 138 hit once each. |
| AC-12 | PASS | `git diff --name-only origin/main...HEAD` lists neither `parallel-items-validate.sh` nor `parallel-lane-assertion.sh` nor mirrors. |
| AC-13 | PASS | Files 340/340/350 lines; no temp-file tokens; no new fixtures (diff has no `tests/fixtures` entries). |

## Scope and Baseline Findings

1. Added change outside declared scope (non-blocking, documented): the `pcoh_build_adjacency` companion fix extends beyond spec Requirements 1-3. `evidence/other/spec-gap-note` justifies it and records orchestrator acceptance; `spec.md` was not amended. Recommendation: note the companion change in the PR description.
2. Behavior change accepted per spec decision 7: tokens after a newline are now validated (exit 2 for malformed).
3. Promoted lifecycle record `docs/features/potential/promoted/2026-09-30-...-newline.md` is present in the diff, consistent with the promotion workflow.
4. No undeclared production file changes: the production diff is two identical copies of one file.

## Acceptance Criteria Status

- Source: `docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/spec.md`
- Total AC items: 13
- Checked off (delivered): 13 (all already checked; reviewer concurs, no changes made)
- Remaining (unchecked): 0
- Items remaining: none

## Result

All 13 acceptance criteria are satisfied relative to baseline. No remediation required; no `remediation-inputs` artifact produced.
