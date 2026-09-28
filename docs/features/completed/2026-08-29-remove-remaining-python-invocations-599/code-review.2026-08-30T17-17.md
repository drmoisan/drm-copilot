# Code Review — remove-remaining-python-invocations (Issue #599)

- Timestamp: 2026-08-30T17-17
- Branch: `feature/remove-remaining-python-invocations-599-r2` vs `main`
- Merge base: `8b94217e198a484956a20297922db211d51d3faa`
- Scope: full branch diff, 114 files, +6294 / -221
- Method: full read of both new production files, the four new/changed test suites, all seven
  mirrored documentation edits, and direct execution probes of the shipped entry point against
  the Python reference.

## Summary

The change ports a Python-only advisory diagnostic to bash so the published `.claude` payload
carries no interpreter dependency for that step, and removes two redundant CLI spellings that
already had an MCP equivalent. The design follows the two existing cross-runtime ports closely:
a pure sourceable library plus a thin I/O entry point, guarded by `BASH_SOURCE[0] == "${0}"`,
with a shared parity corpus read by both a bats lane and a pytest lane.

Overall quality is high. The code is readable, the comments explain intent rather than restate
syntax, the divergences from the reference are deliberately enumerated, and the test suite is
substantially more thorough than the change size would predict. The evidence trail is unusually
complete — including a recorded coverage failure that was diagnosed and remediated by adding
tests rather than by excluding the file.

One correctness finding is remediation-required (CR-1). Three findings are minor.

## Findings

### CR-1 — Major, remediation required: newline in `--edges` silently truncates the edge list

**Location:** `.claude/lib/bash/parallel-lane-assertion.sh:86` (and its byte-identical mirror).

```bash
read -ra tokens <<<"$text"
```

`read` consumes exactly one line. Every token after the first newline in the `--edges` value is
discarded without a message. The Python authority splits with `str.split()`
(`scripts/dev_tools/parallel_lane_assertion.py:425`), which treats `\n` as an ordinary
whitespace separator.

Reproduced on this branch against the same manifest and the same input:

```
--edges $'999:998\n101:202'   bash   -> "Lane assertion: 2 derived conflict component(s); 0 disagreement(s)."
--edges $'999:998\n101:202'   python -> "Lane assertion: 1 derived conflict component(s); 0 disagreement(s)."
```

Why this matters here specifically: `spec.md:352-358` uses the opposite claim as its stated
reason for excluding whitespace from divergence class 3 — "The port specified here consumes the
same whitespace-separated token stream, so it cannot observe interior whitespace either" — and
`spec.md` frames class 3 as having "exactly these four members". The divergence set is presented
as exhaustive and is not. Neither the corpus nor any unit case covers the newline input, so the
gap is invisible to the suites.

Mitigating context, which bounds the severity: the diagnostic is advisory-only and always exits
0, both documented invocation forms are single-line, and the same `read -ra <<<` pattern is
pre-existing in the sibling entry point. `compute-cohorts.sh` was probed with the equivalent
input and also mishandles it (`--keys "101 202 303" --edges $'101:202\n202:303'` yields
`[[101,303],[202]]`, not a valid partition). This finding is therefore about the completeness of
this feature's exhaustive parity claim, not a regression it introduces.

**Recommended remediation** — either is sufficient:

1. Declare and pin it. Add divergence class 6 to `spec.md`, narrow the class-3 whitespace
   paragraph to space and tab, and add a bash-only unit case in the same shape as the existing
   class-3 case. Smallest change; consistent with the sibling's behavior.
2. Close it. Normalize newlines before tokenizing, for example by iterating lines and appending
   each line's tokens, and add a convergence fixture to the shared corpus. This moves the port
   away from its siblings' behavior and should not be done without considering
   `compute-cohorts.sh` at the same time.

### CR-2 — Minor: the entry point mutates the caller's locale at source time

**Location:** `.claude/lib/bash/report-lane-assertion.sh:37`.

