# Cross-Cutting Scope Gates (Issue #479, Phase 5)

Timestamp: 2026-08-17T02-25

All commands in this phase are read-only checks against the accumulated diff. The merge base is
`eb4ce14c245ecff8a4491e4a8fda3e43e14356e3` (`git merge-base origin/main HEAD`), abbreviated
`$MB` below.

Vacuity guard: every new file this feature adds was registered with `git add -N`
(intent-to-add) in `[P3-T10]`, so `git diff --name-only "$MB"` and `git grep` see all of them.
`git status --porcelain --untracked-files=no` reports 60 modified tracked paths at this point,
so no diff check below can pass because work is merely uncommitted and invisible.

---

## [P5-T1] Enforcement-layer non-modification gate (AC14 diff half)

| Check | Command | EXIT_CODE | Result |
|---|---|---|---|
| No `.ps1` file in the diff | `git diff --name-only "$MB" \| grep -i "\.ps1$"` | 1 | **zero matches** |
| Layer-2 Python barrier absent | `git diff --name-only "$MB" \| grep "_parallel_orchestrator_state_cohort_barrier"` | 1 | **zero matches** |
| Layer-2 TypeScript port absent | `git diff --name-only "$MB" \| grep "parallel-orchestrator-state-cohort-barrier.ts"` | 1 | **zero matches** |

All three conditions hold. The two TypeScript files under
`extensions/drm-copilot/src/lib/validate/` that DO appear in the diff are
`parallel-orchestrator-state-core.ts` and `parallel-planner-state-core.ts`, which carry only
D2's `MAX_CONCURRENCY` constant change. The barrier port
`parallel-orchestrator-state-cohort-barrier.ts` is untouched.

