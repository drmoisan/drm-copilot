# Remediation Inputs: Claude Code architecture v2 (#136)

- **Feature Folder:** `docs/features/active/2026-04-11-claude-code-architecture-136/v2`
- **Base Branch:** `origin/development`
- **Head Branch:** `feature/claude-code-architecture-136`
- **Triggered By:** `policy-audit.2026-04-13T08-16.md`, `code-review.2026-04-13T08-16.md`, and `feature-audit.2026-04-13T08-16.md`
- **Authoritative Requirements Source For Remediation:** this file

## Required Fixes

1. **Expand the orchestrator worker delegation contract**
   - **Files:** `.claude/agents/orchestrator.md`, `docs/engineering/claude-code-architecture.md`, and any related Claude-runtime tests under `tests/scripts/claude-runtime/`
   - **Expected behavior:** The main-thread orchestrator must be mechanically able to delegate to every repository-canonical worker the feature claims it supports, including `prd-feature`, `staged-review`, `epic-review`, `status-updater`, and the committed language-engineer workers, or the documentation/settings surface must be narrowed to the actual supported set.
   - **Verification commands:**
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command '& { Import-Module ''./scripts/powershell/PoshQC''; Invoke-PoshQCTest -Root ''c:\Users\DanMoisan\repos\drm-copilot'' }'`
     - `npm run test:unit`

2. **Normalize the PowerShell MCP naming contract across the Claude runtime**
   - **Files:** `.claude/settings.json`, `.claude/rules/powershell.md`, `.claude/agents/atomic-executor.md`, `docs/engineering/claude-code-architecture.md`, and any affected tests or mirrored assets in scope
   - **Expected behavior:** The instructed PowerShell MCP tool names, the permission allowlist, and the architecture walkthrough must all use one canonical naming contract. The final contract must be exercised by automated tests where practical.
   - **Verification commands:**
     - `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`
     - `npm run test:unit`
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command '& { Import-Module ''./scripts/powershell/PoshQC''; Invoke-PoshQCTest -Root ''c:\Users\DanMoisan\repos\drm-copilot'' }'`

3. **Make the feature-review runtime instructions version-aware**
   - **Files:** `.claude/agents/feature-review.md`, any wrapper skill or documentation file that assumes feature-root output paths, and any review-path regression tests added for this behavior
   - **Expected behavior:** Review artifact instructions must explicitly support writing into a selected version folder such as `docs/features/active/.../v2/` rather than only the parent feature root.
   - **Verification commands:**
     - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command '& { Import-Module ''./scripts/powershell/PoshQC''; Invoke-PoshQCTest -Root ''c:\Users\DanMoisan\repos\drm-copilot'' }'`
     - `npm run test:unit`

4. **Refresh live-runtime evidence after contract fixes**
   - **Files:** refreshed evidence under `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/` and, if needed, `spec.md` / `user-story.md`
   - **Expected behavior:** If a live Claude Code session is available, capture concrete slash-command, checkpoint-resume, permission-probe, and stop-gate evidence. If a live session is still unavailable, keep the related criteria explicitly unverified and avoid overstating readiness.
   - **Verification commands:**
     - `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/development`
     - live Claude Code session commands for `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, and checkpoint/stop-gate probes when the environment allows

## Do Not Do

- Do not widen scope beyond the Claude runtime contract issues identified above.
- Do not weaken the architecture documentation merely to match a reduced implementation unless that reduction is intentional and explicitly supported by the spec and user story.
- Do not mark live-runtime criteria PASS without captured transcript or runtime evidence.
- Do not introduce file-level suppressions or policy exceptions as a shortcut around the runtime mismatches.
- Do not create remediation plan siblings at alternate paths; keep the remediation plan in this same `v2` folder.
