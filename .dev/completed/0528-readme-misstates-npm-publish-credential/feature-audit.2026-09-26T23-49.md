# Feature Audit — Issue #528 (readme-misstates-npm-publish-credential)

- Timestamp: 2026-09-26T23-49
- Work Mode: `minor-audit`
- AC Source (sole source): `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/issue.md`, `## Acceptance Criteria` section (AC1-AC8).

Each AC below was independently re-derived against the current file contents at HEAD `d198c9c8` (not merely read from the plan's evidence artifacts), plus one cross-check against a live GitHub API source for the ruleset claim underlying AC6/AC7.

## AC1 — README documents `--provenance`

> `README.md`'s npm publish release procedure documents the `--provenance` flag in the publish command. Check: `grep -n -- "--provenance" README.md` returns at least one match.

Re-run: `grep -n -- "--provenance" README.md` → `401:- Publish steps: ... then \`npm publish --provenance --access public\`.`

**PASS.** One match at line 401, inside the npm publish release procedure section.

## AC2 — README describes OIDC via `id-token: write`

> `README.md`'s npm publish release procedure describes the OIDC trusted-publishing mechanism using the literal token `id-token: write`. Check: `grep -n "id-token: write" README.md` returns at least one match.

Re-run: `grep -n "id-token: write" README.md` → `402:- Credential: publication uses npm trusted publishing over OIDC (workflow permission \`id-token: write\`); no npm token secret is used.`

**PASS.** One match at line 402. Cross-checked against `.github/workflows/publish-mcp-npm.yml` line 45 (`id-token: write`), confirming the claim is technically accurate, not just textually present.

## AC3 — README no longer references `NPM_TOKEN`

> `README.md` no longer claims that publication requires a repository secret; it contains zero occurrences of the literal token `NPM_TOKEN`. Check: `grep -c NPM_TOKEN README.md` returns `0`.

Re-run: `grep -c NPM_TOKEN README.md` → `0`.

**PASS.**

## AC4 — Rotation runbook begins with a superseded notice

> `docs/engineering/npm-token-rotation.runbook.md` begins with a superseded notice: the literal token `superseded` appears within the file's first 5 lines. Check: `head -n 5 ... | grep -c superseded` returns `1` or more.

Re-run: `head -n 5 docs/engineering/npm-token-rotation.runbook.md | grep -c superseded` → `1` (match on line 3: "> **Note:** This runbook is superseded; ...").

**PASS.**

## AC5 — Historical copy remains untouched

> The historical copy `docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/runbooks/npm-token-rotation.runbook.md` remains untouched by this change: it still contains zero occurrences of the literal token `superseded`. Check: `grep -c superseded <path>` returns `0`.

Re-run: `grep -c superseded <path>` → `0`.

Additionally, per the reviewer instruction to verify (not assume) this file has no commit in this session's range:
- `git diff origin/main...HEAD --stat -- "docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/"` → no output (zero-file diff for the entire subtree against the merge base).
- `git log -1 --format="%H %ad" --date=iso -- <path>` → `e2dbb76a 2026-07-03 22:20:21 -0400`, which predates both this session (started 2026-09-25) and 2026-09-26.

**PASS.** The historical copy has no commit in this session's range and is byte-identical to its pre-session state on this branch.

## AC6 — Approval runbook no longer claims "cannot be automated"

> `docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md` no longer describes the approval step as unautomatable: it contains zero occurrences of the literal token `cannot be automated`. Check: `grep -c "cannot be automated" <path>` returns `0`.

Re-run: `grep -c "cannot be automated" <path>` → `0`.

**PASS.**

## AC7 — Approval runbook still documents the pull request requirement

> The same runbook still documents that a pull request is required for the release merge: it contains at least one occurrence of the literal token `pull request`. Check: `grep -c "pull request" <path>` returns `1` or more.

Re-run: `grep -c "pull request" <path>` → `6`.

**PASS.** Additionally cross-checked the substance of the claim (not just the literal token) against the live ruleset: `gh api repos/drmoisan/drm-copilot/rulesets/15241672` shows a `pull_request` rule type present (mandatory PR to merge) with `"required_approving_review_count":0`, which matches the revised runbook text exactly ("requires a pull request and passing status checks but sets `required_approving_review_count: 0`").

## AC8 — Docs-validation checks still hold

> The existing docs-validation checks still hold: `README.md` and `LICENSE` are present and `README.md` is non-empty. Check: `test -f README.md && test -s README.md && test -f LICENSE` exits `0`.

Re-run: `test -f README.md && test -s README.md && test -f LICENSE` → exit code `0`.

**PASS.**

## Acceptance Criteria Status

- Source: `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/issue.md`
- Total AC items: 8
- Checked off (delivered): 8 (AC1-AC8, all already `[x]` in `issue.md` at HEAD; this audit independently confirmed each is genuinely satisfied rather than trusting the checkbox state)
- Remaining (unchecked): 0
- Items remaining: none

No AC item required a check-off action from this review; all eight were already checked off by the executor and each is confirmed correct.

## Scope Decisions Cross-Check

- D1 (README OIDC + `--provenance` correction): delivered, matches AC1-AC3.
- D2 (rotation runbook superseded notice, body untouched, historical copy untouched): delivered, matches AC4-AC5.
- D3 (approval runbook corrected to match live ruleset, PR requirement preserved): delivered, matches AC6-AC7.
- D4 (`NPM_TOKEN` secret deletion out of scope, recorded as follow-up): correctly left undelivered; `issue.md`'s "Proposed Fix / Validation Ideas" checklist item for this remains `[ ]`, consistent with D4's explicit scope exclusion. This is not an AC item and does not affect the AC8-item PASS count.

## Overall Determination

**Ready to merge.** All 8 acceptance criteria PASS on independent re-derivation against current file contents plus two external cross-checks (workflow file, live GitHub ruleset API). No Blocking or Warning findings were raised in the accompanying policy-audit or code-review artifacts. The change is confined to its declared documentation scope; the historical copy required to remain untouched by AC5 has no commit in this session's range.
