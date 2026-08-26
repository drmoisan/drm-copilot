# F3 — `paths:` Glob Justification for the Five Newly Scoped Rules Files

- Timestamp: 2026-08-26T01-05
- Task: `[P2-T7]`
- Plan: `docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/plan.2026-08-25T22-07.md`
- Command: not a command step; this artifact records source quotations and two limitations.
- EXIT_CODE: 0
- Output Summary: All five newly scoped rules files are covered. 45 declared globs are recorded
  (1 + 2 + 7 + 19 + 16). 30 are justified by a quotation from the rule file's own scope, enforcement,
  or governing text. 15 are recorded as declared-without-a-self-quotation, each with the reason for
  its inclusion stated rather than quoted. Both required limitations are recorded: the
  `benchmark-baselines.md` glob set matches zero current files, and no repository code reads `paths:`
  frontmatter from `.claude/rules/`.

---

## Scope of this artifact

Phase 2 inserted a YAML frontmatter block carrying a `paths:` list and a `description:` scalar at the
top of five rules files that previously carried none. This artifact records, per file, why each
declared glob is in that list, quoting the rule file's own scope or enforcement section wherever such
a quotation exists, and saying so explicitly wherever one does not.

A glob is recorded as **self-quoted** when the rule file's own text names the path or the surface the
glob reaches. A glob is recorded as **declared without a self-quotation** when the rule file does not
name it; in that case the reason for its inclusion is stated instead. No inference is presented as a
quotation.

---

## 1. `.claude/rules/ci-workflows.md`

Declared `paths:` (1 entry):

| Glob | Basis |
| --- | --- |
| `.github/workflows/**` | Self-quoted |

Quotation from the file's own `## Scope` section:

> - This rule applies to any workflow step whose `run:` block uses `shell: pwsh` (or the repo default `pwsh`) and intentionally invokes a failing nested command.

Supporting quotation from the same file's rationale:

> No local toolchain stage executes a workflow's `run:` block, so this defect is invisible to local feature-review. This textual rule is the artifact local review cites when reading workflow YAML.

A workflow `run:` block exists only inside a GitHub Actions workflow document, and this repository
stores those under `.github/workflows/`. The single glob is therefore exactly the set the quoted
scope statement describes.

---

## 2. `.claude/rules/benchmark-baselines.md`

Declared `paths:` (2 entries):

| Glob | Basis |
| --- | --- |
| `scripts/benchmarks/**` | Self-quoted |
| `**/baseline*.json` | Self-quoted |

Quotation from the file's own `## Enforcement` section, justifying `scripts/benchmarks/**`:

> - The validator `scripts/benchmarks/Test-BaselineProvenance.ps1` enforces both rejection conditions above and accepts a runner-captured baseline whose `ProcessorName` is a real processor and whose sibling `baseline.provenance.json` is present.

> - The feature-review policy rule `modified-workflow-needs-green-run` (see `.claude/skills/feature-review-workflow/SKILL.md`) provides a second line of defense: a diff under `scripts/benchmarks/**` is Blocking unless a green workflow run against the branch head is present in remediation inputs.

The second bullet states the glob `scripts/benchmarks/**` verbatim.

Quotation from the file's own `## Required: Sibling Provenance File` section, justifying
`**/baseline*.json`:

> Every committed baseline file MUST have a sibling `baseline.provenance.json` in the same directory.

Quotation from the file's own `## Scope` section, bounding both globs:

> - This rule applies to any baseline consumed by a benchmark regression gate.

### LIMITATION 1 (required by `[P2-T7]`) — this glob set matches ZERO current files

`scripts/benchmarks/` **does not exist in this repository.** Verified at execution time:

```
poetry run python -c "import pathlib;print(pathlib.Path('scripts/benchmarks').exists())"
-> False
```

No file matching `**/baseline*.json` was relied upon either; the glob set as a whole selects no
current file.

