# Remediation Baseline — JSON and Markdown Lanes

Timestamp: 2026-08-10T21-42
Issue: #462
Task: [P0-T4]
State: pre-edit (RI-2 single-wildcard grant still present in all six locations)

## Command 1 — repo `settings.json` JSON validity

Command: `node -e "JSON.parse(require('fs').readFileSync('.claude/settings.json','utf8')); console.log('repo settings.json valid')"`

EXIT_CODE: 0

Output Summary: `repo settings.json valid`

## Command 2 — bundled `settings.json` JSON validity

Command: `node -e "JSON.parse(require('fs').readFileSync('extensions/drm-copilot/resources/claude-customizations/.claude/settings.json','utf8')); console.log('bundle settings.json valid')"`

EXIT_CODE: 0

Output Summary: `bundle settings.json valid`

## Command 3 — repo/bundle pair hashes (three pairs)

Command:

```
pwsh -NoProfile -Command "(Get-FileHash .claude/settings.json).Hash; (Get-FileHash extensions/drm-copilot/resources/claude-customizations/.claude/settings.json).Hash; (Get-FileHash .claude/agents/parallel-planner.md).Hash; (Get-FileHash extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md).Hash; (Get-FileHash .claude/agents/parallel-orchestrator.md).Hash; (Get-FileHash extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md).Hash"
```

EXIT_CODE: 0

Output Summary (SHA256, emitted in repo/bundle order per pair):

| Pair | Repo file | Bundle file | Hash | Equal |
| --- | --- | --- | --- | --- |
| 1 | `.claude/settings.json` | `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` | `7DD46B171B35515AF1BAD2C3D7EC464A626A210F29C6500A6CC857F74E6093ED` | YES |
| 2 | `.claude/agents/parallel-planner.md` | `.../claude-customizations/.claude/agents/parallel-planner.md` | `1BAB482EED134E36BA4298494B4E9E8B1C5825B658E63DE951EBC0E414BA5FE2` | YES |
| 3 | `.claude/agents/parallel-orchestrator.md` | `.../claude-customizations/.claude/agents/parallel-orchestrator.md` | `E9F9411CB9D5F8673954C63EC4982D96FB48F76034A404D0E3324ACCD6B1BC22` | YES |

All three repo/bundle pairs are byte-identical at baseline. Full-file hash equality is therefore the
mirror contract for the RI-2 edits: after P3-T4 the same three comparisons must still report
equality.

## Markdown Lane

This repository has **no configured Markdown lint or format toolchain**. There is no markdownlint
configuration, no Prettier lane covering `**/*.md`, and no repo task that checks Markdown. The
Markdown edits in this cycle (`spec.md` in P2-T1, the two agent definitions in P3-T2/P3-T3, the
disclosure artifact in P3-T5, and the bundled mirrors in P3-T4) are therefore verified by their
per-task content acceptance criteria — targeted `grep` assertions and repo/bundle hash equality —
rather than by a toolchain stage. The absence is documented here so that a later reader does not
read the missing Markdown lane as a skipped gate.

The two agent-definition Markdown files additionally carry YAML frontmatter that IS machine-checked:
`tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py` parses the `tools:`
list and asserts grant coverage of every prescribed command invocation. That test is the executable
gate for the RI-2 Markdown edits and runs at P5-T4.

Output Summary: Both `settings.json` copies parse as valid JSON (exit 0). All three repo/bundle
pairs hash-match at baseline. No Markdown toolchain lane exists in this repository; Markdown
verification is by content assertion and by the P5-T4 pytest frontmatter contract tests.
