# Issue Update Mirror — Issue #469

Timestamp: 2026-08-13T17-28

PostedAs: unknown

POSTING BLOCKED — reason: this executor is prohibited from running any `gh` command. The orchestrator owns all Git and GitHub operations, so no comment or body update was posted to https://github.com/drmoisan/drm-copilot/issues/469. The exact text below is the intended update; the local `issue.md` checkbox state has already been updated to match.

## Exact update text

All fifteen acceptance criteria for issue #469 are delivered and verified.

**Content correction (AC1-AC8, AC15).** The four canonical `csharp-legacy` variant sources now document `dotnet tool restore`, `dotnet tool run csharpier format .`, and `dotnet tool run csharpier check .` for the formatting gate; `msbuild <solution>.sln /t:Rebuild /m /p:Configuration=Debug "/p:Platform=Any CPU" /p:EnableNETAnalyzers=true /p:EnforceCodeStyleInBuild=true` for the analyzer gate; and `msbuild <solution>.sln /t:Rebuild /m /p:Configuration=Debug "/p:Platform=Any CPU" /p:TreatWarningsAsErrors=true` for the compiler and nullable gate. The Codex-surface files keep the literal `TaskMaster.sln`; the Claude-surface files keep the `<solution>.sln` placeholder. The global CSharpier fallback and the `sln /t:Build` command form are removed. `/p:Nullable=enable` is removed from every documented command, including the Claude `rules/csharp.md` "Severity-first ordering invariant" cited fragment, and appears only in prohibition prose that tells the reader not to pass it. Gate ordering, the restart-from-formatting rule, zero-regression comparisons, the evidence and reporting contract, and the vstest test step are unchanged. The `README.md` "Legacy VSTO C# (.NET Framework)" section is updated to match.

**Regression tests (AC9-AC12).** Seven tests were added across four Python test files. Five content-contract tests read real repository bytes and assert the seven required substrings present and the three file-scoped forbidden literals absent in each of the four variant files, plus a span-scoped predicate that no backtick-delimited inline code span contains both `msbuild` and `/p:Nullable=enable`. One test pins the modern/default Claude C# profile as an unchanged baseline. Two repeated-generation determinism tests assert that two push-down generations into separate destination roots produce identical `{relative path: content}` maps on both engines. The four content-contract tests were authored before the fix and failed 4-of-4 against the stale content (fail-before evidence), then passed after the correction (pass-after evidence).

**Scope (AC13).** The change set is exactly the four `csharp-legacy` variant sources, `README.md`, four Python test files, and this feature's docs and evidence. Nothing under `packages/mcp-server/resources/**`, no modern/default C# profile file on either surface, no Codex default-slot file, no parallel-orchestration resource, and nothing under `.github/**` is modified. The pre-existing Codex default-slot defect remains out of scope and is recorded at `docs/features/potential/2026-08-13-codex-default-csharp-slot-carries-legacy-content.md`.

**Toolchain (AC14).** One final clean sequence: `poetry run black .` (0), `poetry run ruff check .` (0), `poetry run pyright` (0), `poetry run pytest --cov --cov-branch --cov-report=term-missing` (0; 3781 passed, line 92.30%, branch 84.66%), then in `extensions/drm-copilot`: `npm run format` (0), `npm run lint` (0), `npm run typecheck` (0), `npm run test:coverage` (0; 2495 passed, statements 96.57%, branches 89.90%). No stage rewrote a file, so no restart was required. Coverage is unchanged from baseline in both languages.

## Local mirror status

`issue.md` in this feature folder has AC1 through AC15 flipped from `- [ ]` to `- [x]`, checkbox characters only, with the file line count unchanged at 122 lines. `spec.md` is updated the same way, unchanged at 331 lines.
