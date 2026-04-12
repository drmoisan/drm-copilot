# Remediation Inputs: Claude Code Architecture (#136)

**Created:** 2026-04-12T02-01  
**Source Audits:**
- `policy-audit.2026-04-12T02-01.md`
- `code-review.2026-04-12T02-01.md`
- `feature-audit.2026-04-12T02-01.md`

---

## Required Fixes

### Fix 1: Add Pester unit tests for `.claude/hooks/validate-bash.ps1`

**File(s):** `.claude/hooks/validate-bash.ps1` (existing, 66 lines — do not modify)  
**New file:** `tests/.claude/hooks/validate-bash.Tests.ps1`

**Expected behavior:**
- Each of the 6 blocked patterns must be detected and cause the script to exit with code 1:
  1. `rm -rf /some/path`
  2. `git push --force`
  3. `git push origin --force`
  4. `Remove-Item -Recurse -Force`
  5. `git reset --hard`
  6. `git push -f`
- Safe commands must pass through with exit code 0 (e.g., `ls -la`, `git status`, `echo hello`)
- Empty input must be handled gracefully (exit 0, no error)
- Malformed JSON in `CLAUDE_TOOL_INPUT` environment variable must be handled (fallback to positional argument or empty string)
- The script must be testable by invoking it directly with a command string argument

**Acceptance criteria:**
- All Pester tests pass via `mcp_drmcopilotext_run_poshqc_test`
- Tests follow repo Pester conventions (Describe/Context/It structure, `*.Tests.ps1` naming)
- Tests are independent and deterministic
- No temporary files used
- Test file is under 500 lines

**Verification commands:**
- PoshQC format: `mcp__drmCopilotExtension__run_poshqc_format`
- PoshQC analyze: `mcp__drmCopilotExtension__run_poshqc_analyze`
- PoshQC test: `mcp_drmcopilotext_run_poshqc_test`

---

## Acceptance Criteria Not Yet Met

| AC # | Criterion | Gap | Minimum Change |
|------|-----------|-----|----------------|
| 13 (spec.md DoD) | Tests updated/added | No Pester tests for new hook script | Add `validate-bash.Tests.ps1` |
| 14 (spec.md DoD) | Edge cases and error handling covered by tests | Empty input and JSON parse failure paths untested | Include edge-case test cases |

---

## Do Not Do

- Do NOT modify `.claude/hooks/validate-bash.ps1` — the production code is correct and passes PoshQC format/analyze.
- Do NOT modify any existing test files.
- Do NOT add tests for non-executable deliverables (Markdown, JSON configuration). Only the PowerShell hook requires tests.
- Do NOT attempt to validate seeded test conditions (live Claude Code session items) — these are out of scope for remediation.
- Do NOT weaken any repo policy or add broad suppressions.
- Do NOT create temporary files in tests.
- Do NOT add new dependencies.
