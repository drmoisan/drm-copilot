# harness-survey-gold-standard-contracts-parity-matrix (Issue #1025)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/harness-survey-gold-standard-contracts-parity-matrix/ (Issue #1025)
- Epic: #1018 (shared agent-harness layer across Claude Code, Codex and GitHub Copilot), child 1
- Epic manifest: `docs/features/epics/shared-agent-harness-layer/epic.md`
- Epic design record: `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`

- Issue: #1025
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1025
- Last Updated: 2026-10-30
- Work Mode: full-feature

## Problem / Why

Epic #1018 restructures the three agent ecosystems in this repository (Claude Code, Codex and GitHub Copilot) onto shared cross-tool conventions. Before any generator, push-down or retirement work can start, the epic needs three settled inputs that do not exist today:

- A content-level comparison of the 90 skill names across `.claude/skills`, `.agents/skills` and `.github/skills`. The existing heading comparison (12 byte-identical, 27 wording-only, 16 material differences among 55 shared names) overstates differences because the same topic appears under different headings.
- A tool-neutral gold-standard contract for each shared skill, against which each ecosystem's expression can be judged.
- A machine-readable parity matrix that gives every native feature of every ecosystem a disposition, so later children can prove that no native capability is lost.

Several behaviors that the design depends on are also unverified: Copilot duplicate-skill listing, Codex tolerance of Claude-only frontmatter, whether the Copilot CLI and cloud agent read `.claude/agents`, whether Copilot settings work at workspace scope, and details of the Claude hooks, subagent and permissions documentation.

## Proposed Behavior

- A content-level survey of all 90 skill names, recording for each shared skill the substantive differences between ecosystems.
- A tool-neutral contract per shared skill at `.agents/skills/<name>/references/standard.md` with three parts: objective, observable behaviors, acceptance checks.
- A classification of every cross-ecosystem difference as positive, negative, neutral or mechanism-only, judged against the skill's objective, with an owner bulk-approval artifact; only disputed cases are escalated individually.
- A machine-readable parity matrix (location and schema owned by this child, outside `docs/`) that assigns every native feature of every ecosystem one disposition: shared, native, generated, or dropped with a written reason.
- A completeness test, written in TypeScript or PowerShell, that fails when a native feature has no disposition or a dropped feature has no reason.
- The unverified-behavior experiments. Experiments that need VS Code or Codex are delivered as owner-run runbook steps with a recorded-result artifact and an explicit stop.

Children 3 to 6 of epic #1018 consume the parity-matrix location and schema and the contract format, so this child states them precisely.

## Acceptance Criteria (early draft)

- [ ] Every one of the 90 skill names is surveyed by content, and each shared skill's differences are recorded.
- [ ] Each shared skill has `.agents/skills/<name>/references/standard.md` with objective, observable behaviors and acceptance checks.
- [ ] Every recorded difference is classified as positive, negative, neutral or mechanism-only, and an owner bulk-approval artifact lists the classifications with disputed cases separated.
- [ ] The parity matrix exists at its specified location, conforms to its specified schema, and gives every native feature of every ecosystem a disposition.
- [ ] A completeness test in TypeScript or PowerShell fails when a feature has no disposition or a dropped feature has no reason, and passes on the committed matrix.
- [ ] Each unverified behavior has a recorded result, or an owner-run runbook with a recorded-result artifact and an explicit stop.
- [ ] No new Python script, tool, checker or CLI entry point is added.

## Constraints & Risks

- Language directive (owner): new scripts, tools, checkers and tests are TypeScript or PowerShell; existing Python may be reused or called but not extended with new entry points.
- Execution starts only after the in-flight parallel run `bugs-1001-1002-1003-1006` merges to `main`; this child does not edit files that run changes.
- Experiments that need VS Code or Codex cannot run in an agent session and require owner steps.
- Scale: 90 skill names, about 25 Claude agents, 98 unique Codex agents, 46 Copilot agents, 125 hook files.

## Test Conditions to Consider

- [ ] Unit coverage areas: parity-matrix schema validation and the completeness rule (missing disposition, dropped without reason, unknown disposition); contract presence per shared skill.
- [ ] Integration scenarios: the completeness test run against the committed matrix in CI.
- [ ] CLI/API examples

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create the active feature folder from the template
