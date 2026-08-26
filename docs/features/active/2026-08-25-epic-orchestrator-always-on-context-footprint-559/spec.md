# 2026-08-25-epic-orchestrator-always-on-context-footprint (Spec)

- **Issue:** #559
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-26
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** `full-bug` — this file is the sole acceptance-criteria source. `user-story.md` is supplementary narrative context and carries no acceptance criteria.

## Source Precedence

This spec is written against the completed research at
`docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/research/2026-08-25T23-10-epic-orchestrator-context-footprint-research.md`.
Every line number, line count, and file count in that research was measured against the current
worktree. Where the research and `issue.md` disagree, the research is authoritative and this spec
follows the research. The corrections carried forward are listed in "Corrections to the Issue Text"
below.

## Context

`.claude/agents/epic-orchestrator.md` and its transitively injected standing context total **2,158
measured lines** before the agent receives a delegation prompt or reads any file. Six distinct
defects (F1 through F6) contribute. Five are mechanical removals of duplicated, misdirected, or
non-applicable content. One (F6) is a missing bounded return contract whose cost scales with the
number of child features in an epic wave.

Three of the six defects reach beyond the epic surface. F3 affects every agent in the repository,
because five `.claude/rules/*.md` files carry no frontmatter at all and therefore load
unconditionally into every session.

Measured baseline (research §1.4):

| Component | Lines |
|---|---|
| `CLAUDE.md` (59) + `.claude/agents/epic-orchestrator.md` (162) | 221 |
| Six preloaded skills | 936 |
| Four deliberate `paths: ["**"]` rules | 316 |
| Five unscoped rules | 685 |
| **Total** | **2,158** |

Projected after-state for F1 + F2 + F3 (research §1.5): approximately **970 lines**, a reduction of
approximately 1,188 lines. That figure is a projection. The measured after-state is a required
deliverable (see Acceptance Criteria).

Environment:

- OS/version: Windows 11 Pro 10.0.26200. The defect is repository-neutral; it lives in committed
  configuration files.
- Language: Markdown and YAML frontmatter. One Python test-support module is a forced write.
- Data source: `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`,
  `.claude/skills/orchestrate/SKILL.md`, `.claude/rules/*.md`, `CLAUDE.md`.

Impact / Severity:

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Corrections to the Issue Text

The following five statements in `issue.md` did not survive verification. This spec is written
against the verified facts.

| # | `issue.md` statement | Verified fact |
|---|---|---|
| C1 | "all fifteen rules files" | `.claude/rules/` holds **nineteen** files. Fourteen carry `paths:` and `description:`. **Five carry no frontmatter block at all**, so F3 is an **insertion** of a new block at the top of each file, which shifts every downstream line number in those five files. |
| C2 | F2 heading: "Four preloaded skills" | The agent preloads **six** skills; the target is three; **three** are removed. Additionally, **no prose in either epic file references any removed skill**, so no `Skill` invocation needs to be inserted at a point of use. F2 is a three-line frontmatter deletion and nothing else. |
| C3 | F4: the cited `spec.md` "does not exist anywhere under `docs/`" | The referent **does exist**: `docs/features/completed/2026-07-02-epic-orchestrate-275/spec.md`, and it carries `### 4.`, `### 6.`, and `### 10.`. The defect is that the citation is relative and unqualified ("of this feature"), so it does not resolve from the runtime file, and the originating feature has since moved from `active/` to `completed/`. The fix direction is unchanged; the justification is. |
| C4 | F5: "`CLAUDE.md:303` states >= 80%" | `CLAUDE.md` is **59 lines**. It contains **no coverage figure and no toolchain-loop statement**. There is no line 303. The 80% figure and the four-step loop live in **`AGENTS.md`** (lines 117-118 and 44-51), the Codex/`.agents` standing-guidance surface. F5's mechanical half against `CLAUDE.md` is therefore small: the duplicated `## Tone Policy` body, approximately four lines. |
| C5 | F5: "the 80% figure is attached to a COM/VSTO/WinForms 'testable denominator' exemption" | The literal `testable denominator` appears nowhere in the repository except inside this feature's own documents. No COM/VSTO/WinForms denominator exemption exists in any policy file in this repository. The two figures nonetheless attach to different denominators — see "Reserved Human Decision" below. |

Two binding constraints are absent from the issue text and dominate the blast radius:

- **B1 — a pinned SHA-256 digest freezes both epic files.**
  `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:105-117` pins the SHA-256
  of `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`, consumed
  by `test_frozen_epic_surface_matches_pinned_baseline_digest` in
  `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:470-485`. **Every one of
  F1, F2, F4, and F6 breaks this test.** The pin belongs to still-active feature
  `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/`, so
  `parallel_orchestrator_surface_expectations.py` is a contention point with a concurrent item.
