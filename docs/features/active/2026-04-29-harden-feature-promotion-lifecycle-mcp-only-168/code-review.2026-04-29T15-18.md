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

The rerun confirms that the Claude-side MCP-only hardening behavior is present and that the split validator layout preserved the CLI contract and current checkpoint behavior. The refreshed PR context against `development`, the updated line-count evidence, and the final Python QA loop are all consistent with the feature requirements.

The remediation plan resolved the earlier merge-gate blockers. `scripts/dev_tools/validate_orchestration_review_artifacts.py` is now 99 lines, the extracted `scripts/dev_tools/validate_policy_audit_artifact.py` module remains below the repository file-size limit at 448 lines, and the refreshed focused Python evidence lifts the tracked validator modules to 100%, 90%, and 97% coverage.

**What changed:**
The reviewed working tree hardens `.claude/skills/feature-promotion-lifecycle/SKILL.md`, `.claude/settings.json`, and `.claude/agents/orchestrator.md`; adds `.claude/hooks/enforce-promotion-mcp-only.ps1`; and splits the orchestration validator behavior across `validate_orchestration_artifacts.py`, `validate_orchestration_review_artifacts.py`, and `validate_orchestrator_state.py` with matching test updates.

**Top 3 risks:**
1. The branch currently reviews as a working tree relative to `development`, so future reviewers will still see an empty commit-range summary until the changes are committed.
2. The policy and feature audits should travel with the updated QA evidence so downstream reviewers use the corrected merge-gate package.
3. The split validator architecture now spans three Python modules, so future edits should preserve the stable CLI entrypoint and the additive receipt namespace.

**PR readiness recommendation:** **Ready for Merge Review** — the feature behavior is delivered and the refreshed line-count and Python coverage gates now pass.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/dev_tools/validate_orchestration_review_artifacts.py`; `scripts/dev_tools/validate_policy_audit_artifact.py`; `scripts/dev_tools/validate_orchestrator_state.py` | remediation evidence | The remediation split now keeps all Python validator modules below the repository 500-line limit and lifts the tracked module coverage to the required threshold. | Preserve the current split layout unless a future change can maintain both the stable CLI contract and the line-count budget. | The current evidence resolves the prior file-size and coverage blockers without changing the public validator entrypoint. | `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/other/p1-t6.post-refactor-line-count.2026-04-29T15-18.md`; `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/p3-t4.python-pytest.2026-04-29T15-18.md`; `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/p3-t5.python-coverage-comparison.2026-04-29T15-18.md` |
| Info | `artifacts/pr_context.summary.txt` | `Base/Head` section | The refreshed PR context shows no committed branch delta against `development`; the current review is working-tree based. | Commit the reviewed changes before the next PR-context refresh. | The current rerun is valid, but future branch-level review artifacts will remain empty until the working tree is committed. | `artifacts/pr_context.summary.txt` reports the same SHA for resolved base, head, and merge base. |

No Blocker or Major findings remain in the refreshed review scope.

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

- `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` — verifies entrypoint re-exports, legacy receipt compatibility, additive namespaced receipt acceptance, and unsupported-key rejection.
- `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` — verifies the MCP-only skill wording and orchestrator receipt-namespace wording contracts.
- `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` — proves one allow path and the four forbidden-token deny paths.
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/other/p1-t6.post-refactor-line-count.2026-04-29T15-18.md` — records the resolved validator line counts.
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/p3-t4.python-pytest.2026-04-29T15-18.md` — records the 44 passing Python tests and the refreshed split-module coverage figures.
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/p3-t5.python-coverage-comparison.2026-04-29T15-18.md` — records the resolved Python coverage comparison against the baseline evidence.

### Quality assessment prompts

- **Determinism:** The tests use repository-local text and synthetic payloads only.
- **Isolation:** Each reviewed test targets one contract or one validator decision.
- **Speed:** The focused Python suite completed in `0.16s`; the stored PowerShell evidence shows no long-running behavior.
- **Diagnostics:** Failure messages would identify the missing contract fragment, wrong deny message, or unsupported receipt branch directly.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | The reviewed scope contains no credentials or secret material. |
| No unsafe subprocess or command construction | ✅ PASS | The new PowerShell hook inspects attempted command text; it does not construct or execute subprocess commands. |
| Input validation at boundaries | ✅ PASS | The hook validates `CLAUDE_TOOL_INPUT` and the validator rejects malformed structures explicitly. |
| Error handling remains explicit | ✅ PASS | Both the hook and validator fail closed on malformed input. |
| Configuration / path handling is safe | ✅ PASS | `.claude/settings.json` remains valid JSON and the added hook path is explicit. |

---

## Research Log

No external research was required for this rerun. The review used refreshed repository-local PR context, feature-folder evidence, direct line-count output, and the workspace validator entrypoint.

---

## Verdict

The delivered behavior requested by feature `#168` is still present and the acceptance criteria remain satisfied. The remediation rerun now also supports the prior merge-readiness claim with refreshed evidence: the validator split remains under the repository file-size limit, the stable CLI entrypoint still validates the live checkpoint, and the focused Python coverage gate now passes.

This change is ready for normal PR review. Keep the refreshed review package with the branch when the working-tree changes are committed.
