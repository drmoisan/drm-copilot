# policy-file-consistency-mstest-pester6 - Refactor Spec

- **Issue:** #1106
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T09-01
- **Status:** Draft
- **Version:** 0.1

## Intent & Outcomes

A sweep of the policy surfaces on 2026-11-07 found three inconsistencies between `.claude/rules`, `.github/instructions`, `.agents/skills`, the agents and skills, and the bundled copies under `extensions/drm-copilot/resources/`:

1. **xUnit is named, but the owner uses MSTest.** The owner said: "XUnit is never used by me." Some C# surfaces name xUnit with `dotnet test`, while others name MSTest with `vstest`. A search found about 180 xUnit references across the C# rule, the `csharp-typed-engineer` agent, the `invoke-csharp-engineer` and `csharp-qa-gate` skills, the `tdd-red` agent, their bundled copies, and the contract test `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
2. **Pester v5.x is named, but the repository runs Pester 6.2.** The PowerShell rule, the `.agents` PowerShell skill, and `powershell-unit-test.instructions.md` say v5.x, while the `execution-environment` skill describes Pester 6 processes.
3. **A stray coverage path.** `python-unit-test.instructions.md` carries `--cov=src/lexile_corpus_tuner`, which belongs to another project, and so do some command examples in `python-suppressions.instructions.md`.

The owner authorized fixing these in the canonical `.github/instructions` files and every mirror.


## Invariants (must not change)

List the behaviors, contracts, and external surfaces that must remain identical (CLIs, APIs, outputs, data formats, paths).
- Performance characteristics to preserve (latency/throughput/memory):
- Compatibility guarantees (CLI flags, config schemas, versions):

## Scope (structural changes)

- Replace xUnit with MSTest throughout the C# surfaces. Use the MSTest toolchain the repository actually uses, so that every C# surface names the same framework, runner, and commands.
- Replace Pester v5.x with Pester 6.x wherever it names the supported version.
- Remove `--cov=src/lexile_corpus_tuner` from approved commands. Keep any example text that is clearly about another project only if it is labelled that way; otherwise remove it.
- Keep every mirror identical: `.claude/rules` with `.github/instructions`, the `.agents/skills` copies, the `.codex` copies if any, and the three bundles under `extensions/drm-copilot/resources/`.
- Update contract tests that pin the old wording.


## Non-Goals

What is explicitly out of scope (new behavior, perf changes, UX changes, flags).

## Dependencies / Touchpoints

Upstream/downstream modules, CLIs, data paths, automation, or external consumers that rely on current structure.
- Required coordination (other teams, CI/CD, release tooling):

## Risks & Mitigations

- These are canonical policy files that agents normally may not edit. The owner authorized this change; record the authorization in the checkpoint.
- Pushed-down copies reach consumer repositories only after an extension release.
- The removed text is wrong, not a process reduction, so no ledger entry is needed.


## Technical Specifications

- Files/modules expected to change:
- Public interfaces/contracts affected (even if behavior is unchanged):
- Data flow or validation adjustments:
- Logging/telemetry updates (if any):
- Migration or backfill needs (if any):

## Test Strategy

- Regression tests to add or update:
- Invariant validation tests (ensuring outputs/behavior unchanged):
- Edge cases and negative scenarios (import/path stability, CLI flags):
- Error handling and logging verification:
- Coverage impact and targets for changed lines/modules:
- Toolchain commands to run (format → lint → type-check → test):
- Manual validation steps (if required):

## Definition of Done

- [ ] Structure matches this spec; legacy paths retired or redirected
- [ ] Invariants validated with tests or comparisons
- [ ] Imports/tooling/entry points updated
- [ ] Edge cases and error handling verified
- [ ] Tests, linting, and type checks clean
- [ ] Docs updated (initiative/README/tasks as needed)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Contract tests for the C# framework wording across mirrors
- [ ] Parity tests between canonical files, mirrors, and bundles
- [ ] A search assertion that xUnit, Pester v5.x, and the stray path are absent from policy surfaces
