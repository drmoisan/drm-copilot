<!-- markdownlint-disable-file -->

# Task Research Notes: csharp orchestrator small-path lifecycle consistency (#101)

## Research Executed

### File Analysis

- `docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101/issue.md`
  - Confirms the reproduced contradiction: `csharp-orchestrator` selects `small` but skips promotion/folder lifecycle, leaves `${promotion-type}`, `${short-name}`, `${relativeFile}`, `${long-name}`, `${issue-num}`, and `${feature-folder}` unset, and still reports completion.
- `docs/features/active/2026-03-14-orchestrator-not-following-sequential-tasks-101/spec.md`
  - Repeats the required short-path behavior, highlights the contradictory definitions across the C# agent/prompt/shared skill, and seeds the desired validation ideas for populated lifecycle variables plus `minor-audit` artifact creation.
- `.github/agents/csharp-orchestrator.agent.md`
  - Root C# orchestrator contract is partially modernized (acceptance-criteria handoff text exists), but the small path still jumps directly to planning/execution/review instead of the shared `minor-audit` lifecycle. It also lacks `${plan-path}` in deterministic variable handling and checkpoint fields.
- `.github/prompts/orchestrate-csharp-work.prompt.md`
  - Root C# prompt still describes the small path as a direct delegation to `csharp-typed-engineer`, which is even more permissive than the agent and directly contradicts the shared small-path lifecycle contract.
- `.github/agents/orchestrator.agent.md`
  - Generic orchestrator is the authoritative working reference for the intended small path: promotion/folder creation in `minor-audit`, minimal-audit plan creation with `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`, preflight to `PREFLIGHT: ALL CLEAR`, Phase 0 only execution, small-scope implementation handoff, validation against `issue.md`, and reduced audit/remediation loop.
- `.github/prompts/orchestrate-work.prompt.md`
  - Generic prompt documents the enforced small-path lifecycle, including `minor-audit` promotion/folder creation, minimal plan creation, preflight, Phase 0 only execution, resume branching, validation, and reduced audit.
- `.github/agents/python-orchestrator.agent.md`
  - Python orchestrator matches the generic agent’s enforced small-path lifecycle and adds required small-path handoffs plus `${plan-path}` persistence and evidence-backed completion gates.
- `.github/agents/powershell-orchestrator.agent.md`
  - PowerShell orchestrator also matches the enforced small-path lifecycle and serves as a second language-specific reference for the exact sequence and checkpoint expectations.
- `.github/prompts/orchestrate-python-work.prompt.md`
  - Python prompt still uses the older direct-to-engineer small-path wording, proving prompt drift is already a repo pattern and should be treated as a real consistency risk rather than a one-off C# typo.
- `.github/prompts/orchestrate-powershell-work.prompt.md`
  - PowerShell prompt shows the same outdated small-path shortcut wording as Python and C#, reinforcing that prompt/agent parity must be validated explicitly.
- `.github/skills/feature-promotion-lifecycle/SKILL.md`
  - Canonical short-path contract: short path still performs promotion/folder initialization in `minor-audit`, verifies issue/spec/user-story integrity, resolves and persists `${plan-path}`, delegates minimal-audit planning, runs Phase 0 only, branches on bootstrap mode, validates against `issue.md`, and completes a reduced audit/remediation loop.
- `.github/skills/atomic-plan-contract/SKILL.md`
  - Canonical planning/execution contract for small path: exactly three minimal-audit phases, issue-only requirements source, unconditional final-QC command tasks, preflight loop to `PREFLIGHT: ALL CLEAR`, Phase 0 only execution before branching, plan-path continuity, and fail-closed `minor-audit` integrity rules.
- `.github/skills/acceptance-criteria-tracking/SKILL.md`
  - Canonical acceptance-source rule: in `minor-audit`, `issue.md` is the only authoritative AC source. This is already referenced by the root C# orchestrator handoff text but is absent from the bundled customization mirror.
- `.github/skills/csharp-orchestration-state-machine/SKILL.md`
  - C# checkpoint contract is stale relative to the enforced small path: it omits `${plan-path}`, `work-mode`, bootstrap/resume metadata, and Phase 0 evidence summary fields that PowerShell now persists.
- `.github/skills/csharp-change-budget-router/SKILL.md`
  - C# budget router correctly decides `1-3` production files = small path, but still describes small path only as an atomic plan + execution route and does not restate the mandatory promotion/folder lifecycle required once orchestration is selected.
