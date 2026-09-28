# Research — epic-orchestrator always-on context footprint (Issue #559)

- Timestamp: 2026-08-25T23-10
- Work mode: full-bug
- Workspace root: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af78fca9c0c397078`
- Branch: `bug/epic-orchestrator-always-on-context-footprint-559`
- Scope statement read in full: `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/issue.md`
- Method note: every line number and line count in this document was measured against the
  current worktree contents, not taken from the issue text. Line counts are ripgrep
  line counts (`rg '^' --count`), which count every line including blanks. Where a
  count differs by one from the `Read` tool's last numbered line, the discrepancy is a
  trailing-newline artifact and is noted inline.

---

## 0. Executive summary of corrections to the issue text

Five statements in the issue do not survive verification. The plan must be written against
the verified facts below, not the issue text.

| # | Issue statement | Verified fact |
|---|---|---|
| C1 | "all fifteen rules files" | There are **nineteen** files in `.claude/rules/`. Fourteen carry `paths:` + `description:`; five carry no frontmatter at all. |
| C2 | F2 title: "Four preloaded skills" | The agent preloads **six** skills; the target is three; therefore **three** are removed (`feature-promotion-lifecycle`, `atomic-plan-contract`, `evidence-and-timestamp-conventions`). The issue body itself names three. |
| C3 | F4: "cite a `spec.md` that does not exist anywhere under `docs/`" | The referent **does exist**: `docs/features/completed/2026-07-02-epic-orchestrate-275/spec.md`, and it does carry `### 4.`, `### 6.`, and `### 10.`. The defect is that the citation is *relative and unqualified* ("of this feature"), so it does not resolve from the runtime file. The fix direction in the issue is still correct; the justification changes. |
| C4 | F5: "`CLAUDE.md:303` states >= 80%" | Repository-root `CLAUDE.md` is **59 lines**. It contains **no** coverage figure and **no** toolchain-loop statement. There is no line 303. The 80% figure and the four-step loop live in **`AGENTS.md`** (344 lines), which is the Codex/`.agents` standing-guidance surface, not a Claude-loaded file. |
| C5 | F5: "the 80% figure is attached to a COM/VSTO/WinForms 'testable denominator' exemption" | The literal `testable denominator` appears **nowhere** in the repository except inside this feature's own issue/spec/potential files. No COM/VSTO/WinForms denominator exemption exists in any policy file in this repository. |

Two additional constraints were discovered that the issue does not mention and that
dominate the blast radius:

- **B1 — A pinned SHA-256 digest test freezes both epic files.**
  `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:105-117` pins the
  SHA-256 of `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`,
  consumed by `test_frozen_epic_surface_matches_pinned_baseline_digest` in
  `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:470-485`. Any byte
  change to either epic file fails this test until the pins are updated or the pin is removed.
