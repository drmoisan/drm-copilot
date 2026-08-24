# Acceptance Criteria Status — Issue #412

Task: [P6-T17]

Timestamp: 2026-07-25T19-02

Work mode: `full-bug` — `spec.md` is the sole acceptance-criteria source (`user-story.md` is
intentionally absent), per `.claude/skills/acceptance-criteria-tracking/SKILL.md`.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/spec.md`
  (§Acceptance Criteria, lines 237–273)
- Total AC items: 27
- Checked off (delivered): 26
- Remaining (unchecked): 1
- Items remaining: "The PR body records the divergence-2 backward-compatibility statement: zero
  stored assessments invalidated (paths and counts per the research), and pre-change checkpoints
  with non-floor-only assessments require re-recording via the documented resume reconciliation."

## Items checked off in Phase 6 (four), with the evidence that verified each

| Criterion | Verifying evidence |
|---|---|
| All pre-existing step-status validator tests (Python, Pester, Jest) pass without fixture modification | `evidence/qa-gates/final-python-test.md` (2123 passed / 0 failed), `evidence/qa-gates/final-powershell-test.md` (1391 tests / 0 failures) and `evidence/qa-gates/final-powershell-direct-pester.md` (106/106), `evidence/qa-gates/final-typescript-test.md` (168 suites / 2035 tests passing). No fixture file was modified: `tests/scripts/dev_tools/test_validate_orchestrator_state.py` has zero diff on this branch. |
| `test_push_down_claude_resource_contracts.py` passes, confirming root/mirror content identity | `evidence/qa-gates/final-mirror-parity.md` (7/7 passed; both `diff` checks exit 0) |
| The full per-language toolchain passes for every batch | Phase 1–5 gate artifacts plus the Phase 6 full-repo loop: Python `final-python-format.md` / `final-python-lint.md` / `final-python-typecheck.md` / `final-python-test.md`; PowerShell `final-powershell-format.md` / `final-powershell-analyze.md` / `final-powershell-test.md` / `final-powershell-direct-pester.md`; TypeScript `final-typescript-format.md` / `final-typescript-lint.md` / `final-typescript-typecheck.md` / `final-typescript-test.md`. Every language completed a clean single pass with no restart. |
| Line >= 85% and branch >= 75% maintained on changed files | `evidence/qa-gates/final-coverage-comparison.md` |

## Why the remaining item is not checked off

The remaining criterion requires the divergence-2 backward-compatibility statement to appear in
the **PR body**. No pull request exists for this branch yet; `Agent(pr-author)` writes the PR body
after review. Checking the item off now would assert delivery of an artifact that does not exist,
which the evidence-before-check-off rule prohibits.

The statement text itself is prepared and verified, ready for verbatim inclusion, at
`docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/evidence/other/pr-body-backcompat-statement.md`.
The criterion becomes checkable once the PR body is published with that text.

## Items checked off in earlier phases (22)

Criteria 1–13 of §Divergence 1 and criteria 1–9 of §Divergence 2 were checked off during
Phases 1–5 as each implementing task passed its verification, per the one-at-a-time rule.
