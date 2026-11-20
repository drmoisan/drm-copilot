# Final TypeScript Coverage Delta Evidence

Timestamp: 2026-05-01T00-00Z
Command: N/A (delta computed by comparing baseline and final coverage evidence artifacts)
EXIT_CODE: 0

## Output Summary

**Baseline (Phase 0):**
- Source: `evidence/baseline/phase0-typescript-test-coverage.md` (from git commit `79d02b7`)
- Tests: 336 passed across 28 suites
- Coverage: **94.95%** lines

**Post-Change:**
- Source: `evidence/qa-gates/final-typescript-test-coverage.md`
- Tests: 348 passed across 32 suites (+12 tests, +4 suites)
- Coverage: **95.5%** statements / **95.5%** lines (+0.55 pp)

**New-or-Changed-Code coverage (from `final-typescript-test-coverage.md` per-file figures):**
- `src/repo-automation-tool-names.ts`: 100% lines
- `src/repo-automation-service.ts`: 100% lines
- `src/mcp-tool-definitions.ts`: 100% lines
- `src/mcp-tool-inputs.ts`: 93.34% lines
- `src/mcp-handlers/codex-native-converter-handlers.ts`: 100% lines
- `src/mcp-tools.ts`: 91.08% lines
- `src/extension.ts`: 98.59% lines (note: `promptForShortName` unused import removed in this QA pass)

**Threshold Verdict:**
- Repo-wide coverage must not decrease: **PASS** (94.95% → 95.5%, +0.55 pp)
- New-or-changed-code ≥90%: **PASS** for all Phase 5 changed files (lowest: `mcp-tools.ts` at 91.08%)

Overall verdict: **PASS**
