# Absorption B — Push-Down Bundle Mirror (ADJ-2) — Issue #440 (F7)

Timestamp: 2026-08-08T22-24

Authorization: orchestrator adjudication ADJ-2, absorbed into Phase 4 as a genuine plan gap. The
approved plan `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/plan.2026-08-07T11-10.md`
contains no push-down task.

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`

EXIT_CODE: 0

## Contract Enforced

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` requires every non-memory
`.claude` file (excluding `.claude/settings.local.json` and the `.claude/agent-memory/**` subtree) to
exist under `extensions/drm-copilot/resources/claude-customizations/.claude/` and be BYTE-IDENTICAL to
the repo copy.

Pre-mirror failure, verbatim:

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
AssertionError: Bundle content differs from repo for: .claude\hooks\enforce-epic-invocation-origin.ps1
```

Pre-mirror result: `1 failed, 6 passed`.

## Sequencing

The mirror was performed AFTER [P4-T1] through [P4-T4] completed, so `.claude/settings.json` and
`.claude/skills/parallel-orchestrate/SKILL.md` were in their final Phase 4 state at copy time.

## Pre-Copy Divergence Check (basis for a direct copy)

For each of the three files that already existed in both trees, the repo and bundle copies were
byte-identical at `HEAD`, confirmed by identical git blob hashes:

| File | Repo blob at HEAD | Bundle blob at HEAD | Identical |
| --- | --- | --- | --- |
| `settings.json` | `e647af6f0c34263db5eba31fb9ee5fde7767addd` | `e647af6f0c34263db5eba31fb9ee5fde7767addd` | yes |
| `skills/parallel-orchestrate/SKILL.md` | `bf089b1806b29a172dfe47db7a3d04ef57068a97` | `bf089b1806b29a172dfe47db7a3d04ef57068a97` | yes |
| `hooks/enforce-epic-invocation-origin.ps1` | `31f97b068d812d548133cd2e4d3b24dfce34a27a` | `31f97b068d812d548133cd2e4d3b24dfce34a27a` | yes |

Because the two trees agreed at `HEAD`, a direct repo-to-bundle copy transfers exactly this feature's
delta and nothing else. In particular, for `SKILL.md` this guarantees the bundle's `## Mutation Protocol
(F6)` and `## Radius Drift Detection (F8)` reserved sections are carried over unchanged, since the repo
copy's own edit touched only the F7 placeholder line.

## Mirrored Files (5) with Post-Copy Byte-Identity Verification

SHA-256 of the repo copy and the bundle copy after the mirror, per file:

| # | File (relative to `.claude/`) | Status | Repo == bundle | SHA-256 |
| --- | --- | --- | --- | --- |
| 1 | `hooks/enforce-parallel-cohort-barrier.ps1` | new | True | `AB23D888EEA998F4F9059569B315A5B89CA7A7254D946E1C0CA707F8E0BB1E3C` |
| 2 | `hooks/enforce-parallel-worktree-removal-gate.ps1` | new | True | `236F575362886CA76A7EBDBDF2080FAA18746F5CCAC475710A29C51E453DECA9` |
| 3 | `hooks/enforce-epic-invocation-origin.ps1` | modified in Phase 2 | True | `FC453F5AA7C0ABB562AECAC41C4CD326C3A47DF9FAB832F1828ADEA9A9444AF2` |
| 4 | `settings.json` | modified by P4-T1/P4-T2/P4-T3 | True | `931005029C5691834359BFBB0B1A3D1F4F04DBDF13D3A333B5A8C627B84A5903` |
| 5 | `skills/parallel-orchestrate/SKILL.md` | modified by P4-T4 | True | `BDF559491EFA3929F9EB0F167C1A93ED345D8E5950571133D9A02818D7918218` |

Bundle destination root: `extensions/drm-copilot/resources/claude-customizations/.claude/`.

## Diffstat Parity (repo side versus bundle side)

Repo side:

```
 .claude/hooks/enforce-epic-invocation-origin.ps1 | 34 ++++++++++------
 .claude/settings.json                            | 17 ++++++++
 .claude/skills/parallel-orchestrate/SKILL.md     | 50 +++++++++++++++++++++++-
 3 files changed, 89 insertions(+), 12 deletions(-)
```

Bundle side:

```
 .../hooks/enforce-epic-invocation-origin.ps1       | 34 ++++++++++-----
 .../claude-customizations/.claude/settings.json    | 17 ++++++++
 .../.claude/skills/parallel-orchestrate/SKILL.md   | 50 +++++++++++++++++++++-
 3 files changed, 89 insertions(+), 12 deletions(-)
```

Identical totals, confirming the bundle received this feature's delta and no additional change. The two
new hook files appear as untracked additions on the bundle side.

## Reserved-Section Discipline in the Bundled `SKILL.md`

The bundled copy is the second fan-in conflict surface carrying the same three reserved sections, so the
same discipline was verified there:

Single hunk from `git diff -U0`:

```
@@ -441 +441,49 @@ Reserved for F6; content is appended by that feature and must not be relocated.
```

Its only deletion line:

```
-Reserved for F7; content is appended by that feature and must not be relocated.
```

Post-mirror `grep -n "^## "` tail of the bundled file:

```
435:## Mutation Protocol (F6)
439:## Enforcement Hooks (F7)
491:## Radius Drift Detection (F8)
```

All three reserved headings survive in their original order; the F6 and F8 placeholder bodies are
untouched and absent from the diff. Nothing was relocated, reflowed, or retitled.

## No Foreign Bundle Drift

The push-down test names differing files one at a time. After mirroring these five files the test passes
completely (`7 passed`), so it named no additional differing file. There is no pre-existing bundle drift
from another feature to report, and no file outside this feature's change set was touched.

## Output Summary

PASS. Five `.claude` files were mirrored byte-identically into
`extensions/drm-copilot/resources/claude-customizations/.claude/` after P4-T1 through P4-T4 completed:
the two new hooks `enforce-parallel-cohort-barrier.ps1` and
`enforce-parallel-worktree-removal-gate.ps1`, the Phase 2-modified `enforce-epic-invocation-origin.ps1`,
the Phase 4-modified `settings.json`, and the Phase 4-modified
`skills/parallel-orchestrate/SKILL.md`. Byte identity was verified per file by matching SHA-256 hashes
(all five `match=True`), and delta parity was verified by identical repo-side and bundle-side diffstats
(89 insertions / 12 deletions each). A direct copy was safe because all three pre-existing files had
identical git blob hashes at `HEAD` in both trees. The bundled `SKILL.md` shows the same single hunk at
line 441 with all three reserved headings surviving in order.
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` reports
`7 passed` (was `1 failed, 6 passed`), and named no additional differing file, so no foreign bundle drift
exists.