Suite corroboration (beyond the plan's requirement, run here for completeness):
`poetry run pytest tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py -q`
-> `64 passed in 0.12s`, unmodified. The Layer-1 Pester suite is discharged by `[P7-T11]`.

---

## [P5-T2] Epic-surface non-modification gate (AC19)

Command: `git diff --name-only "$MB" | grep -iE "epic"`

EXIT_CODE: 1 -> **zero matches**. Neither `validate_epic_orchestrator_state.py`,
`validate_epic_planner_state.py`, their TypeScript ports, nor any epic test appears in the diff.

Command: `poetry run pytest tests/scripts/dev_tools -k "epic" -q`

EXIT_CODE: 0 -> `192 passed, 3610 deselected in 0.96s`.

The epic bound is textually unchanged: `validate_epic_orchestrator_state.py:121` and
`validate_epic_planner_state.py:312` still read
`max_parallel_features must be an integer from 1 through 8`.

---

## [P5-T3] Template/pack gate (AC37)

- Directory inspection: `find extensions/drm-copilot/resources -type d -name parallel` returns
  **nothing**. No `templates/parallel` path exists under `extensions/drm-copilot/resources/`, so
  `docs/features/templates/parallel/parallel-status.md` remains unmirrored, as intended.
- `git diff --name-only "$MB" | grep "pack-manifests/core.json"` -> EXIT_CODE 1, **zero
  matches**. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
  is unmodified. This is expected: no new `.claude` file was created by this feature (the new
  Python module lives under `scripts/dev_tools/`).

---

## [P5-T4] TypeScript divergence-class gate (AC39)

Command: `git diff --name-only "$MB" | grep -E "parallel-state-shared\.ts|parallel-state-structures\.ts"`

EXIT_CODE: 1 -> **zero matches**. Neither known-divergence file is modified, so the
`pythonRepr` quote-selection class (`parallel-state-shared.ts:112-132`) and the boolean/integer
`===` class (`parallel-state-structures.ts:228`) are neither entered nor "fixed".

### Fixture review (every fixture added or changed by this feature, by name)

Changed by `[P2-T8]` (6):

| Fixture | Values it exercises | Divergence-class exposure |
|---|---|---|
| `manifest_m4_above_upper_bound.json` | integer `33` | none — plain `int` |
| `manifest_m4_below_lower_bound.json` | integer `0` | none — unchanged value, error text only |
| `manifest_m4_boolean_rejected.json` | boolean `true` | PRE-EXISTING boolean-rejection case, unchanged in value; only the interpolated bound moved |
| `manifest_m4_non_integer.json` | string `"four"` | none — a plain lowercase string with no apostrophe, so `pythonRepr` quote selection is not exercised |
| `manifest_multiple_identity_errors_in_field_order.json` | integer `33`, string `'paused'` | none — no apostrophe in either value |
| `manifest_accessor_open_mode_max_cap.json` | integer `32` | none |

Added by `[P3-T7]` (13):

| Fixture | Values it exercises | Divergence-class exposure |
|---|---|---|
| `manifest_m8_valid_named_component.json` | ints `101`, `102`; string `hooks-lane` | none |
| `manifest_m8_valid_unnamed_component.json` | ints `101`, `102` | none |
| `manifest_m8_not_a_list.json` | string `hooks-lane` | none |
| `manifest_m8_entry_not_an_object.json` | string `hooks-lane` | none |
| `manifest_m8_missing_members.json` | string `hooks-lane` | none |
| `manifest_m8_empty_members.json` | empty flow list `[]` | none — the empty flow collection is inside the bash subset |
| `manifest_m8_members_not_a_list.json` | int `101` | none |
| `manifest_m8_non_positive_member.json` | int `0` | none |
| `manifest_m8_boolean_member.json` | boolean `true` | boolean value in a NUMERIC slot; rejected identically by both runtimes via the same `isinstance(..., bool)` / `type == bool` guard the pre-existing `manifest_m4_boolean_rejected.json` already exercises. It does NOT enter the `parallel-state-structures.ts:228` `===` class, which concerns a checkpoint-side selector, not the manifest layer. Verified locally: both lanes emit `found: True.` |
| `manifest_m8_non_integer_member.json` | string `"101"` | none — digits only, no apostrophe |
| `manifest_m8_member_resolves_to_no_item.json` | ints `101`, `999` | none |
| `manifest_m8_duplicate_membership_across_components.json` | ints `101`, `102` | none |
| `manifest_m8_empty_string_name.json` | empty string `""` | none — an empty string renders `''` in both runtimes |

No fixture added or changed exercises an integral float (deliberately excluded; see
`backward-compat-corpus.2026-08-17T02-05.md`), a quote-divergent string (none contains an
apostrophe), or a boolean-equality selector beyond the pre-existing boolean-rejection class.

---

## [P5-T5] No-JSON-Schema gate (AC40)

### (a) No schema file added

Command: `git diff --name-only --diff-filter=A "$MB" | grep -E "\.schema\.json$|schema.*\.json$"`

EXIT_CODE: 1 -> **zero matches**. No `*.schema.json` or equivalent schema file is added.

### (b) No ADDED JSON-Schema import in any touched module

Command: `git diff "$MB" -- scripts/dev_tools extensions/drm-copilot/src | grep -nE "^\+.*(jsonschema|json-schema)"`

EXIT_CODE: 1 -> **zero ADDED lines**.

Pre-existing matches, recorded as OUT OF SCOPE (neither file is touched by this feature):

- `scripts/dev_tools/validate_discovery_schema_artifacts.py` — 4 matching lines, including
  `from jsonschema import Draft202012Validator`.
- `scripts/dev_tools/validate_json.py` — 8 matching lines.

Total 12 pre-existing matches, matching the plan's recorded count. Neither file appears in
`git diff --name-only "$MB"`.

### (c) No NEW reference to the disqualified artifact

Command (scoped to every surface outside this feature's own planning documents):

```
git diff "$MB" -- . ':(exclude)docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/**' ':(exclude)docs/features/potential/**' | grep -nE "^\+.*mix-calculator"
```

EXIT_CODE: 1 -> **zero ADDED lines**. No rule file, validator, test, fixture, skill, or agent
gained a `mix-calculator` reference.

Pre-existing intentional prohibition citations, untouched:

- `.claude/rules/orchestrator-state.md:7`
- `.claude/rules/orchestrator-state.md:9`
- `.claude/rules/parallel-orchestration.md:9`

All three deliberately quote the disqualified `$id` in order to RECORD the prohibition. The
diff of `.claude/rules/parallel-orchestration.md` touches none of them (its only deletions are
invariant 4, M4, and the A7 opening paragraph).

Recorded exception, with reason: the unscoped form of the command also matches **5** added
lines inside this feature's own planning documents —
`plan.2026-08-16T22-09.md` (2), `spec.md` (2), and
`research/2026-08-16T23-00-lane-scale-and-barrier-semantics-research.md` (1). Every one is
itself a statement of the prohibition ("Nothing references the disqualified
`drmoisan.github.io/mix-calculator/` artifact", and the plan task text quoting this very gate),
authored by the planner in the branch's base commit `a43deb73`, not by execution. They are the
same intentional-citation class as the three rule-file lines and introduce no schema reference.
The scoped command above is the operative gate; this note records the unscoped result so the
difference is auditable rather than hidden.

---

## Gate summary

| Task | AC | Outcome |
|---|---|---|
| P5-T1 | AC14 (diff half) | PASS |
| P5-T2 | AC19 | PASS |
| P5-T3 | AC37 | PASS |
| P5-T4 | AC39 | PASS |
| P5-T5 | AC40 | PASS |
