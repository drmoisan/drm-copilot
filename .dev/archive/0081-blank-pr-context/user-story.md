# `2026-03-05-blank-pr-context-81` — User Story

- Issue: #81
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-03-05

## Story Statement

- As a repository maintainer running scaffold extension tooling in a destination workspace, I want PR-context artifacts to contain meaningful comparison details, so that I can prepare review context without manually rerunning collector logic from repo internals.
- As a pull-request reviewer, I want extension-generated PR summary and appendix artifacts to include branch/range/change context (not placeholder text), so that downstream review and planning automation can rely on them.

## Problem / Why

Issue #81 shows that the extension command currently creates PR-context output files but fills them with placeholder-level content, making artifacts effectively unusable. This breaks parity with the commit-context control path and undermines destination-workspace workflows where users expect extension-generated artifacts to be immediately actionable.

Fixing this closes a high-severity workflow gap: destination users keep the extension boundary model while still getting rich PR context suitable for planning, review, and audit tooling.


## Personas & Scenarios

- Persona: Destination-workspace maintainer using scaffold extension commands
  - Maintains multiple repositories and relies on Command Palette automation instead of manually copying/running internal scripts.
  - Cares about deterministic, trustworthy artifacts that can be consumed by downstream docs/planning flows.
  - Is constrained by host/runtime variability (Windows/macOS/Linux, branch conventions, Git environment differences).
  - Goal: run one command and receive complete PR context artifacts in the destination repo.
- Scenario: Generate PR context from extension command in destination workspace
  - Trigger: Maintainer runs `Scaffold Utils: Collect PR Context` in a destination repository.
  - Step 1: Command resolves workspace and base branch selection as usual.
  - Step 2: Bundled collector executes using destination repo `cwd` and writes summary/appendix artifacts.
  - Decision/Obstacle: If git/runtime data cannot be collected, command returns clear failure diagnostics instead of placeholder success output.
  - Expected outcome: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are both present and contain substantive PR context body content.


## Acceptance Criteria

- [ ] Running `drmCopilotExtension.collectPrContext` in a valid destination git repository produces `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` with substantive, multi-line PR context content (not heading/base-line placeholder-only output).
- [ ] Extension-side PR-context generation preserves existing command UX and boundary behavior (workspace validation, branch selection/cancel semantics, destination `cwd`, no script materialization in destination repo root).
- [ ] If collection fails (runtime/git/data failure), command surfaces actionable errors and does not report success with effectively blank artifacts.
- [ ] Regression tests fail on placeholder-only artifact content and pass when artifacts include meaningful PR context sections.
- [ ] Existing commit-context command behavior remains unchanged.
- [ ] Repro sequence in `issue.md` now yields expected populated PR-context artifacts in the documented Windows-host destination-workspace flow.

## Non-Goals

- Redesigning branch discovery/default-base algorithms.
- Adding new commands, artifact file names, or output destinations beyond current PR-context contract.
- Expanding into unrelated extension UX, telemetry systems, or non-extension PR-context execution paths.