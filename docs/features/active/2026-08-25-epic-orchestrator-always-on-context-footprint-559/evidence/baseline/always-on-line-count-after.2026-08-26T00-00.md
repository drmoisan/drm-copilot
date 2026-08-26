# Post-Change — Always-On Context Line Count, AFTER (Issue #559)

Timestamp: 2026-08-26T00-00
Task: [P5-T1]

## Command:

```
poetry run python -c "import sys,pathlib;c=[(p,len(pathlib.Path(p).read_bytes().splitlines())) for p in sys.argv[1:]];[print(n,p) for p,n in c];print('TOTAL',sum(n for _,n in c))" CLAUDE.md .claude/agents/epic-orchestrator.md .claude/skills/policy-compliance-order/SKILL.md .claude/skills/epic-orchestrate/SKILL.md .claude/skills/acceptance-criteria-tracking/SKILL.md .claude/rules/general-code-change.md .claude/rules/general-unit-test.md .claude/rules/quality-tiers.md .claude/rules/tonality.md
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

EXIT_CODE: 0

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream
process status could mask a failure.

## Method Constraints Honoured

The `-c` payload is byte-identical to the one in `[P0-T9]`; only the file operands differ, so
the before and after halves are measured by the same counting rule.

1. **The payload is a single line.** A multi-line `python -c` payload is a known silent no-op in
   this environment: it exits 0 without executing anything, which would fabricate the
   measurement rather than take it. The payload was passed verbatim as one line, and the
   non-empty per-file output below is the positive evidence that it executed.
2. **`bytes.splitlines()` is used, not `str.splitlines()`.** Line boundaries are the three ASCII
   forms — line feed, carriage return, and the CR/LF pair — not the wider Unicode set the text
   method would additionally split on.

## Observed Output (complete)

```
56 CLAUDE.md
160 .claude/agents/epic-orchestrator.md
40 .claude/skills/policy-compliance-order/SKILL.md
310 .claude/skills/epic-orchestrate/SKILL.md
102 .claude/skills/acceptance-criteria-tracking/SKILL.md
80 .claude/rules/general-code-change.md
105 .claude/rules/general-unit-test.md
51 .claude/rules/quality-tiers.md
80 .claude/rules/tonality.md
TOTAL 984
```

## Per-File Counts

| # | File | Before | After | Delta | Component |
|---|---|---|---|---|---|
| 1 | `CLAUDE.md` | 59 | 56 | -3 | A — standing instruction + agent |
| 2 | `.claude/agents/epic-orchestrator.md` | 162 | 160 | -2 | A |
| 3 | `.claude/skills/policy-compliance-order/SKILL.md` | 40 | 40 | 0 | B — preloaded skills |
| 4 | `.claude/skills/epic-orchestrate/SKILL.md` | 293 | 310 | +17 | B |
| 5 | `.claude/skills/acceptance-criteria-tracking/SKILL.md` | 102 | 102 | 0 | B |
| 6 | `.claude/rules/general-code-change.md` | 80 | 80 | 0 | C — unconditional rules |
| 7 | `.claude/rules/general-unit-test.md` | 105 | 105 | 0 | C |
| 8 | `.claude/rules/quality-tiers.md` | 51 | 51 | 0 | C |
| 9 | `.claude/rules/tonality.md` | 80 | 80 | 0 | C |
| | **TOTAL** | **—** | **984** | | |

The `Before` column reproduces the per-file values recorded in
`always-on-line-count-before.2026-08-26T00-00.md` for the nine files that remain in the
after-state set. It is not the before total: eight files present in the before set are excluded
from the after set for the reasons given below.

## Three-Component Breakdown

| Component | Members | Subtotal |
|---|---|---|
| A — standing instructions plus agent file | `CLAUDE.md` (56), `.claude/agents/epic-orchestrator.md` (160) | 56 + 160 = **216** |
| B — three preloaded skills | `policy-compliance-order` (40), `epic-orchestrate` (310), `acceptance-criteria-tracking` (102) | 40 + 310 + 102 = **452** |
| C — four deliberate unconditional rules | `general-code-change` (80), `general-unit-test` (105), `quality-tiers` (51), `tonality` (80) | 80 + 105 + 51 + 80 = **316** |
| **Total** | **9 files** | 216 + 452 + 316 = **984** |

## Components Excluded From the After-State List

**The five now-scoped rules files (685 lines) are excluded because they no longer load
unconditionally.** F3 (`[P2-T1]` through `[P2-T5]`) inserted a `paths:` frontmatter block into
each, so each now activates only for files matching its globs rather than on every turn:
`.claude/rules/parallel-orchestration.md` (390), `.claude/rules/plan-acceptance-gates.md` (116),
`.claude/rules/orchestrator-state.md` (108), `.claude/rules/ci-workflows.md` (36), and
`.claude/rules/benchmark-baselines.md` (35). Their own on-disk line counts each grew by the
inserted block; that growth is irrelevant to this measurement because the files left the
always-on set entirely.

**The three de-preloaded skills (501 lines) are excluded because they are no longer preloaded.**
F2 (`[P3-T4]`) removed them from the `skills:` list in the `.claude/agents/epic-orchestrator.md`
frontmatter: `.claude/skills/atomic-plan-contract/SKILL.md` (204),
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (176), and
`.claude/skills/feature-promotion-lifecycle/SKILL.md` (121). The files are unmodified and remain
invocable on demand; they are simply no longer injected at startup.

Output Summary: PASS. The after-half measurement executed successfully (EXIT_CODE 0) with a
single-line payload byte-identical to the `[P0-T9]` payload, producing a per-file count for all
9 remaining always-on files. Observed after total is **984 lines**, with the required
three-component breakdown: **216** (standing instructions plus agent file), **452** (three
preloaded skills), and **316** (four deliberate unconditional rules). Eight files totalling 1,186
before-state lines are excluded from the after-state set: the five now-scoped rules files (685)
and the three de-preloaded skills (501). Against the `[P0-T9]` before total of 2,158 the after
total of 984 is strictly lower; the signed difference and its attribution are recorded in
`always-on-line-count-comparison.2026-08-26T00-00.md`.