- **B2 — A byte-identity mirror test forces the bundled payload to change in the same commit.**
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126` asserts that
  every repo `.claude/**` file (excluding `settings.local.json` and `.claude/agent-memory/**`)
  is present in `extensions/drm-copilot/resources/claude-customizations/` **and byte-identical**.
  Every `.claude/` file this change touches must therefore be mirrored in the same change.
  This is not a follow-up; it is a certain write.

---

## 1. Baseline measurement — current always-on surface for `epic-orchestrator`

All counts are ripgrep line counts of the current worktree.

### 1.1 Agent file and standing instructions

| File | Lines |
|---|---|
| `CLAUDE.md` | 59 |
| `.claude/agents/epic-orchestrator.md` | 162 (`Read` shows a final numbered line 163; trailing-newline artifact) |
| **Subtotal** | **221** |

### 1.2 Preloaded skills (frontmatter `skills:`, `.claude/agents/epic-orchestrator.md:19-25`)

| Skill | Path | Lines | Target state |
|---|---|---|---|
| `policy-compliance-order` | `.claude/skills/policy-compliance-order/SKILL.md` | 40 | KEEP |
| `epic-orchestrate` | `.claude/skills/epic-orchestrate/SKILL.md` | 293 | KEEP |
| `feature-promotion-lifecycle` | `.claude/skills/feature-promotion-lifecycle/SKILL.md` | 121 | REMOVE |
| `atomic-plan-contract` | `.claude/skills/atomic-plan-contract/SKILL.md` | 204 | REMOVE |
| `acceptance-criteria-tracking` | `.claude/skills/acceptance-criteria-tracking/SKILL.md` | 102 | KEEP |
| `evidence-and-timestamp-conventions` | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` | 176 | REMOVE |
| **Subtotal (current)** | | **936** | |
| **Subtotal (target)** | | **435** | |

The issue's "~936 lines" figure is exact.

### 1.3 Rules files loaded unconditionally today

Deliberate `paths: ["**"]` (four files — these stay unconditional):

| File | Lines |
|---|---|
| `.claude/rules/general-code-change.md` | 80 |
| `.claude/rules/general-unit-test.md` | 105 |
| `.claude/rules/quality-tiers.md` | 51 |
| `.claude/rules/tonality.md` | 80 |
| **Subtotal** | **316** |

No frontmatter at all (five files — these load unconditionally by omission, and are F3's target):

| File | Lines |
|---|---|
| `.claude/rules/parallel-orchestration.md` | 390 |
| `.claude/rules/plan-acceptance-gates.md` | 116 |
| `.claude/rules/orchestrator-state.md` | 108 |
| `.claude/rules/ci-workflows.md` | 36 |
| `.claude/rules/benchmark-baselines.md` | 35 |
| **Subtotal** | **685** |

The issue's "685 lines across five files" figure is exact.

### 1.4 Total measured always-on baseline

| Component | Lines |
|---|---|
| `CLAUDE.md` + agent file | 221 |
| Six preloaded skills | 936 |
| Four `"**"` rules | 316 |
| Five unscoped rules | 685 |
| **TOTAL** | **2,158** |

### 1.5 Projected after-state (F1, F2, F3 mechanical only)

| Component | Lines |
|---|---|
| `CLAUDE.md` + agent file (minus F1's two lines) | ~219 |
| Three preloaded skills | 435 |
| Four `"**"` rules | 316 |
| Five now-scoped rules (not loaded for an epic run) | 0 |
| **TOTAL** | **~970** |

Projected reduction: **~1,188 lines, ~55%** of the always-on surface. This is a projection,
not a measurement; the "after" measurement must be taken post-change and written to
`docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/`.

### 1.6 One un-measured component

`.claude/agents/epic-orchestrator.md` declares `memory: project`, which loads
`.claude/agent-memory/epic-orchestrator/`. The repository-root `.claude/agent-memory/` is
gitignored (confirmed by `test_push_down_claude_resource_contracts.py` exempting it from the
mirror assertion), so its size is machine-local and cannot be measured from committed files.
A bundled memory set exists at
`extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/epic-orchestrator/`
(1 `MEMORY.md` + 3 feedback files). This is outside the issue's scope and is recorded only so
the measured total is not mistaken for the complete injected context.

---

## 2. F1 — startup protocol instructs re-reading already-injected content

### 2.1 `.claude/agents/epic-orchestrator.md` — verbatim current text

Lines 53-66 (`## Startup Protocol`):

```
53	## Startup Protocol
54	
55	On every invocation:
56	
57	1. Read `CLAUDE.md` for repository tone policy and architecture context.
58	2. Read applicable `.claude/rules/` files for languages in scope.
59	3. Read `artifacts/orchestration/epic-orchestrator-state.json` to check for existing epic
60	   checkpoint state.
61	4. If a valid epic checkpoint exists with a matching `epic_feature_folder`, resume from the
62	   recorded `next_step` (re-deriving durable ground truth via `git worktree list --porcelain`,
63	   `git branch`, and `gh pr view --json state,mergedAt,headRefOid` per the `epic-orchestrate`
64	   skill's resume procedure, not from in-memory notifications alone).
65	5. If no checkpoint exists or the objective is new, begin from manifest parsing
66	   (`docs/features/epics/<epic-slug>/epic.md`).
67	```

**Verified:** lines 57 and 58 are exactly the two lines the issue names. Delete both.
Renumber the remaining steps `3,4,5` → `1,2,3`. The renumber touches lines 59, 61, 65
(the leading ordinal only). Continuation lines 60, 62-64, 66 are unchanged.

**No text elsewhere in the repository cites these step numbers.** A repo-wide search for
`Startup Protocol` found citations only by section name, never by step ordinal, for the epic
agent. (The two step-ordinal citations that exist —
`docs/features/completed/2026-04-11-claude-code-architecture-136/audit-2026-04-12T02-01/feature-audit.2026-04-12T02-01.md:74`
— refer to `orchestrator.md`, not `epic-orchestrator.md`, and are historical audit artifacts.)

### 2.2 `.claude/skills/epic-orchestrate/SKILL.md` — verbatim current text

Lines 20-30:

```
20	procedure is not re-derived ad hoc on each epic run.
21	
22	## Prerequisites
23	
24	Before proceeding, `epic-orchestrator` must:
25	
26	1. Read `CLAUDE.md` for repository tone policy and architectural context.
27	2. Read applicable `.claude/rules/` files for the languages in scope.
28	3. Read the policy files listed in the compliance reading order section of `CLAUDE.md`.
29	
30	## Epic Dependency Manifest
```

**Verified:** the `## Prerequisites` block occupies lines 22-28. The issue's F1 text cites
`SKILL.md:26-28` in the Actual Behavior bullet and `SKILL.md:22-28` in the Fix sentence; the
**block is 22-28** and the whole block is the correct deletion unit.

**Whitespace caution.** Deleting exactly 22-28 leaves line 21 (blank) adjacent to line 29
(blank), producing two consecutive blank lines before `## Epic Dependency Manifest`. The
deletion range should be **22-29** (or 21-28) so a single blank line separates the preceding
paragraph from the next heading. State this explicitly in the plan; a two-blank-line residue
is a gratuitous diff artifact.

**No cross-reference depends on the deleted block.** No file in the repository cites
`epic-orchestrate/SKILL.md` `## Prerequisites`.

### 2.3 Out-of-scope observation (report only, do not widen)

The identical `## Prerequisites` re-read block exists in five other `.claude/skills/` files:
`orchestrate/SKILL.md:21`, `epic-plan/SKILL.md:24`, `parallel-plan/SKILL.md:23`,
`parallel-orchestrate/SKILL.md:37`, `parallel-add/SKILL.md:22`, `parallel-close/SKILL.md:21`,
`parallel-remove/SKILL.md:22`. The issue scopes F1 to the two epic files only. Recorded as a
follow-up candidate; **do not include**.

Separately, `.claude/skills/policy-compliance-order/SKILL.md:19-28` lists `CLAUDE.md` and the
`.claude/rules/` files as a *precedence order*, not as a read instruction, and the skill's own
line 19 states "Claude Code auto-loads rules via path-scoped frontmatter". This does **not**
violate F1's acceptance criterion ("neither file instructs reading `CLAUDE.md` or
`.claude/rules/`"), which is scoped to the two epic files. No edit needed.

---

## 3. F2 — preloaded skills the agent is forbidden to act on

### 3.1 Current frontmatter, verbatim (`.claude/agents/epic-orchestrator.md:19-26`)

```
19	skills:
20	  - policy-compliance-order
21	  - epic-orchestrate
22	  - feature-promotion-lifecycle
23	  - atomic-plan-contract
24	  - acceptance-criteria-tracking
25	  - evidence-and-timestamp-conventions
26	memory: project
```

Six preloads. Target is three. **Three** entries are deleted (lines 22, 23, 25). The issue's
F2 heading says "Four"; the count is three.

### 3.2 Prose-dependency analysis, per removed skill

Method: grep for each skill name across both epic files.

| Removed skill | Referenced in `epic-orchestrator.md`? | Referenced in `epic-orchestrate/SKILL.md`? | Verdict |
|---|---|---|---|
| `feature-promotion-lifecycle` | No (grep returns only the frontmatter line 22) | No (zero matches) | No prose dependency. Frontmatter-only edit. |
| `atomic-plan-contract` | No (only frontmatter line 23) | No (zero matches) | No prose dependency. Frontmatter-only edit. |
| `evidence-and-timestamp-conventions` | No (only frontmatter line 25) | No (zero matches) | No prose dependency. Frontmatter-only edit. |

Retained skills, for completeness:

| Retained skill | Prose reference |
|---|---|
| `policy-compliance-order` | None in either file (frontmatter only). Retained by the issue's explicit target-state list. |
| `epic-orchestrate` | `epic-orchestrator.md:48` (`## Skill` section) and eight further mentions. |
| `acceptance-criteria-tracking` | `epic-orchestrator.md:161-162` (Completion Requirements item 5). |

**Conclusion for F2:** no `Skill` invocation needs to be inserted at any point of use. The two
epic files need **no edits beyond the three deleted frontmatter lines**. This resolves the
question the delegation prompt asked.

### 3.3 A constraint the issue does not mention — the routing matrix still requires the receipts

`config/orchestration-routing.json:129-138` defines the `epic` route's `required_skills`:

```
"required_skills": [
  "epic-orchestrate",
  "orchestrate",
  "feature-promotion-lifecycle",
  "atomic-plan-contract",
  "acceptance-criteria-tracking",
  "evidence-and-timestamp-conventions",
  "pr-context-artifacts",
  "pr-base-branch-merge-base"
]
```

`scripts/dev_tools/_orchestrator_state_routing.py:582-585` enforces one error per required
skill absent from `skill_receipts[]`:

```python
actual_skills = _receipt_skills(state)
for skill in required_skills:
    if skill not in actual_skills:
        errors.append(f"Checkpoint missing required skill receipt: {skill}.")
```

Implications the plan must record:

1. Removing a **preload** does not remove the **route-level receipt obligation**. The epic
   checkpoint must still carry `skill_receipts[]` entries for `feature-promotion-lifecycle`,
   `atomic-plan-contract`, and `evidence-and-timestamp-conventions`, or
   `validate_epic_orchestrator_state_text` will fail.
2. This is already the pre-existing situation for `orchestrate`, `pr-context-artifacts`, and
   `pr-base-branch-merge-base`, which are in `required_skills` but are **not** preloaded on
   `epic-orchestrator` today. The route list is a run-level contract satisfied across the whole
   delegation chain, not an agent-preload list. Removing the three preloads therefore does not
   break the validator.
3. `config/orchestration-routing.json` is **not** in the write list. Trimming it would widen
   scope, and it is byte-mirrored at `extensions/drm-copilot/resources/config/orchestration-routing.json`
   (asserted by `test_push_down_codex_and_agents_resource_contracts.py:200-204`). Leave it alone.

---

## 4. F3 — five rules files lack `paths:` frontmatter

### 4.1 Complete enumeration of `.claude/rules/` (19 files, not 15)

| # | File | Lines | `paths:` | `description:` | Current scope |
|---|---|---|---|---|---|
| 1 | `architecture-boundaries.md` | 46 | yes (L2-4) | yes (L5) | `**/*.ts`, `**/*.cs` |
| 2 | `benchmark-baselines.md` | 35 | **NO** | **NO** | unconditional |
| 3 | `ci-workflows.md` | 36 | **NO** | **NO** | unconditional |
| 4 | `csharp.md` | 108 | yes (L2-4) | yes (L5) | `**/*.cs`, `**/*.csproj` |
| 5 | `general-code-change.md` | 80 | yes (L2-3) | yes (L4) | `**` — deliberate |
| 6 | `general-unit-test.md` | 105 | yes (L2-3) | yes (L4) | `**` — deliberate |
| 7 | `mermaid.md` | 142 | yes (L2-4) | yes (L5) | `**/*.mmd`, `**/*.mermaid` |
| 8 | `orchestrator-state.md` | 108 | **NO** | **NO** | unconditional |
| 9 | `parallel-orchestration.md` | 390 | **NO** | **NO** | unconditional |
| 10 | `plan-acceptance-gates.md` | 116 | **NO** | **NO** | unconditional |
| 11 | `powershell.md` | 97 | yes (L2-5) | yes (L6) | `**/*.ps1`, `**/*.psm1`, `**/*.psd1` |
| 12 | `python-suppressions.md` | 143 | yes (L2-3) | yes (L4) | `**/*.py` |
| 13 | `python.md` | 100 | yes (L2-3) | yes (L4) | `**/*.py` |
| 14 | `quality-tiers.md` | 51 | yes (L2-3) | yes (L4) | `**` — deliberate |
| 15 | `self-explanatory-code-commenting.md` | 97 | yes (L2-3) | yes (L4) | `**/*.py` |
| 16 | `shell.md` | 93 | yes (L2-6) | yes (L7) | `**/*.sh`, `**/*.bats`, `scripts/bash/**`, `tests/shell/**` |
| 17 | `tonality.md` | 80 | yes (L2-3) | yes (L4) | `**` — deliberate |
| 18 | `typescript-suppressions.md` | 66 | yes (L2-3) | yes (L4) | `**/*.ts` |
| 19 | `typescript.md` | 74 | yes (L2-3) | yes (L4) | `**/*.ts` |

**The four deliberate `"**"` files are confirmed** as exactly `general-code-change.md`,
`general-unit-test.md`, `quality-tiers.md`, `tonality.md`. No other file uses `"**"`.

**The five unscoped files carry no YAML frontmatter block at all** — not an empty `paths:`,
not a `description:`. Verified by reading the first lines of `orchestrator-state.md` (line 1 is
`# Orchestrator-State Remediation-Cycle and Human-Interaction Invariants`) and
`ci-workflows.md` (line 1 is `# CI Workflow Authoring`). The edit is therefore an **insertion
of a new frontmatter block at the top of each file**, not a modification of an existing one.
Every subsequent line number in those five files shifts by the block length (5-9 lines).

### 4.2 How `paths:` is consumed — the mechanism

Searched: `scripts/`, `extensions/`, `tests/`, `.claude/hooks/`. **No repository code reads
`paths:` frontmatter from `.claude/rules/`.** The consumers found are:

- **The Claude Code runtime itself.** Documented at
  `docs/engineering/claude-code-architecture.md:16`:
  > `.github/instructions/*.instructions.md` | `.claude/rules/*.md` | Path-scoped via `paths:` YAML frontmatter; activated automatically when matching files are in scope

  and at line 70:
  > `.claude/rules/*.md` | `.github/instructions/*.instructions.md` | Derived: summarized policy content with `paths:` frontmatter added

  and at line 180:
  > Update the `.claude/rules/<lang>.md` file to incorporate the policy delta while **preserving the `paths:` frontmatter**

- **`scripts/dev_tools/codex_native_converter/`** reads `.claude/rules/` for the Codex
  conversion (`inventory.py:49`, `classifier.py:351`, `mapping.py:167`, `rewrites.py:181,188`),
  but it converts rule *bodies*; the converted `.agents/skills/<name>/SKILL.md` outputs carry
  `name:` + `description:` frontmatter and **no `paths:`** (verified against
  `.agents/skills/orchestrator-state/SKILL.md:1-4`).

- **`scripts/dev_tools/push_down_claude_pack_selection.py`** references `.claude/rules/csharp.md`
  as a path constant only; it does not parse frontmatter.

**Consequence for the plan:** correctness of the globs **cannot be asserted by any repository
test**. The only in-repo assertion available is structural (the frontmatter block parses as
YAML; `paths:` is a list of non-empty strings; `description:` is a non-empty string). Behavioral
activation is a runtime property of Claude Code. State this limitation explicitly rather than
writing an acceptance criterion the toolchain cannot evaluate.

### 4.3 Per-file glob verification against each rule's own stated scope

#### 4.3.1 `.claude/rules/ci-workflows.md` (36 lines)

Own scope text (lines 33-36):
> `## Scope` — "This rule applies to any workflow step whose `run:` block uses `shell: pwsh`
> (or the repo default `pwsh`) and intentionally invokes a failing nested command. It does not
> change required-check configuration or branch protection."

Own enforcement text (lines 28-31):
> "Local feature-review cites this rule when reviewing diffs that add or modify `pwsh` steps…
> The feature-review policy rule `modified-workflow-needs-green-run` … requires a green workflow
> run against the branch head before a workflow change can merge."

Issue's suggested glob: `.github/workflows/**`.

**VERDICT: ACCEPT AS SUGGESTED.** The rule's own scope is workflow YAML and nothing else.
`.github/workflows/**` matches all 13 workflow files. Recommended set:

```yaml
paths:
  - ".github/workflows/**"
```

No second glob is justified. The rule names `.claude/skills/feature-review-workflow/SKILL.md`
as a second line of defense but does not govern that file's content.

#### 4.3.2 `.claude/rules/benchmark-baselines.md` (35 lines)

Own scope text (lines 32-35):
> `## Scope` — "This rule applies to any baseline consumed by a benchmark regression gate.
> It does not change which checks are required by branch protection; it constrains the
> provenance of the data those checks consume."

Own enforcement text (lines 27-30):
> "The validator `scripts/benchmarks/Test-BaselineProvenance.ps1` enforces both rejection
> conditions… The feature-review policy rule `modified-workflow-needs-green-run` … provides a
> second line of defense: a diff under `scripts/benchmarks/**` is Blocking unless a green
> workflow run against the branch head is present."

Rule also requires a sibling `baseline.provenance.json` per baseline file.

Issue's suggested globs: `scripts/benchmarks/**`, `**/baseline*.json`.

**VERDICT: ACCEPT, WITH A MATERIAL FINDING.**
`scripts/benchmarks/` **does not exist in this repository**. `Test-BaselineProvenance.ps1`
does not exist. No file matching `**/baseline*.json` exists. Verified by two glob searches
returning "No files found" and by a repo-wide grep for `Test-BaselineProvenance` returning only
this feature's own documents and the `.agents`/`.claude` mirror copies of the rule itself.

The rule governs a surface that is entirely absent. Scoping it to
`scripts/benchmarks/**` + `**/baseline*.json` means it **loads for zero current files**, which
is the correct outcome under the rule's own scope statement. Record this explicitly so a later
reader does not mistake the empty match for a mis-scoping.

Recommended set (adding the provenance sibling the rule itself mandates):

```yaml
paths:
  - "scripts/benchmarks/**"
  - "**/baseline*.json"
  - "**/baseline.provenance.json"
