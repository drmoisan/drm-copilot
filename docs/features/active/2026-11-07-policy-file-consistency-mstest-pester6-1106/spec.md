# policy-file-consistency-mstest-pester6 - Refactor Spec

- **Issue:** #1106
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07
- **Status:** Approved for planning
- **Version:** 0.2
- **Branch:** `chore/policy-file-consistency`
- **Research:** `research/research.2026-11-07T14-30.md`

## Intent & Outcomes

A sweep of the policy surfaces on 2026-11-07 found three inconsistencies between `.claude/rules`, `.github/instructions`, `.agents/skills`, `.codex/agents`, the agents and skills, the feature templates, and the bundled copies under `extensions/drm-copilot/resources/`:

1. **xUnit is named, but the owner uses MSTest.** The owner said: "XUnit is never used by me." The modern Claude C# pack and the `tdd-red` agent name xUnit; the Copilot, Codex default, and legacy surfaces name MSTest.
2. **Pester v5.x is named, but the repository runs Pester 6.2.** `PoshQC.psm1` pins Pester 6.2.0 (below 7.0.0), while the PowerShell rule, skills, agents, instruction file, README, and policy-audit template state v5.
3. **A stray coverage path and other-project example text.** `--cov=src/lexile_corpus_tuner` (a package that does not exist in this repository) appears in an approved command, in `.vscode/tasks.json`, and in argv lists and emitted command text under `scripts/dev_tools`. Several policy surfaces also carry example text from another project (`lexile`, `gutenberg`).

Outcome: every C# surface names MSTest, each C# profile names one runner and command set, every supported-version statement names Pester v6, no approved or emitted command carries the stray coverage path, policy examples use neutral names, and every mirror and bundle copy matches its canonical source.

## Invariants (must not change)

- The `>= 90%` coverage rule for new modules, classes, and methods: not added, removed, or reworded in any file.
- The 85% line and 75% branch coverage thresholds wherever they appear.
- All parallel-only test command wording (the owner applies those edits from a separate draft). Where a token edit shares a line with protected wording, only the named token changes.
- The C# profile split: the modern Claude pack keeps `dotnet build`, `dotnet csharpier check .`, and `dotnet test --collect:"XPlat Code Coverage"` and contains no `msbuild` (pinned by `test_claude_modern_csharp_profile_retains_modern_gate_commands`); the Copilot, Codex default, and legacy surfaces keep `msbuild` and `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`.
- The mocking library named by each profile (NSubstitute in the modern pack, Moq elsewhere) (D5).
- `.claude/rules/*.md` `paths:` frontmatter.
- The prohibition `Do not introduce xUnit or NUnit into existing test projects.` in `csharp-unit-test.instructions.md` (+ bundle) and the generic multi-language list in `github-actions-ci-cd-best-practices.instructions.md` (+ bundle) (D6).
- The `xUnit delta` and `targeted xUnit` sweep tokens and the token count in `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`.
- `scripts/dev_tools/clean_devcontainer.py` container and volume names and the `LEXILE_TK_SCALE` environment variable (D7).
- Historical and behavior-specific Pester 5 references: `extensions/drm-copilot/CHANGELOG.md`, test-file comments, and test fixtures and assertions listed in research Item 2.
- Legacy variant files under `.claude-variants`, `.agents-variants`, and `.codex-variants` (already MSTest).
- Pack manifests: no file is added to or removed from any bundle.

## Scope (structural changes)

- **C# framework (D1).** Replace xUnit with MSTest on every C# surface, using the MSTest idioms listed in research Item 1: `[TestClass]`/`[TestMethod]`, `[DataRow]` for data-driven tests, `[ClassInitialize]` for shared setup, MSTest `Assert`, and `Verify.MSTest` for golden tests.
  - Modern Claude pack (`.claude/rules/csharp.md`, `.claude/agents/csharp-typed-engineer.md`, `.claude/skills/csharp-qa-gate`, `.claude/skills/invoke-csharp-engineer`, `.claude/skills/feature-review-workflow`, `README.md` modern section): keeps `dotnet test --collect:"XPlat Code Coverage"` on the VSTest runner and names the MSTest package set (`MSTest` with `Microsoft.NET.Test.Sdk` and `coverlet.collector`).
  - `.github/agents/tdd-red.agent.md` (+ bundle): `### C# Test Patterns` names MSTest and `[DataRow]` data-driven tests.
  - Copilot, Codex default, and legacy surfaces keep `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`.
