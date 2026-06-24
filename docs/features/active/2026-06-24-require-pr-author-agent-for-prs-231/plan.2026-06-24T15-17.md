# require-pr-author-agent-for-prs - Plan

- **Issue:** #231
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-24T15-17
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature

## Required References

- Policy reading order: `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`
- Mirrored `.claude/rules/` files: `general-code-change.md`, `general-unit-test.md`, `powershell.md`, `quality-tiers.md`, `tonality.md`
- Spec: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/spec.md`
- Research: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/research/2026-06-24T15-45-pr-author-agent-enforcement-research.md`
- Issue: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/issue.md`

**All work must comply with these policies; do not duplicate their content here.**

## Scope Summary

Add a `pr-author` agent that runs the `pr-author` skill and is the only authorized caller of `gh pr create` and `gh pr edit --body*`. Enforcement uses an on-disk authorization sentinel (`artifacts/pr_author_authorization.json`) with a 120-second TTL, verified by the strengthened PreToolUse hook. A new SubagentStop validator hook confirms the agent reported a PR URL/number. Changes are mirrored across the Claude (root + bundled), Codex, and GitHub Copilot ecosystems.

## Enforcement Strength Disclosure (Non-Negotiable Wording)

This mechanism is a **policy guardrail, not a cryptographic or security control.** Any actor with `Write(/artifacts/**)` access can forge the sentinel because all agents share one filesystem and the runtime exposes no native agent-identity signal at Bash PreToolUse time (research Section 1.2, 2.1). It prevents accidental bypass (the PR #228 pattern) and requires a deliberate, documented act to circumvent. Every documentation artifact produced by this plan MUST state this and MUST NOT describe the sentinel as tamper-proof or as a security boundary (AC8).

## PowerShell Batch Discipline

PowerShell per-batch cap is 3 production files + 3 test files. Each PowerShell-touching task runs the PoshQC toolchain in order (`mcp__drm-copilot__run_poshqc_format` -> `mcp__drm-copilot__run_poshqc_analyze` -> `mcp__drm-copilot__run_poshqc_test`) and restarts from format on any failure or file change. The 500-line file limit applies to all production, test, and reusable script files.

## Acceptance-Criteria Mapping (spec Section 6)

- **AC1** (pr-author agent + mirrors + Codex/Copilot equivalents, tools allowlist, sentinel protocol): P3-T1..P3-T4, P5-T1..P5-T6
- **AC2** (no `gh pr create --body-file` without valid sentinel; D/E/F + malformed blocked): P1-T1..P1-T4
- **AC3** (`gh pr edit --body-file` subject to same checks; inline `--body` still Case A): P1-T2, P1-T5
- **AC4** (cross-ecosystem consistency; Claude root/bundled identical; Codex hook added/wired): P5-T1..P5-T7, P6-T7
- **AC5** (hook tests: allowed valid sentinel; blocked D/E/F/malformed/A/B/C; pre-existing pass): P1-T5, P1-T6
- **AC6** (orchestrate skill mandates delegation; settings permit `Agent(pr-author)`): P4-T1..P4-T5, P6-T8
- **AC7** (SubagentStop validator verifies PR URL/number, tested): P2-T1, P2-T2
- **AC8** (all docs characterize as guardrail, record forgeability): P3-T1, P5-T4, P5-T6, P6-T9

---

### Phase 0 — Compliance and PowerShell Baseline

- [x] [P0-T1] Read the policy files in required order and record evidence
  - Files: `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/baseline/phase0-instructions-read.md` exists with `Timestamp:`, `Policy Order:`, and the explicit list of files read

- [x] [P0-T2] Capture PowerShell format baseline for the in-scope hook and test files
  - Command: `mcp__drm-copilot__run_poshqc_format` (check mode) over `.claude/hooks/enforce-pr-author-skill.ps1` and `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/baseline/baseline-poshqc-format.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`

- [x] [P0-T3] Capture PSScriptAnalyzer baseline for the in-scope hook and test files
  - Command: `mcp__drm-copilot__run_poshqc_analyze` over `.claude/hooks/enforce-pr-author-skill.ps1` and `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/baseline/baseline-poshqc-analyze.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`

- [x] [P0-T4] Capture Pester baseline (with coverage) for the existing hook test suite
  - Command: `mcp__drm-copilot__run_poshqc_test` over `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` with coverage on `.claude/hooks/enforce-pr-author-skill.ps1`
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/baseline/baseline-pester.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording pass count and baseline line/branch coverage percentages for `enforce-pr-author-skill.ps1`

---

### Phase 1 — Strengthen PreToolUse Hook (`enforce-pr-author-skill.ps1`) + Tests

Production batch: 1 file (`.claude/hooks/enforce-pr-author-skill.ps1`). Test batch: 1 file (`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`). Within the PowerShell per-batch cap.

- [x] [P1-T1] Add the injectable sentinel-read seam and named TTL constant to `.claude/hooks/enforce-pr-author-skill.ps1`
  - Add `$script:PrAuthorAuthorizationPath = 'artifacts/pr_author_authorization.json'` and `$script:PrAuthorAuthorizationTtlSeconds = 120` as named constants
  - Add `Get-PrAuthorAuthorizationContents` (advanced function, `CmdletBinding`, `[OutputType([string])]`) returning the raw text of the sentinel file or `$null`/empty when absent; this is the test-injectable read seam
  - Acceptance: function and constants exist; dot-sourcing the script in a test scope exposes `Get-PrAuthorAuthorizationContents`; no behavior change to Cases A/B/C

- [x] [P1-T2] Add the injectable clock seam `Get-CurrentDateTimeUtc` to `.claude/hooks/enforce-pr-author-skill.ps1`
  - Function returns `[DateTime]::UtcNow`; injectable via `Mock` in tests for time-travel scenarios
  - Acceptance: `Get-CurrentDateTimeUtc` returns a `[DateTime]` in UTC and is resolvable when the script is dot-sourced

- [x] [P1-T3] Implement `Test-PrAuthorAuthorization` in `.claude/hooks/enforce-pr-author-skill.ps1` covering Cases D/E/F and malformed
  - Reads sentinel via `Get-PrAuthorAuthorizationContents`; computes elapsed via `Get-CurrentDateTimeUtc`
  - Returns `PR_AGENT_AUTHORIZATION_MISSING` when absent/empty; `PR_AGENT_AUTHORIZATION_MALFORMED` when not valid JSON or `issued_at` missing/unparseable; `PR_AGENT_AUTHORIZATION_INVALID` when `issued_by != "pr-author"`; `PR_AGENT_AUTHORIZATION_EXPIRED` when elapsed seconds > `ttl_seconds`; returns `$null` (allow) when all pass
  - Decision order inside the function matches spec FR-2 step 3 (missing -> malformed -> invalid issuer -> expired -> allow)
  - Acceptance: function returns the correct reason string for each scenario and `$null` for a valid in-TTL `pr-author` sentinel

- [x] [P1-T4] Wire `Test-PrAuthorAuthorization` into `Get-PrAuthorBypassReason` after the Case C check in `.claude/hooks/enforce-pr-author-skill.ps1`
  - After the existing Case C branch passes (`--body-file` present and context artifact exists), call `Test-PrAuthorAuthorization`; if it returns non-null, return that reason; otherwise return `$null`
  - Cases A and B continue to evaluate first and unchanged; `gh pr edit` with no body flag and read-only `gh pr` subcommands continue to short-circuit to allow
  - Update the script `.SYNOPSIS`/`.DESCRIPTION` header to document Cases D/E/F and to state the guardrail-not-cryptographic limitation (AC8)
  - Acceptance: file remains under 500 lines; `Get-PrAuthorBypassReason` returns the sentinel block reasons only on the `--body-file`-with-context path; Cases A/B/C unchanged

- [x] [P1-T5] Extend `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` with sentinel authorization contexts
  - Add contexts using mocks on `Get-PrAuthorAuthorizationContents` (sentinel content seam) and `Get-CurrentDateTimeUtc` (clock seam); no sentinel file written to disk, no `Start-Sleep`, no real `gh`
  - Cases (per spec 7.1): Case D missing -> `PR_AGENT_AUTHORIZATION_MISSING`; Case E `issued_by: "orchestrator"` within TTL -> `PR_AGENT_AUTHORIZATION_INVALID`; Case F `issued_by: "pr-author"` `issued_at` 300 s before injected clock -> `PR_AGENT_AUTHORIZATION_EXPIRED`; malformed JSON (`{not-json`) -> `PR_AGENT_AUTHORIZATION_MALFORMED`; malformed missing `issued_at` -> `PR_AGENT_AUTHORIZATION_MALFORMED`; valid `pr-author` `issued_at` 5 s before injected clock within TTL -> allow
  - Acceptance: each new `It` asserts the documented decision/reason; tests are deterministic and create no temporary files

- [x] [P1-T6] Verify backward-compatibility test cases for Cases A/B/C and `gh pr edit --title` remain unmodified and pass in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
  - Confirm the pre-existing Case A (inline `--body`), Case B (no body flag), Case C (context absent), allowed `--body-file` with context, `gh pr edit --title`, and read-only `gh pr` contexts retain their original expectations
  - Acceptance: pre-existing `It` blocks are unchanged in expectation; full file runs green

- [x] [P1-T7] Run the PowerShell QA loop for Phase 1 and capture coverage evidence
  - Commands in order: `mcp__drm-copilot__run_poshqc_format` -> `mcp__drm-copilot__run_poshqc_analyze` -> `mcp__drm-copilot__run_poshqc_test` (coverage on `.claude/hooks/enforce-pr-author-skill.ps1`); restart from format if any step fails or changes files
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/p1-enforce-hook-qa.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording pass count and post-change line >= 85% / branch >= 75% coverage on `enforce-pr-author-skill.ps1`

---

### Phase 2 — SubagentStop Validator Hook (`validate-pr-author-output.ps1`) + Tests

Production batch: 1 new file. Test batch: 1 new file. Within the PowerShell per-batch cap.

- [x] [P2-T1] Create `.claude/hooks/validate-pr-author-output.ps1`
  - Reads `CLAUDE_HOOK_INPUT`, parses JSON, reads `.output`; allows (exit 0) when output contains a PR URL (`github.com/.*/pull/\d+`), a `PR #\d+` reference, or a `gh pr create`/`gh pr edit` confirmation with a PR number; blocks (exit 1) when output is empty, `CLAUDE_HOOK_INPUT` is empty, JSON is malformed, or no PR URL/number is present
  - Use advanced functions with `CmdletBinding`, an injectable detection helper for testability, and a dot-source guard (`if ($MyInvocation.InvocationName -eq '.') { return }`) so tests can import functions without running the entrypoint
  - Header `.DESCRIPTION` states the guardrail-not-cryptographic framing consistent with AC8
  - Acceptance: file is under 500 lines; functions are dot-sourceable; entrypoint exits 0/1 per the rules above

- [x] [P2-T2] Create `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1`
  - Scenarios (spec 7.2): PR URL present -> allow; `gh pr create`/`edit` confirmation with PR number -> allow; output empty -> block; output without PR URL/number -> block; `CLAUDE_HOOK_INPUT` empty -> block; malformed JSON -> exit 1
  - Tests supply `CLAUDE_HOOK_INPUT` content via the function seam or scoped env assignment with restore-in-`finally`; no temporary files; no real `gh`
  - Acceptance: each `It` asserts the documented exit code/decision; suite is deterministic

- [x] [P2-T3] Run the PowerShell QA loop for Phase 2 and capture coverage evidence
  - Commands in order: `mcp__drm-copilot__run_poshqc_format` -> `mcp__drm-copilot__run_poshqc_analyze` -> `mcp__drm-copilot__run_poshqc_test` (coverage on `.claude/hooks/validate-pr-author-output.ps1`); restart from format if any step fails or changes files
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/p2-validate-output-qa.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording pass count and line >= 85% / branch >= 75% coverage on `validate-pr-author-output.ps1`

---

### Phase 3 — `pr-author` Agent Definition (Claude root)

- [x] [P3-T1] Create `.claude/agents/pr-author.md` with the required frontmatter and tools allowlist
  - Frontmatter: `name: pr-author`; descriptive `description`; `model: sonnet`; `skills: [pr-author]`; `memory: project`; tools allowlist exactly `Read`, `Bash(git log *)`, `Bash(git rev-parse *)`, `Bash(gh pr create *)`, `Bash(gh pr edit *)`, `Write(/artifacts/**)`; `hooks.SubagentStop` matcher `"pr-author"` wired to `pwsh -NoProfile -File .claude/hooks/validate-pr-author-output.ps1`
  - Acceptance: frontmatter parses; tools list matches spec FR-1 exactly including `Write(/artifacts/**)`

- [x] [P3-T2] Document the sentinel write-before / delete-after protocol in the `.claude/agents/pr-author.md` system prompt
  - Body instructs: before any `gh pr create` or `gh pr edit --body*`, (a) run `git rev-parse HEAD` for `head_sha`, (b) write `artifacts/pr_author_authorization.json` with `issued_by: "pr-author"`, `issued_at` as UTC ISO-8601, `head_sha`, `ttl_seconds: 120`, (c) issue the `gh` command immediately within TTL, (d) delete `artifacts/pr_author_authorization.json` after the command completes (success or failure); the agent reports the resulting PR URL or PR number in its final output
  - Acceptance: all four protocol steps and the final-output PR-URL/number reporting requirement are present and reference the exact sentinel filename and fields

- [x] [P3-T3] Record the guardrail limitation in `.claude/agents/pr-author.md`
  - Body states the sentinel is a policy guardrail, not a cryptographic/security control, and that any `Write(/artifacts/**)` holder can forge it (AC8)
  - Acceptance: the limitation text is present and does not describe the sentinel as tamper-proof or a security boundary

- [x] [P3-T4] Verify `.claude/agents/pr-author.md` references the `pr-author` skill and reflects the skill's actual capabilities
  - Confirm the `pr-author` skill at `.claude/skills/pr-author/SKILL.md` is referenced; note in the agent body that opening/editing the PR is the agent's responsibility (the skill itself only authors body text and does not list `gh pr create`)
  - Acceptance: the agent body names the `pr-author` skill and assigns the `gh pr create`/`gh pr edit` action to the agent

---

### Phase 4 — Settings, Orchestrate Skill, and Orchestrator Agent Wiring (Claude root)

- [x] [P4-T1] Add `Agent(pr-author)` to the orchestrator allow list in `.claude/settings.json`
  - Acceptance: `.claude/settings.json` permits `Agent(pr-author)`; JSON remains valid

- [x] [P4-T2] Register the `pr-author` SubagentStop matcher and `validate-pr-author-output.ps1` hook in `.claude/settings.json`
  - Add a `SubagentStop` entry with matcher `"pr-author"` invoking `pwsh -NoProfile -File .claude/hooks/validate-pr-author-output.ps1`
  - Acceptance: the SubagentStop entry exists and JSON remains valid

- [x] [P4-T3] Add a `## PR Creation Delegation` section to `.claude/skills/orchestrate/SKILL.md`
  - Section states the orchestrator must not call `gh pr create` directly, must first produce the PR-context artifact via `mcp__drm-copilot__collect_pr_context` (or equivalent), and must then delegate PR creation/body edits to `Agent(pr-author)`
  - Acceptance: the section is present and names `Agent(pr-author)` as the mandatory delegate for PR creation and body edits

- [x] [P4-T4] Add `Agent(pr-author)` to the orchestrator tools list in `.claude/agents/orchestrator.md`
  - Acceptance: `Agent(pr-author)` appears in the orchestrator tools list

- [x] [P4-T5] Document the mandatory pr-author delegation requirement in `.claude/agents/orchestrator.md` body
  - Body states that PR creation and PR body edits must be delegated to `Agent(pr-author)` and that direct `gh pr create`/`gh pr edit --body*` from the main thread is blocked by the hook
  - Acceptance: the delegation requirement text is present

---

### Phase 5 — Cross-Ecosystem Mirrors and Translations

Claude bundled copies MUST be byte-identical to their root counterparts. Codex copies are translations into the Codex format. GitHub Copilot is documentation-only (no hook surface).

- [x] [P5-T1] Mirror the strengthened hook to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` byte-identical to root
  - Acceptance: the bundled file is byte-identical to `.claude/hooks/enforce-pr-author-skill.ps1`

- [x] [P5-T2] Create `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1` byte-identical to root
  - Acceptance: the bundled file is byte-identical to `.claude/hooks/validate-pr-author-output.ps1`

- [x] [P5-T3] Mirror the agent, settings, orchestrate skill, and orchestrator agent to the bundled Claude tree byte-identical to root
  - Files: `extensions/drm-copilot/resources/claude-customizations/.claude/agents/pr-author.md`, `.../.claude/settings.json`, `.../.claude/skills/orchestrate/SKILL.md`, `.../.claude/agents/orchestrator.md`
  - Acceptance: each bundled file is byte-identical to its root counterpart

- [x] [P5-T4] Update Codex agent `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/pr-author.toml` with the sentinel write/delete protocol
  - Add to the agent instructions the same write-before / immediate-`gh` / delete-after protocol and the guardrail limitation (AC8), translated to the Codex `.toml` instruction format
  - Acceptance: the sentinel protocol steps and guardrail limitation appear in the Codex agent instructions

- [x] [P5-T5] Create Codex hook `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` as a translation of the strengthened Claude hook
  - Use the Codex `# Converted hook` header convention (consistent with existing `.codex/hooks/*.ps1`) and the same PowerShell body (Cases A/B/C plus D/E/F/malformed via the sentinel seams)
  - Acceptance: the file exists with the `# Converted hook` header and implements the same decision logic; file remains under 500 lines

- [x] [P5-T6] Wire the Codex hook in `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`
  - Add the hook registration consistent with existing Codex hook wiring in `config.toml`
  - Acceptance: `config.toml` references `enforce-pr-author-skill.ps1` and remains valid TOML

- [x] [P5-T7] Update GitHub Copilot agent `extensions/drm-copilot/resources/customizations/.github/agents/pr-author.agent.md` (documentation-only)
  - Document the sentinel write/delete protocol, state that enforcement in the Copilot ecosystem is documentation-only because no PreToolUse hook surface exists, and record the guardrail-not-cryptographic limitation (AC8)
  - Acceptance: the sentinel protocol, the documentation-only statement, and the guardrail limitation are present

- [x] [P5-T8] Run the PowerShell QA loop for the Codex hook translation and capture evidence
  - Commands in order: `mcp__drm-copilot__run_poshqc_format` -> `mcp__drm-copilot__run_poshqc_analyze` over `.codex/.../hooks/enforce-pr-author-skill.ps1`; restart from format if any step fails or changes files
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/p5-codex-hook-qa.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`

---

### Phase 6 — Final QA Loop, Cross-Ecosystem Equality, and Residual Verification

- [x] [P6-T1] Run final PowerShell formatting over all changed `.ps1` files
  - Command: `mcp__drm-copilot__run_poshqc_format` over `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/validate-pr-author-output.ps1`, both bundled mirrors, the Codex hook, and both test files
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/final-format.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; restart loop if files changed

- [x] [P6-T2] Run final PSScriptAnalyzer over all changed `.ps1` files
  - Command: `mcp__drm-copilot__run_poshqc_analyze` over the same file set as P6-T1
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/final-analyze.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` recording zero analyzer errors

- [x] [P6-T3] Run final Pester with coverage over both hook test suites
  - Command: `mcp__drm-copilot__run_poshqc_test` over `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1`, coverage on `.claude/hooks/enforce-pr-author-skill.ps1` and `.claude/hooks/validate-pr-author-output.ps1`
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/final-pester.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording pass count and post-change line/branch coverage; restart loop if any step fails or changes files

- [x] [P6-T4] Verify coverage thresholds and no-regression on changed lines
  - Compare baseline (P0-T4) vs post-change (P6-T3) coverage for `enforce-pr-author-skill.ps1`; record new-file coverage for `validate-pr-author-output.ps1`
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/coverage-delta.md` records baseline coverage, post-change coverage, and changed/new-code coverage; both files meet line >= 85% / branch >= 75% with no regression on changed lines

- [x] [P6-T5] Verify all pre-existing Case A/B/C and allowed-path tests still pass unchanged (backward compatibility)
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/regression-testing/backward-compat.md` lists the pre-existing test cases and confirms each passes with unmodified expectations (FR-4, AC5)

- [x] [P6-T6] Verify the full acceptance scenario matrix is exercised by tests
  - Confirm allowed (valid `pr-author` sentinel) and blocked (missing/expired/wrong-issuer/malformed, Case A, Case B, Case C) are each asserted in `enforce-pr-author-skill.Tests.ps1`, and the six `validate-pr-author-output` scenarios are asserted (AC5, AC7)
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/scenario-matrix.md` maps each spec 7.1/7.2 scenario to a passing `It`

- [x] [P6-T7] Verify Claude root and bundled copies are byte-identical
  - Compare `enforce-pr-author-skill.ps1`, `validate-pr-author-output.ps1`, `pr-author.md` (agent), `settings.json`, `orchestrate/SKILL.md`, and `orchestrator.md` between `.claude/` and `extensions/drm-copilot/resources/claude-customizations/.claude/`
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/cross-ecosystem-equality.md` records a byte-identical result (e.g., hash match) for each paired Claude file, plus confirmation that the Codex hook exists and is wired and the Copilot agent is documentation-updated (AC4)

- [x] [P6-T8] Verify the orchestrate skill mandates `pr-author` delegation (residual check)
  - Confirm `.claude/skills/orchestrate/SKILL.md` and its bundled mirror contain the `## PR Creation Delegation` section requiring delegation to `Agent(pr-author)` and prohibiting direct `gh pr create` from the main thread
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/orchestrate-delegation-check.md` quotes the mandatory delegation language from both root and bundled skill files (AC6)

- [x] [P6-T9] Verify the guardrail-not-cryptographic disclosure is present in every documentation artifact
  - Confirm the guardrail limitation wording appears in `.claude/agents/pr-author.md`, both hook headers, the Codex agent, and the Copilot agent, and that no artifact describes the sentinel as tamper-proof or a security boundary
  - Acceptance: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/guardrail-disclosure-check.md` lists each documentation file and the quoted disclosure text (AC8)

## Test Plan

- Unit (PowerShell/Pester): strengthened `enforce-pr-author-skill.ps1` Cases A/B/C (unchanged) plus D/E/F/malformed and valid-sentinel; new `validate-pr-author-output.ps1` six scenarios. All deterministic via the `Get-PrAuthorAuthorizationContents` read seam and `Get-CurrentDateTimeUtc` clock seam; no temporary files, no real `gh`, no `Start-Sleep`.
- Integration: none required; this feature is repository tooling only (spec 7.3).
- Manual/CLI: none required.
- Coverage evidence: baseline `evidence/baseline/baseline-pester.md`; post-change `evidence/qa-gates/final-pester.md`; delta `evidence/qa-gates/coverage-delta.md`.

## Open Questions / Notes

- Sentinel is a policy guardrail, not a cryptographic control (research Section 2.3, spec Section 8.1). This is recorded honestly per AC8.
- Codex `config.toml` hook-wiring syntax must match the existing Codex hook registration convention; confirmed `.codex/hooks/` currently has no `enforce-pr-author-skill.ps1`, so P5-T5 is a net-new file.
- Bundled orchestrate skill confirmed present at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`.
