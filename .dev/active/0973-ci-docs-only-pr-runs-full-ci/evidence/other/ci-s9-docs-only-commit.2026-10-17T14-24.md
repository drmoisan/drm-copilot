# CI Quality Gate [P5-T5]: Docs-Only Evidence Commit on PR #975 (Issue #973)

Timestamp: 2026-10-17T14-24
Command: gh run list --workflow ci.yml --branch bug/ci-docs-only-pr-runs-full-ci-973; gh run view 39040462663 --job 117418781887 --log; gh pr checks 975 --json name,bucket
EXIT_CODE: 0

## Run

- Pull request: #975
- Docs-only evidence commit: f110e84edcdc9f7e6a5aacf5cdd7b19a9313a4f6, which changes only paths under `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/` (the three review artifacts, the [P5-T4] evidence artifact, the AC-24 checkbox in `spec.md`, and the [P5-T4] checkbox in the plan)
- Run identifier: 39040462663 (event `pull_request`), conclusion success
- Newest run on the branch whose `CI full run` job succeeded: 39039639260, head e1a6c90eaff39e5da86d46006a1b4459593f8c4f (no later code commit exists)

## Change scope decision

Log line of the `Change scope` job, step `Decide the change scope`:

```
code=false reason=DOCS_ONLY_SINCE_e1a6c90eaff39e5da86d46006a1b4459593f8c4f
```

The SHA after `DOCS_ONLY_SINCE_` equals the head SHA of run 39039639260.

## Checks

- Each of the eleven required contexts of ruleset 15241672 (re-confirmed in `ci-s9-first-run.2026-10-17T14-21.md`) reports pass: drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest); drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest); docs-validation / Documentation Validation; poshqc / PowerShell QC; shell-coverage / Shell Coverage (Bats + kcov); security-scan / Security Scanning; quality-checks7 / Code Quality & Tests (3.10), (3.11), (3.12), (3.13); build-check / Build Package.
- Skipped at job level, as the docs-only behavior specifies: `CI full run`, `NPM Audit Gate`, `poshqc / PowerShell QC static`, the poshqc shard jobs, `poshqc / PowerShell hook suites (Linux)`, `root-typescript-tests`.
- All checks on the head SHA: 15 pass, 6 skipping, 0 pending, 0 failing.

Output Summary: run 39040462663 logged `code=false reason=DOCS_ONLY_SINCE_e1a6c90eaff39e5da86d46006a1b4459593f8c4f`, equal to the head of the newest full green run 39039639260; 11 of 11 required contexts pass; heavy jobs skipped; 0 failing.
