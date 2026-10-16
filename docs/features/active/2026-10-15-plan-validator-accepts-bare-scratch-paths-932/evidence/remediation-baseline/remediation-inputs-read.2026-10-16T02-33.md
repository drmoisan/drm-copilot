# Remediation Inputs Read (Remediation Cycle 1)

Timestamp: 2026-10-16T02-33
Task: [P0-T2]

Files read:

1. `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/remediation-inputs.2026-10-16T01-52.md`
2. `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/policy-audit.2026-10-16T01-52.md`
3. `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/code-review.2026-10-16T01-52.md`
4. `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/feature-audit.2026-10-16T01-52.md`

In-scope IDs (this cycle):

- `RF-1` (code-review CR-1, policy audit PA-1): declare CommonJS `sourceType` and Node globals for `**/*.cjs` in `extensions/drm-copilot/eslint.config.mjs`; rerun original `[P3-T6]`; check it off. Blocking, autonomous.
- `CR-2`: remove the unreachable heading and task-line continuation conditions in both runtimes; relabel the stop fixtures; pin absorb behaviour.
- `CR-3`: correct rule-file lines 15, 17, and 289 to state G1 through G9 plus document-level G10; keep the bundle copy byte-identical.
- `CR-4`: align line splitting on CR LF, LF, and CR through one shared splitter per runtime; add form-feed and U+2028 fixtures; document the normalization residual.
- `CR-5`: document the issue-token-after-definition false-negative class in the rule file, its bundle copy, and `spec.md`.

Declined IDs (orchestrator decision, as stated in the plan's Cycle Scope):

- `CR-6`: declined because deleting the stale research duplicate conflicts with the run rule "Delete nothing".
- `CR-7`: declined because converting the TypeScript fixtures to `it.each` is prohibited by original plan task P1-T5.
