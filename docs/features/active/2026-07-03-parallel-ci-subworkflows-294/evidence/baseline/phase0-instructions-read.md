# Phase 0 Policy-Read Evidence — Issue #294

Timestamp: 2026-07-03T18-07

Policy Order:
1. `.github/copilot-instructions.md`
2. `.github/instructions/general-code-change.instructions.md`
3. `.github/instructions/general-unit-test.instructions.md`
4. `.github/instructions/github-actions.instructions.md`

Files Read (in full):
- `.github/copilot-instructions.md`
- `.github/instructions/general-code-change.instructions.md`
- `.github/instructions/general-unit-test.instructions.md`
- `.github/instructions/github-actions.instructions.md`

Notes:
- `.github/instructions/github-actions.instructions.md` carries `applyTo: ".github/workflows/**/*.yml,.github/workflows/**/*.yaml"`, which matches every file this feature creates or modifies (`ci.yml`, the 7 new `_<name>.yml` files, and `README.md` is documentation, not itself a workflow file but lives in the same directory).
- This feature is `.github/workflows/**`-only; no Python/TypeScript/PowerShell/C# language-specific policy applies (per Scope Statement in the plan).
