# P6-T40 — AC-23 (CI `_shell-coverage.yml` job for the pull request) — PASS branch

Timestamp: 2026-09-27T02-33
Task: [P6-T40]
Working directory: repository worktree root
Branch taken: (a) — a pull request exists, `gh pr checks` exits 0, and the `Shell Coverage (Bats + kcov)` row reads `pass`.

This artifact supersedes the branch (b) deferral recorded in `evidence/qa-gates/ac23-pr-ci.2026-09-27T02-20.md`, which is left unchanged.

Command: `gh pr view 705 --repo drmoisan/drm-copilot --json headRefOid,baseRefName`
EXIT_CODE: 0
Output (verbatim):

```
{"baseRefName":"main","headRefOid":"b59aa3094f8d295cd816b856ec219608f33ca2c4"}
```

Command: `gh run view 36288482266 --repo drmoisan/drm-copilot --json headSha,conclusion,event`
EXIT_CODE: 0
Output (verbatim):

```
{"conclusion":"success","event":"pull_request","headSha":"b59aa3094f8d295cd816b856ec219608f33ca2c4"}
```

Command: `gh api repos/drmoisan/drm-copilot/actions/jobs/108533775215 --jq '[.name,.conclusion,.head_sha,(.labels|join(",")),.runner_name] | @tsv'`
EXIT_CODE: 0
Output (verbatim):

```
shell-coverage / Shell Coverage (Bats + kcov)	success	b59aa3094f8d295cd816b856ec219608f33ca2c4	ubuntu-latest	GitHub Actions 1000022742
```

Command: `grep -n -E "runs-on|actions/checkout|fetch-depth" .github/workflows/_shell-coverage.yml`
EXIT_CODE: 0
Output (verbatim):

```
10:    runs-on: ubuntu-latest
14:        uses: actions/checkout@v7
```

Default checkout depth: line 14 (`uses: actions/checkout@v7`) is followed directly by the next step at line 16; no `with:` block and no `fetch-depth` key exist in the workflow, so the checkout uses the action's default depth.

Command: `gh pr checks 705 --repo drmoisan/drm-copilot`
EXIT_CODE: 0
Output (verbatim):

```
Extension Tests (ubuntu-latest)	pass	38s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482104/job/108533774815	
Extension Tests (windows-latest)	pass	49s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482104/job/108533774699	
NPM Audit Gate / npm audit (.)	pass	19s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775414	
NPM Audit Gate / npm audit (extensions/drm-copilot)	pass	18s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775657	
NPM Audit Gate / npm audit (packages/mcp-server)	pass	14s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775316	
Publish to Marketplace	pass	32s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482104/job/108533895854	
build-check / Build Package	pass	47s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775209	
docs-validation / Documentation Validation	pass	6s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775198	
drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)	pass	34s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775265	
drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)	pass	1m3s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775267	
poshqc / PowerShell QC	pass	6m52s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775407	
quality-checks7 / Code Quality & Tests (3.10)	pass	2m53s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775211	
quality-checks7 / Code Quality & Tests (3.11)	pass	2m32s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775166	
quality-checks7 / Code Quality & Tests (3.12)	pass	2m11s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775181	
quality-checks7 / Code Quality & Tests (3.13)	pass	2m22s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775238	
root-typescript-tests / Root TypeScript Tests (ubuntu-latest)	pass	30s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775248	
root-typescript-tests / Root TypeScript Tests (windows-latest)	pass	1m12s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775170	
security-scan / Security Scanning	pass	35s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775057	
shell-coverage / Shell Coverage (Bats + kcov)	pass	5m27s	https://github.com/drmoisan/drm-copilot/actions/runs/36288482266/job/108533775215	
```

Output Summary:
- Pull request: #705 (base `main`), headRefOid `b59aa3094f8d295cd816b856ec219608f33ca2c4`.
- Run: 36288482266 (`event: pull_request`), headSha `b59aa3094f8d295cd816b856ec219608f33ca2c4`, conclusion `success`.
- Job: 108533775215 `shell-coverage / Shell Coverage (Bats + kcov)`, runner label `ubuntu-latest`, conclusion `success`.
- Checkout: `.github/workflows/_shell-coverage.yml` line 14 `uses: actions/checkout@v7` with no `fetch-depth` override (default depth).
- `gh pr checks 705` exited 0; all 19 checks read `pass`, including the `Shell Coverage (Bats + kcov)` row.
- AC-23: PASS