- `.github/skills/powershell-orchestration-state-machine/SKILL.md`
  - PowerShell state-machine skill is the current reference for the short-path checkpoint schema, including `work-mode`, `${plan-path}`, bootstrap mode, Phase 0 execution summary, and reduced-audit artifact persistence.
- `.github/skills/powershell-change-budget-router/SKILL.md`
  - PowerShell budget router is the current reference for language-specific small-path wording that still preserves `minor-audit` promotion/folder creation, minimal-audit planning, and Phase 0 only execution before development.
- `extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md`
  - Bundled mirror is older than the root copy: it lacks the root agent’s newer acceptance-criteria-tracking language and still uses the obsolete small-path planning/execution shortcut.
- `extensions/drm-copilot/resources/customizations/.github/prompts/orchestrate-csharp-work.prompt.md`
  - Bundled mirror matches the outdated root prompt and still instructs direct small-path delegation to `csharp-typed-engineer`.
- `extensions/drm-copilot/resources/customizations/.github/skills/csharp-orchestration-state-machine/SKILL.md`
  - Bundled mirror matches the stale root C# state-machine skill and therefore also lacks `${plan-path}` / `work-mode` / Phase 0 resume metadata.
- `extensions/drm-copilot/resources/customizations/.github/skills/feature-promotion-lifecycle/SKILL.md`
  - Bundled mirror is older than the root skill: it lacks the root copy’s explicit `${plan-path}` variable, short-path folder-integrity checks, and stricter mode-aware expectations.
- `extensions/drm-copilot/resources/customizations/.github/skills/atomic-plan-contract/SKILL.md`
  - Bundled mirror is older than the root skill: it lacks the root copy’s stricter unconditional final-QC text, checklist/evidence coupling, fail-closed `minor-audit` gates, and full plan-path continuity language.
- `extensions/drm-copilot/resources/customizations/.github/skills`
  - Directory listing confirms the bundled mirror does **not** contain `acceptance-criteria-tracking/`, so any mirrored C# orchestrator update that references that shared skill requires adding the missing bundled copy.
- `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`
  - Existing deterministic tests cover the one-way publisher that copies root `.github` trees into the bundled extension mirror and verify rewrite behavior, overwrite semantics, and per-root coverage for agents/instructions/prompts/skills.
- `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py`
  - Existing helper-focused tests verify artifact emission, explicit source-root reading, and rewrite-catalog helper behavior; these provide the smallest existing seam for adding bundled customization parity/coverage assertions.
- `tests/scripts/dev_tools/test_feature_docs.py`
  - Existing docs tests already validate `minor-audit` issue marker interpretation plus timestamped `plan.<timestamp>.md` handling, which is relevant to short-path plan-path continuity and resume behavior.
- `artifacts/research/20260309-push-down-copilot-customizations-implementation-research.md`
  - Prior research proves the repo already treats root `.github` files and the extension bundled mirror as a deliberate one-way published customization pack, so contract drift between root and mirror is a known maintenance concern and not accidental duplication.

### Code Search Results

- `csharp-orchestrator|orchestrate-csharp-work|feature-promotion-lifecycle|atomic-plan-contract|acceptance-criteria-tracking|orchestrator-state`
  - Confirmed the contradiction is localized to the C# agent/prompt pair, while the generic/Python/PowerShell orchestrators already implement the enforced short-path lifecycle.
- `small path|minor-audit|DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED|Phase 0 only|plan-path|feature-promotion-lifecycle`
  - Found the required small-path lifecycle language in the generic orchestrator, Python orchestrator, PowerShell orchestrator, root shared skills, prompt-resolution utilities, and multiple `minor-audit` tests—but not in the C# agent/prompt pair.
- `resources/customizations/.github/**/*.md`
  - Confirmed the extension bundles mirrored `.github/agents`, `.github/prompts`, and `.github/skills` content, so root customization changes must be mirrored into the packaged customization tree.
- `orchestrate-csharp-work|csharp-orchestrator|orchestrator.agent.md|resources/customizations|customization|mirror|sync-agents|sync customizations`
  - Found no existing tests that directly validate orchestration markdown contracts or root-vs-mirror parity for the C# orchestrator prompt/agent/skills.
- `read_text\(|Path\("\.github|resources/customizations/.github`
  - Found multiple deterministic Python tests in `tests/scripts/dev_tools/` that read markdown/text content directly, showing a repo-standard seam for future customization-contract tests without temp files or external processes.
