# Gate — confinement of the spec.md shape-6 correction and the closeout additions

Timestamp: 2026-08-20T09-53

Task: [P9-T6]

Command: git diff --no-index -U0 -- <scratchpad>/spec.before-p9t6.md docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/spec.md
EXIT_CODE: 1

## Why a non-zero exit is the expected outcome, and why a plain diff cannot be used here

`--no-index` compares the two named paths without consulting the index and exits `1` when they differ.
The two files DO differ — that is the point of the task — so exit `1` is the expected outcome and not a
failure.

A plain diff against a commit could not discriminate. The spec file was UNTRACKED at authoring time,
and once the feature folder is committed a diff against the merge-base baseline reports every line of
the file, including the whole eleven-shape table, as added. Either way the gate could not tell a
confined correction from a wholesale rewrite. The snapshot was taken AFTER the [P9-T2] check-offs, so
those checkbox flips fall outside this comparison by construction.

## Changed-line inventory (line numbers and counts only)

Total: **39 added lines, 2 modified lines** across four hunks.

| Hunk | Post-change line range | Kind | Content class |
| --- | --- | --- | --- |
| 1 | 177 | 1 line replaced in place | the Invariant B mechanism-1 sentence |
| 2 | 399 | 1 line replaced in place | the Test Strategy sentence |
| 3 | 542-568 | 27 lines inserted | new `### Delivered outcome (recorded 2026-08-20)` subsection |
| 4 | 571-580 | 10 lines inserted | new first bullet of `### Post-fix monitoring or clean-up tasks` |

## Confinement assertions

- **Zero changed lines fall inside `spec.md:401-413`**, the eleven-shape table. The table's row 1 is at
  line 403 and its row 6 at line 408 in the post-change file; the nearest changed line is 399, four
  lines above the table's first row. No table row was altered.
- **Zero changed lines fall inside any `- [ ]` or `- [x]` acceptance-criterion item.** The 25
  acceptance-criterion items occupy lines 479-503; the four hunks touch 177, 399, 542-568, and 571-580,
  none of which intersects that range. The only earlier modification to those lines was the [P9-T2]
  check-off flips, which the snapshot deliberately excludes.
- The two replaced sentences are the only prose edits. Both now scope the exactly-one-`EXIT_CODE:`
  property to shapes 01-05 and 07-11 and name shape 06 as the deliberate two-`EXIT_CODE:` exception
  whose expected record is runtime-specific because the spec defers convergence of duplicate-`EXIT_CODE`
  precedence.
- The trailing clause of the line-177 sentence — previously "so the deferred duplicate-`EXIT_CODE`
  divergence cannot confound the comparison", which is FALSE when read over all eleven shapes — is now
  scoped to "for those ten shapes", and the sentence states shape 06's exclusion from the cross-runtime
  agreement assertion explicitly.
- No spec context line is reproduced in this artifact, by design, so this artifact cannot acquire a
  parseable expectation key line (SC7).

Output Summary: 39 added and 2 modified lines across four hunks at post-change lines 177, 399, 542-568,
and 571-580. Zero changed lines fall inside `spec.md:401-413` (the eleven-shape table, whose rows sit at
403-413) and zero fall inside any acceptance-criterion item (lines 479-503). The two in-place
replacements are exactly the two sentences the task names; the insertions are the delivered-outcome
subsection and the widened deferred-defect bullet. The `--no-index` run exits `1` because the two files
differ, which is the expected outcome for this gate.
