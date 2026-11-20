# Remediation Inputs — Issue #1158 — Review R1

- Timestamp: 2026-11-14T11-44
- Issue: #1158
- Branch: feature/test-execution-policy-machine-lock-1158
- PR: none yet (base main)
- Reviewed head: c03f350da362989a3eb4b2153ec9cff5fef45447
- Merge base: add7d747886ce893356b63de2941435f2895b345
- Opened by: feature review (first review, S7)
- Review-Verdict: REMEDIATION_REQUIRED
- Remediation-Path: full
Remediation-Mode: design

## Review Artifacts

- policy-audit: docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/policy-audit.2026-11-14T11-44.md
- code-review: docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/code-review.2026-11-14T11-44.md
- feature-audit: docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/feature-audit.2026-11-14T11-44.md

## Context

Code, tests, coverage, file size, evidence location and tier classification comply at the reviewed head. Two documentation findings remain. The path is full because F1 touches lines inside process-reduction ledger regions (entry 0001 stored patch), which requires regenerating ledger records, and F2 changes the text of a user-story acceptance criterion.

## Findings

### F1 — Agent and skill instructions still direct pytest without the launcher

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: the fix is a text change in files on the branch plus mirror, Codex-variant and ledger regeneration with repository tools; no external party or owner decision is needed.
- Finding-Scope: design
- Location: `.claude/agents/atomic-executor.md` line 81 and its bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md` line 81; `.codex/agents/atomic-executor.toml` and the five `atomic-executor-c*.toml` variants line 92; `.claude/skills/python-qa-gate/SKILL.md` line 33, `.agents/skills/python-qa-gate/SKILL.md` line 33 and their bundle copies.
- Evidence: the `## Toolchain Commands` Python line lists `poetry run pytest -n auto`, and `python-qa-gate` step 4 reads `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov`. The branch removed `Bash(poetry run pytest *)` from the executor allowlist, moved the TypeScript line of the same list to the launcher, and added a `python-qa-gate` paragraph (line 81) saying the pytest gate runs through the launcher. A real-process probe of the branch hook denies `env -u VIRTUAL_ENV poetry -C /abs/wt run pytest -n auto` and `poetry run python -m pytest -q` with `TEST_EXECUTION_POLICY_BLOCKED`. Both stale lines also appear in `docs/engineering/process-reductions/patches/0001-parallel-only-test-gates.patch`.
- Required: replace both commands with the launcher form (`env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest`, with the coverage extras for step 4) in every copy; regenerate the Codex variants (generator `--check` must pass); regenerate the ledger records whose regions contain these lines under the D29 rule; consider a `parallel-gate-wording.Tests.ps1` row forbidding the direct form in these sections. Rerun the wording, brief, push-down contract and ledger chain suites through the launcher and record new evidence.

### F2 — User-story AC4 registration criterion not aligned with spec D31

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: spec decision D31 already records the registration design and spec AC4 already carries the alternative; a planner revision inside the item can align the user-story text without a new owner decision.
- Finding-Scope: design
- Location: `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/user-story.md` line 66.
- Evidence: the criterion requires standalone entries in the Bash and MCP groups of `.claude/settings.json` and `.codex/config.toml`. After #1159 merged, the hook is a member of the four `pretooluse-dispatch.json` registries, and the Codex dispatcher timeout rose from 690 to 720; `test-execution-policy.Registration.Tests.ps1` (19 cases) and the guard-completeness and no-Python suites pass. The executor left the item unchecked for this reason (`evidence/qa-gates/self-review.2026-11-14T11-28.md`).
- Required: an atomic-planner revision rewrites the criterion to match spec D31 branch B (registry membership for the three tool names, Codex dispatcher timeout equal to the member sum), and in the same revision corrects spec line 343 from `0011-local-lane-exclusion.md` to `0012-local-lane-exclusion.md`; then check the criterion off against the existing Registration test evidence.

## Coordinator-Directed Scope (orchestrator decision ORCH-D6)

Added by the orchestrator, not by the reviewer; it is not a review finding and is not counted in the review verdict. The coordinator classified it as a related finding to resolve inside this item (OD-8).

### C1 — No scoped parallel Pester entry point

- Remediability: autonomous
- Finding-Scope: design
- Evidence: `Invoke-PoshQCParallelTest` cannot be scoped to a folder or a list of test files, so runs #1179 and #1162 each fell back to scoped single-process Pester runs (a consumer-suite check, a fails-without-the-fix proof of one test, and a post-sync check), against the parallel-only owner directive (OD-5).
- Required: add a minimal, PowerShell-only scoped parallel entry point that runs a given folder or file list through the same parallel runner (`Invoke-PoshQCParallelTest` or a thin parameter extension of it), covered by Pester tests; reach it through the test-execution launcher so the machine lock and hook apply; state in the policy text (the test-execution-policy skill, the execution-environment brief `## Test Isolation Checks` and `## PowerShell Route and PoshQC MCP Limits`, and the atomic-plan-contract `## Test Cadence (Mandatory)` task-check bullet, in every mirrored copy) that targeted task checks and red-proofs use it instead of a single-process run.

## Acceptance criteria affected

- user-story.md line 66: unchecked; check off after F2.
- spec.md line 348 (Definition of Done, all documented environments): pending-CI, checked off at S9.
- spec.md line 352 (telemetry or logging): not applicable; stays unchecked.