- `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED|PREFLIGHT: ALL CLEAR|phase0-instructions-read.md|plan-path|minor-audit`
  - Found existing unit coverage around prompt-mode resolution, `${plan-path}` substitution, and `minor-audit` document semantics, but nothing that asserts the orchestrator markdown contracts themselves contain the required sequence.

### External Research

- #fetch:https://github.com/drmoisan/drm-copilot/issues/101
  - Fetch failed with HTTP 404 (private issue page), so the local mirrored `issue.md` / `spec.md` files remain the authoritative accessible source for issue content during this research pass.

### Project Conventions

- Standards referenced: `.github/instructions/general-code-change.instructions.md`, `.github/skills/policy-compliance-order/SKILL.md`, `.github/skills/feature-promotion-lifecycle/SKILL.md`, `.github/skills/atomic-plan-contract/SKILL.md`, `.github/skills/acceptance-criteria-tracking/SKILL.md`, `.github/skills/csharp-change-budget-router/SKILL.md`, `.github/skills/csharp-orchestration-state-machine/SKILL.md`
- Instructions followed: research-only mode, no source edits outside `artifacts/research/`, evidence-backed findings only, single recommended implementation path, and brief rejected-alternatives summary.

## Key Discoveries

### Project Structure

The issue is not just one contradictory paragraph; it is a contract drift problem across four layers:

1. **Root C# orchestrator files**
   - `.github/agents/csharp-orchestrator.agent.md` still defines small path as direct planning → execution → review.
   - `.github/prompts/orchestrate-csharp-work.prompt.md` is even older and defines small path as direct delegation to `csharp-typed-engineer`.

2. **Root shared C# support skills**
   - `.github/skills/csharp-orchestration-state-machine/SKILL.md` still models the pre-minor-audit checkpoint schema.
   - `.github/skills/csharp-change-budget-router/SKILL.md` still summarizes small path as plan + execution only instead of “promotion/folder lifecycle + minimal plan + Phase 0 only + constrained implementation”.

3. **Bundled extension customization mirror**
   - The mirrored C# agent/prompt copies are also stale.
   - The mirrored `feature-promotion-lifecycle` and `atomic-plan-contract` skills are **older than the root copies**, so the packaged customization bundle would continue pushing outdated lifecycle guidance even after root fixes unless the mirror is updated too.
   - The bundled mirror currently has **no** `acceptance-criteria-tracking` skill directory at all.

4. **Reference implementations**
   - The generic orchestrator and the Python/PowerShell orchestrators already encode the desired end-state behavior and provide a concrete template for the C# fix.

The cleanest path is therefore not inventing a new C#-specific workflow; it is aligning C# to the already-adopted shared short-path orchestration contract and then synchronizing the bundled customization mirror.

### Implementation Patterns

- **Correct small-path reference already exists**
  - `orchestrator.agent.md`, `python-orchestrator.agent.md`, and `powershell-orchestrator.agent.md` all implement the same enforced short-path lifecycle:
    1. determine `feature`/`bug` + `${short-name}`
    2. ensure potential entry exists
    3. promote with `--work-mode minor-audit`
    4. create branch + active feature folder with `--work-mode minor-audit`
    5. verify `issue.md` marker and absence of `spec.md` / `user-story.md`
    6. resolve and persist `${plan-path}`
    7. build minimal-audit plan with `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`
    8. require `PREFLIGHT: ALL CLEAR`
    9. execute Phase 0 only
    10. branch to manual bootstrap or constrained small-path development
    11. validate against `issue.md`
    12. run reduced audit/remediation loop

- **C#-specific execution chain can already support the same lifecycle**
  - `csharp-atomic-planning.agent.md` and `csharp-atomic-executor.agent.md` already reference `atomic-plan-contract` and `acceptance-criteria-tracking`, so the gap is orchestration wiring, not missing C# planning/execution primitives.
  - `csharp-typed-engineer.agent.md` already has a strict direct-mode size guard and an orchestrator handoff mode, making it a suitable Step S6 implementation delegate once the orchestration lifecycle is established.

- **Mirror drift is a known repo risk with an existing test seam**
  - The push-down customization publisher and its tests were created specifically to publish `.github` customizations into `extensions/drm-copilot/resources/customizations/.github/`.
  - Existing tests validate copy/rewrite behavior for agents/prompts/skills but do not yet pin specific orchestrator-file parity or lifecycle strings.
  - Therefore the minimal deterministic regression seam is content-based tests over root and mirrored markdown files, not runtime orchestration execution.