`pc_enforce_c_locale` is called at top level, outside the `BASH_SOURCE[0] == "${0}"` guard. The
guard's stated purpose (`report-lane-assertion.sh:163`) is that "the file can be sourced without
executing main", and `tests/shell/report_lane_assertion_dispatch.bats:36` depends on exactly
that. Sourcing the file therefore does have an observable side effect on the sourcing shell's
`LC_ALL`.

This is benign in practice — every consumer that sources the file wants the C locale anyway, and
the sibling entry points do the same — but the placement slightly contradicts the guard's stated
contract. Moving the call inside `rla_main`, before the first argument is read, would preserve
the ordering property that `parallel_lane_assertion.bats:255` pins while removing the
source-time effect. Not blocking.

### CR-3 — Minor: file-wide `shellcheck disable=SC2034`

**Location:** `.claude/lib/bash/parallel-lane-assertion.sh:26-30`.

The suppression is justified inline with a correct and specific reason: the class-token
constants and result globals are written here and read by the entry point, which shellcheck
analyses as a separate translation unit. `.claude/rules/shell.md` requires a justified inline
comment, which is present.

The concern is scope, not legitimacy. A file-wide disable will also mask a genuinely dead
variable introduced later in this 495-line file. Per-declaration `# shellcheck disable=SC2034`
comments on the eleven affected globals, or a single `# shellcheck source=` directive plus
targeted disables, would keep the same clean result while preserving the check for future
additions. Not blocking.

### CR-4 — Minor / informational: quadratic membership tests

**Locations:** `pla_count_distinct` (`:280-295`) and the `pc_contains_word` guards in
`pla_derive_components` (`:227-230`).

Both perform linear scans inside a loop, so cost is quadratic in the member count. At the
motivating scale the spec names — 13 lanes over 69 items — this is immaterial, and the corpus
fixture `scale_thirteen_lanes_matching.json` exercises it. Recorded so a future scale increase
has a known place to look. No action recommended now.

## What the change does well

These are recorded because they are non-obvious choices worth preserving, not as praise.

1. **The pure / I/O seam is the same one the reference declares for itself.** The split point is
   taken from `parallel_lane_assertion.py:34-38` rather than invented, and matches both existing
   sibling ports. That makes the three ports comparable to a reader and keeps the entry point at
   169 lines.

2. **M1 message strings are reused, not restated.** `report-lane-assertion.sh:155` prints
   `${PC_ERRORS[0]}` produced by `pm_parse_manifest` rather than re-spelling the message. The
   comment at `:153-154` states the reason: the two lanes cannot drift on wording. This is the
   right call and it is documented at the site.

3. **The out-of-subset path is a distinct line, not folded into "unparseable".** The comment at
   `:144-147` explains that a scanner refusal is not a verdict about the manifest, because the
   Python authority would parse the document. Test-pinned at
   `parallel_lane_assertion.bats:363` including an explicit assertion that the refusal line is
   *not* the unparseable line.

4. **Ordering is made a function of the graph rather than of hash iteration.** The comment at
   `:233-237` reasons that a component's first BFS root is necessarily its smallest member, so
   the component sequence needs no second sort. Both associative arrays are documented as never
   iterated (`:268-269`), so no hash order can reach output. This is the load-bearing property
   for byte-level parity and it is argued rather than asserted.

5. **The kcov attribution problem was diagnosed, not worked around.** The first per-file run
   reported `line-rate="0.814"` for the entry point. The executor identified the specific kcov
   limitation, confirmed it by an isolated single-suite run that reproduced 0.814 exactly, and
   remediated by adding in-process dispatch cases that are *additional to* the subprocess cases
   rather than replacing them — the subprocess cases remain the authority for process exit
   status and stream routing, which an in-process call cannot certify. No production code was
   changed and no file was excluded. The whole reasoning chain is in
   `evidence/qa-gates/bash-new-file-coverage.2026-08-30T20-45.md`.

6. **The divergence pinning tests include controls.** The class-3 test
   (`parallel_lane_assertion.bats:395`) asserts four rejected forms produce a 2-component
   header, then asserts a well-formed edge produces a 1-component header. Without that control
   the four assertions would also pass against an entry point that ignored `--edges` entirely.
   The same pattern appears in the no-production-consumer test (`:454-457`), which verifies the
   grep pattern actually matches somewhere in the tree.

