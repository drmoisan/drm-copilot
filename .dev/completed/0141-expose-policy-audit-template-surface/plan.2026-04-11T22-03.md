# Atomic Plan — Feature #141 Policy-Audit Template Surface Exposure

## Overview
This plan exposes the policy-audit template pair through an additive semantic MCP tool and a matching VS Code command without changing existing repo-automation tool behavior. The implementation is intentionally constrained to TypeScript extension code, bundled Markdown assets under `extensions/drm-copilot/resources/`, and the repository Markdown/agent reference updates required to redirect active `docs/features/templates/policy_audit/AGENTS.md` usage. If execution reveals that new or modified Python or PowerShell wrapper scripts would be required, stop and request replanning instead of widening scope inside this plan.

Planned semantic surface:
- MCP tool: `resolve_policy_audit_template_asset`
- VS Code command: `drmCopilotExtension.resolvePolicyAuditTemplateAsset`
- Supported asset selectors:
  - `template` -> `policy-audit.yyyy-MM-ddTHH-mm.md`
  - `agents` -> `AGENTS.md`

### Phase 0 — Baseline Capture
- [x] [P0-T1] Read policy and requirement files in required order and persist evidence at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/phase0-instructions-read.2026-04-11T22-03.md`.
  - Acceptance: Evidence file exists and contains `Timestamp:`, `Policy Order:`, `Work Mode Source: issue.md`, `Resolved Work Mode: full-feature`, and an explicit ordered list of files read: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`, `AGENTS.md`, `docs/features/templates/policy_audit/AGENTS.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/issue.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/spec.md`, `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/user-story.md`, and `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/research.md`.

