<!-- mirrored from artifacts/research/20260217-link-parent-child-failure-implementation-research.md for feature-folder lifecycle compliance -->

<!-- markdownlint-disable-file -->

# Task Research Notes: link-parent-child-failure

## Research Executed

### File Analysis

- `docs/features/active/2026-02-17-link-parent-child-failure-9/issue.md`
  - Repro is consistent: `link-parent-child.ps1` exits non-zero when child issue fetch fails; VS Code task output can foreground only terminal wrapper + exit code.
- `docs/features/active/2026-02-17-link-parent-child-failure-9/spec.md`
  - Scope and expected behavior emphasize actionable diagnostics for auth/repo/permissions/invalid-number paths.
- `scripts/dev-tools/link-parent-child.ps1`
  - `Get-Issue` collapses all failure causes into one generic message (`Unable to fetch ... Check the number and gh auth.`) and discards command-specific context from `gh` output.
- `tests/scripts/dev-tools/link-parent-child.Tests.ps1`
  - Existing tests cover many success/error branches, but do not assert richer diagnostics (stderr context, auth guidance, repo targeting hint) for fetch failures.
- `.vscode/tasks.json`
  - Task `Dev: 4 Link GitHub Parent/Child Issues` is a shell task without a problem matcher; non-zero exits surface as terminal failure wrappers.
- `src/task-command-map.ts`
  - Extension command `drm-copilot.devLinkParentChild` maps to same script invocation/args as `.vscode/tasks.json`; this is an automation touchpoint for consistent behavior.
- `scripts/dev-tools/link-feature-docs.ps1`
  - Sister script shares similar `Invoke-GhCli`/error approach; useful pattern reference for consistency if shared helper behavior is considered.
- `artifacts/orchestration/powershell-orchestrator-state.json`
  - Workflow confirms this is Step 3 research for Issue #9 and target feature folder.

### Code Search Results

- `link-parent-child|ChildIssueNumber|ParentIssueNumber`
  - Located implementation (`scripts/dev-tools/link-parent-child.ps1`), tests (`tests/scripts/dev-tools/link-parent-child.Tests.ps1`), task wiring (`.vscode/tasks.json`), extension mapping (`src/task-command-map.ts`), and feature docs (`issue.md`, `spec.md`, plan).
- `Write-ScriptError|Get-Issue|Invoke-GhCli`
  - Failure handling currently throws `InvalidOperationException` with high-level messages; `Get-Issue` evaluates only `ExitCode` + empty output and does not classify failure type.
- `Dev: 4 Link GitHub Parent/Child Issues`
  - Confirmed label consistency across package command contribution and task map.

### External Research

- #githubRepo:"N/A (tool unavailable in this environment) gh cli link-parent-child error handling patterns"
  - Unable to query repository search via a dedicated GitHub-repo search tool in this session; recommendation is therefore based on official CLI manuals plus in-repo tests/patterns.
- #fetch:https://github.com/drmoisan/drm-copilot/issues/9
  - Returned HTTP 404 (likely private or inaccessible from current fetch context); local `issue.md`/`spec.md` were used as authoritative issue source.
- #fetch:https://cli.github.com/manual/gh_issue_view
  - Confirms `gh issue view` supports `--json` fields used by script and supports `-R/--repo`, which is currently not leveraged in the script for explicit repo targeting.
- #fetch:https://cli.github.com/manual/gh_issue_edit
  - Confirms `--body-file` behavior used by script; edit operations depend on auth/permission scopes.
- #fetch:https://cli.github.com/manual/gh_issue_comment
  - Confirms comment behavior and repo override support (`-R/--repo`) for deterministic targeting.
- #fetch:https://cli.github.com/manual/gh_auth_status
  - Confirms auth diagnostics path; importantly, this command exits 1 on auth issues, while `--json` mode always returns 0 unless fatal.
- #fetch:https://cli.github.com/manual/gh_help_environment
  - Confirms `GH_REPO` and `GH_HOST` variables influence command context; missing/mismatched repo context is a plausible root-cause class.
- #fetch:https://cli.github.com/manual/gh_help_exit-codes
  - Confirms exit code semantics (`0` success, `1` generic failure, `2` cancel, `4` auth required) useful for richer classification.
- #fetch:https://code.visualstudio.com/docs/editor/tasks
  - Confirms shell tasks surface command output/exit and can be enhanced via presentation/problem-matcher configuration; explains wrapper-style task error presentation.

### Project Conventions

- Standards referenced: general code-change + PowerShell code-change/test policies in `.github/instructions/`; bugfix workflow expects failing regression test first, then minimal fix, then full quality loop.
- Instructions followed: research-only mode constraints, issue-first analysis, implementation-focused output, and feature-context tracing.

## Key Discoveries

### Project Structure

PowerShell script behavior is orchestrated through both `.vscode/tasks.json` and extension command mapping in `src/task-command-map.ts`. This means user-facing behavior is affected by:

1. Script internals (`scripts/dev-tools/link-parent-child.ps1`), and
2. Task execution context (non-interactive shell wrapper behavior in VS Code tasks).

Primary change candidates (implementation phase):

