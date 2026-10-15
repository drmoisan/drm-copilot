# Code Review (#609)

- Timestamp: 2026-10-01T23-21
- Head: `4a45810410fcc5df12d68dee5f3a718d9b2f49d6`; base `origin/main` (`1b1e349f`)
- Reviewed: `git diff origin/main...HEAD` for the four non-documentation files

## Verdict

No blocking code finding. The fix is minimal and correct by reading. Behavioral confirmation of the bash lane depends on CI (bats cannot be run locally under operator rule Option A).

## Fix: `.claude/lib/bash/parallel-lane-assertion.sh` lines 84-88

```
read -ra tokens <<<"${text//[$'\n\r\v\f']/ }"
```

Assessment:
- Correctness: `read -ra` without `-d` reads one newline-terminated record and splits it on default IFS (space, tab, newline). Anything after the first embedded newline was never read (the reported defect); CR, VT, and FF were never separators. Replacing those four characters with spaces first makes the bash set (space, tab, newline, CR, VT, FF) equal the Python `str.split()` set for ASCII. The spec's Root Cause Analysis is consistent with this reading.
- Invariants preserved: `read -ra` stays, so glob characters in a token are not pathname-expanded; no new command, so no new exit-status effect under `set -euo pipefail`; the downstream shape and integer-lexis checks (lines 93-97) are unchanged; output format is unchanged.
- Sibling regions: the other `read -ra` sites (lines 112, 213, 240, 251, 289, 320, 344, 371, 398, 404, 435, 441, 450, 456) read internally built space-joined lists, so they do not need the normalization. Line 88 is the only operator-text site.
- Size: 497 lines (limit 500), +2 net. The comment grew by two lines to document why the normalization exists, which is proportionate.
- Comment accuracy: the comment says "read consumes one newline-terminated record and splits it on IFS only". Accurate.
- Residual (known, recorded as follow-up 2): Python-only whitespace (`\x1c`-`\x1f`, `\x85`, `\xa0`, Unicode spaces) still differs. The code comment says "Newline, CR, VT, and FF" and does not claim full equivalence, so it is not misleading.

Non-blocking observation (R-1, low): `"${text//[$'\n\r\v\f']/ }"` relies on `$'...'` being honored inside a double-quoted pattern expansion. This is standard for bash 4 and later (CI is ubuntu-latest, bash 5.x; the Git Bash in this worktree is 5.2.37). The reviewer could not demonstrate it with an inline command because the worktree guard refused it. The six bats cases will fail on CI if the expansion does not behave as intended; the plan's fallback (a local variable holding `$'\n\r\v\f'`) is available if so.

## Mirror

`extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh` is byte-identical (`cmp` exit 0, identical blob hash `fe1ff687`, LF endings). Manual mirroring remains the project's process; the two byte-equality guards (`tests/shell/parallel_bash_manifest_membership.bats` and the push-down contract pytest) cover drift. The pytest guard passed in the reviewer's run; the bats guard awaits CI.

## Tests: `tests/shell/parallel_lane_assertion.bats` (+37 lines, 495 total)

Strengths:
- A shared helper (`edges_header_is`) keeps six cases within the 500-line limit while asserting both exit status and header in one comparison, so each failure message shows `status:header`.
- Each case includes the single-line `101:202` control, so a failure distinguishes a tokenizer defect from a harness or manifest problem.
- Escapes use ANSI-C quoting, so the file stays ASCII and needs no temporary file.
- Cases cover newline, tab, CR, CRLF-terminated final token (value `$'101:202\r\n'` isolates the last-token CR corruption), undeclared-only vertices, and mixed separators.
- The `edges-parity:` title prefix is unique and counted (6) in the P1-T1 evidence.

Observations (non-blocking):
- R-2 (low): the helper's contract (`$1` = expected header, remaining arguments = values) is stated in a comment, but the file-scope variables `EDGES_MERGED_HEADER` and `EDGES_SPLIT_HEADER` are shell globals set at file scope. Bats evaluates the file once per test, so there is no cross-test leakage. No action required.
- R-3 (low): the tab case and the undeclared-vertices case pass on the unmodified library, so they are boundary guards, not fail-first tests. This is recorded in the evidence and does not weaken the four fail-first cases (newline, CR, CRLF, mixed).
- R-4 (low): the helper asserts only the first output line. The spec limits the assertion to the header line, and the full output is covered by the parity fixture, so this is adequate.
- `shfmt -d` on this `.bats` file reports whole-file differences relative to the repository's `.editorconfig`; this pre-dates the branch (existing cases use the same 4-space indentation) and `shell-qc.sh` does not format `.bats` files.

## Fixture: `tests/fixtures/parallel_lane_assertion/edges_newline_separated.json`

- Keys and order follow the sibling `edges_endpoint_interior_whitespace.json` (`name`, `notes`, `manifest_path`, `manifest_text`, `edges`, `expected_stdout`, `expected_status`, `divergence`).
- `expected_stdout` is derived from the Python authority (recorded in `authority-derivation.2026-09-29T18-45.md`) and verified by the reviewer: `test_reference_reproduces_every_corpus_fixture[edges_newline_separated]` is part of the 83 passing tests. It reports 1 derived component and two informational `item_covered_by_no_component` lines, which agrees with `edges` `999:998\n101:202` against the two-item manifest.
- `divergence` is `null`, consistent with the claim that the lanes now converge for this input.
- The `notes` text is accurate.

## Scope Discipline

No unrelated edits, no formatting churn, no change to the header blocks of the two parity test files, no change to `report-lane-assertion.sh`. Follow-ups (newline truncation in `pcoh_split_words`, residual Python-only whitespace) are recorded in `evidence/other/follow-ups.2026-09-29T18-45.md` and are not silently dropped.

## Blocking Findings

None.

## Gating Items Before Merge

1. CI job `shell-coverage` on head `4a458104` must be read (see `policy-audit` section 8 and `feature-audit`).
2. AC-6 requires fail-before evidence that does not exist; see `remediation-inputs`.
