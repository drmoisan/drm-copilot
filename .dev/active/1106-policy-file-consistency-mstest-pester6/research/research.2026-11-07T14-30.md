# Research: policy-file consistency (MSTest, Pester 6, stray coverage path) — Issue #1106

- Issue: #1106
- Branch: `chore/policy-file-consistency`
- Requirements source: `docs/features/potential/promoted/2026-11-07-policy-file-consistency-mstest-pester6.md` (same content as `issue.md` and the `## Intent & Outcomes` and `## Scope` sections of `spec.md` in this feature folder)
- Researcher tool limits: Read, Grep, Glob, WebFetch, Write only. No `git` or `gh` was run. Facts that need either are marked **ORCHESTRATOR-CONFIRM**.
- Filename stamp note: the researcher has no shell, so the `research.<stamp>.md` stamp was not read from a host clock. **ORCHESTRATOR-CONFIRM** and rename if a clock-read stamp is required.

## Owner Authorization (recorded)

The owner explicitly authorized editing the canonical `.github/instructions` policy files and their mirrors for issue #1106 only. This overrides, for this issue only, the standing rule in `CLAUDE.md` (`## Policy Compliance Reading Order`: "These files are the canonical policy source. Do not modify them."). The plan must record this authorization in the orchestrator checkpoint (the issue's `## Constraints & Risks` also requires it).

Out of scope by owner ruling (located in `## Protected Regions` below so the plan can assert them byte-unchanged):

- the `>= 90%` coverage rule for new modules, classes, and methods (no add, remove, or reword);
- the 85% line and 75% branch thresholds;
- all parallel-only test command wording (the owner applies those edits from a separate draft).

## Current State Summary

The repository contains no C# project of its own. Verified by Glob over `**/*.{csproj,sln,cs,runsettings}`: the only hits are test fixtures (`tests/fixtures/codex_web_setup/solution-root/Alpha.sln`, `tests/fixtures/discovery_analyzers/dotnet/*`, `tests/fixtures/project_file_merge/*.csproj`), none of which is a test project. No workflow under `.github/workflows/` names `dotnet`, `vstest`, or `MSTest` (Grep, zero matches). The devcontainer Dockerfiles install the .NET SDK 10.0.403 but run no tests.

The C# surfaces are distributed policy for consumer repositories, organized as two deliberate profiles (language packs, issues #226, #269, #469):

