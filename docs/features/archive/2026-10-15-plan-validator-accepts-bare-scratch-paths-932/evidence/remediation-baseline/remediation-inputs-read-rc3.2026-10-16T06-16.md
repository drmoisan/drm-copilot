# Remediation Cycle 3 Inputs Read

Timestamp: 2026-10-16T06-16
Task: [P0-T2]

Files read:

1. `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/remediation-inputs.2026-10-16T05-36.md`
2. `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/policy-audit.2026-10-16T05-25.md`
3. `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/code-review.2026-10-16T05-25.md`
4. `docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/feature-audit.2026-10-16T05-25.md`

In scope:

- `N-3` (Low, related, Non-blocking): G6 whitespace normalization in `_has_cross_line_presence` / `_window_join` (Python) and `hasCrossLinePresence` / `windowJoin` (TypeScript) uses each runtime's native whitespace class. Required remediation: use the shared `PLAN_WHITESPACE_CLASS` in both runtimes without a second declaration, add NEL and byte-order-mark frozen fixtures in both suites, run a discriminating corpus A/B, update the rule file, its byte-identical bundle copy, and the spec NFR-2 note, and keep coverage and file-size limits.

Declined or out of scope, with the reason stated in the inputs file:

- `fence-pattern residual`: the command extractor's fence pattern is unchanged since the merge base and shared by G1 through G10; aligning it only in the G10 modules would make G10 extraction disagree with G1-G9 extraction. It stays documented in the rule file. Not a finding.
- `U-2`: jest run from the repository root prints "Coverage data ... was not found" lines and exits 1; unrelated because it depends on the invocation directory and concerns pre-existing threshold keys, and edits to `jest.config.cjs` were restricted.
- `U-3`: the promotion path at `issue.md:5` lacks the folder date prefix; unrelated, produced by promotion tooling and shared by most active `issue.md` files.
- `CR-6`: remains declined as recorded for cycle 1.
- `CR-7`: remains declined as recorded for cycle 1.

Pending CI: AC-23 stays unchecked until CI runs `test_bundled_claude_payload_contains_all_repo_runtime_contracts` on the PR head.
