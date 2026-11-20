# Follow-Ups — Issue #791

- **Issue:** #791
- **Source:** `spec.md` decision D5 and AC-20
- **Recorded:** 2026-10-10T08-46

The two items below are out of scope for #791 (spec D5) and are recorded here for later work.

## Line-number re-derivation note

Spec D5 cites the line numbers observed at specification time. Each cited line was re-read on
2026-10-10 against the branch after its merge of `main`. The current line numbers are:

| File | Spec D5 lines | Current lines | Note |
| --- | --- | --- | --- |
| `.claude/skills/parallel-add/SKILL.md` | 99, 106, 148 | 101, 108, 150 | Two lines were added above line 99 by a `main` merge; content unchanged. |
| `.claude/skills/parallel-close/SKILL.md` | 49, 55, 65 | 49, 55, 65 | Unchanged. |
| `.claude/skills/parallel-orchestrate/SKILL.md` | 634, 789, 797 | 658, 813, 821 | Twenty-four lines were added above line 634 by a `main` merge; content unchanged. |
| `scripts/dev_tools/_parallel_mutation_errors.py` | 192 | 192 | Unchanged. |

## FU-791-1 — Port the remaining parallel engine-call prose to bash

Citations:

- `.claude/skills/parallel-add/SKILL.md` lines 99, 106, 148 (current 101, 108, 150): `decide_admission(...)` from `scripts/dev_tools/parallel_mutation_protocol.py`, the `recolor_unstarted(...)` call on the `DEFER_AND_RECOLOR` branch, and `build_add_entry`.
- `.claude/skills/parallel-close/SKILL.md` lines 49, 55, 65: `decide_close(items)` from `scripts/dev_tools/parallel_mutation_protocol.py`, `build_close_entry`, and the `recolor_unstarted` exclusion sentence.
- `.claude/skills/parallel-orchestrate/SKILL.md` lines 634, 789, 797 (current 658, 813, 821): the statement that the decision logic is `scripts/dev_tools/parallel_mutation_protocol.py`, the drift requeue through `build_requeue_entry` and `recolor_unstarted`, and the six-argument `recolor_unstarted(...)` call shape.
- `.claude/agents/parallel-orchestrator.md`: the `Bash(poetry run python -c *)` grant in the `tools` list.

Rationale: #791 ported only the `parallel-remove` decide, recolor, and entry steps to the bundled
entry point `.claude/lib/bash/remove-parallel-item.sh`. The `parallel-add`, `parallel-close`, and
`parallel-orchestrate` skills still instruct the agent to call functions of the repository-local
Python engine, which does not exist in a pushed-down destination workspace. Porting these call
sites to bash should reuse `.claude/lib/bash/parallel-mutation.sh` (which already implements the
recolor and remove-entry rules with Python parity) and add admission, close, add-entry, and
requeue-entry functions with their own parity corpora. Once no skill in the persona's caller set
invokes the Python engine, reassess whether the remaining inline-code (`-c`) grant in
`.claude/agents/parallel-orchestrator.md` can be removed.

## FU-791-2 — Fix the `UnknownEnumMemberError` member list for non-`state` fields

Citation:

- `scripts/dev_tools/_parallel_mutation_errors.py` line 192: `allowed = VALID_ITEM_STATES if field_name == "state" else VALID_MERGE_STATUS`.

Rationale: the error constructor selects the allowed-member list by testing only whether the field
is `state`; every other field falls through to the merge-status members. A rejected value for a
field such as `disposition` therefore produces a message listing merge-status values, which names
the wrong enum and misleads the caller. The bash port avoided reproducing this text by treating an
out-of-enum `--removal-disposition` as a usage error (exit 2), which is declared divergence 1 in
`.claude/lib/bash/remove-parallel-item.sh`. The fix is to map each field name to its own member
list (and fail explicitly for an unmapped field), with a unit test per field; when it lands, the
declared divergence can be re-evaluated.
