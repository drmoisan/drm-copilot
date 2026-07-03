# Phase 0 — Policy Read Evidence (Remediation Cycle, Issue #294)

Timestamp: 2026-07-03T23-36

Policy Order:

1. `.github/copilot-instructions.md` — repository tone and communication policy (step 1 of the Policy Compliance Reading Order in `CLAUDE.md`).
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules (step 2).
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules (step 3).
4. `.github/instructions/github-actions.instructions.md` — GitHub Actions workflow policy, the applicable domain policy for this feature's file scope (`.github/workflows/**/*.yml`) (step 4, domain-specific).

Files Read (explicit list):

- `.github/copilot-instructions.md`
- `.github/instructions/general-code-change.instructions.md`
- `.github/instructions/general-unit-test.instructions.md`
- `.github/instructions/github-actions.instructions.md`

## Notes

- The `github-actions.instructions.md` `applyTo` frontmatter pattern (`.github/workflows/**/*.yml,.github/workflows/**/*.yaml`) matches the workflow files this remediation cycle produces evidence about. No files matching this pattern are edited by this remediation cycle; only evidentiary artifacts under `docs/features/active/2026-07-03-parallel-ci-subworkflows-294/evidence/` are created or updated.
- This remediation cycle is evidence-capture-only. No Python, TypeScript, PowerShell, or C# production or test file is in scope, and the general-code-change / general-unit-test toolchain-loop requirements are read for completeness but do not trigger any code-change or test-change obligations in this cycle.