- [x] [P0-T2] Record the pre-edit reference inventory and scope decision at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/reference-inventory.2026-04-11T22-03.md` by running `rg -n "docs/features/templates/policy_audit/AGENTS\\.md" .agents .codex .github docs extensions/drm-copilot/resources -g '!docs/features/archive/**'`.
  - Acceptance: Evidence file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, an explicit list of matches categorized as `redirect`, `preserve-source-doc`, `feature-requirement-text`, or `historical-evidence`, and a scope statement confirming this plan remains `TypeScript extension code + bundled Markdown assets + repository Markdown/agent reference updates only` with no Python or PowerShell wrapper changes.

- [x] [P0-T3] Capture the TypeScript baseline formatting result by running `npm run format` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/ts-format.2026-04-11T22-03.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run format`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T4] Capture the TypeScript baseline lint result by running `npm run lint` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/ts-lint.2026-04-11T22-03.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run lint`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T5] Capture the TypeScript baseline type-check result by running `npm run typecheck` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/ts-typecheck.2026-04-11T22-03.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T6] Capture the TypeScript baseline unit-test and coverage result by running `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/ts-test-unit.2026-04-11T22-03.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`, `EXIT_CODE:`, and `Output Summary:` with numeric baseline coverage headline values.

### Phase 1 — Bundle Policy-Audit Assets and Shared Resolver
- [x] [P1-T1] Copy `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` into `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`.
  - Acceptance: Destination file exists and matches the source file byte-for-byte at copy time.

- [x] [P1-T2] Copy `docs/features/templates/policy_audit/AGENTS.md` into `extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md`.
  - Acceptance: Destination file exists and matches the source file byte-for-byte at copy time.

- [x] [P1-T3] Add a policy-audit asset resolver to `extensions/drm-copilot/src/repo-automation-service.ts` that maps the canonical selectors `template` and `agents` to the bundled extension paths under `resources/templates/policy_audit/`.
  - Acceptance: The resolver rejects unsupported selectors with a clear error and never resolves files from the repo-local `docs/features/templates/policy_audit/` tree at runtime.

- [x] [P1-T4] Extend `extensions/drm-copilot/src/repo-automation-service.ts` so the new resolver can optionally copy the selected bundled asset to a caller-supplied workspace target path while still returning the canonical asset id and bundled source path.
  - Acceptance: Service result data distinguishes `bundled_source_path` from any copied destination path and preserves existing result fields used by other tools.

### Phase 2 — Expose the MCP Tool Surface
- [x] [P2-T1] Add the `resolve_policy_audit_template_asset` input contract to `extensions/drm-copilot/src/mcp-tool-inputs.ts` with required `asset` validation and optional `target_path` normalization.
  - Acceptance: Valid selectors are exactly `template` and `agents`, `target_path` is normalized as a workspace-relative or absolute destination when supplied, and unsupported values fail fast before service dispatch.

- [x] [P2-T2] Add `resolve_policy_audit_template_asset` metadata to `extensions/drm-copilot/src/mcp-tools.ts` with a schema that documents `workspace_root`, required `asset`, and optional `target_path`.
  - Acceptance: Tool metadata is additive only, uses `additionalProperties: false`, and describes both bundled assets in the input contract.

- [x] [P2-T3] Add the `resolve_policy_audit_template_asset` dispatch case to `extensions/drm-copilot/src/mcp-tools.ts` so MCP calls route through the shared repo-automation service without changing any existing tool names or behavior.
  - Acceptance: Dispatch passes the normalized `asset` and optional `target_path` values to the service and preserves the standard structured result shape.

### Phase 3 — Add the Matching VS Code Command
- [x] [P3-T1] Add the `drmCopilotExtension.resolvePolicyAuditTemplateAsset` command contribution to `extensions/drm-copilot/package.json`.
  - Acceptance: The manifest contributes one new command entry with a stable title and does not modify existing command ids.

- [x] [P3-T2] Add a dedicated invocation parser to `extensions/drm-copilot/src/workflow-command-arguments.ts` and its exported types so the new command supports `-asset <template|agents>` and optional `-target <path>`.
  - Acceptance: The parser accepts interactive mode when no args are provided, rejects unknown or duplicate flags, and returns a typed invocation contract for the command handler.

- [x] [P3-T3] Register `drmCopilotExtension.resolvePolicyAuditTemplateAsset` in `extensions/drm-copilot/src/extension.ts` with interactive asset selection when the command is invoked without CLI-style args.
  - Acceptance: The command registration is added to the extension subscriptions list and prompts for asset selection only in interactive mode.

- [x] [P3-T4] Route `drmCopilotExtension.resolvePolicyAuditTemplateAsset` through the shared repo-automation service in `extensions/drm-copilot/src/extension.ts`, opening the bundled asset when no `-target` is supplied and copying to the requested workspace path when `-target` is supplied.
  - Acceptance: The command reuses the same asset resolver contract as the MCP tool and does not depend on new Python or PowerShell wrapper scripts.

### Phase 4 — Redirect Active References to the Published Surface
- [x] [P4-T1] Update `.github/agents/staged-review.agent.md` so the policy-audit guidance step references the MCP server surface `drmCopilotExtension` tool `resolve_policy_audit_template_asset` with `asset: agents` instead of the repo-local path `docs/features/templates/policy_audit/AGENTS.md`.
  - Acceptance: The active staged-review agent no longer instructs consumers to open the repo-local `AGENTS.md` file directly.

- [x] [P4-T2] Update `docs/features/templates/policy_audit/README.md` so it distinguishes source-artifact documentation from published automation usage and points automation consumers at the MCP server surface `drmCopilotExtension` tool `resolve_policy_audit_template_asset` for the `AGENTS.md` guidance asset.
  - Acceptance: README language preserves the source-template role of the local folder, points automation consumers at the MCP server surface `drmCopilotExtension` tool `resolve_policy_audit_template_asset` for the `AGENTS.md` guidance asset, and limits any VS Code command mention to interactive/manual use.

- [x] [P4-T3] Update `extensions/drm-copilot/README.md` so the new command and MCP tool are documented in the command list, MCP tool list, input summary, and execution-model sections.
  - Acceptance: README entries describe `resolve_policy_audit_template_asset` and `drmCopilotExtension.resolvePolicyAuditTemplateAsset` with the same selector names used by the implementation.

- [x] [P4-T4] Record the post-edit redirect outcome at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/other/reference-redirection-summary.2026-04-11T22-03.md`.
  - Acceptance: Evidence file lists every remaining `docs/features/templates/policy_audit/AGENTS.md` match from the Phase 0 search and states whether it is an allowed source-artifact reference, feature-requirement text, or historical evidence, with explicit rationale for each preserved match.

### Phase 5 — Add Regression Coverage and Targeted Evidence
- [x] [P5-T1] Update `extensions/drm-copilot/test/repo-automation-service.test.ts` to cover asset selector resolution, invalid selector rejection, and optional copy-to-target behavior for `resolvePolicyAuditTemplateAsset`.
  - Acceptance: Tests fail without the new resolver behavior and pass when the service returns the canonical asset id plus the expected bundled and copied paths.

- [x] [P5-T2] Update `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` to cover valid and invalid `resolve_policy_audit_template_asset` inputs, including `target_path` normalization.
  - Acceptance: Tests assert that only `template` and `agents` are accepted and that bad selector or path inputs fail before service dispatch.

- [x] [P5-T3] Update `extensions/drm-copilot/test/mcp-server.test.ts` so the MCP server lists `resolve_policy_audit_template_asset` and dispatches it through the shared repo-automation service with the normalized input contract.
  - Acceptance: Server tests prove the tool is visible in `ListTools` and forwards the expected arguments in `CallTool`.

- [x] [P5-T4] Add `extensions/drm-copilot/test/extension.resolve-policy-audit-template.test.ts` to cover command registration, interactive asset selection, direct open behavior, and `-target` copy behavior.
  - Acceptance: The focused command test file verifies both interactive and non-interactive paths without requiring a live VS Code host.

