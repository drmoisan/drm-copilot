# PowerShell Handoff H1 Run Record (Issue #509)

Timestamp: 2026-09-30T15-05
Handoff: H1
Source: B (same source as H0)
SourceB-Dispatched: 2026-09-30T14:55:30Z (after P8-T10 completion 2026-09-30T14:54:01Z)
Branch: bug/promotion-gate-lacks-preexisting-issue-branch-exec-509 (orchestrator branch substitution for bug/promotion-gate-lacks-preexisting-issue-branch-509)
sanitized: root, absolute-paths, properties, hostname

## Source A refusal

Source A remains unavailable in the orchestrator session for the same reason recorded verbatim in the H0 run record (evidence/baseline/poshqc-local/run-record.md): the Bash tool worktree guard refuses both `pwsh -NoProfile -Command ...` and `pwsh -NoProfile -File ...`, and no PowerShell host tool is available.

## Commands

### Pre-dispatch scope porcelain check

Command: git status --porcelain -- scripts/dev_tools tests/scripts/dev_tools tests/fixtures/orchestrator_state_issue_adoption .claude/lib/orchestrator-state tests/scripts/claude-lib/orchestrator-state scripts/powershell/PoshQC/settings extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state extensions/drm-copilot/resources/claude-customizations/pack-manifests extensions/drm-copilot/resources/powershell/PoshQC/settings extensions/drm-copilot/src/lib/validate extensions/drm-copilot/test/lib/validate extensions/drm-copilot/jest.config.cjs
EXIT_CODE: 0
Output Summary: empty output. HEAD ca655902a441e6be0d1749f91440d07c38dbe941 equals origin/bug/promotion-gate-lacks-preexisting-issue-branch-exec-509 (pushed before dispatch).

### Dispatch

Command: gh workflow run _poshqc.yml --ref bug/promotion-gate-lacks-preexisting-issue-branch-exec-509
EXIT_CODE: 0
Output Summary: run created, https://github.com/drmoisan/drm-copilot/actions/runs/36732800820

### Run identity

Command: gh run list --workflow=_poshqc.yml --branch bug/promotion-gate-lacks-preexisting-issue-branch-exec-509 --limit 1 --json databaseId,headSha,conclusion
EXIT_CODE: 0
Output Summary: databaseId 36732800820, headSha ca655902a441e6be0d1749f91440d07c38dbe941, conclusion success; git rev-parse HEAD = ca655902a441e6be0d1749f91440d07c38dbe941 (equal).

### Step conclusions

Command: gh run view 36732800820 --json jobs
EXIT_CODE: 0
Output Summary: Format PowerShell success; Analyze PowerShell success; Upload PowerShell test artifacts success; run conclusion success.
AnalyzeStep: success

### Artifact download

Command: gh run download 36732800820 -n poshqc-test-results -D <session scratchpad outside the evidence tree>
EXIT_CODE: 0
Output Summary: pester-junit.xml and powershell-coverage.xml written into this folder with sanitization steps 1-4 applied in order (runner workspace prefix D:\a\drm-copilot\drm-copilot in both separator forms replaced by WORKTREE_ROOT; remaining absolute paths replaced by ABSOLUTE_PATH; properties blocks removed; hostname values replaced by HOST). No analyzer-output.txt for Source B. Junit root: tests="6183" failures="0" errors="0" disabled="10" (repository-wide scope, limit (b); H0 root was tests="6109").

### Post-sanitization checks

Command: grep -c -E -e "(^|[^A-Za-z])[A-Za-z]:[\\/]" pester-junit.xml powershell-coverage.xml; grep -c -F -e "<property " (same files); grep -o -h -E -e "hostname=\"[^\"]*\"" pester-junit.xml | sort -u
EXIT_CODE: 1
Output Summary: absolute-path count :0 for both files; property count :0 for both files; hostname extraction prints only hostname="HOST".