**This is the correct outcome under the rule's own scope statement.** The scope sentence quoted above
conditions the rule on the existence of a benchmark regression gate and the baselines it consumes,
not on the presence of any particular file today. The rule is a standing constraint on a surface this
repository does not currently carry. Scoping it to the paths that surface *would* occupy is what
makes the rule silent now and correctly active if `scripts/benchmarks/` is ever added — which is the
behavior the F3 change exists to produce. An empty match set is therefore evidence the scoping is
right, not evidence it is wrong. The plan states this directly at `[P2-T2]`: "No task asserts that
this glob set matches any file."

---

## 3. `.claude/rules/plan-acceptance-gates.md`

Declared `paths:` (7 entries):

| Glob | Basis |
| --- | --- |
| `scripts/dev_tools/plan_gate_*` | Self-quoted |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | Self-quoted |
| `extensions/drm-copilot/src/lib/validate/plan-gate-*` | Self-quoted |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | Self-quoted |
| `docs/features/**/plan.*.md` | Self-quoted (by subject, not by path literal) |
| `docs/features/**/remediation-plan.*.md` | Self-quoted (by subject, not by path literal) |
| `.claude/skills/atomic-plan-contract/SKILL.md` | Self-quoted |

Quotation from the file's own preamble, justifying the two `plan_gate_*` / `plan-gate-*` globs:

> The rules are enforced by `scripts/dev_tools/plan_gate_discrimination.py` and by the TypeScript parity port at `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` with its shared-predicate module `plan-gate-rules.ts`, both fed by the command extractor (`scripts/dev_tools/plan_gate_commands.py` and `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts`).

Four module names appear there — `plan_gate_discrimination.py`, `plan_gate_commands.py`,
`plan-gate-discrimination.ts`, `plan-gate-rules.ts` — plus `plan-gate-commands.ts` in the same
sentence. The two wildcard globs cover exactly that named family in each runtime.

Quotations from the file's own `## Enforcement` section, justifying the two dispatcher entries:

> - `scripts/dev_tools/validate_orchestration_artifacts.py` routes the existing `plan` artifact type through the two-channel entry point, prints each Warning to stderr prefixed with `PLAN GATE WARNING: `, and derives its exit code from the error channel alone.

> - The TypeScript parity port is dispatched from `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` for the existing `plan` artifact type.

Quotation from the same section, justifying `.claude/skills/atomic-plan-contract/SKILL.md`:

> `.claude/skills/atomic-plan-contract/SKILL.md` carries the authoring-side statement of this guidance and cross-references this file.

Justification for the two plan-document globs, quoting the file's own governing sentence:

> This rule governs the acceptance-gate rules the plan validator applies to the shell commands an atomic plan states as acceptance conditions.

and from `## Scope of Invocation`:

> The plan validator only ever runs against the single artifact it is pointed at.

The artifact the validator is pointed at is a plan document. The file additionally carries a section
headed `## Authoring Guidance for Plan Authors`, whose audience is the author editing such a
document. The rule file does not quote the two path literals, but it names the document class
unambiguously; the globs are the repository's storage location for that class. Both plan and
remediation-plan documents are covered because a remediation plan states acceptance conditions in the
same form.

---

## 4. `.claude/rules/orchestrator-state.md`

Declared `paths:` (19 entries).

### 4a. Self-quoted entries (8)

| Glob | Basis |
| --- | --- |
| `artifacts/orchestration/*orchestrator-state.json` | Self-quoted |
| `scripts/dev_tools/*orchestrator_state*` | Self-quoted |
| `scripts/dev_tools/compute_complexity_floor.py` | Self-quoted |
| `scripts/dev_tools/resolve_delegation_model.py` | Self-quoted |
| `.claude/hooks/validate-orchestrator-output.ps1` | Self-quoted |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | Self-quoted |
| `config/orchestration-routing.json` | Self-quoted |
| `.claude/skills/orchestrate/SKILL.md` | Self-quoted |

Quotation from the file's own opening scope sentence:

> This rule governs remediation-cycle records and the optional `human_interaction` block in the orchestrator-state checkpoint at `artifacts/orchestration/orchestrator-state.json`.

Quotations from the file's own `## Enforcement` section:

> - `scripts/dev_tools/validate_orchestrator_state.py` appends one error per violated invariant when a `remediation_loop` is present, using the existing validator message style (literal, checkpoint-context prefixed).

