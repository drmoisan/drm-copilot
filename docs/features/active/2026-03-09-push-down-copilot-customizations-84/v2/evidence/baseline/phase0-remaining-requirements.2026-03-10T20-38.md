# Phase 0 — Remaining Requirements Map

Timestamp: 2026-03-10T20:38:00Z

Sources:
- docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/spec.md
- docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/user-story.md

## Remaining Unchecked Requirements

### REQ-001: Real Extension Command Registration
Register `drmCopilotExtension.pushDownCopilotCustomizations` as a real extension command that executes a bundled push-down publisher through the same extension-side runtime/script-launch path used for PR-context collection.

### REQ-002: Rewrite of Push-Down Script Reference
Rewrite copied references to `scripts.dev_tools.push_down_copilot_customizations` to a real textual extension-command reference while retaining the existing real-command rewrite for `scripts.dev_tools.pr_context.collector`.

### REQ-003: Bundled Execution with Packaged Source Root
Make bundled push-down execution functional by reading customization source files from a `bundled copy of scripts.dev_tools.push_down_copilot_customizations` packaged with extension resources while writing output artifacts into the destination workspace.

### REQ-004: Automated Test Coverage
Extend automated coverage with Python tests for the remaining publisher behavior and TypeScript tests for push-down command contribution, bundled wrapper execution, destination argument propagation, `continued packaged-path execution of PR-context collection`, and `placeholder-command failure paths`.

### REQ-005: Documentation Updates
Update extension-facing documentation and active feature documentation to show the real push-down command usage and the rewritten textual command-reference contract.

### REQ-006: Baseline and Final QA Evidence
Capture baseline evidence, targeted regression evidence, and a full final QA loop for Python and TypeScript with required artifact fields and Python coverage values.
