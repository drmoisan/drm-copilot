# 2026-04-11-claude-code-architecture - Plan

- **Issue:** #136
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-11T19-55
- **Status:** Delivered
- **Version:** 1.0

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md)
- Python: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- TypeScript: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance and Baseline Capture

- [x] [P0-T1] Create the evidence directory structure at `docs/features/active/2026-04-11-claude-code-architecture-136/evidence/`, `evidence/baseline/`, and `evidence/qa-gates/`
  - Acceptance: `Test-Path 'docs/features/active/2026-04-11-claude-code-architecture-136/evidence'` returns `True`; `Test-Path 'docs/features/active/2026-04-11-claude-code-architecture-136/evidence/baseline'` returns `True`; `Test-Path 'docs/features/active/2026-04-11-claude-code-architecture-136/evidence/qa-gates'` returns `True`

- [x] [P0-T2] Read `.github/copilot-instructions.md` and record the tone policy requirements in the phase-0 evidence artifact
  - Acceptance: Evidence artifact `docs/features/active/2026-04-11-claude-code-architecture-136/evidence/baseline/phase0-instructions-read.md` created with fields `Timestamp:`, `Policy Order:`, and confirmation that `.github/copilot-instructions.md` was read

- [x] [P0-T3] Read `.github/instructions/general-code-change.instructions.md` and record the code change policy requirements in the phase-0 evidence artifact
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` updated to include confirmation that `general-code-change.instructions.md` was read

- [x] [P0-T4] Read `.github/instructions/general-unit-test.instructions.md` and record the unit test policy requirements in the phase-0 evidence artifact
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` updated to include confirmation that `general-unit-test.instructions.md` was read

- [x] [P0-T5] Read `.github/instructions/powershell-code-change.instructions.md` and record the PowerShell-specific requirements in the phase-0 evidence artifact (required because `.claude/hooks/validate-bash.ps1` is a new `.ps1` file)
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` updated to include confirmation that `powershell-code-change.instructions.md` was read

- [x] [P0-T6] Run baseline Python formatter check and record results
  - Acceptance: Evidence artifact `evidence/baseline/baseline-black.md` exists with fields `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, `Output Summary:` (pass/fail and file count)

- [x] [P0-T7] Run baseline Python linter and record results
  - Acceptance: Evidence artifact `evidence/baseline/baseline-ruff.md` exists with fields `Timestamp:`, `Command: poetry run ruff check .`, `EXIT_CODE:`, `Output Summary:` (violation count or clean status)

