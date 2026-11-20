# Main Merge Record - [P4-T1]

Timestamp: 2026-11-08T19-25
Command: git fetch origin; git merge --no-ff --no-edit origin/main (merge commit, no rebase, no force push)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: The merge stopped on one content conflict, which was resolved by hand and committed as a merge commit. Exit code 1 is the merge command's exit on a conflict; the merge commit followed.

## Merge

- Merged ref: `origin/main` (head of main after PR #1140, issue #1136).
- Re-derived merge base after the merge: equal to the merged `origin/main` head.
- Auto-merged without conflict: both epic-orchestrate skills and their bundle copies, all six execution-environment brief copies, both core pack manifests (`hook-epic-fan-in.ps1` entries from main and the `owner-directives` entries from this branch are both present).

## Conflicted Paths and Resolutions

| Path | Conflict | Resolution |
|---|---|---|
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | The `.claude/skills/epic-orchestrate/SKILL.md` digest line in `PINNED_FROZEN_SURFACE_HASHES`: this branch pinned the digest of its pointer edit, main pinned the digest of the #1136 post-fan-in paragraph. | Kept main's `RE-BASELINED by issue #1136` comment and the main-side agent digest; set the skill digest to the SHA-256 of the merged file, which carries both the #1136 paragraph and the owner-directives pointer. |

## Digest

- Recomputed SHA-256 of the merged `.claude/skills/epic-orchestrate/SKILL.md`: `0bcb571ab0bd895aba15a8368b98e62e412422f6593a09805e906ebd6cf1c826` (equal to the staged merge blob; the file has LF line endings).
- Changed: yes. It differs from main's pinned value (`73d5c859007dbfe5bb0a35ad9b5444ea85fe1bf6a43571e1941952490033ed7e`) and from this branch's pre-merge value (`fef4ea0492027137fb4edc96b41b19456669025f1126282d534d5fdca159f644`).
- `.claude/agents/epic-orchestrator.md` digest: main's value, unchanged.
- `git diff --numstat MB...HEAD -- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` against the re-derived merge base: 1 added, 1 deleted.

## Bundle Pairs After the Merge

- `.claude/skills/epic-orchestrate/SKILL.md` and its claude-customizations copy: equal SHA-256 (no re-copy needed).
- `.agents/skills/epic-orchestrate/SKILL.md` and its codex-and-agents copy: equal SHA-256 (no re-copy needed).
- The six execution-environment copies: equal SHA-256, each carrying both the #1136 post-fan-in bullet and the owner-directive bullet.
- Debug check (not gate evidence): the frozen-surface, resource-contract, pack-manifest, and brief pytest files passed on the merged tree.
