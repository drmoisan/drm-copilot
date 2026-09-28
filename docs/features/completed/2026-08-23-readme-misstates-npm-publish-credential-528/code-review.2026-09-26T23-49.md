# Code Review — Issue #528 (readme-misstates-npm-publish-credential)

- Timestamp: 2026-09-26T23-49
- Branch: `bug/readme-misstates-npm-publish-credential-528`, HEAD `d198c9c8`
- Scope: three documentation edits (no code files in the diff). Review criteria are adapted to the documentation-only nature of the change; the general-code-change design principles (simplicity, reusability, extensibility, separation of concerns) are not applicable to prose edits and are not scored below.

## Edit 1 — `README.md` (lines 401-402)

Before:
```
- Publish steps: install `packages/mcp-server` dependencies, run `prepack`, build `out/mcp-server.js`, then `npm publish --access public`.
- Credential: publication requires the repository secret `NPM_TOKEN`.
```

After:
```
- Publish steps: install `packages/mcp-server` dependencies, run `prepack`, build `out/mcp-server.js`, then `npm publish --provenance --access public`.
- Credential: publication uses npm trusted publishing over OIDC (workflow permission `id-token: write`); no npm token secret is used.
```

Independently re-verified against `.github/workflows/publish-mcp-npm.yml`:
- Line 45: `id-token: write` — matches the new README claim.
- Line 95: `run: npm publish --provenance --access public` — matches the new publish-steps line exactly.
- No `NPM_TOKEN` or `NODE_AUTH_TOKEN` reference exists anywhere in that workflow file.

Finding: the edit is minimal, technically accurate, and does not touch any other line in the section. No issues.

## Edit 2 — `docs/engineering/npm-token-rotation.runbook.md` (superseded notice)

The new second paragraph is a blockquote note inserted between the title and the existing "Contract-conformant" line:

```
> **Note:** This runbook is superseded; `.github/workflows/publish-mcp-npm.yml` now publishes via npm trusted publishing over OIDC (`id-token: write`) and does not read the `NPM_TOKEN` secret. Rotating `NPM_TOKEN` will not resolve an `npm publish` failure. Retained for historical reference only.
```

This matches Scope Decision D2 in `issue.md`: the notice is added, but the runbook body is deliberately left unrewritten (a full rewrite or deletion was explicitly declared out of scope). This is a reasonable, low-risk choice for a human-exception runbook — leaving the rotation procedure intact for a scenario where `NPM_TOKEN` rotation is genuinely still relevant (e.g., a future consumer of that secret) while directing readers away from treating it as the npm-publish fix. No issues.

## Edit 3 — `docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md` (line 7)

Before:
```
Act when the orchestrator has recorded an `exception` for the `branch-protection-merge-approval` requirement — that is, when the release version-bump task has opened a pull request against `main` that patch-bumps `extensions/drm-copilot/package.json` and `packages/mcp-server/package.json`, and that PR is waiting for review. Branch protection on `main` requires an approving review from a write-access reviewer who is not the PR author, so this step cannot be automated and is a permitted human gate.
```

After:
```
Act when the release version-bump task has opened a pull request against `main` that patch-bumps `extensions/drm-copilot/package.json` and `packages/mcp-server/package.json`. The `protect-main` ruleset requires a pull request and passing status checks but sets `required_approving_review_count: 0`, so merging this pull request requires no approving review.
```

Independently re-verified against the live ruleset via `gh api repos/drmoisan/drm-copilot/rulesets/15241672`:
- `"required_approving_review_count":0` — matches.
- A `pull_request` rule type is present in the ruleset (mandatory PR), which the revised text still states ("requires a pull request"), consistent with Scope Decision D3 (the PR requirement is preserved; only the approval-count claim is corrected).

One observation, not a defect: the revised sentence drops the prior reference to the `exception`/`branch-protection-merge-approval` orchestrator vocabulary from the "Cue" section's opening clause. A full-file search of the runbook (`grep -n "exception\|branch-protection-merge-approval\|cannot be automated\|permitted human gate"`) confirms zero remaining occurrences of any of those four terms anywhere in the file, so no orphaned reference to the removed framing was left behind. No follow-up is needed on this point.

## General Observations

- All three edits are surgical (1-2 lines each), matching the plan's stated line-count expectations and avoiding collateral changes to surrounding text.
- No dependency, API, or naming concerns apply (Markdown prose only).
- No file exceeds the 500-line limit; Markdown is exempt from that limit in any case.
- No secrets, tokens, or credentials were introduced into the diff; the change only removes an inaccurate reference to an existing secret name.

## Verdict

**PASS.** No Blocking or Warning code-quality findings.