- **csharp-atomic-executor (D2).** Align `.github/agents/csharp-atomic-executor.agent.md` and `.codex/agents/csharp-atomic-executor.toml` (with bundles) to MSTest, `msbuild`, and `vstest.console.exe`, using the commands of `csharp-unit-test.instructions.md` `## 3. C# Toolchain Command Selection`.
- **Pester version.** Replace `(v5.x)` with `(v6.x)` and `Pester v5` with `Pester v6` in every supported-version statement listed in research Item 2, including the policy-audit template and its bundle copy. Regenerate the `powershell-typed-engineer` Codex variants with `scripts/dev_tools/generate_codex_agent_variants.py`.
- **Stray coverage path (D3).** Remove `--cov=src/lexile_corpus_tuner` from:
  - `.github/instructions/python-unit-test.instructions.md` (+ bundle), token only;
  - `.vscode/tasks.json`, token only;
  - `scripts/dev_tools/atomic_executor/qc_runner.py`, `qc_toolchain.py`, `cli_preflight.py`, `prompt_builder.py`, and `scripts/dev_tools/fix_all_branches_extra.py`.
  - Where `--cov=scripts/dev_tools` follows the stray argument, delete the stray argument; where it is the only `--cov` argument, replace it with `--cov=scripts/dev_tools`.
  - Remove the dead `pyproject.toml` ruff per-file-ignore for `src/lexile_corpus_tuner/cli.py`.
  - Update `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`.
- **Other-project examples (D4).** Replace `lexile` and `gutenberg` example text with neutral generic names in `.github/instructions/python-suppressions.instructions.md` (S301 and TID252 examples), `python-code-change.instructions.md`, `general-code-change.instructions.md`, `.github/agents/commit-steward.agent.md`, `.github/prompts/generate-commit-message-repo.prompt.md`, `.github/prompts/remediate-comments.prompt.md`, `docs/features/templates/policy_audit/AGENTS.md`, and `docs/features/templates/policy_audit/README.md`, with each bundle copy under `extensions/drm-copilot/resources/` (including `resources/templates/`) where one exists.
- **Guard test.** Add `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1`.
- **Mirrors.** Apply each canonical edit byte-identically to its mirror and bundle copy in the same task.

## Non-Goals

- Changing the `>= 90%` new-code coverage rule, the 85% line / 75% branch thresholds, or any parallel-only test command wording (owner rulings; the owner applies the parallel-only edits from a separate draft).
- Switching the modern profile to `vstest.console.exe`, or the Copilot/Codex/legacy surfaces to `dotnet test`.
- Adopting MSTest.Sdk on Microsoft.Testing.Platform (`--coverage`).
- Changing the mocking library of any profile (D5).
- Removing the word xUnit from prohibitions or generic multi-language lists (D6).
- Renaming `clean_devcontainer.py` container names or `LEXILE_TK_SCALE` (D7).
- Editing historical, CHANGELOG, test-comment, or fixture references to Pester 5.
- Updating `.claude/skills/execution-environment/SKILL.md` (no stated fact changes).
- Releasing the extension; pushed-down copies reach consumer repositories only after a release.

## Dependencies / Touchpoints

