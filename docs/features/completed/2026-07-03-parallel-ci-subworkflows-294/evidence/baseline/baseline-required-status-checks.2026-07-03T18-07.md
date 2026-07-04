# Pre-Extraction Required-Status-Check Baseline (P0-T8)

- Timestamp: 2026-07-03T21:30:00Z
- Command: `gh api repos/drmoisan/drm-copilot/branches/main/protection/required_status_checks`
- Owner: orchestrator (direct `gh` invocation)

## Result

The initial call to `gh api repos/drmoisan/drm-copilot/branches/main/protection/required_status_checks`
returned:

```
gh: Branch not protected (HTTP 404)
```

A broader call to `gh api repos/drmoisan/drm-copilot/branches/main/protection` (the parent
branch-protection resource) confirms the same condition directly:

```json
{"message":"Branch not protected","documentation_url":"https://docs.github.com/rest/branches/branch-protection#get-branch-protection","status":"404"}
```

- EXIT_CODE: 1 (gh api returns non-zero on a 404 response)

## Output Summary

**No branch protection rule currently exists on `main`, and consequently no required-status-checks
list exists to enumerate.** None of the seven job names targeted by this feature
(`quality-checks7`, `security-scan`, `docs-validation`, `build-check`, `poshqc`, `shell-coverage`,
`drm-copilot-extension-tests`, or their individual matrix legs) are currently configured as a
required status check on `main`, because branch protection itself is not enabled on this branch.

This changes the required-status-check "rename" concern documented in `issue.md` and
`.github/workflows/README.md`'s "Required-Status-Check Rename Procedure" section from an active
migration risk (renaming an existing required check) to a forward-looking configuration
opportunity: whoever enables branch protection on `main` in the future should use the
post-extraction check-run names captured in P4-T9 (`required-status-check-names.<timestamp>.md`),
not any pre-extraction name, since no pre-extraction name was ever registered as required. This
baseline is the authoritative "before" state for the P4-T10 reconciliation step's diff.
