# Phase 0 — Policy Instructions Read (P0-T1)

Timestamp: 2026-08-25T21-56

Task: [P0-T1]
Class: record-only (executes no command; carries no `Command:` and no `EXIT_CODE:` row, per the plan's evidence accounting rule)

## Policy Order

The files below were read in the exact order CLAUDE.md prescribes, then the path-scoped
`.claude/rules/` documents the plan names.

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.github/instructions/python-code-change.instructions.md`
6. `.github/instructions/python-unit-test.instructions.md`
7. `.github/instructions/github-actions.instructions.md`
8. `.claude/rules/python.md`
9. `.claude/rules/quality-tiers.md`
10. `.claude/rules/plan-acceptance-gates.md`
11. `.claude/rules/ci-workflows.md`

## Files Read

The ten policy documents required by P0-T1, listed with their repo-relative paths:

- `.github/copilot-instructions.md`
- `.github/instructions/general-code-change.instructions.md`
- `.github/instructions/general-unit-test.instructions.md`
- `.github/instructions/python-code-change.instructions.md`
- `.github/instructions/python-unit-test.instructions.md`
- `.github/instructions/github-actions.instructions.md`
- `.claude/rules/python.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/plan-acceptance-gates.md`
- `.claude/rules/ci-workflows.md`

`CLAUDE.md` was additionally read as the standing-instruction document that prescribes the
order above. It is listed in the Policy Order block as item 1 and is not counted among the
ten policy documents the acceptance condition enumerates.

## Feature-Document Presence Statements

Each of the four documents the acceptance condition names was checked for existence in the
executing checkout by directory listing.

- `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md` — PRESENT (49324 bytes)
- `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/issue.md` — PRESENT (4251 bytes)
- `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/research/2026-08-23T23-45-ci-coverage-target-remedy-research.md` — PRESENT (43282 bytes)
- `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md` — PRESENT (84488 bytes)

All four are present. The precondition is satisfied and the verdict is NOT BLOCKED.

## Evidence-Subtree Observation (informational, not an acceptance condition)

`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/`
carries five `preflight-findings.*.md` artifacts in this checkout. Write-set entry 7 covers
the entire evidence subtree and explicitly states that these artifacts are an open
enumeration and must not be treated as a count, so the presence of a fifth artifact
(`preflight-findings.2026-08-24T13-21.md`) beyond the four the plan header cites is within
the declared write set and is not a finding.

## Verdict

PASS — the artifact exists, its file list names all ten policy documents, and all four
feature documents are present in the executing checkout.