- **Modern profile** (`csharp-modern` Claude pack, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/csharp-modern.json`): SDK-style .NET 8+, `dotnet build`, `Directory.Build.props`, `dotnet test --collect:"XPlat Code Coverage"`, xUnit, NSubstitute.
- **Legacy profile** (`csharp-legacy` packs, `.claude-variants/csharp-legacy/` and `.agents-variants/csharp-legacy/` + `.codex-variants/csharp-legacy/` in the bundles): .NET Framework / VSTO, `msbuild`, `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`, MSTest, Moq.
- The Copilot surface (`.github/instructions`, `.github/agents`) and the Codex default slot (`.agents/skills/csharp*`, `.codex/agents/csharp-typed-engineer*.toml`) carry legacy-flavored content (MSTest, `msbuild`, `vstest.console.exe`), as recorded for issue #469.

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` pins the profile split: `test_claude_modern_csharp_profile_retains_modern_gate_commands` requires `dotnet csharpier check .` and `dotnet build` and forbids `msbuild` and `/t:Rebuild` in `.claude/rules/csharp.md` and `.claude/skills/csharp-qa-gate/SKILL.md`.

## Q1. MSTest Framework, Runner, and Command Decision

### Per-surface inventory (framework / runner / test command named)

| Surface | Framework | Mocking | Runner and test command |
|---|---|---|---|
| `.claude/rules/csharp.md` (+ bundle) | xUnit (`[Fact]`, `[Theory]`, `[InlineData]`, `IClassFixture<T>`, `Verify.Xunit`) | NSubstitute | `dotnet test --collect:"XPlat Code Coverage"` |
| `.claude/agents/csharp-typed-engineer.md` (+ bundle) | xUnit | NSubstitute | `dotnet build`, `dotnet test` |
| `.claude/skills/csharp-qa-gate/SKILL.md` (+ bundle) | xUnit ("xUnit toolchain", "xUnit gate") | none named | `dotnet test tests/*.ArchitectureTests/*.csproj --no-build`; `dotnet test --collect:"XPlat Code Coverage"`; copies `TestResults/*/coverage.cobertura.xml` |
| `.claude/skills/invoke-csharp-engineer/SKILL.md` (+ bundle) | xUnit | none | none |
| `.claude/skills/feature-review-workflow/SKILL.md` (+ bundle) | none | none | `dotnet test --collect:"XPlat Code Coverage"` |
| `.github/instructions/csharp-unit-test.instructions.md` (+ bundle) | MSTest (`Microsoft.VisualStudio.TestTools.UnitTesting`); "Do not introduce xUnit or NUnit" | Moq | `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage` |
| `.github/instructions/csharp-code-change.instructions.md` (+ bundle) | defers to unit-test policy | — | `msbuild <solution>.sln /t:Build ...` (build only) |
| `.github/agents/csharp-typed-engineer.agent.md` (+ bundle) | MSTest | Moq | `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage` |
| `.github/agents/csharp-atomic-executor.agent.md` (+ bundle) | none named | none | `dotnet build -p:...`; `dotnet test --collect:"XPlat Code Coverage"` (section `### 7.1 C# policy and toolchain gates`) |
| `.github/agents/tdd-red.agent.md` (+ bundle) | xUnit (`### C# Test Patterns`), "Theory tests", AutoFixture | — | none |
| `.agents/skills/csharp/SKILL.md` (+ bundle) | MSTest | Moq | `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage` |
| `.agents/skills/csharp-qa-gate/SKILL.md` (+ bundle) | MSTest ("MSTest gate") | — | `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage` |
| `.agents/skills/invoke-csharp-engineer/SKILL.md` (+ bundle) | MSTest | — | none |
| `.agents/skills/feature-review-workflow/SKILL.md` (+ bundle) | none | — | `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage` |
| `.codex/agents/csharp-typed-engineer.toml` and `-c1`..`-c4`, `-c3-elevated` (+ bundle) | MSTest | Moq | `Bash(msbuild *)` permission |
| `.codex/agents/csharp-atomic-executor.toml` (+ bundle) | none | — | description names "dotnet test" |
| Legacy variants (`.claude-variants/csharp-legacy/rules/csharp.md`, `.../skills/csharp-qa-gate`, `.../skills/invoke-csharp-engineer`, `.../agents/csharp-typed-engineer.md`; `.agents-variants/csharp-legacy/skills/*`; `.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml`) | MSTest | Moq | `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage` |
| `README.md` (`## Language toolchain ecosystems`) | Modern: xUnit + NSubstitute + FluentAssertions, `Verify.Xunit`; Legacy: MSTest | — | Modern `dotnet test --collect:"XPlat Code Coverage"`; Legacy `vstest.console.exe` |
| `AGENTS.md` (root and bundle) | lists MSTest as a test-tool example | — | none |
| `.claude/rules/general-code-change.md` (+ bundle), `.agents/skills/general-code-change/SKILL.md` (+ bundle) | MSTest listed as an example in the toolchain loop | — | none |
| Pack manifests (`pack-manifests/csharp-modern.json`, `csharp-legacy.json` in both bundles) | paths only | — | none |

Executed-code evidence (what consumers actually run):

- `.codex/codex-web-setup.sh` (+ bundle copy): `verify_windows_visual_studio_task_capability` locates `vstest.console.exe` through `vswhere` and fails with "Visual Studio test tooling required by the MSTest tasks is unavailable."; `install_dotnet_coverage` installs `dotnet-coverage` "for MSTest coverage collection"; `write_repo_notes` names `scripts/vscode/Invoke-MSTest.ps1` and `scripts/vscode/Invoke-MSTestWithCoverage.ps1` (consumer-repository scripts; they do not exist in this repository). Pinned by `tests/shell/test_codex_web_setup_codex_verify.bats`.
- `tests/fixtures/orchestration-handoff/taskmaster-469/{claude-to-codex,codex-to-claude}/plan.2026-08-29T12-22.md`: a real consumer plan runs `vstest.console.exe` over built test assemblies with `/Settings:...runsettings /InIsolation /TestCaseFilter:... /Logger:trx`, and collects Cobertura through `dotnet-coverage` via `Invoke-MSTestWithCoverage.ps1`.
- No repository script, workflow, devcontainer, or fixture runs `dotnet test`. No file names `MSTest.Sdk`, `MSTest.TestFramework`, `MSTest.TestAdapter`, or `Microsoft.Testing.Platform` (Grep, zero production matches).

External fact (verified by WebFetch of the Microsoft Learn article "MSTest SDK configuration", `learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-mstest-sdk`): "By default, MSTest.Sdk uses the MSTest runner with MTP, including with dotnet test", coverage under MTP is the `Microsoft.Testing.Extensions.CodeCoverage` extension driven by `--coverage`, and VSTest is selected with `<UseVSTest>true</UseVSTest>`. `--collect:"XPlat Code Coverage"` is the VSTest data-collector form (coverlet collector), so the modern command remains valid for MSTest only on the VSTest runner.

### Recommendation

Framework (every C# surface): **MSTest** (`Microsoft.VisualStudio.TestTools.UnitTesting`; `[TestClass]`, `[TestMethod]`, `[DataRow]` for data-driven tests, `[ClassInitialize]` for shared class setup; `Verify.MSTest` for golden tests) with **FluentAssertions**.

Runner and commands: one per profile, consistent inside each profile.

- Legacy / Copilot / Codex-default surfaces (already MSTest): runner **`vstest.console.exe`**, command `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`. No change, except aligning `csharp-atomic-executor` (decision D2).
- Modern Claude pack: runner **`dotnet test` on the VSTest runner**, command `dotnet test --collect:"XPlat Code Coverage"` (unchanged). The rule names the MSTest package set that keeps this command valid: the `MSTest` package (framework plus adapter) with `Microsoft.NET.Test.Sdk` and `coverlet.collector`, or `MSTest.Sdk` with `<UseVSTest>true</UseVSTest>`.

Evidence for the choice:

1. The canonical policy (`.github/instructions/csharp-unit-test.instructions.md`, authoritative per `CLAUDE.md`) and the only executed consumer evidence (`.codex/codex-web-setup.sh`, the taskmaster-469 fixtures) name MSTest. The owner states xUnit is never used. MSTest is therefore the single framework.
2. The modern profile is host-neutral and runs on Linux (`.claude/rules/csharp.md` "host-neutral .NET foundation"; `csharp-qa-gate` emits `artifacts/csharp/coverage.xml` "the same canonical artifact as CI"). `vstest.console.exe` with `/EnableCodeCoverage` is a Windows Visual Studio tool located through `vswhere` (as `.codex/codex-web-setup.sh` shows), so naming it in the modern profile would make that profile unrunnable on Linux.
3. `test_claude_modern_csharp_profile_retains_modern_gate_commands` forbids `msbuild` in the modern files; the pack design (#226/#269/#469) deliberately separates the two build/run chains.
4. Keeping `dotnet test --collect:"XPlat Code Coverage"` keeps the `csharp-qa-gate` step that copies `TestResults/*/coverage.cobertura.xml` valid (coverlet writes that file); MTP `--coverage` writes a different format and location.

Rejected alternatives:

- **`vstest.console.exe` everywhere**: literally satisfies "same runner" but rewrites the modern profile to Windows-only tooling, breaks `test_claude_modern_csharp_profile_retains_modern_gate_commands`, and contradicts the `Directory.Build.props`/SDK-style content of the modern rule.
- **`dotnet test` everywhere**: contradicts the canonical `.github/instructions` and the consumer's actual `vstest.console.exe` usage on legacy .NET Framework/VSTO projects.
- **MSTest.Sdk on MTP for the modern profile** (`dotnet test -- --coverage`): changes the modern command and the coverage artifact path; no repository evidence of MTP use.

**Decision D1 (owner)**: the early-draft AC "Every C# surface names the same MSTest framework, runner, and commands" cannot be met literally without collapsing the two profiles. Recommended AC wording: "Every C# surface names MSTest as the framework; every surface of a profile names that profile's single runner and command set (modern: `dotnet test --collect:"XPlat Code Coverage"`; legacy and Copilot/Codex default: `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`)."

## Q2. Inventory of Production Surfaces to Change

Exclusions applied: `docs/features/{active,completed,archive,epics,parallel,potential}/**`, `docs/research/**`, `docs/engineering/process-reductions/**`, `virtual/**` (scratch debug artifacts). `docs/features/templates/**` is a production template, not a record, and is included.

### Item 1 — xUnit to MSTest (11 files; 15 with D2)

Each `(+ bundle)` line means the same edit, byte-identical, in the bundle copy.

1. `.claude/rules/csharp.md` (+ `extensions/drm-copilot/resources/claude-customizations/.claude/rules/csharp.md`):
   - frontmatter `description`: `(xUnit)` → `(MSTest)`; `paths:` unchanged.
   - intro sentence: `foundation: xUnit, NSubstitute, FluentAssertions,` → `foundation: MSTest, NSubstitute, FluentAssertions,`.
   - `## Toolchain` item 4: `**Testing — xUnit + NSubstitute + FluentAssertions**` → `**Testing — MSTest + NSubstitute + FluentAssertions**`; the command text after it is unchanged.
   - `## Testing Standards`: `Use **xUnit** as the test framework with \`[Fact]\` and \`[Theory]\` attributes.` → `Use **MSTest** (\`Microsoft.VisualStudio.TestTools.UnitTesting\`) as the test framework with \`[TestClass]\` and \`[TestMethod]\` attributes, on the VSTest runner (the \`MSTest\` package with \`Microsoft.NET.Test.Sdk\` and \`coverlet.collector\`).`; `Use **\`[Theory]\` + \`[InlineData]\`**` → `Use **\`[TestMethod]\` + \`[DataRow]\`**`; `Use **\`IClassFixture<T>\`** to share expensive setup` → `Use **\`[ClassInitialize]\`** to share expensive setup`; `use xUnit \`Assert\`` → `use MSTest \`Assert\``.
   - `### Golden Tests`: `**Verify.Xunit**` → `**Verify.MSTest**`.
2. `.claude/agents/csharp-typed-engineer.md` (+ bundle): `description` `-> xUnit toolchain` → `-> MSTest toolchain`; opening paragraph `deterministic xUnit coverage` → `deterministic MSTest coverage`; workflow step 3 `xUnit scenario-level test strategy` → `MSTest scenario-level test strategy`.
3. `.claude/skills/csharp-qa-gate/SKILL.md` (+ bundle): `description` `-> xUnit toolchain` → `-> MSTest toolchain`; `## Gate Requirements (Hard Gate)` bullet `**xUnit gate**` → `**MSTest gate**` (rest of the line unchanged; see Protected Regions).
4. `.claude/skills/invoke-csharp-engineer/SKILL.md` (+ bundle): `description` `-> xUnit toolchain` → `-> MSTest toolchain`; precondition bullet `Nullable Analysis, xUnit)` → `Nullable Analysis, MSTest)`.
5. `.github/agents/tdd-red.agent.md` (+ `extensions/drm-copilot/resources/customizations/.github/agents/tdd-red.agent.md`), `### C# Test Patterns`: `Use **xUnit** with **FluentAssertions**` → `Use **MSTest** with **FluentAssertions**`; `Implement **Theory tests** for multiple input scenarios` → `Implement **data-driven tests** (\`[DataRow]\`) for multiple input scenarios`.
6. `README.md` (`## Language toolchain ecosystems`): table row `Modern C# (.NET 8+, No-COM)` cell `xUnit + NSubstitute + FluentAssertions` → `MSTest + NSubstitute + FluentAssertions`; `### Modern C# (.NET 8+, No-COM)` bullet `(xUnit + NSubstitute + FluentAssertions)` → `(MSTest + NSubstitute + FluentAssertions)`; determinism paragraph `` `Verify.Xunit` `` → `` `Verify.MSTest` ``.

Decision D2 (recommended: include): align the Copilot/Codex `csharp-atomic-executor` surfaces with their own profile.

7. `.github/agents/csharp-atomic-executor.agent.md` (+ bundle): `description` `nullable/type safety, and dotnet test)` → `nullable/type safety, and MSTest)`; `## 6. Communication & Output Discipline` bullet `dotnet build (analyzers), and dotnet test.` → `msbuild (analyzers and nullable), and vstest.console.exe (MSTest).`; `### 7.1` list items 2–4 → the three commands of `.github/instructions/csharp-unit-test.instructions.md` `## 3. C# Toolchain Command Selection` items 2–4, each keeping the `or repo task equivalent` suffix.
8. `.codex/agents/csharp-atomic-executor.toml` (+ bundle): `description` `nullable and type safety, and dotnet test).` → `nullable and type safety, and MSTest).`

Reviewed and left unchanged (with reason):

- `.github/instructions/csharp-unit-test.instructions.md` (+ bundle) `Do not introduce xUnit or NUnit into existing test projects.`: a prohibition, not a statement that xUnit is the framework; it supports the MSTest choice.
- `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` (+ bundle) `(Jest, Vitest, Pytest, Go testing, JUnit, NUnit, XUnit, RSpec)`: a generic, multi-language CI example list (same line names Go, JUnit, RSpec), not this repository's C# framework.
- `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` sweep tokens `'xUnit delta'` and `'targeted xUnit'`: forbidden-wording guards for #1094, not framework statements; `PGW-SWEEP-HELPER` pins the token count at 38. Removing them weakens the guard and touches the owner's parallel-only wording area.
- `.claude/skills/feature-review-workflow/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/parallel-orchestrator.md`: modern `dotnet test`/`dotnet build` text with no framework name; consistent with the modern profile.
- All legacy variants and `.agents/.codex` C# files: already MSTest.
- `.codex/codex-web-setup.sh` (+ bundle): live code; already MSTest/`vstest.console.exe`.

Decision D5 (owner; recommended: leave): the modern profile names NSubstitute while Copilot/Codex/legacy name Moq. The issue does not mention mocking; changing it widens scope.

### Item 2 — Pester v5.x to Pester 6 (18 hand-edited files + 11 generated = 29)

Supported version evidence: `scripts/powershell/PoshQC/PoshQC.psm1` pins `@{ Name = 'Pester'; Version = '6.2.0'; UpperBound = '7.0.0' }`; `scripts/powershell/PoshQC/README.md` states "Pester 6.2.0 or later, below 7.0"; `README.md` already says "Pester 6.2.x"; `.devcontainer/README.md` says "Pester 6.2.0". Recommended wording: `(v6.x)` where the text says `(v5.x)`, and `Pester v6` where it says `Pester v5`.

Statements of the supported version (in scope):

1. `.claude/rules/powershell.md` (+ bundle): `## Toolchain` item 4 `**Testing — Pester (v5.x)**` → `**Testing — Pester (v6.x)**` (rest of the line is test-command wording; see Protected Regions); `## Testing Standards` `Use **Pester** (v5.x) as the test framework.` → `Use **Pester** (v6.x) as the test framework.`
2. `.agents/skills/powershell/SKILL.md` (+ bundle): the same two edits.
3. `.github/instructions/powershell-unit-test.instructions.md` (+ bundle), `## 1. Framework and Scope`: `**Pester** (v5.x).` → `**Pester** (v6.x).`
4. `.claude/agents/powershell-typed-engineer.md` (+ bundle): `deterministic Pester v5 coverage` → `deterministic Pester v6 coverage`.
5. `.codex/agents/powershell-typed-engineer.toml` (hand-edited base): `deterministic Pester v5 coverage` → `deterministic Pester v6 coverage`. The generator then rewrites the bundle base and the 10 variants (`-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` in `.codex/agents/` and in the bundle).
6. `.codex/agents/powershell-di-unit-test-engineer.toml` (+ bundle): `description` `Pester v5 unit tests` → `Pester v6 unit tests`.
7. `.github/agents/powershell-typed-engineer.agent.md` (+ bundle): `**Pester v5** tests` → `**Pester v6** tests`.
8. `.github/agents/Powershell DI Unit Test Engineer.agent.md` (+ bundle): `description` `Pester v5 unit tests` → `Pester v6 unit tests`; body bullet `Pester v5 unit tests (fast, deterministic, isolated)` → `Pester v6 unit tests (fast, deterministic, isolated)`.
9. `README.md`: table row `PowerShell` cell `Pester v5` → `Pester v6`; `### PowerShell` bullet `test (Pester v5):` → `test (Pester v6):`.
10. `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (+ `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`): row `| **Use Pester v5.x** |` → `| **Use Pester v6.x** |`, and `[Describe Pester v5 features used` → `[Describe Pester v6 features used`. No validator anchors on `Use Pester` (Grep over scripts and tests: no match outside the two templates and `pester.runsettings.psd1` comments).

Historical or behavior-specific references (out of scope, leave unchanged):

- `extensions/drm-copilot/CHANGELOG.md` (issue #953 entry, "installer minimum is now Pester 5.9.0"): release history.
- Test-file comments describing Pester 5 behavior or authorship: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` and `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` ("Pester 5.x breakpoint mode"), `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1` ("Discovery-time variables ... in Pester 5"), `tests/scripts/claude-skills/epic-progress-report/*.Tests.ps1`, `tests/scripts/dev-tools/activate.Tests.ps1`, `tests/scripts/claude-hooks/validate-bash.Tests.ps1` (header comments).
- `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` assertion `'- Would install PowerShell modules: Pester 5.9.0'`: asserts host-bootstrap output against its fixture; changing it alters behavior under test.
- `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` exemplar row ("PowerShell Pester 5, injectable seams"): fixture text.
- `docs/research/**` and `docs/features/**` records.

### Item 3 — `lexile` and `--cov=src/lexile_corpus_tuner`

`src/lexile_corpus_tuner` does not exist (Grep over `src/`: only `src/hello-typescript.ts`). `pyproject.toml` `[tool.coverage.run]` sets `source = ["src", "scripts/dev_tools", "packages/discovery-runtime/src"]`.

Correction to the issue text: `python-suppressions.instructions.md` carries no `--cov` or `poetry run` command (Grep, zero matches). It carries two code examples that name the other project (class (b) below).

(a) Approved command text in a policy surface (in scope; 2 files):

- `.github/instructions/python-unit-test.instructions.md` (+ `extensions/drm-copilot/resources/customizations/.github/instructions/python-unit-test.instructions.md`), `## 4. Respecting the Toolchain Loop`: `` `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` `` → recommended minimal edit `` `poetry run pytest --cov=scripts/dev_tools --cov-report=term-missing` ``. This line is also test-command wording, so it overlaps the owner's parallel-only draft (decision D3). No `.claude/rules/python.md` or `.agents/skills/python/SKILL.md` mirror carries the stray path.

(b) Example text belonging to the other project (policy or customization surfaces):

- `.github/instructions/python-suppressions.instructions.md` (+ bundle): `### S301` example `MODEL_PATH = Path(__file__).parent / "artifacts" / "lexile_model.pkl"`; `### TID252` example `from lexile_corpus_tuner.lexile_scoring_model.pipeline_scripts.gutenberg_query_core import (` with `from ..gutenberg_query_core import QueryGroupModel  # noqa: TID252`. Named by the issue; recommended neutral replacements: `"model.pkl"`, `from my_package.pipeline.query_core import (`, and `from ..query_core import QueryGroupModel  # noqa: TID252`.
- `.github/instructions/python-code-change.instructions.md` (+ bundle): `LexileCorpus`, `LexileModel`, `compute_lexile_score`, `“Lexile model”` (illustrative names).
- `.github/instructions/general-code-change.instructions.md` (+ bundle): `“Lexile model,”` in a module-purpose example.
- `.github/prompts/remediate-comments.prompt.md` (+ bundle): scope example `src/lexile_corpus_tuner/.../enrich_original_pub_year/**`.
- `.github/prompts/generate-commit-message-repo.prompt.md` (+ bundle): two example commit subjects.
- `.github/agents/commit-steward.agent.md` (+ bundle): example scope `(feat(lexile-scoring-model))`.
- `docs/features/templates/policy_audit/AGENTS.md` (+ `extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md`) and `docs/features/templates/policy_audit/README.md`: example audit subjects.

Decision D4 (owner): the issue says to keep other-project example text only if labelled, otherwise remove it. Recommended: neutralize the two `python-suppressions` examples (named in the issue); leave the remaining illustrative names unless the owner extends scope, because they are not commands and each removal edits another canonical policy file.

(c) Live code or configuration (changing it alters behavior):

| File | Symbol / location | Effect today |
|---|---|---|
| `.vscode/tasks.json` | task `QC: 4 Pytest: run tests with coverage` args `--cov=src/lexile_corpus_tuner` | coverage of a missing package; pytest-cov warns, `scripts/dev_tools` still measured |
| `scripts/dev_tools/atomic_executor/qc_runner.py` | `QCRunner.FULL_TEST`, and a second argv list | the only `--cov` target is the missing package, so the run measures nothing |
| `scripts/dev_tools/atomic_executor/qc_toolchain.py` | Python toolchain test argv | same |
| `scripts/dev_tools/atomic_executor/cli_preflight.py` | argv list and the emitted instruction text `poetry run pytest --cov=src/lexile_corpus_tuner ...` | emitted command text |
| `scripts/dev_tools/atomic_executor/prompt_builder.py` | prompt text `--cov=src/lexile_corpus_tuner --cov=scripts/dev_tools` | emitted command text |
| `scripts/dev_tools/fix_all_branches_extra.py` | argv list | same as above |
| `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` | `test_run_full...` asserts `calls[3] == [..., "--cov=src/lexile_corpus_tuner", ...]` | pins the argv; must change with `qc_runner.py` |
| `pyproject.toml` | `[tool.ruff.lint.per-file-ignores]` `"src/lexile_corpus_tuner/cli.py" = ["B008"]` | dead entry, no effect |
| `scripts/dev_tools/clean_devcontainer.py` | `DEFAULT_CONTAINER_NAME = "lexile-corpus-tuner-devcontainer"` and volume names | operational names |
| `scripts/dev_tools/tk_dialog_helpers.py` | env var `LEXILE_TK_SCALE` (pinned by `tests/scripts/dev_tools/test_copy_research_to_issue.py`) | public env-var name |
| `scripts/dev_tools/atomic_executor/__init__.py` | module docstring | none |

Decision D3 (owner). Recommendation:

- Include the six coverage-argument sites (`.vscode/tasks.json`, `qc_runner.py` (both), `qc_toolchain.py`, `cli_preflight.py` (both), `prompt_builder.py`, `fix_all_branches_extra.py`) plus `test_qc_runner.py`, because they emit or execute the same stray command that AC4 removes. Replace `--cov=src/lexile_corpus_tuner` with bare `--cov` where it is the only `--cov` argument (so `pyproject.toml` `source` applies), and delete it where `--cov=scripts/dev_tools` follows. This is a behavior change (coverage is measured where it was not); state it in the change description.
- Constraint: five Python production files exceed the direct-mode batch budget of three (`.claude/hooks/enforce-python-batch-budget.ps1`), so this needs the orchestrated large route.
- Overlap: `.vscode/tasks.json` holds the parallel VS Code tasks that the owner's parallel-only draft may edit. Edit only the serial task's argument token.
- Leave the `pyproject.toml` dead ignore, `clean_devcontainer.py`, `LEXILE_TK_SCALE`, and the docstring unchanged; they are not coverage paths or approved commands.
- If the owner prefers a policy-only change, defer all of class (c) and state that AC4 covers policy surfaces only.

## Q3. Mirror and Generation Topology

| Canonical file (edited by hand) | Mirrors | Hand or generated |
|---|---|---|
| `.github/instructions/<name>.instructions.md` | `extensions/drm-copilot/resources/customizations/.github/instructions/<name>.instructions.md` | hand, byte-identical |
| `.claude/rules/csharp.md`, `.claude/rules/powershell.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/<name>.md` | hand, byte-identical |
| `.claude/agents/<name>.md`, `.claude/skills/<name>/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/...` | hand, byte-identical |
| `.agents/skills/powershell/SKILL.md` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/powershell/SKILL.md` | hand, byte-identical |
| `.github/agents/<name>.agent.md`, `.github/prompts/<name>.prompt.md` | `extensions/drm-copilot/resources/customizations/.github/...` | hand, byte-identical |
| `.codex/agents/powershell-typed-engineer.toml` (base) | bundle base; `.codex/agents/powershell-typed-engineer-{c1,c2,c3,c3-elevated,c4}.toml` and their bundle copies | generated by `scripts/dev_tools/generate_codex_agent_variants.py` |
| `.codex/agents/powershell-di-unit-test-engineer.toml`, `.codex/agents/csharp-atomic-executor.toml` | bundle copies | hand (not in `GENERATED_AGENT_FAMILIES` of `scripts/dev_tools/resolve_codex_deployment.py`) |
| `docs/features/templates/policy_audit/*` | `extensions/drm-copilot/resources/templates/policy_audit/*` | hand, byte-identical |

The `.claude/rules/*.md` files are summaries, not byte mirrors, of `.github/instructions/*.instructions.md`; the C# pair already diverges by profile. `.claude-variants`, `.agents-variants`, and `.codex-variants` exist only in the bundles and need no change.

Generator facts (from `scripts/dev_tools/generate_codex_agent_variants.py`): `_synchronize` reads each `.codex/agents/<family>.toml` from the repository root, re-renders the root alias, writes the bundle alias and every variant in both roots, and rewrites `pack-manifests/*.json`. `--check` reports drift without writing.

Order of operations:

1. Edit each canonical file, then copy it byte-identically to its bundle mirror in the same task.
2. Edit `.codex/agents/powershell-typed-engineer.toml`, then run `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`, then `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` (exit 0). The batch-budget hook does not see generator writes.
3. Edit hand-mirrored Codex TOML files and their bundle copies.
4. Add or update tests, then run the contract tests (Q4) and the parallel gates.

Pushed-down copies reach consumer repositories only after an extension release and reinstall.

## Q4. Contract Tests

Must keep passing (wording or parity pins):

- `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`: `PGW-<Id>` rows `COPILOT-TDD-RED`/`-BUNDLE` (require `debugging only`), `COPILOT-PS-TYPED`/`-BUNDLE` (require `Invoke-PoshQCParallelTest`, forbid `mcp_drmcopilotext_run_poshqc_test`), `AUDIT-TEMPLATE`/`-BUNDLE`, `AUDIT-AGENTS`/`-BUNDLE`, `COPILOT-REMEDIATE-PROMPT`/`-BUNDLE`; `PGW-SWEEP-SURFACES` (new wording in `.claude/skills`, `.claude/agents`, `.github/agents`, `.codex/agents`, templates must not contain `targeted MSTest`, `MSTest delta`-style phrases or any other sweep token); `PGW-SWEEP-HELPER` (token count 38; unchanged if the tokens stay).
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (bundle equality), `test_claude_modern_csharp_profile_retains_modern_gate_commands` (modern files keep `dotnet build`, no `msbuild`), `test_claude_legacy_variant_files_contain_corrected_gate_commands` and `test_claude_legacy_variant_files_exclude_stale_gate_commands` (variants untouched).
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`: `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`, `test_codex_legacy_variant_files_*`.
- `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py`: `test_codex_orchestration_chain_agents_match_repo_sources` (includes `csharp-atomic-executor`), `test_shared_codex_skills_match_repo_agent_skill_sources`.
- Generator check: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`.
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`: no new files are bundled, so unaffected.
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`: new text must not name `TaskMaster` or `No-COM` in pushed rules and skills (`CONSUMING_NAMES`); `TaskMaster.sln` must not appear in `SOLUTION_SURFACES`. The proposed edits add neither.
- `tests/scripts/dev_tools/test_claude_rules_frontmatter.py`: `paths:` of `.claude/rules/csharp.md` and `.claude/rules/powershell.md` unchanged.
- `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`, `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py`, `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`: no pinned xUnit, MSTest, or Pester text (Grep); unaffected.
- `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`: `FOREIGN_COVERAGE_TARGET = "lexile_corpus_tuner"` asserts absence from `.github/workflows/_quality-checks.yml`; the workflow is untouched.
- `tests/shell/test_codex_web_setup_codex_verify.bats`: pins the MSTest message in `.codex/codex-web-setup.sh`; unaffected.
- Will change only under D3: `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py` (the `calls[3]` argv assertion in the `run_full` Python test).

No Python or Pester test enforcing byte equality between `.github/**` and `extensions/drm-copilot/resources/customizations/.github/**` was found, apart from the PGW rows (Grep over `tests/scripts/dev_tools` and the extension tests). **ORCHESTRATOR-CONFIRM**; the plan should assert equality of each changed pair by hash comparison.

New search-assertion test: recommended home is a new file, `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1`, in the scanned folder `tests/scripts` (`config/poshqc-scan.json`), so a shard picks it up automatically. Reasons: `parallel-gate-wording.Tests.ps1` (260 lines) is scoped to #1094 and is the file the owner's parallel-only draft is most likely to touch; `test_push_down_issue_824_follow_ups.py` is about 500 lines (guidance tier); PowerShell follows the standing preference against new Python. The guard must scan specific phrases, not bare `xUnit`, because `csharp-unit-test.instructions.md` and the generic CI list keep the word legitimately. Suggested forbidden phrases: `Use **xUnit**`, `xUnit +`, `xUnit toolchain`, `xUnit gate`, `xUnit coverage`, `xUnit scenario`, `Verify.Xunit`, `[Fact]`, `[Theory]`, `IClassFixture`; `Pester (v5.x)`, `Pester v5`, `Pester v5.x`; `--cov=src/lexile_corpus_tuner`. Suggested scope: `.claude/rules`, `.claude/agents`, `.claude/skills`, `.agents/skills`, `.github/instructions`, `.github/agents`, `.github/prompts`, `.codex/agents`, `docs/features/templates`, `README.md`, and the three bundles plus `extensions/drm-copilot/resources/templates`. Add an in-memory helper test (as `PGW-SWEEP-HELPER` does) so the guard is shown to fail on reintroduced text.

## Q5. Protected Regions (must stay byte-unchanged)

The `>= 90%` rule, in files this change edits:

- `.claude/skills/csharp-qa-gate/SKILL.md` (+ bundle), `## Gate Requirements (Hard Gate)`: `- **New modules, classes, or methods**: coverage >= 90% for each new unit introduced in the batch.`
- `.agents/skills/powershell/SKILL.md` (+ bundle), `## Testing Standards`: `- Any new module, class, or method must reach >= 90% coverage.`
- `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (+ bundle): row `| **Coverage expectation** |` with `Confirm new code has >= 90% coverage and repo-wide >= 80%.`
- Other locations not edited by this change (listed so a sweep can confirm them unchanged): `AGENTS.md` (+ bundle), `.github/instructions/general-unit-test.instructions.md` (+ bundle), `.agents/skills/{csharp,csharp-qa-gate,python,python-qa-gate,powershell-qa-gate,typescript}/SKILL.md` (+ bundles), and the legacy variants `.claude-variants/csharp-legacy/{rules/csharp.md,skills/csharp-qa-gate/SKILL.md}` and `.agents-variants/csharp-legacy/skills/{csharp,csharp-qa-gate}/SKILL.md`.

The 85%/75% thresholds in edited files: `.claude/rules/csharp.md` `### Coverage` first bullet; `.claude/rules/powershell.md` `## Testing Standards` line-coverage bullets. Not edited.

Parallel-only test wording in edited files (the owner's draft owns it):

- `.claude/skills/csharp-qa-gate/SKILL.md`: every `single gate run` phrase (description, `## When to Use This Skill`, `## Gate Requirements (Hard Gate)` intro and bullets), and the `## Prohibited Shortcuts` bullet ending `debugging only; it is never a gate or evidence, and the final gate is the single gate run.`
- `.claude/agents/csharp-typed-engineer.md`: `description` tail `quality gates read from the single gate run.`; workflow step 4 `Test and coverage results come from the single gate run. A focused run of one test file to debug a specific failure is debugging only.`
- `.claude/skills/invoke-csharp-engineer/SKILL.md`: `description` tail `quality gates read from the single gate run.`
- `.claude/rules/powershell.md` and `.agents/skills/powershell/SKILL.md`: `## Toolchain` item 4 text after the version token (`Run tests via MCP. MCP command: \`mcp__drm-copilot__run_poshqc_test\`. Use repo config at ...`).
- `.github/instructions/powershell-unit-test.instructions.md`: `## 1. Framework and Scope` bullet `**Agent execution requirement:** ... mcp_drmcopilotext_run_poshqc_test ...` and all of `## 4. Running the Toolchain (PowerShell Tests)`.
- `.github/instructions/python-unit-test.instructions.md`: `## 4. Respecting the Toolchain Loop` (the edited line itself; see D3).
- `.github/agents/powershell-typed-engineer.agent.md`, `.github/agents/Powershell DI Unit Test Engineer.agent.md` (`description` tail `and the parallel test gates.`), `.codex/agents/powershell-di-unit-test-engineer.toml` (same tail), `.github/agents/tdd-red.agent.md` (`debugging only` text), the policy-audit template (`N/A - no pre-change run`, `poetry run pytest -n auto`, `Invoke-PoshQCParallelTest`), and `README.md` `### PowerShell` test bullet after `(Pester v6):`.

Same-line overlaps: the token edits in `csharp-qa-gate` (`**xUnit gate**`), the three C# `description` lines, `.claude/rules/powershell.md` and `.agents/skills/powershell/SKILL.md` toolchain item 4, `README.md` PowerShell test bullet, and the `python-unit-test` approved command share a line with protected text. Each such task must change only the named token, and its acceptance must compare the line before and after with only that token substituted.

## Q6. Execution-Environment Brief

No fact stated by `.claude/skills/execution-environment/SKILL.md` changes. The brief already states "PowerShell selects Pester 6.2.0" and "separate Pester 6 processes"; it names no C# framework or runner and no `lexile` path. A new guard test is not a changed fact; adding it to `## Contract Tests That Pin Mirrored Files` is optional and would require all six byte-identical copies.

## Testing Strategy

- New Pester guard file (Q4) with data-driven rows over the scope, plus an in-memory helper test. No temporary files; read files in place as `parallel-gate-wording.Tests.ps1` does.
- Under D3: update `test_qc_runner.py` argv assertion; add a check that no `--cov=src/lexile_corpus_tuner` remains in the edited argv lists.
- Gates: one `Invoke-PoshQCParallelTest` run and one `poetry run pytest -n auto` run, each with zero failures; the generator `--check`; the Python contract suites named in Q4 run inside the pytest gate.

## Numeric Derivation Evidence

These counts support the inventory only. Recommendation: do not put numeric counts into `spec.md` acceptance criteria; the guard test asserts absence instead.

### Claim N1: xUnit framework statements in production surfaces = 11 files (excluding D2)

- Complete Family: non-record files whose text names xUnit as this repository's C# framework or toolchain.
- Exhaustive Search Scope: the whole worktree excluding `docs/**` (records), `virtual/**`; `docs/features/templates/**` checked separately (no match).
- Inclusion Rules: framework, toolchain, gate, or golden-test statements naming xUnit.
- Exclusion Rules: prohibitions (`csharp-unit-test.instructions.md` + bundle), generic multi-language lists (`github-actions-ci-cd-best-practices.instructions.md` + bundle), guard tokens in `parallel-gate-wording.Tests.ps1`.
- Primary Search Strategy or Query Expression: Grep `(?i)xunit`, glob `!docs/**`, content mode.
- Primary Member Set: `.claude/rules/csharp.md`, bundle copy; `.claude/agents/csharp-typed-engineer.md`, bundle; `.claude/skills/csharp-qa-gate/SKILL.md`, bundle; `.claude/skills/invoke-csharp-engineer/SKILL.md`, bundle; `.github/agents/tdd-red.agent.md`, bundle; `README.md`.
- Primary Count: 11.
- Cross-check Search Strategy or Query Expression: Grep `(?i)mstest|vstest|xunit|dotnet test|dotnet build|msbuild|Moq|NSubstitute|EnableCodeCoverage|XPlat` per directory (`.claude/skills`, `.claude/agents`, `.github/agents`, `.agents/skills`, `.codex/agents`), plus Grep `(?i)xunit|mstest|vstest|dotnet test` over `.github`, `tests`, `scripts`, `AGENTS.md`.
- Cross-check Member Set: `.claude/agents/csharp-typed-engineer.md`, `.claude/skills/csharp-qa-gate/SKILL.md`, `.claude/skills/invoke-csharp-engineer/SKILL.md`, `.github/agents/tdd-red.agent.md` (repository side; `.agents`, `.codex`, `scripts`, `AGENTS.md` show MSTest only), `.claude/rules/csharp.md` (read directly), each with the bundle copy found by the primary search; `README.md` (read directly).
- Cross-check Count: 11.
- Member-set Comparison: identical after normalizing bundle paths.

### Claim N2: Pester supported-version statements = 18 hand-edited files plus 11 generated

- Complete Family: non-record files stating Pester 5 as the supported or required framework version.
- Exhaustive Search Scope: whole worktree excluding `docs/**` except `docs/features/templates/**`.
- Inclusion Rules: rule, instruction, agent, skill, template, and README statements.
- Exclusion Rules: CHANGELOG history; test comments and fixtures listed under Item 2.
- Primary Search Strategy or Query Expression: Grep `(?i)Pester\s*\(?v?5|v5\.x|Pester 5|Pester v5`, glob `!**/docs/**`, files mode (38 files) minus exclusions, plus Grep of `docs/features/templates`.
- Primary Member Set: `.claude/rules/powershell.md`, `.agents/skills/powershell/SKILL.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/agents/powershell-typed-engineer.md`, `.codex/agents/powershell-typed-engineer.toml`, `.codex/agents/powershell-di-unit-test-engineer.toml`, `.github/agents/powershell-typed-engineer.agent.md`, `.github/agents/Powershell DI Unit Test Engineer.agent.md`, the policy-audit template, each with its bundle copy (17), plus `README.md` (18); generated: 5 root variants, bundle base, 5 bundle variants (11).
- Primary Count: 18 + 11.
- Cross-check Search Strategy or Query Expression: Grep `(?i)Pester\s*\(?v?5|v5\.x|Pester 5|Pester v5`, glob `!{docs,tests,node_modules}/**`, content mode, read line by line.
- Cross-check Member Set: the same files by line, with the 10 generated variant paths and the bundle base listed individually.
- Cross-check Count: 18 + 11.
- Member-set Comparison: identical.

## Pre-Mortem

- Review checklists: the policy-audit and code-review checklists will ask whether canonical policy files were edited; mitigation: record the owner authorization (this document, `## Owner Authorization`) in the checkpoint and the PR body, and cite issue #1106.
- Coverage: no production code changes unless D3 is approved; under D3, `qc_runner.py`, `qc_toolchain.py`, `cli_preflight.py`, `prompt_builder.py`, and `fix_all_branches_extra.py` each need per-file line >= 85% and branch >= 75% read from the single pytest gate run with `--cov=<dotted.module>`; the plan must name the dotted modules.
- Mirror parity: a missed bundle copy or a hand edit of a generated Codex variant fails `test_bundled_*_contains_all_repo_runtime_contracts` or the generator `--check`; mitigation: pair every canonical edit with its mirror in one task, run the generator after the base TOML edit, and hash-compare each `.github` pair because no automated test was found for that tree.
- File size: the new guard test is small; `parallel-gate-wording.Tests.ps1` (260 lines) and `test_push_down_issue_824_follow_ups.py` (about 500 lines) are not extended. Markdown is exempt.
- Test isolation: the new guard reads files in place with no temporary files, no mocks, and no script-scope state that leaks; it runs in a PoshQC shard alongside other suites, so it must not define global functions outside `BeforeAll`.
- CI-only behavior: the guard runs on `windows-latest` shards, and the Linux hook-suite job does not scan `tests/scripts/claude-runtime`; use `Join-Path` and forward-slash relative paths anyway. Bundle paths contain `Powershell DI Unit Test Engineer.agent.md` (spaces); quote it.
- Evidence: the PR body needs the generator `--check` output, the Pester and pytest gate results, and the before/after line comparisons for the same-line overlaps; store under `<FEATURE>/evidence/qa-gates/` with clock-read UTC stamps.

## Decision Points for the Owner

- D1: accept "MSTest everywhere; one runner per profile" in place of a single runner for all C# surfaces (recommended), or require one runner everywhere.
- D2: align `csharp-atomic-executor` (Copilot agent and Codex TOML, with bundles) to MSTest and `vstest.console.exe` (recommended: include).
- D3: include the live-code `--cov=src/lexile_corpus_tuner` sites and `test_qc_runner.py` (recommended: include, on the large route), and confirm that the `python-unit-test` approved-command line may be edited despite the overlap with the parallel-only draft (recommended: remove only the stray token).
- D4: scope of other-project example text (recommended: neutralize the two `python-suppressions` examples only).
- D5: modern profile mocking library NSubstitute versus Moq (recommended: leave unchanged).
- D6: AC wording: the absence guard scans specific phrases, so the prohibition line in `csharp-unit-test.instructions.md` and the generic CI list keep the word `xUnit` (recommended).
