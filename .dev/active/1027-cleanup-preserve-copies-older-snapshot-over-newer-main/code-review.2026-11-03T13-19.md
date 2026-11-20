# Code Review: cleanup-merged-worktrees preserve staging decision (#1027)

**Review Date:** 2026-11-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027`
**Feature Folder Selection Rule:** named by the caller; matches the issue number (#1027) in the folder name, `issue.md`, and `spec.md`.
**Base Branch:** `main` (merge base `715241396b557ce198e44f5c4b606fbcd9082c3c`)
**Head Branch:** `bug/cleanup-preserve-older-snapshot-1027-r2` at `ca69ec5c5b030e76494ccdcbeaffa2f3cd74175e`
**Review Type:** Initial review

---

## Executive Summary

The branch replaces the unconditional whole-file copy in `cleanup-worktrees.sh --preserve` with a staging decision for targets that already exist on the consolidation branch. The reviewed diff is 215 paths: three production bash scripts (one new library of 234 lines, two modified), `SKILL.md`, their byte-identical bundle mirrors, one `core.json` entry, two new and three modified bats suites, the git stub, 16 new fixture scenarios, and feature-folder documentation and evidence. Evidence reviewed: the PR-context summary and appendix, the full source diff, the CI `cov.xml` of run 41640864723 (downloaded and read by the reviewer), the executor's QA and regression evidence, and a reviewer-run evidence-location scan and mirror `cmp`.

The implementation is cohesive and matches the spec's verdict table row for row. Each guard is a small pure helper, every refusal goes through one function that emits the full refusal contract, and the writing phase stays policy-free. Tests drive every verdict row, every base-unavailable cause, and both blob-read failures, and the fail-before and pass-after evidence demonstrates that the issue repro fails on the unchanged library and passes with the fix.

**What changed:**
`cleanup_worktrees_preserve_merge_lib.sh` adds `preserve_merge_split_lines`, `preserve_merge_is_subsequence` (G1, G2, guard (b)), `preserve_merge_extra_within` (G3), `preserve_merge_refuse`, `preserve_merge_check_duplicate`, `preserve_merge_resolve_base`, `preserve_merge_guard_b`, and `preserve_merge_decide`. `preserve_plan_one` calls the duplicate check and the decision after the `IGNORED-TARGET` check and before the index decision, and appends plan columns 9 (mode) and 10 (merged blob id). `preserve_commit_plan` writes `cat-file blob <oid>` output for `merge` entries and keeps the byte copy otherwise. The wrapper sources the new library and its `usage` text describes per-class staging and `REFUSED-WOULD-REGRESS`.

**Top 3 risks:**
1. An unreadable existing target is read as empty content, which lets guard (b) admit a whole-file copy for that record (Minor finding 1). The condition requires a regular file the operator cannot read, so the likelihood is low.
2. The runtime Git on hosts other than the operator host is unverified for `merge-file --object-id` (Git 2.43 or later). The failure mode is fail-closed (`REFUSED-WOULD-REGRESS`), so the risk is reduced consolidation, not data loss. The spec already lists the follow-up.
3. A merged file is written to the working tree as the normalized blob, bypassing smudge and end-of-line conversion (Nit finding 2). Staged content is correct; only the working-tree line endings of that one file can differ on `core.autocrlf=true` hosts.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; the remaining findings are Minor or Nit and do not affect the acceptance criteria.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_merge_lib.sh` | `preserve_merge_decide`, line 201 (`main_c=$(<"$cwt/$tgt")`) | A read failure on an existing regular target (for example, permission denied) leaves `main_c` empty and is not checked. `preserve_plan_one` runs inside `preserve_plan_one "$line" \|\| PRESERVE_EXIT=1`, so `set -e` is suspended and execution continues. For an `untracked` record, or a `modified` record with no base, guard (b) then sees an empty needle and returns `copy`, so the target would be overwritten. The `modified` merge path is not affected because `hash-object -w` on the same file would also fail and refuse. | Check the read status and refuse on failure, for example `main_c=$(<"$cwt/$tgt") \|\| { preserve_merge_refuse "$tgt" "guard-b: the target could not be read"; return 1; }`, and add one bats test that redefines the read through a non-readable path or an injected failure. | The library's stated design is fail-closed; this is the one input-read path that fails open. The trigger (an unreadable regular file in the operator's own consolidation worktree) is uncommon, so severity is Minor. | Source inspection of lines 197-206; wrapper `set -euo pipefail` at line 7; call site `cleanup_worktrees_preserve_lib.sh` line 365. |
| Nit | `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh` | `preserve_commit_plan`, merge branch (`cleanup_wt_git -C "$PRESERVE_CWT" cat-file blob "$oid" >"$dstfile"`) | The merged blob is written to the working tree in its normalized (LF) form, without smudge or end-of-line conversion. On a `core.autocrlf=true` checkout the merged file's working-tree line endings differ from the rest of the tree until the next checkout. The staged content is correct. | Consider `cat-file --filters --path="$tgt" "$oid"` (Git 2.11 or later) so the working-tree copy follows the same conversion as a checkout. | Keeps the working tree consistent with checkout semantics; no effect on the committed content. | Source inspection; `SKILL.md` already states that staging re-normalizes tracked text. |
| Nit | `tests/shell/test_cleanup_worktrees_preserve_merge.bats` | CRLF tests | CRLF and unterminated-line tolerance are exercised at the helper level (`preserve_merge_is_subsequence`) only; no scenario drives `preserve_merge_decide` with a CRLF target against an LF blob. | Optionally add one plan-level scenario with inline CRLF main content (the `cleanup_wt_git` redefinition pattern used by the read-failure tests avoids a fixture). | The acceptance criterion is satisfied as written; an end-to-end case would guard the integration of the helper with the `$(<file)` and `cat-file` reads. | Test file lines 132-150. |
| Info | `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh` | whole file | The file is at exactly 500 logical lines (baseline 492), the guidance-tier boundary. No gate applies; the next addition will cross the guidance tier. | When this library next changes, look for a logical split. | Forward-looking maintenance note. | `awk 'END{print NR}'` at head: 500. |
| Info | `docs/features/active/2026-10-30-cleanup-preserve-copies-older-snapshot-over-newer-main-1027/spec.md` | header | `Status: Draft` and `Last Updated: 2026-10-30T20-58` were not updated after delivery. | Update at PR or archive time if the lifecycle tooling expects it. | Document metadata only. | `spec.md` lines 6-7. |

