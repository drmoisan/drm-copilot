# Code Review — issue 637, preserve-file consolidation

Timestamp: 2026-09-08T12-21
Branch: `bug/cleanup-worktrees-preserve-file-consolidation-637-r2`
HEAD: `ed975b747b8b5915b8c6b592d9deb7bab2738aa0`
Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` (merge base `fff74314`)

Overall assessment: **the change is of high quality and is safe to merge.** Zero blocking
findings. Seven non-blocking findings are recorded, four of which are already disclosed in
`spec.md` and correctly assigned elsewhere.

## What Was Reviewed

Production: `scripts/bash/cleanup_worktrees_preserve_lib.sh` (492 lines, new),
`scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` (212 lines, new),
`scripts/bash/cleanup-worktrees.sh` (+39 lines).

Tests: three bats suites totalling 43 tests, plus a `jq` stub and roughly 60 checked-in
fixture scenario directories.

## The Three Substantive Properties

The directive named three properties as the substance of the work and asked whether the
delivered code and tests establish them in both directions, on bytes rather than parsed
text. Each is assessed below against the code as read and against evidence re-derived by
this reviewer.

### (a) MEMORY.md index lines carried across verbatim — ESTABLISHED

The renderer writes the line's own bytes and supplies only a terminator
(`preserve_render_index_append`, EOL library). It performs no separator normalization and
no re-rendering.

The positive direction is asserted in `the memory index line is appended verbatim to the
destination index` with a payload deliberately containing an em dash and a parenthesised
markdown link:

    local line="- [Appended lesson](appended-lesson.md) — carried across verbatim, separator included"
    run preserve_render_index_append /dev/stdout "$line" lf no
    [ "$output" = "$line" ]

An implementation that normalized the separator fails this equality. The same test also
asserts the checked-in index is *unchanged* afterwards, which pins that the read-only phase
wrote nothing.

The drop direction is covered by `an absent destination index is created and reported as
CREATED` (an index that does not exist is created rather than the line being dropped, and
the outcome deliberately contributes to exit 1 so it cannot pass silently). The duplicate
direction is covered by `a duplicate index entry is skipped and does not change the exit
code`, which additionally asserts the file is still copied and staged, so the duplicate
suppresses only the append. Both assert on `PRESERVE_EXIT` directly, not merely on output
text.

### (b) Target line endings preserved exactly — ESTABLISHED, on bytes

This is the property most at risk on a Windows host, and the tests handle it correctly.
The line-ending assertions do not compare captured strings. They count bytes through a
pipe:

    run bash -c "source '${EOLLIB}' && preserve_render_index_append /dev/stdout '${line}' crlf no | tr -dc '\r' | wc -c"
    [ "$output" -eq 1 ]
    run bash -c "source '${EOLLIB}' && preserve_render_index_append /dev/stdout '${line}' lf no | tr -dc '\r' | wc -c"
    [ "$output" -eq 0 ]

The test file states the reason explicitly: command substitution strips trailing line
feeds and on a Windows host strips a trailing CRLF pair whole, so both terminators would
capture as the empty string and a string comparison could not fail. That is exactly right,
and it is the difference between a test that pins the property and one that cannot.

Every line-ending test carries a negative control. `an unterminated final line receives a
terminator before the append` asserts both that the unterminated fixture owes a terminator
(status 0) and that a terminated fixture does not (status 1) — without the second, the test
would pass against an implementation that always answered yes.

The advisory field is genuinely re-derived, not trusted. `preserve_derive_line_ending`
reads the target's current bytes; `preserve_plan_index` compares the advisory value against
the derived one, emits `ADVISORY-MISMATCH` on disagreement, and assigns
`PRESERVE_INDEX_TERM="$derived"`. The test `a stale advisory crlf value does not override
an LF target` closes the loop with a byte assertion on the destination index:

    [[ "$index_content" != *$'\r'* ]]

**Independently re-derived by this reviewer.** The CRLF fixture's integrity was verified
against git's object store rather than the working tree, which is the stronger check:

    git cat-file blob HEAD:tests/.../preserve/eol-crlf/MEMORY.md | od -c
      → # Memory Index \r \n \r \n - [Existing lesson](existing-lesson.md) ... \r \n

    git cat-file blob HEAD:tests/.../eol-crlf/mixed-index/.../MEMORY.md | od -c
      → ... crlf-entry.md) - ends with CRLF \r \n - [A line feed terminated entry](lf-entry.md) ... \n

The index blobs really do carry CRLF, and the mixed fixture really does mix. The
`.gitattributes` exception is correctly scoped and correctly ordered — `git check-attr text`
reports `unset` for the two `eol-crlf/**` paths and `auto` for a sibling fixture outside
that directory, so the `-text` line overrides `* text=auto eol=lf` for exactly the intended
subtree and nothing more.

### (c) Host tokens refused fail-closed by a read-only pre-pass — ESTABLISHED

The ordering property holds structurally, which is stronger than holding by test. All
scanning occurs in `preserve_plan`; all writing occurs in `preserve_commit_plan`;
`run_preserve` enters the second only when the first returns 0. `preserve_plan` evaluates
the hard stop *after* the record loop completes:

    while IFS= read -r line; do
        [[ -n $line ]] || continue
        preserve_plan_one "$line" || PRESERVE_EXIT=1
    done <<<"$sorted"
    ((PRESERVE_BLOCKED == 0)) || return 3

Because `preserve_plan_one` returns 1 on a match rather than aborting, the loop continues
and every match is reported, not just the first. This reviewer read every operation
reachable from phase 1 — `check-ignore`, `grep`, `preserve_derive_line_ending`,
`preserve_index_has_entry`, `preserve_index_needs_terminator` (`tail -c 1`) — and confirms
all are read-only. There is no per-record check interleaved with staging.

Both directions are pinned. Refusal: `each host token pattern is detected` asserts exit 3,
one diagnostic per identifier HT1–HT6, a count of exactly six `HOST-TOKEN-BLOCKED` records,
and `[ "${#PRESERVE_PLAN_STREAM[@]}" -eq 0 ]` — nothing reached the writing phase for *any*
record, not only the matching ones. Acceptance: `HEAD~1 and other revision syntax do not
match the short-name pattern` asserts a legitimate payload is still staged at exit 0, so
the refusal is not a blanket reject. `the host token scan reads only the named source file`
pins the scope from both sides: it asserts no refusal, and then asserts with `grep -c` that
the tokens really are present in the manifest and the destination index, so the test is not
passing because the fixture forgot to carry them.

The upstream advisory is not trusted in either direction. A `clean` claim still triggers the
local scan (the `host-token` fixture's own record says `clean` and is refused anyway), and a
`tokens_present` claim short-circuits to refusal even though that fixture's bytes are clean —
and the test proves the file is clean with a `grep` that must return non-zero.

## Test Quality Assessment

The directive flagged the eleven coverage-remediation tests in
`test_cleanup_worktrees_preserve_failures.bats` as the most likely to be assertion-light,
since they were written to raise a coverage number. **That suspicion is not borne out.**
Each of the eleven asserts a specific diagnostic string, a specific `ACTION|` record, a
negative control that no staging call occurred, and the `PRESERVE_EXIT` accumulator value.
For example, the five writing-phase failure branches are individually discriminated:

- `a failed staging call is reported as FAILED` asserts `stub-git: -C /dev add -- null` was
  logged (so every earlier operation in the chain ran and succeeded) and that the failure
  text is `the staging call failed`.
- `a failed index staging call is reported as FAILED` asserts **both** argv lines, which is
  the only thing distinguishing it from the previous branch.

Two patterns deserve specific credit because they are the difference between a real gate and
a vacuous one:

1. **Loop-count assertions.** `an absent or malformed host_token_scan refuses to stage the
   record` iterates a glob and then asserts `[ "$count" -eq 5 ]`, with the stated reason
   that a glob matching no directory would leave every assertion unexecuted and the test
   would pass having checked nothing. The field-matrix test does the same with 8.

2. **Operand-anchored absence assertions.** The suites use
   `add_re='stub-git: .*[[:space:]]add[[:space:]]'` rather than the literal `stub-git: add`,
   with the reason recorded: the stub logs its full argv including the leading `-C
   <worktree>`, so the literal form could never match and therefore could never fail. This
   is precisely the "verification gate that cannot fail" failure mode, identified and
   avoided.

Similarly, `an unresolvable jq returns 127 and stages nothing` asserts *two* things because
bash returns 127 for "command not found" as well — a failed source or a misspelled function
would produce 127 and pass a status-only assertion.

Test count grew 343 → 386 (+43), matching exactly the 26 + 6 + 11 tests across the three new
suites.

## Findings

### F1 — Major (non-blocking): the production `jq` filter has zero execution coverage

**Location:** `scripts/bash/cleanup_worktrees_preserve_lib.sh:111-124` (the filter literal
in `preserve_read_manifest`); `tests/fixtures/cleanup_worktrees/preserve/stub-bin/jq`.

The `jq` stub never parses JSON. It replays a hand-authored `jq.out` byte stream and an
optional `jq.rc` from the scenario directory. Consequently the ~14-line jq program — which
is the single point where the manifest is validated and projected into the 14-column TSV
contract — is never executed by any test. The correspondence between each checked-in
`manifest.json` and its sibling `jq.out` is maintained by hand and nothing verifies it.

This also means AC-06 does not test what its wording suggests: the `bad-tool` and
`bad-schema` scenarios supply `jq.rc = 5`, so the test pins the shell's handling of a
non-zero `jq` exit, not that the filter rejects those manifests. The coverage-remediation
artifact independently corroborates this: lines 111–123 are among the uncovered lines and
are attributed to being interior lines of a single multi-line statement.

**Verification performed.** `jq` is not installed on this host, so the filter could not be
executed to compare against the fixtures. This reviewer instead derived the expected output
by hand for four representative scenarios and compared byte-for-byte against the checked-in
`jq.out` files: `untracked` (a `null` `memory_index_line`, giving `true`/`true`/empty),
`field-matrix/memory-index-line-key-absent` (giving `false`/`true`/empty), and the
`scan-malformed` cases `absent` (`type` → `null`), `not-an-object` (`type` → `string`),
`missing-result`, `missing-pattern-set-id`, and `result-out-of-vocabulary`. **All sampled
derivations are correct**, including the `has()`/`== null` distinction and the `type`
projection. `jq` exiting 5 on an uncaught `error()` is also correct.

**Why this is not blocking.** The stub design is what `spec.md` prescribes — the Test
Strategy section states the suites run "against new checked-in fixture scenario directories"
and the suite headers state "no real jq is ever invoked." Spec open question O14 records the
related decision that CI need not install `jq` precisely because no test needs it. No
acceptance criterion requires the filter to execute. The sampled fixtures are correct.

**Recommendation (follow-up, not a merge blocker).** Add one contract test, gated on a real
`jq` being present, that runs the production filter over each checked-in `manifest.json` and
compares stdout and exit code against the sibling `jq.out`/`jq.rc`. That single test would
convert the hand-maintained correspondence into an enforced one and would give the filter
real coverage, at the cost of the `jq` dependency O14 already contemplates.

### F2 — Minor: the CRLF direction of the terminator join is not asserted

**Location:** `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh`, `preserve_plan_index`;
`tests/shell/test_cleanup_worktrees_preserve_eol.bats:113-155`.

`preserve_plan_index` joins derivation to rendering with one assignment,
`PRESERVE_INDEX_TERM="$derived"`. The tests assert that join only for the LF case
(`[ "$PRESERVE_INDEX_TERM" = "lf" ]` inside the ADVISORY-MISMATCH test). The CRLF test
asserts the two halves separately — that `preserve_derive_line_ending` returns `crlf` for
the CRLF fixture, and that `preserve_render_index_append` with token `crlf` emits exactly
one carriage return — but never asserts `PRESERVE_INDEX_TERM = "crlf"` against a CRLF
target. A hypothetical implementation that hardcoded `PRESERVE_INDEX_TERM="lf"` would pass
every test in the file.

The residual risk is small: the assignment is a single unconditional statement that the LF
case does exercise, and the AC-18 test comment reasons the composition explicitly. But the
directive asked specifically whether the CRLF-does-not-become-LF direction is pinned end to
end, and strictly it is pinned in two pieces rather than through the join.

**Recommendation.** Add one line to `a crlf target receives a crlf terminated index line`:
call `preserve_plan_index` against a target under `preserve/eol-crlf/` and assert
`[ "$PRESERVE_INDEX_TERM" = "crlf" ]`. One statement closes the gap.

### F3 — Minor: `jq @tsv` escapes are not decoded, so "verbatim" has four exceptions

**Location:** `scripts/bash/cleanup_worktrees_preserve_lib.sh`, the `@tsv` projection and
`preserve_split_tsv`.

`jq`'s `@tsv` escapes tab, newline, carriage return, and backslash as two-character
sequences. `preserve_split_tsv` splits on literal tabs and performs no unescaping. A
`memory_index_line` containing a literal backslash would therefore be written to the index
as `\\`, and one containing a tab, CR, or LF would be written with the escape sequence
literal — contradicting the byte-verbatim property for those four characters.

**Severity rationale.** Narrow in practice. MEMORY.md index lines in this repository are
markdown link lines with no backslashes, and any Windows path containing a backslash would
be refused by the HT1 host-token pattern before reaching the index. The AC-11 test does not
cover this because it drives the renderer directly rather than the manifest path.

**Recommendation.** Either decode the four `@tsv` escapes in `preserve_split_tsv`, or record
the limitation in the library header alongside the existing note explaining why tab was
chosen as the transport delimiter.

### F4 — Observation: duplicate detection keys on a different field than the one written

**Location:** `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh`, `preserve_index_has_entry`;
called from `preserve_plan_index` with `"${tgt##*/}"`.

