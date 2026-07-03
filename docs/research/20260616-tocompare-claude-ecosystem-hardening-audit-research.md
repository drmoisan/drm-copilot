# Claude Ecosystem Hardening Audit — SOURCE vs REPO Comparison

**Date:** 2026-06-16  
**Artifact:** `artifacts/research/20260616-tocompare-claude-ecosystem-hardening-audit-research.md`

---

## 1. Method and Trees Compared

### Trees in scope

| Label | Path |
|---|---|
| SOURCE (copied-in) | `artifacts/tocompare/.claude` |
| CANONICAL RUNTIME | `.claude` |
| BUNDLED MIRROR (contract-tested) | `extensions/drm-copilot/resources/claude-customizations/` |
| SECOND MIRROR (no standalone contract test found) | `packages/mcp-server/resources/claude-customizations/` |

### Method

Each file present in both SOURCE and REPO was read in full and compared section-by-section. Files present in only one tree were examined to determine whether they represent net-new functionality, alternative implementations, or project-specific content. Contract tests under `tests/scripts/dev_tools/` were read to determine which mirror paths are formally enforced.

---

## 2. Authoritative Bundled-Mirror Set (Contract-Test Evidence)

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` defines:

```python
BUNDLED_ROOT = (
    REPO_ROOT / "extensions" / "drm-copilot" / "resources" / "claude-customizations"
)
```

Three tests enforce byte-identical parity between `.claude/` and this bundle for all non-`agent-memory`, non-`settings.local.json` files:
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` — fails if any repo file is absent or content-divergent from the bundle.

The `packages/mcp-server/resources/claude-customizations/` path contains a `.claude` tree (verified by glob), but **no standalone Python contract test enforces its byte parity with the canonical runtime**. That mirror appears to be maintained manually or by the push-down script; it is not covered by the `test_push_down_claude_resource_contracts.py` suite.

**Authoritative contract-enforced mirror:** `extensions/drm-copilot/resources/claude-customizations/`

The `packages/mcp-server/resources/claude-customizations/` mirror must be kept in sync but has no automated parity gate. Any propagation must update both mirrors.

---

## 3. Propagation-Recommendation Table

