# Phase 4 Consequential Repairs (ESCALATED) — Issue #440 (F7)

Timestamp: 2026-08-08T22-24

Command: `poetry run pytest tests/scripts/dev_tools/ -q`

EXIT_CODE: 0

## Status: ESCALATION, not a plan task

Two test failures appeared that are neither Phase 4 tasks nor either authorized absorption. Both are
mechanical consequences of work the plan and the absorptions REQUIRE, and neither existed before this
delegation. They are recorded here and escalated in the completion report rather than silently absorbed.
No new phase or task was invented; each repair is the narrowest edit that removes a regression this
delegation introduced.

## Repair 1 — Reserved-Body Pin Invalidated by P4-T4

**Failing test:**
`tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_orchestrate_skill_reserved_sections_carry_one_line_reserved_body`

**Cause.** The F5-authored pin iterates `pinned.RESERVED_HEADINGS` and asserts every reserved section's
body still equals its one-line placeholder sentence. Its stated intent, quoted from the test comment, is
that "no wave-4 content has been added ahead of its own feature." P4-T4 mandates replacing exactly the
F7 placeholder body with F7's content, so the pin and the plan task are in direct mechanical conflict.
F7's content is not ahead of its own feature; it IS its own feature.

**Repair, narrowest form.** `RESERVED_HEADINGS` was NOT modified, so the heading-identity, ordering, and
uniqueness pins in `test_orchestrate_skill_reserved_wave_four_sections_close_the_file` continue to cover
all three headings including F7's. Only the one-line-body pin was narrowed, by exempting sections whose
owning feature has landed:

- Added to `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`:
  `LANDED_WAVE_FOUR_FEATURES: frozenset[str] = frozenset({"F7"})`, with a comment stating that each
  wave-4 feature adds its own token when it appends its section.
- Added to the failing test: a `continue` for a heading whose feature is in that set.

The pin remains fully in force for F6 and F8: if either feature's content were added before that
feature lands, the test would still fail.

**Fan-in warning (third contended surface).** These two files are a THIRD fan-in surface shared with the
concurrently executing F6 (#442) and F8 (#446), beyond the two named in the plan's wave-4 contention
constraint (`.claude/skills/parallel-orchestrate/SKILL.md` and
`scripts/dev_tools/validate_parallel_orchestrator_state.py`). F6 and F8 will each hit the identical
failure when they append their own reserved section, and each will need to add its own token to
`LANDED_WAVE_FOUR_FEATURES`. The constant was deliberately shaped as a one-token-per-feature set so each
addition is a single additive line. This surface is NOT named in the approved plan and should be recorded
in the epic's contention register.

## Repair 2 — Pack-Manifest Completeness Broken by Absorption B

**Failing test:**
`tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest`

**Cause.** Absorption B's mandated mirror places two new files under
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. A separate contract requires
every bundled `.claude` file to appear in the union of the pack manifests. The failure named exactly the
two files this feature added:

```
AssertionError: Bundled .claude files missing from every manifest: ['.claude/hooks/enforce-parallel-cohort-barrier.ps1', '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1']
```

Absorption B's own contract test (`test_push_down_claude_resource_contracts.py`) cannot pass without the
mirror, and this manifest test cannot pass with the mirror unless the manifest is updated, so the two
entries are mechanically required by the absorption.

**Repair, narrowest form.** Two entries appended to
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` in alphabetical
position, between `enforce-orchestration-preimplementation-gate.ps1` and
`enforce-pr-author-skill.epic-base-branch.ps1`, matching the file's existing sorted-path convention and
the placement of the four sibling `enforce-epic-*` hooks in the same list:

```json
    ".claude/hooks/enforce-parallel-cohort-barrier.ps1",
    ".claude/hooks/enforce-parallel-worktree-removal-gate.ps1",
```

No existing manifest entry was modified, reordered, or removed, and no other manifest file was touched.
The `.codex` pack manifest was deliberately NOT touched: the `.codex` tree is outside this feature's
scope and the delegation prohibits editing the codex suites.

The TypeScript counterpart `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`
required no change: its `it.each` list is a fixed issue-#279 presence assertion over unrelated epic
paths, and its completeness case reads the real manifests, which now include both entries.

## Verification

| Check | Result |
| --- | --- |
| `poetry run black .` | `376 files left unchanged` |
| `poetry run ruff check .` | `All checks passed!` |
| `poetry run pyright` | `0 errors, 0 warnings, 0 informations` |
| `poetry run pytest tests/scripts/dev_tools/ -q` | `2950 passed` (0 failed) |
| `poetry run pytest -q` (full suite) | `3038 passed` (0 failed) |

No assertion was deleted or loosened in Repair 1 beyond the documented landed-feature exemption, and the
heading-order pin covering all three reserved sections is untouched.

## Output Summary

ESCALATED and repaired. Two test failures appeared as mechanical consequences of required work and were
fixed with the narrowest possible edits. Repair 1: P4-T4's mandated replacement of the F7 placeholder
body invalidated the F5-authored one-line-reserved-body pin, whose stated intent is to catch content
added ahead of its own feature; the pin was narrowed by a new `LANDED_WAVE_FOUR_FEATURES` frozenset
holding only `F7`, leaving `RESERVED_HEADINGS` and the heading-order/uniqueness pins untouched and the
body pin fully in force for F6 and F8. Repair 2: Absorption B's mandated bundle mirror added two files
that the pack-manifest completeness contract requires to be listed, so both were appended in
alphabetical position to `pack-manifests/core.json` with no existing entry altered. Notably, the two
files touched by Repair 1 form a THIRD fan-in surface with the concurrent F6 and F8 features that the
approved plan does not name; F6 and F8 will each need to add their own one-line token, and the epic's
contention register should record this. Post-repair: black/ruff/pyright clean, `2950 passed` for
`tests/scripts/dev_tools/`, `3038 passed` for the full suite, zero failures.
