# expose-policy-audit-template-surface (Issue #141)
title: "expose-policy-audit-template-surface - Plan"
issue: "TBD"
parent: "none"
owner: "Dan Moisan"
last_updated: "2026-04-11T22-02"
status: "Draft"
status_color: "lightgrey"
version: "0.1"
---

# expose-policy-audit-template-surface (Potential)

- Date captured: 2026-04-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/expose-policy-audit-template-surface/ (Issue #141)

- Issue: #141
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/141
- Last Updated: 2026-04-12
- Work Mode: full-feature

## Problem / Why

The repository already treats many templates as published automation assets, but nothing currently exposes the policy-audit template pair through the published `drmCopilotExtension` MCP surface or through a matching extension command. Consumers that need the canonical policy-audit guidance must still depend on the repository-local path `docs/features/templates/policy_audit/AGENTS.md`, which breaks the extension-hosted automation model and keeps repository prompts and skills coupled to a source path that should instead be surfaced semantically.

## Proposed Behavior

Extend the canonical `drmCopilotExtension` automation surface so it can return both `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` and `docs/features/templates/policy_audit/AGENTS.md` from the published extension bundle. Add a matching extension command for the same capability, then replace repository references that currently hardcode `docs/features/templates/policy_audit/AGENTS.md` so they point to the MCP server surface rather than the local repository path.

## Acceptance Criteria (early draft)

- [ ] The published `drmCopilotExtension` MCP surface exposes the bundled policy-audit template markdown file and the bundled policy-audit `AGENTS.md` guidance file through a canonical tool or resource path that is available outside the source repository layout
- [ ] The VS Code extension contributes a matching command for retrieving or copying the same policy-audit template assets from the bundled extension surface
- [ ] Repository references that currently hardcode `docs/features/templates/policy_audit/AGENTS.md` are redirected to the MCP server surface, or any remaining exceptions are explicitly documented with rationale
- [ ] Regression coverage proves the new MCP and extension command behavior, and repository documentation or prompt references remain consistent with the published automation surface

## Constraints & Risks

- Preserve existing command and MCP behavior unless the new policy-audit template-access capability requires an additive extension.
- Do not remove the source template files under `docs/features/templates/policy_audit/`; they remain the source artifacts.
- Keep the adapter model consistent with existing semantic MCP tooling patterns such as `resolve_execute_hard_lock_prompt`.
- Redirect only references to `docs/features/templates/policy_audit/AGENTS.md`; references to the README or template markdown may remain local if they are still source-artifact references.
- The change is expected to touch TypeScript extension code, bundled resources, extension registration, and repository prompts or skills. This is outside the 1-3 file small-path budget.

## Test Conditions to Consider

- [ ] Unit coverage areas: MCP tool registration, input validation, server exposure, and extension command registration or dispatch
- [ ] Integration scenarios: retrieve the policy-audit template assets from the published `drmCopilotExtension` MCP surface in a workspace that does not rely on the repo-local template path
- [ ] CLI/API examples: verify any published command or tool arguments and response payloads used by prompts, skills, or lifecycle automation

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [x] Create `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/` folder from the template
- [x] Finalize the full-feature requirements package (`spec.md`, `user-story.md`, `research.md`)
- [ ] Delegate canonical planning at `plan.2026-04-11T22-03.md`