| File / Element | Source state | Repo state | Classification | Recommendation | Rationale |
|---|---|---|---|---|---|
| `schemas/orchestrator-state.schema.json` | Present (repo-local `$id`, no foreign origin) | Absent | See Section 5 | PORT-INVARIANT-ONLY | Schema is not the foreign schema; but `human_interaction` invariant is missing from repo's prose rule and validator |
| `skills/human-exception-runbook/SKILL.md` | Present (new skill) | Absent | HARDENING | PROPAGATE | Net-new guardrail; defines runbook contract for exception handling; referenced by `orchestrate` skill and `validate-orchestrator-output.ps1` |
| `skills/human-exception-runbook/example.runbook.md` | Present | Absent | HARDENING | PROPAGATE | Required companion to SKILL.md; provides the example artifact the skill mandates |
| `rules/orchestrator-state.md` | Absent | Present | REPO-AHEAD | DO NOT PROPAGATE | Repo-specific prose rule + foreign-schema warning; not a regression target |
| `hooks/validate-orchestrator-output.ps1` — `Test-HumanInteractionShape` function | Present (adds ~80 lines) | Absent | HARDENING | PROPAGATE | Blocks DONE when `human_interaction` requirements are unresolved/halted/exception-without-runbook; corresponds to mandate in `orchestrate` skill |
| `hooks/validate-task-researcher-output.ps1` — `Test-AutomationFeasibilitySection` function | Present (adds ~60 lines) | Absent | HARDENING | PROPAGATE | Blocks research artifact acceptance when an autonomous-execution topic is detected but `## Automation Feasibility` section is absent |
| `skills/orchestrate/SKILL.md` — `## Autonomous-Execution Mandate` section | Present (lines 27–55 of SOURCE) | Absent | HARDENING | PROPAGATE | Defines detection points, three permitted responses (`scope_change`, `exception`, `halt`), exception-runbook requirement, and all three enforcement points; companion to the hook additions |
| `rules/general-unit-test.md` — `## Coverage Exclusion Policy` section | Present (strict prohibition on excluding production paths) | Absent | HARDENING | PROPAGATE | Blocks coverage `exclude` entries that match production source paths; marks such entries as Blocking in feature review; closes a loophole not addressed by repo version |
| `rules/general-unit-test.md` — `## Test File Location` section | Present (requires `tests/` mirror structure, prohibits colocation in `src/`) | Absent | HARDENING | PROPAGATE | Adds deterministic structural rule for test placement; prevents test files from appearing alongside production source |
| `skills/remediation-handoff-atomic-planner/SKILL.md` | More detailed (full chain diagram, per-artifact timestamp rules, preflight sub-loop, plan shape, exit gate) | Shorter version (basic trigger/input/handoff) | HARDENING | PROPAGATE | Source version is substantially more complete: adds `Full Handoff Chain` diagram, `Required Artifacts` with entry-vs-exit timestamp contract, `Plan Shape` contract, `Preflight Sub-Loop` formalization, and `Exit Gate` definition |
| `settings.json` | Identical | Identical | NOISE | DO NOT PROPAGATE | Byte-for-byte match |
| `settings.local.json` | SOURCE has 626-byte version with project-specific dotnet/gh allow-list from a different repo | REPO has 73-byte version | DIVERGENT/repo-specific | DO NOT PROPAGATE | SOURCE local settings reference `drm-copilot`/TMW worktree paths and dotnet commands from another repo's workflow; local settings are developer-local, not shared |
| All hook scripts (except `validate-orchestrator-output.ps1` and `validate-task-researcher-output.ps1`) | Identical | Identical | NOISE | DO NOT PROPAGATE | Verified identical content |
| All agent files | Identical | Identical | NOISE | DO NOT PROPAGATE | Verified identical content |
| All rules except `general-unit-test.md` and `orchestrator-state.md` | Identical | Identical | NOISE | DO NOT PROPAGATE | Verified identical content |
| `skills/feature-review-workflow/SKILL.md` | Identical | Identical | NOISE | DO NOT PROPAGATE | Verified identical content |
| `skills/review-feature/SKILL.md` | Identical | Identical | NOISE | DO NOT PROPAGATE | Verified identical content |
| `agent-memory/**` | PROJECT-SPECIFIC | N/A | DIVERGENT | DO NOT PROPAGATE | Other repo's memory (TMW project context, orchestrator feedback, etc.) is not relevant here |

---

## 4. Detailed Findings for Genuinely-Hardened Elements

### 4.1 Autonomous-Execution Mandate — `orchestrate` skill

**SOURCE delta:** Lines 27–55 of `artifacts/tocompare/.claude/skills/orchestrate/SKILL.md` add a complete `## Autonomous-Execution Mandate` section that is entirely absent from the repo's version of the same file.

The section defines:
- **Detection points:** Unautomatable requirements must be enumerated before kickoff or surfaced no later than the research stage. Third-party UI research must include an `## Automation Feasibility` section.
- **Three permitted responses:** `scope_change` (remove manual dependency), `exception` (emit a runbook), `halt` (block DONE).
- **Exception-runbook requirement:** On `exception`, the orchestrator emits `<FEATURE>/runbooks/<name>.runbook.md` and records `runbook_path` in checkpoint state.
- **Enforcement points:** Three enforcements are named — schema (`orchestrator-state.schema.json`), completion gate (`Test-HumanInteractionShape`), and research gate (`Test-AutomationFeasibilitySection`).

**Why this is hardening:** Without the mandate, the orchestrator has no obligation to detect unautomatable steps early. A silent manual blocker found at the end of a workflow is indistinguishable from a defect in the workflow.

