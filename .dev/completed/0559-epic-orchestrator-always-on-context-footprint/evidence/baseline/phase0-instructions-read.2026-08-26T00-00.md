# Phase 0 — Policy Reads (Issue #559)

Timestamp: 2026-08-25T23-34
Task: [P0-T1]
Feature: docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559
Work Mode: full-bug

## Policy Order:

The required reading order for this change, as stated by `[P0-T1]` and by
`.claude/skills/policy-compliance-order/SKILL.md`:

1. `CLAUDE.md` — standing repository instructions (tone policy, policy-compliance order, architecture)
2. `.claude/rules/general-code-change.md` — cross-language code change policy
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy
4. `.claude/rules/python.md` — Python toolchain and coding standards (in-scope language)
5. `.claude/rules/python-suppressions.md` — pre-authorized Ruff/Pyright suppression patterns
6. `.claude/rules/self-explanatory-code-commenting.md` — docstring and commenting standards
7. `.claude/rules/plan-acceptance-gates.md` — atomic-plan acceptance gates G1 through G6
8. `.claude/rules/orchestrator-state.md` — orchestrator-state checkpoint invariants
9. `.claude/rules/parallel-orchestration.md` — parallel-surface artifact invariants and blast-radius doctrine
10. `.claude/rules/quality-tiers.md` — module rigor tiers T1 through T4 and the gate matrix

## Files Read:

| # | File | How read | Status |
|---|---|---|---|
| 1 | `CLAUDE.md` | auto-loaded standing instruction (verbatim in session context) | READ |
| 2 | `.claude/rules/general-code-change.md` | auto-loaded standing instruction (verbatim in session context) | READ |
| 3 | `.claude/rules/general-unit-test.md` | auto-loaded standing instruction (verbatim in session context) | READ |
| 4 | `.claude/rules/python.md` | explicit `Read` tool invocation | READ |
| 5 | `.claude/rules/python-suppressions.md` | explicit `Read` tool invocation | READ |
| 6 | `.claude/rules/self-explanatory-code-commenting.md` | explicit `Read` tool invocation | READ |
| 7 | `.claude/rules/plan-acceptance-gates.md` | auto-loaded standing instruction (verbatim in session context) | READ |
| 8 | `.claude/rules/orchestrator-state.md` | auto-loaded standing instruction (verbatim in session context) | READ |
| 9 | `.claude/rules/parallel-orchestration.md` | auto-loaded standing instruction (verbatim in session context) | READ |
| 10 | `.claude/rules/quality-tiers.md` | auto-loaded standing instruction (verbatim in session context) | READ |

Additionally loaded as standing instructions and read: `.claude/rules/tonality.md`,
`.claude/rules/ci-workflows.md`, `.claude/rules/benchmark-baselines.md`.

Skills loaded for this execution: `policy-compliance-order`, `atomic-plan-contract`,
`evidence-and-timestamp-conventions`, `acceptance-criteria-tracking`.

## Constraints Carried Forward:

- Python is the only in-scope toolchain language for new code (Decision 2 of the plan). The
  four-step Python loop is format (`black`) → lint (`ruff`) → type-check (`pyright`) →
  test (`pytest`), restarting from step 1 on any failure or file change.
- Coverage thresholds are uniform across tiers: line >= 85%, branch >= 75%.
- No production file may be excluded from coverage measurement.
- Test files live under `tests/` mirroring the production tree; colocation is prohibited.
- No test may create temporary files or depend on external services.
- No file under `.claude/rules/` or `.github/instructions/` may be modified as a policy edit;
  the five `.claude/rules/*.md` writes this plan declares are frontmatter-scoping additions
  explicitly declared in the plan's blast radius, not policy-content edits.
- Suppressions (`# noqa`, `# type: ignore`) require a pre-authorized pattern or explicit approval.
- Evidence paths are non-overridable and resolve under
  `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/<kind>/`.

EXIT_CODE: 0

Output Summary: All ten required policy files were read in the stated order, plus three
additional standing-instruction rule files. Three files (`python.md`, `python-suppressions.md`,
`self-explanatory-code-commenting.md`) were read by explicit tool invocation; the remaining
seven were present verbatim as auto-loaded standing instructions. No policy file was modified.

---

## Preconditions:

Task: [P0-T10]
Timestamp: 2026-08-25T23-52

### Command:

```
ls spec.md user-story.md issue.md
grep -n "Work Mode" issue.md
grep -n "^#\+ Acceptance Criteria" spec.md
awk 'NR>=555 && /^## /{print NR": "$0}' spec.md
awk 'NR>=556 && NR<=709 && /^[[:space:]]*- \[[ x]\]/' spec.md | wc -l
grep -c "^- \[[ x]\]" user-story.md
```

