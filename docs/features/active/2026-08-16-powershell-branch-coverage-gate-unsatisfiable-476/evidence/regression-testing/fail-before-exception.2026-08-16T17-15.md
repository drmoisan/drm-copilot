# Fail-Before Exception Dossier (Issue #476)

Timestamp: 2026-08-16T17-15

WhyFailingRunImpossible: This defect is a prose-only policy inconsistency, not a behavioral defect in executable code. The change set modifies Markdown policy text exclusively; no production code, hook, script, configuration, or test file changes. Research R5 verified, and the confirming grep below re-verified, that no test in `tests/**` or `extensions/drm-copilot/test/**` asserts on the branch-coverage wording of any of the 17 affected files. There is therefore no deterministic automated test that could fail before the fix and pass after it, because the failing behavior is exercised by a reviewing agent reading policy prose, not by a test runner evaluating an assertion. Authoring a wording-pinning test purely to manufacture a fail-before signal is explicitly optional under the spec's Test Strategy and is not required by any acceptance criterion; the plan does not include it.

## Confirming Grep (R5 re-verification)

Command: `rg -i -n --hidden "branch coverage|branch-coverage" tests/` and `rg -i -n --hidden "branch coverage|branch-coverage" extensions/drm-copilot/test/`

Results:

```text
tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:152:    Context 'Test-ChildCheckpointAllowsEpicMerge helper (direct branch coverage)' {
tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:173:    Context 'Test-EpicCheckpointAllowsMerge helper (direct branch coverage)' {
tests/scripts/dev_tools/test_potential_to_issue_branches.py:1:"""Branch-coverage tests for scripts/dev_tools/potential_to_issue.py.
tests/scripts/dev_tools/test_potential_to_issue_branches.py:4:report for `potential_to_issue.py` to raise its per-module branch coverage above

(extensions/drm-copilot/test/: no matches, exit code 1)
```

All four `tests/**` matches are descriptive test-name text about a module's own branch coverage. None reads, parses, or asserts on the content of `.claude/rules/powershell.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/skills/feature-review-workflow/SKILL.md`, `.claude/agents/feature-review.md`, `.claude/skills/powershell-qa-gate/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/quality-tiers/SKILL.md`, or `README.md`. The extension test tree contains no match at all. R5 is confirmed at execution time.

## Alternative Proof

The defect and its remediation are proved by a before-and-after inventory comparison rather than by a red-to-green test transition.

- **Pre-change defect evidence:** `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/baseline/branch-coverage-grep-baseline.2026-08-16T17-14.md`. That artifact records 19 root-file line positions across 8 files that bind an unqualified branch `>= 75%` requirement reaching PowerShell, plus the same 19 positions in the bundle mirrors, plus `README.md:298`. It also records the retained out-of-surface positions that must not change.
- **Post-change counterpart:** the P4-T9 late inventory sweep at `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/qa-gates/ac16-inventory-sweep.<ts>.md`, which re-runs the identical command and must show zero remaining unqualified PowerShell branch-threshold bindings while confirming `.claude/rules/shell.md` is unchanged.
- **Independent capability proof (the reason the threshold is unevaluable, not merely unmet):** recorded in `spec.md` Repro & Evidence — `artifacts/pester/powershell-coverage.xml` contains `CLASS`, `INSTRUCTION`, `LINE`, and `METHOD` counters and zero `BRANCH` counter nodes; the installed Pester 5.6.1 module source contains zero occurrences of the string `branch`; Pester's `CodeCoverage` configuration surface exposes no branch property.
- **Mechanism-side corroboration:** `.claude/hooks/validate-feature-review-coverage.ps1` already returns `$null` when zero `BRANCH` counters exist and skips the 75% check on null. The mechanism therefore already implements the target policy; this change closes a prose/mechanism gap rather than weakening an operating gate. The hook is not modified (AC10).

## Binding Regression Surface Used Instead

The regression protection for this change is root/bundle byte parity and pack-manifest completeness, which fail deterministically if any root edit lands without its mirror edit:

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
- `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` (Jest twin)

Baseline state for that surface is recorded at `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/baseline/pytest-parity-baseline.2026-08-16T17-09.md` (20 passed, exit code 0); the post-change counterparts are P5-T1 and P5-T3.

SearchScope: `tests/` and `extensions/drm-copilot/test/` (recursive, hidden files included)
SearchPatterns: `branch coverage`, `branch-coverage` (case-insensitive, alternation)
SearchResult: four descriptive matches in `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` and `tests/scripts/dev_tools/test_potential_to_issue_branches.py`; none asserts on affected-file wording. Zero matches under `extensions/drm-copilot/test/`.
