# Feature Audit — issue 637, preserve-file consolidation

Timestamp: 2026-09-08T12-21
Branch: `bug/cleanup-worktrees-preserve-file-consolidation-637-r2`
HEAD: `ed975b747b8b5915b8c6b592d9deb7bab2738aa0`
Baseline: `origin/epic/cleanup-merged-worktrees-hardening-integration` (merge base `fff74314`)
Work mode: `full-bug` (`issue.md:12`) → **`spec.md` is the sole acceptance-criteria source**.
`user-story.md` is present in the folder but is **not** an AC source in this mode and was not
counted.

Verdict: **43 of 43 acceptance criteria PASS.** No criterion was downgraded and none was
unchecked.

## AC Enumeration Method

Criteria were counted between the exact heading `## Acceptance Criteria` (spec.md:874) and
the next equal-depth heading `## Open Questions` (spec.md:981). That span contains exactly
43 checkbox items, AC-01 through AC-43, all currently `[x]`.

The severity radio-button block elsewhere in `spec.md` uses unchecked boxes for its
unselected options. Those lie outside the AC span and were correctly excluded, as the
directive required.

Test-name existence was verified by enumerating `^@test` lines across the three suites:
26 in `test_cleanup_worktrees_preserve.bats`, 6 in `test_cleanup_worktrees_preserve_eol.bats`,
11 in `test_cleanup_worktrees_preserve_failures.bats` — 43 tests total, matching the CI plan
line movement from `1..343` to `1..386`.

Test-pass status rests on CI run 34223163823 (plan line `1..386`, zero `not ok`), on head SHA
`c58ac6e58dd4831530509806143f4e32212bfeb0`. This reviewer verified independently that no
source, test, or fixture file changed between that SHA and HEAD — only eight `.md` files
under `docs/` — so the run applies to the code under review.

## A Note on the AC-15 to AC-20 File Locator

AC-15 through AC-20 each name `tests/shell/test_cleanup_worktrees_preserve.bats` as the
containing file. All six tests are in fact in
`tests/shell/test_cleanup_worktrees_preserve_eol.bats`. The AC preamble states that criteria
naming a bats test "assert that the named test exists in the named file," so on a purely
literal reading these six locators are wrong.

**They are nevertheless recorded PASS, and were not unchecked.** The reason is that the same
specification pre-authorizes exactly this placement at `spec.md:221-227`:

> The same pre-authorization applies to the bats suite, which may split into
> `tests/shell/test_cleanup_worktrees_preserve.bats` and
> `tests/shell/test_cleanup_worktrees_preserve_eol.bats`.

The executor exercised an authorization the spec granted in advance, and correctly did not
edit AC text while checking off, per the `acceptance-criteria-tracking` rule that only
`- [ ]` → `- [x]` may change. The named tests exist, they pass, and each pins the behaviour
its criterion describes. Unchecking on a locator that the spec itself supersedes would be
over-reading the evidence.

This is recorded as a documentation-consistency item for the spec owner: reconcile the six
AC locators with the D1 pre-authorization so the two statements agree.

`tests/shell/test_cleanup_worktrees_preserve_failures.bats` is a third suite that the
pre-authorization does not name. No acceptance criterion names any test in it, so no
criterion is affected. Creating it violates no rule — it sits under `tests/shell/` and is
discovered by the same directory-scoped `bats` invocation — and the rationale is recorded in
the file header and in `evidence/other/coverage-remediation-decision.2026-09-08T12-10.md`.

## Acceptance Criteria Evaluation

Legend: **CI** = pass status from run 34223163823. **RV** = re-verified independently by this
reviewer in this session.