Working directory:
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3\docs\features\active\2026-08-25-epic-orchestrator-always-on-context-footprint-559`

EXIT_CODE: 0

### The Three Required Statements

| # | Statement | Verdict | Evidence |
|---|---|---|---|
| 1 | `spec.md` exists in the feature folder and carries an `## Acceptance Criteria` section | **CONFIRMED TRUE** | `spec.md` present (748 lines); `## Acceptance Criteria` at line 555 |
| 2 | `user-story.md` exists and carries no acceptance criteria | **CONFIRMED TRUE** | `user-story.md` present; checkbox count is 0; the document states at line 9 that it carries no acceptance criteria |
| 3 | `issue.md` records `- Work Mode: full-bug` | **CONFIRMED TRUE** | `issue.md` line 12 reads exactly `- Work Mode: full-bug` |

All three statements are confirmed true.

### Statement 1 detail — `spec.md` acceptance-criteria section

The `## Acceptance Criteria` section spans lines 555 through 709, bounded below by the next
top-level heading `## Risks & Mitigations` at line 710. Section boundaries were established from
the observed heading positions rather than assumed:

```
555: ## Acceptance Criteria
710: ## Risks & Mitigations
722: ## Rollout & Follow-up
```

The section contains eight subheadings:

| Line | Subheading |
|---|---|
| 557 | `### F1 — startup protocol no longer instructs re-reading injected content` |
| 569 | `### F2 — preloaded skill set reduced from six to three` |
| 579 | `### F3 — all nineteen rules files carry scoped frontmatter` |
| 611 | `### F4 — no unqualified section citation remains under `.claude/`` |
| 627 | `### F5 — mechanical half` |
| 642 | `### F5 — decision half (BLOCKED ON A HUMAN DECISION; CANNOT BE SATISFIED BY THIS RUN)` |
| 657 | `### F6 — bounded child return contract` |
| 676 | `### Cross-cutting` |

### Recorded Checkbox Count Under `## Acceptance Criteria`

| Metric | Value |
|---|---|
| **Acceptance-criteria checkboxes in `spec.md` (lines 556-709)** | **38** |
| Unchecked (`- [ ]`) at baseline | 38 |
| Checked (`- [x]`) at baseline | 0 |
| Checkboxes elsewhere in `spec.md` (before line 555) | 4 — not acceptance criteria |
| Checkboxes after line 710 | 0 |
| Checkboxes in `user-story.md` | 0 |

The count was taken twice, once matching only unindented checkboxes and once matching
indented ones as well. Both returned 38, so no nested acceptance criterion was missed.

The 4 checkboxes appearing before line 555 are outside the `## Acceptance Criteria` heading and
are therefore not acceptance criteria under the `acceptance-criteria-tracking` skill. They are
excluded from the tracked total.

### AC Source Resolution

`issue.md` records `- Work Mode: full-bug`. Under the AC-source table in
`.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug` resolves the authoritative
acceptance-criteria source to **`spec.md` only**. `user-story.md` is present as narrative
context and is explicitly not an AC source for this mode, which is consistent with its own
line-9 statement that it carries no acceptance criteria. The mode marker was read from the
persisted `issue.md` metadata block, which is the single source of truth; no workflow override
was applied.

### Expected Terminal AC State

Per the plan's **RESERVED HUMAN DECISION** section, the `### F5 — decision half` subheading
carries two acceptance criteria with different dispositions, and this was verified directly
against the file:

- **Line 644** — the coverage-floor and toolchain-stage-count selection. The criterion text
  itself opens `**BLOCKED — DO NOT CHECK.**` and states that it cannot be satisfied by this
  change. It **remains unchecked at delivery**, which is the expected and correct outcome, not a
  delivery failure.
- **Line 652** — requires `artifacts/orchestration/orchestrator-state.json` to carry a
  `human_interaction.requirements[]` entry with `response: "halt"`. This criterion **is**
  deliverable and is delivered by task `[P4-T7]`.

The expected terminal state is therefore **37 of 38 checked**, with the line-644 criterion
deliberately left unchecked.

Output Summary: PASS. All three feature-document preconditions are confirmed true. `spec.md`
exists and carries an `## Acceptance Criteria` section at line 555 spanning to line 709 across
eight subheadings; `user-story.md` exists and carries zero acceptance criteria; `issue.md` line
12 records `- Work Mode: full-bug`, resolving the AC source to `spec.md` only. The recorded
acceptance-criteria checkbox count under `## Acceptance Criteria` is **38**, all unchecked at
baseline. Expected terminal state is 37 of 38 checked, because the BLOCKED line-644 criterion is
reserved for a human decision and must remain unchecked.
