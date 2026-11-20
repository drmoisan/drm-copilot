# expose-commit-script (Issue #74)

- Date captured: 2026-03-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/expose-commit-script/ (Issue #74)

- Issue: #74
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/74
- Last Updated: 2026-03-03T22-05
- Work Mode: full

## Problem / Why

The scaffold extension already proves that bundled scripts can execute from extension resources and write artifacts into a destination workspace. What is missing is a realistic Git-aware workflow that validates repository introspection behavior, especially for staged changes.

`scripts/dev_tools/collect_commit_context.py` provides the desired commit-context logic today, but only from repository-local script execution paths. Without extension exposure, we cannot validate the production boundary where the extension executes packaged resources while targeting the destination workspace repository.

This feature closes that gap by making commit-context collection an extension command that inspects staged files in the destination workspace and writes `artifacts/commit_context.txt` there. It establishes a reusable contract for future extension-side automation tied to commit and PR preparation.

## Proposed Behavior

Add an extension command that invokes an extension-bundled commit-context collector (based on `collect_commit_context.py`) against the active destination workspace root.

At runtime, the command should:
- Validate an open workspace root.
- Resolve and validate required runtime(s) for bundled script invocation.
- Resolve the collector script from extension bundled resources (never copy it into workspace root).
- Execute the collector with process working directory set to the destination workspace root so all Git queries (`status`, `diff --cached`, etc.) target that repository.
- Write commit context output to `artifacts/commit_context.txt` under the destination workspace.
- Surface lifecycle, runtime selection, and failure diagnostics in the `Scaffold Utils` output channel.

## Acceptance Criteria (early draft)

- [x] Extension contributes a Command Palette action for commit-context collection (for example, `drmCopilotExtension.collectCommitContext`).
- [x] Command returns a clear actionable error when no workspace is open.
- [x] Command executes a script resolved from extension bundled resources and does not create collector script files in the destination workspace root.
- [x] Collector process is launched with destination workspace root as working directory, and Git introspection targets that repository.
- [x] Output artifact is written to `<destination-workspace>/artifacts/commit_context.txt`.
- [x] Artifact contains the collector's core sections: repository remotes, current branch, upstream, status (short), staged files (name-status), staged diff, unstaged files (name-status), unstaged diff, untracked files, diff stat, changed Python files, and last commit header.
- [x] When there are no staged changes, artifact still generates successfully and includes `(no staged changes)` markers in staged sections.
- [x] Runtime selection and command lifecycle events are logged to `Scaffold Utils`, including non-zero exit and Git/runtime resolution failures.
- [x] Unit tests verify command registration/disposal, workspace validation, runtime resolution, bundled script path resolution, and spawn `cwd`/arguments.
- [x] Integration tests verify end-to-end artifact generation semantics from deterministic committed fixtures with staged changes and no script materialization in workspace root.
- [x] Error-path tests verify missing workspace, missing runtime, unavailable/failing Git command path, and collector non-zero exit handling.

## Implementation Evidence Links

- Baseline artifact: [`evidence/baseline/baseline.test.2026-03-03T21-15.md`](./evidence/baseline/baseline.test.2026-03-03T21-15.md)
- QA artifact: [`evidence/qa-gates/final-qc.pass1.test.2026-03-03T21-15.md`](./evidence/qa-gates/final-qc.pass1.test.2026-03-03T21-15.md)
- Remediation closure: [`evidence/other/remediation-closure.2026-03-03T22-05.md`](./evidence/other/remediation-closure.2026-03-03T22-05.md)

## Constraints & Risks

- Must preserve extension boundary: execution originates extension-side while operating on destination workspace filesystem and Git repository.
- Cross-platform behavior (Windows/macOS/Linux) must keep runtime probing and path handling deterministic.
- Git executable availability and repository-state failures must surface as explicit, actionable errors.
- Large staged/unstaged diffs can increase artifact size and command duration; logging must preserve diagnosability without freezing UX.
- Multi-root workspaces require a deterministic root-selection rule to avoid collecting context from the wrong repository.
- Scope control: this feature exposes commit-context collection only; it does not include commit-message authoring UX.

## Test Conditions to Consider

- [ ] Unit coverage areas
	- [ ] Command registration and disposal behavior
	- [ ] Workspace root discovery success/failure
	- [ ] Bundled script path resolution logic
	- [ ] Runtime detection and ordered fallback behavior
	- [ ] Spawn arguments include destination workspace working directory and output path
- [ ] Integration scenarios
	- [ ] Destination repo with staged tracked file changes
	- [ ] Destination repo with unstaged and untracked changes
	- [ ] Destination repo with no staged changes still produces artifact with expected "no staged changes" markers
	- [ ] Artifact content sections validated and deterministic
	- [ ] No script materialization in workspace root
	- [ ] Workspace path containing spaces/unicode executes successfully
- [ ] CLI/API examples
	- [ ] Command Palette usage for commit-context collection
	- [ ] Optional command argument support for output path (if added)

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/expose-commit-script/` folder from the template