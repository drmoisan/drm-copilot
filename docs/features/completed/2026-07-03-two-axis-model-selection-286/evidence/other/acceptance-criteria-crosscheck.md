# Acceptance-Criteria Cross-Check

Timestamp: 2026-07-03T16-43

Work Mode: full-feature. AC sources: `spec.md` and `user-story.md` (authoritative); `issue.md` carries an early draft mirrored for completeness.

Every acceptance criterion maps to at least one completed task and a named evidence artifact. No AC is unmapped.

## WS1 — Model-selection machinery

| AC | Satisfying tasks | Evidence artifact |
|---|---|---|
| `route` not a model-selection input; `complexity_band` sole input | P1-T1, P1-T4, P7-T1, P7-T5, P8-T8 | `evidence/regression-testing/route-not-model-input.md` |
| `model_policy` + `model_budget` config (default `disabled`); bundled byte-identical | P2-T1, P2-T2, P2-T3, P2-T4 | `evidence/qa-gates/config-parity.md` |
| `compute_complexity_floor` deterministic; each `[floor]`→C3; max; never exceed C3; C4 never floor-forced; band >= floor | P1-T1, P1-T2, P1-T3, P1-T7 | `evidence/regression-testing/determinism-and-floor-invariants.md` |
| `resolve_delegation_model` deterministic; base/`available`/`disabled` clamp/`preferred` overlay; executor & pr-author C3 stay opus | P1-T4, P1-T5, P1-T6 | `evidence/regression-testing/determinism-and-floor-invariants.md`, `evidence/qa-gates/final-pytest-coverage.md` |
| Complexity + model-routing validators pass well-formed, fail closed with literal messages; lacking-fields validate unchanged | P3-T1, P3-T2, P3-T3, P3-T4, P3-T6 | `evidence/qa-gates/final-pytest-coverage.md`, `evidence/regression-testing/backward-compat-checkpoints.md` |
| Both validators wired via key-gated blocks in `validate_orchestrator_state_text`; not in `REQUIRED_STATE_KEYS` | P3-T5, P3-T6 | `evidence/regression-testing/backward-compat-checkpoints.md` |
| `orchestrate` + `epic-orchestrate` document model selection + `fable_policy` kickoff marker; name both reference impls | P7-T1, P7-T5 | `evidence/qa-gates/skills-parity.md` |

## WS2 — commit-message agent

| AC | Satisfying tasks | Evidence artifact |
|---|---|---|
| `.claude/agents/commit-message.md` exists, `model: haiku`, read-only tools, valid frontmatter | P5-T1, P5-T5 | `evidence/qa-gates/agents-parity.md`, `evidence/other/agent-frontmatter-smoke-check.md` |
| `.claude/settings.json` authorizes `Agent(commit-message)` | P6-T2, P6-T4 | `evidence/qa-gates/orchestrator-allowlist-parity.md` |
| Both commit points delegate message text to `Agent(commit-message)`; `git commit` stays on orchestrator | P7-T2, P7-T3 | `evidence/qa-gates/skills-parity.md` |

## WS3 — human-exception-runbook agent

| AC | Satisfying tasks | Evidence artifact |
|---|---|---|
| `.claude/agents/human-exception-runbook.md` exists, `model: sonnet`, `Write(<FEATURE>/runbooks/**)`, valid | P5-T3, P5-T5 | `evidence/qa-gates/agents-parity.md`, `evidence/other/agent-frontmatter-smoke-check.md` |
| `.claude/settings.json` authorizes `Agent(human-exception-runbook)` | P6-T2, P6-T4 | `evidence/qa-gates/orchestrator-allowlist-parity.md` |
| Exception path delegates authoring to `Agent(human-exception-runbook)`; orchestrator records `runbook_path` | P7-T4 | `evidence/qa-gates/skills-parity.md` |

## Cross-cutting

| AC | Satisfying tasks | Evidence artifact |
|---|---|---|
| All new fields additive/optional; existing routes and checkpoints validate unchanged | P2-T1, P2-T2, P3-T5, P3-T6 | `evidence/regression-testing/backward-compat-checkpoints.md` |
| Bundle sync complete; pytest and Pester green | P8-T4, P8-T5, P8-T6 | `evidence/qa-gates/final-pytest-coverage.md`, `evidence/qa-gates/final-bundle-sync-parity.md`, `evidence/qa-gates/final-pester.md` |

## Additional (checkpoint-shape prose, spec Definition of Done)

| Item | Satisfying tasks | Evidence artifact |
|---|---|---|
| `.claude/rules/orchestrator-state.md` extended with additive scope/enforcement subsections for the two arrays and `model_budget` | P4-T1, P4-T2, P4-T3 | `evidence/qa-gates/rules-parity.md` |
| File-size limit (<= 500 lines) for all feature files | P8-T7 | `evidence/qa-gates/file-size-limit.md` |

## Determination

All acceptance criteria in `spec.md` (WS1, WS2, WS3, Cross-cutting), `user-story.md`, and `issue.md` map to completed tasks with named evidence. No unmapped AC remains; completion is not blocked.
