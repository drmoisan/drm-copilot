# legacy-discovery-hooks (Issue #366)

- Date captured: 2026-07-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/legacy-discovery-hooks/ (Issue #366)
- Epic: legacy-discovery-and-parity (child feature; manifest placeholder issue 9004)

- Issue: #366
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/366
- Last Updated: 2026-07-17
- Work Mode: full-feature

## Problem / Why

The legacy-discovery-and-parity epic delivers a domain-neutral discovery and
parity-definition capability. Consumer repositories produce discovery artifacts
(domain profile plus seven versioned JSON-schema-governed artifacts) whose
conformance is checked by the deterministic validators delivered in feature
legacy-discovery-validators (#361 / manifest #9003). Without completion-gate
hooks that invoke those validators at the appropriate Claude Code lifecycle
events, there is no runtime gate that blocks progression when a required
discovery artifact is absent, malformed, or non-conforming. This feature
supplies those PowerShell completion-gate hooks.

## Proposed Behavior

Provide PowerShell completion-gate hooks that enforce discovery-artifact
completion gates by invoking the discovery validators (never reimplementing
validation logic). The hooks follow the repository's canonical hook conventions
(PreToolUse and/or SubagentStop I/O, dot-source guard, JSON decision payloads)
and are registered in `.claude/settings.json` under the appropriate event with
the standard `{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/<name>.ps1"}`
form. Gate behavior is driven by the domain profile; the hooks contain no
TaskMaster/TMW/Outlook/VSTO/email/task-management-specific behavior.

## Acceptance Criteria (early draft)

- [ ] One or more PowerShell completion-gate hooks enforce discovery-artifact completion gates by invoking the discovery validators.
- [ ] Hooks follow canonical PreToolUse/SubagentStop I/O conventions and the dot-source guard.
- [ ] Hooks are registered in `.claude/settings.json` under the appropriate event with the standard command form.
- [ ] Hooks are domain-neutral (no domain-specific identifiers in source, comments, or messages).
- [ ] Pester tests are mirrored at `tests/scripts/claude-hooks/<name>.Tests.ps1`.

## Constraints & Risks

- Depends on legacy-discovery-validators (#361) validator CLI surface; the hooks invoke `dev.discovery.validate-*` / `scripts.dev_tools.validate_discovery_artifacts` and do not implement validators.
- Domain neutrality is an epic invariant.
- Do NOT implement the validators (separate, already-prepared feature).
- New `.claude/` assets are mirrored to `resources/` later by the publishing feature (#9012), out of scope here.

## Test Conditions to Consider

- [ ] Hook allows when discovery artifacts are present and conforming.
- [ ] Hook blocks/denies when a required discovery artifact is absent or non-conforming.
- [ ] Malformed hook input handled per canonical convention.
- [ ] Domain-neutrality grep gate on new hook source.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/legacy-discovery-hooks/` folder from the template
