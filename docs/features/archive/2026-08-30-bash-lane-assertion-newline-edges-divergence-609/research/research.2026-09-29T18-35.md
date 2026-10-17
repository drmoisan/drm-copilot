# Research: bash lane-assertion `--edges` newline divergence (#609)

- Issue: #609 (work mode full-bug), branch `bug/bash-lane-assertion-newline-edges-divergence-609`
- Base: origin/main 43c9e95e
- Method: static reading of the current tree. No shell, Python, or bats was executed in this session (shell tools are denied in agent worktrees), so behavior statements about `read` are derived from the code plus documented bash semantics and from the reproduction already recorded in the issue. They are marked "unverified by execution" where relevant.

## 1. Tokenization in each lane

### Bash lane

Entry point `.claude/lib/bash/report-lane-assertion.sh` stores the raw `--edges` value (line 112, `edges="$2"`) and passes it unchanged to `rla_report` (line 159), which calls `pla_parse_edges "$1"` (line 78). The tokenizer is in `.claude/lib/bash/parallel-lane-assertion.sh:73-98`:

```bash
local text="${1-}" token first second
PLA_EDGES=()
local -a tokens=()
# read -ra rather than an unquoted expansion, so a token carrying a glob
# character is never subjected to pathname expansion.
read -ra tokens <<<"$text"          # line 86
```

Mechanism: `read` without `-d` uses newline as its record delimiter and consumes exactly one record. The here-string supplies `"$text"` plus one appended newline. With `-a`, `read` splits that first record on `IFS` (default space, tab, newline) into the array, and stops. Everything after the first embedded newline stays unread in the here-string and is discarded. For `999:998\n101:202` the array is `("999:998")`; `999:998` names undeclared vertices, is skipped in `pla_derive_components` (lines 225-226), so no edge lands and the manifest's two items stay separate (2 components), matching the issue's bash output. Tab and space are IFS characters inside the single record, so they split correctly; only the record delimiter (newline) truncates.

The same idiom (`read -ra <var> <<<"$x"`) is used throughout the file: lines 110, 211, 238, 249, 287, 318, 342, 369, 396, 402, 433, 439, 448, 454. Only line 86 takes untrusted operator text; the others read internally built space-joined lists.

Sibling precedent (out of scope): `.claude/lib/bash/parallel-cohorts.sh:54-63` `pcoh_split_words` does `read -ra PCOH_WORDS <<<"${1-}"` and is used by `compute-cohorts.sh:71,77`. It has the same single-line behavior, as the issue records. It is a different helper from `pla_parse_edges`.

### Python authority

`scripts/dev_tools/parallel_lane_assertion.py:410-433`, `parse_edges`:

```python
for token in edge_text.split():      # line 425
    first, separator, second = token.partition(EDGE_SEPARATOR)
```

`str.split()` with no argument splits on any run of Unicode whitespace (including `\n`, `\r`, `\t`, `\v`, `\f`, `\x1c-\x1f`, `\x85`, `\xa0`) and drops empty strings. `999:998\n101:202` yields two tokens, `101:202` merges the two items into one component (1 component), matching the issue's Python output.

### Whitespace-set difference (additional finding)

Even with newline fixed, bash `read` uses only space, tab, newline as IFS by default. Python additionally splits on CR, VT, FF, `\x1c-\x1f`, and non-ASCII whitespace. Under bash a CR-terminated token such as `202\r` is not a lexical integer (`^-?(0|[1-9][0-9]*)$`, `parallel-lane-assertion.sh:70`) and the edge is dropped, whereas Python splits it off and keeps the edge. So `--edges $'101:202\r\n'` also diverges today. This is the same undeclared class; it is not covered by any current test. Unverified by execution.

## 2. The #599 spec

- Location: `docs/features/completed/2026-08-29-remove-remaining-python-invocations-599/spec.md`. The feature is in `completed/`, not `active/` (the issue and the remediation file cite an `active/` path that no longer exists). The `active/` glob for that slug returns nothing; `completed/` holds spec, plan, issue, user-story, code-review, feature-audit, policy-audit, and `remediation-inputs.2026-08-30T17-17.md`.
- `### Declared divergences from the Python reference` (spec.md:328-366): "Five classes, of which two are inherited ... and three are new". Numbered list:
  1. inherited, M1 YAML-parse-failure text (333)
  2. inherited, non-printable string-repr escapes (336)
  3. new, `--edges` integer lexis, exactly four members: leading zero, leading `+`, underscore separator, non-ASCII decimal digit (338-347)
  4. new, manifest-unreadable detail text (359)
  5. new, out-of-subset manifests (363)
