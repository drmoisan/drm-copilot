# runbook-commands-not-checked-against-pinned-tool-versions (Spec)

- **Issue:** #1128
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T20-00
- **Status:** Draft
- **Version:** 0.2

## Context
The `human-exception-runbook` skill wrote a Windows packaging runbook that told the user to run `python -m nuitka --clean-cache=clcache`. Nuitka 4.3.4, the version pinned in the lockfile, rejects that value; `--clean-cache=all` works. Runbook commands are not checked against the pinned tool version.

Environment:
- OS/version: Windows 11 Pro, Claude Code
- Python version: per the iar-migration lockfile
- Command/flags used: `python -m nuitka --clean-cache=clcache`
- Data source or fixture: iar-migration E1 Windows packaging runbook, 2026-11-07/08

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Have the orchestrator invoke `human-exception-runbook` for a step that needs a tool command, in a repository whose lockfile pins the tool (Nuitka 4.3.4).
2. Read the generated runbook.
3. Run the command it gives.

Expected:
Every tool command in a runbook is either checked against the version pinned in the lockfile, or clearly marked as not verified, with the pinned version stated.

Actual:
The runbook gave a flag value the pinned version rejects, with no indication that the command had not been verified.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: Nuitka 4.3.4 rejects `--clean-cache=clcache`; `--clean-cache=all` is accepted.


## Scope & Non-Goals
- In scope:
  - A pure PowerShell module that resolves pinned tool versions from lockfile content, derives the tool name from a command line, and reports version-marking findings for a runbook.
  - A SubagentStop hook on the `human-exception-runbook` agent that blocks a runbook with findings.
  - Skill, agent, and example text changes, and all mirrors and bundle copies.
- Out of scope / non-goals:
  - Running tool `--help` automatically.
  - Verifying flag semantics mechanically. The gate enforces honest version marking, not command correctness.
  - A Codex hook (no Codex agent exists for this skill).
- Explicitly excluded systems, integrations, or datasets: none.

## Root Cause Analysis
The `human-exception-runbook` skill and agent source procedures MCP-first and web-second, but no rule or gate ties a tool command to the version pinned in the repository's lockfile, and no rule requires marking an unverified command. Nothing checks a written runbook.

## Proposed Fix

### Design summary (what changes where):
Add a `## Tool Command Version Rule` to the skill, a version-marker convention for runbooks, a pure checking module, and a SubagentStop hook that applies the module to the written runbook.

### Boundaries and invariants to preserve:
- The runbook's purpose (human-exception instructions) is not weakened; the gate adds marking, not restrictions on content.
- PowerShell only; no new Python.
- Module functions are pure over content strings; file reads happen only in the hook through injected seams.

### Dependencies or blocked work:
None.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- New `.claude/lib/runbook/RunbookCommandVersion.psm1`.
- New `.claude/hooks/validate-human-exception-runbook-output.ps1`, registered in the `hooks:` frontmatter of `.claude/agents/human-exception-runbook.md` the way `.claude/agents/pr-author.md` registers its hook.
- `.claude/skills/human-exception-runbook/SKILL.md` (new `## Tool Command Version Rule` section and a Conformance bullet) and `example.runbook.md` (a shell block with a marker).
- Agent file: states the rule, the return line `runbook_path: <path>`, and the hook.
- Mirrors: `.agents/skills/human-exception-runbook/` (keeps its own frontmatter and `.agents` path references); bundle copies under `extensions/drm-copilot/resources/claude-customizations/` and `codex-and-agents-customizations/`; the new module and hook are bundled and listed in the core pack manifest.

#### Functions/classes/CLI commands impacted:
- `Get-RunbookPinnedToolVersion`: lockfile name + content -> map of normalized tool name -> version. Formats: poetry.lock and uv.lock (`[[package]]` name/version), package-lock.json (`packages["node_modules/<name>"].version`), requirements*.txt (`name==version`). Normalization is PEP 503: lowercase, runs of `-`, `_`, `.` fold to `-`.
- `Get-RunbookCommandToolName`: command line -> tool. First token; `python -m X`, `python3 -m X`, `py -m X`, `poetry run X`, `uv run X`, `npx X` -> X.
- `Get-RunbookCommandVersionFinding`: runbook text + pinned map -> findings.
- Hook modeled on `validate-task-researcher-output.ps1`.

