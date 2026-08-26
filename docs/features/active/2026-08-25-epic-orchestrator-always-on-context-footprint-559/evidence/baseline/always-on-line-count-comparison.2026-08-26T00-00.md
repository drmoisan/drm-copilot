# Always-On Context Line Count — Before/After Comparison (Issue #559)

Timestamp: 2026-08-26T00-00
Task: [P5-T2]

Command: not applicable (comparison of two recorded measurements, not a command step)

EXIT_CODE: 0

## Sources

| Half | Artifact | Task | Total |
|---|---|---|---|
| Before | `always-on-line-count-before.2026-08-26T00-00.md` | `[P0-T9]` | 2,158 lines over 17 files |
| After | `always-on-line-count-after.2026-08-26T00-00.md` | `[P5-T1]` | 984 lines over 9 files |

Both halves were measured by the same single-line `python -c` payload, byte-identical between
the two tasks, with only the file operands differing. Both used `bytes.splitlines()`, so the
line boundary is the same in both halves.

## Headline

| Quantity | Value |
|---|---|
| Before total | **2,158** lines |
| After total | **984** lines |
| Signed difference (after minus before) | **-1,174** lines |
| Absolute reduction | **1,174** lines |
| Percentage reduction | **54.40%** |
| Retained fraction | 45.60% |

The after total is strictly less than the before total.

## Component-Level Comparison

| Component | Before | After | Delta |
|---|---|---|---|
| A — `CLAUDE.md` + epic-orchestrator agent | 221 | 216 | -5 |
| B — preloaded skills | 936 (6 files) | 452 (3 files) | -484 |
| C — deliberate unconditional rules | 316 (4 files) | 316 (4 files) | 0 |
| D — unscoped rules files | 685 (5 files) | 0 (excluded) | -685 |
| **Total** | **2,158** | **984** | **-1,174** |

## Attribution by Feature

Each contribution below is measured, not estimated. Per-file line deltas come from the two
measurements above; hunk-level splits come from `git diff <feature-base> --unified=0` against
the feature base commit `b36179b2bcdaf541242241301f3aa3e170b96363`.

| Feature | Mechanism | Contribution |
|---|---|---|
| **F3** — scope the five unscoped rules files | `paths:` frontmatter inserted into each of the five files (`[P2-T1]` through `[P2-T5]`), so none loads unconditionally any longer | **-685** |
| **F2** — cut the preloaded skill list from six to three | Three `skills:` entries removed from the agent frontmatter (`[P3-T4]`): -501 from set membership (`atomic-plan-contract` 204, `evidence-and-timestamp-conventions` 176, `feature-promotion-lifecycle` 121), plus -3 for the three removed frontmatter lines in the agent file itself | **-504** |
| **F1** — remove redundant read instructions | Two `## Startup Protocol` read steps deleted from `.claude/agents/epic-orchestrator.md` (`[P3-T3]`, -2) and the `## Prerequisites` block deleted from `.claude/skills/epic-orchestrate/SKILL.md` (`[P3-T9]`, -8) | **-10** |
| **F5** — de-duplicate the tone policy | Four duplicated tone-policy bullets in `CLAUDE.md` replaced with one pointer line to `.claude/rules/tonality.md` (`[P4-T1]`): 4 removed, 1 added | **-3** |
| F4 — qualify the section citations (counter-directional) | Two unqualified citations replaced with qualified ones in `.claude/agents/epic-orchestrator.md` (`[P3-T1]` +2, `[P3-T2]` +1); the `.claude/skills/epic-orchestrate/SKILL.md` clause deletion (`[P3-T6]`) is line-neutral | **+3** |
| F6 — bounded child return contract (counter-directional) | `## Bounded Child Return Contract` section added to `.claude/skills/epic-orchestrate/SKILL.md` (`[P3-T7]`, +25); the kickoff-line append (`[P3-T8]`) is line-neutral | **+25** |
| | **Sum** | **-1,174** |