- The whitespace paragraph is spec.md:348-358: "Whitespace inside an endpoint is not a member of class 3 ... `str.split()` before `token.partition(":")` ... The port specified here consumes the same whitespace-separated token stream, so it cannot observe interior whitespace either." The last sentence is the factually incomplete claim for newline.
- spec.md:484-485: "Divergence class 3 is a behavior difference, not a bug. Without the pinning unit test it would be indistinguishable from a porting defect."
- The spec is a closed-feature document. Editing it is possible but is retroactive documentation on a completed feature.
- Other live documents declaring the class list: the same five-class list is restated in the header of `tests/shell/parallel_lane_assertion_parity.bats:19-55` and the module docstring of `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py:20-52`. Both contain the sentence "Both implementations split the --edges value on whitespace ... the two CONVERGE on it". Class 4 alone is restated in `tests/shell/parallel_lane_assertion.bats:12-18`. `.claude/rules/parallel-orchestration.md:134` describes the diagnostic but declares no divergence classes. `.claude/skills/parallel-plan/SKILL.md` lines 285-336 and the `parallel-planner.md` invocation carry no divergence list (the diagnostic invocation is now at SKILL.md:336, not :321 as the issue states; both forms pass single-line strings). No divergence list exists under `.claude/` rules, skills, or agents beyond that.

## 3. Mirrors and parity guards

- Canonical: `.claude/lib/bash/parallel-lane-assertion.sh` and `.claude/lib/bash/report-lane-assertion.sh`.
- Bundled mirrors (glob `**/{report-lane-assertion,parallel-lane-assertion}.sh` over the whole worktree returned exactly four files): `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh` and `.../report-lane-assertion.sh`. No copy exists under `.codex/` or `.agents/`.
- Both files are registered in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:168,172`; that registration needs no change for an in-place edit.
- Byte-equality guards:
  - `tests/shell/parallel_bash_manifest_membership.bats:56-71` (`cmp -s` per library file between `.claude/lib/bash` and the bundle; the list is discovered by `discover_lib_basenames`) and `:73-` (no bundled-only files).
  - `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, `SCOPED_ROOTS == (.claude,)`, compares text of every `.claude/**` file against the bundle).
- Mirroring is manual (no copy automation), so an edit to the canonical library must be copied byte-identically to the bundle.

## 4. Existing tests and the natural home for a regression test

