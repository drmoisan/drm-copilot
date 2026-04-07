# Feature Audit

- Feature: `bundle-poshqc-suite-into-extension`
- Issue: #133
- Status: ready for review

## Acceptance Criteria Mapping

- [x] The extension exposes a bundled PoshQC command and MCP tool that run from extension resources rather than repo-local scripts.
- [x] The bundled suite executes against the destination workspace and can limit scanning to one or more workspace-relative folders.
- [x] The shared PoshQC module validates scan folders and preserves the existing quality-gate behavior for formatting, analysis, and Pester execution.
- [x] The extension and PowerShell test suites cover the new wrapper, command wiring, MCP dispatch, and folder-selection behavior.
- [x] Documentation and feature artifacts reflect the new bundled workflow and its usage.

## Evidence

- Final extension test/coverage run passed.
- Final PowerShell wrapper run passed against selected scan folders.
- Final analyzer and lint/typecheck passes were clean.

## Closeout

- The feature is complete on the selected large/full-feature path.
- No remediation was required after the final review pass.