#### Data flow and validation changes:
Counted fences are those whose info string is empty or one of `sh`, `bash`, `shell`, `console`, `powershell`, `pwsh`, `ps1`, `cmd`, `bat`; other info strings (for example `text`, `json`, `output`) are exempt. Each non-blank, non-comment line of a counted fence is a command. Immediately after the closing fence the runbook carries one `Version check:` line per distinct tool of the block, in one of these forms:
- `Version check: verified against <tool> <version>`
- `Version check: not verified against <tool> <version>`
- `Version check: <tool> not pinned in this repository`

Findings: a counted block with a tool lacking a marker line; a marker naming a version different from the pinned version; a `not pinned` marker for a pinned tool; a malformed `Version check:` line. `verified` is permitted only when the command was checked against documentation or help for exactly the pinned version, cited in Source and Citation with the version.

#### Error handling and logging updates:
The hook reads `runbook_path:` from the last assistant message, resolves the item worktree through `Resolve-SubagentStopTargetWorktree`, reads the runbook and the top-level lockfiles beneath that root through injected read seams, and blocks repairably with every finding. A missing `runbook_path:` line or a missing file also blocks repairably. Module import and dot-sources use the hook dependency-guard pattern.

#### Rollback/feature-flag considerations (if applicable):
Remove the hook registration from the agent frontmatter to disable the gate.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
As listed under functions and data flow above. Agent return line: `runbook_path: <path>`.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
Existing runbooks are not re-validated. New runbooks containing counted shell blocks must carry marker lines.

#### Performance constraints (latency/throughput/memory):
Negligible; operates on one runbook and the top-level lockfiles.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): lockfiles of the supported formats exist at the item worktree root when a tool is pinned.
- Constraints (budget, performance, compatibility): PowerShell only; Pester tests with in-memory seams and no temporary files; parallel gate runs only.
- External dependencies (services, libraries, releases): none new.

## Data / API / Config Impact
- User-facing or API changes: runbooks gain `Version check:` lines after shell blocks.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): the core pack manifest lists the new module and hook.

## Test Strategy
- Regression tests to add or update: `tests/scripts/claude-lib/runbook/RunbookCommandVersion.Tests.ps1` and `tests/scripts/claude-hooks/validate-human-exception-runbook-output.Tests.ps1`, plus existing mirror and pack-manifest contract tests.
- Unit tests (Pester) for the fixed behavior and boundaries: lockfile resolution per format with normalization; tool-name extraction per launcher form; marker validation.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): mismatched version, `not pinned` for a pinned tool, malformed marker, exempt fences, comment and blank lines, missing `runbook_path:`, missing file.
- Error handling and logging verification: hook block messages list every finding.
- Coverage impact and targets for changed lines/modules: at least 85% line coverage on the new PowerShell files.
- Toolchain commands to run (format -> lint -> test): the repository PowerShell toolchain, run in parallel only.
- Manual validation steps (if required): none beyond the regression fixture.

## Acceptance Criteria
- [ ] Reproduction: a regression fixture of a runbook with `python -m nuitka --clean-cache=clcache` in a shell block, no marker, and a poetry.lock pinning nuitka 4.3.4 produces a finding naming nuitka and 4.3.4 (fails before the fix because no check exists; passes after).
- [ ] Lockfile resolution returns the pinned version for each supported format (poetry.lock, uv.lock, package-lock.json, requirements*.txt), with PEP 503 normalization.
- [ ] A marker naming the pinned version passes for both the `verified` and `not verified` forms; a mismatched version, a `not pinned` claim for a pinned tool, and a malformed marker each produce a finding; an unpinned tool with the `not pinned` form passes; exempt fences produce no finding.
- [ ] The SubagentStop hook blocks on findings, a missing `runbook_path:`, and a missing file, and allows a conformant runbook, with item-worktree resolution.
- [ ] Skill, agent, example, and all mirrors are updated; mirror and pack-manifest contract tests pass.
- [ ] Full toolchain passes with no new failures against the Phase 0 baseline and at least 85% line coverage on the new PowerShell files.

## Risks & Mitigations
- Technical or operational risks: false positives on commands that are not tool invocations (for example shell builtins); agents marking `verified` without checking; lockfile formats beyond the supported ones are treated as unpinned.
- Mitigations and rollbacks: the `not pinned` form is the sanctioned path for tools absent from every lockfile; the skill requires a version-bearing citation for `verified`; the gate enforces honest marking rather than correctness; rollback by removing the hook registration.

## Rollout & Follow-up
- Release/rollout steps: ship with the next extension release; destination repositories need a push-down refresh to receive the skill, agent, module, and hook.
- Post-fix monitoring or clean-up tasks: watch for false-positive blocks in the first runbooks produced after the refresh.
- Links: issue #1128, PRs, `human-exception-runbook` skill.
