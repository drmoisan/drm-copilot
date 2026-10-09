# root-format-check-fails-on-test-fixtures (Issue #848)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/root-format-check-fails-on-test-fixtures/ (Issue #848)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #848
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/848
- Last Updated: 2026-10-08
- Work Mode: minor-audit

## Summary

The root `npm run format:check` exits 2 on main because Prettier's `tests/**/*.{...,json}` glob includes JSON fixtures under `tests/fixtures/`. 214 fixture files are reported as unformatted, and one intentionally invalid fixture produces a parse error. The failure is pre-existing and was excluded from the acceptance criteria of #802 and #830.

## Environment

- OS/version: Windows 11 Pro (local toolchain runs during #802 and #830)
- Python version: n/a (Node / Prettier)
- Command/flags used: `npx --yes npm@11 run format:check` from the repository root
- Data source or fixture: `package.json:33` (`format:check` script); `tests/fixtures/**/*.json`; no `.prettierignore` exists at the repository root

## Steps to Reproduce

1. Check out main (for example fb413fce).
2. From the repository root run `npm run format:check`.
3. Observe the exit code and the `[warn]` and `[error]` lines.

## Expected Behavior

`npm run format:check` exits 0 on a clean main checkout, so the root formatting stage of the mandatory toolchain loop can pass. Fixtures that must keep their exact bytes, including intentionally invalid JSON, are excluded from formatting.

## Acceptance Criteria

- [ ] AC-1: From the repository root, `npm run format:check` exits 0 on the branch head.
- [ ] AC-2: Prettier excludes `tests/fixtures/` for both the root `format` and `format:check` scripts, so no file under `tests/fixtures/` is reported, parsed, or rewritten by either script.
- [ ] AC-3: No file under `tests/fixtures/` is modified by the change; in particular `tests/fixtures/worktree-resolution/shared/item-own-invalid-json/artifacts/orchestration/orchestrator-state.json` remains byte-identical and invalid JSON.
- [ ] AC-4: The Pester suites that consume the invalid fixture (`tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` and `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`) pass unchanged after the change.

Scope note (orchestrator, 2026-10-09): adding the root `format:check` to a CI workflow is listed in this issue as a consideration ("consider adding"), not an expected behavior, and is out of scope for this fix. The acceptance criteria above were authored by the orchestrator from the Expected Behavior and Proposed Fix sections because the promoted record carried no explicit `## Acceptance Criteria` section.

## Actual Behavior

Exit code 2. Output recorded at `docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/evidence/baseline/root-format-check.2026-10-07T15-00.md`:

- 214 `[warn] tests/fixtures/...` lines, for example `tests/fixtures/blast_radius/...`, `tests/fixtures/orchestrator_state_blocked_reason/...`, `tests/fixtures/parallel_cohorts/...`, `tests/fixtures/worktree-resolution/...`.
- One parse error on an intentionally invalid fixture:

```
[error] tests/fixtures/worktree-resolution/shared/item-own-invalid-json/artifacts/orchestration/orchestrator-state.json: SyntaxError: Unexpected keyword 'this'. (1:3)
[error] > 1 | { this is not valid json
```

That fixture is consumed by `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1:56` and `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1:61` and is documented in `tests/fixtures/worktree-resolution/README.md:40`; it must stay invalid.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #802 `issue.md:81` (Change Log): "AC-3 narrowed by orchestrator decision to exclude the pre-existing root `format:check` failure (byte-identical output at baseline 6e6ccd62 and at the branch head ...). That failure will be filed as a separate issue." #830 `code-review.2026-10-07T17-00.md:35` and `feature-audit.2026-10-07T17-00.md:61` repeat the request to file it.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

The root formatting gate is permanently red locally, so each change must baseline-diff its output to show no regression (as #830 did), and a real formatting defect in `src/` or `tests/` TypeScript is harder to see. No CI workflow runs the root `format:check` (no `prettier` or `format:check` reference under `.github/workflows/`), so CI does not detect either the existing failure or new ones.

## Suspected Cause / Notes

- `package.json:32-33`: the `format` and `format:check` globs include `"tests/**/*.{ts,tsx,js,mjs,cjs,json}"`, which matches all fixture JSON. There is no `.prettierignore`.
- Running `npm run format` would rewrite fixture bytes, which some tests may depend on (byte-identical corpora, CRLF fixtures), and would fail on the invalid fixture. Reformatting the fixtures is therefore not a safe fix without review.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: none required; add a root `.prettierignore` entry for `tests/fixtures/**` (or narrow the `tests/**` glob in `package.json:32-33`).
- [ ] Integration scenario to retest: `npm run format:check` exits 0 on main; the Pester and pytest suites that read `tests/fixtures/**` pass unchanged.
- [ ] Manual verification notes: consider adding the root `format:check` to CI after it is green, so a regression is detected.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
