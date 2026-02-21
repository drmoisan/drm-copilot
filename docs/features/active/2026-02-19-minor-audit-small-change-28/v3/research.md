<!-- markdownlint-disable-file -->

# Task Research Notes: machine-readable-work-mode-branching

## Research Executed

### File Analysis

- `.github/agents/atomic_planning.agent.md`
  - Uses `policy-compliance-order` + `atomic-plan-contract`; enforces Phase 0 + final QA loop, but has no explicit `Work Mode` ingestion/branching contract.
- `.github/agents/atomic_executor.agent.md`
  - Enforces plan preflight and execution rigor, but does not require mode-aware acceptance criteria branching (`minor-audit` vs `full`).
- `.github/agents/python-typed-engineer.agent.md`
  - Enforces strong baseline/QA gates and scope control, but no machine-readable `Work Mode` branch requirements.
- `.github/agents/powershell-atomic-planning.agent.md`
  - Mirrors atomic planning contract and preflight handoff rigor; no mode-aware branch contract.
- `.github/agents/powershell-atomic-executor.agent.md`
  - Enforces strict PowerShell toolchain and preflight, but no path selection based on persisted mode marker.
- `.github/agents/powershell-orchestrator.agent.md`
  - Has deterministic branching, but by change-budget (`small`/`large`) rather than `Work Mode` metadata.
- `.github/skills/atomic-plan-contract/SKILL.md`
  - Requires Phase 0 policy reading + baseline capture and final QA loop; currently mode-agnostic.
- `.github/skills/feature-promotion-lifecycle/SKILL.md`
  - Defines `${work-mode}` variable and mode-aware output expectation (`minor-audit` may omit `spec.md`/`user-story.md`).
- `docs/features/active/2026-02-20-bootstrap-typescript-33/issue.md`
  - Contains persisted marker `- Work Mode: minor-audit` above first `##` heading.
- `docs/features/active/2026-02-20-bootstrap-typescript-33/plan.2026-02-21T10-38.md`
  - Still template-like with placeholders (`<Phase Name>`, `<Atomic task...>`) and no mode-specific planning requirements.
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/spec.md`
  - Defines fail-closed marker semantics and mode-aware consumer expectations.
- `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/user-story.md`
  - Requires deterministic minor-audit eligibility and minimum evidence package for review.

### Code Search Results

- `work-mode|Work Mode|minor-audit` in `.github/agents/atomic_planning.agent.md`
  - No matches.
- `work-mode|Work Mode|minor-audit` in `.github/agents/atomic_executor.agent.md`
  - No matches.
- `work-mode|Work Mode|minor-audit` in `.github/agents/python-typed-engineer.agent.md`
  - No matches.
- `work-mode|Work Mode|minor-audit` in `.github/agents/powershell-atomic-planning.agent.md`
  - No matches.
- `work-mode|Work Mode|minor-audit` in `.github/agents/powershell-atomic-executor.agent.md`
  - No matches.

### External Research

- #githubRepo:"microsoft/autogen deterministic multi-agent routing selector graph"
  - Verified patterns: custom selector function override, candidate filtering, explicit termination conditions, and graph-constrained execution (`GraphFlow`) for deterministic routing semantics.
- #fetch:https://developers.openai.com/api/docs/guides/structured-outputs
  - Structured outputs provide schema-adherent responses (not just valid JSON), explicit refusal signaling, and strict schema constraints suitable for machine-checkable control planes.
- #fetch:https://developers.openai.com/api/docs/guides/function-calling
  - Determinism levers include `strict: true`, `tool_choice` control, `allowed_tools`, disabling parallel tool calls when needed, and schema constraints (`required`, `additionalProperties: false`).
- #fetch:https://developers.openai.com/api/docs/guides/evaluation-best-practices
  - Recommends eval-driven development with architecture-aware evaluation (workflow vs single-agent vs multi-agent), tool-selection evaluations, and continuous evaluation to catch nondeterministic regressions.
- #fetch:https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/prompt-engineering
  - Supports consistency improvements via explicit instruction ordering, syntax constraints, task decomposition, grounding, and output-structure specification.
- #fetch:https://platform.claude.com/docs/en/build-with-claude/structured-outputs
  - Confirms practical deterministic constraints: strict tool schemas, grammar compilation/caching behavior, and explicit caveats for refusal/token-limit edge cases.
- #fetch:https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/selector-group-chat.html
  - Confirms hybrid approach: model-based selection + deterministic override (`selector_func`, `candidate_func`) + termination gates.
- #fetch:https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/graph-flow.html
  - Confirms directed-graph workflow execution for deterministic control, conditional branching, loop controls, activation groups, and message filtering.

### Project Conventions

- Standards referenced: `policy-compliance-order`, `atomic-plan-contract`, `evidence-and-timestamp-conventions`, `feature-promotion-lifecycle`.
- Instructions followed: repo policy precedence and Task Researcher constraint (research-only output in `artifacts/research/`).

## Key Discoveries

### Project Structure

Current repo capability is split:

1. Producer layer already persists `- Work Mode: ...` in `issue.md` and supports `--work-mode` in lifecycle commands.
2. Planning/execution agents enforce strong generic rigor (preflight, baseline, QA loops) but do not ingest `issue.md` marker as a required branch input.
3. Feature-level plan templates can still be generated without mode-aware obligations, causing drift between issue-level marker and plan-level obligations.

### Implementation Patterns

Most deterministic pattern that fits this repo: a two-layer control plane.

- Layer A (machine-readable state): canonical `Work Mode` marker + optional structured sidecar (`work-mode.contract.json`) generated from `issue.md`.
- Layer B (agent/skill enforcement): hard preflight checks requiring explicit mode branch, fail-closed to `full` if marker missing/malformed.

This mirrors existing repo behavior (fail-closed to full in spec) and existing deterministic contracts (preflight ALL CLEAR/REVISIONS REQUIRED).

### Complete Examples

```python
from dataclasses import dataclass
from pathlib import Path
import re

