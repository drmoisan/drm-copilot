# Code Review: orchestrator-state-routing-contract-mismatch (#230)

**Review Date:** 2026-06-24
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-06-24-orchestrator-state-routing-contract-mismatch-230`
**Feature Folder Selection Rule:** Selected by issue-number suffix match (`-230`) against the branch name `fix/orchestrator-state-routing-contract-mismatch-230` and the material scoping-doc change (`spec.md`).
**Base Branch:** `main` (merge-base `258aa903542346cc534c03da39e4b938223c1f2d`)
**Head Branch:** `fix/orchestrator-state-routing-contract-mismatch-230` (`4bcc1c5f6dc8e6d89fe23790439f8a149ad8639f`)
**Review Type:** Initial review

---

## Executive Summary

The change reconciles the orchestrator-state routing matrix with the actual Claude Code runtime inventory and documents a receipt-emission contract so the strict completion gate (`validate_orchestration_artifacts` with `require_complete: true`) is satisfiable with truthful receipts. On the production side the change is data and documentation only: `config/orchestration-routing.json` (and its bundled mirror) drop the stale names `feature-reviewer`, `commit-steward`, `orchestrator-workflow`, `repo-automation-adapter`, and `collect_commit_context`, and rename the review agent to `feature-review` across all three routes. `.claude/skills/orchestrate/SKILL.md` (and its mirror) gain a `## Routing-Contract Receipt Emission` section describing the `delegation_receipts[]`, `skill_receipts[]`, and `mcp_call_receipts[]` shapes. Two Python test files change: a new byte-identity guard test for the two config copies, and a single fixture-value update in the existing routing-contract module.

