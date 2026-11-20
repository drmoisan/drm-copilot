<!-- markdownlint-disable-file -->

# Task Research Notes: expose-policy-audit-template-surface

## Research Executed

### Request and repository evidence

- User objective:
  - expose `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`
  - expose `docs/features/templates/policy_audit/AGENTS.md`
  - surface both through the published `drmCopilotExtension` MCP server
  - add a matching VS Code extension command
  - redirect repository references to the local `AGENTS.md` path so they point to the MCP surface instead
- Reference inventory:
  - `rg -n "docs/features/templates/policy_audit/AGENTS\\.md|policy_audit"` found hardcoded references in `.agents`, `.github`, `docs/features/templates/policy_audit/README.md`, and archived feature artifacts.
  - The highest-value redirect targets are current workflow prompts, skills, and extension customization payloads that instruct agents to open the repo-local `AGENTS.md`.

### Relevant extension implementation seams

- `extensions/drm-copilot/src/repo-automation-service.ts`
  - This file already centralizes extension-side automation entry points and is the most likely place to add a new bundled template access workflow.
- `extensions/drm-copilot/src/mcp-tools.ts`
  - This file defines the semantic MCP tool inventory and its metadata.
- `extensions/drm-copilot/src/mcp-tool-inputs.ts`
  - Existing tool input validation likely needs a new additive input contract if the new capability supports asset selection or destination behavior.
- `extensions/drm-copilot/src/mcp-server.ts`
  - The published MCP server surface is wired here and will need to expose any new tool or resource handler.
- `extensions/drm-copilot/src/extension.ts`
  - Extension command registration and command-to-service dispatch are defined here.
- `extensions/drm-copilot/src/workflow-command-arguments.ts`
  - Existing workflow commands use this module to normalize direct command arguments. A matching extension command should follow the same pattern where practical.
- `extensions/drm-copilot/package.json`
  - A new command contribution will require manifest registration.

### Relevant bundled and source assets

- `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`
  - The canonical source template that should remain in the repository as the source artifact.
- `docs/features/templates/policy_audit/AGENTS.md`
  - The canonical guidance file currently referenced directly by repo prompts and skills.
- `docs/features/templates/policy_audit/README.md`
  - Documents the local template usage and may need wording updates if the published automation surface becomes the preferred access path.
- `extensions/drm-copilot/resources/templates/`
  - Existing bundled workflows indicate where additive template-access helpers may belong.
- `extensions/drm-copilot/resources/scripts/dev_tools/`
  - Existing published automation wrappers may provide the simplest bridge if the new capability is implemented as a bundled script or copier.

### Existing pattern to mirror

- `resolve_execute_hard_lock_prompt`
  - The repo already exposes a semantic template-resolution style capability through both the MCP server and an extension command-adjacent service path.
  - This is the closest existing pattern for a new policy-audit template access capability.

## Key Discoveries

1. The request is a mixed-surface extension feature, not a single-language narrow fix.
   - TypeScript extension files, bundled extension resources, and repository prompts or docs are all in scope.
   - The scope exceeds the small-path file budget, so the large path is the correct route.

2. The redirect request is narrower than a full template migration.
   - The user only requested redirecting references to `docs/features/templates/policy_audit/AGENTS.md`.
   - References to the source template markdown or README can remain repo-local when they are source-artifact references rather than published automation usage instructions.

3. Archive artifacts contain historical path references.
   - The repository includes archived policy audits, plans, and evidence that mention the local `AGENTS.md` path.
   - Redirecting every historical reference may not be practical or desirable. Any intentionally preserved historical references will need explicit documentation.

4. The published MCP surface already provides a stable naming pattern.
   - Existing tools such as `resolve_execute_hard_lock_prompt`, `collect_pr_context`, and `new_active_feature_folder` suggest that additive semantic template-access tooling should use a similarly explicit name and response contract.

## Recommended Implementation Shape

1. Add a semantic policy-audit template access capability to the extension service and MCP server.
2. Register a matching extension command that resolves the same bundled assets through the published extension installation, not the repo-local source path.
3. Bundle any required policy-audit template files into the published extension resources if they are not already present in the installed extension footprint.
4. Update current prompts, skills, and customization payloads so instructions point to the MCP surface for `policy_audit/AGENTS.md` access rather than the repo-local path.
5. Add regression coverage for:
   - MCP tool registration and dispatch
   - extension command registration and argv handling
   - repository reference redirection in current source materials

## Open Risks

- The exact set of repository references that should be redirected versus preserved as historical source references requires implementation judgment.
- The workflow requires delegated planning, execution, and review later in the process. This host does not currently expose `spawn_agent`, so the orchestration run will block at the planning delegation boundary unless that capability becomes available.
