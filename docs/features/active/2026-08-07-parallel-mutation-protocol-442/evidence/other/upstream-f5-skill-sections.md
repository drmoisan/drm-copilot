# Upstream F5 SKILL Section Inventory and Wave-4 Ordering Verification (P1-T2)

Timestamp: 2026-08-08T21-44

Task: [P1-T2] Verify F5's reserved section names and the wave-4 section ordering in
`.claude/skills/parallel-orchestrate/SKILL.md`.

File read: `.claude/skills/parallel-orchestrate/SKILL.md` (F5, issue 441)
HEAD at read time: `c939b5b80c8c297db49febaebdd35dda2c869a3f`
File length at read time: 446 lines

Command: `grep -n "^## \|^# " .claude/skills/parallel-orchestrate/SKILL.md`

EXIT_CODE: 0

## Ordered Section Inventory (file order, exact heading text, line numbers at read time)

| Order | Line | Exact heading text |
| --- | --- | --- |
| — | 9 | `# Parallel Orchestrate Skill` (H1 title) |
| 1 | 37 | `## Prerequisites` |
| 2 | 46 | `## Parallel Manifest Consumption` |
| 3 | 83 | `## Cohort Consumption and Ordering` |
| 4 | 107 | `## Cohort Barrier and Max-Concurrency Slot Filling` |
| 5 | 147 | `## Per-Item Branch and Worktree Lifecycle` |
| 6 | 172 | `## Parallel-Mode Kickoff Parameter` |
| 7 | 213 | `## Model Selection` |
| 8 | 240 | `## Per-Item Merge to Main (Merge-on-Green)` |
| 9 | 275 | `## Per-Item Merge-Conflict Handling` |
| 10 | 313 | `## Worktree Cleanup` |
| 11 | 331 | `## Documentation Maintenance Boundaries` |
| 12 | 368 | `## Parallel-Level Checkpoint` |
| 13 | 410 | `## Completion Requirements` |
| 14 | 435 | **`## Mutation Protocol (F6)`** — F6's reserved target section |
| 15 | 439 | **`## Enforcement Hooks (F7)`** — F7's reserved section, immediately after F6's |
| 16 | 443 | **`## Radius Drift Detection (F8)`** — F8's reserved section, last in the file |

Seventeen `#`/`##` headings total: one H1 plus sixteen `##` sections.

## Exact Reserved Heading Text for F6

`## Mutation Protocol (F6)` — at line 435, character-for-character as quoted, including the
parenthesized `(F6)` suffix.

Its current body is the single placeholder sentence at line 437, quoted verbatim from the file:

```
## Mutation Protocol (F6)

Reserved for F6; content is appended by that feature and must not be relocated.
```

This is the one line P4-T4 replaces, and it is the ONLY line F4-T4 may remove.

## Exact Heading Text and Relative Position of the F7 and F8 Sections

```
## Mutation Protocol (F6)          <- line 435  (position 14 of 16)

Reserved for F6; content is appended by that feature and must not be relocated.

## Enforcement Hooks (F7)          <- line 439  (position 15 of 16)

Reserved for F7; content is appended by that feature and must not be relocated.

## Radius Drift Detection (F8)     <- line 443  (position 16 of 16, last section)

Reserved for F8; content is appended by that feature and must not be relocated.
```

Relative position confirmed: F6's section is **NOT the last section of the file**. It is followed, in
this exact order, by `## Enforcement Hooks (F7)` and then `## Radius Drift Detection (F8)`. The
file's final section is F8's, not F6's.

Consequence for P4-T4, restated from the observation: F6's appended content must END BEFORE the
`## Enforcement Hooks (F7)` heading at line 439. An "append at end of file" edit would write into or
past F8's section and is invalid.

## File Prose on Reservation and Cross-Referencing

Confirmed present at lines 30-35, quoted verbatim:

```
Every section below is self-contained. A cross-reference names another section by its exact
heading text, never by position or number, so a section can be added or extended without
reflowing, reordering, or renumbering anything else in this file. The sections
`## Mutation Protocol (F6)`, `## Enforcement Hooks (F7)`, and `## Radius Drift Detection (F8)`
are reserved for the wave-4 features named in them: each is appended to by its own feature and
must not be relocated.
```

Both elements of the expected state are present:

1. All three wave-4 sections are declared reserved for the named wave-4 features and declared as
   must-not-be-relocated.
2. Cross-references are required to name another section by its **exact heading text**, never by
   position or number. P4-T4 must therefore reference other sections by exact heading text only.

Line 428 additionally confirms F6's ownership of the close path from F5's side: "The run is a standing
queue and terminates only via `/parallel-close`, which is owned by F6 and is neither specified nor
shipped by this feature." This corroborates P4-T3's scope.

## Divergence Verdict

**NO DIVERGENCE.**

| Expected-state element (reconciled 2026-08-08 against `c939b5b8`) | Observed | Verdict |
| --- | --- | --- |
| Section reserved for F6 is named exactly `## Mutation Protocol (F6)` | line 435, exact match | matches |
| It currently holds the single placeholder sentence "Reserved for F6; content is appended by that feature and must not be relocated." | line 437, verbatim match | matches |
| It is NOT the last section of the file | position 14 of 16 `##` sections | matches |
| It is followed by `## Enforcement Hooks (F7)` | line 439, immediately after | matches |
| Then by `## Radius Drift Detection (F8)`, in that order | line 443, last section | matches |
| File prose states all three sections are reserved for the named wave-4 features and must not be relocated | lines 32-35, verbatim | matches |
| File prose states cross-references name a section by exact heading text, not position | lines 30-32, verbatim | matches |

None of the stop-rule conditions named in the task's acceptance clause holds: the reserved heading
text is not different, F6's section is not last, and the F7/F8 sections are neither absent nor
reordered. The phase stop rule is NOT triggered.

Output Summary: Read the landed F5 SKILL in full (446 lines) and recorded its complete ordered
inventory of 16 `##` sections plus the H1. F6's reserved section is named exactly
`## Mutation Protocol (F6)` (line 435) and holds exactly the one placeholder sentence "Reserved for
F6; content is appended by that feature and must not be relocated." (line 437). It is position 14 of
16 and is therefore NOT last: it is followed in this exact order by `## Enforcement Hooks (F7)` (line
439) and `## Radius Drift Detection (F8)` (line 443, the file's final section). The file's own prose
at lines 30-35 declares all three wave-4 sections reserved and must-not-be-relocated and requires
cross-references to name a section by exact heading text rather than position. Verdict: **NO
DIVERGENCE** against every element of the reconciled expected state; phase stop rule not triggered.

AC: S11, S12 (evidence recorded; check-off deferred to Phase 6 per the execution directive)