**Files requiring change:**
- `.claude/skills/orchestrate/SKILL.md` — add `## Autonomous-Execution Mandate` section (lines 27–55 of SOURCE; insert before `## Delegation Model`)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` — same change
- `packages/mcp-server/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` — same change

---

### 4.2 `Test-HumanInteractionShape` — `validate-orchestrator-output.ps1`

**SOURCE delta:** SOURCE version adds `Test-HumanInteractionShape` function (lines 133–214) and two call sites (lines 292–298) in `Invoke-OrchestratorOutputValidation`. The repo version has neither.

The function:
- Passes when `human_interaction` key is absent from checkpoint (backward-compatible).
- Blocks when `requirements` array is missing.
- Blocks when any requirement has no `response`.
- Blocks when `response` is outside the enum (`scope_change|exception|halt`).
- Blocks when `response == 'halt'` (halt blocks DONE).
- Blocks when `response == 'exception'` and `runbook_path` is empty or file does not exist on disk.
- Uses an injectable `$FileExistsCheck` scriptblock for testability.

**Why this is hardening:** Without `Test-HumanInteractionShape`, the orchestrator can write DONE even when an unresolved `halt` or a runbook-less `exception` is present in the checkpoint. The hook is the mechanical enforcement of the Autonomous-Execution Mandate.

**Files requiring change:**
- `.claude/hooks/validate-orchestrator-output.ps1` — add `Test-HumanInteractionShape` function and wire it into `Invoke-OrchestratorOutputValidation`
- `.claude/rules/orchestrator-state.md` — update the "Foreign Schema Warning" note to mention that `human_interaction` invariant is now also enforced by this hook (not just the schema)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1` — same code change
- `packages/mcp-server/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1` — same code change

---

### 4.3 `Test-AutomationFeasibilitySection` — `validate-task-researcher-output.ps1`

**SOURCE delta:** SOURCE version adds `Test-AutomationFeasibilitySection` function (lines 86–147) and a call site (lines 192–195) at the end of `Invoke-TaskResearcherOutputValidation`. The repo version ends the validation before that check.

The function:
- Is narrow-scoped by a detection pattern (`autonomous-execution|human-interaction`) checked against both the filename and the agent output.
- Non-matching research artifacts pass unaffected.
- For matching artifacts, reads the file and requires an `## Automation Feasibility` heading.
- Uses an injectable `$ReadFileContent` scriptblock for testability.

**Why this is hardening:** Without this check, a task-researcher can produce an autonomous-execution research artifact that omits the feasibility section required by the mandate. The hook ensures that every research artifact touching third-party UIs or human-interaction scenarios explicitly records the automation feasibility assessment.

**Files requiring change:**
- `.claude/hooks/validate-task-researcher-output.ps1` — add `Test-AutomationFeasibilitySection` function and call site
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1` — same change
- `packages/mcp-server/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1` — same change

---

### 4.4 `human-exception-runbook` skill — SOURCE-only

**SOURCE delta:** Two files, entirely absent from repo:
- `artifacts/tocompare/.claude/skills/human-exception-runbook/SKILL.md`
- `artifacts/tocompare/.claude/skills/human-exception-runbook/example.runbook.md`

`SKILL.md` defines:
- When to use the skill (orchestrator detected an unautomatable requirement resolved as `exception`)
- Canonical path: `<FEATURE>/runbooks/<name>.runbook.md` (note: explicitly outside `evidence/`, so `enforce-evidence-locations.ps1` does not apply — OD-45-6)
- Five required sections: Cue, Prerequisites, Step-by-step Instructions, Verification, Source and Citation
- MCP-first / web-second sourcing rule for third-party UI steps
- Conformance definition

`example.runbook.md` provides a complete, contract-conformant example (grant tenant-wide admin consent for an Entra application).

**Why this is hardening:** The `orchestrate` skill and `validate-orchestrator-output.ps1` both reference this skill by path. Without the skill file, the runbook contract is undefined. The `runbook_path` gate in `Test-HumanInteractionShape` enforces that a runbook file exists, but nothing tells the orchestrator what a conformant runbook looks like.

**Files requiring change:**
- `.claude/skills/human-exception-runbook/SKILL.md` — create new file
- `.claude/skills/human-exception-runbook/example.runbook.md` — create new file
- Both bundled mirrors — same new files at corresponding paths

---

### 4.5 `general-unit-test.md` — Two hardened sections

**SOURCE delta:** The SOURCE `general-unit-test.md` (shown in system context from `artifacts/tocompare/.claude/rules/general-unit-test.md`) contains two sections absent from the repo's `.claude/rules/general-unit-test.md`:

**Section A: Coverage Exclusion Policy** (after the Coverage Requirements section)

```
No production file may be excluded from coverage measurement. Every production source 
file is in the denominator of the coverage metric...