| AC | Verdict | Basis |
|---|---|---|
| AC-01 | PASS | Library exists (492 lines). Test at `preserve.bats:112` sources the chain in a fresh subshell and asserts empty output and exit 0 for both the EOL library and the full chain. CI. |
| AC-02 | PASS | Test at `preserve.bats:196` drives `bash cleanup-worktrees.sh preserve` and asserts an `ACTION\|preserve-stage\|null\|OK` record reachable only through the new arm. CI. RV: dispatch arm confirmed in the wrapper diff. |
| AC-03 | PASS | Test at `preserve.bats:209` asserts status 2 and the usage banner. CI. |
| AC-04 | PASS | RV: `CLEANUP_WT_MANIFEST_PATH` present in the usage heredoc (wrapper diff, Environment overrides block). Test at `preserve.bats:215` asserts both halves — an absent override path is reported verbatim, and an existing one is the manifest actually read. CI. |
| AC-05 | PASS | Test at `preserve.bats:127` asserts status 127, the `no jq binary resolved` diagnostic, the *absence* of `command not found` (which discriminates the two sources of 127), and no `stub-git:` line. CI. |
| AC-06 | PASS | Test at `preserve.bats:146` asserts status 1, the `REJECTED` record for both `bad-tool` and `bad-schema`, and no git call. CI. See code-review F1: the test pins the shell's handling of a non-zero `jq` exit, not the filter's own rejection. |
| AC-07 | PASS | Test at `preserve.bats:236` asserts `MISSING-WORKTREE`, no `stub-git:` line, and that the worktree was not created. CI. |
| AC-08 | PASS | Test at `preserve.bats:73` asserts the `PRESERVE\|` record with worktree, source and verdict, the `OK` staging record, and the `add -- null` argv. CI. Fail-before recorded. |
| AC-09 | PASS | Test at `preserve.bats:251` asserts `change_class: modified` takes the identical staging path. CI. |
| AC-10 | PASS | Test at `preserve.bats:265` extracts the `PRESERVE\|` source column and asserts the exact ordered string; the fixture manifest lists `zzz` first, so array-order iteration produces the reverse and fails. CI. |
| AC-11 | PASS | Test at `preserve.bats:348` asserts renderer output equals the input line exactly, with an em dash and a markdown link in the payload, and asserts the checked-in index is unchanged. CI. |
| AC-12 | PASS | Test at `preserve.bats:281` asserts staging succeeded, that no `ACTION\|preserve-index\|` record of any kind was emitted, and that no index file was created. CI. |
| AC-13 | PASS | Test at `preserve.bats:371` asserts the `CREATED` record, that nothing was written, and that `PRESERVE_EXIT` is 1. CI. |
| AC-14 | PASS | Test at `preserve.bats:389` asserts `SKIPPED-DUPLICATE`, that the file is still copied and staged, and that `PRESERVE_EXIT` is 0. CI. See code-review F4 (spec-level observation). |
| AC-15 | PASS | Test at `preserve_eol.bats:88`. Asserts a terminator is owed for the unterminated fixture **and not owed** for a terminated one, then counts line feeds on the raw stream (2 with a leading terminator, 1 without). Locator note above. CI. |
| AC-16 | PASS | Test at `preserve_eol.bats:61`. Asserts `ADVISORY-MISMATCH` and that the destination index contains no carriage return, so the stale `crlf` advisory did not reach it. Locator note above. CI. Fail-before recorded. |
| AC-17 | PASS | Test at `preserve_eol.bats:113`. Asserts the mismatch record, that `PRESERVE_INDEX_TERM` is the re-derived `lf` rather than the advisory `crlf`, and a negative control that an agreeing advisory emits no record. Locator note above. CI. |
| AC-18 | PASS | Test at `preserve_eol.bats:130`. Byte assertions: derivation returns `crlf`; `preserve_line_terminator` emits 2 bytes for `crlf` and 1 for `lf`; the renderer emits exactly one CR for `crlf` and zero for `lf`. Locator note above. CI. See code-review F2 for the untested join. |
| AC-19 | PASS | Test at `preserve_eol.bats:157`. Asserts derivation returns `mixed`, the `EOL-MIXED` record, the absence of an index `OK` record, `PRESERVE_EXIT` 1, and an empty plan stream — the record is refused entirely. Locator note above. CI. |
| AC-20 | PASS | Test at `preserve_eol.bats:49`. **RV, and strengthened:** this reviewer read the fixture from git's object store rather than the working tree — `git cat-file blob HEAD:...eol-crlf/MEMORY.md \| od -c` shows `\r \n` terminators throughout. The index blob genuinely is CRLF, so the fixture is not merely CRLF by local checkout accident. CI. |
| AC-21 | PASS | RV: `.gitattributes` contains exactly `tests/fixtures/cleanup_worktrees/preserve/eol-crlf/** -text` on line 2, after `* text=auto eol=lf`, so the later rule wins. `git check-attr text` reports `unset` for the two `eol-crlf/**` fixtures and `auto` for a sibling fixture outside it — the exception is correctly scoped and no broader. |
| AC-22 | PASS | Test at `preserve.bats:86` asserts exit status **3**, a `HOST-TOKEN-BLOCKED` record, and no `add` argv via an operand-anchored regex that can actually fail. The record's own advisory says `clean`, so a pass trusting the manifest would have staged it. CI. Fail-before recorded. |
| AC-23 | PASS | Test at `preserve.bats:420` asserts one diagnostic per identifier HT1–HT6, a count of exactly 6 `HOST-TOKEN-BLOCKED` records, and an empty plan stream. Six checked-in fixtures, one per pattern. CI. |
| AC-24 | PASS | Test at `preserve.bats:434` asserts the legitimate revision-syntax payload is accepted at exit 0 with no match — the refusal is not a blanket reject. RV: the HT4 pattern requires a slash on both sides of the `~N` token, so `HEAD~1` cannot match. CI. |
| AC-25 | PASS | Test at `preserve.bats:443` asserts no refusal, then asserts with `grep -c` that the token **is** present in the manifest and in the destination index and **is not** present in the named source file — so the pass is not vacuous. CI. |
| AC-26 | PASS | Test at `preserve.bats:159` iterates the `scan-malformed/` scenarios, asserts `SKIPPED-INVALID` and a `host_token_scan` reason for each, and asserts the loop count is exactly 5 so an empty glob cannot pass silently. CI. |
| AC-27 | PASS | Test at `preserve.bats:459` asserts both halves: a foreign identifier alone yields `PATTERN-SET-MISMATCH` at exit 0 with no block, and a foreign identifier over token-bearing bytes yields both the mismatch and the block at exit 3 — the local scan governs. CI. |
| AC-28 | PASS | Test at `preserve.bats:174` iterates the `field-matrix/` scenarios asserting `SKIPPED-INVALID`, with a loop-count assertion of exactly 8, one per skip-bearing field of the D4 table. The three reasons unreachable through a manifest fixture (`..` segments, short column count, non-boolean is-null) are covered separately in `preserve_failures.bats`. CI. |
| AC-29 | PASS | Test at `preserve.bats:295` asserts status 1, the `MISSING-SOURCE` record, and the absence of an `OK` record — a skip, not a hard stop. CI. |
| AC-30 | PASS | Test at `preserve.bats:308` asserts `IGNORED-TARGET` and, via the operand-anchored regex, that **no `add` call occurred at all** — strictly stronger than "contains no `--force`". RV of the substance: `grep` over both new libraries finds no `--force` and no `-f` flag on any git invocation; the only matches are comments and `[[ -f ... ]]` file tests. CI. |
| AC-31 | PASS | Test at `preserve.bats:325` loops `clean:0`, `skipped:1`, `blocked:3` asserting each exit code, and asserts the blocked run staged nothing. CI. |
| AC-32 | PASS | Both stub tests at `preserve.bats:49` and `:57` assert a **non-default** exit code (1) plus the logged argv. The stub's default arm exits 0, so an assertion of 0 would pass even with the new case arm absent; the tests avoid that. CI. |
| AC-33 | PASS | RV: `## Report Line Contract` at `SKILL.md:58`; the `PRESERVE\|` bullet at `:81` sits inside that section's bullet list, adjacent to the `ACTION\|` bullet it is anchored to. |
| AC-34 | PASS | RV: `cmp` reports the mirror byte-identical; both files hash to `f6be47ff9d2d63b5246aa7041273ff349fb8b6b1db52aa4231defc21589c7a2e`, matching the recorded value. |
| AC-35 | PASS | RV: `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` → `11 passed`, exit 0. |
| AC-36 | PASS | RV: `git diff --stat <merge-base> HEAD -- scripts/bash/cleanup_worktrees_lib.sh` prints nothing; `git status --porcelain` is clean. The file remains at 490 lines. |
| AC-37 | PASS | RV: `git diff --stat <merge-base> HEAD -- .claude/hooks` prints nothing; working tree clean. `.claude/rules` and `.github/instructions` are likewise untouched. |
| AC-38 | PASS | RV per file with `wc -l`: 492 / 212 / 163 (scripts), 471 / 264 / 175 (suites), 275 / 79 (stubs). All at or below 500. Markdown exempt. |
| AC-39 | PASS | `evidence/qa-gates/final-qc-single-pass.2026-09-08T12-10.md` records format 0 → check 0 → test 0 in one uninterrupted iteration on one tree state. RV: this reviewer re-ran `shell-qc.sh check` locally to exit 0 with zero output, with `shellcheck` and `shfmt` both confirmed present so the stage was not a silent skip. The no-rewrite claim correctly rests on a pre-format `shfmt -d` no-diff observation rather than on `shfmt -w`'s uninformative exit code. Route deviation recorded: stages 1–2 ran locally, stage 3 in CI on the same head SHA. |
| AC-40 | PASS | `evidence/qa-gates/final-qc-coverage.2026-09-08T12-10.md` records the headline `Bash coverage (lines): 93.2%` from run 34223163823, `cov.xml` produced, per-file rates 0.906 / 0.870 / 1.000. 93.2 >= 85.0. No branch figure exists because kcov measures lines only; that is an exemption in `.claude/rules/quality-tiers.md`, not a gap. |
| AC-41 | PASS | RV: `scripts/bash/shell_qc_lib.sh:333-336` excludes only `<root>/tests`; the include pattern covers all of `scripts/`. That file is not in the branch diff, so no exclusion was added. The 0.807 → 0.906 remediation was achieved with eleven behavioural tests, not an exclusion. |
| AC-42 | PASS | Three artifacts under `evidence/regression-testing/`, one per required case: `fail-before-untracked` (AC-08), `fail-before-stale-eol` (AC-16), `fail-before-host-token` (AC-22), each `EXIT_CODE: 1` with `ExpectedExitCode: 1`. Corroborated by CI run 34213641449: plan line `1..349` with exactly 3 failures. |
| AC-43 | PASS | RV: `grep` for `mktemp`, `BATS_TEST_TMPDIR`, `BATS_TMPDIR`, `TMPDIR`, and `/tmp/` across all three suites and the entire `preserve/` fixture tree returns nothing. Writable destinations are `/dev/null` and `/dev/stdout`, which are character devices. Roughly 60 checked-in fixture scenario directories are used throughout. |

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/spec.md
- Total AC items: 43
- Checked off (delivered): 43
- Remaining (unchecked): 0
- Items remaining: none
```

No AC source file was modified by this review. All 43 criteria were already `[x]` and all 43
are confirmed PASS, so no check-off or un-check-off action was required.

## Plan State

103 of 104 plan tasks are checked. The single unchecked task is `[P0-T2]`, a six-span Phase 0
task whose Span 3 is the `pwsh`-wrapped WSL route probe. That span was genuinely refused; the
artifact `evidence/baseline/baseline-git-state.2026-09-08T09-36.md` records
`EXIT_CODE: 1` with `ExpectedExitCode: 1` and an output summary beginning `ROUTE REFUSED`,
which is the branch the task text itself defines for that outcome. Leaving the task unchecked
because one of its six spans could not execute as written is the honest choice; the remaining
five spans are all recorded with exit 0. **No outstanding work is implied.**

## Behaviour Verified Against the Baseline

The `preserve` subcommand did not exist at the merge base. The new behaviour is additive:

- New dispatch arm `preserve | --preserve` in `main`, taking no operand.
- Two new sourceable libraries, sourced in dependency order before use.
- Two new environment seams, `CLEANUP_WT_MANIFEST_PATH` and `CLEANUP_WT_JQ_BIN`, both
  documented in the wrapper usage text.
- One new report record type, `PRESERVE|<worktree-path>|<source-path>|<verdict>`, documented
  in `SKILL.md` and in the wrapper usage text.
- A four-value exit contract: 0 clean, 1 skipped or index created, 3 host-token hard stop,
  127 tool unresolvable.

No existing arm, report record, or exit code changed. `run_report` and `run_apply` are
untouched, and `cleanup_worktrees_lib.sh` is byte-identical to the baseline.

## Composition With Issue 635

The directive asked whether the implementation assumes a paired `removals[]` record for each
`preserved_files[]` entry. **It does not.** `preserve_read_manifest`'s filter projects from
`(.preserved_files // [])[]` only and never references `.removals`. Every fixture manifest
carries `"removals": []`, so the unpaired case is demonstrated positively across the whole
suite rather than merely not relied upon. 635's ordering requirement — consolidation before
dirty content is discarded — is a sequencing obligation on the caller and is unaffected by
this implementation.

## Residual Items Carried Forward (not defects in this branch)

These are recorded in `spec.md` and correctly assigned elsewhere. They are listed so the
epic planner sees them together:

1. **O3 (OPEN, escalated).** If a manifest's `target_path` names the gitignored
   `.claude/agent-memory/**` root — as the current `SKILL.md` example does — every record is
   refused as `IGNORED-TARGET` and nothing is staged. This reviewer confirmed the path is
   ignored by `.gitignore:67` and that the rule applies in the consolidation worktree. The
   behaviour is defined, reported, and never forced, so the failure is visible rather than
   silent. This is the most consequential open item for the feature's first real use.
2. **Documentation correction 2.** `SKILL.md:410` still shows
   `pattern_set_id: "child-f-host-tokens-v1"`, which this implementation reports as
   `PATTERN-SET-MISMATCH` on every record. Advisory only; assigned to #635.
3. **O4 (resolved by spec, worth revisiting).** Duplicate detection keys on
   `basename(target_path)` while the bytes appended are `memory_index_line`; see code-review
   F4.
4. **Spec locator inconsistency.** AC-15 to AC-20 name the pre-split suite file; the D1
   pre-authorization names the post-split one. Reconcile the two.
