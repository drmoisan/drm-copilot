# Frozen-Surface Pin Re-Baseline (issue #673)

Timestamp: 2026-09-19T18-50

Command: `Get-FileHash -LiteralPath '.claude/skills/epic-orchestrate/SKILL.md' -Algorithm SHA256` lowercased; then a Python edit script performing the digest replacement first and the comment insertion second, recording each digest entry's line number before and after; then a comparison of the agent digest against `git show b7c1161655b4b53b0358dc7890a26200207c4b91:tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.

EXIT_CODE: 0

## Digests

| Path string the entry is identified by | Old digest | New digest |
| --- | --- | --- |
| `.claude/skills/epic-orchestrate/SKILL.md` | `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7` | `cfbe83349e1712275400c4591ab784f966321c37d36982a131aea25736d86db7` |
| `.claude/agents/epic-orchestrator.md` | `5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec` | unchanged |

The old skill digest matches the value `[P0-T15]` recorded for the same file at baseline, which confirms the entry was correct before this change and that the only reason it moved is `[P8-T4]`'s paragraph.

## Line numbers, before and after each edit

Both entries are identified by their path string rather than by line number, because the two edits in this task are order-dependent: inserting the comment paragraph shifts every digest line below it.

| Entry | Pre-edit line | Post-edit line |
| --- | --- | --- |
| `.claude/agents/epic-orchestrator.md` digest | 126 | 133 |
| `.claude/skills/epic-orchestrate/SKILL.md` digest | 130 | 137 |

Both moved down by seven lines, the length of the inserted comment paragraph. The digest replacement was performed first, against the pre-edit file, and the comment insertion second.

## Comment paragraph added

```
#
# RE-BASELINED by issue #673. That change added a checkpoint-hygiene paragraph to
# `## Epic-Level Checkpoint` in the epic skill, stating that a coordinating session
# holds no per-feature checkpoint at its own root and archives any it finds to
# `artifacts/orchestration/handoff/`. Only the skill digest moved; the pin stays live
# for the entry whose path string is `.claude/agents/epic-orchestrator.md`, whose
# digest is unchanged, so an unintended edit to the agent file still fails loudly.
```

It occurs exactly once and follows the issue #559 re-baseline note, preserving that file's convention of recording each re-baseline rather than replacing the previous explanation.

## Acceptance verification

| Condition | Result |
| --- | --- |
| The new digest equals `Get-FileHash -Algorithm SHA256` of the edited skill, lowercased | yes — the value computed from the file is present in the expectations file exactly once |
| The digest recorded against `.claude/agents/epic-orchestrator.md` is byte-identical to its value at `F5_BASE_SHA` | yes — both readings are `5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec` |
| The file contains `RE-BASELINED by issue #673.` exactly once | yes |

Output Summary: The epic-skill digest is re-baselined to `cfbe83349e1712275400c4591ab784f966321c37d36982a131aea25736d86db7`, which equals the SHA-256 of the file as `[P8-T4]` left it. The agent digest is untouched and byte-identical to its value at the merge base, so the pin remains a live guard for that file rather than being blanket-disabled. Both digest entries were located by path string, not by line number, and both shifted down by the seven lines the comment paragraph added.
