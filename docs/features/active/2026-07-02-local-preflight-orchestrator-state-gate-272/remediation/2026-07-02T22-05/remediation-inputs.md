# Remediation Inputs: local-preflight-orchestrator-state-gate (#272)

**Timestamp:** 2026-07-02T22-05
**Cycle:** 2 (entry)
**Triggering source:** orchestrator-discovered defect, found while performing the "PR Creation Delegation" preflight step (AC #7) that this feature itself specifies. Not sourced from a `feature-review` audit artifact — the prior re-audit (`audit/2026-07-02T21-40/code-review.md`, `audit/2026-07-02T21-40/feature-audit.md`, `audit/2026-07-02T21-40/policy-audit.md`) reported zero blocking findings, but did not exercise the preflight check against a realistic, in-flight (pre-PR-creation) checkpoint. This finding is recorded here per the orchestrate skill's remediation-loop contract so it goes through the same governed plan -> preflight -> execute -> reaudit cycle as a review-sourced finding.

**Work mode:** `full-bug`. AC source: `spec.md` `## Acceptance Criteria`.

---

## Blocking Findings Requiring Remediation

### 1. [Blocking] `--require-complete` is structurally impossible to satisfy before `gh pr create` is ever called, permanently deadlocking the very action the hook is supposed to gate

**Files:**
- `.claude/hooks/enforce-pr-author-skill.ps1` (`Invoke-OrchestratorStatePreflight`, default `$Invoker`)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` (byte-identical mirror)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` (header-preserving mirror)
- `.claude/skills/orchestrate/SKILL.md` (`## PR Authoring (pr-author Handoff)`, step 2: orchestrator-side `pr_author_preflight`)
- `.claude/agents/orchestrator.md` (`## PR Creation Delegation`)

**Expected behavior:** The local preflight check should verify that the orchestration checkpoint reflects legitimate, completed upstream work (promotion, planning, execution, review) before authorizing `gh pr create`/`gh pr edit --body*`, and should be satisfiable by a real, in-flight orchestration session at the exact point it is about to delegate to `Agent(pr-author)` for the *first* PR creation of the branch.

**Actual behavior (independently verified by direct command execution against the real, current checkpoint):**

```
$ poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-complete
Checkpoint completion validation failed: pr_gate must be an object with keys: pr_number, pr_url, head_branch, head_sha.
Checkpoint completion validation failed: ci_gate must be an object with keys: conclusion, head_sha, verified_at.
Checkpoint missing required agent receipt: pr-author.
(exit code 1)
```

Reading `scripts/dev_tools/_orchestrator_state_routing.py` confirms this is not a fixable-by-better-checkpoint-authoring problem, it is structural:

- `_validate_completion_ci_gate` requires `state["ci_gate"]["conclusion"] == "success"`. `ci_gate` is populated by orchestrate/SKILL.md's own "Step S9 — CI Green Gate," which the same skill file documents runs *after* `S8_create_pr`. CI cannot run against a PR that does not exist yet.
- `validate_completion_pr_gate` (active whenever the selected route's `requires_pr_gate` is `true`, which is the case for the `large` route this feature itself used) requires a populated `pr_gate` object containing `pr_number`/`pr_url`/`head_branch`/`head_sha` — values that literally do not exist until *after* `gh pr create` succeeds.
- `validate_routing_contract` requires a delegation receipt for every `required_agents` entry of the selected route, which for the `large` route includes `pr-author` itself — a receipt that can only be recorded *after* `Agent(pr-author)` has already run.

Consequently: for any real orchestration session using the `large` route (or any route with `requires_pr_gate: true`), `--require-complete` **cannot pass** at the moment the hook/preflight is invoked (immediately before the first `gh pr create` call), because three of its required conditions (`ci_gate`, `pr_gate`, the `pr-author` receipt) can only become true *as a consequence of* the very action the check is gating. This is not a transient gap that closes once "the orchestrator does its job properly" — it is a logical impossibility for the first PR-creation attempt on any branch, for every future feature that goes through this hook. The bug this feature was created to fix (a validation gate that can never meaningfully pass or fail) has been replaced with a validation gate that can never pass at all, which is a more severe regression: the original CI gate was an inert no-op; this hook-level gate is a hard, permanent block on legitimate PR creation.

**Root cause:** `spec.md` and the executed implementation reused the exact `--require-complete` invocation and the exact `$Invoker`-seam pattern from the pre-existing `.claude/hooks/validate-orchestrator-output.ps1` (a `SubagentStop` hook that fires rarely and was not independently exercised against a realistic in-flight checkpoint either) without verifying that `--require-complete`'s semantics — full lifecycle completion, including post-PR-creation CI-green and PR-gate evidence — are compatible with being invoked *before* PR creation. Neither the original feature-review (`audit/2026-07-02T20-15/policy-audit.md`/`audit/2026-07-02T20-15/code-review.md`) nor the remediation-cycle-1 re-audit (`*.2026-07-02T21-40.md`) exercised the hook or the orchestrator-side preflight against a real, in-flight (pre-PR) checkpoint to confirm the "allow" path is reachable in practice; both reviews' manual-validation evidence (`evidence/qa-gates/manual-validation-allow.md`) explicitly stubbed `Invoke-OrchestratorStatePreflight`'s return value rather than exercising the real default `$Invoker` against a realistic checkpoint, which is exactly why this defect was not caught earlier.

**Verification command:**
```bash
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-complete
```
Run against the real, current, in-flight checkpoint for this very feature (a `large`-route session that has completed promotion, research, spec, planning, execution, and review, and is about to delegate to `pr-author` for the first time) — this is as favorable a real-world checkpoint as will ever exist at this point in the lifecycle, and it still fails on exactly the three structurally-impossible-to-satisfy-pre-PR conditions above.

**Acceptance for this remediation item:** The preflight check used by (a) `Invoke-OrchestratorStatePreflight` in all three hook copies and (b) the orchestrator's own `pr_author_preflight` step must be satisfiable by a real, in-flight checkpoint immediately before the *first* `gh pr create` call of a branch, while still meaningfully rejecting a missing/malformed checkpoint or a checkpoint that skipped required upstream work (promotion, planning, execution, review — i.e., steps 5-8). It must not require `ci_gate`, `pr_gate`, or a `pr-author` delegation receipt to already exist, because those cannot exist before the gated action runs. The existing `--require-complete` full-lifecycle semantics (including `ci_gate`/`pr_gate`/full routing-contract receipts) must remain available and unchanged for contexts where they are structurally satisfiable (e.g., a true final-completion/DONE check performed after PR creation and CI have already run) — this remediation must not weaken or remove that check for those contexts, only add or select a distinct, pre-PR-appropriate check for the hook/preflight use case.

**Evidence pointer:** This finding; independently reproduced by the orchestrator via direct CLI execution against the real checkpoint at `artifacts/orchestration/orchestrator-state.json` (not a fixture).

---

## Do Not Do

- Do not weaken, remove, or bypass `--require-complete`'s existing full-lifecycle semantics (`ci_gate`, `pr_gate`, full routing-contract receipts) — those remain correct and necessary for a true final-completion check; this remediation must introduce or select a *distinct* check for the pre-PR-creation use case, not degrade the existing one.
- Do not "fix" this by hard-coding the hook to always allow `gh pr create`/`gh pr edit` (that reintroduces the original bypass-path bug #272 was opened to close).
- Do not fix this by stubbing/mocking the real checkpoint in production code paths (only test code may mock `$Invoker`).
- Do not remove the `pr_author_preflight` checkpoint-recording concept; adjust what it validates, not whether it exists.
- Do not touch `ci_gate`/`pr_gate` semantics used elsewhere in `orchestrator.md` (Step S9, PR Creation Gate condition 6) — those remain correct for their existing, post-PR-creation purpose.
- Do not delete or rename the real, live `artifacts/orchestration/orchestrator-state.json` checkpoint during any verification step.

---

## Handoff

Per `remediation-handoff-atomic-planner`, this file is authored at cycle-2 entry alongside a corresponding `remediation/2026-07-02T22-05/remediation-plan.md` (to be authored by `atomic-planner`). This delegation does not author the remediation plan itself; it hands off findings only.
