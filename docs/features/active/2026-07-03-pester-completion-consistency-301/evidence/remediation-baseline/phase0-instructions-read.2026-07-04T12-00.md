# Phase 0 — Policy Read Evidence (Remediation Cycle 1)

Timestamp: 2026-07-04T12-00

Policy Order:
1. `CLAUDE.md` (repo root)
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/typescript.md`

Files Read:
- `CLAUDE.md` — confirmed tone policy (professional, factual, neutral) and policy-compliance reading order apply to this remediation cycle.
- `.claude/rules/general-code-change.md` — confirmed the cross-language code-change policy (simplicity-first design, 500-line file limit, fail-fast error handling) applies to the edits planned for `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `tsconfig.json`.
- `.claude/rules/general-unit-test.md` — confirmed the >=85% line coverage / >=75% branch coverage requirement and the coverage-exclusion prohibition (no production file may be excluded from coverage measurement) apply to the four in-scope hook files being added to `CodeCoverage.Path`.
- `.claude/rules/powershell.md` — confirmed the mandatory PoshQC toolchain order (format -> analyze -> test, restart on any file change or failure; no type-check stage for PowerShell) and the coverage-regression-on-changed-lines rule.
- `.claude/rules/typescript.md` — confirmed the mandatory TypeScript toolchain order (format -> lint -> type-check -> test, restart on any file change or failure) applicable to the root `tsconfig.json` fix.

Output Summary: All five policy files read and confirmed applicable to this remediation cycle's scope (pester.runsettings.psd1 CodeCoverage.Path fix, coverage rerun, AC 3 re-evaluation, tsconfig.json fix). No conflicts identified between policy files and the remediation-plan scope.