- **B2 — a byte-identity mirror test forces the bundled payload into the same commit.**
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126` asserts that every
  repository `.claude/**` file (excluding `settings.local.json` and `.claude/agent-memory/**`) is
  present under `extensions/drm-copilot/resources/claude-customizations/` and **byte-identical**.
  The **eight** mirror files listed in "Files to Change" are certain writes in this change, not a
  follow-up.

## Repro & Evidence

Steps to reproduce:

1. Launch an `Agent(epic-orchestrator)` delegation.
2. Measure the context injected before the delegation prompt: the agent file, its six preloaded
   skills, every unconditionally-loaded `.claude/rules/` file, and `CLAUDE.md`.
3. Observe 2,158 lines of always-on content, including three preloaded skills serving delegations
   the agent's own Delegation Model forbids it to make, 685 lines of rules governing surfaces the
   epic run does not touch, two startup instructions to re-read content already injected verbatim,
   and three unresolvable `spec.md` section citations.

Expected behavior: the epic-orchestrator surface loads only the content it needs — three preloaded
skills, rules files scoped by `paths:` frontmatter to the artifacts they govern, no startup
instruction to re-read already-injected files, no unqualified section citation, `CLAUDE.md`
pointing at the rules files rather than restating them, and a bounded fixed-shape return contract
for child `orchestrator` delegations.

## Scope & Non-Goals

### In scope

F1, F2, F3, F4, **F5's mechanical half only**, and F6.

### Out of scope — recorded explicitly to prevent scope creep

| Excluded | Reason |
|---|---|
| **`AGENTS.md`** | Holds the actual 80%-vs-85% and four-vs-seven contradictions at lines 117-118 and 44-51. It is the Codex standing-guidance surface, is outside the issue's F5 scope, and its reconciliation is blocked on the same reserved human decision. **`AGENTS.md` is not written by this change.** |
| **F5's decision half** | Reserved for a human. See "Reserved Human Decision" below. |
| **`.agents/` and `.codex/` mirrors** | Changing the `.claude/` originals leaves `.agents/skills/{orchestrator-state,ci-workflows,benchmark-baselines,epic-orchestrate,orchestrate}/SKILL.md` and `.codex/agents/epic-orchestrator.toml` stale, **and no test catches it** (`test_push_down_codex_and_agents_resource_contracts.py` sets `SCOPED_ROOTS = (Path(".codex"), Path(".agents"))` and compares the bundle against the repository `.agents`/`.codex`, never against `.claude/`). A follow-up push-down is therefore required and is recorded in "Rollout & Follow-up". This change does not widen to include it. |
| **`.github/instructions/**`** | Non-modifiable per `CLAUDE.md:32` and `.claude/skills/policy-compliance-order/SKILL.md:32`. |
| **`config/orchestration-routing.json`** and its resources mirror | The `epic` route's `required_skills` list still names the three de-preloaded skills, but that is a **run-level receipt obligation satisfied across the whole delegation chain**, not an agent-preload list. `orchestrate`, `pr-context-artifacts`, and `pr-base-branch-merge-base` are already in that list without being preloaded on `epic-orchestrator`. Removing the three preloads therefore does not break `validate_epic_orchestrator_state_text`. Trimming the routing file would widen scope and is not done. |
| **The six other skills carrying the same F1 `## Prerequisites` defect** | `.claude/skills/{epic-plan,parallel-plan,parallel-orchestrate,parallel-add,parallel-close,parallel-remove}/SKILL.md` each carry the identical re-read block. The issue scopes F1 to the two epic files. Recorded as a follow-up candidate. |
| **The fourteen already-scoped `.claude/rules/*.md`** | Verified to carry both `paths:` and `description:`. Read-only. |
| **Any `docs/features/completed/**` artifact containing `spec.md §`** | Immutable history. F4's criterion is scoped to `.claude/` for this reason. |
| **Splitting `.claude/rules/parallel-orchestration.md`** into a schema rule and a blast-radius rule | Would give each a narrower `paths:` set, but rewrites a 390-line rule that four other subsystems cite by path. Scope widening. Follow-up candidate only. |

## Root Cause Analysis

Each defect has an independent cause; there is no single upstream fault.

- **F1** — the startup protocols were written before path-scoped rule auto-injection existed as the
  loading mechanism, so they instruct a read of content the runtime already injects verbatim.
- **F2** — the `skills:` list was populated with everything the epic surface might touch, rather
  than with what the agent's own Delegation Model permits it to do.
- **F3** — five rules files were authored without frontmatter. Absence of `paths:` means
  unconditional load, so omission silently produces the broadest possible scope. No repository test
  asserts frontmatter presence, so the omission was never surfaced.
- **F4** — the citations were written while the originating feature's `spec.md` was a sibling of
  the authoring context. The phrase "of this feature" was accurate then and is unresolvable from
  the runtime file now.
- **F5** — policy bodies were copied into standing-instruction files rather than referenced, and
  the copies then diverged from the rules files as the rules were revised.
- **F6** — child `orchestrator` delegations were never given a return contract, because the parent
  re-derives authoritative state from git and `gh` regardless. The returned prose is therefore paid
  for and discarded.

## Proposed Fix

### F1 — remove startup instructions to re-read already-injected content

- `.claude/agents/epic-orchestrator.md`: delete lines 57-58 (`Read CLAUDE.md...`,
  `Read applicable .claude/rules/ files...`). Renumber the remaining `## Startup Protocol` steps
  contiguously from 1: the ordinals at lines 59, 61, and 65 become 1, 2, 3. Continuation lines 60
  and 62-64 and 66 are unchanged. No text elsewhere in the repository cites these step ordinals for
  the epic agent.
- `.claude/skills/epic-orchestrate/SKILL.md`: delete the `## Prerequisites` block. The block
  occupies lines 22-28. **Delete 22-29 (or 21-28)**, not 22-28: deleting exactly 22-28 leaves the
  blank line 21 adjacent to the blank line 29, producing two consecutive blank lines before
  `## Epic Dependency Manifest`. Exactly one blank line must separate the preceding paragraph from
  that heading.
- Add no replacement text in either file. No cross-reference in the repository depends on the
  deleted block.
- `.claude/skills/policy-compliance-order/SKILL.md:19-28` lists `CLAUDE.md` and the rules files as
  a **precedence order**, not a read instruction, and its own line 19 states that Claude Code
  auto-loads rules via path-scoped frontmatter. It is not in F1's scope and needs no edit.

### F2 — reduce the preloaded skill set from six to three

Delete lines 22, 23, and 25 of `.claude/agents/epic-orchestrator.md` frontmatter, leaving `skills:`
as exactly `policy-compliance-order`, `epic-orchestrate`, `acceptance-criteria-tracking`.

Removed: `feature-promotion-lifecycle` (121 lines), `atomic-plan-contract` (204 lines),
`evidence-and-timestamp-conventions` (176 lines). Total removed: 501 lines.

**No prose edit is required.** Each removed skill name appears in the two epic files only on its own
frontmatter line; a grep for each name returns zero prose matches in both files. The issue's
conditional instruction ("if any prose depends on a removed preload, convert it to an explicit
`Skill` invocation") therefore does not fire.

### F3 — add `paths:` and `description:` frontmatter to the five unscoped rules files

The five files carry **no frontmatter block at all**. The edit inserts a new block at the top of
each, matching the shape used by the fourteen already-scoped files: opening `---`, a `paths:` list
of double-quoted globs, an unquoted `description:` scalar containing no colon, closing `---`, one
blank line, then the existing `# Heading`.

Per-file glob sets, each justified against the rule's own stated scope or enforcement section:

- **`ci-workflows.md`** — `.github/workflows/**`. The rule's own `## Scope` names workflow YAML and
  nothing else. Accept as suggested; no second glob is justified.
- **`benchmark-baselines.md`** — `scripts/benchmarks/**`, `**/baseline*.json`. **Material finding:
  `scripts/benchmarks/` does not exist in this repository**, `Test-BaselineProvenance.ps1` does not
  exist, and no file matches `**/baseline*.json`. The rule governs a surface that is entirely
  absent, so this glob set correctly matches zero current files. This is the correct outcome under
  the rule's own scope statement and must be recorded so a later reader does not mistake the empty
  match for mis-scoping. **No acceptance criterion may assert that this rule's glob matches at
  least one file.**
- **`plan-acceptance-gates.md`** — the three suggested globs plus
  `scripts/dev_tools/validate_orchestration_artifacts.py`,
  `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`,
  `docs/features/**/remediation-plan.*.md`, and `.claude/skills/atomic-plan-contract/SKILL.md`. The
  two dispatchers and the authoring-side skill are named by the rule's own `## Enforcement` and
  authoring-guidance sections but are missed by the suggested set; `remediation-plan.*.md` is the
  same artifact type produced by the remediation loop and validated by the same `plan` artifact
  type.
