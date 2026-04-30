# Code Review: harden feature promotion lifecycle MCP-only (#168)

**Review Date:** 2026-04-29
**Reviewer:** GitHub Copilot
**Feature Folder:** `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168`
**Feature Folder Selection Rule:** Explicitly supplied active feature folder for issue `#168`
**Base Branch:** `development`
**Head Branch:** `feature/harden-feature-promotion-lifecycle-mcp-only-168` working tree
**Review Type:** Remediation review

---

## Executive Summary

The reviewed working tree remediates the prior policy finding by splitting the orchestration validator into `validate_orchestration_artifacts.py`, `validate_orchestration_review_artifacts.py`, and `validate_orchestrator_state.py` while preserving the existing CLI entrypoint, artifact-type names, and additive `delegation_receipts.promotion.*` behavior. The implementation evidence includes direct inspection of the split modules, a CLI `--help` verification pass, targeted regression suites, and the final Phase 2 Python QA evidence.

Implementation quality is strong in the remediation scope. The split modules are cohesive, all touched production files are now below the repository’s 500-line limit, and the stable CLI contract is preserved. The remaining technical concern is test depth rather than behavior: the two new split modules currently measure 87% and 83% line coverage in the final QA evidence, below the repository target for new modules.

**What changed:**
The change set modifies `.claude/skills/feature-promotion-lifecycle/SKILL.md`, `.claude/settings.json`, `.claude/agents/orchestrator.md`, and `scripts/dev_tools/validate_orchestration_artifacts.py`; adds `.claude/hooks/enforce-promotion-mcp-only.ps1`; and updates the related PowerShell and Python regression suites to cover the new guardrails and validator behavior.

**Top 3 risks:**
1. The two new split modules currently measure 87% and 83% line coverage in the final QA evidence, below the repository target for new modules.
2. The review is necessarily working-tree-based because the feature branch tip currently equals `development`, so the canonical commit-range summary does not capture the implementation delta.
3. The validator entrypoint is now a re-export layer, so future changes must continue to preserve the public CLI and imported symbol surface exercised by the regression tests.

**PR readiness recommendation:** **Needs Revision** — the remediation objective is implemented and verified, but the two new split modules should gain additional test coverage before normal PR flow.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Medium | `scripts/dev_tools/validate_orchestration_review_artifacts.py`; `scripts/dev_tools/validate_orchestrator_state.py` | coverage evidence | The remediation resolved the prior 500-line issue, but the two new split modules currently measure 87% and 83% line coverage in the final QA evidence, below the repository target for new modules. | Add targeted tests for uncovered malformed review-artifact and orchestrator-state edge paths while preserving the current CLI and validator contracts. | The split itself is correct and verified, but the new-module coverage target remains the main outstanding policy concern in the remediated scope. | `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-pytest.2026-04-29T10-52.md` reports 87% for `validate_orchestration_review_artifacts.py` and 83% for `validate_orchestrator_state.py`. |
| Info | `artifacts/pr_context.summary.txt` | `Base/Head` section | The refreshed PR context against `development` shows the branch tip and base at the same commit, so the effective review scope is the current working tree rather than a committed branch diff. | Commit or stage the reviewed changes before any final PR review so the canonical PR-context summary can represent the actual branch delta. | The current review is still valid, but future reviewers will otherwise see an empty commit-range summary. | `artifacts/pr_context.summary.txt` reports `Base ref (resolved): origin/development @ d38105a...` and `Head ref (resolved): feature/harden-feature-promotion-lifecycle-mcp-only-168 @ d38105a...`. |
| Info | `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/powershell-coverage-comparison.2026-04-29T08-56.md` | coverage comparison | The generated PowerShell coverage artifacts do not provide a numeric changed-file metric for `.claude/hooks/enforce-promotion-mcp-only.ps1`. | If numeric changed-file coverage becomes a hard gate for PowerShell guardrails, extend the evidence generation so the report includes per-file metrics for newly added hooks. | The current behavior is directly tested, but the audit trail cannot prove numeric changed-file coverage from the generated report alone. | The comparison artifact records `New/Changed-code Coverage: NOT DERIVABLE FROM GENERATED REPORT`. |

