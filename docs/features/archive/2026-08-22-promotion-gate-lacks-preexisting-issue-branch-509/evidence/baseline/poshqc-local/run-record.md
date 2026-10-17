# PowerShell Handoff H0 Run Record (Issue #509)

Timestamp: 2026-09-30T14-10
Handoff: H0
Source: B
SourceB-Dispatched: 2026-09-30T13:58:06Z (after P0-T17 completion 2026-09-30T13:57:15Z; supersedes an earlier dispatch at 13:44:19Z, run 36723840493, whose copies were replaced)
Branch: bug/promotion-gate-lacks-preexisting-issue-branch-exec-509 (orchestrator branch substitution for bug/promotion-gate-lacks-preexisting-issue-branch-509, which is checked out in a locked planning worktree)
sanitized: root, absolute-paths, properties, hostname

## Source A refusal (verbatim)

The orchestrator session has no dedicated PowerShell host tool; its Bash tool refused both Source A probe forms.

Probe 1 (inline command): `pwsh -NoProfile -Command "$PSVersionTable.PSVersion.ToString()"`

Refusal text: This agent is isolated in the worktree WORKTREE_ROOT, but this command runs pwsh inside a construct too complex to verify; what it reads or is handed as shell text cannot be shown not to run git. Refusing to run it — a worktree-isolated agent's git operations must target its own worktree. Split it into plain, separate commands and run them from WORKTREE_ROOT.

Probe 2 (script file in the session scratchpad): `pwsh -NoProfile -File <scratchpad>/probe.ps1`

Refusal text: This agent is isolated in the worktree WORKTREE_ROOT, but this command runs pwsh in a plain command; what it reads or is handed as shell text cannot be shown not to run git. Refusing to run it — a worktree-isolated agent's git operations must target its own worktree. Run the plain command from WORKTREE_ROOT.

## Commands

### Pre-dispatch scope porcelain check

Command: git status --porcelain -- scripts/dev_tools tests/scripts/dev_tools tests/fixtures/orchestrator_state_issue_adoption .claude/lib/orchestrator-state tests/scripts/claude-lib/orchestrator-state scripts/powershell/PoshQC/settings extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state extensions/drm-copilot/resources/claude-customizations/pack-manifests extensions/drm-copilot/resources/powershell/PoshQC/settings extensions/drm-copilot/src/lib/validate extensions/drm-copilot/test/lib/validate extensions/drm-copilot/jest.config.cjs
EXIT_CODE: 0
Output Summary: empty output (no uncommitted scope-of-the-diff changes). Branch pushed to origin at 127635e94f51e855c7b82f21c87d575bf5acfdad before dispatch (no scope-of-the-diff changes exist at baseline).

### Dispatch

Command: gh workflow run _poshqc.yml --ref bug/promotion-gate-lacks-preexisting-issue-branch-exec-509
EXIT_CODE: 0
Output Summary: run created, https://github.com/drmoisan/drm-copilot/actions/runs/36725543249

### Run identity

Command: gh run list --workflow=_poshqc.yml --branch bug/promotion-gate-lacks-preexisting-issue-branch-exec-509 --limit 1 --json databaseId,headSha,conclusion
EXIT_CODE: 0
Output Summary: [{"conclusion":"success","databaseId":36725543249,"headSha":"127635e94f51e855c7b82f21c87d575bf5acfdad"}]; git rev-parse HEAD at dispatch = 127635e94f51e855c7b82f21c87d575bf5acfdad (equal).

### Step conclusions

Command: gh run view 36725543249 --json jobs
EXIT_CODE: 0
Output Summary: steps: Install PoshQC tooling success; Analyze PowerShell success; run conclusion success.
AnalyzeStep: success

### Artifact download

Command: gh run download 36725543249 -n poshqc-test-results -D <session scratchpad outside the evidence tree>
EXIT_CODE: 0
Output Summary: downloaded pester-junit.xml, powershell-coverage.xml, powershell-coverage.koverage.xml. The two XML files named by the plan were written into this folder with sanitization steps 1-4 applied in order (runner workspace prefix (the CI checkout root) in both separator forms replaced by WORKTREE_ROOT; remaining absolute paths replaced by ABSOLUTE_PATH; properties blocks removed; hostname values replaced by HOST). No analyzer-output.txt is written for Source B. Junit root: tests="6109" failures="0" errors="0" disabled="10" (repository-wide scope, limit (b)).

### Post-sanitization checks

Command: grep -c -E -e "(^|[^A-Za-z])[A-Za-z]:[\\/]" pester-junit.xml powershell-coverage.xml; grep -c -F -e "<property " (same files); grep -o -h -E -e "hostname=\"[^\"]*\"" pester-junit.xml
EXIT_CODE: 1
Output Summary: absolute-path count :0 for both files; property count :0 for both files; every hostname value is hostname="HOST"; the package key WORKTREE_ROOT/.claude/lib/orchestrator-state is intact.