> - `scripts/dev_tools/validate_orchestrator_state.py` appends one error per violated `complexity_assessments` invariant when a `complexity_assessments` key is present, delegating to `scripts/dev_tools/_orchestrator_state_complexity.py`, which recomputes the floor via `compute_complexity_floor`.

> - `scripts/dev_tools/validate_orchestrator_state.py` appends one error per violated `model_routing_receipts` invariant when a `model_routing_receipts` key is present, delegating to `scripts/dev_tools/_orchestrator_state_model_routing.py`, which recomputes the resolved model via `resolve_delegation_model`.

The glob `scripts/dev_tools/*orchestrator_state*` covers `validate_orchestrator_state.py` and the
four delegated `_orchestrator_state_*` helper modules named across that section.

Quotation naming the two reference implementations as file paths:

> 3. **Floor equals the computed floor.** Each entry's `floor` must equal `compute_complexity_floor(signals_present)` (the reference implementation in `scripts/dev_tools/compute_complexity_floor.py`).

> 1. **Model equals the resolved model.** Each entry's `model` must equal `resolve_delegation_model(agent, complexity_band, fable_policy)["model"]` (the reference implementation in `scripts/dev_tools/resolve_delegation_model.py`).

Quotation naming both hooks:

> The completion hook (`.claude/hooks/validate-orchestrator-output.ps1`) passes `--require-model-routing` alongside `--require-complete` and surfaces a gate failure as the `MODEL_ROUTING_BLOCKED:` block reason. The PreToolUse deterrent (`.claude/hooks/enforce-model-routing-receipt.ps1`) performs presence-only gating before a delegation.

Quotation naming the routing configuration:

> The session `model_budget.fable_policy` switch is a three-way enum `disabled | available | preferred` defined in `config/orchestration-routing.json`, defaulting to `disabled`.

Quotation naming `.claude/skills/orchestrate/SKILL.md`, twice:

> The invariants are additive and support the autonomous-execution mandate documented in `.claude/skills/orchestrate/SKILL.md`.

> The invariants are additive and support the two-axis model-selection mechanism documented in `.claude/skills/orchestrate/SKILL.md` (`## Model Selection`).

Quotation covering the TypeScript parity surface:

> The MCP TypeScript surface performs the existence check only (delegated-agent set ⊆ routing-receipt-agent set); the Python validator remains authoritative for per-receipt correctness.

### 4b. Entries declared WITHOUT a self-quotation (11)

