# Spec: pcoh_split_words drops tokens after the first newline (Issue #794)

- Issue: #794
- Work Mode: full-bug
- Related: #609 (closed, fixed by PR #815)
- Research: `research/research.2026-10-08T21-30.md`

## Problem Statement

`pcoh_split_words` in `.claude/lib/bash/parallel-cohorts.sh` populates `PCOH_WORDS` with `read -ra PCOH_WORDS <<<"${1-}"`. `read` consumes a single newline-terminated record, so every token after the first newline in a `--keys` or `--edges` value is dropped without a diagnostic. The tokens are also never validated, because validation runs through the same function.

Reproduction on main:

- `sh .claude/lib/bash/compute-cohorts.sh --keys "1 2"` prints `[[1,2]]`.
- `sh .claude/lib/bash/compute-cohorts.sh --keys "$(printf '1\n2')"` prints `[[1]]`.

A multi-line `--edges` value silently omits conflict edges, which can place conflicting items in the same cohort. Callers that pass single-line, space-separated values are unaffected.

## Scope

In scope:

- `pcoh_split_words` in `.claude/lib/bash/parallel-cohorts.sh` and its comment block.
- The byte-identical bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-cohorts.sh`.
- Regression rows in `tests/shell/parallel_cohorts.bats`.

All user-reachable call sites reach `pcoh_split_words` through `compute-cohorts.sh` (`--keys`, `--edges`) and `compute-concurrency-batches.sh` (`--keys`), then through the library call sites at `parallel-cohorts.sh` lines 82, 124, 133, 169, 223, and 297. Line 181 receives an internally built single-space-joined value. A fix inside `pcoh_split_words` therefore covers every site.

Out of scope:

- `.claude/lib/bash/parallel-lane-assertion.sh` (already fixed by #609; no change).
- `.claude/lib/bash/parallel-items-validate.sh` lines 71 and 238. Their inputs are single-line constants: `PC_BLAST_RADIUS_LIST_FIELDS` (`parallel-common.sh`) and `PM_TOP_LEVEL_PROHIBITED_KEYS="integration_branch"` (`parallel-manifest-validate.sh:53`).
- `compute-cohorts.sh`, `compute-concurrency-batches.sh`, `core.json`, and the parity corpus under `tests/fixtures/parallel_cohorts/`.

## Assumptions and Decisions

1. The statement in `issue.md` that #609 is still open is stale. #609 is closed, fixed by PR #815 (merge commit 28443d3b). That fix tokenizes with `read -ra tokens <<<"${text//[$'\n\r\v\f']/ }"` at `.claude/lib/bash/parallel-lane-assertion.sh:88`.
2. Decision: #794 adopts the same inline expression in `pcoh_split_words`, so the library has one tokenizing rule. The "coordinate with #609" item in the issue is satisfied by adopting the rule #609 chose. No shared helper is introduced, because `parallel-lane-assertion.sh` may not be sourced by other library files (guard in `tests/shell/parallel_lane_assertion.bats`) and a helper in `parallel-common.sh` would touch additional files and mirrors.
3. Decision: `read -d ''` is rejected. With a here-string it returns non-zero at EOF, which aborts entry points running under `set -euo pipefail`, and it does not split on CR, VT, or FF.
4. Decision: the separator set after the fix is space, tab, LF, CR, VT, and FF (ASCII whitespace). Other Unicode whitespace is not treated as a separator, consistent with the divergence declared in #609.
5. Assumption: `scripts/dev_tools/parallel_cohort_computation.py` takes typed lists and has no string tokenizer. The reference for a multi-line input is therefore list equivalence: the output for a multi-line value must equal the output for the same tokens supplied space-separated. The issue text that the Python authority "splits on any whitespace" applies to the lane-assertion module, not the cohort module.
6. Assumption: empty and whitespace-only input (including newline-only input) continues to yield an empty array, preserving the empty-graph case.
7. Behavior change accepted: tokens after a newline become subject to the existing integer-lexis validation, so a malformed token after a newline now exits 2 instead of being ignored.
8. Assumption: no operator questions are possible; the decisions above were taken from the research record and orchestrator resolutions. The merge commit SHA 28443d3b was supplied by the orchestrator and is recorded as given.
9. Assumption: if `bash`, `bats`, or `wsl` are unavailable in the local session, fail-before and pass evidence is obtained from the `shell-coverage` CI job (as #609 did with a throwaway branch) or from a local `sh` run.
10. No acceptance criterion in this spec asserts a numeric count of files, call sites, or fixtures, so Numeric Derivation Evidence is not required. The call-site and fixture figures above are context only.

## Requirements

1. `pcoh_split_words` must assign `local text="${1-}"` and tokenize with `read -ra PCOH_WORDS <<<"${text//[$'\n\r\v\f']/ }"`, keeping `read -ra` so tokens are never pathname-expanded and keeping the unset-argument default.
2. The comment block above `pcoh_split_words` must state that newline, CR, VT, and FF are converted to spaces first because `read` consumes one record, and that the resulting separator set matches Python `str.split()` for ASCII. The function description must say "whitespace-separated" rather than "space-separated".
3. The bundled mirror must be copied byte for byte from the repository file.
4. Regression tests must be added to `tests/shell/parallel_cohorts.bats` in the #609 style. Each new row pairs a multi-line input with its single-line control for both `compute-cohorts.sh` and `compute-concurrency-batches.sh`, using `$'...'` literals, no fixtures, and no temporary files.

## Acceptance Criteria

- [x] AC-1: `compute-cohorts.sh --keys` with a newline-separated value (for example `$'1\n2'`) reports all keys and produces output equal to the single-line control `"1 2"` (`[[1,2]]`); the same holds for `compute-concurrency-batches.sh --keys`.
- [x] AC-2: `compute-cohorts.sh --edges` with a newline-separated value honors every edge and produces output equal to the same edges supplied space-separated, including a case where an edge after the first newline changes the cohort assignment relative to omitting that edge.
- [x] AC-3: Tab-, CR-, VT-, and FF-separated `--keys` and `--edges` values each produce output equal to their single-line controls, and a CRLF-terminated final token is kept.
- [x] AC-4: A mixed-separator value with a trailing newline, and a whitespace-only or newline-only value, behave as specified: the former equals its single-line control and the latter yields the empty-graph result.
- [x] AC-5: A malformed token placed after a newline in `--keys` or `--edges` is validated and causes exit status 2, where it was previously ignored.
- [x] AC-6: A library-level test sources `parallel-cohorts.sh`, calls `pcoh_split_words` directly with a multi-separator value, and asserts the element count and each element of `PCOH_WORDS`.
- [x] AC-7: The comment block above `pcoh_split_words` states the newline, CR, VT, and FF handling and the ASCII separator-set equivalence to Python `str.split()`, and describes the input as whitespace-separated.
- [x] AC-8: `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-cohorts.sh` is byte-identical to `.claude/lib/bash/parallel-cohorts.sh`, and `tests/shell/parallel_bash_manifest_membership.bats` passes.
- [x] AC-9: Fail-before evidence is recorded under `<FEATURE>/evidence/` in the canonical evidence location, showing the new bats rows fail against the unfixed library (CI run or local `sh` run), followed by pass evidence after the fix.
- [x] AC-10: `bash scripts/bash/shell-qc.sh check` (shfmt, shellcheck) passes with no new suppressions, and the full bats suite passes, including `parallel_cohorts_parity.bats` and `parallel_payload_only.bats`.
- [x] AC-11: `bash scripts/bash/shell-qc.sh test --coverage` reports kcov line coverage of at least 85% on the changed bash file, and the changed line in `parallel-cohorts.sh` is executed by at least one test. No branch-coverage gate applies to bash.
- [x] AC-12: `.claude/lib/bash/parallel-items-validate.sh` and `.claude/lib/bash/parallel-lane-assertion.sh` (and their bundled mirrors) are unchanged by this work.
- [x] AC-13: No file touched by this work exceeds 500 lines, and no temporary file or new fixture is created by the new tests.

## Verification Plan

1. Add the bats rows first and run them against the unfixed library to capture fail-before evidence (AC-9).
2. Apply the `pcoh_split_words` change and comment update, then copy the file to the bundled mirror (AC-7, AC-8).
3. Run `bash scripts/bash/shell-qc.sh format`, `check`, and `test --coverage`; repeat until a single pass is clean (AC-10, AC-11).
4. Confirm with `git diff --stat` that only `parallel-cohorts.sh`, its mirror, `tests/shell/parallel_cohorts.bats`, and feature documentation changed (AC-12, AC-13).
