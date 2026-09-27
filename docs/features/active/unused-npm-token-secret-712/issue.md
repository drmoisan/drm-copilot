# unused-npm-token-secret (Issue #712)

- Date captured: 2026-09-26
- Author: Dan Moisan
- Status: Active -> docs/features/active/unused-npm-token-secret-712/ (Issue #712)
- Issue: #712
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/712
- Last Updated: 2026-09-27
- Work Mode: full-bug

> Source note: the potential-entry lifecycle record for this issue is not present on this branch. This file was populated from the GitHub issue #712 body (`gh issue view 712`). The issue body carries `- Work Mode: minor-audit`; the orchestration kickoff for this run selected `full-bug`, which is the persisted mode.

## Summary

The repository secret `NPM_TOKEN` is referenced by no workflow. `publish-mcp-npm.yml` publishes through npm trusted publishing (OIDC, `id-token: write` with `--provenance`). Issue #528 (PR #701) corrected the docs and left deleting the secret as a follow-up under its decision D4.

## Environment

- OS/version: n/a (GitHub repository settings)
- Python version: n/a
- Command/flags used: `gh secret list`, and a search of `.github/workflows/` for `NPM_TOKEN`
- Data source or fixture: the drmoisan/drm-copilot repository secrets

## Steps to Reproduce

1. List the repository secrets and see that `NPM_TOKEN` is present.
2. Search `.github/workflows/`: no workflow references it.

## Expected Behavior

No unused long-lived publish credential is stored in the repository.

## Actual Behavior

An unused npm token remains stored. A leaked or stale token is exposure without any benefit, and its presence misleads maintainers into rotating it to fix publish failures, as the old README advised.

## Logs / Screenshots

- Snippet: #528 `issue.md` D4, and the `feature-audit.2026-09-26T23-49.md` note on D4.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Scope Note (orchestration kickoff)

This is a credential-management action. The automatable portion is: verifying that no workflow references `NPM_TOKEN`, removing dead references in workflows or docs, and adding a guard test that fails if an unused-secret reference reappears. Deleting the repository secret and revoking the npm token require a human and are routed through a human-exception runbook under this feature's `runbooks/` folder. No agent reads, prints, or handles any secret value.

## Acceptance Criteria

- [ ] AC1. No file under `.github/workflows/` references the `NPM_TOKEN` secret, verified by a repository check.
- [ ] AC2. A guard test exists that fails when a workflow reintroduces a reference to `NPM_TOKEN`, and passes on the current tree.
- [ ] AC3. Dead repository documentation that directs maintainers to use or rotate `NPM_TOKEN` for npm publishing is removed or marked superseded, per the decision recorded in `spec.md`.
- [ ] AC4. A human-exception runbook for deleting the `NPM_TOKEN` repository secret and revoking the corresponding npm token exists under this feature's `runbooks/` folder, and the human action is recorded as pending.

## Source

From: docs/features/potential/2026-09-26-unused-npm-token-secret.md (lifecycle record not present on this branch)
