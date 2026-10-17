# Code Review: Issue #890 (parallel skills Python engine calls and enum error members)

- Timestamp: 2026-10-12T20-40
- Branch: `bug/parallel-skills-python-engine-calls-and-enum-error-members-890`
- Head: 05d4cc0d5
- Scope: `git diff origin/main...HEAD`
- Overall verdict: **PASS** (0 Blocking, 5 Non-blocking); bats execution and kcov rates are CI-pending

## Executive Summary

The change ports six Python engine calls in three skills to a new destination-portable bash entry point, splits shared option parsing out of `remove-parallel-item.sh`, and makes `UnknownEnumMemberError` list the members of the rejected field. The design is small and consistent with the existing `remove-parallel-item.sh` pattern.

Correctness checks performed (no defect found):

- Validation order in `pm_build_add_entry`, `pm_build_close_entry`, `pm_build_requeue_entry` (generation first, then item key) matches `MutationEntry` and the corpus.
- Deferred add and requeue stamp `g + 1`; `--generation -1` with `--deferred true` yields 0 (fixture `add-entry-deferred-generation-minus-one`).
- `pm_decide_close` validates tokens in supplied order, rejects non-positive keys with the `UnknownItemError` text and out-of-enum states with the item-state list, and lists every in-flight key ascending with Python list rendering.
- `mpr_close` rejects duplicate keys before the library runs (declared divergence 1) so a later record cannot silently replace an earlier one.
- `pmcli_emit` / `mpr_main` preserve the exit contract (0 stdout JSON, 1 one stderr line, 2 usage error).
- `remove-parallel-item.sh` now delegates option parsing to `parallel-mutation-cli.sh`; subcommand option lists, validation order, and the disposition usage error are unchanged. The `at` timestamp is read only when `--at` is omitted.
- `pm_entry_contract_message` gained an optional third argument defaulting to `remove`; existing call sites are unchanged.
- `_parallel_mutation_errors.py`: `_ENUM_MEMBERS_BY_FIELD` insertion order drives the unmapped-field message; docstrings updated; all three live raise sites use mapped fields.
- Skill text: each `bash` fence starts with `bash .claude/lib/bash/mutate-parallel-run.sh <subcommand>` so `skill_bundle_contract` extracts it and the persona grant glob matches. `--generation` for add-entry is documented as read before any step-5 recolor, which matches `build_add_entry(current_generation=g)`.
- Test quality: Python tests follow Arrange-Act-Assert with message-bearing assertions; the errors test asserts `type(...) is ValueError` to exclude the subclass; the corpus lane has a floor and exact stem-set test so it cannot pass vacuously.

No blocking code-quality finding. Bats execution and kcov rates are not reviewable locally and are carried as CI-pending in the policy audit.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking (NB-1) | `tests/shell/parallel_mutation_run_parity.bats` | lines 74-103 | All 21 fixtures run inside one `@test`. A failure names the fixture on stderr only. | No action required. Splitting per fixture would need generated test names, which bats does not support cleanly. | The existing remove-parity suite uses the same shape. | Reviewer read of the file |
| Non-blocking (NB-2) | `.claude/lib/bash/parallel-mutation-cli.sh` | line 93 | `$(($1))` wraps silently on integers above 2^63-1; Python would accept them. | Optionally add a length cap to the `^-?(0\|[1-9][0-9]*)$` check. | Practical impact is nil for issue numbers and generations. | Reviewer read of the file |
| Non-blocking (NB-3) | `tests/shell/parallel_mutation_run_parity.bats` | lines 48-50 | The harness uses `python3 -c` with `eval` on a fixture-derived expression. | No action required. | Inputs are checked-in literals; the file states the interpreter is a harness dependency only; the pattern is inherited from the remove-parity suite. | Reviewer read of the file |
| Non-blocking (NB-4) | `.claude/lib/bash/mutate-parallel-run.sh` | lines 62-166 | The `mpr_*` functions repeat the `pmcli_integer`-then-copy pattern (two lines per option). | Acceptable as written. | Folding into a helper would shorten the file but obscure the `\|\| rc=$?` flow. | Reviewer read of the file |
| Non-blocking (NB-5) | `.claude/lib/bash/parallel-mutation-ops.sh` | lines 54-76 | `pm_decide_admission` builds the blocking set as a space-delimited string and matches with glob patterns; a direct library caller passing non-canonical integers (for example `007`) would not match. | No action required. | Correct because every key is canonicalized by the entry point before the call; documented in the file contract ("expected in canonical decimal form"). | Reviewer read of the file |

Blocking findings: 0. Non-blocking findings: 5.

## Verdict

**PASS** for code quality. No blocking code-quality findings. Bats execution and kcov rates are not reviewable locally and are carried as CI-pending in `policy-audit.2026-10-12T20-40.md`. No remediation inputs are required.