```

The third entry is subsumed by the second and may be omitted; include it only if the plan
prefers the rule's mandated filename to be literally present.

#### 4.3.3 `.claude/rules/plan-acceptance-gates.md` (116 lines)

Own enforcement text (lines 108-114):
> - `scripts/dev_tools/plan_gate_commands.py` extracts task-attributed command candidates;
>   `scripts/dev_tools/plan_gate_discrimination.py` evaluates G1 through G6…
> - `scripts/dev_tools/validate_orchestration_artifacts.py` routes the existing `plan` artifact
>   type through the two-channel entry point…
> - The TypeScript parity port is dispatched from
>   `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` for the existing `plan`
>   artifact type…
> - `.claude/hooks/validate-planner-output.ps1` is **not** modified by this rule and carries no
>   part of its enforcement.

Header text (lines 6-9) names the TypeScript modules:
> `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` with its shared-predicate
> module `plan-gate-rules.ts`, both fed by the command extractor
> (`scripts/dev_tools/plan_gate_commands.py` and
> `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`)

Authoring-guidance text (line 106):
> "`.claude/skills/atomic-plan-contract/SKILL.md` carries the authoring-side statement of this
> guidance and cross-references this file."

Issue's suggested globs: `scripts/dev_tools/plan_gate_*`, `extensions/drm-copilot/src/lib/validate/plan-gate-*`, `docs/features/**/plan.*.md`.

**VERDICT: ACCEPT WITH TWO ADDITIONS.**

Verified matches for the suggested globs:
- `scripts/dev_tools/plan_gate_*` → `plan_gate_commands.py`, `plan_gate_coverage.py`, `plan_gate_discrimination.py` (3 files, all correct).
- `extensions/drm-copilot/src/lib/validate/plan-gate-*` → `plan-gate-commands.ts`, `plan-gate-discrimination.ts`, `plan-gate-rules.ts` (3 files, all correct).
- `docs/features/**/plan.*.md` → the plan artifacts the gates evaluate. Correct, but **misses `remediation-plan.*.md`**, which is the same artifact type produced by the remediation loop and is validated by the same `plan` artifact type.

Two surfaces named by the rule's own enforcement section are **not** covered by the suggested set:
- `scripts/dev_tools/validate_orchestration_artifacts.py` (the CLI dispatcher).
- `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` (the MCP dispatcher).
- `.claude/skills/atomic-plan-contract/SKILL.md` (the authoring-side cross-reference).

Recommended set:

```yaml
paths:
  - "scripts/dev_tools/plan_gate_*"
  - "scripts/dev_tools/validate_orchestration_artifacts.py"
  - "extensions/drm-copilot/src/lib/validate/plan-gate-*"
  - "extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts"
  - "docs/features/**/plan.*.md"
  - "docs/features/**/remediation-plan.*.md"
  - ".claude/skills/atomic-plan-contract/SKILL.md"
```

The `validate_orchestration_artifacts.py` and `orchestration-artifacts.ts` entries are shared
with `parallel-orchestration.md` and `orchestrator-state.md`; that overlap is expected and
harmless (all three rules genuinely govern those dispatchers).

#### 4.3.4 `.claude/rules/orchestrator-state.md` (108 lines) — the critical sub-question

Own subject (line 3):
> "This rule governs remediation-cycle records and the optional `human_interaction` block in
> the orchestrator-state checkpoint at `artifacts/orchestration/orchestrator-state.json`."

Own enforcement text (lines 98-108) names, in order:
- `scripts/dev_tools/validate_orchestrator_state.py`
- `scripts/dev_tools/_orchestrator_state_complexity.py`
- `scripts/dev_tools/_orchestrator_state_model_routing.py`
- `scripts/dev_tools/_orchestrator_state_model_routing_gate.py`
- `scripts/dev_tools/compute_complexity_floor.py` (reference implementation, line 76)
- `scripts/dev_tools/resolve_delegation_model.py` (reference implementation, line 84)
- `.claude/hooks/validate-orchestrator-output.ps1` (line 96)
- `.claude/hooks/enforce-model-routing-receipt.ps1` (line 96)
- `config/orchestration-routing.json` (Model-Budget Contract, line 68)
- "the MCP tool `validate_orchestration_artifacts`" (line 108)
- "The MCP TypeScript surface" (line 96)
- `.claude/skills/orchestrate/SKILL.md` `## Model Selection` (lines 60, 88)

**CRITICAL SUB-QUESTION — does the suggested glob reach the surfaces that WRITE these checkpoints?**

The suggested glob is `artifacts/orchestration/*orchestrator-state.json` + `scripts/dev_tools/*orchestrator_state*`.

The surfaces that **write** an orchestrator-state-family checkpoint are the six orchestration
personas and their five procedure skills:

| Writer | Path | Covered by suggested glob? |
|---|---|---|
| orchestrator agent | `.claude/agents/orchestrator.md` | **NO** |
| epic-orchestrator agent | `.claude/agents/epic-orchestrator.md` | **NO** |
| parallel-orchestrator agent | `.claude/agents/parallel-orchestrator.md` | **NO** |
| epic-planner agent | `.claude/agents/epic-planner.md` | **NO** |
| parallel-planner agent | `.claude/agents/parallel-planner.md` | **NO** |
| orchestrate skill | `.claude/skills/orchestrate/SKILL.md` | **NO** |
| epic-orchestrate skill | `.claude/skills/epic-orchestrate/SKILL.md` | **NO** |
| parallel-orchestrate skill | `.claude/skills/parallel-orchestrate/SKILL.md` | **NO** |
| epic-plan skill | `.claude/skills/epic-plan/SKILL.md` | **NO** |
| parallel-plan skill | `.claude/skills/parallel-plan/SKILL.md` | **NO** |
| the checkpoint artifact | `artifacts/orchestration/*orchestrator-state.json` | yes |
| the validators | `scripts/dev_tools/*orchestrator_state*` (19 files, verified) | yes |

**The suggested glob does NOT reach the writers.** The checkpoint file itself is written by the
`Write`/`Edit` tool at run time; whether that write puts the file "in scope" for path-scoped
rule activation is a Claude Code runtime behavior with no in-repo evidence either way. Relying
on it is the single highest risk in F3.

The safe form covers both the artifacts and the authoring surfaces. Recommended set:

```yaml
paths:
  - "artifacts/orchestration/*orchestrator-state.json"
  - "artifacts/orchestration/*planner-state.json"
  - "scripts/dev_tools/*orchestrator_state*"
  - "scripts/dev_tools/compute_complexity_floor.py"
  - "scripts/dev_tools/resolve_delegation_model.py"
  - "extensions/drm-copilot/src/lib/validate/orchestrator-state-*"
  - ".claude/agents/orchestrator.md"
  - ".claude/agents/epic-orchestrator.md"
  - ".claude/agents/parallel-orchestrator.md"
  - ".claude/agents/epic-planner.md"
  - ".claude/agents/parallel-planner.md"
  - ".claude/skills/orchestrate/SKILL.md"
  - ".claude/skills/epic-orchestrate/SKILL.md"
  - ".claude/skills/parallel-orchestrate/SKILL.md"
  - ".claude/skills/epic-plan/SKILL.md"
  - ".claude/skills/parallel-plan/SKILL.md"
  - ".claude/hooks/validate-orchestrator-output.ps1"
  - ".claude/hooks/enforce-model-routing-receipt.ps1"
  - "config/orchestration-routing.json"
```

Verification of the two globs that use wildcards:
- `scripts/dev_tools/*orchestrator_state*` → 19 files: `_epic_orchestrator_state_launch_binding.py`, `_epic_orchestrator_state_resolution.py`, `_orchestrator_state_codex_model_routing.py`, `_orchestrator_state_codex_topology.py`, `_orchestrator_state_complexity.py`, `_orchestrator_state_human_interaction.py`, `_orchestrator_state_model_routing.py`, `_orchestrator_state_model_routing_gate.py`, `_orchestrator_state_preparation_terminal.py`, `_orchestrator_state_pr_creation_readiness.py`, `_orchestrator_state_routing.py`, `_orchestrator_state_step_status.py`, `_parallel_orchestrator_state_cohort_barrier.py`, `_parallel_orchestrator_state_drift.py`, `_parallel_orchestrator_state_mode_completion.py`, `_parallel_orchestrator_state_mutations.py`, `validate_epic_orchestrator_state.py`, `validate_orchestrator_state.py`, `validate_parallel_orchestrator_state.py`.
- `extensions/drm-copilot/src/lib/validate/orchestrator-state-*` → 9 files: `orchestrator-state-codex-model-routing.ts`, `orchestrator-state-codex-topology.ts`, `orchestrator-state-completion.ts`, `orchestrator-state-core.ts`, `orchestrator-state-human-interaction.ts`, `orchestrator-state-model-routing-existence.ts`, `orchestrator-state-preparation-terminal.ts`, `orchestrator-state-remediation.ts`, `orchestrator-state-routing.ts`.

**Trade-off to state in the plan.** Including the five orchestration agent files in the glob
means `orchestrator-state.md` (108 lines) re-enters the context of any session editing an
orchestration persona — including this very feature, which edits `epic-orchestrator.md`. That
is correct behavior (a session editing an orchestrator surface should see the checkpoint
invariants) but it partially offsets F3's saving for exactly this class of work. It does **not**
offset it for the epic-orchestrator's own *runtime* delegations, which do not have those files
in scope. If the plan prefers the narrower form, it must record that the writers are then
uncovered and that this was a deliberate choice.

#### 4.3.5 `.claude/rules/parallel-orchestration.md` (390 lines)

Own scope text (`## Scope and Backward Compatibility`, lines 16-20):
> "These invariants apply only to the three parallel artifacts named above" —
> `docs/features/parallel/<slug>/parallel.md`,
> `artifacts/orchestration/parallel-orchestrator-state.json`,
> `artifacts/orchestration/parallel-planner-state.json`.

Own enforcement text (`## Enforcement`, near the end) names:
- `scripts/dev_tools/validate_parallel_orchestrator_state.py`
- `scripts/dev_tools/_parallel_state_common.py`, `_parallel_state_structures.py`, `_parallel_state_records.py`
- `scripts/dev_tools/validate_parallel_planner_state.py`
- `scripts/dev_tools/parallel_manifest_contract.py`
- `scripts/dev_tools/validate_orchestration_artifacts.py`
- `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts`, `parallel-state-structures.ts`, `parallel-state-records.ts`, `parallel-orchestrator-state-core.ts`, `parallel-planner-state-core.ts`
- `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`
- `config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json`
- `.claude/hooks/enforce-epic-merge-gate.ps1`

