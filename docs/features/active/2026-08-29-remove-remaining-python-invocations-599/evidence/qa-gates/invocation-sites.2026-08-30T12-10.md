# P5-T12 — in-scope invocation sites closed, non-goal sites preserved

Timestamp: 2026-08-30T12-10

## Clause (a) — `python -m scripts.dev_tools.` under `.claude/skills/`

Command: `git grep -n -F "python -m scripts.dev_tools." -- .claude/skills/`
EXIT_CODE: 0
Output Summary: exactly **one** match, as required:

```
.claude/skills/parallel-orchestrate/SKILL.md:817:poetry run python -m scripts.dev_tools.parallel_drift_detection_cli \
```

Pre-feature value recorded in the plan: four matches —
`epic-orchestrate/SKILL.md:296` (site 1), `parallel-plan/SKILL.md:315` (site 4),
`parallel-orchestrate/SKILL.md:482` (site 2), and `parallel-orchestrate/SKILL.md:817`
(site 3, non-goal). The drop from four to one is the evidence that all three in-scope sites closed.
The surviving match is the drift-detection CLI at the line number the criterion names, 817.

## Clause (b) — `poetry run python` under `.claude/skills/`

Command: `git grep -n -F "poetry run python" -- .claude/skills/`
EXIT_CODE: 0
Output Summary: exactly **two** matches, both declared non-goals of this feature:

```
.claude/skills/parallel-orchestrate/SKILL.md:817:poetry run python -m scripts.dev_tools.parallel_drift_detection_cli \
.claude/skills/parallel-remove/SKILL.md:112:   poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py --item <key> --disposition abandon --confirm-abandon --pr <pr-number> --worktree <worktree-path>
```

Pre-feature value recorded in the plan: four matches — `parallel-plan/SKILL.md:315`,
`parallel-orchestrate/SKILL.md:482`, `parallel-orchestrate/SKILL.md:817`, and
`parallel-remove/SKILL.md:112`. Sites 3 and 5 are the two that remain, at the exact line numbers
the criterion names.

Both non-goals survive verbatim. The second is additionally load-bearing:
`.claude/hooks/enforce-parallel-abandon-gate.ps1` matches on the tokens of the
`parallel_mutation_abandon_cli.py` invocation, and no file under `.claude/skills/parallel-remove/`
was edited by this phase.

Site 1 at `.claude/skills/epic-orchestrate/SKILL.md:296` was spelled `python -m` with no
`poetry run` prefix, so it never appeared in this grep. Clause (a) rather than clause (b) is the
count that evidences its closure.

## Clause (c) — MCP form preserved in both rewritten skills

Command: `git grep -c -F "mcp__drm-copilot__validate_orchestration_artifacts" -- .claude/skills/epic-orchestrate/SKILL.md .claude/skills/parallel-orchestrate/SKILL.md`
EXIT_CODE: 0
Output Summary:

```
.claude/skills/epic-orchestrate/SKILL.md:1
.claude/skills/parallel-orchestrate/SKILL.md:1
```

Both counts are non-zero. This is a preservation check: it guards against an over-broad deletion in
P5-T1 or P5-T2 that would remove the MCP form along with the CLI spelling. Neither deletion was
over-broad.