No Blockers or Major findings. No covered file is at or above 700 logical lines, so no file-size Warning row applies.

---

## Implementation Audit

### Bash implementation audit

#### What changed well

- The decision is isolated in a new library, which kept `cleanup_worktrees_preserve_lib.sh` at 500 lines and left phase 2 policy-free.
- The absent-target path is a pure `-f` test with no git call, so existing behavior and argv logs for absent targets are unchanged; a test asserts the absence of `merge-file`, `hash-object`, `merge-base`, and `rev-parse`.
- G1 runs before any object is written, so a G1 refusal writes no blob (asserted by test).
- `preserve_merge_resolve_base` short-circuits on `source_path != target_path` without a git call and treats empty git output as unavailable.
- No git call passes `-f` or `--force`, and no process substitution is passed to git as a file argument (the only process substitution feeds bash's own `read` loop).
- The carriage-return variable and the `k` key prefix for associative arrays are explained in comments; both address real bash pitfalls (ANSI-C quoting inside expansions, empty subscripts).

#### API and safety notes

- Plan columns are appended after column 8, and `${PRESERVE_FIELDS[8]-}` defaults keep eight-column entries working; the failures suite still drives the eight-column helper.
- The duplicate-target set is newline-delimited and reset per pass in `preserve_plan`; a target counts as seen when a record reaches the check, which the function comment states.
- Three SC2034 suppressions are scoped to one line or one function and state the cross-file reason.

#### Error handling and logging

- Every refusal emits `ACTION|preserve-stage|<tgt>|REFUSED-WOULD-REGRESS`, a `cleanup-worktrees: refused <tgt>: <reason>` stderr line whose reason begins with the guard token, and sets `PRESERVE_EXIT=1`.
- `merge-file` failures report the exit code (`merge-file rc=<n>`), and empty `main_oid`, `wt_oid`, or `merged_oid` values also refuse.
- A successful merge writes `cleanup-worktrees: merged <tgt>` to stderr; no new stdout record type is introduced.
- The one unchecked read is described in Minor finding 1.

---

## Test Quality Audit

The new suites drive each verdict-table row of the spec, each of the four base-unavailable causes, the duplicate-target case, both blob-read failures, and both writing-phase merge outcomes. All git interaction goes through the recording stub, merge scenarios drive the read-only planning phase only, and writing-phase tests target `/dev/null`, so no checked-in fixture is written and no temporary file is created.

### Reviewed test and QA artifacts

- `tests/shell/test_cleanup_worktrees_preserve_merge.bats` — helpers, the issue repro, merge outcomes, G1/G2/G3 and merge-error refusals, absent-target negative control, blob-read failures. Assertions cover stdout, stderr reason, `PRESERVE_EXIT`, plan-stream length, and plan columns 9 and 10.
- `tests/shell/test_cleanup_worktrees_preserve_merge_fallback.bats` — stub key forms (including non-zero exit replay), four base-unavailable causes, untracked existing target, duplicate target.
- `tests/shell/test_cleanup_worktrees_preserve_failures.bats` — merge-mode write through `cat-file` with a non-existent source (proves the content came from the blob) and the `FAILED` path with no `add` call.
- `tests/fixtures/cleanup_worktrees/stub-bin/git` — four new key forms; header no longer cites production line numbers (`grep -c -E '_lib[.]sh:[0-9]'` prints 0) or states that no `-w` behavior exists (`grep -c -F 'defines no -w'` prints 0), re-run by the reviewer.
- `evidence/regression-testing/fail-before-repro.2026-11-03T12-35.md` — the repro fails on the unchanged library with `plan entry columns: 8, mode: ''`.
- `evidence/regression-testing/pass-after-repro.2026-11-03T12-41.md` — 116 of 116 preserve-area tests pass after the fix.
- `evidence/regression-testing/bats-order-isolation.2026-11-03T13-03.md` — forward and reversed suite order, 71 of 71 each.
- `evidence/qa-gates/shell-coverage.2026-11-03T13-12.md` and CI run 41640864723 `cov.xml` — 95.3% aggregate, 99.0% on the new library; reviewer confirmed no changed executable line is unexecuted.

### Quality assessment prompts

- **Determinism:** canned stub responses keyed by sanitized operands; no clock, randomness, real git, or real jq.
- **Isolation:** one verdict row or cause per test; the `cleanup_wt_git` redefinition is confined to the test process.
- **Speed:** stub-only execution; CI full shell suite of 761 tests passed in the same job as baseline.
- **Diagnostics:** the merge-entry helper echoes the column count and mode on failure; refusal assertions match the exact reason token.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | No credentials or host paths in the diff; fixture worktree paths are repo-relative and the stub keys use only the final `-C` component. |
| No unsafe subprocess or command construction | PASS | All git calls are argv lists through `cleanup_wt_git`; no `eval`; no forced git operation. |
| Input validation at boundaries | PASS | Records still pass `preserve_validate_record`, `MISSING-SOURCE`, host-token, and `IGNORED-TARGET` checks before the decision. |
| Error handling remains explicit | PARTIAL | Every guard and git failure refuses explicitly; the unchecked target read in Minor finding 1 is the exception. |
| Configuration / path handling is safe | PASS | Seams unchanged (`CLEANUP_WT_GIT_BIN`, `CLEANUP_WT_JQ_BIN`, `CLEANUP_WT_CONSOLIDATION_PATH`, `CLEANUP_WT_MANIFEST_PATH`); `hash-object -w --path=<tgt>` applies the target's attributes. |
| Bundle mirror parity | PASS | Reviewer `cmp` of the four source/mirror pairs: identical; `core.json` lists the new library in sorted position. |
| Coverage exclusion policy | PASS | No coverage `exclude` entry was added for a production path. |

---

## Research Log

No external research was required for this review. Git behavior relied on (`merge-file --object-id` from Git 2.43, `--union` semantics, `hash-object --path`) is documented in the feature's `research/2026-10-30T21-30-preserve-modified-merge-research.md` and the spec's dependencies section.

---

## Verdict

The change is ready for the normal PR flow. The implementation fixes the issue's silent data loss with a fail-closed design, the tests cover every specified outcome, coverage is 99.0% on the new library with no regression elsewhere, and the bundle mirrors are identical. The Minor finding (an unchecked target read that fails open under guard (b)) and the two Nits are non-blocking improvements; the Minor finding is small enough to address in a remediation cycle within this item if the orchestrator chooses, but it does not violate any acceptance criterion or policy gate.
