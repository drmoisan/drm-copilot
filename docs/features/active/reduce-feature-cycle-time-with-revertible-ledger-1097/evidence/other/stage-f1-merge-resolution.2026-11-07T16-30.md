# Stage F1 Merge Resolution (origin/main after PR #1108)

Timestamp: 2026-11-07T16-30
Command: git fetch origin; git merge --no-ff --no-commit origin/main; git checkout --conflict=diff3 on the five sources; SCRATCH/f1/issue-1097-f1-resolve.py (per hunk: verify PR #1108's side equals the base side with only the file's token pair renamed, keep this branch's side with the same pair renamed, then rename the pair on lines this branch added); copy each resolved source to its bundle copy; poetry run python -m scripts.dev_tools.generate_codex_agent_variants then --check; git add of the ten paths; git commit (merge)
EXIT_CODE: 0
Output Summary:
  origin/main at merge time: the PR #1108 merge commit (no further advance after the fetch). Merge commit has two parents (this branch's head and origin/main) and was pushed without force.
  Conflicted paths from git status: exactly the ten the plan names; no further conflicted path. The other 92 paths changed by origin/main since the merge base merged without conflict, 28 of them in the union of the 0006 and 0001 path sets (24 in the 0006 set).
  Per-hunk check: in all 7 conflict hunks PR #1108's side equalled the merge-base side with only the token pair renamed (mismatches 0), so keeping this branch's side with the pair renamed keeps both sides.
  Region resolutions:
    .claude/agents/csharp-typed-engineer.md: description hunk = E2 tail ("zero-regression quality gates ... compared with the `Phase 0 baseline`") with "MSTest toolchain"; Plan and baseline hunk = E2 baseline clause with "MSTest scenario-level test strategy"; intro paragraph auto-merged with PR #1108's "deterministic MSTest coverage"; steps 5 and 6 and the stop condition keep E2 text.
    .claude/skills/csharp-qa-gate/SKILL.md: description hunk = E2 sentence (Phase A baseline, zero-regression deltas) with "MSTest toolchain"; requirements hunk = E2 delta bullets with the first bullet named "MSTest delta" (PR #1108 renamed "xUnit gate" only; heading unchanged by PR #1108); Required Inputs and reporting block E2 lines swept.
    .claude/skills/invoke-csharp-engineer/SKILL.md: description hunk = E2 tail with "MSTest toolchain"; Applies list auto-merged with PR #1108's MSTest; reporting block E2 lines swept.
    .codex/agents/powershell-di-unit-test-engineer.toml: description = "Pester v6" plus the E2 tail "zero-regression gates on the parallel test gates against the `Phase 0 baseline`".
    .github/agents/Powershell DI Unit Test Engineer.agent.md: description = "Pester v6" plus "zero-regression gates"; argument-hint (same hunk, changed only by this branch) keeps "I will baseline"; test bullet auto-merged with PR #1108's "Pester v6"; handoff prompts and gate bullets keep E2 text.
  Sweep (lines this branch added per the stored 0006 patch, absent from origin/main, carrying the old token):
    .claude/agents/csharp-typed-engineer.md xUnit->MSTest 2 (both in conflict hunks)
    .claude/skills/csharp-qa-gate/SKILL.md xUnit->MSTest 4 (2 in hunks, 2 auto-merged: Required Inputs baseline record, reporting-block Baseline line)
    .claude/skills/invoke-csharp-engineer/SKILL.md xUnit->MSTest 3 (1 in hunk, 2 auto-merged: reporting-block Baseline and QA Gate Results lines)
    .codex/agents/powershell-di-unit-test-engineer.toml Pester v5->Pester v6 1
    .github/agents/Powershell DI Unit Test Engineer.agent.md Pester v5->Pester v6 1
    The other 12 sources in both the PR #1108 diff and the 0006 path set carry no old token (xUnit, Pester v5, dotnet test, dotnet build, Lexile, v5.x) on a line this branch added: 0 renames.
  Resolved sources differ from the pre-merge branch head by 14 token renames only (11 sweep renames plus 3 PR #1108 renames auto-merged); remaining old tokens in the five sources: 0.
  Mirrors: git hash-object equal for all five source and bundle pairs; before resolution each bundle's two sides equalled its source's sides.
  Codex generator: generate exit 0 with no file changed; --check exit 0.
  Conflict markers: 23 paths carry seven-character markers after the merge, the same 23 as at the pre-merge HEAD (21 tests/fixtures/project_file_merge fixtures, 2 archived documents); new marker paths 0; markers in the ten resolved paths 0.
  PR #1108 forbidden-phrase list of policy-toolchain-naming.Tests.ps1 (xUnit toolchain, xUnit gate, xUnit scenario, Nullable Analysis, xUnit, Pester v5, lexile, gutenberg, and the rest), searched case-insensitively over every path of the 0006 and 0001 path sets: 0 files.
  Tests asserting the wording (search of tests and extensions/drm-copilot/test for the five file names: 21 files, none carrying xUnit, MSTest, Pester v5, or Pester v6): unchanged because the resolution keeps PR #1108's names. policy-toolchain-naming.Tests.ps1 (added by PR #1108) asserts the absence of the old names: unchanged, and the sweep satisfies it. parallel-gate-wording.Tests.ps1 and test_codex_orchestration_contracts.py assert the E2 wording, which the resolution keeps: unchanged. No test found that disagrees.
  Scratch paths are recorded as SCRATCH.
