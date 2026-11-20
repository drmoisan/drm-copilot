# AC-15 — PR ci.yml Run at Branch Head (issue #647, PR #816)

Timestamp: 2026-10-02T00-54
Recorded by: feature-review agent (reaudit, remediation cycle 1 exit)

Commands:
- `gh api repos/drmoisan/drm-copilot/actions/runs/36965884865 --jq '{path,head_sha,conclusion,event,name}'`
- `gh run view 36965884865 --repo drmoisan/drm-copilot --json headSha,conclusion,status,workflowName,event,jobs`
- `gh pr checks 816 --repo drmoisan/drm-copilot`

EXIT_CODE: 0 (all three commands)

Output Summary:
- Run ID: 36965884865
- Workflow: `CI` (`.github/workflows/ci.yml`), event `pull_request`
- Head SHA: `5842258714a4ef7342e71de98f57c26609dcd624` (equals the branch head under review)
- Status / conclusion: `completed` / `success`
- Created 2026-10-02T04:44:42Z, updated 2026-10-02T04:54:04Z
- Job `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)`: conclusion `success`
  - Step `Type-check extension source and test tree`: `success`
  - Step `Run extension unit/integration tests`: `success`
- Job `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)`: conclusion `success`
  - Step `Type-check extension source and test tree`: `success`
  - Step `Run extension unit/integration tests`: `success`
- `gh pr checks 816`: 23 checks, all `pass`.

Disposition: AC-15 PASS. Both matrix legs of `drm-copilot-extension-tests` conclude `success` and each includes the step `Type-check extension source and test tree`. This also satisfies rule `modified-workflow-needs-green-run` for `.github/workflows/_drm-copilot-extension-tests.yml`.
