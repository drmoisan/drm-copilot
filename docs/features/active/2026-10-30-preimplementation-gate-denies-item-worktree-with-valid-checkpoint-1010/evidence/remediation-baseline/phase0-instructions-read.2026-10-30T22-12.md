# Phase 0 Policy Reads (Issue #1010, remediation cycle 1, P0-T1)

Timestamp: 2026-10-30T22-12
Policy Order: CLAUDE.md, then `.claude/rules/general-code-change.md`, then `.claude/rules/general-unit-test.md`, then the domain rules in scope (`.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`), per the `policy-compliance-order` skill; then the execution-environment brief and the remediation input.

## Files Read

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`
6. `.claude/rules/tonality.md`
7. `.claude/skills/execution-environment/SKILL.md`
8. `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010/remediation-inputs.2026-10-30T21-59.md`

## Notes

- PowerShell line coverage threshold: 85% per changed production file; no branch gate for Pester.
- Pester counts are read from `artifacts/pester/pester-junit.xml` and line coverage from `artifacts/pester/powershell-coverage.xml`; PoshQC MCP results carry no output and are not used for counts.
- The remediation input holds F1 (helper parity across the two `-epic-scope` files) and F2 (pathspecs after value-taking `git commit`/`git add` options).