The file **also** carries a large `## Blast-Radius Contention Doctrine (issue #489)` section
(roughly lines 200-330) whose subject is a **different** surface entirely:
- `config/blast-radius.json` and `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`
- `scripts/dev_tools/_blast_radius_token_shapes.py` and the `derive_blast_radius` / `validate_blast_radius` / `detect_escaped_paths` modules
- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`
- `.claude/lib/bash/parallel-yaml-scan.sh`
- `scripts/dev_tools/parallel_lane_assertion.py`
- `tests/scripts/dev_tools/test_blast_radius_config_parity.py`
- `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`
- `.claude/rules/plan-acceptance-gates.md` (the shared placeholder-marker vocabulary)

Issue's suggested globs: `artifacts/orchestration/parallel-*`, `docs/features/parallel/**`, `scripts/dev_tools/*parallel*`, `extensions/drm-copilot/src/lib/validate/parallel-*`.

**VERDICT: ACCEPT THE FOUR SUGGESTED, BUT THEY ARE INCOMPLETE.** The blast-radius doctrine
surface is entirely uncovered. Verified: `extensions/drm-copilot/src/lib/validate/parallel-*`
matches 6 files (`parallel-kickoff-artifact.ts`, `parallel-orchestrator-state-cohort-barrier.ts`,
`parallel-orchestrator-state-core.ts`, `parallel-planner-state-core.ts`, `parallel-state-records.ts`,
`parallel-state-shared.ts`, `parallel-state-structures.ts` — 7 files). Recommended set:

```yaml
paths:
  - "artifacts/orchestration/parallel-*"
  - "docs/features/parallel/**"
  - "scripts/dev_tools/*parallel*"
  - "scripts/dev_tools/*blast_radius*"
  - "scripts/dev_tools/validate_orchestration_artifacts.py"
  - "extensions/drm-copilot/src/lib/validate/parallel-*"
  - "extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts"
  - "extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts"
  - "config/blast-radius.json"
  - "**/config/blast-radius.json"
  - ".claude/lib/blast-radius/**"
  - ".claude/lib/bash/parallel-yaml-scan.sh"
  - ".claude/hooks/enforce-epic-merge-gate.ps1"
  - ".claude/agents/parallel-orchestrator.md"
  - ".claude/agents/parallel-planner.md"
  - ".claude/skills/parallel-*/SKILL.md"
```

**Alternative worth putting to the plan.** `parallel-orchestration.md` is 390 lines — 57% of
F3's entire 685-line saving — and it covers two unrelated subjects (parallel-artifact schema,
and blast-radius derivation). Splitting it into two rules files with two narrow `paths:` sets
would be a cleaner outcome. **This is scope widening and is NOT recommended for this change.**
Record it as a follow-up candidate only. If the plan takes the single-file route, the combined
glob set above is the correct one, and it will load the whole 390 lines for a blast-radius edit
that only needs one section.

### 4.4 Frontmatter block shape to insert

Match the shape already used by the fourteen scoped files exactly — opening `---`, `paths:`
list, `description:` scalar, closing `---`, then a blank line, then the existing `# Heading`:

```markdown
---
paths:
  - "<glob>"
description: <one-line summary>.
---

# <existing heading>
```

Quoting: every existing `paths:` entry in the repository is double-quoted. Match that.
`description:` is unquoted in all fourteen existing files except where it contains a colon
(`.claude/rules/csharp.md:5` uses an unquoted value containing a parenthetical). Keep values
free of colons to avoid needing quotes.

---

## 5. F4 — dangling `spec.md §N` citations

### 5.1 Complete enumeration

Repo-wide search for `spec\.md\s*§`. Occurrences inside `.claude/` (the only ones in scope):

| # | Location | Verbatim surrounding text |
|---|---|---|
| 1 | `.claude/agents/epic-orchestrator.md:105-107` | `- \`Agent(orchestrator)\` — one delegation per child feature in the manifest, carrying the epic-mode` / `  kickoff line and, for dependent features, the upstream-context citation lines (both defined in` / `` `spec.md` §4 and §10 of this feature and restated procedurally in the `epic-orchestrate` skill). `` |
| 2 | `.claude/agents/epic-orchestrator.md:135-136` | `Update \`artifacts/orchestration/epic-orchestrator-state.json\` after every completed step, per the` / `` full schema defined in `spec.md` §6: `objective`, `route_id: "epic"`, `epic_feature_folder`, `` |
| 3 | `.claude/skills/epic-orchestrate/SKILL.md:267-268` | `` `mcp_call_receipts[]`) — the full schema is defined in `spec.md` §6 of this feature. The `` |

**Exactly three, matching the issue.** No fourth occurrence exists in `.claude/`.

### 5.2 Occurrences outside `.claude/` (report only — NOT in scope)

| Location | Nature |
|---|---|
| `docs/features/active/2026-08-25-.../spec.md:35,43` and `issue.md:33,42` | This feature's own documents describing the defect. Self-referential; must not be "fixed". |
| `docs/features/potential/promoted/2026-08-25-epic-orchestrator-always-on-context-footprint.md:31,40` | Same, the promoted lifecycle record. |
| `docs/features/completed/2026-07-02-epic-orchestrate-275/plan.2026-07-02T19-13.md:80,81` | Historical plan artifact of the originating feature; `spec.md §10` there resolves correctly to its sibling. Immutable history. |
| `docs/features/completed/2026-07-02-epic-orchestrate-275/feature-audit.2026-07-02T23-00.md:84,87` | Same. |
| `docs/features/completed/2026-04-25-canonical-evidence-locations-non-overridable-158/code-review.2026-04-25T15-45.md:104` | Unrelated historical artifact. |
| `docs/features/completed/2026-07-25-orchestration-state-contract-divergences-412/evidence/other/pr-body-backcompat-statement.md:8` | `spec.md §Backward-compatibility` — a named section, not a number; unrelated. |

F4's acceptance criterion "no occurrence of `spec.md §` remains" must be scoped to `.claude/`
or it will be unsatisfiable without rewriting immutable completed-feature history. **State the
scope of the criterion explicitly in the plan.**

### 5.3 Does a satisfying `spec.md` exist?

**Yes — the issue is wrong on this point.** `docs/features/completed/2026-07-02-epic-orchestrate-275/spec.md`
exists and its headings are:

```
 1: # epic-orchestrate — Spec
78: ### 4. Merge-on-green extension to per-feature orchestration
113: ### 6. Epic-level checkpoint
187: ### 7. Wave barrier
227: ### 10. Context handoff to dependent features
```

All three cited sections (§4, §6, §10) exist. The defect is that the citation says "of this
feature" with no path, so from the perspective of a reader of `.claude/agents/epic-orchestrator.md`
the referent is unresolvable — and the feature has since moved from `active/` to `completed/`,
so any path that had been written would now be stale. The fix direction in the issue remains
correct.

### 5.4 Correct replacement targets

| # | Current | Replacement target | Justification |
|---|---|---|---|
| 1 (`epic-orchestrator.md:107`) | "`spec.md` §4 and §10 of this feature and restated procedurally in the `epic-orchestrate` skill" | `.claude/skills/epic-orchestrate/SKILL.md` `## Merge-on-Green Kickoff Parameter` (line 121) and `## Context Handoff to Dependent Features` (line 161) | §4 → the merge-on-green kickoff line; §10 → the upstream-context citation line. Both are fully restated in the skill. The clause "and restated procedurally in the `epic-orchestrate` skill" becomes the *only* authority rather than a secondary one. |
| 2 (`epic-orchestrator.md:136`) | "per the full schema defined in `spec.md` §6" | `validate_epic_orchestrator_state_text` (implemented in `scripts/dev_tools/validate_epic_orchestrator_state.py`) | The issue's suggested target. The file exists. The agent's own Completion Requirements item 4 (line 159) already names `validate_epic_orchestrator_state_text`, so the citation becomes internally consistent. |
| 3 (`epic-orchestrate/SKILL.md:268`) | "— the full schema is defined in `spec.md` §6 of this feature." | Delete the clause; the surrounding `## Epic-Level Checkpoint` section (lines 261-282) **is** the schema statement, and lines 278-282 already name the validator and its module path. | Pointing this line at "the corresponding section of `epic-orchestrate/SKILL.md`" as the issue suggests would be a self-reference. Deletion, or re-pointing at `validate_epic_orchestrator_state_text` for symmetry with #2, is the correct resolution. |

### 5.5 Do all other cross-references in the two epic files resolve?

Checked every path-like token in both files. All resolve:

- `.claude/agents/orchestrator.md` — exists.
- `.claude/skills/epic-orchestrate/SKILL.md` — exists.
- `.claude/skills/orchestrate/SKILL.md` — exists; `## Model Selection` and `Remediation Loop (R1–R5)` headings both present (lines 99 and 189).
- `.claude/hooks/enforce-epic-invocation-origin.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `validate-orchestrator-output.ps1` — all exist.
- `scripts/dev_tools/epic_wave_computation.py` — exists.
- `scripts/dev_tools/validate_epic_orchestrator_state.py` — exists.
- `scripts/orchestration/Invoke-CiGateParser.ps1` — exists.
- `.claude/lib/model-routing/ModelRouting.psm1` — exists.
- `config/orchestration-routing.json` — exists.
- `docs/features/epics/<epic-slug>/epic.md`, `epic-status.md`, `epic-kickoff.md` — templated paths, not literal.

**No further dangling reference beyond the three `spec.md §` citations.**

---

## 6. F5 — `CLAUDE.md` versus the rules files

### 6.1 THE DECISION HALF IS RESERVED FOR A HUMAN

**This research does NOT select a coverage floor and does NOT select a toolchain stage count.**
No value is recommended, inferred, implied, or characterised as likely, obvious, or preferable.
The decision is **OPEN and UNRESOLVED** and must be recorded as a `human_interaction`
requirement with `response: "halt"` per the issue. Anything in this section is a statement of
what the files currently say and where they say it.

### 6.2 The exact contradicting statements and their locations

#### Coverage floor

| Statement | File:line | Verbatim |
|---|---|---|
| 85% line / 75% branch | `.claude/rules/general-unit-test.md:23` | `- **Line coverage must remain >= 85% across all tiers (T1–T4).**` |
| | `.claude/rules/general-unit-test.md:24` | `- **Branch coverage must remain >= 75% across all tiers (T1–T4) for languages whose coverage tooling measures branch coverage.**` … |
| 85% line / 75% branch | `.claude/rules/quality-tiers.md:33` | `- Line coverage: >= 85%.` |
| | `.claude/rules/quality-tiers.md:34` | `- Branch coverage: >= 75% for languages whose coverage tooling measures branch coverage.` … |
| 80% repo-wide / 90% new module | `AGENTS.md:117` | `- **Repository-wide line coverage must remain >= 80%.**` |
| | `AGENTS.md:118` | `- **Any new module, class, or method must target >= 90% coverage.**` |
| 80% repo-wide | `.github/instructions/general-unit-test.instructions.md:39` | `  - Repository-wide line coverage must remain \`>= 80%\`.` |
| 80% repo-wide per language | `.claude/skills/feature-review-workflow/SKILL.md:148` | `     - coverage regression below policy threshold (< 80% repo-wide per language, < 80% or regression for modified files, or < 90% for new files)` |