- **Prompt drift is already a pattern**
  - Python and PowerShell prompts still describe the older direct-to-engineer small path even though their agents are correct.
  - That means C# should not just copy generic agent logic; the change should explicitly update the C# prompt text and add tests that catch prompt/agent/skill contract divergence.

### Complete Examples

```markdown
Source: `.github/agents/orchestrator.agent.md` (working reference for the enforced short path)

## Small path (budget 1-3 production files and 1-3 test files)

Follow this exact sequence.

### Step S1 — Scope potential feature/bug
...
### Step S2 — Promote with short-path flag
...
### Step S3 — Create minimal short-path plan
- Handoff MUST include directive `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`.
- Handoff MUST include `${plan-path}` and require in-place updates to that single file.
- Generated plan MUST include exactly 3 phases.
- Do not mark S3 complete until delegate returns `plan-path` and `PREFLIGHT: ALL CLEAR`.

### Step S4 — Execute baseline phase only
- Execute only Phase 0.
- Persist checkpoint with Phase 0 completion evidence.

### Step S5 — Branch by bootstrap mode
- `manual bootstrap` -> save checkpoint and stop.
- otherwise continue with constrained small-path development.

### Step S6 — Delegate constrained small-path development
### Step S7 — Validate delivery and post-QC documentation
### Step S8 — Run reduced audit and remediation loop
```

### API and Schema Documentation

