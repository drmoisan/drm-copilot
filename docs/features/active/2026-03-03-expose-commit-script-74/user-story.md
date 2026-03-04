# `2026-03-03-expose-commit-script` — User Story

- Issue: #74
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-03-03T19-53

## Story Statement

- As a developer using the scaffold extension in a destination repository, I want to run a Command Palette action that collects commit context from staged files, so that I can generate a deterministic `artifacts/commit_context.txt` artifact without leaving VS Code.
- As a maintainer validating extension-boundary automation, I want commit-context collection to execute from bundled extension resources while targeting the destination workspace Git state, so that we can prove no-script-materialization and repository-correct introspection behavior.

## Problem / Why

The scaffold extension already proves that bundled scripts can execute from extension resources and write artifacts into a destination workspace. What is missing is a realistic Git-aware workflow that validates repository introspection behavior, especially for staged changes.

`scripts/dev_tools/collect_commit_context.py` provides the desired commit-context logic today, but only from repository-local script execution paths. Without extension exposure, we cannot validate the production boundary where the extension executes packaged resources while targeting the destination workspace repository.

This feature closes that gap by making commit-context collection an extension command that inspects staged files in the destination workspace and writes `artifacts/commit_context.txt` there. It establishes a reusable contract for future extension-side automation tied to commit and PR preparation.


## Personas & Scenarios

- Persona: Extension-first workflow maintainer
  - Maintains the scaffold extension and validates that extension commands operate against a destination workspace repository, not the extension repository.
  - Cares about deterministic, cross-platform behavior for runtime probing, subprocess invocation, and artifact creation.
  - Is constrained by extension packaging boundaries: scripts must execute from bundled extension resources and must not be copied into workspace root.
  - Wants reliable commit-context artifacts for downstream PR/commit preparation automation.
  - Is frustrated by workflows that only work from repository-local script execution and cannot validate extension-side production behavior.
- Scenario: Collect commit context from staged changes in a destination workspace
  - A maintainer opens VS Code on a destination repository that has staged changes and triggers `Scaffold: Collect Commit Context` from the Command Palette.
  - The extension validates a workspace root, resolves Python runtime, resolves the bundled collector script path from extension resources, and spawns the collector with `cwd` set to the destination workspace.
  - The collector runs Git queries against the destination repository, writes `artifacts/commit_context.txt`, and reports lifecycle events to `Scaffold Utils`.
  - If no workspace is open or runtime/Git resolution fails, the command returns an actionable error instead of silently failing.
  - The maintainer verifies the artifact sections and confirms no collector script file was materialized into the destination workspace root.


## Acceptance Criteria

- [ ] Extension contributes a Command Palette action for commit-context collection (for example, `scaffoldExtension.collectCommitContext`).
- [ ] Command returns a clear actionable error when no workspace is open.
- [ ] Command executes a script resolved from extension bundled resources and does not create collector script files in the destination workspace root.
- [ ] Collector process is launched with destination workspace root as working directory, and staged/unstaged Git introspection targets that destination repository.
- [ ] Output artifact is written to `<destination-workspace>/artifacts/commit_context.txt`.
- [ ] Artifact contains the collector's core sections: repository remotes, current branch, upstream, status (short), staged files (name-status), staged diff, unstaged files (name-status), unstaged diff, untracked files, diff stat, changed Python files, and last commit header.
- [ ] When there are no staged changes, artifact still generates successfully and includes `(no staged changes)` markers in staged sections.
- [ ] Runtime selection and command lifecycle events are logged to `Scaffold Utils`, including non-zero exit and Git/runtime resolution failures.
- [ ] Unit tests verify command registration/disposal, workspace validation, runtime resolution, bundled script path resolution, and spawn `cwd`/arguments.
- [ ] Integration tests verify end-to-end artifact generation from a controlled fixture repository with staged changes and no script materialization in workspace root.
- [ ] Error-path tests verify missing workspace, missing runtime, unavailable/failing Git command path, and collector non-zero exit handling.


## Non-Goals

- Reimplementing commit-context Git logic in TypeScript; this feature uses the existing Python collector behavior as the source of truth.
- Adding commit message drafting, commit authoring UX, or PR text generation workflows.
- Copying or materializing collector scripts into the destination workspace root.
- Supporting custom output paths in v1 of this feature unless explicitly added in follow-up scope.
- Changing multi-root selection UX beyond the current deterministic policy used by the extension command path.