**`CLAUDE.md` carries no coverage figure at any line.** The file is 59 lines; its sections are
`## Tone Policy` (7-16), `## Policy Compliance Reading Order` (18-32), `## Language-Specific
Rules` (34-43), `## Architecture` (45-59).

#### Toolchain loop

| Statement | File:line | Verbatim |
|---|---|---|
| Seven stages | `.claude/rules/general-code-change.md:33` | `Run the full seven-stage toolchain in this exact order and repeat until all stages pass in a single pass:` |
| | `.claude/rules/general-code-change.md:35-41` | 1 Formatting, 2 Linting, 3 Type checking, 4 Architecture-boundary tests, 5 Unit tests, 6 Contract/schema compatibility checks, 7 Integration tests |
| | `.claude/rules/general-code-change.md:43` | `**Restart from step 1** if any stage fails or auto-fixes any files. Do not stop the loop until all seven stages complete without errors in a single pass.` |
| Four steps | `AGENTS.md:44` | `Run the full toolchain in this exact order and repeat until all steps pass in a single pass:` |
| | `AGENTS.md:46-49` | 1 Formatting, 2 Linting, 3 Type checking, 4 Testing |
| | `AGENTS.md:51` | `**Restart from step 1** if any step fails or auto-fixes any files. Do not stop the loop until all four steps complete without errors in a single pass.` |

**`CLAUDE.md` carries no toolchain-loop statement at any line.**

### 6.3 Where the contradiction actually lives, and what that means for scope

`AGENTS.md` (344 lines) is a **generated** standing-guidance file. Its own header (lines 1-7):

```
# Converted standing guidance

Merged standing-guidance sources:
- `general-code-change.md`
- `general-unit-test.md`
- `tonality.md`
- `AGENTS.md`
```

It embeds verbatim copies of the three rules files, including their frontmatter, **frozen at an
earlier revision**. Its embedded copy of `general-unit-test.md` still says 80%/90%; the live
`.claude/rules/general-unit-test.md` says 85%/75%. Its embedded copy of `general-code-change.md`
still says four steps; the live rule says seven stages. `AGENTS.md:303` is `## Architecture`,
not a coverage line.

`AGENTS.md` is the Codex/`.agents` surface. It is byte-mirrored at
`extensions/drm-copilot/resources/codex-and-agents-customizations/AGENTS.md` (`AGENTS.md:117`
and the mirror both carry the 80% line), and that mirror is asserted byte-identical by
`test_push_down_codex_and_agents_resource_contracts.py:207-220` — **but only for `.codex/**` and
`.agents/**`, not for root `AGENTS.md`** (`SCOPED_ROOTS = (Path(".codex"), Path(".agents"))`).

**Consequence for the plan.** The issue scopes F5 to `CLAUDE.md`. On the verified facts:

1. There is **nothing in `CLAUDE.md` to remove** for the coverage floor or the toolchain loop;
   neither statement is there.
2. The **only** duplicated policy body in `CLAUDE.md` is the `## Tone Policy` block
   (lines 9-14, six lines of bullets plus the lead-in at line 9), which restates
   `.claude/rules/tonality.md` (80 lines, `paths: ["**"]`, therefore always loaded alongside it).
   `CLAUDE.md:16` already points at the authoritative source, but points at
   `.github/copilot-instructions.md` and `.github/instructions/tonality.instructions.md`
   rather than at `.claude/rules/tonality.md`.
3. The 80%-vs-85% and four-vs-seven contradictions are real but live between `AGENTS.md` /
   `.github/instructions/` and `.claude/rules/`. Resolving them requires touching files the
   issue does not scope, and `.github/instructions/` is explicitly non-modifiable per
   `CLAUDE.md:32` and `.claude/skills/policy-compliance-order/SKILL.md:32`.

**Recommendation to the plan: treat F5's mechanical half as narrow, and escalate the scope
mismatch alongside the reserved decision.** Do not silently expand F5 to `AGENTS.md`. Do not
silently narrow it to nothing.

### 6.4 What must be PRESERVED in `CLAUDE.md`

Per the issue: "keeping the compliance order and the C#-specific toolchain command list".

- **Compliance order — PRESERVE.** `CLAUDE.md:18-32`, the `## Policy Compliance Reading Order`
  section. Verified present and unique. Note that it enumerates `.github/instructions/*` paths,
  while `.claude/skills/policy-compliance-order/SKILL.md:17-28` enumerates the parallel
  `.claude/rules/*` paths. Both are preserved as-is unless the plan is told otherwise.
- **C#-specific toolchain command list — PRESERVE, but it is NOT in `CLAUDE.md`.** Searched:
  `CLAUDE.md` contains no toolchain command list of any kind. The C# command list lives in
  `.claude/rules/csharp.md` (108 lines, `paths: ["**/*.cs", "**/*.csproj"]`, already correctly
  scoped). Nothing to preserve in `CLAUDE.md`; nothing to change in `csharp.md`.

### 6.5 Mechanical-half change set actually available in `CLAUDE.md`

| Current | Lines | Proposed replacement |
|---|---|---|
| `## Tone Policy` body (four bullets) | 11-14 | A one-line pointer to `.claude/rules/tonality.md`, which is already always-loaded. |
| `The full tone policy is defined in .github/copilot-instructions.md and .github/instructions/tonality.instructions.md. Those files are authoritative.` | 16 | Retain, optionally adding `.claude/rules/tonality.md` as the runtime-loaded derivative. |
| `## Language-Specific Rules` list of four rule files | 38-41 | Already a pointer block, not a duplication. **No change needed.** Optionally extend the list to name the newly-scoped rules from F3 so a reader can discover them. |
| `## Architecture` | 45-59 | Not duplicated anywhere in `.claude/rules/`. **No change.** |
| `## Policy Compliance Reading Order` | 18-32 | **Preserve verbatim** per the issue. |

Net mechanical saving in `CLAUDE.md`: approximately 4 lines. This is small; say so plainly
rather than implying F5 carries a large share of the reduction.

### 6.6 The `human_interaction` record

Per `.claude/rules/orchestrator-state.md` invariants (`## Invariants (human_interaction block)`),
a `response: "halt"` requirement needs no `runbook_path` (only `response: "exception"` does).
The requirement text should state both open questions verbatim and must not carry a
recommendation:

> Two policy values contradict between `AGENTS.md` (a generated standing-guidance file carrying
> a frozen copy of the rules) and `.claude/rules/`. (a) Coverage floor: `AGENTS.md:117` states
> repository-wide line coverage >= 80% with a >= 90% new-module target;
> `.claude/rules/general-unit-test.md:23-24` and `.claude/rules/quality-tiers.md:33-34` state
> line >= 85% and branch >= 75% across all tiers. (b) Toolchain loop: `AGENTS.md:44-51` specifies
> four steps; `.claude/rules/general-code-change.md:33-43` specifies seven stages. Both values
> are reserved for a human decision. No coverage threshold and no toolchain stage count is
> changed by this work.

---

## 7. F6 — bounded return contract for child delegations

### 7.1 Where children are launched

`.claude/skills/epic-orchestrate/SKILL.md`:

- Line 106-109, `## Epic Integration Branch Lifecycle` item 3:
  > Each child feature's worktree/branch (created via
  > `Agent(orchestrator, isolation: "worktree", run_in_background: true)`) is branched from
  > `origin/<integration_branch>`, not `origin/main`.
- Lines 121-132, `## Merge-on-Green Kickoff Parameter` — **this is the epic-mode kickoff line**,
  quoted verbatim at line 126:
  > `Epic mode: true. epic_feature_folder: <epic-slug>. integration_branch: epic/<epic-slug>-integration. epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json. PR base branch MUST be <integration_branch>, not main; pass --base <integration_branch> to gh pr create.`
- Lines 134-159, `## Model Selection` — appends a second kickoff marker line at line 138.
- Lines 161-176, `## Context Handoff to Dependent Features` — appends per-dependency citation
  lines "after the epic-mode kickoff line above" (line 164).

`.claude/agents/epic-orchestrator.md:105-111` (`## Delegation Model`) mirrors the same
delegation channel and cites the kickoff line.

### 7.2 Where state is re-derived (the rationale F6 must state)

Three places state the re-derivation requirement, and all three name the identical command triple:

| Location | Verbatim |
|---|---|
| `.claude/skills/epic-orchestrate/SKILL.md:223-226` (`## Wave Barrier`) | `epic-orchestrator` does not launch wave N+1 until every wave-N feature's dependency edges are durably confirmed merged, verified against `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid` on resume, **not from in-memory completion notifications alone**. |
| `.claude/skills/epic-orchestrate/SKILL.md:273-276` (`## Epic-Level Checkpoint`) | Every field needed to re-derive state durably on resume (`worktree_path`, `branch_name`, `pr_number`, `merge_status`) is re-derivable from `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid` — **the checkpoint is a cache of that durable state, not the source of truth**. |
| `.claude/agents/epic-orchestrator.md:61-64` (Startup Protocol item 4, becomes item 2 after F1) | resume from the recorded `next_step` (re-deriving durable ground truth via `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid` per the `epic-orchestrate` skill's resume procedure, **not from in-memory notifications alone**) |

The parallel-surface analogue of this doctrine is already written as prose in
`.claude/rules/parallel-orchestration.md` `## Cache Doctrine — the checkpoint is not the source
of truth`, and it names the same three commands. F6's rationale sentence should cite that
doctrine rather than restate it.

### 7.3 Where the bounded return contract should be inserted

**Recommended insertion point: a new `##` section in `.claude/skills/epic-orchestrate/SKILL.md`
placed immediately after `## Merge-on-Green Kickoff Parameter` (i.e. after line 132) and before
`## Model Selection` (line 134).**

Rationale for that position: the kickoff line is defined at line 126 and the child-facing half
of the constraint is appended to it, so the return contract sits adjacent to the text it
constrains. Placing it after `## Model Selection` would separate the two halves by 25 lines of
unrelated model-routing prose.

Suggested heading: `## Bounded Child Return Contract`.

**Required content of the fixed shape** (the issue's minimum, plus the fields the epic
checkpoint's `features[]` records already carry, so the parent can write its checkpoint from the
return without a second lookup):

| Field | Type | Source in existing text | Required |
|---|---|---|---|
| `issue_num` | positive integer | `epic.md` frontmatter primary key (`SKILL.md:61`) | issue minimum |
| `feature_folder` | string | `epic.md` frontmatter (`SKILL.md:63-66`) | issue minimum |
| `merge_status` | enum | `SKILL.md:269-271`: `not_started`, `worktree_created`, `pr_open`, `ci_green`, `merge_conflict`, `blocked_conflict_loop_limit`, `merged`, `worktree_removed` | issue minimum |
| `pr_number` | integer or null | `SKILL.md:274` re-derivable field list | issue minimum |
| `merge_commit_sha` | string or null | `SKILL.md:131` (`epic_merge.merge_commit_sha`) | issue minimum |
| `blocked_reason` | string or null | `SKILL.md:200-203` (`step9_status: "blocked_conflict_loop_limit"`) | issue minimum |

Optional additions the plan may consider (each already exists in the epic checkpoint schema, so
adding them costs the parent nothing and removes a re-derivation round-trip):
`branch_name`, `worktree_path`, `pr_url`, `plan_path`. Recommend keeping the shape at the
issue's six required fields plus at most `branch_name` and `worktree_path`, since those two are
the inputs to `git worktree remove` in `## Worktree Cleanup` (lines 228-237).

**Required prose, per the issue's acceptance criterion:**
1. The shape is fixed and content beyond it is **discarded**.
2. Authoritative state is **re-derived regardless** of what the child returns, from
   `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid`.
   This is the rationale: an unconstrained prose report is not trusted, so returning it costs
   context and buys nothing.
3. The constraint scales: one epic wave of N children returns N reports into a single parent
   context.

### 7.4 The epic-mode kickoff line — child-facing half

`.claude/skills/epic-orchestrate/SKILL.md:126` is the literal line. The child-facing constraint
appends to it. The existing line already ends with a directive sentence
(`PR base branch MUST be <integration_branch>, not main; pass --base <integration_branch> to gh pr create.`),
so the appended clause follows the same imperative form. A shape consistent with the existing
text:

> `... pass --base <integration_branch> to gh pr create. Final report MUST be exactly the bounded return shape { issue_num, feature_folder, merge_status, pr_number, merge_commit_sha, blocked_reason } and nothing else; any additional narrative is discarded and the parent re-derives authoritative state from git and gh regardless.`

**Note on the duplicate.** `.claude/agents/epic-orchestrator.md:105-107` describes the same
kickoff line by reference, not verbatim. If the plan edits line 126, line 107 needs no matching
change beyond the F4 citation fix already planned for it. Verify this at execution time: the
agent file does not quote the kickoff line's text.

### 7.5 DEFINITIVE ANSWER — does `.claude/skills/orchestrate/SKILL.md` need a matching child-side edit?

**YES.** Three pieces of evidence, in decreasing strength.

**Evidence 1 — the exact precedent already exists in that file, for the sibling marker.**
`.claude/skills/orchestrate/SKILL.md:90-97` is a full `## Preparation Mode` section documenting
the other marker-driven mode that `epic-planner` injects into a child `orchestrator`'s kickoff
line. It documents the marker, the route, the scope, the terminal checkpoint, and — decisively —
**what the child must return**:

> `.claude/skills/orchestrate/SKILL.md:97`:
> `- **Commit.** Commit the prepared feature folder and plan to the current branch (the worktree branch created off the epic integration branch) before stopping, and report the \`plan-path\` and preflight status in the final output.`

A final-output requirement injected by a parent's kickoff marker is therefore already an
established child-side documented obligation in this exact file. A bounded return contract for
`Epic mode: true` with no corresponding child-side statement would be the only marker-driven
final-output constraint in the repository stated on the parent side alone.

**Evidence 2 — the child's own completion contract currently says nothing about the returned text.**
`.claude/skills/orchestrate/SKILL.md:161-168`, `## Completion Requirements`, constrains four
things: artifacts on disk, validation gates, checkpoint state, and the model-routing gate. It
does not constrain the shape or size of what the orchestrator reports to its caller. There is
no other section in the 368-line file that does. The child has no instruction to be terse.

**Evidence 3 — every other epic-mode obligation is already documented on the child side.**
`Epic mode: true` currently has three effects, and all three are written into
`.claude/skills/orchestrate/SKILL.md`:
- `:223` — S9 step 6: `If the checkpoint's epic_mode is true, execute gh pr merge --merge ...`
- `:239-242` — the `epic_merge` checkpoint object schema (populated only in epic mode).
- `:285` — PR Creation Gate condition 7: `epic_mode is false, OR (epic_mode is true AND the integration-branch merge ... has completed ...)`.

The pattern is consistent: `epic-orchestrate/SKILL.md` states what the parent emits;
`orchestrate/SKILL.md` states what the child does about it. F6 adds a fourth epic-mode effect
and must follow the same pattern or the child side becomes incomplete.

**Counter-consideration, recorded for completeness.** A strictly minimal fix could rely on the
kickoff line alone, since the line is delivered deterministically at delegation time and the
child reads it. This is weaker because the kickoff line is one sentence in a delegation prompt
while `orchestrate/SKILL.md` is preloaded standing context for the child, and because it breaks
the three-for-three pattern above. The evidence favours the child-side edit.

**Recommended child-side edit.** Add a short subsection under `## Completion Requirements`
(after line 168) or a new `## Epic Mode` section adjacent to `## Preparation Mode`, stating the
bounded return shape and that content beyond it is discarded. Keep it under ten lines: this is a
context-reduction feature, and a long child-side section would partially defeat it.

**Blast-radius consequence:** `.claude/skills/orchestrate/SKILL.md` **enters the blast radius**,
and with it the bundled mirror
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
(certain, via B2). It does **not** trigger the pinned-digest test (B1 pins only the two epic
files — verified against `parallel_orchestrator_surface_expectations.py:108-117`).

---

## 8. Push-down and mirror analysis

### 8.1 The bundled `.claude` payload — IN SCOPE, CERTAIN WRITES (not a follow-up)

`extensions/drm-copilot/resources/claude-customizations/.claude/` contains a full mirror,
including all nineteen `rules/*.md` files, `agents/epic-orchestrator.md`, and
`skills/epic-orchestrate/SKILL.md` (verified by glob).

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126`
(`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) enumerates **every** repo
`.claude/**` file except `settings.local.json` and `.claude/agent-memory/**`, and asserts both
presence in the bundle and **byte-identical content**:

```python
assert read_text(BUNDLED_ROOT, relative_path) == read_text(REPO_ROOT, relative_path), \
    f"Bundle content differs from repo for: {relative_path}"
```

A second, narrower test (`test_epic_run_kickoff_discovery_contract.py:107+`,
`test_discovery_fix_is_mirrored_into_bundled_payload`) independently asserts byte-identity for
`.claude/agents/epic-orchestrator.md` specifically.

**Therefore every `.claude/` file this change touches must be mirrored in the same commit.**
This is not the follow-up push-down the issue asks about; it is a hard, test-enforced
requirement of the change itself.

Note also the memory entry recorded elsewhere in this repository: a repo-side `resources/` edit
does not change what an *installed extension* pushes down until rebuild+reinstall. That affects
downstream distribution, not this commit's test gate.

### 8.2 The `.agents/` and `.codex/` mirrors — OUT OF SCOPE, follow-up REQUIRED

What exists:

| Surface | Files relevant to this change |
|---|---|
| `.agents/skills/orchestrator-state/SKILL.md` | Converted copy of `.claude/rules/orchestrator-state.md`. Frontmatter is `name:` + `description:`, **no `paths:`**. |
| `.agents/skills/ci-workflows/SKILL.md` | Converted copy of `.claude/rules/ci-workflows.md`. |
| `.agents/skills/benchmark-baselines/SKILL.md` | Converted copy of `.claude/rules/benchmark-baselines.md`. |
| `.agents/skills/epic-orchestrate/SKILL.md` | Converted copy of `.claude/skills/epic-orchestrate/SKILL.md`. |
| `.agents/skills/orchestrate/SKILL.md` | Converted copy of `.claude/skills/orchestrate/SKILL.md`. |
| `.codex/agents/epic-orchestrator.toml` | Codex persona for the epic orchestrator. |
| `AGENTS.md` (root) | Merged standing guidance embedding stale copies of three rules files. |

What does **not** exist: `.agents/skills/parallel-orchestration/` and
`.agents/skills/plan-acceptance-gates/`. Those two rules were never converted.

**Does changing the `.claude/` originals leave a mirror stale? YES, and no test will catch it.**

- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:35` sets
  `SCOPED_ROOTS = (Path(".codex"), Path(".agents"))`. It asserts that the **bundle** matches the
  **repo `.agents`/`.codex`** — it never compares `.agents/` against `.claude/`.
- `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` asserts content of
  `.agents/skills/epic-orchestrate/SKILL.md` and `.codex/agents/epic-orchestrator.toml`, but
  against its own literal fragments, not against `.claude/`.
- No test asserts converter output parity between `.claude/rules/<x>.md` and
  `.agents/skills/<x>/SKILL.md`.

**Recorded follow-up (do NOT widen this change):**
1. Regenerate `.agents/skills/{orchestrator-state,ci-workflows,benchmark-baselines,epic-orchestrate,orchestrate}/SKILL.md`
   from the updated `.claude/` originals via the Codex native converter.
2. Reconcile the stale embedded copies in root `AGENTS.md` (four-step loop at 44-51; 80%/90%
   coverage at 117-118) — **blocked on the same human decision as F5**.
3. Mirror any resulting `.agents`/`.codex` change into
   `extensions/drm-copilot/resources/codex-and-agents-customizations/` (that mirror IS
   test-enforced).
4. Consider a converter-parity test so this class of staleness fails loudly in future.

### 8.3 Documentation that describes the surface

`docs/engineering/claude-code-architecture.md` lines 16, 70, 180, 247 describe `paths:`
scoping as the mechanism. Nothing there becomes false after F3 (F3 makes the description *more*
true). **No edit needed.** Listed as a conditional write only if the plan chooses to record the
newly-scoped rules.

---

## 9. Toolchain applicability and regression-test homes

### 9.1 Which gates apply to the changed file types

The change touches Markdown + YAML-frontmatter files, plus (necessarily) one Python test-support
module and possibly one Pester test file.

| Gate | Command | Applies? |
|---|---|---|
| Markdown lint / format | — | **NO SUCH GATE EXISTS.** `.github/workflows/_docs-validation.yml` checks only that `README.md` is non-empty, `LICENSE` exists, and warns on two instruction paths. `pyproject.toml`'s `dev.format-markdown` maps to `scripts/dev_tools/markdown_label_formatter.py`, which formats chat transcripts (`LABEL_PREFIXES = ("User:", "GitHub Copilot:")`) and is not a policy-file gate. `package.json`'s prettier globs cover `src/`, `tests/`, and named config files only — no `.md`. |
| YAML-frontmatter validation | — | No repository gate parses `.claude/rules/` frontmatter. A new test must supply it. |
| Python format | `poetry run black --check .` (`_quality-checks.yml:54-56`) | **YES**, if `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` is edited. |
| Python lint | `poetry run ruff check` (`_quality-checks.yml:59-61`) | **YES**, same condition. |
| Python type check | `poetry run pyright` (`_quality-checks.yml:64-66`) | **YES**, same condition. |
| Python tests | `poetry run pytest` (`_quality-checks.yml:74-76`; `pyproject.toml` `testpaths = ["tests"]`) | **YES, MANDATORY** — this is the gate that catches B1 and B2. |
| PowerShell format/analyze/test (PoshQC) | `.github/workflows/_poshqc.yml`; locally the `mcp__drm-copilot__run_poshqc_*` MCP tools per `.claude/rules/powershell.md` | **CONDITIONAL** — only if a `.ps1`/`Tests.ps1` file is added or edited. No `.ps1` change is required by the six defects; a Pester regression test would trigger it. |
| Extension TypeScript tests | `.github/workflows/_drm-copilot-extension-tests.yml` | **NO** — no `.ts` file changes. |
| Shell coverage | `.github/workflows/_shell-coverage.yml` | **NO** — no `.sh`/`.bats` change. |
| Codex agent profile check | `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` (`_quality-checks.yml:69-71`) | **NO** — no `.codex/agents/*.toml` change. |

### 9.2 The three existing tests that will fail without a matching edit

| Test | File:line | Trigger | Required action |
|---|---|---|---|
| `test_frozen_epic_surface_matches_pinned_baseline_digest` | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:470-485`, constants at `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:105-117` | Any byte change to `.claude/agents/epic-orchestrator.md` (F1, F2, F4) or `.claude/skills/epic-orchestrate/SKILL.md` (F1, F4, F6) | Recompute both SHA-256 digests and update the two constants, **or** remove the pin. See 9.3. |
| `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126` | Any change to any `.claude/**` file | Mirror every changed file into `extensions/drm-copilot/resources/claude-customizations/.claude/...` byte-for-byte. |
| `test_discovery_fix_is_mirrored_into_bundled_payload` | `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py:107+` | Change to `.claude/agents/epic-orchestrator.md` or `.claude/skills/epic-run/SKILL.md` | Subsumed by the previous row; mirroring satisfies both. |

Additionally, `test_epic_orchestrator_precondition_establishes_kickoff_presence`
(`test_epic_run_kickoff_discovery_contract.py:82-104`) pins three literal fragments inside
`.claude/agents/epic-orchestrator.md` lines 85-97 (the `## Prepared-Epic Execution` section).
F1/F2/F4/F6 do not touch those lines, so **no action is required**, but the plan must state
that the section is not to be reflowed.

### 9.3 The pinned-digest question the plan must decide

The pin's own comment (`parallel_orchestrator_surface_expectations.py:105-107`) states its
purpose:

```python
# Baseline SHA-256 digests of the frozen epic surface, captured before any Phase
# 1 edit. This feature must modify neither file, so the digests are pinned as
# constants and compared without any git dependency in-test.
```

The pin belongs to feature `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/`,
which is **still in `active/`**. Its purpose is to prove that *that* feature did not touch the
epic surface. Issue #559 is a different feature that legitimately does touch it.

Two options, both writes to the same file:
- **(a) Update the two digest constants** to the post-change SHA-256 values. Preserves the pin's
  intent (nobody changes the epic surface accidentally) but re-baselines it to a state feature
  441 never produced, which weakens 441's own audit claim if 441 is re-audited.
- **(b) Remove `PINNED_FROZEN_SURFACE_HASHES` and the consuming test.** The pin's stated purpose
  is exhausted once 441 completes; a permanent digest pin on a file another feature is expected
  to edit is a recurring cost.

**This research does not choose between (a) and (b).** It is a design decision for the plan.
Record both, with the note that feature 441 being still-active makes (b) riskier — 441's
`policy-audit` and `feature-audit` artifacts cite this test by name
(`docs/features/active/2026-08-07-parallel-orchestrator-surface-441/policy-audit.2026-08-08T18-12.md:800`).
Whichever is chosen, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` is
a **certain write**.

### 9.4 Regression tests — does a natural home exist?

Searched `tests/` for any assertion on `.claude/rules/` frontmatter, on agent `skills:` lists, or
on cross-reference resolution.

| Proposed assertion (from the issue's Validation Ideas) | Existing test? | Natural home |
|---|---|---|
| Every `.claude/rules/*.md` frontmatter block parses as valid YAML | **NONE** | New. Two candidates: (i) a Python test at `tests/scripts/claude-runtime/` — **but that directory contains only Pester `.Tests.ps1` files**, and Python tests live under `tests/scripts/dev_tools/`; (ii) an `It` block appended to `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1`, which already asserts `.claude/` structural facts (skills exist, agents exist, agent files contain literals). Recommend (ii) for topical fit, or a new `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` if the plan prefers to avoid triggering the PoshQC gate. |
| Only the four deliberate `"**"` rules load unconditionally | **NONE** | Same file as above. Assert: the set of rules files whose `paths:` contains `"**"` equals exactly `{general-code-change, general-unit-test, quality-tiers, tonality}`. This is a strong, cheap, exact assertion. |
| `epic-orchestrator.md` frontmatter parses and every `skills:` entry resolves to an existing `.claude/skills/<name>/SKILL.md` | **NONE**. `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1:16-29` asserts five *named* skills exist, but never reads an agent's `skills:` list. | Same file. Generalise to: for every `.claude/agents/*.md`, every `skills:` entry resolves. That closes the gap for all 24 agents, not just this one. |
| No cross-reference in the two epic files points at a non-existent path | **NONE** | Same file, or a new Python test. Note the difficulty: templated paths (`docs/features/epics/<epic-slug>/epic.md`) must be excluded, which makes a general assertion fragile. A narrower, robust assertion is: **the literal string `spec.md §` does not appear in any file under `.claude/`**. That is exact, cheap, and directly encodes F4's acceptance criterion. Recommend this form. |
| Bounded return shape documented; kickoff line carries the constraint | **NONE** | Literal-fragment assertions, following the established pattern in `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py:54-65`. That file is the closest precedent in the repository for pinning required prose fragments in `.claude/` runtime files. |
| Measured before/after always-on line count | n/a — evidence artifact, not a test | `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. |

**Decision the plan must make:** Pester (`.Tests.ps1` under `tests/scripts/claude-runtime/`)
versus pytest (`.py` under `tests/scripts/dev_tools/`).
- Pester gives the best topical fit (`claude-runtime-structure.Tests.ps1` is exactly this kind
  of assertion) but pulls the PoshQC format/analyze/test gate into a change that otherwise has
  no PowerShell.
- pytest keeps the toolchain to Python-only (black, ruff, pyright, pytest — already required by
  the `parallel_orchestrator_surface_expectations.py` edit) and puts the test next to the
  existing `.claude`-content tests (`test_epic_run_kickoff_discovery_contract.py`,
  `test_push_down_claude_resource_contracts.py`, `test_parallel_orchestrator_surface_contracts.py`),
  which are all pytest. YAML parsing is available (`import yaml` is already used at
  `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py:35`).

On the evidence, **pytest under `tests/scripts/dev_tools/` is the lower-friction choice**: it
matches every existing `.claude`-content assertion in the repository and adds no new toolchain
gate. The plan should state which it picked and why.

### 9.5 Coverage

`.claude/rules/general-unit-test.md:23-24` requires >= 85% line and >= 75% branch. The change
adds no production code. `pyproject.toml:118-119` sets `[tool.coverage.run] source = ["src", "scripts/dev_tools"]`,
and no file under either root changes, so the coverage denominator is unchanged and the metric
cannot regress. Say so explicitly in the plan rather than running a coverage gate that measures
nothing (see `.claude/rules/plan-acceptance-gates.md` G1/G3 — a `--cov` argument that collects
no data is exactly the unfalsifiable-gate defect that rule exists to catch).

---

## 10. Behaviour semantics — success, failure, ordering, edge cases

### 10.1 Per-defect success conditions

| Defect | Success | Failure |
|---|---|---|
| F1 | `.claude/agents/epic-orchestrator.md` `## Startup Protocol` contains three contiguously numbered steps, none instructing a read of `CLAUDE.md` or `.claude/rules/`; `.claude/skills/epic-orchestrate/SKILL.md` has no `## Prerequisites` section; exactly one blank line separates the preceding paragraph from `## Epic Dependency Manifest`. | Any residual read instruction; non-contiguous numbering; double blank line. |
| F2 | `skills:` contains exactly `policy-compliance-order`, `epic-orchestrate`, `acceptance-criteria-tracking`; each resolves to an existing `SKILL.md`; no prose in either epic file references a removed skill. | A `skills:` entry that does not resolve; a dangling prose reference. |
| F3 | All 19 rules files carry a parseable `paths:` list and a non-empty `description:`; the `"**"` set is exactly the four deliberate files; each new glob set is justified by a quotation from the file's own scope/enforcement section. | Any file without frontmatter; a fifth `"**"`; a glob whose justification is not traceable to the rule's own text. |
| F4 | No occurrence of the literal `spec.md §` anywhere under `.claude/`; the three replacements each resolve to an existing path or an existing heading in an existing file. | Any residual `spec.md §` in `.claude/`; a replacement pointing at a non-existent target. |
| F5 (mechanical) | `CLAUDE.md` retains `## Policy Compliance Reading Order` verbatim; the tone-policy body is replaced by a pointer; no coverage threshold and no toolchain stage count is changed anywhere. | Any change to a coverage figure or stage count; loss of the compliance order. |
| F5 (decision) | A `human_interaction` requirement with `response: "halt"` is recorded in the checkpoint, stating both open questions with file:line evidence and no recommendation. | A value chosen by inference; a missing `human_interaction` record. |
| F6 | `epic-orchestrate/SKILL.md` documents the fixed return shape with all six required fields, states that excess content is discarded, and states the re-derivation rationale; line 126's kickoff line carries the child-facing clause; `orchestrate/SKILL.md` carries the matching child-side statement. | A shape missing any of the six fields; a kickoff line without the clause; no child-side statement. |

### 10.2 Ordering constraints

1. **F3's five edits are independent of one another** and independent of F1/F2/F4/F6. They can
   land in any order. The issue's "one shared verification task" is a documentation step, not a
   sequencing constraint.
2. **F1, F2, F4 all edit `.claude/agents/epic-orchestrator.md`.** They are line-disjoint
   (F2: 22-25; F1: 57-58 + renumber 59/61/65; F4: 107 and 136) but must be applied to the same
   file. Sequence them within one phase to avoid stale-line-number errors: **apply from the
   bottom of the file upward** (F4 line 136 → F4 line 107 → F1 lines 57-58 → F2 lines 22-25) so
   each edit's line numbers are unaffected by the preceding edits.
3. **F1, F4, F6 all edit `.claude/skills/epic-orchestrate/SKILL.md`.** Same rule: bottom-up
   (F4 line 268 → F6 new section after line 132 → F6 line 126 → F1 lines 22-29).
4. **The digest re-pin (9.3) must be the LAST step** touching either epic file. Recomputing a
   digest before the final edit lands produces a wrong constant.
5. **The bundled mirror copies must be written after their `.claude/` originals are final**, for
   the same reason.

### 10.3 Edge cases

- **Line-ending sensitivity.** Both the SHA-256 pin (`read_bytes()`) and the mirror parity test
  (`read_text(encoding="utf-8")`) are affected by CRLF/LF. The mirror test compares decoded text
  so it tolerates a `.gitattributes`-normalised difference; the digest test hashes raw bytes and
  does not. On Windows, an editor that rewrites line endings will change the digest without
  changing a visible character. Compute the digest from the same working-tree bytes that will be
  committed.
- **Frontmatter insertion shifts every line number** in the five rules files by the block length.
  Any acceptance criterion in the plan that cites a line number inside those five files must
  cite it as post-change or as a literal string, not a pre-change line number.
- **`benchmark-baselines.md` scoped to a non-existent directory** (4.3.2) is a correct-but-inert
  outcome. A test asserting "the glob matches at least one file" would fail for this rule and
  must not be written.
- **`orchestrator-state.md` glob breadth** (4.3.4): if the narrow form is chosen, the rule stops
  reaching the orchestration personas. Record the choice and its consequence.
- **Placeholder-bearing literals.** Several fragments quoted in this document contain `<` and `>`
  (for example `git fetch origin epic/<epic-slug>-integration`). Per
  `.claude/rules/plan-acceptance-gates.md` (checkable-literal placeholder guard), such a token
  is not a checkable search literal. A plan acceptance condition must not `grep -F` for a
  marker-bearing string and call it a gate; it will be reported as unfalsifiable. Use a
  placeholder-free substring instead.

---

## 11. Candidate approaches considered

### 11.1 Approach A (RECOMMENDED) — six line-disjoint edits plus the two forced mechanical consequences

Treat F1-F6 as six independent content edits to five source files, then apply the two
test-forced consequences (digest re-pin, bundled mirror) as mechanical closing steps. Add one
new structural test covering F2's and F3's acceptance criteria. Record F5's decision half as a
`human_interaction` halt and deliver everything else.

Advantages:
- Matches the issue's own planner notes ("F1, F2, F4 are independent single-file edits
  plannable as separate atomic tasks").
- Every write is traceable to a named defect or to a named failing test.
- The blast radius is bounded and enumerable (Section 12), which is what the concurrent
  scheduling requires.
- No production code changes, so the coverage denominator is untouched.

Limitations:
- The bundled mirror doubles the file count in the diff. Unavoidable given B2.
- `parallel_orchestrator_surface_expectations.py` is shared with an active concurrent feature
  (441), which is a genuine contention point that must be visible in the declared radius.

### 11.2 Rejected alternatives

- **Split `parallel-orchestration.md` into two rules files** (schema invariants vs blast-radius
  doctrine) so each gets a narrow `paths:` set. Rejected: scope widening beyond the issue, and
  it would rewrite a 390-line rule that four other subsystems cite by path.
- **Delete the `PINNED_FROZEN_SURFACE_HASHES` pin outright rather than re-baselining.**
  Rejected as a research recommendation because feature 441 is still active and its audit
  artifacts cite the test by name; the choice is escalated to the plan (9.3) rather than made here.
- **Widen F5 to reconcile `AGENTS.md`.** Rejected: it is the Codex surface, the issue scopes F5
  to `CLAUDE.md`, and the reconciliation is blocked on the same reserved human decision.
- **Regenerate the `.agents/`/`.codex/` mirrors in this change.** Rejected: the issue puts them
  explicitly out of scope, and no test forces them (8.2). Recorded as a follow-up.

---

## 12. COMPLETE CANDIDATE WRITE LIST

Deduplicated, grouped by directory. **CERTAIN** = the change cannot land without it.
**CONDITIONAL** = depends on a stated decision.

### 12.1 Repository root

| Path | Status | Reason |
|---|---|---|
| `CLAUDE.md` | **CERTAIN** | F5 mechanical half: replace the duplicated `## Tone Policy` body (lines 11-14) with a pointer. Note: this is a ~4-line change, and the coverage/toolchain statements the issue expected to find here **do not exist**. |
| `AGENTS.md` | **CONDITIONAL — recommend NOT writing** | Holds the actual 80%/four-step contradictions (lines 44-51, 117-118). Out of the issue's F5 scope AND blocked on the reserved human decision. Write only if a human resolves the decision AND explicitly widens scope. |

### 12.2 `.claude/agents/`

| Path | Status | Reason |
|---|---|---|
| `.claude/agents/epic-orchestrator.md` | **CERTAIN** | F2 (delete frontmatter lines 22, 23, 25), F1 (delete lines 57-58, renumber 59/61/65), F4 (lines 107, 136). |

### 12.3 `.claude/skills/`

| Path | Status | Reason |
|---|---|---|
| `.claude/skills/epic-orchestrate/SKILL.md` | **CERTAIN** | F1 (delete `## Prerequisites`, lines 22-29), F4 (line 268), F6 (new `## Bounded Child Return Contract` section after line 132; append child-facing clause to the kickoff line at 126). |
| `.claude/skills/orchestrate/SKILL.md` | **CERTAIN** | F6 child-side edit. Answer to the delegation prompt's decisive question is YES — evidence in 7.5. |

### 12.4 `.claude/rules/` — F3

| Path | Status | Reason |
|---|---|---|
| `.claude/rules/parallel-orchestration.md` | **CERTAIN** | Insert `paths:` + `description:` frontmatter (390 lines, 57% of F3's saving). |
| `.claude/rules/plan-acceptance-gates.md` | **CERTAIN** | Insert frontmatter. |
| `.claude/rules/orchestrator-state.md` | **CERTAIN** | Insert frontmatter. Glob breadth decision per 4.3.4. |
| `.claude/rules/ci-workflows.md` | **CERTAIN** | Insert frontmatter. |
| `.claude/rules/benchmark-baselines.md` | **CERTAIN** | Insert frontmatter. Note: globs match zero current files (4.3.2). |

The other fourteen rules files are **READ ONLY** — verified to already carry both keys.

### 12.5 `extensions/drm-copilot/resources/claude-customizations/.claude/` — forced by B2

Every path in 12.2, 12.3, and 12.4 has a mandatory byte-identical mirror. All **CERTAIN**:

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

`CLAUDE.md` is **NOT** mirrored under `claude-customizations/` — the parity test's
`SCOPED_ROOTS` is `(Path(".claude"),)` only, and no `claude-customizations/CLAUDE.md` exists
(verified by glob returning no files at that level).

### 12.6 `tests/`

| Path | Status | Reason |
|---|---|---|
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | **CERTAIN** | Lines 105-117 pin SHA-256 digests of both epic files. Either update both constants or remove the pin (decision per 9.3). **Contention risk: this file belongs to concurrently-active feature 441.** |
| `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | **CONDITIONAL** | Written only if option (b) of 9.3 is chosen (remove `test_frozen_epic_surface_matches_pinned_baseline_digest` at lines 470-485). Not written under option (a). |
| `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` | **CONDITIONAL — new file** | Written if the plan chooses pytest for the F2/F3/F4 structural regression tests (recommended, 9.4). Would assert: all 19 rules files carry parseable `paths:` + non-empty `description:`; the `"**"` set is exactly the four named files; every `.claude/agents/*.md` `skills:` entry resolves; the literal `spec.md §` is absent from `.claude/`. |
| `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` | **CONDITIONAL — mutually exclusive with the previous row** | Written if the plan chooses Pester instead. Triggers the PoshQC gate. |
| `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py` | **READ ONLY** | Pins fragments in `epic-orchestrator.md:85-97`. Not touched by F1/F2/F4/F6. Verify at execution that the section is unreflowed. |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | **READ ONLY** | Enumerates dynamically; satisfied by mirroring. No edit. |

### 12.7 Feature-folder artifacts (this feature's own outputs)

| Path | Status |
|---|---|
| `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/research/2026-08-25T23-10-epic-orchestrator-context-footprint-research.md` | **CERTAIN** — this file |
| `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/spec.md` | **CERTAIN** — the Proposed Fix / Scope / Test Strategy / Acceptance Criteria sections are template stubs |
| `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/plan.<ts>.md` | **CERTAIN** |
| `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/issue.md` | **CERTAIN** — AC checkboxes |
| `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/**` | **CERTAIN** — before/after line-count measurement (Section 1) per the issue's validation ideas |
| `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/qa-gates/**` | **CERTAIN** — toolchain gate evidence |
| `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/regression-testing/**` | **CERTAIN** — fail-before/pass-after for the new structural test |
| `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/issue-updates/**` | **CONDITIONAL** — if the GitHub issue is updated |
| `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/policy-audit.<ts>.md`, `code-review.<ts>.md`, `feature-audit.<ts>.md`, `remediation-inputs.<ts>.md` | **CONDITIONAL** — produced by feature-review |
| `artifacts/orchestration/orchestrator-state.json` | **CERTAIN** — checkpoint, including the `human_interaction` halt record for F5 |
| `artifacts/pr_body_<N>.md`, `artifacts/pr_body_<N>.receipt.json`, `artifacts/pr_context.summary.txt` | **CERTAIN** — PR authoring |

### 12.8 Explicitly NOT written (recorded to prevent scope creep)

| Path | Why not |
|---|---|
| `.agents/skills/{orchestrator-state,ci-workflows,benchmark-baselines,epic-orchestrate,orchestrate}/SKILL.md` | Out of scope per the issue. Follow-up push-down (8.2). No test forces it. |
| `.codex/agents/epic-orchestrator.toml`, `.codex/**` | Same. |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/**` | Only needed if `.agents`/`.codex` change, which they do not. |
| `.github/instructions/**` | Non-modifiable per `CLAUDE.md:32`. |
| `config/orchestration-routing.json` and its resources mirror | Trimming `required_skills` would widen scope; the receipts obligation is satisfiable without it (3.3). |
| The fourteen already-scoped `.claude/rules/*.md` | Already carry both keys. |
| `docs/engineering/claude-code-architecture.md` | Nothing it states becomes false. Conditional at most. |
| Any `docs/features/completed/**` artifact containing `spec.md §` | Immutable history (5.2). |
| `.claude/skills/{epic-plan,parallel-plan,parallel-orchestrate,parallel-add,parallel-close,parallel-remove}/SKILL.md` | Carry the same F1 `## Prerequisites` defect but are out of the issue's scope (2.3). |

### 12.9 Blast-radius summary for conflict-edge computation

Distinct directories written (excluding this feature's own folder and `artifacts/`):

| Directory | Certain files | Conditional files |
|---|---|---|
| repository root | 1 (`CLAUDE.md`) | 1 (`AGENTS.md`) |
| `.claude/agents/` | 1 | 0 |
| `.claude/skills/` | 2 | 0 |
| `.claude/rules/` | 5 | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/` | 8 | 0 |
| `tests/scripts/dev_tools/` | 1 | 2 |
| `tests/scripts/claude-runtime/` | 0 | 1 |
| **Total** | **18** | **4** |

**Highest contention risks against concurrent items:**
1. `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` — shared with the
   still-active feature 441 (parallel-orchestrator surface).
2. `CLAUDE.md` — a root standing-instructions file that many items may touch.
3. `.claude/rules/parallel-orchestration.md` — any item working on the parallel surface or on
   blast-radius derivation will contend.
4. `.claude/skills/orchestrate/SKILL.md` — the most widely-cited procedure file in the runtime.
5. `extensions/drm-copilot/resources/claude-customizations/.claude/**` — any item that edits any
   `.claude/` file lands here too, by B2.
