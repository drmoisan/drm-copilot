# policy-file-consistency-mstest-pester6 (Issue #1106)

- Date captured: 2026-11-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/policy-file-consistency-mstest-pester6/ (Issue #1106)

- Issue: #1106
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1106
- Last Updated: 2026-11-07
- Work Mode: full-feature

## Problem / Why

A sweep of the policy surfaces on 2026-11-07 found three inconsistencies between `.claude/rules`, `.github/instructions`, `.agents/skills`, the agents and skills, and the bundled copies under `extensions/drm-copilot/resources/`:

1. **xUnit is named, but the owner uses MSTest.** The owner said: "XUnit is never used by me." Some C# surfaces name xUnit with `dotnet test`, while others name MSTest with `vstest`. A search found about 180 xUnit references across the C# rule, the `csharp-typed-engineer` agent, the `invoke-csharp-engineer` and `csharp-qa-gate` skills, the `tdd-red` agent, their bundled copies, and the contract test `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
2. **Pester v5.x is named, but the repository runs Pester 6.2.** The PowerShell rule, the `.agents` PowerShell skill, and `powershell-unit-test.instructions.md` say v5.x, while the `execution-environment` skill describes Pester 6 processes.
3. **A stray coverage path.** `python-unit-test.instructions.md` carries `--cov=src/lexile_corpus_tuner`, which belongs to another project, and so do some command examples in `python-suppressions.instructions.md`.

The owner authorized fixing these in the canonical `.github/instructions` files and every mirror.

## Proposed Behavior

- Replace xUnit with MSTest throughout the C# surfaces. Use the MSTest toolchain the repository actually uses, so that every C# surface names the same framework, runner, and commands.
- Replace Pester v5.x with Pester 6.x wherever it names the supported version.
- Remove `--cov=src/lexile_corpus_tuner` from approved commands. Keep any example text that is clearly about another project only if it is labelled that way; otherwise remove it.
- Keep every mirror identical: `.claude/rules` with `.github/instructions`, the `.agents/skills` copies, the `.codex` copies if any, and the three bundles under `extensions/drm-copilot/resources/`.
- Update contract tests that pin the old wording.

## Out of scope (owner rulings)

- **Do not change the >= 90% coverage rule for new modules, classes, and methods.** It stays wherever it appears. Do not add it where it is absent, and do not remove it.
- Do not change the parallel-only test command wording; the owner is applying those edits from a separate draft.
- Do not change the 85% line and 75% branch thresholds.

## Acceptance Criteria (early draft)

- [ ] No rule, instruction, agent, skill, or bundle names xUnit as this repository's C# test framework.
- [ ] Every C# surface names the same MSTest framework, runner, and commands.
- [ ] No surface names Pester v5.x as the supported version.
- [ ] No approved command carries `--cov=src/lexile_corpus_tuner`.
- [ ] All mirrors and bundles match their canonical source, and the parity and contract tests pass.
- [ ] The >= 90% new-code rule text is unchanged.
- [ ] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.

## Constraints & Risks

- These are canonical policy files that agents normally may not edit. The owner authorized this change; record the authorization in the checkpoint.
- Pushed-down copies reach consumer repositories only after an extension release.
- The removed text is wrong, not a process reduction, so no ledger entry is needed.

## Test Conditions to Consider

- [ ] Contract tests for the C# framework wording across mirrors
- [ ] Parity tests between canonical files, mirrors, and bundles
- [ ] A search assertion that xUnit, Pester v5.x, and the stray path are absent from policy surfaces

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/policy-file-consistency-mstest-pester6/` folder from the template