**What changed:**
- `config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json`: per-route `required_agents` / `required_skills` / `required_mcp_tools` value lists corrected; structure unchanged; copies remain byte-identical (sha256 `088130c0...`).
- `.claude/skills/orchestrate/SKILL.md` and its mirror: +62 lines documenting the three receipt-array shapes the validator reads.
- `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` (new, 56 lines): asserts the two config copies are byte-identical.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py`: fixture `skill_source` `orchestrator-workflow` -> `orchestrate` (1 line).
- No validator source (`scripts/dev_tools/_orchestrator_state_routing.py`, `validate_orchestrator_state.py`, or bundled mirrors) changed.

**Top 3 risks:**
1. Config drift between the canonical and bundled copies in future edits. This is the precise risk the new parity test mitigates; it is now covered.
2. Documented receipt shapes diverging from the validator's accepted shapes. Verified: the SKILL.md text matches `_receipt_skills` (`required is True`, non-empty `evidence`), `_mcp_tools` (`ok is True`, non-empty `evidence`), and `_receipt_agents` (non-empty `agent_name`) exactly.
3. The Codex-era payload (`extensions/.../codex-and-agents-customizations/.agents/skills/...`) still references the stale names; this is documented as intentionally out of scope and does not affect the Claude Code runtime.

**PR readiness recommendation:** **Go** — The change is minimal, data-and-documentation only on the production side, fully verified against the validator's actual receipt-shape logic, and all toolchain and coverage gates pass.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `config/orchestration-routing.json` | per-route required lists | Stale names removed; `feature-review` rename applied across all three routes. | None. | Aligns the matrix with the real `.claude/agents/`, `.claude/skills/`, and registered MCP tools. | `git diff 258aa90..4bcc1c5 -- config/orchestration-routing.json`; `grep` for stale tokens returns no matches. |
| Info | `extensions/drm-copilot/resources/config/orchestration-routing.json` | whole file | Bundled mirror byte-identical to canonical. | None. | Prevents canonical/bundled validation divergence. | `sha256sum` match `088130c0...`; `cmp` identical. |
| Info | `.claude/skills/orchestrate/SKILL.md` | `## Routing-Contract Receipt Emission` | Documented receipt shapes match validator-accepted shapes exactly. | None. | Ensures `require_complete: true` is satisfiable with truthful receipts. | SKILL.md diff cross-checked against `_receipt_skills`/`_mcp_tools`/`_receipt_agents` lines 63-118 of `_orchestrator_state_routing.py`. |
| Info | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` | whole file | Skill mirror byte-identical to canonical. | None. | Keeps the bundled skill documentation in lockstep. | `cmp` identical. |
| Info | `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` | full file | New byte-identity guard test; deterministic, no temp files, clear failure message. | None. | Closes the previously uncovered parity gap (existing bundle-parity test does not cover this config). | `poetry run pytest <file> -q` -> pass. |
| Info | `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` | `_build_complete_large_state` | Fixture `skill_source` updated to `orchestrate` to track the corrected matrix. | None. | Keeps the dynamically built fixture consistent with the corrected routing matrix. | Diff line 57; module passes. |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The fix corrects data the validator already reads rather than altering validator logic, which keeps the strict-vs-default contract intact and limits blast radius. Verified: validator source is unchanged (`git diff --name-only` over the four validator paths produced no output).
- The new parity test addresses a real gap: the pre-existing `test_validate_orchestration_artifacts_bundle_parity.py` covers only the five validator Python modules, not `orchestration-routing.json`. The new test makes future config drift a test failure.
- The byte-level comparison (`read_bytes()`) is the correct choice; it catches trailing-newline and encoding differences a text compare would miss, as the comment notes.

#### Typing and API notes

- No new public Python API surface was added. The new test uses `from __future__ import annotations` and an explicit `-> None` annotation. No `Any` usage introduced.

#### Error handling and logging

- No production error-handling paths changed. The test relies on a single `assert` with an actionable failure message naming both file paths and the corrective action. No logging changes.

---

## Test Quality Audit

The verification evidence is present and consistent. The new parity test directly exercises the byte-identity invariant; the corrected routing matrix is exercised by the existing routing-contract module (positive completed-large/small/remediation acceptance plus negative missing/renamed receipt tests). Coverage evidence (`coverage-comparison.md`, `artifacts/python/lcov.info`) confirms no regression and repo-wide line coverage of 85.48% with 85.97% branch coverage.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` — verifies the two config copies are byte-identical; deterministic, no temp files; clear failure message. No gap.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` — verifies the corrected matrix passes `validate_routing_contract` and that missing/renamed receipts fail with the exact validator messages. Fixture updated to track the corrected `skill_source`.
- `docs/features/active/2026-06-24-orchestrator-state-routing-contract-mismatch-230/evidence/qa-gates/coverage-comparison.md` — proves no coverage regression; production routing module unchanged at 89%.
- `docs/features/active/2026-06-24-orchestrator-state-routing-contract-mismatch-230/evidence/qa-gates/qa-{black,ruff,pyright,pytest}.md` — record EXIT 0 for each toolchain stage.
- `artifacts/python/lcov.info` — repo-wide line coverage 85.48%.

### Quality assessment prompts

- **Determinism:** Tests read in-repo files and build dict fixtures; no wall-clock, RNG, or network.
- **Isolation:** Each test targets one behavior (config byte-identity; one validator behavior per existing test).
- **Speed:** Targeted run `8 passed in 0.05s`.
- **Diagnostics:** The parity test failure message names both file paths and the remediation step; validator negative tests assert exact per-violation strings.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff contains only config name lists, Markdown documentation, and test code; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | New test uses `pathlib` only; no subprocess or shell invocation. |
| Input validation at boundaries | N/A | No new runtime input boundary; the validator (unchanged) already validates receipt shapes. |
| Error handling remains explicit | ✅ PASS | Validator's per-violation error strings preserved; no production error path changed. |
| Configuration / path handling is safe | ✅ PASS | Test resolves repo root via `Path(__file__).resolve().parents[3]`; no absolute or user-controlled paths. |

---

## Research Log

No external research was required. All evidence is derivable from the branch diff, the in-repo validator source, the bundled templates, and the feature-folder evidence artifacts.

---

## Verdict

The change is ready for normal PR flow. It is a minimal, well-scoped correction: production-side changes are limited to JSON config data and skill documentation, the validator logic is provably unchanged, the documented receipt shapes match the validator's accepted shapes exactly, the two config copies are byte-identical and now guarded by a new test, and all Python toolchain and coverage gates pass with no regression. This verdict is consistent with the Findings Table (no Blocker/Major) and the Go recommendation above.
