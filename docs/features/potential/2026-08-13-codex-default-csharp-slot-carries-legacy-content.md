# codex-default-csharp-slot-carries-legacy-content (Potential Bug)

- Date captured: 2026-08-13
- Author: Dan Moisan
- Status: Draft

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

On the Codex/Agents customization surface, the default (modern) C# slot carries classic-MSBuild, VSTO-era content. `.agents/skills/csharp/SKILL.md` and `.agents/skills/csharp-qa-gate/SKILL.md` document `msbuild TaskMaster.sln`, MSTest, Moq, `vstest.console.exe`, and `/p:Nullable=enable`, which is the legacy toolchain rather than the modern SDK-style toolchain the equivalent Claude-surface files describe.

## Environment

- OS/version: any
- Python version: n/a (defect is in Markdown resource payloads)
- Command/flags used: `push_down_codex_and_agents_customizations` with the default pack set (no `csharp-legacy` selection)
- Data source or fixture: `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/csharp/SKILL.md` and `.agents/skills/csharp-qa-gate/SKILL.md`

## Steps to Reproduce

1. Push the Codex/Agents customizations down without selecting the `csharp-legacy` pack.
2. Read the emitted `.agents/skills/csharp/SKILL.md` toolchain section.
3. Compare it against the equivalent Claude-surface modern file `.claude/rules/csharp.md`.

## Expected Behavior

The Codex/Agents default C# slot describes the modern SDK-style toolchain, matching the Claude-surface modern profile: `dotnet tool restore` plus `dotnet csharpier check .`, `dotnet build` with analyzers and solution-wide nullable enforced through `Directory.Build.props`, and `dotnet test --collect:"XPlat Code Coverage"` with xUnit, NSubstitute, and FluentAssertions.

## Actual Behavior

The Codex/Agents default C# slot describes the legacy toolchain:

- `dotnet tool run csharpier .` or `csharpier .`
- `msbuild TaskMaster.sln /t:Build /p:Configuration=Debug /p:Platform="Any CPU" /p:EnableNETAnalyzers=true /p:EnforceCodeStyleInBuild=true`
- `msbuild TaskMaster.sln /t:Build /p:Configuration=Debug /p:Platform="Any CPU" /p:Nullable=enable /p:TreatWarningsAsErrors=true`
- `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage` with MSTest and Moq

It also names a foreign repository's solution file (`TaskMaster.sln`) in the default, non-variant slot.

## Logs / Screenshots

- [x] Attached minimal logs or snippet
- Snippet: `.agents/skills/csharp/SKILL.md:16` — ``Command: `msbuild TaskMaster.sln /t:Build ...` ``

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

A consumer that selects the Codex/Agents default pack for a modern SDK-style repository receives legacy VSTO instructions naming a solution file that does not exist in their repository. The two customization surfaces disagree about what the default C# profile is.

## Suspected Cause / Notes

The Codex/Agents surface was derived from a snapshot that predated the modern C# profile split, so the default slot was never migrated when the Claude surface's `.claude/rules/csharp.md` and `.claude/skills/csharp-qa-gate/SKILL.md` were modernized. The `csharp-legacy` variant files on the Codex surface are near-duplicates of the default-slot files, which is consistent with that history.

Observed during research for issue #469 (legacy C# gate command correctness). It was deliberately left uncorrected there because that change's requirement set mandates that the default C# profile remain unchanged.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: a resource-contract assertion that the Codex/Agents default C# slot carries modern-toolchain markers and no classic-MSBuild markers, mirroring whatever assertion the Claude surface uses.
- [x] Integration scenario to retest: default-pack push-down for the Codex/Agents surface, plus the existing legacy-versus-modern mutual-exclusivity check.
- [x] Manual verification notes: compare the Codex default slot against the Claude modern profile field by field; the two surfaces should describe the same toolchain.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