- **`orchestrator-state.md`** — see "The `orchestrator-state.md` reach requirement" below.
- **`parallel-orchestration.md`** — the four suggested globs plus the blast-radius doctrine surface,
  which the suggested set leaves entirely uncovered: `scripts/dev_tools/*blast_radius*`,
  `config/blast-radius.json`, `**/config/blast-radius.json`,
  `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`,
  `.claude/lib/blast-radius/**`, `.claude/lib/bash/parallel-yaml-scan.sh`, plus the dispatchers,
  `.claude/hooks/enforce-epic-merge-gate.ps1`, the two parallel personas, and
  `.claude/skills/parallel-*/SKILL.md`.

#### The `orchestrator-state.md` reach requirement

The issue's suggested glob set for this rule is
`artifacts/orchestration/*orchestrator-state.json` plus `scripts/dev_tools/*orchestrator_state*`.
**That set reaches none of the ten surfaces that write those checkpoints.** The writers are the five
orchestration personas (`.claude/agents/{orchestrator,epic-orchestrator,parallel-orchestrator,epic-planner,parallel-planner}.md`)
and the five procedure skills (`.claude/skills/{orchestrate,epic-orchestrate,parallel-orchestrate,epic-plan,parallel-plan}/SKILL.md`).
The suggested set covers the checkpoint artifact and the validators only.

The checkpoint file itself is written by the `Write`/`Edit` tool at run time. Whether that write
puts the file in scope for path-scoped rule activation is a Claude Code runtime behavior with no
in-repository evidence in either direction. Relying on it is the single highest risk in F3.

**The glob set for `orchestrator-state.md` must therefore include the ten writer files
explicitly**, in addition to the artifacts, the validators
(`scripts/dev_tools/*orchestrator_state*`, 19 files verified;
`extensions/drm-copilot/src/lib/validate/orchestrator-state-*`, 9 files verified), the two
reference implementations (`compute_complexity_floor.py`, `resolve_delegation_model.py`), the two
hooks named by the rule's own enforcement section, and `config/orchestration-routing.json`.

Trade-off, recorded deliberately: including the five orchestration persona files means
`orchestrator-state.md` (108 lines) re-enters the context of any session that edits an orchestration
persona — including this feature, which edits `epic-orchestrator.md`. That is correct behavior; a
session editing an orchestrator surface should see the checkpoint invariants. It does **not** offset
F3's saving for the epic-orchestrator's own runtime delegations, which do not have those files in
scope.

#### F3 verification limitation, stated explicitly

**No repository code reads `paths:` frontmatter from `.claude/rules/`.** The consumer is the Claude
Code runtime itself. The Codex native converter reads rule *bodies* and emits `name:` +
`description:` frontmatter with no `paths:`. Consequently, **glob correctness cannot be asserted by
any repository test.** The only in-repository assertions available are structural: the frontmatter
block parses as YAML, `paths:` is a list of non-empty strings, and `description:` is a non-empty
string. Behavioral activation is a runtime property. The acceptance criteria below are written to
respect this limit rather than to assert something the toolchain cannot evaluate.

### F4 — resolve the three unqualified `spec.md` section citations

Exactly three occurrences exist under `.claude/`. No fourth exists.

| # | Location | Resolution |
|---|---|---|
| 1 | `.claude/agents/epic-orchestrator.md:107` (§4, §10) | Re-point at `.claude/skills/epic-orchestrate/SKILL.md` `## Merge-on-Green Kickoff Parameter` (§4) and `## Context Handoff to Dependent Features` (§10). Both are fully restated in the skill; the existing clause "and restated procedurally in the `epic-orchestrate` skill" becomes the only authority rather than a secondary one. |
| 2 | `.claude/agents/epic-orchestrator.md:136` (§6) | Re-point the schema authority at `validate_epic_orchestrator_state_text`, implemented in `scripts/dev_tools/validate_epic_orchestrator_state.py`. The agent's own Completion Requirements item 4 (line 159) already names that function, so the citation becomes internally consistent. |
| 3 | `.claude/skills/epic-orchestrate/SKILL.md:268` (§6) | **Delete the clause.** The surrounding `## Epic-Level Checkpoint` section (lines 261-282) is itself the schema statement, and lines 278-282 already name the validator and its module path. Re-pointing this line at "the corresponding section of `epic-orchestrate/SKILL.md`" as the issue suggests would be a self-reference. Deleting the clause, or re-pointing it at `validate_epic_orchestrator_state_text` for symmetry with #2, is the correct resolution. |