| Glob | Named in the rule's own text? |
| --- | --- |
| `artifacts/orchestration/*planner-state.json` | No — only the orchestrator checkpoint is named |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-*` | No — the parity surface is described, the module paths are not quoted |
| `.claude/agents/orchestrator.md` | No |
| `.claude/agents/epic-orchestrator.md` | No |
| `.claude/agents/parallel-orchestrator.md` | No |
| `.claude/agents/epic-planner.md` | No |
| `.claude/agents/parallel-planner.md` | No |
| `.claude/skills/epic-orchestrate/SKILL.md` | No |
| `.claude/skills/parallel-orchestrate/SKILL.md` | No |
| `.claude/skills/epic-plan/SKILL.md` | No |
| `.claude/skills/parallel-plan/SKILL.md` | No |

Verified by search: of the ten checkpoint-writer surfaces, only `.claude/skills/orchestrate/SKILL.md`
appears in the body of `.claude/rules/orchestrator-state.md`. The other nine are not named anywhere
in that file, and the string `planner-state` does not appear in the body either.

`extensions/drm-copilot/src/lib/validate/orchestrator-state-*` reaches the TypeScript parity surface
that the sentence quoted above describes ("The MCP TypeScript surface performs the existence check
only"). The rule states the parity relationship but quotes no module path for it, so the glob is
recorded here as declared rather than self-quoted.

`artifacts/orchestration/*planner-state.json` is the planner half of the same checkpoint class. The
rule governs the orchestrator checkpoint explicitly and does not name the planner checkpoint; the
glob is included because the planner checkpoint is the sibling artifact written into the same
directory by the planner surfaces listed above, and a writer editing one is authoring against the
same checkpoint contract. That is an inference from the rule's subject matter, not a quotation.

Reason for the nine writer surfaces' inclusion, stated rather than quoted: each writes or resumes an
orchestration checkpoint governed by this rule, so a change authored in any of them without the rule
loaded is authored against an unstated contract. The set is pinned by the constant
`CHECKPOINT_WRITER_SURFACES` in `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` and
asserted by `test_orchestrator_state_rule_paths_reach_every_checkpoint_writer`. That test is the
authority for the set; this rule file is not. The nine are recorded here as declared-by-test rather
than self-quoted so a later reader does not look for a quotation that does not exist.

---

## 5. `.claude/rules/parallel-orchestration.md`

Declared `paths:` (16 entries).

### 5a. Self-quoted entries (12)

| Glob | Basis |
| --- | --- |
| `artifacts/orchestration/parallel-*` | Self-quoted |
| `docs/features/parallel/**` | Self-quoted |
| `scripts/dev_tools/*parallel*` | Self-quoted |
| `extensions/drm-copilot/src/lib/validate/parallel-*` | Self-quoted |
| `scripts/dev_tools/*blast_radius*` | Self-quoted |
| `config/blast-radius.json` | Self-quoted |
| `**/config/blast-radius.json` | Self-quoted |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | Self-quoted |
| `.claude/lib/bash/parallel-yaml-scan.sh` | Self-quoted |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | Self-quoted |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | Self-quoted |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | Self-quoted |

Quotation from the file's own opening scope sentence, justifying the first two globs:

> This rule governs the three artifacts of the `parallel` orchestration surface: the parallel-run manifest at `docs/features/parallel/<slug>/parallel.md`, the parallel-orchestrator checkpoint at `artifacts/orchestration/parallel-orchestrator-state.json`, and the parallel-planner checkpoint at `artifacts/orchestration/parallel-planner-state.json`.

Quotations from the file's own `## Enforcement` section:

> - `scripts/dev_tools/validate_parallel_orchestrator_state.py`, with the helper modules `scripts/dev_tools/_parallel_state_common.py`, `scripts/dev_tools/_parallel_state_structures.py`, and `scripts/dev_tools/_parallel_state_records.py`, appends one error per violated orchestrator invariant.

> - `scripts/dev_tools/parallel_manifest_contract.py` appends one error per violated manifest invariant and exposes the default-resolving accessors.

> - `scripts/dev_tools/validate_orchestration_artifacts.py` registers the CLI subparsers `parallel-orchestrator-state` (with `--require-complete`) and `parallel-planner-state` (with `--require-ready-for-execution`).

> - The TypeScript parity port at `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts`, `parallel-state-structures.ts`, `parallel-state-records.ts`, `parallel-orchestrator-state-core.ts`, and `parallel-planner-state-core.ts` reproduces the same invariants and is dispatched from `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` for both new `artifact_type` values.

> - The `PreToolUse` merge gate `.claude/hooks/enforce-epic-merge-gate.ps1` carries a parallel allow-branch that authorizes a per-item `gh pr merge --merge` from the parallel-orchestrator checkpoint when `route_id == "parallel"`.

Quotations from the file's own `## Blast-Radius Contention Doctrine (issue #489)` section:

> `config/blast-radius.json` carries an optional `mandate_reads` list enumerating those paths as exact entries and `**` subtree globs. That list is the mandate-read exclusion set. `derive_blast_radius` removes matching citations from the harvest before resolving modules and shared surfaces, and `validate_blast_radius` removes them from its plan-side extraction so V1 and V2 stay self-consistent against a radius derived from the same plan.

That sentence names both `derive_blast_radius` and `validate_blast_radius`, which the glob
`scripts/dev_tools/*blast_radius*` reaches, and names `config/blast-radius.json`.

> The push-down publishes a second truth table into a destination workspace at `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`.

That is the second committed copy, which `**/config/blast-radius.json` reaches. Both copies are
asserted reachable by `test_parallel_orchestration_rule_paths_cover_blast_radius_config`.

> `assembleModules` in `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` computes a destination's module map from the destination's OWN layout.

> The destination-runtime bash YAML subset parser (`.claude/lib/bash/parallel-yaml-scan.sh`) rejects a non-empty flow collection.

