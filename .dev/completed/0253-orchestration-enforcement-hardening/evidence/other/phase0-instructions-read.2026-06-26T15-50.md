# Phase 0 — Instructions Read (Issue #253)

- Timestamp: 2026-06-26T15-50
- Policy Order: per `.claude/skills/policy-compliance-order` and `CLAUDE.md` Policy Compliance Reading Order

## Policy Order

1. Repository tone and communication policy
2. Baseline cross-language code change policy
3. Baseline cross-language unit test policy
4. Language-specific policies (Python, PowerShell) for files in scope
5. GitHub Actions policy (informational; config JSON parity is exercised via Pytest, not GH Actions)

## Files Read (in order)

1. `.github/copilot-instructions.md` — repository tone and communication policy
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules (mirrored by `.claude/rules/general-code-change.md`, loaded into context)
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules (mirrored by `.claude/rules/general-unit-test.md`, loaded into context)
4. `.github/instructions/python-code-change.instructions.md` — Python code change policy
5. `.github/instructions/python-unit-test.instructions.md` — Python unit test policy (mirrored by `.claude/rules/python.md`, loaded into context)
6. `.github/instructions/powershell-code-change.instructions.md` — PowerShell code change policy (mirrored by `.claude/rules/powershell.md`, loaded into context)
7. `.github/instructions/powershell-unit-test.instructions.md` — PowerShell unit test policy (mirrored by `.claude/rules/powershell.md`, loaded into context)
8. `.github/instructions/github-actions.instructions.md` — GitHub Actions policy (informational for this feature)

## Standing rules also loaded into session context

- `CLAUDE.md` (project standing instructions)
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
- `.claude/rules/powershell.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/self-explanatory-code-commenting.md`
- `.claude/rules/tonality.md`

## Key constraints applicable to this feature

- File-size limit: no production/test/script file may exceed 500 lines.
- Toolchain loops run to a single clean pass: Python (Black, Ruff, Pyright, Pytest with coverage); PowerShell (PoshQC format, analyze, Pester with coverage).
- Coverage thresholds uniform across tiers: line >= 85%, branch >= 75%, no regression on changed lines.
- Suppressions require pre-authorized patterns or explicit approval.
- Backward compatibility mandatory: existing checkpoints without new fields keep validating; `strict_route_membership` defaults to False; `requires_pr_gate` defaults to False when absent.
- Evidence written only under `docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/<kind>/`.
- The three unrelated working-tree changes under `tests/scripts/claude-hooks/*.Tests.ps1` (pwsh-runner-independence) are out of scope and not touched.