- Bash unit: `tests/shell/parallel_lane_assertion.bats` sources the library directly. `pla_parse_edges` cases at lines 52-78 (space-only inputs). Class-3 case at 395-429 uses `PAYLOAD_MANIFEST()` (line 241, `tests/fixtures/parallel_manifest_payload/parallel.md`, declares issue_num 101 and 202 at fixture lines 7 and 19) and `ENTRY_POINT()` (line 234), with `split_header`/`merged_header` constants and a `101:202` control. This is the exact shape the issue's reproduction uses.
- Bash parity: `tests/shell/parallel_lane_assertion_parity.bats` iterates every `tests/fixtures/parallel_lane_assertion/*.json` record, runs the entry point as a subprocess with `--edges "$edges"` (line 102), and compares to `expected_stdout`. The value is read via `$(...)`, which preserves interior newlines (only trailing ones are stripped), so an embedded-newline `edges` value survives. It has a floor of 20 records (line 70) and a convergence case for interior whitespace (176-189).
- Python parity: `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py` runs every corpus record through `main([...])` in-process (line 216); it also asserts `manifest_text` equals the manifest file (229-256). Python unit: `tests/scripts/dev_tools/test_parallel_lane_assertion.py` (`parse_edges` cases at 333-351).
- Corpus record template: `tests/fixtures/parallel_lane_assertion/edges_endpoint_interior_whitespace.json` (keys `name, notes, manifest_path, manifest_text, edges, expected_stdout, expected_status, divergence`; `expected_stdout` must be derived from the Python authority, not hand written). Existing edges fixtures: `edges_empty`, `edges_whitespace_only`, `edges_reversed_and_duplicated`, and others in that directory. None contains a newline, tab, or CR.
- Natural home:
  - Convergence corpus records (newline; optionally tab and CR) in `tests/fixtures/parallel_lane_assertion/`, since one artifact then pins both lanes (the corpus's stated purpose). Candidate record: manifest `manifests/two-items-no-assertion.md`, edges `"999:998\n101:202"`, whose report equals the single-line `"999:998 101:202"` report from the Python authority (1 component).
  - A bash unit case in `tests/shell/parallel_lane_assertion.bats` next to line 52-78 or the class-3 case, using `PAYLOAD_MANIFEST` and asserting the header line for newline, tab, CR/CRLF, with the `101:202`-only control.
- Run commands (documented, not executed here): `bash scripts/bash/shell-qc.sh format`, `bash scripts/bash/shell-qc.sh check`, `bash scripts/bash/shell-qc.sh test --coverage` (per `.claude/rules/shell.md`; `shell-qc.sh test` runs bats over `tests/shell` and `tests/bash`, usage at `scripts/bash/shell-qc.sh:24`). Single file: `bats tests/shell/parallel_lane_assertion.bats`. Python: `poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py tests/scripts/dev_tools/test_parallel_lane_assertion.py`. CI runs bats: `.github/workflows/_shell-coverage.yml` installs bats/shellcheck/shfmt/kcov and runs `shell-qc.sh check` and `shell-qc.sh test --coverage` (lines 16-19, 51-55). In this environment use `sh file.sh` style invocation per the project memory notes; CI is the bats authority.

## 5. Fix options

Naming note: the issue labels (A) close and (B) declare; `remediation-inputs.2026-08-30T17-17.md` uses the opposite labels. This section uses the issue's labels.

- (A) Close the divergence in `pla_parse_edges`. One-statement change at line 86: normalize newline (and CR/VT/FF, if the ASCII whitespace set is adopted) to spaces before the split, for example `read -ra tokens <<<"${text//[$'\n\r\v\f']/ }"`. This is pure parameter expansion, has no `read` exit-status effect under `set -euo pipefail` (entry point line 29), and needs no `read -d ''` idiom (which returns status 1 at EOF and would need an `|| true` guard). Advantages: the port then matches the authority on the input the issue names; the spec/test-header sentence "both implementations split the --edges value on whitespace" becomes true as written, so no closed-spec edit and no class-6 declaration are needed; both parity lanes gain a convergence record. Limits: non-ASCII whitespace and `\x1c-\x1f` still differ (see section 1); the sibling `compute-cohorts.sh` is untouched.
- (B) Declare class 6 and pin it. Requires editing a closed feature's `spec.md` (two places), two test header blocks, and a bash-only test, and leaves a known porting defect in a diagnostic whose purpose is byte-identical output with the authority (`parallel-lane-assertion.sh:6-9`, `report-lane-assertion.sh:19-20`). Class 3 is justified by the port reproducing a stricter lexis deliberately; nothing comparable justifies losing newline-separated edges.

Recommendation: (A). It is the smaller total change to production code (one statement plus a comment), the operator input is a legitimate whitespace-separated list, and it removes rather than documents the discrepancy. Scope bound: fix `pla_parse_edges` only. Record the following as follow-ups, not part of this change:
1. `compute-cohorts.sh` / `pcoh_split_words` (`parallel-cohorts.sh:54-63`) newline truncation. It is a separate helper shared by cohort and batch entry points and has its own Python authority and parity suite (`tests/shell/parallel_cohorts_parity.bats`), so fixing it is not "trivially the same helper".
2. Residual Python-only whitespace (`\x1c-\x1f`, `\x85`, `\xa0`, other Unicode spaces) in `--edges`, unless the implementer chooses to declare it.

## 6. Minimal file set for the recommended fix (repository-relative)

Production:
- `.claude/lib/bash/parallel-lane-assertion.sh` (line 86 tokenization and the comment at 84-85)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh` (byte-identical copy; guarded by `parallel_bash_manifest_membership.bats:56-71` and `test_push_down_claude_resource_contracts.py:118-143`)

Tests:
- `tests/shell/parallel_lane_assertion.bats` (newline, tab, CR/CRLF unit cases with control assertion)
- `tests/fixtures/parallel_lane_assertion/edges_newline_separated.json` (new convergence record; `expected_stdout` generated by running `scripts/dev_tools/parallel_lane_assertion.py`; covered automatically by both parity suites; the two parity files need no edit)
- Optional: a second record for CR/CRLF (`edges_crlf_separated.json`) if the ASCII whitespace set is adopted.

Not written: `spec.md` of #599 (closed; no change needed under option A), `core.json`, `report-lane-assertion.sh`, `compute-cohorts.sh`, `parallel-cohorts.sh`.

Evidence for the implementation run belongs under this feature's `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/<kind>/` per the evidence-and-timestamp conventions, not under `docs/features/completed/2026-08-29-remove-remaining-python-invocations-599/` as the #599 remediation note suggests and not under `artifacts/`.

Toolchain note: the modified bash files fall under `.claude/rules/shell.md` (shfmt, shellcheck, bats with kcov line coverage >= 85%); the new fixture is JSON and needs no separate gate. File-size limit (500 lines) is not affected: `parallel-lane-assertion.sh` is 495 lines, so a comment-only growth of more than 5 lines would breach it; keep the edit to at most 4 added lines.

## Numeric Derivation Evidence

No numeric count is proposed for a `spec.md` acceptance criterion in this research. The counts cited above (five classes; four class-3 members; four mirrored/canonical files) are read from existing documents or a single-glob inventory and are not proposed as new criteria.

## Automation Feasibility

No human interaction is expected. The fix is a one-line tokenizer change, one mirror copy, one bats unit case, and one JSON corpus record whose expected output is derived by running the Python authority. All are automatable. The only environment caveat is that bats and bash cannot be executed inside this agent worktree; CI (`_shell-coverage.yml`) or an operator-run `sh`-style invocation provides the bats verification.