All other path-like tokens in both epic files were checked and resolve to existing files. No further
dangling reference exists.

**Criterion scope.** Occurrences of `spec.md §` also exist in this feature's own documents, in the
promoted lifecycle record, and in five immutable `docs/features/completed/**` artifacts. F4's
criterion is scoped to `.claude/` for that reason; an unscoped criterion would be unsatisfiable
without rewriting completed-feature history.

### F5 — mechanical half only

`CLAUDE.md` is 59 lines with four sections: `## Tone Policy` (7-16), `## Policy Compliance Reading
Order` (18-32), `## Language-Specific Rules` (34-43), `## Architecture` (45-59).

The only duplicated policy body in the file is the `## Tone Policy` bullet block at lines 11-14,
which restates `.claude/rules/tonality.md` (80 lines, `paths: ["**"]`, therefore always loaded
alongside it).

Mechanical change set:

| Element | Lines | Action |
|---|---|---|
| `## Tone Policy` bullet body | 11-14 | Replace with a one-line pointer to `.claude/rules/tonality.md`, which is already always-loaded. |
| Existing authority sentence naming `.github/copilot-instructions.md` and `.github/instructions/tonality.instructions.md` | 16 | Retain. Optionally add `.claude/rules/tonality.md` as the runtime-loaded derivative. |
| `## Policy Compliance Reading Order` | 18-32 | **Preserve verbatim.** |
| `## Language-Specific Rules` | 34-43 | Already a pointer block, not a duplication. No change required. |
| `## Architecture` | 45-59 | Not duplicated in `.claude/rules/`. No change. |

Two elements the issue instructed be preserved:

- **The compliance order** is at `CLAUDE.md:18-32` and is preserved verbatim.
- **The C#-specific toolchain command list is not in `CLAUDE.md`.** `CLAUDE.md` contains no
  toolchain command list of any kind. That list lives in `.claude/rules/csharp.md`
  (`paths: ["**/*.cs", "**/*.csproj"]`, already correctly scoped). There is nothing to preserve in
  `CLAUDE.md` and nothing to change in `csharp.md`. The instruction is satisfied by leaving both
  alone.

Net mechanical saving in `CLAUDE.md`: approximately four lines. F5 therefore carries a small share
of the total reduction. **No coverage threshold value and no toolchain stage count is changed
anywhere by this work.**

### F6 — bounded child return contract

`.claude/skills/epic-orchestrate/SKILL.md` launches a full wave of child `orchestrator` agents whose
unconstrained prose reports return into the parent's context. The parent then deliberately distrusts
those reports and re-derives authoritative state from `git worktree list --porcelain`, `git branch`,
and `gh pr view --json state,mergedAt,headRefOid`. The returned prose is paid for and discarded.
This is the only defect whose cost scales with epic size: one wave of N children returns N reports
into a single parent context.

**Parent side** — add a new `## Bounded Child Return Contract` section to
`.claude/skills/epic-orchestrate/SKILL.md`, placed immediately after `## Merge-on-Green Kickoff
Parameter` (after line 132) and before `## Model Selection` (line 134), so that the contract sits
adjacent to the kickoff line it constrains rather than being separated from it by 25 lines of
model-routing prose.

Required fixed shape — six fields, each already present in the epic checkpoint's `features[]`
records:

| Field | Type | Existing source in the skill |
|---|---|---|
| `issue_num` | positive integer | `epic.md` frontmatter primary key (`SKILL.md:61`) |
| `feature_folder` | string | `epic.md` frontmatter (`SKILL.md:63-66`) |
| `merge_status` | enum | `SKILL.md:269-271` |
| `pr_number` | integer or null | `SKILL.md:274` re-derivable field list |
| `merge_commit_sha` | string or null | `SKILL.md:131` |
| `blocked_reason` | string or null | `SKILL.md:200-203` |

The plan may add at most `branch_name` and `worktree_path`, which are the inputs to
`git worktree remove` in `## Worktree Cleanup` (lines 228-237), if it prefers to remove a
re-derivation round-trip.

Required prose, per the issue's acceptance condition:

1. The shape is fixed and content beyond it is **discarded**.
2. Authoritative state is **re-derived regardless**, from the three commands above. This is the
   rationale: an unconstrained prose report is not trusted, so returning it costs context and buys
   nothing. The parallel-surface analogue is already written as
   `.claude/rules/parallel-orchestration.md` `## Cache Doctrine — the checkpoint is not the source
   of truth`, which names the same three commands; F6's rationale should cite that doctrine rather
   than restate it.
3. The constraint scales with wave width.

**Kickoff line** — `.claude/skills/epic-orchestrate/SKILL.md:126` is the literal epic-mode kickoff
line. Append the child-facing half of the constraint to it, in the same imperative form as the
existing trailing directive. `.claude/agents/epic-orchestrator.md:105-107` describes that kickoff
line **by reference, not verbatim**, so it needs no matching change beyond the F4 citation fix
already planned for line 107. Verify at execution that the agent file does not quote the kickoff
line's text.

**Child side — the decisive question is answered YES.** `.claude/skills/orchestrate/SKILL.md`
requires a matching edit. Three pieces of evidence:

1. **The precedent already exists in that file for the sibling marker.**
   `.claude/skills/orchestrate/SKILL.md:90-97` is a full `## Preparation Mode` section documenting
   the other marker-driven mode a parent injects into a child `orchestrator`'s kickoff line, and
   line 97 states what the child must return in its final output. A final-output requirement
   injected by a parent's kickoff marker is therefore already an established child-side documented
   obligation in this exact file.
2. **The child's own completion contract says nothing about the returned text.**
   `## Completion Requirements` (lines 161-168) constrains artifacts on disk, validation gates,
   checkpoint state, and the model-routing gate. Nothing in the 368-line file constrains the shape
   or size of what the orchestrator reports to its caller. The child has no instruction to be terse.
3. **Every other epic-mode obligation is already documented on the child side.** `Epic mode: true`
   currently has three effects, and all three are written into `.claude/skills/orchestrate/SKILL.md`
   (lines 223, 239-242, and 285). F6 adds a fourth epic-mode effect; stating it on the parent side
   alone would break a three-for-three pattern and leave the child side incomplete.