- `scripts/dev-tools/link-parent-child.ps1` (core fix)
- `tests/scripts/dev-tools/link-parent-child.Tests.ps1` (regression + scenario expansion)
- Optional/no-change-by-default touchpoints to evaluate only if needed:
  - `.vscode/tasks.json` (presentation/problem matcher)
  - `src/task-command-map.ts` (if task label/args change)

### Implementation Patterns

Observed root-cause contributors in current implementation:

- `Test-GhCli` verifies only binary presence (`Get-Command gh`) but not auth state.
- `Get-Issue` treats all fetch failures as one message and does not include `gh` stderr or repo context.
- No explicit `-R/--repo` parameter or repo-context preflight, so failures can reflect incorrect inferred repo.
- In task context, the terminal often foregrounds exit-status framing; if diagnostics are not explicit and early, troubleshooting is slower.

### Complete Examples

```powershell
# Source: scripts/dev-tools/link-parent-child.ps1 (current implementation)
function Get-Issue {
    param(
        [string] $IssueNumber,
        [string] $Label,
        [scriptblock] $InvokeGh = { param([string[]] $GhArgs) Invoke-GhCli -GhArgs $GhArgs }
    )

    $result = & $InvokeGh @('issue', 'view', $IssueNumber, '--json', 'number', 'title', 'url', 'body')
    if ($result.ExitCode -ne 0 -or -not $result.Output) {
        Write-ScriptError "Unable to fetch $Label issue #$IssueNumber. Check the number and gh auth."
    }

    return $result.Output | ConvertFrom-Json
}
```

### API and Schema Documentation

- `gh issue view` / `gh issue edit` / `gh issue comment`:
  - Support `-R/--repo` for deterministic repository selection.
  - `gh issue view ... --json number,title,url,body` aligns with current script.
- `gh auth status`:
  - Suitable for explicit preflight diagnostics; note special exit behavior when `--json` is used.
- `gh` exit codes:
  - `4` indicates auth required; enables more targeted user guidance than current generic message.

### Configuration Examples

```json
{
  "label": "Dev: 4 Link GitHub Parent/Child Issues",
  "type": "shell",
  "command": "pwsh",
  "args": [
    "-NoLogo",
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    "${workspaceFolder}/scripts/dev-tools/link-parent-child.ps1",
    "-ChildIssueNumber",
    "${input:ChildIssueNumber}",
    "-ParentIssueNumber",
    "${input:ParentIssueNumber}"
  ],
  "problemMatcher": []
}
```

### Technical Requirements

- Preserve non-zero exits on failure.
- Improve failure classification and message actionability for at least:
  - invalid issue number/not found,
  - auth/token problems,
  - repo targeting mismatch/inference errors,
  - permissions/scope errors.
- Keep implementation focused on `scripts/dev-tools/link-parent-child.ps1` with tests in `tests/scripts/dev-tools/link-parent-child.Tests.ps1`.
- Validation must include PowerShell quality loop: format → analyze → Pester.

## Recommended Approach

Implement a **minimal, classified error-diagnostics path in `link-parent-child.ps1`** (no architectural rewrite):

1. Add a small helper that normalizes `gh` failures into categories using:
   - exit code (`4` => auth required),
   - stderr/output signature snippets (not found/permissions/repo context clues),
   - optional repo context (`gh repo view --json nameWithOwner` or equivalent best-effort).
2. Update `Get-Issue` error path to include:
   - label + issue number,
   - best-effort repo context (or explicit suggestion to set `GH_REPO` / use `-R`),
   - actionable next steps (`gh auth status`, verify issue number, verify access/scope).
3. Keep throw semantics (`InvalidOperationException`) and overall control flow unchanged.
4. Add failing regression tests first in `tests/scripts/dev-tools/link-parent-child.Tests.ps1` for child-fetch failure diagnostics; then implement minimal code to pass.

Why this is the best fit:

- Meets issue acceptance criteria with smallest surface-area change.
- Preserves existing behavior and automation contracts.
- Avoids broad refactor/dependency additions.
- Leverages already strong unit test coverage in the script.

Rejected alternatives (brief, non-exhaustive):

- Full refactor to shared gh-wrapper module across multiple scripts: rejected for this bug because scope/risk is larger than needed.
- Task-only changes (problem matcher/presentation) without script diagnostics: rejected because root actionable context should come from script-level error messages regardless of launcher.
- Silent retries/fallback repo probing: rejected due to ambiguity and potential to mask root causes.

## Implementation Guidance

- **Objectives**: Make fetch failures for child/parent issue retrieval self-diagnosing while preserving non-zero failure behavior and existing script flow.
- **Key Tasks**:
  - Add regression tests (failing first) for `Get-Issue`/`Invoke-LinkParentChild` fetch-failure diagnostics.
  - Implement categorized message construction in `scripts/dev-tools/link-parent-child.ps1`.
  - Keep optional follow-up for `.vscode/tasks.json` strictly scoped if script-level diagnostics are still obscured.
- **Dependencies**:
  - Existing `gh` CLI only; no new runtime dependencies required.
  - Existing Pester harness and mocks in `tests/scripts/dev-tools/link-parent-child.Tests.ps1`.
- **Success Criteria**:
  - Repro case emits explicit, actionable error text in direct script execution.
  - Task-invoked run still exits non-zero and includes same actionable diagnostics in terminal output.
  - New/updated regression tests pass.
  - PowerShell toolchain pass for changed files (format/analyze/test) in final verification.