The six contributions sum exactly to the observed signed difference of -1,174, so the
attribution is complete and no residual is unaccounted for. F4 and F6 are recorded with their
true signs: both add always-on lines. They are included because an attribution that reported
only the reductions would not reconcile against the measured total.

The four features the acceptance condition names — F1, F2, F3, and F5 — together account for
-1,202 lines; F4 and F6 add back 28, leaving the net -1,174.

F6's +25 lines are what buy the per-child return-payload reduction, which is a separate and
unmeasured saving: the bounded return shape constrains what each child returns to the parent at
run time, and that traffic is not part of the always-on measurement.

## Components Excluded From the After-State List, and Why

**The five now-scoped rules files (685 before-state lines).** F3 gave each a `paths:`
frontmatter block, so each activates only for files matching its globs instead of on every turn:
`.claude/rules/parallel-orchestration.md` (390), `.claude/rules/plan-acceptance-gates.md` (116),
`.claude/rules/orchestrator-state.md` (108), `.claude/rules/ci-workflows.md` (36), and
`.claude/rules/benchmark-baselines.md` (35). Each file's own on-disk line count grew by the
inserted block, but the file is no longer in the always-on set, so its full former contribution
leaves the total.

**The three de-preloaded skills (501 before-state lines).** F2 removed them from the `skills:`
list in the `.claude/agents/epic-orchestrator.md` frontmatter:
`.claude/skills/atomic-plan-contract/SKILL.md` (204),
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (176), and
`.claude/skills/feature-promotion-lifecycle/SKILL.md` (121). The files themselves are unmodified
and remain invocable on demand; they are no longer injected at startup.

Both exclusions are exclusions from the *always-on set*, not deletions. No excluded file was
removed from the repository, and every one remains reachable — the rules files by path match,
the skills by explicit invocation.

## The One Un-Measured Component: Agent Memory

Task: [P5-T3]

`.claude/agents/epic-orchestrator.md` carries a `memory: project` declaration. That declaration
loads the contents of `.claude/agent-memory/epic-orchestrator/` into the agent's always-on
context at startup, in addition to the nine files measured above.

That directory is gitignored. Its contents are therefore machine-local: they differ between
checkouts, are not reproducible from the repository, and cannot be measured from committed
files. No committed artifact records what any given machine's copy contains, so neither the
before nor the after half of this measurement includes it, and neither half could.

The consequence for both totals is stated explicitly: **the measured before total of 2,158 lines
and the measured after total of 984 lines both exclude agent memory, and are therefore a lower
bound on the context actually injected on any given machine**, not a complete accounting. The
true injected footprint on a machine with a populated `.claude/agent-memory/epic-orchestrator/`
is higher than both figures by the size of that directory's contents.

The signed difference of -1,174 lines is unaffected in sign by this omission, because the
`memory: project` declaration is present both before and after this change — no task in this
plan adds, removes, or alters it. The omission is a constant term common to both halves, not a
term that moves between them. Its magnitude, however, is unknown, so the percentage reduction of
54.40% is a figure over the measurable set only and should not be read as the percentage
reduction in total injected context.

Output Summary: PASS. Before total **2,158**; after total **984**; signed difference
**-1,174** lines (**54.40%** reduction). The after total is strictly less than the before total.
The reduction is attributed to F3 (-685), F2 (-504), F1 (-10), and F5 (-3), against
counter-directional additions from F4 (+3) and F6 (+25); the six contributions reconcile exactly
to -1,174. Eight files are excluded from the after-state list: the five now-scoped rules files
(685) because they no longer load unconditionally, and the three de-preloaded skills (501)
because they are no longer preloaded. Both measured totals exclude the agent-memory component
loaded by the `memory: project` declaration on `.claude/agents/epic-orchestrator.md`, which is
gitignored and therefore not measurable from committed files; both totals are consequently a
lower bound on injected context.
