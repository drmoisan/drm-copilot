# Baseline — Always-On Context Line Count, BEFORE (Issue #559)

Timestamp: 2026-08-25T23-50
Task: [P0-T9]

## Command:

```
poetry run python -c "import sys,pathlib;c=[(p,len(pathlib.Path(p).read_bytes().splitlines())) for p in sys.argv[1:]];[print(n,p) for p,n in c];print('TOTAL',sum(n for _,n in c))" CLAUDE.md .claude/agents/epic-orchestrator.md .claude/skills/policy-compliance-order/SKILL.md .claude/skills/epic-orchestrate/SKILL.md .claude/skills/feature-promotion-lifecycle/SKILL.md .claude/skills/atomic-plan-contract/SKILL.md .claude/skills/acceptance-criteria-tracking/SKILL.md .claude/skills/evidence-and-timestamp-conventions/SKILL.md .claude/rules/general-code-change.md .claude/rules/general-unit-test.md .claude/rules/quality-tiers.md .claude/rules/tonality.md .claude/rules/parallel-orchestration.md .claude/rules/plan-acceptance-gates.md .claude/rules/orchestrator-state.md .claude/rules/ci-workflows.md .claude/rules/benchmark-baselines.md
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

EXIT_CODE: 0

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream
process status could mask a failure.

## Method Constraints Honoured

Two constraints stated by `[P0-T9]` were followed exactly:

1. **The payload is a single line.** A multi-line `python -c` payload is a known silent no-op in
   this environment: it exits 0 without executing anything. Reformatting the payload across
   lines would have fabricated the measurement instead of taking it. The payload was passed
   verbatim as one line, and the non-empty per-file output below is the positive evidence that
   it actually executed rather than silently no-opping.
2. **`bytes.splitlines()` is used, not `str.splitlines()`.** The file is read with
   `read_bytes()` so the line boundaries are the three ASCII forms — line feed, carriage return,
   and the CR/LF pair — and not the wider Unicode set (`\x0b`, `\x0c`, `\x1c`, `U+2028`,
   `U+2085`, and others) that the text method would additionally split on. This keeps the count
   equal to what a line-oriented tool would report.

## Observed Output (complete)

```
59 CLAUDE.md
162 .claude/agents/epic-orchestrator.md
40 .claude/skills/policy-compliance-order/SKILL.md
293 .claude/skills/epic-orchestrate/SKILL.md
121 .claude/skills/feature-promotion-lifecycle/SKILL.md
204 .claude/skills/atomic-plan-contract/SKILL.md
102 .claude/skills/acceptance-criteria-tracking/SKILL.md
176 .claude/skills/evidence-and-timestamp-conventions/SKILL.md
80 .claude/rules/general-code-change.md
105 .claude/rules/general-unit-test.md
51 .claude/rules/quality-tiers.md
80 .claude/rules/tonality.md
390 .claude/rules/parallel-orchestration.md
116 .claude/rules/plan-acceptance-gates.md
108 .claude/rules/orchestrator-state.md
36 .claude/rules/ci-workflows.md
35 .claude/rules/benchmark-baselines.md
TOTAL 2158
```

## Per-File Counts

| # | File | Lines | Component |
|---|---|---|---|
| 1 | `CLAUDE.md` | 59 | A — standing instruction + agent |
| 2 | `.claude/agents/epic-orchestrator.md` | 162 | A |
| 3 | `.claude/skills/policy-compliance-order/SKILL.md` | 40 | B — preloaded skills |
| 4 | `.claude/skills/epic-orchestrate/SKILL.md` | 293 | B |
| 5 | `.claude/skills/feature-promotion-lifecycle/SKILL.md` | 121 | B |
| 6 | `.claude/skills/atomic-plan-contract/SKILL.md` | 204 | B |
| 7 | `.claude/skills/acceptance-criteria-tracking/SKILL.md` | 102 | B |
| 8 | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | 176 | B |
| 9 | `.claude/rules/general-code-change.md` | 80 | C — unconditional rules |
| 10 | `.claude/rules/general-unit-test.md` | 105 | C |
| 11 | `.claude/rules/quality-tiers.md` | 51 | C |
| 12 | `.claude/rules/tonality.md` | 80 | C |
| 13 | `.claude/rules/parallel-orchestration.md` | 390 | D — unscoped rules |
| 14 | `.claude/rules/plan-acceptance-gates.md` | 116 | D |
| 15 | `.claude/rules/orchestrator-state.md` | 108 | D |
| 16 | `.claude/rules/ci-workflows.md` | 36 | D |
| 17 | `.claude/rules/benchmark-baselines.md` | 35 | D |
| | **TOTAL** | **2158** | |

## Component Subtotals

| Component | Members | Subtotal | Expected | Result |
|---|---|---|---|---|
| A — `CLAUDE.md` + epic-orchestrator agent | 2 files | 59 + 162 = **221** | 221 | MATCH |
| B — six preloaded skills | 6 files | 40 + 293 + 121 + 204 + 102 + 176 = **936** | 936 | MATCH |
| C — four unconditional rules files | 4 files | 80 + 105 + 51 + 80 = **316** | 316 | MATCH |
| D — five unscoped rules files | 5 files | 390 + 116 + 108 + 36 + 35 = **685** | 685 | MATCH |
| **Total** | **17 files** | 221 + 936 + 316 + 685 = **2158** | 2158 | **MATCH** |

## Acceptance Reconciliation

| Acceptance condition | Expected | Observed | Result |
|---|---|---|---|
| Before total | 2158 | 2158 | MATCH |
| Subtotal A | 221 | 221 | MATCH |
| Subtotal B | 936 | 936 | MATCH |
| Subtotal C | 316 | 316 | MATCH |
| Subtotal D | 685 | 685 | MATCH |

The observed total equals the expected total, and every component subtotal equals its expected
value. The acceptance condition's contingent clause — "if the observed total differs, the
artifact records the observed value and names each file whose count differs from research §1" —
is therefore not triggered. **No file's count differs from research §1**, so there is no
divergence list to record.

## Reduction Targets This Baseline Anchors

The after-half measurement (`always-on-line-count-after.2026-08-26T00-00.md`) and the comparison
artifact (`always-on-line-count-comparison.2026-08-26T00-00.md`) are produced in a later phase
and compare against these numbers. The two mechanisms this change uses to reduce the total are
visible in the component breakdown:

- **Component D (685 lines)** is removed from the always-on set by scoping the five unscoped
  rules files with `paths:` frontmatter (F3, tasks `[P2-T1]` through `[P2-T5]`). These files
  load on every turn today only because they carry no scoping.
- **Part of component B** is removed by cutting the epic-orchestrator's preloaded skill list
  from six to three (F2, task `[P3-T4]`), which drops `feature-promotion-lifecycle` (121),
  `atomic-plan-contract` (204), and `evidence-and-timestamp-conventions` (176).

Component C is deliberately retained: all four files are repository-wide policies whose
unconditional loading is correct. Component A shrinks only by the small F1 and F4 edits.

Output Summary: PASS. The before-half measurement executed successfully (EXIT_CODE 0) with a
single-line payload, producing a per-file count for all 17 always-on files. Observed before
total is **2158 lines**, exactly matching the expected 2158, with all four component subtotals
matching exactly: **221** (CLAUDE.md + epic-orchestrator agent), **936** (six preloaded skills),
**316** (four unconditional rules files), and **685** (five unscoped rules files). No file's
count differs from research §1, so no divergence list is recorded.
