# User Story: policy-file consistency (MSTest, Pester 6, stray coverage path)

- **Issue:** #1106
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07
- **Spec:** `spec.md`

## Story

As the repository owner who distributes policy to consumer repositories,
I want every rule, instruction, agent, skill, prompt, template, and bundle copy to name the toolchain I actually use (MSTest, Pester 6, and coverage paths that exist in this repository),
so that agents following any surface produce tests and commands that match my projects, and no surface contradicts another.

## Context

- The owner does not use xUnit. The modern Claude C# pack and the `tdd-red` agent name it; the other C# surfaces name MSTest.
- The repository pins Pester 6.2.0, but several surfaces state Pester v5.
- `--cov=src/lexile_corpus_tuner` and other `lexile`/`gutenberg` example text come from another project.
- The owner explicitly authorized editing the canonical `.github/instructions` policy files and their mirrors for issue #1106 only.

## Scenarios

1. An agent loads the modern Claude C# rule and writes tests: it uses MSTest attributes and runs `dotnet test --collect:"XPlat Code Coverage"`.
2. An agent loads a Copilot, Codex, or legacy C# surface: it uses MSTest and runs `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`.
3. An agent loads any PowerShell surface: it is told Pester v6 is the supported version.
4. An agent or developer runs an approved Python coverage command, VS Code task, or atomic-executor command: coverage targets `scripts/dev_tools`, not a missing package.
5. A contributor reintroduces xUnit framework wording, Pester v5 wording, or the stray coverage path: the guard test fails and names the file and phrase.

## Out of Scope

- The `>= 90%` new-code coverage rule, the 85% line / 75% branch thresholds, and parallel-only test command wording (owner rulings).
- Mocking libraries, MSTest.Sdk on Microsoft.Testing.Platform, `clean_devcontainer.py` names, and `LEXILE_TK_SCALE`.

## Acceptance Criteria

- [ ] An agent reading any C# surface is told to use MSTest; no surface names xUnit as this repository's C# test framework.
- [ ] An agent reading a C# surface finds one runner and command set for that surface's profile (modern Claude pack: `dotnet test --collect:"XPlat Code Coverage"`; Copilot, Codex default, legacy, and `csharp-atomic-executor`: `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`).
- [ ] An agent reading any PowerShell surface is told Pester v6 is the supported version.
- [ ] No approved or emitted Python coverage command, VS Code task, or atomic-executor argv list carries `--cov=src/lexile_corpus_tuner`.
- [ ] Policy surfaces and their bundle copies use neutral example names instead of other-project (`lexile`, `gutenberg`) text.
- [ ] A consumer receiving the bundles gets text identical to the canonical sources, and the generator `--check`, parity, and contract tests pass.
- [ ] The `>= 90%` new-code rule, the 85% line / 75% branch thresholds, and the parallel-only test command wording are byte-unchanged.
- [ ] Reintroducing a forbidden phrase makes `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1` fail; with the change applied it passes.
- [ ] `Invoke-PoshQCParallelTest` and `poetry run pytest -n auto` pass with zero failures, no coverage drop on changed lines versus the Phase 0 baseline, and each changed Python file at 85% line / 75% branch or higher.
