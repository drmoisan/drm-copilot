# Phase 0 — Instructions Read Evidence

- Timestamp: 2026-07-10T17-41
- Issue: #344
- Feature: poshqc-test-terminal-output-scan-config

## Policy Order

Policy files were read in the required order defined by `policy-compliance-order` and the plan's `[P0-T1]` task.

## Files Read

1. `CLAUDE.md` (standing instructions, always loaded)
2. `.claude/rules/general-code-change.md` (cross-language code change policy)
3. `.claude/rules/general-unit-test.md` (cross-language unit test policy)
4. `.claude/rules/typescript.md` (TypeScript toolchain and coding standards)
5. `.claude/rules/typescript-suppressions.md` (TypeScript suppression policy)
6. `.claude/rules/powershell.md` (PowerShell toolchain and coding standards)
7. `.claude/rules/python.md` (Python toolchain and coding standards)
8. `.claude/rules/python-suppressions.md` (Python suppression policy)

Supporting rules also consulted for this feature scope:
- `.claude/rules/quality-tiers.md` (coverage thresholds: line >= 85%, branch >= 75%)
- `.claude/rules/self-explanatory-code-commenting.md`
- `.claude/rules/tonality.md`

## Notes

- The extension package (`extensions/drm-copilot`) uses the Jest harness (`run-jest.cjs`, tests in `extensions/drm-copilot/test/*.test.ts`). Per the approved spec and plan, this feature follows the package's established Jest harness and does not introduce Vitest into this package. The generic `typescript.md` naming of Vitest is superseded here by the package-specific harness authority stated in the spec (Constraints & Risks) and plan (Conventions).

## Output Summary

All eight required policy files plus supporting rule files were read prior to any code or test change. Reading order matches the required order exactly.
