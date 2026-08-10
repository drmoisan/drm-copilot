# QA Gate — JSON and Markdown Lanes (post-change)

Timestamp: 2026-08-10T21-57
Issue: #462
Task: [P5-T1]
State: post-change (RI-1 through RI-4 all applied)
Baseline for comparison: `evidence/remediation-baseline/json-markdown-baseline.2026-08-10T21-42.md`

## Command 1 — repo `settings.json` JSON validity

Command: `node -e "JSON.parse(require('fs').readFileSync('.claude/settings.json','utf8')); console.log('repo settings.json valid')"`

EXIT_CODE: 0

Output Summary: `repo settings.json valid`. The three-entry grant replacement preserved JSON
validity.

## Command 2 — bundled `settings.json` JSON validity

Command: `node -e "JSON.parse(require('fs').readFileSync('extensions/drm-copilot/resources/claude-customizations/.claude/settings.json','utf8')); console.log('bundle settings.json valid')"`

EXIT_CODE: 0

Output Summary: `bundle settings.json valid`

## Command 3 — repo/bundle pair hashes (three pairs, post-change)

Command:

```
pwsh -NoProfile -Command "(Get-FileHash .claude/settings.json).Hash; (Get-FileHash extensions/drm-copilot/resources/claude-customizations/.claude/settings.json).Hash; (Get-FileHash .claude/agents/parallel-planner.md).Hash; (Get-FileHash extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md).Hash; (Get-FileHash .claude/agents/parallel-orchestrator.md).Hash; (Get-FileHash extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md).Hash"
```

EXIT_CODE: 0

Output Summary:

| Pair | File | Baseline hash | Post-change hash | Repo == Bundle |
| --- | --- | --- | --- | --- |
| 1 | `.claude/settings.json` | `7DD46B17...6093ED` | `9EE53B5E27D06DBFDD9EE55DAE7E6BCD5C956F51A184BAF11A3FB763B6777C4B` | YES |
| 2 | `.claude/agents/parallel-planner.md` | `1BAB482E...BA5FE2` | `DA43FE4EA74912482F7C094A7503916040C421BF2407C8DAC9231FC94679A749` | YES |
| 3 | `.claude/agents/parallel-orchestrator.md` | `E9F9411C...B1BC22` | `1FAB17FF7B41FB7FECDA7F46087E7692AF6530AFF19D814A448CAA976EA17636` | YES |

All three hashes changed relative to baseline, confirming each pair was actually edited. Within each
pair the repo and bundle hashes are identical, confirming the mirror contract holds after the RI-2
edits. The mirrors were produced by copying the edited repo file over the bundle file, so the
equality is exact byte parity, not merely equivalent content.

## Markdown Lane

This repository has no configured Markdown lint or format toolchain (recorded at baseline in
`json-markdown-baseline.2026-08-10T21-42.md`). There is no markdownlint configuration, no Prettier
lane covering `**/*.md`, and no repo task that checks Markdown. The absence is documented rather
than skipped.

The five Markdown edits in this cycle are verified by content acceptance instead:

| File | Edit | Verified by |
| --- | --- | --- |
| `<FEATURE>/spec.md` | RI-1 sixth-scenario removal, box checked | P2-T1 grep (`generation handling` -> 0 matches) |
| `.claude/agents/parallel-planner.md` | RI-2 frontmatter + two prose sites | P3-T2 grep; P3-T6 YAML frontmatter parse; P5-T4 pytest |
| `.claude/agents/parallel-orchestrator.md` | RI-2 frontmatter + one prose site | P3-T3 grep; P3-T6 YAML frontmatter parse; P5-T4 pytest |
| both bundled agent mirrors | RI-2 byte-identical mirror | pair-hash equality above; P5-T4 pytest parity test |
| `<FEATURE>/evidence/other/permission-surface-callout.2026-08-10T17-08.md` | RI-2 disclosure amendment | P3-T5 grep (`not applied` -> 0 matches; `Amended:` present) |

Both agent files additionally carry machine-checked YAML frontmatter. `tests/scripts/dev_tools/
test_parallel_orchestrator_permission_contracts.py` parses the `tools:` list and asserts grant
coverage of every prescribed command invocation; `test_push_down_claude_resource_contracts.py::
test_bundled_claude_payload_contains_all_repo_runtime_contracts` asserts byte-identical repo/bundle
text parity. Both run at P5-T4.

Output Summary: Both `settings.json` copies parse as valid JSON post-change (exit 0). All three
repo/bundle pairs hash-match after the RI-2 edits, and all three hashes differ from baseline,
confirming the edits landed in both copies. No Markdown toolchain lane exists; Markdown verification
is by per-task content assertion plus the P5-T4 frontmatter and parity contract tests.
