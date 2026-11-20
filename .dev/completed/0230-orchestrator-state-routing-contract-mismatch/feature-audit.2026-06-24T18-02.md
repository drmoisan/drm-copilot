# Feature Audit: orchestrator-state-routing-contract-mismatch (#230)

**Audit Date:** 2026-06-24
**Feature Folder:** `docs/features/active/2026-06-24-orchestrator-state-routing-contract-mismatch-230`
**Base Branch:** `main`
**Head Branch:** `fix/orchestrator-state-routing-contract-mismatch-230`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `e93a0fd4ccf4f39f946f04fa70b9a56f4ed6f22f` resolved as `origin/main`)
- **Head branch/commit:** `fix/orchestrator-state-routing-contract-mismatch-230` (commit `4bcc1c5f6dc8e6d89fe23790439f8a149ad8639f`)
- **Merge base:** `258aa903542346cc534c03da39e4b938223c1f2d`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-06-24-orchestrator-state-routing-contract-mismatch-230/evidence/**`
  - Additional evidence: direct `git diff 258aa90..4bcc1c5`, `sha256sum`/`cmp` of config copies, validator source inspection, `poetry run pytest` targeted re-run, `artifacts/python/lcov.info`
- **Feature folder used:** `docs/features/active/2026-06-24-orchestrator-state-routing-contract-mismatch-230`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`; per the work-mode contract, `full-bug` resolves the AC source to `spec.md` only.
- **Scope note:** Audit performed over the full branch diff `258aa90..4bcc1c5` against `main`. No scope-narrowing accepted. Only Python has changed code/test files; JSON config changed but is not coverage-measured.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — only source (work mode `full-bug`)

### Acceptance criteria

1. `config/orchestration-routing.json` references only real agent, skill, and MCP-tool names for all three routes: `required_agents` use `feature-review` (not `feature-reviewer`) and contain no `commit-steward`; `required_skills` contain no `orchestrator-workflow` or `repo-automation-adapter`; `required_mcp_tools` contain no `collect_commit_context`. The per-route lists match the target values in the Proposed Fix section.
2. `extensions/drm-copilot/resources/config/orchestration-routing.json` is byte-identical to `config/orchestration-routing.json`.
3. A guard test asserts the two config copies are identical and passes.
4. `.claude/skills/orchestrate/SKILL.md` instructs the orchestrator to emit `skill_receipts[]` entries (`skill` non-empty string, `required: true`, `evidence` non-empty string), `mcp_call_receipts[]` entries (`tool` non-empty string, `ok: true`, `evidence` non-empty string), and `delegation_receipts[]` entries supplying `agent_name`, for the retained required names of each route.
5. A regression test confirms a truthful completed-large checkpoint passes `validate_routing_contract` (and `validate_orchestration_artifacts` with `require_complete: true`) with the corrected names, returning zero routing-contract errors.
6. Negative tests confirm that missing or renamed receipts fail with the validator's clear messages (`Checkpoint missing required agent receipt: <name>.`, `Checkpoint missing required skill receipt: <name>.`, `Checkpoint missing successful MCP receipt: <name>.`).
7. No behavior change to `scripts/dev_tools/_orchestrator_state_routing.py` logic beyond reading corrected data; the module source is unchanged and its bundled mirror is unchanged.
8. The full Python toolchain passes in one clean pass: Black, Ruff, Pyright, Pytest with line coverage >= 85% and branch coverage >= 75% and no regression on changed lines.
9. The original repro no longer occurs: a truthfully completed `large`-route orchestration produces a checkpoint that passes `require_complete: true`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Config names corrected across all three routes | PASS | Diff removes `feature-reviewer`, `commit-steward`, `orchestrator-workflow`, `repo-automation-adapter`, `collect_commit_context` and renames to `feature-review` in `small`/`large`/`remediation`. Stale-token grep returns no matches. Per-route lists match the spec Proposed Fix target values. | `git diff 258aa90..4bcc1c5 -- config/orchestration-routing.json`; `grep -E "feature-reviewer\|commit-steward\|orchestrator-workflow\|repo-automation-adapter\|collect_commit_context" config/orchestration-routing.json` | Verified against the target lists in spec.md lines 99-114. |
| 2 | Bundled mirror byte-identical to canonical | PASS | `sha256` both = `088130c04ef1bc7c653049fca5f7430aefc5a488d01d03053b54805a25a33e1c`; `cmp` reports identical. Matches the AC-cited `088130c0...`. | `sha256sum config/orchestration-routing.json extensions/drm-copilot/resources/config/orchestration-routing.json`; `cmp <both>` | — |
| 3 | Guard test asserts identity and passes | PASS | New `test_orchestration_routing_config_parity.py::test_canonical_and_bundled_routing_config_are_byte_identical` passes. | `poetry run pytest tests/scripts/dev_tools/test_orchestration_routing_config_parity.py -q` | Part of `8 passed in 0.05s`. |
| 4 | SKILL.md documents the three receipt shapes for retained names | PASS | New `## Routing-Contract Receipt Emission` section specifies `skill_receipts[]` (`skill`, `required: true`, `evidence`), `mcp_call_receipts[]` (`tool`, `ok: true`, `evidence`), and `delegation_receipts[]` (`agent_name`). Shapes cross-checked against `_receipt_skills`/`_mcp_tools`/`_receipt_agents` and match exactly. | `git diff 258aa90..4bcc1c5 -- .claude/skills/orchestrate/SKILL.md`; inspection of `scripts/dev_tools/_orchestrator_state_routing.py` lines 63-118 | Bundled skill mirror `cmp` identical. |
| 5 | Regression test: completed-large checkpoint passes routing contract with corrected names | PASS | `test_validate_orchestrator_state_routing_contract.py` module passes; fixture built from `load_routing_matrix()` auto-tracks the corrected matrix; `skill_source` fixture updated to `orchestrate`. | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py -q` | Part of `8 passed in 0.05s`; 1169 passed at repo level per evidence. |
| 6 | Negative tests fail with exact validator messages | PASS | Existing module includes missing/renamed agent, skill, and MCP receipt negative tests asserting the exact per-violation strings; module passes. | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py -q` | Validator message strings unchanged (source unchanged, AC 7). |
| 7 | No validator logic change; module source and bundled mirror unchanged | PASS | `git diff --name-only` over `scripts/dev_tools/_orchestrator_state_routing.py`, `validate_orchestrator_state.py`, and their two bundled mirrors produced no output. | `git diff --name-only 258aa90..4bcc1c5 -- scripts/dev_tools/_orchestrator_state_routing.py scripts/dev_tools/validate_orchestrator_state.py extensions/.../_orchestrator_state_routing.py extensions/.../validate_orchestrator_state.py` | Confirms the fix is data/doc only. |
| 8 | Full Python toolchain clean pass; coverage thresholds met; no changed-line regression | PASS | Black/Ruff/Pyright EXIT 0; Pytest 1169 passed; branch 85.97% (>= 75%); repo-wide line 85.48% per `lcov.info` (>= 85%); no production Python line changed so no changed-line regression. | `poetry run black .`; `poetry run ruff check .`; `poetry run pyright`; `poetry run pytest --cov --cov-branch --cov-report=term-missing` | The pytest term TOTAL line value is 83% (pre-existing); lcov repo-wide line is 85.48%. Both exceed the 80% remediation threshold; lcov meets the 85% uniform-tier line threshold. No production line changed. |
| 9 | Original repro resolved: completed-large checkpoint passes `require_complete: true` | PASS | The regression test exercises `validate_orchestrator_state_text(..., require_complete=True)` against a completed-large checkpoint built from the corrected matrix and returns zero errors; corrected matrix + documented receipt shapes make the gate satisfiable. | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py -q` | Verified by the same passing module covering the strict-completion path. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 9 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. On the next live completed `large`-route orchestration, run `validate_orchestration_artifacts` with `require_complete: true` against the live checkpoint to confirm the gate passes outside the test fixtures (noted as post-fix monitoring in spec.md; not a merge blocker).
2. Optional (out of scope for #230): align the Codex customization payload names with the Claude Code runtime, or document the intentional divergence.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, all nine criteria evaluate to PASS and are represented as markdown checkboxes in `spec.md`. All nine were already marked `[x]` by the executor; this review independently verified each and confirms the checked state is correct. No checkbox state required modification.

### AC Status Summary

- Source: `spec.md`
- Total AC items: 9
- Checked off (delivered): 9
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 9 | 9 | 0 | Checkbox-backed; all verified PASS by this review; already checked by executor, no change needed |

No source-file checkbox change was made because all nine items were already checked `[x]` and this review confirms each is correctly PASS.