The child-side edit is a short subsection under `## Completion Requirements` or a new `## Epic Mode`
section adjacent to `## Preparation Mode`, stating the bounded return shape and that content beyond
it is discarded. Keep it under ten lines: this is a context-reduction feature.

## RESERVED HUMAN DECISION — F5's Decision Half

**This section records an open decision that this change does not make and must not make.**

Two policy values contradict each other. The contradiction is real. **This spec does not select a
value for either, does not infer one, and does not characterize either option as obvious, likely,
preferable, safer, or correct. Both remain open.**

### Open question 1 — the authoritative coverage floor, and its denominator

| Statement | Location | Verbatim |
|---|---|---|
| 85% line / 75% branch, all tiers | `.claude/rules/general-unit-test.md:23-24` | `- **Line coverage must remain >= 85% across all tiers (T1–T4).**` / `- **Branch coverage must remain >= 75% across all tiers (T1–T4) for languages whose coverage tooling measures branch coverage.**` |
| 85% line / 75% branch, uniform | `.claude/rules/quality-tiers.md:33-34` | `- Line coverage: >= 85%.` / `- Branch coverage: >= 75% for languages whose coverage tooling measures branch coverage.` |
| 80% repository-wide, 90% new module | `AGENTS.md:117-118` | `- **Repository-wide line coverage must remain >= 80%.**` / `- **Any new module, class, or method must target >= 90% coverage.**` |
| 80% repository-wide | `.github/instructions/general-unit-test.instructions.md:39` | `  - Repository-wide line coverage must remain \`>= 80%\`.` |
| 80% repository-wide per language | `.claude/skills/feature-review-workflow/SKILL.md:148` | `coverage regression below policy threshold (< 80% repo-wide per language, < 80% or regression for modified files, or < 90% for new files)` |

**These are different denominators, not merely different numbers.** The 80% figure is stated as a
repository-wide floor paired with a separate 90% new-module target; the 85% figure is stated as a
per-tier floor against the full production denominator with a companion 75% branch floor. Choosing
a number without choosing the denominator it attaches to does not resolve the contradiction.

### Open question 2 — the authoritative toolchain loop

| Statement | Location | Verbatim |
|---|---|---|
| Seven stages | `.claude/rules/general-code-change.md:33` | `Run the full seven-stage toolchain in this exact order and repeat until all stages pass in a single pass:` |
| | `.claude/rules/general-code-change.md:35-41` | 1 Formatting, 2 Linting, 3 Type checking, 4 Architecture-boundary tests, 5 Unit tests, 6 Contract/schema compatibility checks, 7 Integration tests |
| | `.claude/rules/general-code-change.md:43` | `Do not stop the loop until all seven stages complete without errors in a single pass.` |
| Four steps | `AGENTS.md:44` | `Run the full toolchain in this exact order and repeat until all steps pass in a single pass:` |
| | `AGENTS.md:46-49` | 1 Formatting, 2 Linting, 3 Type checking, 4 Testing |
| | `AGENTS.md:51` | `Do not stop the loop until all four steps complete without errors in a single pass.` |

### Where the contradicting statements actually live

**Not in `CLAUDE.md`.** `CLAUDE.md` is 59 lines and carries no coverage figure and no toolchain-loop
statement at any line. This corrects the issue's assumption (correction C4). The contradicting
statements live in `AGENTS.md` at lines **117-118** (coverage) and **44-51** (toolchain loop), with
a matching 80% figure in `.github/instructions/general-unit-test.instructions.md:39`.

`AGENTS.md` is a generated standing-guidance file that embeds verbatim copies of
`general-code-change.md`, `general-unit-test.md`, and `tonality.md`, **frozen at an earlier
revision**. Its embedded copy of `general-unit-test.md` still says 80%/90% while the live rule says
85%/75%; its embedded copy of `general-code-change.md` still says four steps while the live rule
says seven stages.

### Consequences for this change

1. **`AGENTS.md` is NOT written by this change.** It is out of the issue's F5 scope, and its
   reconciliation is blocked on this same decision.
2. `.github/instructions/**` is non-modifiable per `CLAUDE.md:32`.
3. **No coverage threshold value and no toolchain stage count is changed anywhere by this work.**
4. The decision must be recorded as a `human_interaction` requirement with `response: "halt"` in
   `artifacts/orchestration/orchestrator-state.json`. Per
   `.claude/rules/orchestrator-state.md` `## Invariants (human_interaction block)`, a `halt`
   requirement needs no `runbook_path`; only `response: "exception"` does. The requirement text must
   state both open questions with file-and-line evidence and must carry no recommendation.
5. The corresponding acceptance criterion below is **left unchecked and cannot be satisfied by this
   run.** That is the expected and correct outcome, not a failure of delivery.

## Files to Change

### Certain writes

| Path | Defect |
|---|---|
| `CLAUDE.md` | F5 mechanical (approximately 4 lines) |
| `.claude/agents/epic-orchestrator.md` | F2 (frontmatter lines 22, 23, 25), F1 (lines 57-58 plus renumber), F4 (lines 107, 136) |
| `.claude/skills/epic-orchestrate/SKILL.md` | F1 (delete `## Prerequisites`), F4 (line 268), F6 (new section after 132; kickoff clause at 126) |
| `.claude/skills/orchestrate/SKILL.md` | F6 child-side edit |
| `.claude/rules/parallel-orchestration.md` | F3 frontmatter insertion |
| `.claude/rules/plan-acceptance-gates.md` | F3 frontmatter insertion |
| `.claude/rules/orchestrator-state.md` | F3 frontmatter insertion, broad glob per the reach requirement |
| `.claude/rules/ci-workflows.md` | F3 frontmatter insertion |
| `.claude/rules/benchmark-baselines.md` | F3 frontmatter insertion (matches zero current files, by design) |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | B1 digest re-pin or pin removal |

### Certain writes forced by B2 — the eight bundled mirrors

