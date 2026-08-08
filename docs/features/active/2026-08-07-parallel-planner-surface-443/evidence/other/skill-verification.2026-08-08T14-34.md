# Skill Verification — `.claude/skills/parallel-plan/SKILL.md`

Timestamp: 2026-08-08T14-34
Task: [P5-T12]
Subject: `.claude/skills/parallel-plan/SKILL.md`

## Size Check

Command: `wc -l .claude/skills/parallel-plan/SKILL.md`
EXIT_CODE: 0
Output Summary: `420 .claude/skills/parallel-plan/SKILL.md`

- Measured line count: **420**
- Hard requirement (`.claude/rules/general-code-change.md`, File Size Limit): under 500 — **PASS**
- Plan target range: approximately 220-300 — **exceeded by 120 lines; recorded as a deviation
  below.**

### Size deviation record

The plan's target range is an approximation ("target approximately 220-300, hard requirement under
500"); the binding acceptance criterion is "the line count is under 500", which the file satisfies
at 420.

The overrun is attributable to the content mandated by [P5-T2] through [P5-T11], which is denser
than the epic-plan precedent the range was estimated from. Specifically:

- [P5-T5] requires four landed-signature bullets, the serialized key set, the reason vocabulary,
  the F1a correction paragraph, and a five-step planner procedure — 58 lines.
- [P5-T9] requires two full sections: the complete top-level and per-item checkpoint field sets,
  the four-invariant readiness contract, the F4-owned git-integrity attribution, the cache
  doctrine, a four-item F3-owned surface list, the kickoff-ownership statement, and the
  single-item-run disposition — 65 lines.
- [P5-T10] requires a fenced kickoff template plus four structural-requirement bullets — 60 lines.

One compression pass was applied to the introduction (removing a section list that duplicated the
frontmatter `description` and the heading structure), reducing the file from 425 to 420 lines. No
further reduction was made because every remaining paragraph is named by a task acceptance
criterion, and removing content would fail those criteria. No content was dropped to meet the
approximate range.

## Negative-Constraint Checks

Command: `Grep pattern='worthiness|depends_on|wave|integration branch|integration_branch|conflicts\(a, b\)|pinned|python -m|Epic mode: true|Parallel mode: true' path='.claude/skills/parallel-plan/SKILL.md' output_mode=content -n=true -i=true`
EXIT_CODE: 0
Output Summary: 10 matching lines returned. Every match was audited below; no match is a prohibited
construct.

Supporting command: `grep -n 'Preparation mode: true' .claude/skills/parallel-plan/SKILL.md`
EXIT_CODE: 0
Output Summary: the preparation kickoff line is line 72; line 78 is the properties bullet that
quotes the two markers.

| # | Constraint | Pattern | Matches | Result |
| --- | --- | --- | --- | --- |
| 1 | No epic-worthiness gate analogue | `worthiness` (case-insensitive) | 4, all negations | PASS |
| 2 | No `depends_on` authoring instruction | `depends_on` | 2, both prohibitions | PASS |
| 3 | No wave-design section | `wave` (case-insensitive) | 4, all citations of epic-surface names | PASS |
| 4 | No integration-branch creation instruction | `integration branch` / `integration_branch` | 2, both negations | PASS |
| 5 | No two-argument `conflicts(a, b)` form | `conflicts\(a, b\)` | 0 | PASS |
| 6 | No pinned-set reference | `pinned` (case-insensitive) | 0 | PASS |
| 7 | No `python -m` CLI instruction for F1 or F2 | `python -m` | 0 | PASS |
| 8 | `Epic mode: true` absent from the kickoff line | `Epic mode: true` | 1, at line 91 (omission statement); kickoff line is line 72 | PASS |
| 9 | `Parallel mode: true` absent from the kickoff line | `Parallel mode: true` | 1, at line 92 (omission statement); kickoff line is line 72 | PASS |

### Per-match audit

**Check 1 — `worthiness` (4 matches, all negations).**

- Line 18: "there is no worthiness assessment".
- Line 59: "The operator is never asked for ordering edges, cohort assignments, or a worthiness
  verdict."
- Line 300: "`**Deliberately absent:** any `epic_worthiness` analogue`" — a checkpoint-field
  prohibition.
- Line 301: "The parallel surface renders no worthiness verdict".

No `## `-level worthiness-gate heading exists. Verified separately with
`Grep pattern='^## .*([Ww]orthiness|[Ww]ave|[Dd]ependenc)'`, which returned zero matches at
[P5-T1] and remains satisfied: the fourteen `##` headings are Prerequisites, Item Intake,
Preparation Fan-Out, Artifact Home, Radius Computation and Validation, Cohort Seeding, Manifest
Authoring, Checkpoint Persistence, F3 Ownership Boundary, Kickoff Artifact, Completion Report, plus
Invocation Prompt / Item Summary / Integrity, which are headings inside the fenced kickoff
template rather than skill sections.

**Check 2 — `depends_on` (2 matches, both prohibitions).**

- Line 274: "The manifest carries no `depends_on` field at any level".
- Line 300: "`**Deliberately absent:** ... any `depends_on` field`".

Both are required by the acceptance criteria of [P5-T8] and [P5-T9] respectively. Neither is an
authoring instruction; the constraint under verification is the absence of an instruction to author
the field, and a prohibition on writing it satisfies that constraint. The matches are recorded here
rather than suppressed so the check is auditable. No authoring instruction exists.

**Check 3 — `wave` (4 matches, all epic-surface proper names or negations).**

- Line 91: `enforce-epic-wave-barrier.ps1` — the hook filename named in the deliberate-omission
  rationale.
- Line 146: `scripts/dev_tools/epic_wave_computation.py` — the import-only-library precedent cited
  by [P5-T5].
- Line 246: "the analogue of the epic planner's wave-number cross-check" — the F3 planner-invariant
  P5 quotation required by [P5-T7].
- Line 300: "any `wave` field" in the deliberate-absence statement required by [P5-T9].

There is no wave-design section and no wave-assignment instruction.

**Check 4 — integration branch (2 matches, both negations).**

- Line 119: "That branch is explicitly not an integration branch: no item branch ever merges into
  it, it never merges into any item branch".
- Line 274: "no top-level `integration_branch` field; both are prohibited-key rejections in the
  schema".

No integration-branch creation instruction exists.

**Checks 8 and 9 — mode markers.** The preparation kickoff line is line 72 and contains neither
marker. The two literal strings appear only at lines 91-92, inside the `**Deliberate omissions.**`
paragraph that explains why each is absent, which is what [P5-T3]'s acceptance criterion requires.

## Supplementary Positive Checks (recorded for completeness)

| Element | Pattern | Matches | Result |
| --- | --- | --- | --- |
| Three-argument contention signature | `conflicts(a, b, config)` | 2 | PASS |
| Landed cohort signature | `compute_cohorts(item_keys, conflict_edges)` | 1 | PASS |
| Config truth table named | `config/blast-radius.json` | 3 | PASS |
| Preparation markers present | `Preparation mode: true`, `route_id: preparation` | line 72 and line 78 | PASS |
| Preparation base ref | `origin/main` | present | PASS |

## Verdict

All negative checks pass. Line count 420 is under the 500-line hard limit. The measured length
exceeds the plan's approximate 220-300 target by 120 lines; the deviation is recorded above with
its cause and is not remediated, because every remaining line is required by a task acceptance
criterion.
