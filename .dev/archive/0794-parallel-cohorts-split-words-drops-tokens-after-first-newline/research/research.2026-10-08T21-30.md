# Research: pcoh_split_words drops tokens after the first newline (Issue #794)

- Date: 2026-10-08
- Scope: read-only investigation against the current tree of this worktree.
- Tool limitation: the Bash tool was disabled in this session, so no `git log`, `git show`, or `bats` command could be run. Findings come from Read, Grep, and Glob only. Where git evidence would be needed (the merge SHA of the #609 fix), the gap is stated explicitly.

## 1. Current state of `pcoh_split_words`

File: `.claude/lib/bash/parallel-cohorts.sh` (330 lines). Current text, lines 51-63:

```
# Scratch array populated by pcoh_split_words.
PCOH_WORDS=()

pcoh_split_words() {
	# Populate PCOH_WORDS by splitting a space-separated string.
	#
	# Args: $1 = the string to split. An empty or whitespace-only string yields
	# an empty array, which is the empty-graph and empty-cohort case. `read -ra`
	# is used rather than an unquoted expansion so a token is never subjected to
	# pathname expansion.
	PCOH_WORDS=()
	read -ra PCOH_WORDS <<<"${1-}"
}
```

The comment block is lines 55-60; the `read` is line 62. The comment mentions pathname expansion only; it does not mention newlines. The issue's line citations (62, comment 54-60) are accurate to within one line (comment is 55-60).

Mechanism: `read` consumes one newline-terminated record, then splits it on IFS (space, tab, newline). Everything after the first newline is never read. `-d ''` alone would also not address CR, VT, FF, which Python `str.split()` treats as whitespace.

### Callers

All call sites of `pcoh_split_words` (Grep, repository `.claude/lib/bash`):

| Site | Function / context | Can a multi-line value reach it? |
|---|---|---|
| `compute-cohorts.sh:71` | `cc_validate_tokens`, `--keys` value | Yes. `keys="$2"` straight from the CLI argument (compute-cohorts.sh:101). |
| `compute-cohorts.sh:77` | `cc_validate_tokens`, `--edges` value | Yes. Same path from `--edges`. |
| `compute-concurrency-batches.sh:102` | `cb_main`, `--keys` value | Yes. `keys="$2"` from the CLI (line 74). |
| `parallel-cohorts.sh:82` | `pcoh_validate_item_keys "$1"` | Yes. Receives the raw `$keys` forwarded by `pcoh_compute_cohorts` (line 269) from `compute-cohorts.sh:129`. |
| `parallel-cohorts.sh:124` | `pcoh_build_adjacency`, keys | Yes. Raw `$keys` forwarded (line 270). |
| `parallel-cohorts.sh:133` | `pcoh_build_adjacency`, `${2-}` edges | Yes. Raw `$edges` forwarded (line 270). |
| `parallel-cohorts.sh:169` | `pcoh_welsh_powell_order "$1"` | Yes. Raw `$keys` forwarded (line 271 -> 206). |
| `parallel-cohorts.sh:181` | `pcoh_lowest_free_index`, `PCOH_NEIGHBORS[$key]` | No. The value is built internally at lines 108-109 by single-space concatenation of already-split tokens. |
| `parallel-cohorts.sh:223` | `pcoh_render_cohorts "$1"` | Yes. Raw `$keys` forwarded (line 272). |
| `parallel-cohorts.sh:297` | `pcoh_compute_concurrency_batches "$1"` | Yes. Raw `$keys` forwarded from `compute-concurrency-batches.sh:108`. |

Consequence: every user-reachable site funnels through `pcoh_split_words`. A fix inside that one function covers all nine reachable sites and the one internal site. The entry points call it twice (validation, then via the library), so both passes must agree; a single-function fix guarantees that.

Line-based consumers (`done <<<"$ordered"` at parallel-cohorts.sh:213, 249, 305; `while IFS= read -r key` at 210, 241, 302) read internally generated, newline-delimited lists from `sort`. They are correct and unaffected.

Failure behavior to be aware of: because `compute-cohorts.sh` validates tokens before computing, a multi-line `--keys "1\n2"` is validated on `1` only and the dropped `2` is never validated either. With the fix, tokens after the newline become subject to the existing integer-lexis check (exit 2 on a bad token), which is a behavior change for malformed multi-line input and is the intended consequence.

## 2. The #609 fix

- Issue #609 feature folder: `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/`.
- Delivery: PR #815, head branch `bug/bash-lane-assertion-newline-edges-divergence-609` (`code-review.2026-10-02T04-20.md:10`), local HEAD `c9f006ad5f1fb3eea4233895bb9bd722e18535a5`. Fail-first CI commit `1524e2d2` on branch `tmp/609-fail-first` (`evidence/regression-testing/bats-unit-before.2026-10-02T03-53.md`). The merge-commit SHA was not retrievable without git; confirm with `git log --oneline --grep=609` or `git log -S"\\v\\f" -- .claude/lib/bash/parallel-lane-assertion.sh` at implementation time.
- The issue.md statement that #609 is "still open" with `read -ra tokens <<<"$text"` at line 86 is stale. On the current tree the line is `.claude/lib/bash/parallel-lane-assertion.sh:88`:

  ```
  read -ra tokens <<<"${text//[$'\n\r\v\f']/ }"
  ```

  with the comment at lines 84-87 explaining that newline, CR, VT, and FF become spaces first because `read` consumes one record and splits on IFS only, so the Python `str.split()` whitespace set would otherwise differ.
- Tokenizing rule chosen by #609: replace `\n`, `\r`, `\v`, `\f` with a space by parameter expansion, then `read -ra`. Space and tab are already IFS characters, so the resulting separator set equals Python `str.split()` for ASCII (space, tab, LF, CR, VT, FF). This keeps the `read -ra` idiom, so a glob-bearing token is never pathname-expanded (spec line 60 of the #609 spec).
- Scope chosen by #609: only `pla_parse_edges` (line 88). Its spec states line 86 was the only `read -ra` taking operator-supplied text (#609 spec line 49) and recorded `pcoh_split_words` as Follow-up 1 (spec lines 41, 157). The remaining `read -ra` sites in `parallel-lane-assertion.sh` (lines 112, 213, 240, 251, 289, 320, 344, 371, 398, 404, 435, 441, 450, 456) read internally built space-joined lists and were left unchanged.
- Shared helper: none exists. `parallel-common.sh` defines `pc_enforce_c_locale`, `pc_errors_*`, `pc_repr*`, `pc_is_*`, `pc_contains_word`, `pc_enum_*` (function list at lines 54-232) and no tokenizer. `parallel-cohorts.sh` sources `parallel-common.sh` (line 31) but not `parallel-lane-assertion.sh`, and a #609-era test (`tests/shell/parallel_lane_assertion.bats:468-489`, "no library file sources the diagnostic") forbids any other library file from sourcing `parallel-lane-assertion.sh`. So reuse by sourcing is not permitted.
- Recommendation: apply the identical inline expression in `pcoh_split_words` (`read -ra PCOH_WORDS <<<"${1//[$'\n\r\v\f']/ }"`, using `${1-}` to preserve the unset-safe default). A new shared helper in `parallel-common.sh` is an alternative but would touch a third file plus its mirror and would force a second edit to the just-merged #609 site to be coherent; the inline form achieves "one tokenizing rule" (one expression, two sites) with minimal blast radius. Note `${1-}` inside a pattern substitution: write it as `local text="${1-}"` first, then `"${text//[$'\n\r\v\f']/ }"`, which matches the #609 style at lines 81 and 88 and avoids `set -u` pitfalls with nested defaults.
- Rejected alternative: `read -d '' -ra`. With a here-string it returns non-zero at EOF, which aborts the entry points that run under `set -euo pipefail` (compute-cohorts.sh:26, compute-concurrency-batches.sh:24) unless every call is guarded, and it still does not split on CR, VT, FF.

## 3. `parallel-items-validate.sh` sites

- Line 71: `read -ra radius_fields <<<"$PC_BLAST_RADIUS_LIST_FIELDS"`. `PC_BLAST_RADIUS_LIST_FIELDS="paths modules shared_surfaces contracts"` is a constant at `parallel-common.sh:46` (only definition per Grep). It cannot contain a newline.
- Line 238: `read -ra top_key_list <<<"$top_keys"`. `top_keys` is argument `$3` of `pi_scan_prohibited_keys` (line 222). The only caller is `parallel-manifest-validate.sh:264`, which passes `"$PM_TOP_LEVEL_PROHIBITED_KEYS"`, a module constant (not read in this research; the Grep shows only the call site). I did not open the constant's definition, so "constant, single-line" is an inference from its naming and from there being a single call site that passes no operator data.
- Recommendation: out of scope. Neither input is operator-supplied. Include them only if the plan wants a blanket rule; changing them adds mirror churn for no behavior change. Record them as intentionally unchanged in the spec.

## 4. Python authority and parity tests

- Module: `scripts/dev_tools/parallel_cohort_computation.py` (`compute_cohorts` at line 350, `compute_concurrency_batches` at line 419). It takes typed `Iterable[int]` and tuple edges. Grep found no `argparse`, `__main__`, `sys.argv`, or `.split` in it. The Python cohort module therefore has no string tokenizer at all. The issue statement "the Python authority splits on any whitespace" is true only for the lane-assertion module (`scripts/dev_tools/parallel_lane_assertion.py:425`, `for token in edge_text.split():`). For #794 the authority is the list-valued API: the correct bash result for a newline-separated string is the result for the same items supplied as a list.
- Parity corpus: `tests/fixtures/parallel_cohorts/*.json` (32 files; Glob listing). Consumed by two suites that pin the lanes together without cross-process execution:
  - Python: `tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py` (asserts the Python module reproduces each fixture).
  - Bash: `tests/shell/parallel_cohorts_parity.bats` (101 lines; test "the bash lane reproduces every cohort corpus fixture", line 68). It builds `--keys` and `--edges` with `" ".join(...)` (lines 76, 81-82), so the corpus never contains a non-space separator.
- Other Python tests touching the module: `test_parallel_cohort_computation.py`, `test_parallel_cohort_computation_errors.py`, `test_parallel_mergeable_cohort.py`, `test_parallel_mutation_cohort_invariant_binding.py`. None invoke the bash scripts.
- Python/Pester tests invoking these bash scripts: none found. All six test files mentioning the script names are bats (`parallel_cohorts.bats`, `parallel_cohorts_parity.bats`, `parallel_payload_only.bats`, `parallel_bash_manifest_membership.bats`, `parallel_lane_assertion.bats`, `parallel_lane_assertion_parity.bats`).
- No numeric acceptance criterion is proposed in this artifact, so no Numeric Derivation Evidence section is required. The 32-fixture figure above is context only and must not be copied into `spec.md` as an assertion without a separate two-method derivation.

## 5. Existing bats tests

| File | Lines | Role |
|---|---|---|
| `tests/shell/parallel_cohorts.bats` | 222 | Unit tests for the library and both entry points. `setup()` (lines 10-18) defines `COHORTS`, `BATCHES`, sources `parallel-cohorts.sh`, calls `pc_enforce_c_locale`. Cases use `run bash "$COHORTS" --keys "..." --edges "..."` then `[ "$status" -eq N ]` and `[ "$output" = "..." ]`. 4-space indentation in the bats file. Last case at line 217 exercises the sourced library. |
| `tests/shell/parallel_cohorts_parity.bats` | 101 | Corpus parity (above). |
| `tests/shell/parallel_items_validate.bats` | 187 | Items validator (not affected). |
| `tests/shell/parallel_bash_manifest_membership.bats` | 89 | Core manifest membership and byte-identical mirror guard. |
| `tests/shell/parallel_payload_only.bats` | not measured | Removes Python from PATH; invokes the entry points. |

How #609 tested the newline case (`tests/shell/parallel_lane_assertion.bats`):
- A file-scope pair of expected-header constants (`EDGES_MERGED_HEADER`, `EDGES_SPLIT_HEADER`, lines 431-432) and a helper `edges_header_is` (lines 434-442) that loops over values and also runs a single-line control (`101:202`) so the test cannot pass against an entry point that ignores the flag.
- Six cases, lines 444-466, with names of the form `edges-parity: a newline-separated value matches the single-line control`, `a tab-separated value ...`, `a CR-separated value ...`, `a CRLF-terminated final token is kept`, `newline-separated edges naming only undeclared vertices are skipped`, `mixed separators with a trailing newline match the single-line control`. Values are ANSI-C quoted literals such as `$'999:998\n101:202'`. No temporary file or new fixture was created for the bats rows; one JSON fixture was added elsewhere for the feature (policy-audit line 17).
- Fail-first evidence was obtained through a CI run on a throwaway branch because local bash was unavailable.

Proposed test shape for #794 (no test code written here): add rows to `tests/shell/parallel_cohorts.bats`, same style. Each pairs a multi-line input with the single-line control output compared in the same case, covering `compute-cohorts.sh` `--keys`, `--edges`, and `compute-concurrency-batches.sh` `--keys`, with separators LF, CR, VT, FF, CRLF-terminated final token, and a mixed-separator trailing-newline value, plus one case that shows a bad token after a newline now exits 2. Also one library-level case calling `pcoh_split_words` directly and asserting `${#PCOH_WORDS[@]}` and elements. Separator characters are written as `$'...'` literals; no fixture is required. Rows belong in `parallel_cohorts.bats`, which is 222 lines, so the 500-line cap leaves room.

## 6. Bundled mirrors

Exact mirror tree: `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/`. Mirror files for the files in play:
- `.../parallel-cohorts.sh` (contains the same `pcoh_split_words` at the same lines 51-62; Grep confirmed identical line numbers).
- `.../compute-cohorts.sh`, `.../compute-concurrency-batches.sh` (unchanged by the recommended fix).

Guard: `tests/shell/parallel_bash_manifest_membership.bats:56` ("every repository bash library file has a byte-identical bundled counterpart") compares with `cmp -s` for every `.claude/lib/bash/*.sh`. It also requires a `core.json` entry (`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lines 172-174 list all three cohort files) and rejects bundled-only files. Therefore the mirror must be edited to be byte-identical (manual copy; no sync script was found in this research, and #609 recorded `mirror-updated` as a manual step with the mirror listed as modified in the same change). `core.json` needs no change because no file is added. The push-down tests under `tests/scripts/dev_tools/test_push_down_claude_*.py` read the bundle but are not tied to this content.

Caveat from repository memory (not re-verified here): a repo-side `resources/` edit does not change what a push-down writes until the extension is rebuilt and reinstalled. This does not affect the in-repo mirror requirement.

## 7. Coverage and CI

- Local routes: `.claude/rules/shell.md` says run `bash scripts/bash/shell-qc.sh test` and `... test --coverage`; on Windows the toolchain runs under WSL. Agent sessions may have `bash`/`pwsh`/`wsl` text-denied; `sh <file>` is the fallback for running scripts and CI is the verification route for bats (as #609 did via `tmp/609-fail-first`).
- CI: `.github/workflows/ci.yml:26-27` calls `.github/workflows/_shell-coverage.yml`, job `shell-coverage` ("Shell Coverage (Bats + kcov)", `ubuntu-latest`). Steps: install `shellcheck` and `bats` via apt, shfmt 3.8.0 binary, kcov v43 built from source (cached); then `bash scripts/bash/shell-qc.sh check` (line 52) and `bash scripts/bash/shell-qc.sh test --coverage` (line 55); upload `artifacts/pester/kcov/**`.
- Coverage: kcov line coverage only, includes `.claude/lib/bash/`; threshold line >= 85%, no branch gate (`shell.md` lines 61-71). #609 baseline for the neighbouring file: 98.9% per file, 93.7% merged. The changed line must be executed by a test (the #609 audit checked `hits="1"` on the changed line in `cov.xml`).

## 8. Format and lint

- Format: `bash scripts/bash/shell-qc.sh format` (shfmt write mode); `check` runs `shfmt -d` over all discovered files first. shfmt default style, tab indentation (`shell.md` line 87). Applies to `.sh` files; the `.bats` files use 4-space indentation and are discovered only as test inputs (discovery of scripts is by `.sh` suffix or shebang; bats files with `#!/usr/bin/env bats` are not bash/sh shebangs).
- Lint: `bash scripts/bash/shell-qc.sh check` runs `shellcheck` once per file. File-level suppression precedent: `parallel-cohorts.sh:21` (`# shellcheck disable=SC2034`, justified inline at 22-24).
- Optional syntax check: `bash -n`.
- Config files: no `.shellcheckrc` or `.editorconfig` found at repo root (Glob). Behavior is driven by `scripts/bash/shell-qc.sh` and `scripts/bash/shell_qc_lib.sh`; override seams `SHELL_QC_<TOOL>_BIN`.
- Pinned versions: shfmt 3.8.0, kcov v43, apt shellcheck and bats; CI versions are canonical (`shell.md` lines 73-78).
- The recommended replacement expression contains `$'\n\r\v\f'` inside a bracket expression; the identical form already passes shfmt and shellcheck at `parallel-lane-assertion.sh:88`, so no new suppression is expected.

## 9. Line counts (500-line limit)

Counts from Grep `^` per file (current tree):

| File | Lines | After fix (estimated) |
|---|---|---|
| `.claude/lib/bash/parallel-cohorts.sh` | 330 | about 335 (comment update plus 1-2 lines) |
| `extensions/.../.claude/lib/bash/parallel-cohorts.sh` | equal to repo copy (mirror, byte-identical guard) | same |
| `.claude/lib/bash/compute-cohorts.sh` | 143 | unchanged |
| `.claude/lib/bash/compute-concurrency-batches.sh` | 122 | unchanged |
| `.claude/lib/bash/parallel-items-validate.sh` | 244 | unchanged (out of scope) |
| `tests/shell/parallel_cohorts.bats` | 222 | about 270-300 |
| `tests/shell/parallel_cohorts_parity.bats` | 101 | unchanged |

All remain well under 500.

## Candidate approaches (summary)

1. Inline normalization identical to #609 inside `pcoh_split_words` (recommended). One production line change plus comment; matches the already-merged and CI-verified rule; keeps `read -ra`; no new coupling.
2. New shared tokenizer in `parallel-common.sh` used by both libraries. Cleaner in principle, but edits three production files and mirrors, re-opens the closed #609 site, and adds a function that needs its own tests; no behavior gain.
3. `read -d '' -ra` (rejected above): errexit hazard, incomplete separator set.
4. Unquoted expansion `PCOH_WORDS=($1)` (rejected): pathname expansion of tokens, the reason the original comment cites `read -ra`.

## Behavior semantics

- Separator set after the fix: space, tab, LF, CR, VT, FF; equal to Python `str.split()` for ASCII. Other Unicode whitespace is excluded, matching the declared divergence in #609 ("residual Python-only whitespace").
- Empty or whitespace-only (including only newlines) input yields an empty array (empty-graph case preserved).
- Duplicate-key, self-loop, unknown-endpoint, leading-zero, and malformed-edge behaviors are unchanged but now apply to every token.

## Automation Feasibility

Fully automatable; no human interaction is required. Edits are textual (one expression, one comment, one mirror copy, bats rows). Verification runs in CI (`shell-coverage` job) with no manual steps. The only environment constraint is that local agent sessions may be unable to run `bash`/`bats`; in that case the fail-first and pass runs are obtained through CI as #609 did, which is also automatable (`gh workflow run`/PR checks).

## Recommended fix

1. In `parallel-cohorts.sh` `pcoh_split_words`, assign `local text="${1-}"` and replace line 62 with `read -ra PCOH_WORDS <<<"${text//[$'\n\r\v\f']/ }"` (same expression as `parallel-lane-assertion.sh:88`). Update the comment (lines 55-60) to state that newline, CR, VT, and FF become spaces first, since `read` consumes one record, and that the separator set matches Python `str.split()` for ASCII. Update the function header wording "space-separated string" to "whitespace-separated string".
2. Copy the file byte for byte to the bundled mirror.
3. Add bats regression rows to `tests/shell/parallel_cohorts.bats` (fail-first via CI), covering `--keys`, `--edges`, and `compute-concurrency-batches.sh --keys` with LF, CR, VT, FF, CRLF-terminated, and mixed separators, each against a single-line control, plus one direct `pcoh_split_words` array assertion and one bad-token-after-newline exit-2 case.
4. Leave `parallel-items-validate.sh:71,238` and the internal `read -ra` sites of `parallel-lane-assertion.sh` unchanged; record them in the spec as out of scope with the evidence above.
5. Correct the stale statements in `issue.md`/`spec.md` ("#609 still open", "Python authority splits on any whitespace" for the cohort module): #609 is fixed by PR #815; the cohort Python module takes typed lists, so the authority for the newline case is list-equivalence.
6. Run `bash scripts/bash/shell-qc.sh format`, `check`, `test --coverage` (locally under WSL where possible; otherwise confirm in the `shell-coverage` CI job).

## Files the implementation will write

Production:
- `.claude/lib/bash/parallel-cohorts.sh`

Mirrors:
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-cohorts.sh`

Tests:
- `tests/shell/parallel_cohorts.bats`

Fixtures: none required (inputs are `$'...'` literals; no temporary files per policy).

Not written: `compute-cohorts.sh`, `compute-concurrency-batches.sh`, `parallel-items-validate.sh`, `parallel-lane-assertion.sh`, `core.json`, and the parity corpus.

## Open items for the planner

- Merge-commit SHA of PR #815 was not retrieved (no git access in this session); a one-line `git log --oneline --grep=609` at planning time closes it.
- `PM_TOP_LEVEL_PROHIBITED_KEYS` definition was not opened; the out-of-scope recommendation for `parallel-items-validate.sh:238` rests on there being a single caller passing a module constant.
- Whether to also add a corpus-level parity fixture with a non-space separator was not evaluated; the corpus builder uses `" ".join`, so extending it would require changing the bats harness and the Python lane together. Not recommended for this fix.
