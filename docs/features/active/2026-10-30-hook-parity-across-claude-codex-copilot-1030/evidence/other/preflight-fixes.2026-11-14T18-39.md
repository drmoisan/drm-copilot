# Preflight In-Place Fixes (Issue #1030), Round Two

Timestamp: 2026-11-14T18-39
Plan: docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/plan.2026-10-30T18-37.md
Preflight: confirming single-pass preflight (round two) after the planner revision of [P2-T1], [P2-T2] and [P2-T3]

## Fixes

1. [P2-T1] | signature disagreeing with the spec (defect class 3) | Spec `## API / CLI Surface` states that child 5 selects matrix entries by `ecosystem`, `kind`, `name`, `source_path` and `source_pointer`, not by parsing `id`. The task named only the first four fields. The selection key now reads "`ecosystem`, `kind`, `name`, `source_path` and, when present, `source_pointer` (never by parsing `id`)". No entry, group or note value changes; at planning time the four fields already select each registration uniquely.
2. [P2-T3] | asserted token not pinned to the instructed text (literal formatting) | The rows `records C1 as NOT-EXPRESSIBLE naming issue 555` and `records C2 as DEFER naming agent_type` named no asserted token. Each row now states its selection and its token: the `.claude/hooks/pretooluse-dispatch.json` entry whose `name` is `PreToolUse/Agent/enforce-orchestration-preimplementation-gate` has class `NOT-EXPRESSIBLE` and a `Reason` containing `#555`; the `enforce-pr-author-command-allowlist` entry has class `DEFER` and a `Reason` containing `agent_type`. Both tokens are text that [P2-T1] already instructs the executor to write ("issue #555", "the unverified `agent_type` field"). The row names are unchanged.