WORK_MODE_RE = re.compile(r"^-\s*Work Mode:\s*(minor-audit|full)\s*$", re.IGNORECASE)


@dataclass(frozen=True)
class WorkModeContract:
    mode: str
    source: str
    fail_closed_default: str = "full"


def resolve_work_mode(issue_md_path: Path) -> WorkModeContract:
    """Resolve persisted work mode from issue metadata with fail-closed semantics."""
    text = issue_md_path.read_text(encoding="utf-8")
    for line in text.splitlines():
        match = WORK_MODE_RE.match(line.strip())
        if match:
            return WorkModeContract(mode=match.group(1).lower(), source=str(issue_md_path))
    # fail-closed policy
    return WorkModeContract(mode="full", source=str(issue_md_path))
```

### API and Schema Documentation

Recommended machine-readable contract for all planning/execution agents:

- Input source precedence:
  1. `issue.md` persisted marker (authoritative)
  2. optional explicit CLI override only if policy permits (must be echoed and reconciled)
  3. fallback `full` (fail-closed)
- Required branch outcomes:
  - `minor-audit`: require baseline + targeted verification + end-state evidence; do not require `spec.md`/`user-story.md` completeness checks.
  - `full`: require full plan/spec/story obligations and complete toolchain loop.
- Preflight enforcement:
  - if selected mode is `minor-audit`, preflight fails unless plan contains mode-specific evidence tasks and mode-specific completion criteria.

### Configuration Examples

```json
{
  "work_mode_contract": {
    "version": "1",
    "source": "docs/features/active/<feature>/issue.md",
    "selected_mode": "minor-audit",
    "fail_closed_default": "full",
    "requirements": {
      "minor_audit": {
        "must_have_evidence": ["baseline", "targeted-verification", "end-state"],
        "doc_expectations": {"spec_md": "optional", "user_story_md": "optional"}
      },
      "full": {
        "must_have_evidence": ["baseline", "qa-gates", "regression-testing"],
        "doc_expectations": {"spec_md": "required", "user_story_md": "required"}
      }
    }
  }
}
```

### Technical Requirements

- Add a shared mode-resolution helper (or skill-level contract text) consumed by:
  - `atomic_planner`, `atomic_executor`, `python-typed-engineer`, `powershell-atomic-planning`, `powershell-atomic-executor`.
- Extend `atomic-plan-contract` with mandatory mode-branch preflight checks:
  - verify mode source,
  - verify branch-specific acceptance criteria,
  - verify evidence task set by mode.
- Update plan template generation so `minor-audit` plans include no placeholders and include explicit baseline/targeted/end-state tasks.
- Add contract tests validating each agent file contains mode-aware preflight/branching directives.
- Add smoke-test fixtures for:
  - valid minor marker,
  - malformed marker,
  - missing marker (must select full).

**Mandatory unachievable objective callout**:
- **Perfect determinism is not achievable with LLM-based planning/execution alone; only bounded determinism is achievable.** Rationale: generation remains probabilistic, so reliability must come from constrained inputs/outputs, fail-closed policies, strict schema/tool controls, and automated eval gates.

## Recommended Approach

Adopt a deterministic “mode control plane” centered on the persisted `issue.md` marker, and enforce it via shared preflight gates.

Selected approach:

1. Canonical mode source: `issue.md` marker (`- Work Mode: minor-audit|full`).
2. Optional normalization artifact: generate `work-mode.contract.json` during planning intake.
3. Shared preflight requirement (all targeted agents): parse mode, branch acceptance criteria/evidence policy, fail closed to `full` if missing/malformed.
4. Plan-template enforcement: mode-specific atomic scaffolding, no placeholders.
5. Continuous evals: add mode-routing contract tests + smoke tests from real feature folders.

Rejected alternatives (brief):

- Prompt-only branching without machine-readable marker: rejected because it is not auditable and drifts under non-deterministic generation.
- Runtime heuristic mode inference from file presence: rejected because missing files may be valid in `minor-audit` and invalid in `full`; marker is clearer and fail-closed.
- Per-agent custom logic without shared contract: rejected due to drift risk and inconsistent policy interpretation.

## Implementation Guidance

- **Objectives**: Make mode selection machine-verifiable and force deterministic branch behavior for plan/execution/evidence requirements.
- **Key Tasks**:
  - Update `v3/spec.md` to define a formal mode control plane and preflight branch contract across planning/execution agents.
  - Update `v3/user-story.md` acceptance criteria to explicitly require agent/skill mode branching and fail-closed semantics.
  - Add/extend shared skill contract (`atomic-plan-contract`) with mode-aware preflight checks.
  - Update each target agent to require mode ingestion and branch-specific obligations.
  - Add contract + smoke tests for mode branch correctness and malformed-marker handling.
- **Dependencies**: Existing `feature-promotion-lifecycle`, `atomic-plan-contract`, and evidence schema conventions (`Timestamp`, `Command`, `EXIT_CODE`).
- **Success Criteria**:
  - Plans generated from `minor-audit` issues always include baseline + targeted + end-state evidence tasks and skip full-doc mandates.
  - Plans generated from `full` issues enforce full-doc path.
  - Missing/malformed markers always route to `full` (auditable fail-closed).
  - Contract tests confirm all five targeted agents/skills carry explicit mode-branch directives.