- [x] [P5-T5] Update `extensions/drm-copilot/test/workflow-command-arguments.test.ts` and `extensions/drm-copilot/test/extension.test.ts` so the new parser and command registration are covered in the existing command-surface regression suite.
  - Acceptance: Tests prove the parser rejects malformed flag sequences and the extension registers the new command exactly once.

- [x] [P5-T6] Run the targeted TypeScript regression suite from `extensions/drm-copilot/` using `node run-jest.cjs --runTestsByPath test/repo-automation-service.test.ts test/mcp-tool-inputs.test.ts test/mcp-server.test.ts test/workflow-command-arguments.test.ts test/extension.resolve-policy-audit-template.test.ts test/extension.test.ts` and persist `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/regression-testing/ts-policy-audit-surface.2026-04-11T22-03.md`.
  - Acceptance: Artifact contains `Timestamp:`, the exact `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming the policy-audit surface regression suites that passed.

- [x] [P5-T7] Run the post-edit reference scan using `rg -n "docs/features/templates/policy_audit/AGENTS\\.md" .agents .codex .github docs extensions/drm-copilot/resources -g '!docs/features/archive/**'` and persist `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/regression-testing/reference-redirection.2026-04-11T22-03.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` confirming the active staged-review agent no longer matches the repo-local path and that any remaining matches are limited to documented exceptions.

### Phase 6 — Final TypeScript QA Loop
- [x] [P6-T1] Run final TypeScript formatting from `extensions/drm-copilot/` using `npm run format` and capture `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-format.2026-04-11T22-03.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P6-T2] Run final TypeScript lint from `extensions/drm-copilot/` using `npm run lint` and capture `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-lint.2026-04-11T22-03.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run lint`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P6-T3] Run final TypeScript type-check from `extensions/drm-copilot/` using `npm run typecheck` and capture `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-typecheck.2026-04-11T22-03.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P6-T4] Run final TypeScript unit tests with coverage from `extensions/drm-copilot/` using `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` and capture `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-test-unit.2026-04-11T22-03.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values.

- [x] [P6-T5] Record the final TypeScript coverage disposition at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-coverage-summary.2026-04-11T22-03.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: derived-from-P0-T6-and-P6-T4`, `EXIT_CODE: 0`, and `Output Summary:`; cites the baseline coverage value from `P0-T6`; cites the post-change coverage value from `P6-T4`; states whether coverage regressed; states whether changed/new-code coverage obligations were satisfied; and states `remediation required` rather than `PASS` if changed/new-code coverage cannot be determined deterministically from the recorded evidence.

- [x] [P6-T6] Record the final QA loop summary at `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/qa-loop-summary.2026-04-11T22-03.md`.
  - Acceptance: Summary artifact records the final clean-pass order `format -> lint -> typecheck -> test`, any rerun count triggered by file changes or failures, cites the `P6-T5` coverage summary artifact, and includes an explicit statement that no Python or PowerShell wrapper QA loop was required because Phase 0 locked scope to TypeScript extension code + bundled Markdown assets + repository Markdown/agent reference updates only.

## Acceptance Criteria Traceability
- AC1 (published MCP surface exposes bundled template and guidance assets): P1-T1, P1-T2, P1-T3, P1-T4, P2-T1, P2-T2, P2-T3, P5-T1, P5-T2, P5-T3
- AC2 (matching VS Code command exposes the same assets): P3-T1, P3-T2, P3-T3, P3-T4, P5-T4, P5-T5
- AC3 (active repository references redirect away from repo-local `AGENTS.md` path): P0-T2, P4-T1, P4-T2, P4-T3, P4-T4, P5-T7
- AC4 (regression coverage and documentation stay consistent): P0-T6, P5-T1, P5-T2, P5-T3, P5-T4, P5-T5, P5-T6, P6-T1, P6-T2, P6-T3, P6-T4, P6-T5, P6-T6

## Preflight Checklist
- [x] Phase headings follow the required `### Phase N — Title` format.
- [x] Task ids are sequential and phase-aligned.
- [x] The plan updates the provided plan path in place and creates no sibling plan files.
- [x] Phase 0 includes explicit policy-read evidence, reference-inventory evidence, and TypeScript baseline evidence tasks.
- [x] The plan includes explicit reference-inventory work before any redirect tasks.
- [x] The plan constrains implementation to TypeScript extension code, bundled Markdown assets, and repository Markdown/agent reference updates only, and fails closed if wrapper-language scope would expand.
- [x] Active `AGENTS.md` redirects target the MCP server surface, and preserved source-artifact, feature-requirement, and historical-evidence exceptions are explicitly documented.
- [x] Baseline and final TypeScript test tasks use coverage-enabled commands and persist numeric coverage evidence.
- [x] Final QA includes the full TypeScript toolchain loop with per-command artifacts, a coverage disposition artifact, and a clean-pass summary.
- [x] No placeholder tokens or bucket tasks remain.
