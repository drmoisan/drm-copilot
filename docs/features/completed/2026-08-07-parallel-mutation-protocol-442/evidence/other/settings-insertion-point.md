# Upstream Contract Re-Verification — `.claude/settings.json` Insertion Point ([P1-T7])

Timestamp: 2026-08-08T21-48

Command: `poetry run python <scratchpad>/inspect_settings.py .claude/settings.json`
(throwaway inspector parsing the JSON and printing the `PreToolUse` matcher inventory
and the full `Bash` matcher `hooks` array in order; deleted after use)
EXIT_CODE: 0

## Hooks Surface Structure

`.claude/settings.json` carries `hooks.PreToolUse` as a three-matcher array:

| Index | `matcher` | `hooks` length |
| --- | --- | --- |
| 0 | `Bash` | 6 |
| 1 | `Write|Edit` | 10 |
| 2 | `Agent` | 5 |

Exactly one `PreToolUse` matcher has `matcher == "Bash"`, and it carries a `hooks`
array. The structure is therefore NOT "structurally different" in the sense that would
apply the phase stop rule. Verdict: no divergence.

## Ordered `PreToolUse` → `Bash` Matcher `hooks` Array Entries

Array length: **6**. Entries in order, all `type: "command"`:

| Index | `command` |
| --- | --- |
| 0 | `pwsh -NoProfile -File .claude/hooks/validate-bash.ps1` |
| 1 | `pwsh -NoProfile -File .claude/hooks/enforce-promotion-mcp-only.ps1` |
| 2 | `pwsh -NoProfile -File .claude/hooks/enforce-pr-author-skill.ps1` |
| 3 | `pwsh -NoProfile -File .claude/hooks/enforce-orchestration-preimplementation-gate.ps1` |
| 4 | `pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1` |
| 5 | `pwsh -NoProfile -File .claude/hooks/enforce-epic-worktree-removal-gate.ps1` |

This matches the plan's reconciled expected order exactly, entry for entry.
Verdict: no divergence.

## Observed Final Entry

**`pwsh -NoProfile -File .claude/hooks/enforce-epic-worktree-removal-gate.ps1`**
(index 5). This is the entry the plan recorded at reconciliation time.

## Confirmed Insertion Point

**The [P5-T2] insertion point is immediately AFTER THE FINAL ENTRY OBSERVED AT EDIT
TIME of the `PreToolUse` → `Bash` matcher `hooks` array.**

As observed now, that final entry is `enforce-epic-worktree-removal-gate.ps1` at index
5, so the new entry would land at index 6. The insertion point is defined RELATIVE TO
THE OBSERVED TAIL, not at a fixed index: [P5-T2] must re-read the array at edit time
and append after whatever entry is then last.

## F7-Entry Presence Finding

**F7 has NOT yet appended any entry to this array.** No entry references a
`parallel-` prefixed hook, and no entry other than the six above is present. The array
length is 6, unchanged from the reconciliation-time snapshot.

Per the task's acceptance text, additional entries appended by F7 later are explicitly
NOT a divergence. Because F7 may append to this same array concurrently with F6, the
recorded tail above is a SNAPSHOT. A merge conflict in `.claude/settings.json` is
expected under wave-4 concurrency and is resolved by KEEPING BOTH features' entries, in
either order, never by discarding one.

## Output Summary

Overall verdict: **NO DIVERGENCE.** The `PreToolUse` → `Bash` matcher exists and
carries a `hooks` array of exactly the six expected entries in the expected order, with
`enforce-epic-worktree-removal-gate.ps1` as the observed final entry. The [P5-T2]
insertion point is confirmed as "after the observed final entry of the `PreToolUse` →
`Bash` matcher `hooks` array". No F7 entry is present yet. The Phase 1 stop rule is NOT
triggered.
