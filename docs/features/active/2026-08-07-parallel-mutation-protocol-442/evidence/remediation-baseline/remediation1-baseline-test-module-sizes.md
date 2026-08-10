# Remediation Cycle 1 — Test-Module Line-Count and Call-Site Baseline

Timestamp: 2026-08-09T06-31

Task: [P0-T9]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Remediation cycle: 1
HEAD at capture: a9e2463c
Working tree at capture: clean (no remediation edit applied yet)

This artifact is captured BEFORE any edit, so the relocation arithmetic in the remediation plan's
`## Test-Module Relocation Arithmetic` section rests on measured values rather than assertion.

## Check 1 — Line counts

Command: `wc -l tests/scripts/dev_tools/test_parallel_mutation_protocol.py tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py scripts/dev_tools/parallel_mutation_protocol.py`
EXIT_CODE: 0

```
  498 tests/scripts/dev_tools/test_parallel_mutation_protocol.py
  499 tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py
  500 tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py
  370 tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py
  393 scripts/dev_tools/parallel_mutation_protocol.py
 2260 total
```

| File | Measured | Plan's stated baseline | Match |
| --- | --- | --- | --- |
| `test_parallel_mutation_protocol.py` | **498** | 498 | yes |
| `test_parallel_mutation_protocol_properties.py` | **499** | 499 | yes |
| `test_parallel_mutation_protocol_ops.py` | **500** | 500 exactly | yes |
| `test_parallel_mutation_abandon_cli.py` | **370** | n/a | recorded |
| `scripts/dev_tools/parallel_mutation_protocol.py` | **393** | n/a (cap 500) | recorded |

**No divergence from the plan's table. The budgets in `## Test-Module Relocation Arithmetic` stand
unchanged and require no recomputation before Phase 1 begins.**

## Check 2 — Enumerated call sites

Command: `grep -rn "recolor_unstarted\|decide_admission" tests scripts .claude`
EXIT_CODE: 0

### `tests/scripts/dev_tools/test_parallel_mutation_protocol.py` (498 lines)

- `recolor_unstarted` call sites — **8**: lines **140, 153, 168, 181, 191, 201, 214, 347**
- `decide_admission` call sites — **9**: lines **331, 339, 357, 375, 382, 391, 402 (two on the wrapped call beginning at 402), 409**
- Import references (not call sites): lines 44, 47
- `def test_` count: 37

### `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py` (499 lines)

- `recolor_unstarted` call sites — **5**: lines **172, 220, 291, 346, 493**
- `decide_admission` call sites — **3**: lines **335, 388, 492**
- Import references (not call sites): lines 50, 54; docstring references at 11, 18, 19, 162
- `def test_` count: 18

### `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` (500 lines)

- `recolor_unstarted` call sites — **0**
- `decide_admission` call sites — **0**
- **Confirmed: this 500-line module contains ZERO call sites for either changed function, so it
  requires no edit and must remain byte-unchanged.** ([P7-T9], [P7-T10] Check I)

### `tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py` (370 lines)

- `recolor_unstarted` call sites — **0**; `decide_admission` call sites — **0**

### Production modules

- `scripts/dev_tools/parallel_mutation_protocol.py`: `decide_admission` DEFINED at line 114 (`__all__` entry at 106); `recolor_unstarted` DEFINED at line 164 (`__all__` entry at 110); docstring reference at line 129 (the circular paragraph [P3-T2] deletes)
- `scripts/dev_tools/_parallel_mutation_models.py`: docstring references only at lines 117, 222, 290 (no call site)

### Documentation surface

- `.claude/skills/parallel-add/SKILL.md:68` — `decide_admission(candidate, conflict_edges, in_flight)` (three-argument, to be migrated by [P5-T1])
- `.claude/skills/parallel-add/SKILL.md:73` — `recolor_unstarted(unstarted_items, ...` (to be migrated by [P5-T1])
- `.claude/skills/parallel-remove/SKILL.md:81` — `recolor_unstarted(unstarted_items, conflict_edges, pinned, ...` (to be migrated by [P5-T2])
- `.claude/skills/parallel-close/SKILL.md:65` — a PROHIBITION on calling `recolor_unstarted` during a close; no call shape, so no change needed ([P5-T7])
- `.claude/skills/parallel-orchestrate/SKILL.md:571` — drift-requeue append contract reference (to be migrated by [P5-T3])
- The four corresponding bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/**` carry the same lines and are mirrored by [P5-T4] through [P5-T6]

One further match, `.claude/agent-memory/atomic-planner/feedback_fix_own_contract_not_defer.md:15`,
is agent-memory prose about this remediation cycle, not a call site or a documented call shape.

## Check 3 — Class spans relied on by the relocation tasks

Command: `grep -n "^class " <each module>`
EXIT_CODE: 0

`test_parallel_mutation_protocol.py`:
```
83:class TestEnumConsumption:
128:class TestPinnedItemsNeverMove:
208:class TestGenerationAccounting:
325:class TestAdmissionOverAllItems:
414:class TestCompletionPredicate:
474:class TestRecolorResultValueObject:
```
`TestPinnedItemsNeverMove` starts at **128** and the next class starts at 208, so its span ends at
its last code line **205** — confirming the plan's corrected 128-205 span (approximately 78 lines)
and its six `recolor_unstarted` call sites at 140, 153, 168, 181, 191, 201.
`TestAdmissionOverAllItems` starts at **325** and the next class starts at 414, so its span ends at
its last code line **411** — confirming the plan's 325-411 span (approximately 87 lines).

`test_parallel_mutation_protocol_properties.py`:
```
86:class GeneratedRun:
204:class TestPropertyOneDeterminism:
260:class TestPropertyTwoIndependentSets:
299:class TestPropertyThreePinStability:
371:class TestPerFunctionProperties:
```
`TestPropertyThreePinStability` starts at **299** and the next class starts at 371, so its span ends
at its last code line **368** — confirming the plan's corrected 299-368 span (approximately 70
lines) and that the `decide_admission` call site at line **335** and the `recolor_unstarted` call
site at line **346** both lie INSIDE it and relocate with it under [P4-T9]. The only
`decide_admission` call site remaining in that module after the relocations is line **492**, and
the remaining `recolor_unstarted` call sites are **172, 220, 291, 493** — exactly as the plan's
iteration-4 auditability corrections state.

Output Summary: Line counts measured at 498 / 499 / 500 / 370 / 393, matching the plan's table
exactly with no divergence, so no budget recomputation is required. Call sites enumerated with
line numbers: 8 recolor + 9 admission in `test_parallel_mutation_protocol.py`; 5 recolor + 3
admission in `test_parallel_mutation_protocol_properties.py`; **0 and 0 in
`test_parallel_mutation_protocol_ops.py`** and in `test_parallel_mutation_abandon_cli.py`. Class
spans confirm 128-205, 325-411, and 299-368.