- Canonical policy sources (`.github/instructions`, `.github/agents`, `.github/prompts`) and their bundle copies under `extensions/drm-copilot/resources/customizations/`.
- Claude pack (`.claude/rules`, `.claude/agents`, `.claude/skills`) and `extensions/drm-copilot/resources/claude-customizations/`.
- Codex and agents pack (`.agents/skills`, `.codex/agents`) and `extensions/drm-copilot/resources/codex-and-agents-customizations/`; generated variants via `generate_codex_agent_variants.py`.
- Templates: `docs/features/templates/policy_audit/*` and `extensions/drm-copilot/resources/templates/policy_audit/*`.
- Python tooling under `scripts/dev_tools/atomic_executor/` and `scripts/dev_tools/fix_all_branches_extra.py`; `.vscode/tasks.json`; `pyproject.toml`.
- Contract tests listed in research Q4, including `parallel-gate-wording.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, and `test_codex_handoff_contract_parity.py`.
- Coordination: the owner's separate parallel-only wording draft touches some of the same files and lines.

## Constraints

- **Owner authorization:** the owner explicitly authorized editing the canonical `.github/instructions` policy files and their mirrors for issue #1106 only. This overrides, for this issue only, the standing `CLAUDE.md` rule that the canonical policy files must not be modified. Record the authorization in the orchestrator checkpoint and the PR body.
- Avoid new Python; the guard test is Pester.
- The D3 Python edits span five production files, which exceeds the direct-mode Python batch budget; use the orchestrated route.
- Generated Codex variants are never hand-edited.
- No temporary files in tests.

## Risks & Mitigations

- **Same-line overlap with protected wording.** Mitigation: each such task changes only the named token and compares the line before and after with only that token substituted.
- **Missed mirror or hand-edited generated variant.** Mitigation: pair every canonical edit with its mirror in one task, run the generator then `--check`, and hash-compare each changed `.github` pair because no automated parity test covers that tree.
- **Python behavior change (D3).** Coverage in the atomic executor and `fix_all_branches_extra.py` commands now targets an existing package (`scripts/dev_tools`) instead of a missing one, so those runs measure coverage where they previously measured none. Mitigation: update `test_qc_runner.py` and state the change in the PR description.
- **Review checklists flag canonical policy edits.** Mitigation: cite the owner authorization.
- **No ledger entry.** The removed text is wrong, not a process reduction, so no process-reduction ledger entry is needed.

### Decision record: one runner per profile (D1)

One runner for every C# surface was not chosen. The modern profile is host-neutral and its commands are pinned by tests; `vstest.console.exe /EnableCodeCoverage` is Windows Visual Studio tooling located through `vswhere` and does not emit the cobertura artifact (`TestResults/*/coverage.cobertura.xml`) that the modern `csharp-qa-gate` copies. Using `dotnet test` everywhere would contradict the canonical `.github/instructions` policy and the consumers' actual `vstest.console.exe` usage on .NET Framework and VSTO projects. MSTest is therefore the single framework, and each profile names one runner and command set.

## Technical Specifications

- Files expected to change: the files named in `## Scope`, each with its bundle copy, plus the generated `powershell-typed-engineer` Codex variants and the new guard test. Research Q2 lists every file and the exact token edits.
- Public interfaces and contracts affected: distributed policy text (rules, instructions, agents, skills, prompts, templates); argv lists and emitted command text in `scripts/dev_tools/atomic_executor` and `fix_all_branches_extra.py`.
- Data flow or validation adjustments: none beyond the coverage target change in D3.
- Logging/telemetry updates: none.
- Migration or backfill needs: none; consumers receive the new text on the next extension release.

## Test Strategy

- Regression tests to add or update:
  - New `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1`. Data-driven absence assertions over `.claude/rules`, `.claude/agents`, `.claude/skills`, `.agents/skills`, `.github/instructions`, `.github/agents`, `.github/prompts`, `.codex/agents`, `docs/features/templates`, `README.md`, and the bundle trees under `extensions/drm-copilot/resources/`. Forbidden phrases: `Use **xUnit**`, `xUnit +`, `xUnit toolchain`, `xUnit gate`, `xUnit coverage`, `xUnit scenario`, `Verify.Xunit`, `[Fact]`, `[Theory]`, `IClassFixture`, `Pester (v5.x)`, `Pester v5`, `--cov=src/lexile_corpus_tuner` (research Q4 list). The plan may add D4 other-project phrases after confirming no in-scope surface keeps them legitimately. An in-memory helper test proves the scan fails on reintroduced text. Files are read in place.
  - `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`: updated argv assertion.
- Invariant validation: before/after comparison of protected regions (research Q5) and same-line overlaps; existing contract tests in research Q4; generator `--check`.
- Edge cases: file paths with spaces (`Powershell DI Unit Test Engineer.agent.md`); words that legitimately keep `xUnit` (prohibition, generic CI list); CI shards on `windows-latest`.
- Error handling: the guard reports the file and phrase for each violation.
- Coverage: changed Python files meet 85% line and 75% branch, read from the single pytest gate run; no coverage drop on changed lines versus the Phase 0 baseline.
- Toolchain: format, lint, type-check, then one `Invoke-PoshQCParallelTest` run and one `poetry run pytest -n auto` run, each with zero failures; `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` exits 0.
- Evidence: store under `<FEATURE>/evidence/qa-gates/` with clock-read UTC stamps.

## Acceptance Criteria

- [x] No rule, instruction, agent, skill, prompt, template, README, or bundle copy names xUnit as this repository's C# test framework; the `Do not introduce xUnit or NUnit` prohibition and the generic multi-language CI list keep the word.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-07T15-25.md` (PTN- rows pass, PTN-HELPER-EXEMPT keeps the prohibition and the generic list)
- [x] Every C# surface names MSTest as the framework and uses MSTest idioms (`[TestClass]`/`[TestMethod]`, `[DataRow]`, `[ClassInitialize]`, `Verify.MSTest`).
  - Evidence: `evidence/qa-gates/parity-and-protected-regions.2026-11-07T15-13.md` (word diffs) and `evidence/qa-gates/pester-gate.2026-11-07T15-25.md` (PTN- rows)
- [x] Each C# profile names one runner and command set: the modern Claude pack names `dotnet test --collect:"XPlat Code Coverage"` on the VSTest runner with the `MSTest`, `Microsoft.NET.Test.Sdk`, and `coverlet.collector` package set; the Copilot, Codex default, legacy, and `csharp-atomic-executor` surfaces name `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`.
  - Evidence: `evidence/qa-gates/pytest-gate.2026-11-07T15-18.md` (test_claude_modern_csharp_profile_retains_modern_gate_commands passes); P1-T3 commit check (`/EnableCodeCoverage` count 1, no dotnet test/build in csharp-atomic-executor)
- [x] The spec records why one runner for every C# surface was not chosen.
  - Evidence: `spec.md` section `### Decision record: one runner per profile (D1)`
- [x] No surface states Pester v5 or v5.x as the supported version; each supported-version statement names Pester (v6.x) or Pester v6, and historical, CHANGELOG, test-comment, and fixture references are unchanged.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-07T15-25.md` (PTN- rows), `evidence/qa-gates/codex-generator-check.2026-11-07T15-01.md`, `evidence/qa-gates/parity-and-protected-regions.2026-11-07T15-13.md`
- [x] No approved or emitted command, task, or argv list carries `--cov=src/lexile_corpus_tuner`; each former site targets `--cov=scripts/dev_tools`, the dead `pyproject.toml` per-file-ignore is removed, and `test_qc_runner.py` asserts the new argv.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-07T15-25.md` (PTN-CODE), `evidence/qa-gates/pytest-gate.2026-11-07T15-18.md` (test_qc_runner.py 24 passed)
- [x] The PR description states the D3 Python behavior change (coverage now targets an existing package).
  - Evidence: PR #1108 body, summary bullet "Python behavior change (D3)" and the D3 behavior-change section; verified with `gh pr view 1108` on 2026-11-07.
  - pending pr-author (text prepared in `evidence/other/pr-body-notes.2026-11-07T15-26.md`)
- [x] Other-project example text (`lexile`, `gutenberg`) is replaced with neutral generic names in the D4 policy surfaces and their bundle copies; `clean_devcontainer.py` names and `LEXILE_TK_SCALE` are unchanged.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-07T15-25.md` (PTN- rows over lexile and gutenberg), `evidence/qa-gates/parity-and-protected-regions.2026-11-07T15-13.md`
- [x] Every changed mirror and bundle copy is byte-identical with its canonical source, the generated Codex variants are produced by `generate_codex_agent_variants.py` with `--check` clean, and the parity and contract tests in research Q4 pass.
  - Evidence: `evidence/qa-gates/parity-and-protected-regions.2026-11-07T15-13.md` (29 pairs EQUAL, generator --check exit 0), `evidence/qa-gates/pytest-gate.2026-11-07T15-18.md` (Q4 contract suites pass)
- [x] The `>= 90%` new-code coverage rule, the 85% line / 75% branch thresholds, and all parallel-only test command wording are byte-unchanged; same-line edits change only the named token.
  - Evidence: `evidence/qa-gates/parity-and-protected-regions.2026-11-07T15-13.md` (protected-token counts equal at MB and HEAD; same-line word diffs)
- [x] The owner authorization for editing canonical policy files is recorded in the orchestrator checkpoint and the PR body.
  - Evidence: checkpoint `owner_decisions`; PR #1108 body section `## Owner Authorization`; verified with `gh pr view 1108` on 2026-11-07.
  - pending pr-author (checkpoint record confirmed; PR-body text prepared in `evidence/other/pr-body-notes.2026-11-07T15-26.md`)
- [x] `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1` exists, passes, and its in-memory helper test fails on reintroduced forbidden text.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-07T15-25.md` (18 PTN- rows pass, including PTN-HELPER)
- [x] `Invoke-PoshQCParallelTest` and `poetry run pytest -n auto` pass with zero failures and no coverage drop on changed lines versus the Phase 0 baseline.
  - Evidence: `evidence/qa-gates/pester-gate.2026-11-07T15-25.md`, `evidence/qa-gates/pytest-gate.2026-11-07T15-18.md`, `evidence/qa-gates/coverage-threshold.2026-11-07T15-25.md`
- [x] Each changed Python file meets 85% line and 75% branch coverage, read from the gate run.
  - Evidence: `evidence/qa-gates/coverage-threshold.2026-11-07T15-25.md`

## Definition of Done

- [ ] All acceptance criteria above are checked off with evidence under `<FEATURE>/evidence/`.
- [ ] Toolchain pass completed (format, lint, type-check, test) in a single pass.
- [ ] Protected-region and same-line comparisons recorded as evidence.