### 5b. Entries declared WITHOUT a self-quotation (4)

| Glob | Named in the rule's own text? |
| --- | --- |
| `.claude/lib/blast-radius/**` | No — only its Pester mirror is named |
| `.claude/agents/parallel-orchestrator.md` | No |
| `.claude/agents/parallel-planner.md` | No |
| `.claude/skills/parallel-*/SKILL.md` | No |

For `.claude/lib/blast-radius/**` the nearest text in the rule is a citation of that library's test
mirror, not of the library itself:

> `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle` in `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, mirrored in `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`, closes that gap structurally.

The directory `.claude/lib/blast-radius/` exists in this repository and holds the runtime library
that the quoted Pester mirror exercises. The glob is included because editing that library changes
blast-radius derivation, which is the subject of the doctrine section quoted above. This is an
inference from the rule's subject matter, not a quotation of it.

For the three agent and skill globs, the reason for inclusion is that they are the parallel surface's
own authoring surfaces: the two agents and the `parallel-*` skills are what write the three artifacts
this rule governs. The rule does not name them.

---

## LIMITATION 2 (required by `[P2-T7]`) — glob correctness is unverifiable in-repository

**No repository code reads `paths:` frontmatter from `.claude/rules/`.** The only consumer of that
key is the Claude Code runtime itself, which is external to this repository and whose glob engine is
not exposed here.

Searches performed at execution time:

- `git grep -n "'paths'" -- scripts` and `git grep -n '"paths"' -- extensions/drm-copilot/src scripts`
  return matches only in code that reads a `paths` key from a **JSON pack manifest**
  (`scripts/dev_tools/push_down_claude_pack_selection.py`,
  `scripts/dev_tools/push_down_codex_pack_selection.py`,
  `scripts/dev_tools/generate_codex_agent_variants.py`,
  `extensions/drm-copilot/src/lib/push-down/claude-pack-selection.ts`,
  `extensions/drm-copilot/src/lib/push-down/codex-pack-selection.ts`) or from a **blast-radius
  record** (`scripts/dev_tools/compute_blast_radius.py`,
  `scripts/dev_tools/parallel_drift_detection.py`,
  `scripts/dev_tools/_parallel_drift_cli_io.py`). None of them reads a `.claude/rules/*.md`
  frontmatter block.
- `git grep -l -F 'rules/' -- .claude/hooks scripts extensions/drm-copilot/src` returns files that
  cite rule file names in prose or map them to `.codex/rules/` during conversion. None parses a
  rules-file frontmatter mapping.

**Consequence.** Nothing in this repository can determine whether a declared glob loads the rule at
the moment the runtime would need it. Therefore only **structural** assertions are made, and they are
the only assertions the new test module makes:

1. Every rule file carries a parseable frontmatter block with a non-empty `paths:` list and a
   non-empty `description:` scalar
   (`test_every_claude_rule_carries_parseable_paths_and_description`).
2. Exactly four rule files load unconditionally
   (`test_unconditional_rule_set_is_exactly_the_four_deliberate_files`).
3. A declared glob set textually reaches a named target string, matched with `fnmatch.fnmatchcase`
   against a literal repo-relative path
   (`test_orchestrator_state_rule_paths_reach_every_checkpoint_writer`,
   `test_plan_acceptance_gates_rule_paths_cover_both_dispatchers`,
   `test_parallel_orchestration_rule_paths_cover_blast_radius_config`).

Assertion 3 compares a glob against a **string**, not against the filesystem, and `fnmatch`'s `*`
crosses path separators, which is more permissive at a segment boundary than a runtime `**` segment.
The test module records this trade in the docstring of its `globs_cover` helper. No assertion in this
repository proves that a rule actually loads for a given edited file, and none is claimed here.

---

## Summary of recorded limitations

| # | Limitation | Where recorded |
| --- | --- | --- |
| 1 | The `benchmark-baselines.md` glob set matches zero current files because `scripts/benchmarks/` does not exist here. This is the correct outcome under that rule's own scope statement. | Section 2 |
| 2 | No repository code reads `paths:` frontmatter from `.claude/rules/`, so glob correctness is unverifiable in-repository and only structural assertions are made. | Limitation 2 |