- **C# orchestrator variables that must be persisted before completion**
  - `${promotion-type}`
  - `${short-name}`
  - `${relativeFile}`
  - `${long-name}`
  - `${issue-num}`
  - `${feature-folder}`
  - `${plan-path}` (missing today in the C# state contract)

- **Short-path planning/execution invariants**
  - planner handoff must include `DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED`
  - plan must use `${feature-folder}/issue.md` as the sole requirements source
  - plan must contain exactly three phases
  - planner must return both `plan-path` and `PREFLIGHT: ALL CLEAR`
  - orchestrator must execute Phase 0 only before development branching
  - `minor-audit` folder integrity must fail closed if `spec.md` or `user-story.md` exists unexpectedly

- **Checkpoint/resume invariants**
  - short-path completion cannot occur while lifecycle variables remain null
  - checkpoint should capture `work-mode`, `${plan-path}`, bootstrap branch state, and Phase 0 evidence summary before branching
  - existing branch/folder reuse must continue to be recorded rather than treated as a fatal duplicate-path error

- **Mirror-parity invariants**
  - root and bundled extension copies of any changed `.github` agent/prompt/skill must remain textually aligned unless a documented packaging-specific exception exists
  - if the mirrored agent references a shared skill, the mirrored skill must exist in the bundled customization tree

### Configuration Examples

```yaml
# Representative frontmatter/handoff delta the C# orchestrator needs to mirror
handoffs:
  - label: Build minimal-audit atomic plan (preflight all clear)
    agent: atomic_planner
  - label: Execute Phase 0 only
    agent: atomic_executor
  - label: Small-scope implementation path
    agent: csharp-typed-engineer
  - label: Validate small-path delivery and post-QC docs
    agent: atomic_executor
  - label: Post-implementation small-path audit
    agent: feature_code_review_agent
```

### Technical Requirements

- **Required file classes to keep aligned**
  - root C# agent + prompt
  - bundled mirrored C# agent + prompt
  - root C# state/router skills
  - bundled mirrored C# state/router skills
  - bundled mirrored shared skills required by the updated C# files (`feature-promotion-lifecycle`, `atomic-plan-contract`, `acceptance-criteria-tracking`)

- **Edge cases that the fix must preserve**
  - resume/checkpoint continuity when a run is interrupted after promotion but before planning
  - branch already exists → checkout/reuse and persist that fact instead of failing
  - feature folder already exists → detect/reuse canonical paths while preserving `minor-audit` integrity checks
  - `${plan-path}` continuity when a prior `plan*.md` already exists in the folder
  - manual bootstrap stop after Phase 0 with deterministic resume token
  - reduced-audit integrity must fail if Phase 0 evidence or checklist state is missing/contradictory
  - no completion if lifecycle variables remain null or if `issue.md` lacks `- Work Mode: minor-audit`

**Mandatory unachievable objective callout**:
- **No objective was proven unachievable.** The repo already contains a working generic/Python/PowerShell short-path contract and C# planning/execution delegates capable of supporting it; the gap is contract alignment and mirror parity, not missing infrastructure.

## Recommended Approach

Adopt the **generic/Python/PowerShell enforced short-path lifecycle verbatim for C# orchestration** rather than inventing a C#-specific shortcut.

That means the C# fix should:

1. Update the root C# orchestrator agent so its small path becomes the same S1–S8 sequence used by the generic/Python/PowerShell orchestrators.
2. Add the missing small-path handoffs to the C# agent frontmatter:
   - minimal-audit plan creation
   - Phase 0 only execution
   - constrained small-path implementation
   - delivery validation against `issue.md`
   - reduced small-path audit
3. Persist `${plan-path}` in the C# checkpoint model and carry `work-mode`/bootstrap/Phase-0 summary fields needed for deterministic resume.
4. Update the C# prompt so it describes the same enforced short-path lifecycle as the agent, instead of the obsolete direct `csharp-typed-engineer` shortcut.
5. Update the C# change-budget router skill so “small path” still explicitly means the orchestrated `minor-audit` lifecycle, not just plan+execute.
6. Update the C# state-machine skill so the documented checkpoint schema matches the enforced small-path lifecycle.
7. Sync the bundled extension customization copies for every changed root customization file.
8. Bring the bundled shared-skill mirror up to parity where it is stale (`feature-promotion-lifecycle`, `atomic-plan-contract`) and add the missing bundled `acceptance-criteria-tracking` skill if the mirrored C# agent references it.
9. Add deterministic text-based regression tests that assert the C# agent/prompt encode the required small-path signals and that bundled mirrors stay aligned with their root counterparts.

Why this is the best option:

- It reuses the repo’s already-approved short-path contract instead of creating a fourth orchestration variant.
- It keeps `minor-audit` semantics consistent across language orchestrators.
- It fixes both the root user-facing contract and the packaged downstream customization bundle.
- It adds the smallest reliable regression seam: content contract tests over markdown customizations, not brittle live-agent execution tests.

Rejected alternatives (brief, non-exhaustive):

- **Keep C# small path as direct planning/execution and only populate lifecycle variables synthetically**
  - Rejected because it preserves the contract violation and would still skip mandatory `minor-audit` artifact creation, Phase 0 gating, and reduced-audit flow.
- **Let the prompt stay outdated and only fix the agent**
  - Rejected because prompt drift already exists in Python/PowerShell and is exactly the sort of silent inconsistency that caused the bug to persist.
- **Patch only the root files and ignore the bundled mirror**
  - Rejected because the extension’s published customization pack would continue distributing stale orchestration contracts to downstream workspaces.
- **Copy the generic orchestrator text wholesale without updating C# support skills/state schema**
  - Rejected because resume/checkpoint behavior would still be under-specified for `${plan-path}`, `work-mode`, and Phase 0 resume metadata.

## Implementation Guidance

- **Objectives**: Make C# small-path orchestration honor the same `minor-audit` promotion/folder/planning/Phase-0/validation/reduced-audit lifecycle as the generic, Python, and PowerShell orchestrators; eliminate root-vs-prompt and root-vs-bundled-mirror drift.
- **Key Tasks**:
  - Update `.github/agents/csharp-orchestrator.agent.md` small-path sequence and handoffs.
  - Update `.github/prompts/orchestrate-csharp-work.prompt.md` to describe the enforced small path.
  - Update `.github/skills/csharp-orchestration-state-machine/SKILL.md` for `${plan-path}`, `work-mode`, Phase 0 summary, and bootstrap resume fields.
  - Update `.github/skills/csharp-change-budget-router/SKILL.md` to restate the lifecycle-preserving small path.
  - Mirror those changes into `extensions/drm-copilot/resources/customizations/.github/...`.
  - Refresh stale bundled shared-skill copies and add bundled `acceptance-criteria-tracking` if referenced.
  - Add deterministic content-contract tests under `tests/scripts/dev_tools/` to assert required strings/sections and root↔mirror parity.
- **Dependencies**:
  - Existing generic/Python/PowerShell orchestrator files as the reference implementation.
  - Existing `csharp-atomic-planning`, `csharp-atomic-executor`, and `csharp-typed-engineer` agents for downstream execution.
  - Existing push-down customization publisher test infrastructure for mirror/parity regression coverage.
- **Success Criteria**:
  - C# root agent and prompt both encode the enforced small-path lifecycle.
  - C# checkpoint/state skill includes `${plan-path}` and required short-path resume metadata.
  - Root and bundled mirrored C# customizations are aligned.
  - Bundled shared-skill dependencies referenced by the mirrored C# files exist and match root contracts.
  - Deterministic tests fail on missing `minor-audit`/Phase 0/`${plan-path}` signals or root↔mirror drift.
