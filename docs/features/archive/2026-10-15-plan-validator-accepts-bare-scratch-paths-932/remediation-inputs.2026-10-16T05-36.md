# Remediation Inputs: plan-validator-accepts-bare-scratch-paths (Issue #932), cycle 3

Review-Verdict: PASS (0 blocking); cycle opened for one related non-blocking finding per the run rule that related findings are fixed inside the item.

- Inputs timestamp: 2026-10-16T05-36 (UTC)
- Base: `origin/main`
- Head: `95d61f2a5`
- Source review (cycle 2 re-audit, all stamped 2026-10-16T05-25):
  - policy-audit-path: docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/policy-audit.2026-10-16T05-25.md
  - code-review-path: docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/code-review.2026-10-16T05-25.md
  - feature-audit-path: docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/feature-audit.2026-10-16T05-25.md
- Author: orchestrator, transcribing the re-audit's related finding and the orchestrator's classification decisions.
- Attempt budget: this is the third and last remediation attempt the loop guard allows for this item.

## Related finding to fix in this cycle (Severity: Non-blocking)

### N-3 G6 whitespace normalization uses each runtime's native whitespace class (Low)

- Facts (from the re-audit):
  - Python normalizes G6 text with `str.split()` / `str.strip()` in `_has_cross_line_presence` and `_window_join` (`scripts/dev_tools/plan_gate_discrimination.py:258,280`).
  - TypeScript normalizes the same text with `/\s+/` and `trim()` (`extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts:345-350,394,429`).
  - Reviewer probe: Python `"a\x85b".split()` returns `['a', 'b']`; JavaScript `"a\u0085b".split(/\s+/)` returns `["ab"]`. A tracked file whose phrase contains NEL, an information separator (U+001C to U+001F), or the byte-order mark can therefore produce a different G5/G6 outcome in the two runtimes.
  - Cycle 2 introduced `PLAN_WHITESPACE_CLASS` (Python `scripts/dev_tools/plan_gate_scratch.py:79-81`, TypeScript `extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts:77`), the exact intersection of the two native classes, and applied it to G10 only.
- Required remediation (orchestrator decision: align the code, do not merely document):
  - Make the G6 normalizers in both runtimes (the single-line test and the window join) use the same explicit whitespace class as G10. Reuse the existing `PLAN_WHITESPACE_CLASS` definition rather than declaring a second copy; if import direction makes direct reuse unsuitable, place the shared class in one module per runtime and keep the existing Python test that pins the TypeScript string to the Python string covering the class wherever it lives.
  - Add frozen-expectation fixtures to both the Python and TypeScript G6 literal suites that would fail before the change: at least one NEL case and one byte-order-mark case, covering both directions of the divergence.
  - Confirm no G1-G9 result change on the existing plan corpus with a discriminating A/B probe, as done for U-1 in cycle 2.
  - Update the rule-file parity paragraph in `.claude/rules/plan-acceptance-gates.md`, its bundled copy (byte-identical), and the spec NFR-2 note so they state that G6 normalization uses the shared class. Keep the existing statement of the fence-pattern residual.
  - Keep 100% line and branch coverage on both G10 modules, do not reduce coverage of changed lines, and keep every changed file at or under 500 lines.

## Declined or out of scope (no action in this item)

- Fence-pattern residual (code review "Design and Correctness Notes"): the command extractor's fence pattern `^\s*` plus three backticks is unchanged since the merge base and is shared by G1 through G10. Aligning it only in the G10 modules would make G10 extraction disagree with G1-G9 extraction. It remains documented in the rule file. Not a finding.
- U-2: jest run from the repository root prints "Coverage data ... was not found" lines for pre-existing per-file threshold keys and exits 1; the package script run exits 0. Unrelated: it depends on the invocation directory and concerns threshold keys that pre-date this branch, and the coordinator restricted this item's edits to `extensions/drm-copilot/jest.config.cjs`.
- U-3: the promotion path at `issue.md:5` lacks the folder's date prefix. Unrelated: produced by the promotion tooling and shared by most active `issue.md` files.
- CR-6 and CR-7 remain declined as recorded for cycle 1.

## Pending CI (not a remediation item)

- AC-23 stays unchecked until CI runs `test_bundled_claude_payload_contains_all_repo_runtime_contracts` on the PR head. Keep the rule-file bundle copy byte-identical.