No Blockers findings were identified.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The validator broadens `delegation_receipts` acceptance in an additive way instead of breaking the legacy list-based checkpoint shape.
- The split keeps receipt-state validation isolated from review-artifact validation while preserving the shared CLI entrypoint and re-export surface.

#### Typing and API notes

- The touched Python validator remains Pyright-clean and uses explicit types at the JSON boundary.
- No new public Python API surface was added; the CLI contract remains `scripts.dev_tools.validate_orchestration_artifacts`.

#### Error handling and logging

- The validator continues to fail closed on malformed JSON and unsupported namespace keys.
- No ad-hoc debug output was introduced.

### PowerShell implementation audit

#### What changed well

- The new hook is narrow by design and blocks only the four promotion-bypass tokens named in the feature docs.
- The helper structure makes the entrypoint easy to test without shelling out.

#### API and safety notes

- The hook uses `CmdletBinding()`, explicit helper names, and a deterministic `allow` or `block` JSON response.
- The token check is case-insensitive and scoped to command text inspection only, which avoids mutating or broadening the command surface.

#### Error handling and logging

- Malformed JSON in `CLAUDE_TOOL_INPUT` is surfaced explicitly as an error.
- The entrypoint returns a canonical block reason rather than silently ignoring malformed or forbidden inputs.

---

## Test Quality Audit

The automated verification evidence is strong for the delivered remediation behavior. The focused Python suite exercises the split-validator contracts directly, the CLI `--help` verification proves the artifact-type names remain unchanged, and the coverage-enabled Pytest run confirms the current `delegation_receipts.promotion.*` shape still passes.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` — verifies entrypoint re-exports, legacy receipt compatibility, additive promotion namespace acceptance, and namespace rejection behavior.
- `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py` — verifies the validator-dependent review and guardrail wording contracts still pass unchanged after the split.
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-black.2026-04-29T10-47.md` — proves the final restarted Black pass was clean.
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-ruff.2026-04-29T10-49.md` — proves the final Ruff pass was clean after the restart.
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-pyright.2026-04-29T10-51.md` — proves the final Pyright pass was clean.
- `docs/features/active/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/evidence/qa-gates/python-pytest.2026-04-29T10-52.md` — records 29 passing tests and the split-module coverage figures.

### Quality assessment prompts

- **Determinism:** The tests use repository text and synthetic JSON/command payloads only.
- **Isolation:** Each new or changed test maps to a single contract, validator branch, or hook decision.
- **Speed:** The focused Python suite completed in `0.14s`, and the PowerShell QA run completed successfully without long-running dependencies.
- **Diagnostics:** Failure messages would identify the specific missing wording fragment, unsupported key, or incorrect block message.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | The reviewed diff contains no credentials, tokens, or secret material. |
| No unsafe subprocess or command construction | ✅ PASS | The new PowerShell hook inspects attempted Bash command text; it does not construct or execute subprocess commands. |
| Input validation at boundaries | ✅ PASS | The hook validates `CLAUDE_TOOL_INPUT` as JSON, and the validator rejects unsupported `delegation_receipts` shapes explicitly. |
| Error handling remains explicit | ✅ PASS | Both the hook and the validator fail closed with explicit error text rather than broad suppression. |
| Configuration / path handling is safe | ✅ PASS | `.claude/settings.json` adds one explicit hook path and retains its schema declaration. |

---

## Research Log

No external research was required for this review. The review relied on repository-local evidence, including refreshed PR context and the feature folder’s baseline and QA artifacts.

---

## Verdict

The behavior requested by feature `#168` is present in the reviewed working tree and is supported by direct test and audit evidence. The lifecycle skill is MCP-only for agent sessions, the promotion bypass hook is registered and functioning, and the checkpoint validator now accepts the documented additive receipt namespace.

The remediation change is not yet ready for normal PR flow because the two new split modules remain below the repository target for new-module coverage. The prior 500-line production-file finding is resolved, the CLI contract is preserved, and the next review should focus only on expanded test coverage if that policy requirement remains in scope.
