# Code Review: harden feature promotion lifecycle MCP-only (#168)

**Review Date:** 2026-04-29
**Reviewer:** GitHub Copilot
**Feature Folder:** `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168`
**Feature Folder Selection Rule:** Explicitly supplied active feature folder for issue `#168`
**Base Branch:** `development`
**Head Branch:** `feature/harden-feature-promotion-lifecycle-mcp-only-168` working tree
**Review Type:** Post-remediation re-review

---

## Executive Summary

The rerun confirms that the Claude-side MCP-only hardening behavior is present and that the split validator layout preserved the CLI contract and current checkpoint behavior. The refreshed PR context against `development` and the current workspace validator checks are consistent with the feature requirements.

The earlier 2026-04-29T13-55 review package overstated merge readiness. A direct line-count rerun shows `scripts/dev_tools/validate_orchestration_review_artifacts.py` is still 516 lines, so the repository's 500-line production-file rule remains open. The QA evidence also still leaves the two new Python modules below the repository's 90% new-module coverage target.

**What changed:**
The reviewed working tree hardens `.claude/skills/feature-promotion-lifecycle/SKILL.md`, `.claude/settings.json`, and `.claude/agents/orchestrator.md`; adds `.claude/hooks/enforce-promotion-mcp-only.ps1`; and splits the orchestration validator behavior across `validate_orchestration_artifacts.py`, `validate_orchestration_review_artifacts.py`, and `validate_orchestrator_state.py` with matching test updates.

**Top 3 risks:**
1. `scripts/dev_tools/validate_orchestration_review_artifacts.py` is still 516 lines, so the prior 500-line finding is not resolved.
2. `validate_orchestration_review_artifacts.py` and `validate_orchestrator_state.py` remain below the repository 90% coverage target for new modules.
3. The branch currently reviews as a working tree relative to `development`, so future reviewers will still see an empty commit-range summary until the changes are committed.

**PR readiness recommendation:** **Needs Revision** ΓÇö the feature behavior is delivered, but the merge gate remains closed by the unresolved file-size and coverage findings.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `scripts/dev_tools/validate_orchestration_review_artifacts.py` | whole file | The production module is still 516 lines, which violates the repository 500-line production-file limit. | Split the review-artifact validator again into smaller cohesive modules while preserving the current CLI contract and validator behavior. | The repository treats the 500-line production-file limit as a hard code-change policy rule. | `pwsh` line-count check on 2026-04-29 reported `scripts/dev_tools/validate_orchestration_review_artifacts.py    516`. |
| Major | `scripts/dev_tools/validate_orchestration_review_artifacts.py`; `scripts/dev_tools/validate_orchestrator_state.py` | coverage evidence | The two new Python modules remain below the repository 90% coverage target for new modules. | Add focused tests for the remaining defensive branches in the split validator modules. | The feature's behavior is covered, but the current evidence still misses the policy target for new modules. | `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-pytest.2026-04-29T10-52.md` records 87.02% and 83.33%. |
| Info | `artifacts/pr_context.summary.txt` | `Base/Head` section | The refreshed PR context shows no committed branch delta against `development`; the current review is working-tree based. | Commit the reviewed changes before the next PR-context refresh. | The current rerun is valid, but future branch-level review artifacts will remain empty until the working tree is committed. | `artifacts/pr_context.summary.txt` reports the same SHA for resolved base, head, and merge base. |

No additional Blocker or Major findings were identified beyond the unresolved merge-gate items above.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The stable CLI entrypoint remains intact while the receipt and review validation logic is separated into helper modules.
- The current workspace validator still accepts the live checkpoint shape through `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json`.

#### Typing and API notes

- The reviewed Python validator surfaces remain type-annotated and Pyright-clean per the stored QA evidence.
- No new public Python API was added beyond the split internal modules; the public entrypoint remains `scripts.dev_tools.validate_orchestration_artifacts`.

#### Error handling and logging

- The validator remains explicit about malformed inputs and unsupported receipt shapes.
- No ad-hoc debug output was introduced in the reviewed Python scope.

### PowerShell implementation audit

#### What changed well

- The new hook remains narrow and deterministic: it blocks only the four forbidden promotion-bypass tokens.
- The helper-based structure makes the hook easy to test directly without invoking Bash.

#### API and safety notes

- The PowerShell scope remains below the repository size limit.
- The hook's behavior remains explicit and does not mutate or reinterpret command text beyond token inspection.

#### Error handling and logging

- Malformed hook input is surfaced explicitly.
- The deny path returns the canonical block reason rather than silently ignoring forbidden commands.

---

## Test Quality Audit

The review evidence remains strong for delivered behavior. The QA artifacts show clean formatter, lint, type-check, and test passes for the implementation scope, and the current rerun adds direct validation of the live checkpoint behavior plus the corrected file-size evidence.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` ΓÇö verifies entrypoint re-exports, legacy receipt compatibility, additive namespaced receipt acceptance, and unsupported-key rejection.
- `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` ΓÇö verifies the MCP-only skill wording and orchestrator receipt-namespace wording contracts.
- `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` ΓÇö proves one allow path and the four forbidden-token deny paths.
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-pytest.2026-04-29T10-52.md` ΓÇö records the 29 passing Python tests and the current split-module coverage figures.

### Quality assessment prompts

- **Determinism:** The tests use repository-local text and synthetic payloads only.
- **Isolation:** Each reviewed test targets one contract or one validator decision.
- **Speed:** The focused Python suite completed in `0.16s`; the stored PowerShell evidence shows no long-running behavior.
- **Diagnostics:** Failure messages would identify the missing contract fragment, wrong deny message, or unsupported receipt branch directly.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | Γ£à PASS | The reviewed scope contains no credentials or secret material. |
| No unsafe subprocess or command construction | Γ£à PASS | The new PowerShell hook inspects attempted command text; it does not construct or execute subprocess commands. |
| Input validation at boundaries | Γ£à PASS | The hook validates `CLAUDE_TOOL_INPUT` and the validator rejects malformed structures explicitly. |
| Error handling remains explicit | Γ£à PASS | Both the hook and validator fail closed on malformed input. |
| Configuration / path handling is safe | Γ£à PASS | `.claude/settings.json` remains valid JSON and the added hook path is explicit. |

---

## Research Log

No external research was required for this rerun. The review used refreshed repository-local PR context, feature-folder evidence, direct line-count output, and the workspace validator entrypoint.

---

## Verdict

The delivered behavior requested by feature `#168` is still present and the acceptance criteria remain satisfied. The rerun, however, shows that the prior statement that the 500-line production-file finding was resolved is no longer supported by the current working tree.

This change is not ready for normal PR flow. Resolve the oversized `scripts/dev_tools/validate_orchestration_review_artifacts.py` module and raise coverage for the two new Python modules to the repository's 90% new-module target, then rerun the review package.