Each must be byte-identical to its repository original:

| Path |
|---|
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/ci-workflows.md` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/benchmark-baselines.md` |

`CLAUDE.md` is **not** mirrored under `claude-customizations/`; the parity test's `SCOPED_ROOTS` is
`(Path(".claude"),)` only.

### Conditional writes

| Path | Condition |
|---|---|
| `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` (new) | Written if the plan chooses pytest for the structural regression tests. |
| `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` | Mutually exclusive alternative if the plan chooses Pester. Pulls the PoshQC gate into a change that otherwise has no PowerShell. |
| `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | Written only if the plan removes the digest pin rather than re-baselining it. |

## Assumptions, Constraints, Dependencies

- **Assumption.** Path-scoped rule activation is a Claude Code runtime behavior. No repository test
  can assert that a given glob activates a given rule. Structural assertions are the only available
  in-repository verification for F3.
- **Constraint (B1).** The SHA-256 pin at
  `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:105-117` is broken by every
  one of F1, F2, F4, and F6. The plan must choose between re-baselining the two constants and
  removing the pin with its consuming test. Feature 441 is still active and its audit artifacts cite
  that test by name, which the plan must weigh. Either way this file is a certain write.
- **Constraint (B2).** Every changed `.claude/**` file must be mirrored byte-identically in the same
  commit.
- **Constraint — ordering.** Edits to a shared file must be applied bottom-up so each edit's line
  numbers are unaffected by preceding edits. The digest re-pin must be the **last** step touching
  either epic file, and the bundled mirrors must be written after their originals are final.
- **Constraint — line endings.** The digest test hashes raw bytes; a CRLF/LF rewrite changes the
  digest without changing a visible character. Compute digests from the same working-tree bytes that
  will be committed.
- **Constraint — line-number citations.** F3's frontmatter insertion shifts every downstream line
  number in the five rules files. Any criterion must cite a post-change line number or a literal
  string, never a pre-change line number.
- **Constraint — checkable literals.** Per `.claude/rules/plan-acceptance-gates.md`, a search
  literal containing `<`, `>`, `${`, `$(`, or `%` is not checkable. Acceptance conditions must use
  placeholder-free substrings.
- **Constraint — frozen section.** `test_epic_orchestrator_precondition_establishes_kickoff_presence`
  pins three literal fragments inside `.claude/agents/epic-orchestrator.md` lines 85-97
  (`## Prepared-Epic Execution`). F1/F2/F4/F6 do not touch those lines. **That section must not be
  reflowed.**
- **Dependency.** None external. No production source file changes.

## Data / API / Config Impact

- **User-facing or API changes:** none. No runtime code path changes.
- **Delegation contract change:** F6 adds a fourth `Epic mode: true` effect. It is additive: a child
  that returns more than the bounded shape is not an error, its excess content is discarded, and the
  parent re-derives state regardless. No existing checkpoint field changes.
- **Config schema changes:** none. `config/orchestration-routing.json` is unchanged; its `epic`
  route `required_skills` obligation is satisfied at the run level, not by agent preloads.
- **Coverage denominator:** unchanged. `pyproject.toml:118-119` sets
  `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`, and no file under either root
  changes. The coverage metric cannot regress. A `--cov` argument aimed at the changed files would
  collect no data and would be an unfalsifiable gate under
  `.claude/rules/plan-acceptance-gates.md` G1/G3; none is written.

## Test Strategy

- **Applicable gates.** Python format (`black`), lint (`ruff`), type check (`pyright`), and
  `pytest` apply, because `parallel_orchestrator_surface_expectations.py` is a certain write.
  `pytest` is the gate that catches both B1 and B2. PoshQC applies only if the plan chooses the
  Pester test home. TypeScript extension tests, shell coverage, and the Codex agent-profile check do
  not apply.
- **No Markdown gate exists.** `.github/workflows/_docs-validation.yml` checks only that `README.md`
  is non-empty and `LICENSE` exists. `pyproject.toml`'s `dev.format-markdown` maps to a chat
  transcript formatter, not a policy-file gate. `package.json`'s prettier globs cover no `.md`. No
  repository gate parses `.claude/rules/` frontmatter; the new structural test supplies that.
- **New structural test.** One new test file asserting: all nineteen `.claude/rules/*.md` carry a
  parseable `paths:` list of non-empty strings and a non-empty `description:`; the set of rules
  whose `paths:` contains `"**"` equals exactly the four named files; every `skills:` entry of every
  `.claude/agents/*.md` resolves to an existing `.claude/skills/` `SKILL.md`; and the literal
  `spec.md §` is absent from every file under `.claude/`. Recommended home is pytest under
  `tests/scripts/dev_tools/`, which matches every existing `.claude`-content assertion in the
  repository and adds no new toolchain gate; the plan must state which home it picked and why.
- **F6 prose assertions.** Literal-fragment assertions following the pattern established in
  `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py:54-65`, using
  placeholder-free substrings.
- **Fail-before / pass-after evidence** for the new structural test under
  `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/regression-testing/`.
- **Baseline measurement** under
  `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/`.
- **Toolchain gate evidence** under
  `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/`.

All evidence is written to the canonical `evidence/<kind>/` paths under the feature folder per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No evidence is written to
`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path.

## Acceptance Criteria

### F1 — startup protocol no longer instructs re-reading injected content

- [ ] `.claude/agents/epic-orchestrator.md` `## Startup Protocol` contains exactly three steps,
      numbered contiguously `1.`, `2.`, `3.`, and no step instructs reading `CLAUDE.md` or reading
      `.claude/rules/`.
- [ ] `.claude/skills/epic-orchestrate/SKILL.md` contains no `## Prerequisites` heading, verified by
      `git grep -n -F "## Prerequisites" -- .claude/skills/epic-orchestrate/SKILL.md` returning no
      matches (exit code 1).
- [ ] Exactly one blank line separates the paragraph preceding the deleted block from the
      `## Epic Dependency Manifest` heading in `.claude/skills/epic-orchestrate/SKILL.md`; no two
      consecutive blank lines are introduced by the deletion.

### F2 — preloaded skill set reduced from six to three

- [ ] The `skills:` list in `.claude/agents/epic-orchestrator.md` frontmatter contains exactly three
      entries: `policy-compliance-order`, `epic-orchestrate`, `acceptance-criteria-tracking`.
- [ ] `git grep -n -F "feature-promotion-lifecycle" -- .claude/agents/epic-orchestrator.md .claude/skills/epic-orchestrate/SKILL.md`
      returns no matches, and the same command returns no matches for `atomic-plan-contract` and for
      `evidence-and-timestamp-conventions`.
- [ ] `config/orchestration-routing.json` is unmodified, verified by
      `git diff --exit-code -- config/orchestration-routing.json` returning exit code 0.

### F3 — all nineteen rules files carry scoped frontmatter

- [ ] All nineteen files matching `.claude/rules/*.md` carry a YAML frontmatter block that parses
      successfully, whose `paths:` value is a list of one or more non-empty strings and whose
      `description:` value is a non-empty string. Asserted by the new structural test.
- [ ] The set of `.claude/rules/*.md` files whose `paths:` list contains the entry `"**"` is exactly
      `{general-code-change.md, general-unit-test.md, quality-tiers.md, tonality.md}` — four files,
      no more and no fewer. Asserted by the new structural test.
- [ ] The `paths:` list in `.claude/rules/orchestrator-state.md` names all ten checkpoint-writer
      surfaces explicitly: the five files
      `.claude/agents/orchestrator.md`, `.claude/agents/epic-orchestrator.md`,
      `.claude/agents/parallel-orchestrator.md`, `.claude/agents/epic-planner.md`,
      `.claude/agents/parallel-planner.md`, and the five files
      `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`,
      `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/epic-plan/SKILL.md`,
      `.claude/skills/parallel-plan/SKILL.md`. Each entry is present as a literal path or is matched
      by an explicit glob in that list. Asserted by a test that resolves each of the ten paths
      against the recorded `paths:` list.
- [ ] The `paths:` list in `.claude/rules/plan-acceptance-gates.md` includes
      `scripts/dev_tools/validate_orchestration_artifacts.py`,
      `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`, and
      `docs/features/**/remediation-plan.*.md`.
- [ ] The `paths:` list in `.claude/rules/parallel-orchestration.md` includes at least one entry
      covering the blast-radius derivation surface, specifically `config/blast-radius.json`.
- [ ] The plan document records, in prose, that the glob set for
      `.claude/rules/benchmark-baselines.md` matches zero current files because
      `scripts/benchmarks/` does not exist in this repository, and that this is the correct outcome
      under that rule's own scope statement. No test asserts a non-empty match for that rule.
- [ ] The five edited rules files each retain their original body content unchanged below the
      inserted frontmatter block, verified by a diff whose only hunk in each file is the insertion at
      the top.

### F4 — no unqualified section citation remains under `.claude/`

- [ ] `git grep -n -F "spec.md §" -- .claude/` returns no matches (exit code 1). The criterion is
      scoped to `.claude/`; occurrences in this feature's own documents, in the promoted lifecycle
      record, and in `docs/features/completed/**` are out of scope and are not modified.
- [ ] `.claude/agents/epic-orchestrator.md` line 136's replacement names
      `validate_epic_orchestrator_state_text`, and
      `scripts/dev_tools/validate_epic_orchestrator_state.py` exists.
- [ ] `.claude/agents/epic-orchestrator.md` line 107's replacement names two headings that exist in
      `.claude/skills/epic-orchestrate/SKILL.md`: `## Merge-on-Green Kickoff Parameter` and
      `## Context Handoff to Dependent Features`. Verified by a test asserting both heading literals
      are present in that file.
- [ ] Every path-like token in `.claude/agents/epic-orchestrator.md` and
      `.claude/skills/epic-orchestrate/SKILL.md` that is not a template placeholder resolves to an
      existing file in the repository.

### F5 — mechanical half

- [ ] `CLAUDE.md` `## Policy Compliance Reading Order` is byte-identical to its pre-change content,
      verified by a diff showing no hunk within that section.
- [ ] The `## Tone Policy` section of `CLAUDE.md` no longer restates the tonality bullet list and
      instead names `.claude/rules/tonality.md` as the runtime-loaded authoritative source.
- [ ] `git diff -- CLAUDE.md` contains no added or removed line matching any of the literals `80%`,
      `85%`, `75%`, `90%`, `four-step`, `four steps`, `seven-stage`, or `seven stages`.
- [ ] `.claude/rules/csharp.md` is unmodified, verified by
      `git diff --exit-code -- .claude/rules/csharp.md` returning exit code 0.
- [ ] `AGENTS.md` is unmodified, verified by `git diff --exit-code -- AGENTS.md` returning exit
      code 0.
- [ ] No file under `.github/instructions/` is modified, verified by
      `git diff --exit-code -- .github/instructions/` returning exit code 0.

### F5 — decision half (BLOCKED ON A HUMAN DECISION; CANNOT BE SATISFIED BY THIS RUN)

- [ ] **BLOCKED — DO NOT CHECK.** A human has selected the authoritative coverage floor (80% with
      its repository-wide denominator and 90% new-module companion target, or 85% with its per-tier
      full-production denominator and 75% branch companion), and has selected the authoritative
      toolchain loop (four steps or seven stages); the selection has been applied to `AGENTS.md`
      lines 44-51 and 117-118 and to the `.claude/rules/` files as required. **This criterion cannot
      be satisfied by this change.** This change must not select either value, must not infer one,
      and must not change any coverage threshold or toolchain stage count anywhere. The criterion
      remains unchecked at delivery, and that is the expected outcome.
- [ ] `artifacts/orchestration/orchestrator-state.json` carries a `human_interaction.requirements[]`
      entry with `response: "halt"` whose text states both open questions with file-and-line
      evidence and carries no recommendation, and the checkpoint validates against
      `scripts/dev_tools/validate_orchestrator_state.py`.

### F6 — bounded child return contract

- [ ] `.claude/skills/epic-orchestrate/SKILL.md` contains a `## Bounded Child Return Contract`
      heading, positioned after `## Merge-on-Green Kickoff Parameter` and before `## Model
      Selection`.
- [ ] That section names all six required fields as the fixed return shape: `issue_num`,
      `feature_folder`, `merge_status`, `pr_number`, `merge_commit_sha`, `blocked_reason`. Asserted
      by a test checking each of the six literals is present within the section.
- [ ] That section states that content beyond the fixed shape is discarded, and states that
      authoritative state is re-derived regardless from `git worktree list --porcelain`,
      `git branch`, and `gh pr view --json state,mergedAt,headRefOid`.
- [ ] The epic-mode kickoff line in `.claude/skills/epic-orchestrate/SKILL.md` carries the
      child-facing half of the constraint, asserted by a placeholder-free literal-fragment test.
- [ ] `.claude/skills/orchestrate/SKILL.md` carries the matching child-side statement of the bounded
      return shape and of the discard rule, and that statement is ten lines or fewer.
- [ ] `.claude/agents/epic-orchestrator.md` lines 85-97 (`## Prepared-Epic Execution`) are unchanged,
      verified by `poetry run pytest tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py`
      passing.

### Cross-cutting

- [ ] Every `skills:` entry in every `.claude/agents/*.md` file resolves to an existing
      `.claude/skills/` directory containing a `SKILL.md`. Asserted by the new structural test over
      all agent files, not only `epic-orchestrator.md`.
- [ ] Each of the eight files under
      `extensions/drm-copilot/resources/claude-customizations/.claude/` listed in "Files to Change"
      is byte-identical to its repository original, verified by
      `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
      passing.
- [ ] The pinned SHA-256 digests in
      `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` are consistent with the
      committed contents of `.claude/agents/epic-orchestrator.md` and
      `.claude/skills/epic-orchestrate/SKILL.md`, or the pin and its consuming test have been removed
      together; either way
      `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`
      passes. The plan records which resolution it chose and why.
- [ ] A measured before-and-after always-on line count for the `epic-orchestrator` surface (agent
      file, preloaded skills, unconditionally-loaded rules, and `CLAUDE.md`) is recorded as a
      timestamped artifact under
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/`,
      stating the before total, the after total, and the per-component breakdown. The before total
      is 2,158 lines.
- [ ] The new structural regression test has a recorded fail-before result and a pass-after result
      under
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/regression-testing/`.
- [ ] The full applicable toolchain passes in a single pass: `black --check`, `ruff check`,
      `pyright`, and `pytest`; PoshQC additionally if a PowerShell file was added or edited. Gate
      output is recorded under
      `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/`.
- [ ] No file under `.agents/`, `.codex/`, or
      `extensions/drm-copilot/resources/codex-and-agents-customizations/` is modified, verified by
      `git diff --exit-code` over those three paths returning exit code 0.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| **The `orchestrator-state.md` glob does not reach checkpoint writers at run time.** Path-scoped activation on a runtime-written checkpoint file is undocumented behavior. | Name the ten writer files explicitly in the `paths:` list rather than relying on activation via the checkpoint artifact. The corresponding acceptance criterion asserts their presence. |
| **Glob correctness is unverifiable in-repository.** No test can assert that a rule activates for the files it should. | Restrict acceptance criteria to structural assertions. Require each glob set to be justified by a quotation from the rule's own scope or enforcement section, recorded in the plan. |
| **The digest pin is shared with concurrently-active feature 441.** Re-baselining it re-anchors that feature's audit claim to a state it never produced; removing it deletes a test that feature 441's audit artifacts cite by name. | The plan chooses explicitly and records the reasoning. Either resolution is a write to the same file, so the contention is unavoidable and must be visible in the declared blast radius. |
| **Line-ending rewrite silently invalidates the digest.** | Compute both digests from the same working-tree bytes that will be committed, as the final step touching either epic file. |
| **Frontmatter insertion invalidates every downstream line-number citation** in the five rules files. | No acceptance criterion cites a pre-change line number inside those five files. |
| **The `.agents/`/`.codex/` mirrors go stale and no test catches it.** | Recorded as a required follow-up with a concrete task list. A converter-parity test is proposed so the class of staleness fails loudly in future. |
| **F5's decision half is resolved by inference.** | The decision is stated in its own prominent spec section, its criterion is left unchecked with explicit blocking language, and the change is required to leave `AGENTS.md`, `.github/instructions/`, and every threshold value untouched. |

## Rollout & Follow-up

Rollout: no release step. The change lands as configuration and documentation content. The bundled
extension payload is updated in the same commit, but a repository-side `resources/` edit does not
change what an installed extension pushes down until the extension is rebuilt and reinstalled.

Required follow-ups, recorded here without widening this change:

1. **`.agents/` and `.codex/` push-down.** Regenerate
   `.agents/skills/{orchestrator-state,ci-workflows,benchmark-baselines,epic-orchestrate,orchestrate}/SKILL.md`
   from the updated `.claude/` originals via the Codex native converter, then mirror the result into
   `extensions/drm-copilot/resources/codex-and-agents-customizations/` (that mirror is
   test-enforced). Note that `.agents/skills/parallel-orchestration/` and
   `.agents/skills/plan-acceptance-gates/` do not exist; those two rules were never converted.
2. **Converter-parity test** so `.claude/` to `.agents/` staleness fails loudly rather than silently.
3. **`AGENTS.md` reconciliation** of the stale embedded rule copies at lines 44-51 and 117-118 —
   blocked on the same human decision as F5.
4. **The six other skills carrying the F1 `## Prerequisites` defect.**
5. **Possible split of `.claude/rules/parallel-orchestration.md`** into a schema rule and a
   blast-radius rule, each with a narrow `paths:` set. It is 390 lines, 57 percent of F3's saving,
   and covers two unrelated subjects.

Links:

- Issue: https://github.com/drmoisan/drm-copilot/issues/559
- Research: `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/research/2026-08-25T23-10-epic-orchestrator-context-footprint-research.md`
- Narrative context: `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/user-story.md`