The duplicate predicate compares the existing index line's markdown link target against
`basename(target_path)`, but the bytes appended are `memory_index_line`. Nothing constrains
those to agree. If a manifest's index line links to a name other than the target's basename,
duplicate suppression never fires and a re-run appends the line again — the exact duplicate
outcome the feature exists to prevent.

**This is not an implementation defect.** `spec.md:571-575` specifies the predicate in
exactly these terms ("a line whose markdown link target ... equals the basename of
`target_path`"), resolved as open question O4. The implementation is faithful to the spec.
Both the `index-duplicate` and `index-append` fixtures happen to have aligned values, so
only the aligned case is exercised.

**Recommendation (spec-level follow-up).** Either validate at consumption that the index
line's link target equals `basename(target_path)` and skip the record as invalid when it
does not, or match on the index line's own link target. This is a change to the O4
resolution and belongs with the spec owner, not this branch.

### F5 — Observation (already disclosed): `SKILL.md` still shows `child-f-host-tokens-v1`

**Location:** `.claude/skills/cleanup-merged-worktrees/SKILL.md:410` and its push-down mirror.

The example manifest an editorial pass copies still carries
`"pattern_set_id": "child-f-host-tokens-v1"`. The delivered library owns and expects
`cleanup-wt-host-tokens-v1`, so a manifest authored from the template emits
`ACTION|preserve-scan|<target>|PATTERN-SET-MISMATCH` on **every** record.

Verified: the production code uses `cleanup-wt-host-tokens-v1` consistently. The
`child-f-...` literal appears in only four places repository-wide — `SKILL.md:410`, its
mirror, and the two `pattern-set-id/` fixtures that deliberately exercise the mismatch path.
The identifier requirement from the directive is satisfied.

Already disclosed in `spec.md` "Documentation corrections" item 2, which states the corrected
value and assigns the `SKILL.md` fix to #635, which owns that step. The consequence not
spelled out there is the per-record report noise. The behaviour is advisory only and does not
change the exit code, so nothing breaks.

### F6 — Observation (already disclosed): the example `target_path` is gitignored

**Location:** `.claude/skills/cleanup-merged-worktrees/SKILL.md:405`.

The example's `target_path` is `.claude/agent-memory/general-purpose/...`. This reviewer
confirmed with `git check-ignore -v --no-index` that this path is ignored by `.gitignore:67`
(`.claude/agent-memory`), and that the ignore rule applies in any worktree of this
repository including the consolidation worktree. A manifest built from the template would
therefore have every record refused as `IGNORED-TARGET` at exit 1, staging nothing.

Already disclosed and escalated: `spec.md` open question **O3** states the question in
exactly these terms and marks it "OPEN — escalate to the epic planner," and the Risks table
carries the matching row with the mitigation that the failure is visible rather than silent.
The fixtures use a tracked `agent-memory/...` destination (confirmed not ignored), which is
the namespace under which the design works.

This is correctly out of scope for this child. It is recorded here because it is the single
most consequential open item for the feature's first real use.

### F7 — Minor: maintenance headroom and a path-form inconsistency

- `cleanup_worktrees_preserve_lib.sh` stands at 492 of the 500-line cap. The next change to
  it will very likely require another split. The spec's pre-authorized split has already been
  spent on the EOL group, so a future split needs a fresh placement decision.
- `preserve_commit_plan` stages the target with a repo-relative path (`add -- "$tgt"`) but
  the index with an absolute one (`add -- "$ipath"`, built as `"$cwt/${tdir}MEMORY.md"`).
  Git accepts both, and the failure tests assert the absolute form, so behaviour is correct
  and pinned. The inconsistency is cosmetic.

## Points of Positive Note

- **`preserve_split_tsv` avoids a real bug that `IFS=$'\t' read` would have introduced.**
  Tab is an IFS whitespace character, so `read` collapses runs of tabs and strips leading and
  trailing ones; a record with an empty `memory_index_line` column would silently shift every
  later column left and land the evidence value in the pattern-set-id variable. The library
  walks the string with parameter expansion instead, and the header comment states the reason.
  This is the kind of defect that would have produced confusing downstream failures.

- **Idempotence under partial failure.** If the index append succeeds but its staging call
  fails, the line is already in the file. A re-run detects it via `preserve_index_has_entry`
  and reports `SKIPPED-DUPLICATE` rather than appending twice. The pass self-heals.

- **No force flag anywhere.** An ignored destination is refused rather than forced, with the
  reason recorded: forcing would produce a commit that appears to preserve the lesson while
  push-down never distributes it. AC-30 asserts the output contains no `--force`.

- **Composition with issue 635 is correct.** `preserve_read_manifest` reads only
  `.preserved_files[]` and never touches `.removals`, so a `preserved_files[]` entry whose
  `worktree_path` has no matching removal record is handled normally. Every fixture manifest
  carries `"removals": []`, which demonstrates the unpaired case positively rather than
  merely not depending on the pairing.

- **The coverage remediation was honest.** The residual uncovered lines were attributed to
  kcov's line-attribution behaviour for multi-line statements, and that attribution was
  *confirmed by a `PS4`/`set -x` probe* rather than asserted. No production path was excluded
  to make a number move.
