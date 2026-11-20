# Remediation Inputs: plan-validator-accepts-bare-scratch-paths (Issue #932), cycle 2

Review-Verdict: PASS (0 blocking); cycle opened for related non-blocking findings per the run rule that related findings are fixed inside the item.

- Inputs timestamp: 2026-10-16T03-19 (UTC)
- Base: `origin/main`
- Head: `64fb37f2b`
- Source review (cycle 1 re-audit, all stamped 2026-10-16T03-15):
  - policy-audit-path: docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/policy-audit.2026-10-16T03-15.md
  - code-review-path: docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/code-review.2026-10-16T03-15.md
  - feature-audit-path: docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/feature-audit.2026-10-16T03-15.md
- Author: orchestrator, transcribing the re-audit's related and unrelated findings and the orchestrator's classification decisions.

## Related findings to fix in this cycle (Severity: Non-blocking)

### N-1 Continuation whitespace test differs between runtimes (Low)

- Facts (from the re-audit):
  - Python decides continuation with `line[:1].isspace()` (`scripts/dev_tools/plan_gate_scratch.py:81`); TypeScript uses `/^\s/` (`extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts:88`).
  - A line that begins with NEL (U+0085) continues the logical line in Python and ends it in TypeScript, so the two runtimes emit different G10 message text for the same plan. The reviewer confirmed this with a probe.
  - The parity note added in cycle 1 (`.claude/rules/plan-acceptance-gates.md:153`, `spec.md:211`) names only whitespace normalization as the remaining runtime difference.
- Required remediation (orchestrator decision: align the code, do not merely document): make both runtimes use one explicit, identical whitespace class for the continuation test, and add a fixture with a frozen expected result to both suites that exercises a NEL-led line (and at least one other character on which `str.isspace()` and the JavaScript `\s` class disagree). Re-derive the whitespace normalization step at the same time: if it uses the same two differing classes (`str.split()` versus `/\s+/`), align it to the same explicit class and add a fixture. Update the rule file note, its bundle copy (byte-identical), and the spec NFR-2 note so they state the alignment rather than a residual difference. Keep 100% line and branch coverage on both modules.

### N-2 Stale comment names the old Python splitter (Info)

- Fact: the body comment at `extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts:268-272` still names Python `str.splitlines()` as the matching function.
- Required remediation: update the comment to name `split_plan_lines` (the shared CR/LF splitter introduced in cycle 1).

### U-1 Discrimination module still uses splitlines (reclassified as related)

- Facts (from the re-audit): `scripts/dev_tools/plan_gate_discrimination.py:277` calls `splitlines()`, while `extensions/drm-copilot/src/lib/validate/plan-gate-rules.ts:428` splits on CR/LF only. The code is unchanged since the merge base and reads repository source files for the G1-G9 literal check.
- Classification: the reviewer listed this as unrelated. The orchestrator reclassifies it as related because `plan_gate_discrimination.py` is a file this item modifies and the defect is the same line-splitting parity class that cycle 1 fixed.
- Required remediation: route this call through `split_plan_lines` (or an equivalent CR/LF splitter) so the Python and TypeScript literal checks split identically, add a parity fixture that would fail before the change, and confirm no G1-G9 result changes on the existing plan corpus.

## Declined (no action in this item)

- U-2: jest reports "Coverage data ... was not found" for six pre-existing per-file threshold entries in `extensions/drm-copilot/jest.config.cjs`. Declined: the coordinator restricted this item's edits to that file to the single per-file threshold entry, because concurrent item #543 also edits it. The run exits 0.
- U-3: the promotion path at `issue.md:5` lacks the folder's date prefix. Unrelated: it is produced by the promotion tooling and is shared by 53 of 89 active `issue.md` files.
- CR-6 and CR-7 remain declined as recorded for cycle 1.

## Pending CI (not a remediation item)

- AC-23 stays unchecked until CI runs `test_bundled_claude_payload_contains_all_repo_runtime_contracts` on the PR head. Keep the rule-file bundle copy byte-identical.
