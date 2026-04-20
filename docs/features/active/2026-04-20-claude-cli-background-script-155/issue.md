# claude-cli-background-script (Issue #155)

- Date captured: 2026-04-20
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/claude-cli-background-script/ (Issue #155)
- Issue: #155
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/155
- Last Updated: 2026-04-20
- Work Mode: minor-audit

## Problem / Why

The repository's orchestration model depends on the ability to delegate implementation work to isolated Claude CLI sessions while keeping the main worktree available for foreground orchestration. There is no automated way to do this today. The manual workflow requires creating a worktree, checking out a branch, navigating to the new directory, launching `claude` with the correct flags, and managing the background process by hand. Each step is error-prone and blocks the terminal until the session ends. Without a scriptable single-call entry point, foreground control of background development is not reliably achievable.

## Proposed Behavior

Add `scripts/dev-tools/new-claude-worktree-session.ps1` — a PowerShell script consistent with the existing `scripts/dev-tools/` tooling — that:

1. Accepts `-ShortName` (required), `-Objective` (optional prompt text), `-WorktreeParentPath` (optional, defaults to `../` relative to repo root), and `-BranchName` (optional, defaults to `feature/<timestamp>-<ShortName>`).
2. Verifies that `git` and `claude` are on `PATH` before any file system mutation.
3. Constructs a dated worktree path: `<WorktreeParentPath>/drm-copilot-wt-<timestamp>-<ShortName>`.
4. Checks that the path does not already exist.
5. Runs `git worktree add <path> -b <branch>` to create an isolated worktree sharing the main object store.
6. Launches `claude` as a non-blocking background process (`Start-Process` without `-Wait`) in the new worktree directory, passing `-Objective` as the prompt and `--dangerously-skip-permissions` for unattended operation, with stdout and stderr redirected to a log file inside the worktree.
7. Writes the worktree path, background process ID, and log file path to stdout, then exits `0`.

The calling orchestrator session retains control immediately after the script returns and can use the process ID and log path to monitor the background session.

## Acceptance Criteria (early draft)

- [ ] Invoking the script with a valid `-ShortName` and `-Objective` creates a git worktree at `<WorktreeParentPath>/drm-copilot-wt-<timestamp>-<ShortName>` on a new branch (`feature/<timestamp>-<ShortName>` when `-BranchName` is not supplied)
- [ ] The Claude CLI process starts in the background in the new worktree's directory with the provided `-Objective` and `--dangerously-skip-permissions` in its arguments
- [ ] The script returns to the caller immediately without blocking — `Start-Process` is called without `-Wait`
- [ ] The script writes worktree path, process ID, and log file path to stdout before exiting `0`
- [ ] If `claude` is not on `PATH`, the script exits non-zero with a descriptive error before any file system mutation
- [ ] If the target worktree path already exists, the script exits non-zero with a descriptive error before calling `git worktree add`

## Constraints & Risks

- `claude` CLI must be installed and on `PATH`; the script does not manage installation.
- Worktrees share the git object store; long-running sessions generating many loose objects may affect pack performance — standard git worktree consideration.
- The background process runs with `--dangerously-skip-permissions`, giving it full tool access; callers must supply well-scoped objectives.
- Branch name uniqueness relies on the timestamp; two sessions started within the same second with the same `-ShortName` will collide on branch creation.
- Script is PowerShell-only (Windows-first, consistent with existing `scripts/dev-tools/`); no Linux/macOS shell equivalent in scope.
- Scope is limited to launch: no session monitoring, inter-session communication, or lifecycle management after process start.

## Test Conditions to Consider

- [ ] Unit coverage: worktree path construction, default branch name derivation, custom `-BranchName` passthrough, `claude` not on `PATH` error, existing worktree path collision error
- [ ] Unit coverage: `Start-Process` called without `-Wait` (non-blocking assertion), `--dangerously-skip-permissions` present in arguments, stdout contains path/PID/log fields
- [ ] Integration scenario: invoke script from main worktree, verify new worktree appears in `git worktree list`, verify background `claude` process starts in the correct working directory
- [ ] CLI example: `./scripts/dev-tools/new-claude-worktree-session.ps1 -ShortName "auth-refactor" -Objective "Refactor the auth module."`

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/claude-cli-background-script/` folder from the template