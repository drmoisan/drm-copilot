Timestamp: 2026-08-28T20-30

Policy Order:
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`

Confirmation:
1. `CLAUDE.md` — read in full. Confirms the four-layer runtime architecture, the policy-compliance reading order pointing to `.github/instructions/*`, and that `.claude/rules/*.md` mirror those instructions for PowerShell/Python/TypeScript/C#.
2. `.claude/rules/general-code-change.md` — read in full. Confirms the mandatory seven-stage toolchain loop (format, lint, type-check, architecture-boundary tests, unit tests, contract/schema checks, integration tests), the 500-line file-size limit, and the I/O-boundary and error-handling rules that govern the new Pester test file added by this fix.
3. `.claude/rules/general-unit-test.md` — read in full. Confirms the >= 85% line-coverage threshold (PowerShell exempt from the branch-coverage gate), the prohibition on excluding production files from coverage measurement, and the test-file-location mirroring rule that places the new sibling test under `tests/scripts/dev-tools/`.
4. `.claude/rules/powershell.md` — read in full. Confirms the format → analyze → test toolchain order, the wrapper-function mocking seam pattern (`Invoke-<Tool>Exe`), the mock-signature-parity rule, and the 500-line script cap that is this fix's driver for creating a new sibling test file rather than extending the existing 497-line file.