Permitted exclude entries (non-production paths only):
- Build output directories: dist/**, lib/**, lib-amd/**.
- Test files and test infrastructure: **/*.test.ts, tests/**, src/test-support/**.
- Config files: vitest.config.ts, eslint.config.mjs, .dependency-cruiser.cjs, webpack.config.js.
- node_modules/**.

Prohibited exclude entries:
- Any path under src/ that contains production runtime code...

Enforcement: Feature-review agents must treat any exclude entry that matches a 
production source path as a Blocking finding.
```

**Section B: Test File Location** (after External Dependencies section)

```
Test files must live in a tests/ directory tree that mirrors the production source 
structure... 
Colocation — placing test files alongside production source files in src/ or 
equivalent — is not permitted. An agent that creates or moves a test file into 
the production source tree has violated this rule.
```

**Why this is hardening:** The coverage exclusion policy closes a loophole not addressed by the repo version — agents could silently exclude production source paths from coverage measurement. The test file location rule prevents colocation of test files with production code, which is a structural invariant this repo relies on (the contract tests for push-down assume a `tests/` tree).

**Files requiring change:**
- `.claude/rules/general-unit-test.md` — add both sections
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md` — same change
- `packages/mcp-server/resources/claude-customizations/.claude/rules/general-unit-test.md` — same change

---

### 4.6 `remediation-handoff-atomic-planner/SKILL.md` — Substantially expanded

**SOURCE delta:** SOURCE version is 114 lines with a formal handoff-chain specification. Repo version is 41 lines covering only trigger conditions, required inputs, and a brief handoff summary.

Key additions in the SOURCE:
- `Full Handoff Chain` ASCII diagram (orchestrator → atomic-planner → preflight loop → atomic-executor → feature-review → exit gate)
- `Required Artifacts` section: five artifacts per cycle, entry-timestamp vs. exit-timestamp distinction. A cycle with fewer than five artifacts is explicitly malformed.
- `Plan Shape` section: references `atomic-plan-contract/SKILL.md` and requires MCP plan validation before executor runs preflight.
- `Preflight Sub-Loop` section: formalization of the `PREFLIGHT: REVISIONS REQUIRED` → planner revision → re-preflight sub-loop.
- `Exit Gate` section: defines `blocking_count`, `exit_condition_met`, and cycle N+1 initialization.

**Why this is hardening:** The repo version leaves the entry/exit timestamp distinction unspecified, which allows malformed cycles (e.g., single timestamp for both entry and exit artifacts). The full chain diagram removes ambiguity about which worker does what. The plan-shape and preflight-sub-loop contracts align the skill with the existing `atomic-plan-contract` and `validate-orchestrator-output.ps1` invariants.

**Files requiring change:**
- `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` — replace with SOURCE version
- Both bundled mirrors — same replacement

---

## 5. Explicit Treatment — `schemas/orchestrator-state.schema.json` Foreign-Schema Question

**Finding:** The SOURCE schema at `artifacts/tocompare/.claude/schemas/orchestrator-state.schema.json` is NOT the foreign schema referenced in the repo's `.claude/rules/orchestrator-state.md` warning. Evidence:

- The SOURCE schema `$id` is `"orchestrator-state.schema.json"` — a relative, repo-local identifier with no external hostname.
- The foreign schema warned against has `$id` referencing `drmoisan.github.io/mix-calculator/`, which does not appear anywhere in the SOURCE schema.
- The SOURCE schema's top-level uses `"additionalProperties": true`, making it additive and backward-compatible with existing checkpoints.
- The cycle-level `"additionalProperties": false` in the SOURCE schema matches the existing repo validator contract (the three invariants in `validate_orchestrator_state.py`).

**Invariants encoded in SOURCE schema that the repo's `validate_orchestrator_state.py` covers:**
- Non-empty `plan_path` (minLength: 1 in schema; prose invariant 1 in rule)
- Execution requires cleared preflight (`allOf` if/then in schema; invariant 2 in rule)
- Exit gate requires zero blocking count (`allOf` if/then in schema; invariant 3 in rule)

**Net-new invariant in SOURCE schema NOT covered by repo's prose rule or validator:**

The SOURCE schema adds a top-level `human_interaction` object with:
- `required: ["requirements"]`
- Per-requirement `required: ["id", "description", "discovered_at_stage", "response"]`
- `response` enum: `["scope_change", "exception", "halt"]`
- `allOf` exception-requires-runbook conditional: `response == "exception"` requires non-empty `runbook_path`

The repo's `validate_orchestrator_state.py` does not cover the `human_interaction` shape at all. The hook-based `Test-HumanInteractionShape` (see Section 4.2) is the runtime enforcement, but the schema codifies the structural contract.

**Recommendation: PORT-INVARIANT-ONLY**

Do not copy the schema verbatim. Instead:
1. Port the `human_interaction` invariants into `scripts/dev_tools/validate_orchestrator_state.py` following the same error-message style as the existing three invariants.
2. Update `.claude/rules/orchestrator-state.md` to remove the "Foreign Schema Warning" framing (the schema with a repo-local `$id` is no longer the disqualified foreign schema) and instead document the new `human_interaction` invariants alongside the existing three, citing the validator for enforcement.
3. Optionally add the schema file under `.claude/schemas/` to serve as machine-readable documentation, but enforce via the existing Python validator rather than a JSON Schema validator tool.

---

## 6. Explicit Treatment — `human-exception-runbook` Skill

The `skills/human-exception-runbook/` skill is a net-new guardrail worth adopting. It is not a duplicate of existing content. Assessment:

**What it adds:** A formal runbook contract for the one case the autonomous-execution mandate cannot fully automate — a permitted exception that requires a human to execute a specific step. The contract defines what must be in the runbook (five sections), where it must live (`<FEATURE>/runbooks/<name>.runbook.md`), and what sourcing standard applies (MCP-first, web-second for third-party UI steps).

**Integration with existing enforcement:** `validate-orchestrator-output.ps1`'s `Test-HumanInteractionShape` checks that a runbook file exists at `runbook_path`. This check is meaningless if agents do not know what a conformant runbook contains. The skill closes that gap.

**Is it repo-specific?** The runbook contract is generic across any repository using the orchestrator pattern. The example in `example.runbook.md` uses Microsoft Entra / Graph context, which is relevant to this repo's domain.

**Recommendation: PROPAGATE** both SKILL.md and example.runbook.md as described in Section 4.4.

---

## 7. Prioritized Follow-up Changes

All items require changes to `.claude/` (canonical runtime) and both bundled mirrors.

| Priority | Item | Change Budget | Key Files Affected |
|---|---|---|---|
| 1 (High) | Add `Test-HumanInteractionShape` to `validate-orchestrator-output.ps1` | Small (add one function + two call sites; ~90 lines) | `hooks/validate-orchestrator-output.ps1` (3 copies) |
| 2 (High) | Add `Test-AutomationFeasibilitySection` to `validate-task-researcher-output.ps1` | Small (add one function + one call site; ~65 lines) | `hooks/validate-task-researcher-output.ps1` (3 copies) |
| 3 (High) | Add `## Autonomous-Execution Mandate` section to `orchestrate/SKILL.md` | Small (prose addition; ~28 lines) | `skills/orchestrate/SKILL.md` (3 copies) |
| 4 (High) | Create `skills/human-exception-runbook/` (SKILL.md + example.runbook.md) | Small (two new files; ~100 lines total) | New files in 3 copies |
| 5 (Medium) | Port `human_interaction` invariants to `validate_orchestrator_state.py` + update `rules/orchestrator-state.md` | Medium (Python validator extension + rule prose update; ~40 lines Python + rule update) | `scripts/dev_tools/validate_orchestrator_state.py`, `.claude/rules/orchestrator-state.md` |
| 6 (Medium) | Add `## Coverage Exclusion Policy` and `## Test File Location` sections to `general-unit-test.md` | Small (prose additions; ~35 lines) | `rules/general-unit-test.md` (3 copies) |
| 7 (Medium) | Replace `remediation-handoff-atomic-planner/SKILL.md` with SOURCE version | Small (replace existing 41-line file with 114-line file) | `skills/remediation-handoff-atomic-planner/SKILL.md` (3 copies) |

**Dependency ordering:** Items 1–4 are self-contained and can be applied in any order. Item 5 depends on Items 1 and 4 being deployed (so the hook and skill exist before the rule references them). Items 6 and 7 are independent of 1–5.

**Not recommended for propagation:**
- `settings.local.json` from SOURCE — developer-local; contains another repo's allow-list entries.
- `agent-memory/**` from SOURCE — project-specific memory from the TMW repository.
- SOURCE `schemas/orchestrator-state.schema.json` verbatim — invariants are better maintained via the existing Python validator pattern.
- `rules/orchestrator-state.md` from REPO into SOURCE — the repo is ahead here; nothing to port back.
