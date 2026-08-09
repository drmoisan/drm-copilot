# Wave-4 Shared-File Confinement and Additive-Only Verification ([P7-T10])

Timestamp: 2026-08-09T03-49

Task: [P7-T10] Verify shared-file confinement and the additive-only constraint from the branch diff.

Feature: `docs/features/active/2026-08-07-parallel-mutation-protocol-442` (issue #442)
Branch: `feature/parallel-mutation-protocol-442`
Comparison base: **`c939b5b8`** — the P1-T1-recorded reconciliation base. Every diff below is pinned to
that commit, never to the moving `origin/epic/parallel-orchestration-integration` tip.

EXIT_CODE: 0 for every diff command below.

## Check A — No Epic Contention, No F3 Schema Change

Command: `git diff --stat c939b5b8 -- .`

```
 .claude/settings.json                              |   4 +
 .claude/skills/parallel-orchestrate/SKILL.md       | 145 ++++++++++-
 .../plan.md                                        | 276 +++++++++++++--------
 .../spec.md                                        |  55 ++--
 .../user-story.md                                  |  18 +-
 .../claude-customizations/.claude/settings.json    |   4 +
 .../.claude/skills/parallel-orchestrate/SKILL.md   | 145 ++++++++++-
 .../claude-customizations/pack-manifests/core.json |   4 +
 .../PoshQC/settings/pester.runsettings.psd1        |   5 +
 .../validate_parallel_orchestrator_state.py        |   2 +
 .../PoshQC/settings/pester.runsettings.psd1        |   5 +
 .../parallel_orchestrator_surface_expectations.py  |   7 +
 ...test_parallel_orchestrator_surface_contracts.py |  15 +-
 13 files changed, 541 insertions(+), 144 deletions(-)
```

Thirteen modified tracked files. Not one is an epic artifact or an F3 schema definition. Confirmed by
four targeted scoped diffs, each of which produced EMPTY output with exit code 0:

| Scoped diff | Output | Verdict |
| --- | --- | --- |
| `git diff --stat c939b5b8 -- ".claude/hooks/enforce-epic-*"` | empty | PASS — no `enforce-epic-*` hook modified |
| `git diff --stat c939b5b8 -- ".claude/skills/*epic*" ".claude/agents/*epic*"` | empty | PASS — no epic skill or epic agent modified |
| `git diff --stat c939b5b8 -- "scripts/dev_tools/*epic*" "scripts/dev_tools/_parallel_state_common.py" "scripts/dev_tools/_parallel_state_structures.py" "scripts/dev_tools/_parallel_state_records.py" "scripts/dev_tools/validate_parallel_planner_state.py" "scripts/dev_tools/parallel_manifest_contract.py"` | empty | PASS — no epic validator and no F3 schema/validator helper modified |
| `git diff --stat c939b5b8 -- ".claude/rules/"` | empty | PASS — no rule file modified, including `.claude/rules/parallel-orchestration.md` |

New (untracked) files added by F6, none of them an epic or F3 artifact:

- Production Python: `scripts/dev_tools/parallel_mutation_protocol.py`, `_parallel_mutation_models.py`,
  `parallel_mutation_abandon_cli.py`, `_parallel_orchestrator_state_mutations.py`,
  `_parallel_mutation_errors.py`, `_parallel_mutation_entries.py`,
  `_parallel_orchestrator_state_mode_completion.py`
- Production PowerShell: `.claude/hooks/enforce-parallel-abandon-gate.ps1`
- Skills: `.claude/skills/parallel-add/SKILL.md`, `parallel-remove/SKILL.md`, `parallel-close/SKILL.md`
- Tests: `tests/scripts/dev_tools/test_parallel_mutation_protocol.py`,
  `test_parallel_mutation_protocol_ops.py`, `test_parallel_mutation_protocol_properties.py`,
  `test_parallel_mutation_abandon_cli.py`, `test_parallel_abandon_token_seam.py`,
  `test_validate_parallel_orchestrator_state_mutations.py`,
  `test_validate_parallel_orchestrator_state_mutation_modes.py`,
  `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`
- Bundle mirrors of the four new `.claude/**` files (see out-of-table edit 2)

**Check A verdict: PASS.**

## Check B — SKILL.md In-Section Confinement

Command: `git diff c939b5b8 -- .claude/skills/parallel-orchestrate/SKILL.md`

`--numstat`: **144 added, 1 removed.**

The diff consists of **exactly one hunk**:

```
@@ -437 +437,144 @@ else.
```

The single removed line is exactly the F6 placeholder sentence and nothing else:

```
-Reserved for F6; content is appended by that feature and must not be relocated.
```

Because there is only one hunk, every other section of the file is byte-identical to the base by
construction; no section was relocated, reflowed, reordered, or retitled.

Post-edit wave-4 heading positions:

```
435:## Mutation Protocol (F6)
582:## Enforcement Hooks (F7)
586:## Radius Drift Detection (F8)
```

| Sub-check | Result |
| --- | --- |
| Added lines only inside `## Mutation Protocol (F6)` | PASS — the hunk starts at line 437, two lines after the F6 heading at 435, and its 144 added lines end at 580, before the F7 heading at 582 |
| Exactly the one placeholder line removed | PASS — 1 removal, and it is that sentence verbatim |
| `## Enforcement Hooks (F7)` present and unmodified | PASS — present at 582; outside the single hunk |
| `## Radius Drift Detection (F8)` present and unmodified | PASS — present at 586; outside the single hunk |
| Three wave-4 headings in the original relative order | PASS — 435 < 582 < 586, the same F6 → F7 → F8 order recorded by P1-T2 |
| No F6-added line at or after the F7 heading | PASS — highest added line is 580; F7 heading is 582 |
| File length | 588 lines, Markdown (cap-exempt) |

**Check B verdict: PASS.**

## Check C — Validator Confinement

Command: `git diff c939b5b8 -- scripts/dev_tools/validate_parallel_orchestrator_state.py`

`--numstat`: **2 added, 0 removed.**

```diff
@@ -35,6 +35,7 @@ from __future__ import annotations
 import json
 from typing import cast

+from scripts.dev_tools import _parallel_orchestrator_state_mutations as mutation_rules
 from scripts.dev_tools._parallel_state_common import (
@@ -321,6 +322,7 @@ def validate_parallel_orchestrator_state_text(
     errors.extend(_validate_identity(state_map))
     errors.extend(scan_prohibited_keys(state_map, CONTEXT))
     errors.extend(_validate_collections(state_map))
+    errors.extend(mutation_rules.validate_mutation_protocol(state_map, CONTEXT))

     # BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION
```

Post-edit line positions, read from the file:

```
324     errors.extend(_validate_collections(state_map))
325     errors.extend(mutation_rules.validate_mutation_protocol(state_map, CONTEXT))
327     # BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION
```

| Sub-check | Result |
| --- | --- |
| Exactly one added import line | PASS — line 38, `import ... as mutation_rules` |
| Exactly one added call line | PASS — line 325 |
| Zero removed lines | PASS — `2 0` numstat |
| Call sits after `errors.extend(_validate_collections(state_map))` | PASS — 324 then 325 |
| Call sits before the `# BEGIN F7 EXTENSION SEAM` comment | PASS — 325 then 327 |
| Seam block byte-identical to the base | PASS — programmatic comparison of the substring from `# BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` through `# END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` in base and head returned `seam byte-identical: True` (8-line block). F6 wrote nothing inside F7's seam |
| `if require_complete:` block and `_validate_completion` call untouched | PASS — outside the two hunks |
| File length | 336 → **338** lines, under the 500 cap |

**Check C verdict: PASS.**

## Check D — Settings Confinement

Command: `git diff c939b5b8 -- .claude/settings.json`

`--numstat`: **4 added, 0 removed** — one JSON object appended to the `PreToolUse` → `Bash` matcher
`hooks` array, and nothing else.

```diff
@@ -114,6 +114,10 @@
           {
             "type": "command",
             "command": "pwsh -NoProfile -File .claude/hooks/enforce-epic-worktree-removal-gate.ps1"
+          },
+          {
+            "type": "command",
+            "command": "pwsh -NoProfile -File .claude/hooks/enforce-parallel-abandon-gate.ps1"
           }
         ]
```

Bash-matcher array read back from the parsed JSON:

```
0 pwsh -NoProfile -File .claude/hooks/validate-bash.ps1
1 pwsh -NoProfile -File .claude/hooks/enforce-promotion-mcp-only.ps1
2 pwsh -NoProfile -File .claude/hooks/enforce-pr-author-skill.ps1
3 pwsh -NoProfile -File .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
4 pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1
5 pwsh -NoProfile -File .claude/hooks/enforce-epic-worktree-removal-gate.ps1
6 pwsh -NoProfile -File .claude/hooks/enforce-parallel-abandon-gate.ps1
```

Indices 0-5 are the six pre-existing entries in exactly the order P1-T7 recorded; the new entry is
appended at index 6 after the observed final entry `enforce-epic-worktree-removal-gate.ps1`. No
`enforce-epic-*` registration was modified, reordered, or removed. No other key of the file changed.

**Check D verdict: PASS.**

## Check E — No Schema Growth

No field was added to `mutations[]`, `drift_events[]`, or `conflict_edges[]`, and no member was added to
any of the nine parallel enums. Evidence:

1. `.claude/rules/parallel-orchestration.md` — the authoritative schema and enum prose — is unmodified
   (Check A scoped diff over `.claude/rules/` is empty).
2. The F3 schema/validator helper modules `_parallel_state_common.py`, `_parallel_state_structures.py`,
   and `_parallel_state_records.py` are unmodified (Check A scoped diff is empty).
3. The new validator helper consumes the seven-field shape and the four-member `op` vocabulary as
   constants read from F3's landed shape, adding nothing:

```python
MUTATION_ENTRY_FIELDS: tuple[str, ...] = tuple(
    "op item_key at prior_state new_state disposition recolor_generation".split()
)
CLOSE_OP = "close"
ITEM_SCOPED_OPS: tuple[str, ...] = tuple("add remove requeue".split())
OPS_WITH_NULL_PRIOR_STATE: tuple[str, ...] = tuple("add close".split())
OPS_WITH_NULL_NEW_STATE: tuple[str, ...] = (CLOSE_OP,)
```

   That is exactly F3's seven fields, exactly the four-member `op` set partitioned as
   `close` + `{add, remove, requeue}`, and exactly the landed nullability rule. No eighth field, no
   fifth `op`.
4. The mode-completion helper imports `VALID_MODES` and `MERGED_MERGE_STATUSES` from
   `_parallel_state_common` rather than restating or extending them, so the `mode` and `merge_status`
   enums are consumed from F3's definitions.
5. `disposition` values are consumed as the F3 pair `detach | abandon`; no third disposition exists
   anywhere in the new code.

**Check E verdict: PASS.**

## Check F — No Dependency Change

Command: `git diff c939b5b8 -- pyproject.toml poetry.lock`

Output: **empty**, exit code 0. No dependency was added, removed, or version-changed. This confirms the
P1-T6 determination that `hypothesis` is not added and that property tests use seeded
`random.Random(seed)` instead.

**Check F verdict: PASS.**

## Out-of-Table Edits — Four Edits Beyond the Plan's Confinement Table

The plan's Wave-4 Contention Constraint table names three shared files. Execution necessarily touched
four further paths. Each is recorded here with its diff shape and justification rather than left
implicit. None of them touches an `enforce-epic-*` hook, an epic validator, an epic skill, an epic
agent, `.claude/rules/**`, or any F3 schema definition — verified by the Check A scoped diffs above.

### Out-of-table edit 1 — Landed F5 surface-contract test invalidated by [P4-T4]

Files and diff shape:

| File | Added | Removed |
| --- | --- | --- |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 7 | 0 |
| `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | 12 | 3 |

Why the edit was unavoidable: a test landed by F5,
`test_orchestrate_skill_reserved_sections_carry_one_line_reserved_body`, asserted that **all three**
reserved wave-4 sections still hold their one-line placeholder body. [P4-T4] is the task that replaces
the F6 placeholder with F6's content, so that landed assertion becomes false the moment F6 does the work
the plan mandates. The assertion cannot be satisfied and the plan executed at the same time.

Edit shape — a minimal, merge-friendly append, not a restructure:

```python
POPULATED_RESERVED_HEADINGS: tuple[str, ...] = ("## Mutation Protocol (F6)",)
```

plus a two-line skip guard in the test loop:

```python
    for heading in pinned.RESERVED_HEADINGS:
        if heading in pinned.POPULATED_RESERVED_HEADINGS:
            continue
```

The rest of the 12/3 delta is docstring text explaining the skip. `RESERVED_HEADINGS` itself is
unchanged, so the final-headings, uniqueness, and ordering obligations continue to apply to the
populated section; only the placeholder-body assertion is scoped down.

**F7 and F8 each need a one-line append to this tuple** when they populate their own sections:

```python
POPULATED_RESERVED_HEADINGS: tuple[str, ...] = (
    "## Mutation Protocol (F6)",
    "## Enforcement Hooks (F7)",      # F7 appends this line
    "## Radius Drift Detection (F8)", # F8 appends this line
)
```

Confirmation of merge-friendliness: the change is one added tuple member inside a single tuple literal
plus one `continue` guard. Two features appending distinct string members to the same tuple literal is a
one-line-each textual addition in the same style as the `.claude/settings.json` and validator appends
this plan already treats as concurrency-safe. Nothing was reordered, renamed, or removed, no existing
assertion was deleted, and no other test in either file was altered.

Verdict: PASS — minimal additive edit, merge-friendly, no restructure.

### Out-of-table edit 2 — Bundle mirror and pack-manifest registration

Files:

| File | Added | Removed | Shape |
| --- | --- | --- | --- |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | new file (259 lines) | — | byte mirror |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-{add,remove,close}/SKILL.md` | new files | — | byte mirrors |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` | 145 (144 add / 1 del) | — | byte mirror of the same in-section append |
| `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` | 4 | 0 | byte mirror of the same appended entry |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | 4 | 0 | four sorted-position path registrations |

Why: landed contract tests require every `.claude/**` file to be byte-mirrored into the extension bundle
and registered in a pack manifest. Omitting the mirror would fail those tests.

Byte-identity verification (SHA-256 of source versus mirror, with byte sizes):

| Source | Mirror | Bytes | SHA-256 prefix | Verdict |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | bundle copy | 8842 = 8842 | `21ba3429e084a5a1` | IDENTICAL |
| `.claude/skills/parallel-add/SKILL.md` | bundle copy | 7658 = 7658 | `9511f727d4b775f3` | IDENTICAL |
| `.claude/skills/parallel-remove/SKILL.md` | bundle copy | 9881 = 9881 | `27744a1647667974` | IDENTICAL |
| `.claude/skills/parallel-close/SKILL.md` | bundle copy | 5171 = 5171 | `4d24f9c725c60fc3` | IDENTICAL |
| `.claude/skills/parallel-orchestrate/SKILL.md` | bundle copy | 38372 = 38372 | `825b8baf961c1bb9` | IDENTICAL |
| `.claude/settings.json` | bundle copy | 8778 = 8778 | `7116a47ab265194e` | IDENTICAL |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | bundle copy | 8871 = 8871 | `ddff3972ff42f355` | IDENTICAL |

All seven mirrored files are byte-identical to their sources.

`pack-manifests/core.json` diff — four path insertions, each at its sorted position, zero removals:

```diff
+    ".claude/hooks/enforce-parallel-abandon-gate.ps1",
...
+    ".claude/skills/parallel-add/SKILL.md",
+    ".claude/skills/parallel-close/SKILL.md",
     ".claude/skills/parallel-orchestrate/SKILL.md",
     ".claude/skills/parallel-plan/SKILL.md",
+    ".claude/skills/parallel-remove/SKILL.md",
```

No pre-existing manifest entry was changed, removed, or reordered.

Verdict: PASS — additive-only, byte-identical mirrors, registrations at sorted positions.

### Out-of-table edit 3 — `pester.runsettings.psd1` coverage allowlist, both copies

Files: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundle mirror
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.

Diff shape: **5 added, 0 removed in each copy**, and the two diffs are textually identical (the SHA-256
comparison above confirms the two files remain byte-identical to each other). One path appended to the
`CodeCoverage.Path` allowlist plus a four-line explanatory comment:

```diff
+            # Issue #442 added this PreToolUse abandon-gate hook, which guards the destructive
+            # parallel abandon disposition; measured here so the new production hook is not
+            # excluded from coverage. The test suite dot-sources the file (guarded body) so
+            # line attribution is valid.
+            '.claude/hooks/enforce-parallel-abandon-gate.ps1'
```

Why: `.claude/rules/general-unit-test.md` states that **no production file may be excluded from coverage
measurement**. The new hook is a production file, so leaving it out of the allowlist would be a policy
violation. Nothing was removed from the allowlist and no existing entry changed, so no file previously
measured lost measurement.

Note recorded in P7-T7: the MCP test tool resolves this allowlist from the installed extension bundle
rather than from `workspace_root`, so the edit does not change the current session's measured set; the
hook's coverage was therefore measured directly (86.96% line). The in-repo edit is still correct and
required, and takes effect on the next extension rebuild.

Verdict: PASS — additive-only, policy-required, identical in both copies.

### Out-of-table edit 4 — Feature documentation

Files: `docs/features/active/2026-08-07-parallel-mutation-protocol-442/plan.md` (checkbox and revision
updates), `spec.md` (the plan-time divergence-6 per-op table correction plus the 12 Phase 6 AC
check-offs), `user-story.md` (the 9 Phase 6 AC check-offs, 9 added / 9 removed — marker flips only).

Why: these are the plan's own artifacts and the AC source files this plan's Phase 6 is required to
update. `user-story.md` shows exactly 9 additions and 9 deletions, which is marker-only by arithmetic;
the `spec.md` AC-line diff was inspected and shows exactly 12 `- [ ]` → `- [x]` flips with criterion text
byte-unchanged.

Verdict: PASS — in-scope documentation, no criterion text altered.

## No Residual Working-Tree Rename From the P5-T4 Demonstration

P5-T4 demonstrated the token-seam binding by applying a single-sided rename in the working tree, then
reverting it. The branch diff must show no residual rename. Verified:

```
CLI:   ABANDON_DISPOSITION_TOKEN = f"{DISPOSITION_OPTION} {ABANDON_DISPOSITION}"
       CONFIRM_ABANDON_TOKEN = CONFIRM_ABANDON_OPTION
hook:  $script:AbandonDispositionToken = '--disposition abandon'
       $script:AbandonConfirmToken = '--confirm-abandon'
SKILL: poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py --item <key> --disposition abandon --confirm-abandon --pr <pr-number> --worktree <worktree-path>
```

`poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py -q` → **10 passed**,
exit code 0, so all three artifacts agree and no single-sided rename remains.

## Note on Concurrent Features

F7 and F8 lines, had they merged first, would be part of this comparison base and their presence would
not be an F6 violation. At the time of this verification the base `c939b5b8` contains no F7 or F8
content, and F6 added nothing inside either feature's reserved section or inside F7's validator seam.

Output Summary: All six checks PASS against the pinned base `c939b5b8`.
**Check A** — 13 modified tracked files, none an epic hook/skill/agent/validator, no F3 schema helper,
no `.claude/rules/**` file; four scoped diffs over those paths are all empty.
**Check B** — SKILL.md is one hunk, 144 added / 1 removed, the removal being exactly the F6 placeholder
sentence; added lines span 437-580, entirely before the F7 heading at 582; all three wave-4 headings
present at 435/582/586 in the original F6 → F7 → F8 order.
**Check C** — validator diff is 2 added / 0 removed; call line 325 sits between
`_validate_collections` (324) and the `# BEGIN F7 EXTENSION SEAM` comment (327); the 8-line seam block is
byte-identical to the base; file 336 → 338 lines.
**Check D** — `.claude/settings.json` is 4 added / 0 removed, one appended Bash-matcher entry at index 6,
with the six pre-existing entries unchanged and in their recorded order.
**Check E** — no schema field and no enum member added; the rule file and all three F3 helper modules are
untouched, and the new helper restates exactly F3's seven fields and four-member `op` vocabulary.
**Check F** — `git diff c939b5b8 -- pyproject.toml poetry.lock` is empty; no dependency change.
Four out-of-table edits are recorded with diff shape and justification: (1) the F5 surface-contract test,
adjusted by a 7-line additive `POPULATED_RESERVED_HEADINGS` tuple plus a 2-line skip guard — confirmed a
minimal merge-friendly append, with F7 and F8 each needing one further line in that tuple; (2) the
extension bundle mirror and `pack-manifests/core.json`, with all seven mirrored files verified
**byte-identical by SHA-256** and four sorted-position manifest insertions with zero removals; (3) the
two `pester.runsettings.psd1` copies, 5 added / 0 removed each and byte-identical to one another, required
by the no-production-file-excluded coverage rule; (4) the feature's own `plan.md`, `spec.md`, and
`user-story.md`. None of the four touches an `enforce-epic-*` hook, an epic validator, an epic skill, an
epic agent, `.claude/rules/**`, or any F3 schema definition. No residual single-sided token rename remains
(seam test: 10 passed).

Verdict: **PASS** — every check A-F satisfied; no remediation required.