7. **The non-ASCII digit case is written as explicit UTF-8 bytes.**
   `$'\xd9\xa1\xd9\xa0\xd9\xa1'` at `parallel_lane_assertion.bats:417` keeps the test file ASCII
   so the value does not depend on the locale in which the file is read. The reason is stated in
   the comment.

8. **Advisory-only semantics are pinned structurally, not just behaviorally.**
   `parallel_lane_assertion.bats:431` walks every file in `.claude/lib/bash/` and asserts that
   nothing but the entry point sources the library and that nothing sources the entry point.
   That is the assertion that actually prevents the diagnostic from acquiring a scheduling
   consumer later.

## Test Quality Assessment

| Dimension | Assessment |
| --- | --- |
| Placement | Correct. `tests/shell/*.bats` and `tests/scripts/dev_tools/*.py`; no colocation in `.claude/lib/bash/` |
| Temp files | None. Verified by grep for `mktemp`, `/tmp`, `BATS_TMPDIR`, `BATS_TEST_TMPDIR` across all four suites — zero matches. Every input is a file literal or a checked-in fixture |
| Determinism | No clock read, no RNG, no `sleep`. Verified by grep. `pc_enforce_c_locale` pins collation |
| Independence | Each `setup()` re-sources and resets; parity lanes are data-driven over checked-in JSON |
| Isolation | Unit cases target single functions; dispatch cases target single `rla_main` arms; parity cases target whole-report identity. Failure attribution is clear |
| Vacuity guards | `MINIMUM_FIXTURE_COUNT=20` declared and asserted in both lanes (23 fixtures present); the bats lane carries a `python3 is available` case; the corpus test asserts `manifest_text` matches `manifest_path` so a record cannot drift from its fixture |
| Negative coverage | Four usage-error arms, unreadable file, unreadable directory, unparseable manifest, out-of-subset manifest, five malformed `--edges` token shapes, four rejected integer lexis forms |
| Scenario completeness | All four finding classes; absent, empty-string, and non-string `name`; dropped and all-dropped members; duplicate member; shared item across components; self-loop; undeclared endpoint; reversed and duplicated edges; 13-lane / 69-item scale |
| Gap | The newline-in-`--edges` input is covered by no case in either lane. See CR-1 |

## Documentation Edits

The five markdown edits were read in full against the shipped behavior.

- `parallel-plan/SKILL.md:318-323` — the invocation is replaced and the grant note is corrected
  in the same edit, which is what resolves the live payload contradiction the spec describes.
  Lines 322-329 and 569-573 are semantically unchanged, as required.
- `parallel-planner.md` — the `tools:` grant prefix matches the documented invocation exactly.
  The entry-point count (three -> four) and the sourceable-library count (six -> seven) were
  independently recomputed against the 11 files in `.claude/lib/bash/` and are correct. The
  stale sentence at the old 185-186 is replaced with an accurate one.
- `parallel-orchestrator.md:92-97` — the rationale no longer names the deleted consumer. The
  rewrite correctly narrows "two named consumers" to one while keeping the per-invocation-form
  scoping of the grant.
- `epic-orchestrate/SKILL.md:295-299` and `parallel-orchestrate/SKILL.md:480-483` — the CLI
  spellings are deleted and `require_complete` is explicitly retained on the MCP call, so no
  capability is lost at the completion gate.

No documentation edit overstates what shipped. Each is consistent with the code as read.

## Recommended Actions

| Priority | Action |
| --- | --- |
| Required | CR-1: declare and pin the newline-in-`--edges` divergence in `spec.md` plus a bash-only unit case, or close it in `pla_parse_edges` with a convergence fixture |
| Optional | CR-2: move `pc_enforce_c_locale` inside `rla_main` so sourcing has no side effect |
| Optional | CR-3: narrow the `SC2034` suppression from file-wide to per-declaration |
| None | CR-4: recorded for future scale work only |