- [x] [P0-T8] Run baseline Python type checker and record results
  - Acceptance: Evidence artifact `evidence/baseline/baseline-pyright.md` exists with fields `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, `Output Summary:` (error count)

- [x] [P0-T9] Run baseline Python test suite with coverage and record results
  - Acceptance: Evidence artifact `evidence/baseline/baseline-pytest.md` exists with fields `Timestamp:`, `Command: poetry run pytest --cov --cov-report=term-missing`, `EXIT_CODE:`, `Output Summary:` (pass/fail counts and overall coverage %)

- [x] [P0-T10] Run baseline TypeScript formatter check and record results
  - Acceptance: Evidence artifact `evidence/baseline/baseline-prettier.md` exists with fields `Timestamp:`, `Command: npx prettier --check .`, `EXIT_CODE:`, `Output Summary:`

- [x] [P0-T11] Run baseline TypeScript linter and record results
  - Acceptance: Evidence artifact `evidence/baseline/baseline-eslint.md` exists with fields `Timestamp:`, `Command: npx eslint .`, `EXIT_CODE:`, `Output Summary:` (error and warning counts)

- [x] [P0-T12] Run baseline TypeScript compiler check and record results
  - Acceptance: Evidence artifact `evidence/baseline/baseline-tsc.md` exists with fields `Timestamp:`, `Command: npx tsc --noEmit`, `EXIT_CODE:`, `Output Summary:`

- [x] [P0-T13] Run baseline TypeScript test suite with coverage and record results
  - Acceptance: Evidence artifact `evidence/baseline/baseline-jest.md` exists with fields `Timestamp:`, `Command: npx jest --coverage`, `EXIT_CODE:`, `Output Summary:` (pass/fail counts and overall coverage %)

- [x] [P0-T14] Run baseline PowerShell formatter check via MCP and record results
  - Acceptance: Evidence artifact `evidence/baseline/baseline-poshqc-format.md` exists with fields `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE:`, `Output Summary:`

- [x] [P0-T15] Run baseline PowerShell analyzer via MCP and record results
  - Acceptance: Evidence artifact `evidence/baseline/baseline-poshqc-analyze.md` exists with fields `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE:`, `Output Summary:`

- [x] [P0-T16] Run baseline PowerShell tests via MCP and record results
  - Acceptance: Evidence artifact `evidence/baseline/baseline-poshqc-test.md` exists with fields `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE:`, `Output Summary:` (pass/fail counts and coverage %)

### Phase 1 — Layer 1: Standing Instructions

- [x] [P1-T1] Create `CLAUDE.md` at the repository root with these four required sections: (1) repository tone policy summary derived from `.github/copilot-instructions.md`, (2) policy compliance reading order from `.github/skills/policy-compliance-order/SKILL.md`, (3) explicit reference to `.claude/rules/` for modular language-specific rule loading, (4) architectural context describing the four-layer Claude Code model used in this repository; the file must not embed multi-step procedures — those belong in skills or subagents
  - Preconditions: Phase 0 complete; `.github/copilot-instructions.md` read at P0-T1
  - Acceptance: `Test-Path 'CLAUDE.md'` returns `True`; `(Select-String -Path 'CLAUDE.md' -Pattern 'tone|policy').Count` is ≥ 2; `(Select-String -Path 'CLAUDE.md' -Pattern '\.claude/rules').Count` is ≥ 1

- [x] [P1-T2] Create `.claude/rules/python.md` with YAML frontmatter `paths: ["**/*.py"]` and policy content summarized from `.github/instructions/python-code-change.instructions.md` and `.github/instructions/python-unit-test.instructions.md`
  - Acceptance: `Test-Path '.claude/rules/python.md'` returns `True`; `(Select-String -Path '.claude/rules/python.md' -Pattern 'paths:').Count` is 1; `(Select-String -Path '.claude/rules/python.md' -Pattern '\*\*\/\*\.py').Count` is ≥ 1

- [x] [P1-T3] Create `.claude/rules/powershell.md` with YAML frontmatter `paths: ["**/*.ps1", "**/*.psm1", "**/*.psd1"]` and policy content summarized from `.github/instructions/powershell-code-change.instructions.md` and `.github/instructions/powershell-unit-test.instructions.md`
  - Acceptance: `Test-Path '.claude/rules/powershell.md'` returns `True`; `(Select-String -Path '.claude/rules/powershell.md' -Pattern 'paths:').Count` is 1; `(Select-String -Path '.claude/rules/powershell.md' -Pattern '\.ps1').Count` is ≥ 1

- [x] [P1-T4] Create `.claude/rules/typescript.md` with YAML frontmatter `paths: ["**/*.ts"]` and policy content summarized from `.github/instructions/typescript-code-change.instructions.md` and `.github/instructions/typescript-unit-test.instructions.md`
  - Acceptance: `Test-Path '.claude/rules/typescript.md'` returns `True`; `(Select-String -Path '.claude/rules/typescript.md' -Pattern 'paths:').Count` is 1; `(Select-String -Path '.claude/rules/typescript.md' -Pattern '\*\*\/\*\.ts').Count` is ≥ 1

- [x] [P1-T5] Create `.claude/rules/csharp.md` with YAML frontmatter `paths: ["**/*.cs", "**/*.csproj"]` and policy content summarized from `.github/instructions/csharp-code-change.instructions.md` and `.github/instructions/csharp-unit-test.instructions.md`
  - Acceptance: `Test-Path '.claude/rules/csharp.md'` returns `True`; `(Select-String -Path '.claude/rules/csharp.md' -Pattern 'paths:').Count` is 1; `(Select-String -Path '.claude/rules/csharp.md' -Pattern '\.cs').Count` is ≥ 1

### Phase 2 — Layer 2: Skills

- [x] [P2-T1] Create `.claude/skills/orchestrate/SKILL.md` with complete frontmatter: `name: orchestrate`, `description:` (accurate and specific enough for automatic skill surfacing), `context: fork`, `agent: orchestrator`, `argument-hint: [objective]`; body must instruct the orchestrator to read policy from `CLAUDE.md` and `.claude/rules/`, resume state from `artifacts/orchestration/orchestrator-state.json`, delegate only through configured subagents, and not report completion until required artifacts and validation gates pass
  - Preconditions: Phase 1 complete
  - Acceptance: `Test-Path '.claude/skills/orchestrate/SKILL.md'` returns `True`; `(Select-String -Path '.claude/skills/orchestrate/SKILL.md' -Pattern 'context: fork').Count` is 1; `(Select-String -Path '.claude/skills/orchestrate/SKILL.md' -Pattern 'agent: orchestrator').Count` is 1; `(Select-String -Path '.claude/skills/orchestrate/SKILL.md' -Pattern 'argument-hint').Count` is 1

- [x] [P2-T2] Create `.claude/skills/commit-message/SKILL.md` with complete frontmatter: `name: commit-message`, `description:` (specific to commit message generation), `allowed-tools: [Read, "Bash(git log *)", "Bash(git diff *)"]`; body derived from `.github/agents/commit-message-conventions.agent.md` or `.github/skills/commit-message-conventions/SKILL.md` implementing the conventional commit message workflow
  - Acceptance: `Test-Path '.claude/skills/commit-message/SKILL.md'` returns `True`; `(Select-String -Path '.claude/skills/commit-message/SKILL.md' -Pattern 'allowed-tools').Count` is 1; `(Select-String -Path '.claude/skills/commit-message/SKILL.md' -Pattern 'Bash\(git log').Count` is ≥ 1; `(Select-String -Path '.claude/skills/commit-message/SKILL.md' -Pattern 'Bash\(git diff').Count` is ≥ 1

- [x] [P2-T3] Create `.claude/skills/pr-author/SKILL.md` with complete frontmatter: `name: pr-author`, `description:` (specific to PR body authoring), `allowed-tools: [Read, "Bash(git log *)"]`; body derived from `.github/agents/pr-authoring.agent.md` or `.github/skills/pr-authoring/SKILL.md` implementing the PR authoring workflow; file must NOT include `Bash(git push`, `Write`, or `Edit` in the allowed-tools list
  - Acceptance: `Test-Path '.claude/skills/pr-author/SKILL.md'` returns `True`; `(Select-String -Path '.claude/skills/pr-author/SKILL.md' -Pattern 'allowed-tools').Count` is 1; `(Select-String -Path '.claude/skills/pr-author/SKILL.md' -Pattern 'Bash\(git log').Count` is ≥ 1; `(Select-String -Path '.claude/skills/pr-author/SKILL.md' -Pattern 'Bash\(git push|Write|Edit').Count` is 0

- [x] [P2-T4] Create `.claude/skills/research-issue/SKILL.md` with complete frontmatter: `name: research-issue`, `description:` (specific to research task execution), `allowed-tools: [Read, Grep, Glob, WebFetch]`; body derived from `.github/prompts/research-issue.prompt.md` implementing the research task workflow
  - Acceptance: `Test-Path '.claude/skills/research-issue/SKILL.md'` returns `True`; `(Select-String -Path '.claude/skills/research-issue/SKILL.md' -Pattern 'WebFetch').Count` is ≥ 1; `(Select-String -Path '.claude/skills/research-issue/SKILL.md' -Pattern 'Grep').Count` is ≥ 1; `(Select-String -Path '.claude/skills/research-issue/SKILL.md' -Pattern 'allowed-tools').Count` is 1

### Phase 3 — Layer 3: Subagents

- [x] [P3-T1] Read `.github/agents/orchestrator.agent.md` to identify current specialist delegation targets and tool patterns before creating the Claude-native orchestrator subagent
  - Acceptance: A note in the executor's working log confirms which `Agent(...)` delegation targets appear in the canonical file; this step has no file output but blocks P3-T2

- [x] [P3-T2] Create `.claude/agents/orchestrator.md` with complete frontmatter: `name: orchestrator`, `description:` (deterministic repository orchestrator, proactive), `tools:` list including `Agent(atomic-planner,atomic-executor,feature-review,task-researcher)`, `Read`, `Grep`, `Glob`, `Bash`, `mcp__drmCopilotExtension__.*`; `model: sonnet`; `skills:` listing `policy-compliance-order`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `acceptance-criteria-tracking`; `memory: project`; `hooks:` Stop entry blocking termination unless checkpoint updated and required artifact paths confirmed; body must include explicit instruction to read `artifacts/orchestration/orchestrator-state.json` before new work and write updated checkpoint after each phase transition
  - Preconditions: P3-T1 complete; Phase 2 complete
  - Acceptance: `Test-Path '.claude/agents/orchestrator.md'` returns `True`; `(Select-String -Path '.claude/agents/orchestrator.md' -Pattern 'model: sonnet').Count` is 1; `(Select-String -Path '.claude/agents/orchestrator.md' -Pattern 'memory: project').Count` is 1; `(Select-String -Path '.claude/agents/orchestrator.md' -Pattern 'orchestrator-state\.json').Count` is ≥ 2

- [x] [P3-T3] Create `.claude/agents/atomic-planner.md` with complete frontmatter: `name: atomic-planner`, `description:` (planning-only, docs and artifacts paths), `tools:` list including `Read`, `Grep`, `Glob`, `"Edit(docs/**)"`, `"Edit(artifacts/**)"`, `"Write(docs/**)"`, `"Write(artifacts/**)"` — NO open-ended `Bash` or unconstrained `Write(/)`; `model: sonnet`; `skills: [atomic-plan-contract]`; `memory: project`; `hooks:` Stop entry blocking termination unless output plan file path confirmed; body derived from `.github/agents/atomic-planner.agent.md`
  - Acceptance: `Test-Path '.claude/agents/atomic-planner.md'` returns `True`; `(Select-String -Path '.claude/agents/atomic-planner.md' -Pattern 'Write\(docs').Count` is ≥ 1; `(Select-String -Path '.claude/agents/atomic-planner.md' -Pattern 'Write\(artifacts').Count` is ≥ 1; `(Select-String -Path '.claude/agents/atomic-planner.md' -Pattern '^  - Bash$').Count` is 0

- [x] [P3-T4] Create `.claude/agents/atomic-executor.md` with complete frontmatter: `name: atomic-executor`, `description:` (plan execution with explicit toolchain patterns), `tools:` list with explicit `Bash(...)` scoped patterns: `"Bash(poetry run black *)"`, `"Bash(poetry run ruff *)"`, `"Bash(poetry run pyright *)"`, `"Bash(poetry run pytest *)"`, `"Bash(npx prettier *)"`, `"Bash(npx eslint *)"`, `"Bash(npx tsc *)"`, `"Bash(npx jest *)"`, `"Bash(pwsh *)"`, `"Bash(git *)"`, `"mcp__drmCopilotExtension__.*"`, `Read`, `Grep`, `Glob`, `Edit`, `Write`; `model: sonnet`; `skills: [atomic-plan-contract, evidence-and-timestamp-conventions]`; `memory: project`; body derived from `.github/agents/atomic-executor.agent.md`
  - Acceptance: `Test-Path '.claude/agents/atomic-executor.md'` returns `True`; `(Select-String -Path '.claude/agents/atomic-executor.md' -Pattern 'Bash\(poetry run').Count` is ≥ 4; `(Select-String -Path '.claude/agents/atomic-executor.md' -Pattern 'Bash\(npx').Count` is ≥ 4; `(Select-String -Path '.claude/agents/atomic-executor.md' -Pattern '^  - Bash$').Count` is 0

- [x] [P3-T5] Create `.claude/agents/feature-review.md` with complete frontmatter: `name: feature-review`, `description:` (review specialist restricted to docs/features/active write path), `tools:` list including `Read`, `Grep`, `Glob`, `"Bash(git diff *)"`, `"Write(/docs/features/active/**)"` — NO unconstrained write patterns; `model: sonnet`; `skills: [policy-compliance-order, acceptance-criteria-tracking]`; `memory: project`; `hooks:` Stop entry blocking termination unless review artifact paths confirmed; body derived from `.github/agents/feature-review.agent.md`
  - Acceptance: `Test-Path '.claude/agents/feature-review.md'` returns `True`; `(Select-String -Path '.claude/agents/feature-review.md' -Pattern 'Bash\(git diff').Count` is ≥ 1; `(Select-String -Path '.claude/agents/feature-review.md' -Pattern 'Write\(/docs/features/active').Count` is ≥ 1; `(Select-String -Path '.claude/agents/feature-review.md' -Pattern 'Write\(/)').Count` is 0

- [x] [P3-T6] Create `.claude/agents/task-researcher.md` with complete frontmatter: `name: task-researcher`, `description:` (research specialist restricted to artifacts/research write path), `tools:` list including `Read`, `Grep`, `Glob`, `WebFetch`, `"Write(/artifacts/research/**)"` — NO write access outside `/artifacts/research/`; `model: sonnet`; `skills: [evidence-and-timestamp-conventions]`; `memory: project`; `hooks:` Stop entry blocking termination unless research artifact path confirmed; body derived from `.github/agents/task-researcher.agent.md`
  - Acceptance: `Test-Path '.claude/agents/task-researcher.md'` returns `True`; `(Select-String -Path '.claude/agents/task-researcher.md' -Pattern 'WebFetch').Count` is ≥ 1; `(Select-String -Path '.claude/agents/task-researcher.md' -Pattern 'Write\(/artifacts/research').Count` is ≥ 1

### Phase 4 — Layer 4: Enforcement

- [x] [P4-T1] Create `.claude/settings.json` with a `permissions` block containing: `allow` array with entries `"Bash(git *)"`, `"Bash(poetry run *)"`, `"Bash(pwsh *)"`, `"Bash(npx *)"`, `"Read"`, `"Edit(/docs/**)"`, `"Write(/docs/**)"`, `"Write(/artifacts/**)"`, `"mcp__drmCopilotExtension__.*"`, `"Skill(orchestrate *)"`, `"Skill(commit-message *)"`, `"Skill(pr-author *)"`, `"Skill(research-issue *)"` (13 entries minimum); `deny` array with entries `".env"`, `"**/.env"`, `"**/secrets/**"`, `"**/*.key"`, `"**/*.pem"` (5 entries minimum); `hooks.SubagentStop` array entry with matcher targeting `atomic-planner`, `atomic-executor`, `feature-review`, and `task-researcher` and hook body blocking stopping when required completion marker or artifact path is absent; `hooks.PreToolUse.Bash` entry invoking `.claude/hooks/validate-bash.ps1`; default permission mode set to `acceptEdits` — NOT `bypassPermissions`
  - Preconditions: Phase 3 complete
  - Acceptance: `Test-Path '.claude/settings.json'` returns `True`; `(Get-Content '.claude/settings.json' | ConvertFrom-Json).permissions.allow.Count` is ≥ 13; `(Get-Content '.claude/settings.json' | ConvertFrom-Json).permissions.deny.Count` is ≥ 5; `(Select-String -Path '.claude/settings.json' -Pattern 'SubagentStop').Count` is ≥ 1; `(Select-String -Path '.claude/settings.json' -Pattern 'PreToolUse').Count` is ≥ 1; `(Select-String -Path '.claude/settings.json' -Pattern 'bypassPermissions').Count` is 0

- [x] [P4-T2] Create `.claude/hooks/validate-bash.ps1` with dangerous-command detection blocking these exact patterns: `rm -rf`, `git push --force`, `git push origin --force`, `Remove-Item -Recurse -Force`, `git reset --hard`, `git push -f`; script accepts the incoming command string as input (via `$env:CLAUDE_TOOL_INPUT` or `$args[0]`), exits with code 1 when any blocked pattern is detected, and exits with code 0 when the command is safe
  - Acceptance: `Test-Path '.claude/hooks/validate-bash.ps1'` returns `True`; `(Select-String -Path '.claude/hooks/validate-bash.ps1' -Pattern 'rm -rf').Count` is ≥ 1; `(Select-String -Path '.claude/hooks/validate-bash.ps1' -Pattern 'git push --force').Count` is ≥ 1; `(Select-String -Path '.claude/hooks/validate-bash.ps1' -Pattern 'exit 1').Count` is ≥ 1; `(Select-String -Path '.claude/hooks/validate-bash.ps1' -Pattern 'exit 0').Count` is ≥ 1

### Phase 5 — Documentation

- [x] [P5-T1] Create `docs/engineering/claude-code-architecture.md` with section 1 — Copilot-to-Claude Equivalence Table: a Markdown table with columns `Copilot Primitive`, `Claude Equivalent`, `Notes` and rows for instruction files, direct-use prompts, specialist agents, reusable skills, and handoff metadata
  - Preconditions: Phase 4 complete
  - Acceptance: `Test-Path 'docs/engineering/claude-code-architecture.md'` returns `True`; `(Select-String -Path 'docs/engineering/claude-code-architecture.md' -Pattern 'Copilot Primitive|instruction files|specialist agents').Count` is ≥ 3

- [x] [P5-T2] Add section 2 to `docs/engineering/claude-code-architecture.md` — Non-Equivalences: explicitly state that `handoffs:` metadata has no direct Claude equivalent; document that the Claude-native substitute is the combination of named subagents + skill `context: fork` + `agent:` routing + checkpoint files + `SubagentStop` hooks; explicitly state that custom subagents cannot spawn further subagents from within a subagent invocation and that the orchestrator coordinates delegation from the main thread; explicitly state that `.claude/commands/` is a backward-compatibility surface only and `.claude/skills/` is the recommended surface for new user-invocable workflows
  - Acceptance: `(Select-String -Path 'docs/engineering/claude-code-architecture.md' -Pattern 'handoffs.*no direct|no.*direct.*handoffs|non-equivalen').Count` is ≥ 1; `(Select-String -Path 'docs/engineering/claude-code-architecture.md' -Pattern 'SubagentStop').Count` is ≥ 1; `(Select-String -Path 'docs/engineering/claude-code-architecture.md' -Pattern '\.claude/commands.*backward|backward.*\.claude/commands').Count` is ≥ 1

- [x] [P5-T3] Add section 3 to `docs/engineering/claude-code-architecture.md` — Sync Strategy: specify the authoritative source for each asset category (`.claude/rules/` derived from `.github/instructions/*.instructions.md`; `.claude/skills/` derived from `.github/skills/*/SKILL.md`; `.claude/agents/` maintained alongside `.github/agents/*.agent.md` with manual sync using diff); state that no `.claude/` file replaces a `.github/` file; describe the step-by-step manual sync procedure for each category
  - Acceptance: `(Select-String -Path 'docs/engineering/claude-code-architecture.md' -Pattern 'authoritative|authoritative source|sync strategy').Count` is ≥ 1; `(Select-String -Path 'docs/engineering/claude-code-architecture.md' -Pattern '\.github/instructions.*source|derived from.*\.github').Count` is ≥ 1

- [x] [P5-T4] Add section 4 to `docs/engineering/claude-code-architecture.md` — Validation Walkthrough: document a complete small-path orchestration run under Claude Code with specific file paths cited at each step in this sequence: (1) user invokes `/orchestrate`, (2) orchestrator reads `artifacts/orchestration/orchestrator-state.json`, (3) orchestrator delegates to `atomic-planner`, (4) `atomic-planner` writes plan to `docs/features/active/<feature>/plan.md`, (5) orchestrator delegates to `atomic-executor`, (6) executor runs toolchain and writes evidence, (7) orchestrator writes updated checkpoint; walkthrough must explicitly name at least two enforcement boundaries enforced by hooks or permissions (not prose) and state the expected block behavior for each named hook type
  - Acceptance: `(Select-String -Path 'docs/engineering/claude-code-architecture.md' -Pattern 'orchestrator-state\.json').Count` is ≥ 1; `(Select-String -Path 'docs/engineering/claude-code-architecture.md' -Pattern 'atomic-planner').Count` is ≥ 2; `(Select-String -Path 'docs/engineering/claude-code-architecture.md' -Pattern 'PreToolUse|SubagentStop').Count` is ≥ 2

### Phase 6 — Final QC Loop

- [x] [P6-T1] Run Python formatter check (`poetry run black --check .`) and record the QC result artifact
  - Acceptance: Evidence artifact `evidence/qa-gates/qc-black.md` exists with fields `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE: 0`, `Output Summary:`; if EXIT_CODE is non-zero, apply formatting fix and restart the QC loop from P6-T1

- [x] [P6-T2] Run Python linter (`poetry run ruff check .`) and record the QC result artifact
  - Acceptance: Evidence artifact `evidence/qa-gates/qc-ruff.md` exists with fields `Timestamp:`, `Command: poetry run ruff check .`, `EXIT_CODE: 0`, `Output Summary:`; if EXIT_CODE is non-zero, apply fix and restart from P6-T1

- [x] [P6-T3] Run Python type checker (`poetry run pyright`) and record the QC result artifact
  - Acceptance: Evidence artifact `evidence/qa-gates/qc-pyright.md` exists with fields `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE: 0`, `Output Summary:` stating 0 errors; if non-zero, fix and restart from P6-T1

- [x] [P6-T4] Run Python test suite with coverage (`poetry run pytest --cov --cov-report=term-missing`) and record the QC result artifact
  - Acceptance: Evidence artifact `evidence/qa-gates/qc-pytest.md` exists with fields `Timestamp:`, `Command: poetry run pytest --cov --cov-report=term-missing`, `EXIT_CODE: 0`, `Output Summary:` stating pass count and overall coverage %; if non-zero, fix and restart from P6-T1

- [x] [P6-T5] Run TypeScript formatter check (`npx prettier --check .`) and record the QC result artifact
  - Acceptance: Evidence artifact `evidence/qa-gates/qc-prettier.md` exists with fields `Timestamp:`, `Command: npx prettier --check .`, `EXIT_CODE: 0`, `Output Summary:`; if non-zero, fix and restart from P6-T1

- [x] [P6-T6] Run TypeScript linter (`npx eslint .`) and record the QC result artifact
  - Acceptance: Evidence artifact `evidence/qa-gates/qc-eslint.md` exists with fields `Timestamp:`, `Command: npx eslint .`, `EXIT_CODE: 0`, `Output Summary:`; if non-zero, fix and restart from P6-T1

- [x] [P6-T7] Run TypeScript compiler check (`npx tsc --noEmit`) and record the QC result artifact
  - Acceptance: Evidence artifact `evidence/qa-gates/qc-tsc.md` exists with fields `Timestamp:`, `Command: npx tsc --noEmit`, `EXIT_CODE: 0`, `Output Summary:`; if non-zero, fix and restart from P6-T1

- [x] [P6-T8] Run TypeScript test suite (`npx jest --coverage`) and record the QC result artifact
  - Acceptance: Evidence artifact `evidence/qa-gates/qc-jest.md` exists with fields `Timestamp:`, `Command: npx jest --coverage`, `EXIT_CODE: 0`, `Output Summary:` stating pass count and overall coverage %; if non-zero, fix and restart from P6-T1

- [x] [P6-T9] Run PowerShell formatter via MCP (`mcp__drmCopilotExtension__run_poshqc_format`) and record the QC result artifact
  - Acceptance: Evidence artifact `evidence/qa-gates/qc-poshqc-format.md` exists with fields `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE: 0`, `Output Summary:`; if EXIT_CODE is non-zero or files are changed, fix and restart from P6-T1

- [x] [P6-T10] Run PowerShell analyzer via MCP (`mcp__drmCopilotExtension__run_poshqc_analyze`) and record the QC result artifact
  - Acceptance: Evidence artifact `evidence/qa-gates/qc-poshqc-analyze.md` exists with fields `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE: 0`, `Output Summary:` stating 0 errors and 0 warnings; if non-zero, apply autofix and restart from P6-T1

- [x] [P6-T11] Run PowerShell tests via MCP (`mcp_drmcopilotext_run_poshqc_test`) and record the QC result artifact
  - Acceptance: Evidence artifact `evidence/qa-gates/qc-poshqc-test.md` exists with fields `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE: 0`, `Output Summary:` stating pass count and coverage %; if non-zero, fix and restart from P6-T1

- [x] [P6-T12] Validate YAML frontmatter presence in all `.claude/*.md`, `.claude/rules/*.md`, `.claude/skills/**/*.md`, and `.claude/agents/*.md` files by running `Get-ChildItem '.claude' -Recurse -Filter '*.md' | ForEach-Object { $c = Get-Content $_ -Raw; if (-not ($c -match '(?s)^---.*?---')) { Write-Error "Missing frontmatter: $_"; exit 1 } }; exit 0` and record the QC result artifact
  - Acceptance: Evidence artifact `evidence/qa-gates/qc-frontmatter.md` exists with fields `Timestamp:`, `Command:` (the exact command above), `EXIT_CODE: 0`, `Output Summary:` listing all validated file paths and confirming frontmatter present in each

### Phase 7 — Acceptance Criteria Verification

- [x] [P7-T1] Verify all 17 required output files exist by executing: `$files = @('CLAUDE.md','.claude/rules/python.md','.claude/rules/powershell.md','.claude/rules/typescript.md','.claude/rules/csharp.md','.claude/skills/orchestrate/SKILL.md','.claude/skills/commit-message/SKILL.md','.claude/skills/pr-author/SKILL.md','.claude/skills/research-issue/SKILL.md','.claude/agents/orchestrator.md','.claude/agents/atomic-planner.md','.claude/agents/atomic-executor.md','.claude/agents/feature-review.md','.claude/agents/task-researcher.md','.claude/settings.json','.claude/hooks/validate-bash.ps1','docs/engineering/claude-code-architecture.md'); $missing = $files | Where-Object { -not (Test-Path $_) }; if ($missing.Count -gt 0) { Write-Error "Missing files: $($missing -join ', ')"; exit 1 }; exit 0` and record the result in `evidence/qa-gates/qc-file-inventory.md`
  - Acceptance: `evidence/qa-gates/qc-file-inventory.md` exists with `EXIT_CODE: 0` and `Output Summary:` listing all 17 files as present

- [x] [P7-T2] Verify spec.md AC — `CLAUDE.md` content: confirm file contains tone policy, compliance reading order, `.claude/rules/` reference, and architectural context without embedded multi-step procedures
  - Acceptance: `(Select-String -Path 'CLAUDE.md' -Pattern 'tone|policy').Count` ≥ 2; `(Select-String -Path 'CLAUDE.md' -Pattern '\.claude/rules').Count` ≥ 1; corresponding AC checkbox in `spec.md` marked `[x]`

- [x] [P7-T3] Verify spec.md AC — `.claude/rules/` files: confirm all four language rule files exist, each has a `paths:` frontmatter field scoping it to the correct extension patterns, and each carries policy content
  - Acceptance: `(Get-ChildItem '.claude/rules' -Filter '*.md').Count` equals 4; each file's `(Select-String -Path $file -Pattern 'paths:').Count` is 1; corresponding AC checkboxes in `spec.md` marked `[x]`

- [x] [P7-T4] Verify spec.md AC — `.claude/skills/` files: confirm all four skill files exist, each has `name:`, `description:`, and either `allowed-tools:` or `context:`+`agent:` frontmatter fields
  - Acceptance: `(Get-ChildItem '.claude/skills' -Recurse -Filter 'SKILL.md').Count` equals 4; `(Select-String -Path '.claude/skills/**/*.md' -Pattern 'description:').Count` equals 4; `.claude/commands/` does not exist or is documented as backward-compatibility legacy; corresponding AC checkboxes in `spec.md` marked `[x]`

- [x] [P7-T5] Verify spec.md AC — `.claude/agents/` files: confirm all five subagent files exist, each has `tools:`, `model:`, `memory:`, `skills:`, and `hooks:` frontmatter fields, and no subagent uses an open-ended tool pattern
  - Acceptance: `(Get-ChildItem '.claude/agents' -Filter '*.md').Count` equals 5; `(Select-String -Path '.claude/agents/*.md' -Pattern 'model:').Count` equals 5; `(Select-String -Path '.claude/agents/*.md' -Pattern 'memory: project').Count` equals 5; `(Select-String -Path '.claude/agents/*.md' -Pattern '^  - Bash$').Count` equals 0; corresponding AC checkboxes in `spec.md` marked `[x]`

- [x] [P7-T6] Verify spec.md AC — `.claude/settings.json`: confirm permissions block, allow/deny arrays, SubagentStop hook, PreToolUse hook, and no bypassPermissions
  - Acceptance: All P4-T1 acceptance conditions confirmed; `(Select-String -Path '.claude/settings.json' -Pattern 'bypassPermissions').Count` is 0; corresponding AC checkboxes in `spec.md` marked `[x]`

- [x] [P7-T7] Verify spec.md AC — `docs/engineering/claude-code-architecture.md`: confirm equivalence table, non-equivalences with explicit `handoffs:` statement, `.claude/commands/` backward-compatibility statement, sync strategy, and end-to-end walkthrough with at least two named enforcement boundaries
  - Acceptance: All P5-T1 through P5-T4 acceptance conditions confirmed; corresponding AC checkboxes in `spec.md` marked `[x]`

- [x] [P7-T8] Verify user-story.md AC — orchestrator checkpoint behavior: confirm orchestrator subagent body includes instructions to read `artifacts/orchestration/orchestrator-state.json` before new work and write updated checkpoint after each phase transition
  - Acceptance: `(Select-String -Path '.claude/agents/orchestrator.md' -Pattern 'orchestrator-state\.json').Count` is ≥ 2; corresponding AC checkbox in `user-story.md` marked `[x]`

- [x] [P7-T9] Mark all delivered AC items in `spec.md` as `[x]` for the items verified in P7-T2 through P7-T7
  - Preconditions: P7-T2 through P7-T7 all complete
  - Acceptance: `(Select-String -Path 'docs/features/active/2026-04-11-claude-code-architecture-136/spec.md' -Pattern '- \[x\]').Count` is ≥ 10

- [x] [P7-T10] Mark all delivered AC items in `user-story.md` as `[x]` for the items verified in P7-T2 through P7-T8
  - Preconditions: P7-T2 through P7-T8 all complete
  - Acceptance: `(Select-String -Path 'docs/features/active/2026-04-11-claude-code-architecture-136/user-story.md' -Pattern '- \[x\]').Count` is ≥ 8

- [x] [P7-T11] Update this plan file: mark all completed tasks as `[x]` and set `Status: Delivered` in the metadata block
  - Acceptance: `(Select-String -Path 'docs/features/active/2026-04-11-claude-code-architecture-136/plan.2026-04-11T19-55.md' -Pattern 'Status: Delivered').Count` is 1

## Test Plan

No new automated unit tests are required for this feature. All 17 deliverable files are configuration, documentation, or a standalone hook script. Verification is performed through file-existence checks, frontmatter pattern matching, JSON structure validation, and toolchain regression runs in Phases 6 and 7.

The seeded validation scenarios in `spec.md` (tool restriction enforcement, SubagentStop gate verification, end-to-end orchestration run, checkpoint resume) require runtime access to a Claude Code session and are documented as manual validation scenarios in the Phase 5 walkthrough section of `docs/engineering/claude-code-architecture.md`.

## Open Questions / Notes

- The `.claude/agents/atomic-executor.md` `tools` list in Phase 3 is derived from the known toolchain commands. Before executing P3-T4, verify by running `Get-ChildItem '.github/agents' -Filter '*.agent.md'` to confirm whether additional specialist Bash patterns (e.g., `Bash(msbuild *)` for C# work) belong in the executor allowlist.
- Before executing P3-T2, verify the current list of specialist delegation targets by inspecting `.github/agents/orchestrator.agent.md` for any delegation targets not yet named in this plan (e.g., `prd-feature`, `python-typed-engineer`, `powershell-typed-engineer`, `typescript-engineer`). Extend the orchestrator `Agent(...)` allowlist to match.
- The `.claude/hooks/validate-bash.ps1` script must follow all PowerShell code change policy rules (formatting via `mcp__drmCopilotExtension__run_poshqc_format`, linting via `mcp__drmCopilotExtension__run_poshqc_analyze`) as verified in Phase 6. If PSScriptAnalyzer reports issues with the hook script, fix them before completing Phase 6.
