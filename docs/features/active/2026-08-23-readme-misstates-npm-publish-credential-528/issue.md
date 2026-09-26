# readme-misstates-npm-publish-credential (Issue #528)

- Date captured: 2026-08-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/readme-misstates-npm-publish-credential/ (Issue #528)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #528
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/528
- Last Updated: 2026-08-23
- Work Mode: minor-audit

## Summary

`README.md:402` states that npm publication requires the repository secret `NPM_TOKEN`. It does not.
The workflow publishes via npm trusted publishing over OIDC and references no secret at all, so the
documented recovery action for a failed publish points at something that has no effect. A related
release runbook also asserts a branch-protection approval requirement that the live ruleset does not
impose.

## Environment

- OS/version: not applicable (documentation)
- Python version: not applicable
- Command/flags used: `grep -rn 'NPM_TOKEN' .github/workflows/`
- Data source or fixture: `README.md`, `.github/workflows/publish-mcp-npm.yml`, repository ruleset `protect-main`

## Steps to Reproduce

1. Read `README.md:402`: "Credential: publication requires the repository secret `NPM_TOKEN`."
2. Run `grep -rn 'NPM_TOKEN' .github/workflows/`. It returns nothing.
3. Read `.github/workflows/publish-mcp-npm.yml`: line 37 declares `id-token: write`, line 46 sets `registry-url: "https://registry.npmjs.org"`, and line 63 runs `npm publish --provenance --access public`. No `NODE_AUTH_TOKEN` is set anywhere.

## Expected Behavior

The release documentation names the credential mechanism the workflow actually uses, so that someone
debugging a failed publish investigates the right thing.

## Actual Behavior

Three inaccuracies, in decreasing severity:

1. **`README.md:402` names the wrong credential mechanism.** The `NPM_TOKEN` secret does exist in the repository, which makes the claim especially convincing, but no workflow references it. Authentication is npm trusted publishing via OIDC. Rotating or replacing `NPM_TOKEN` cannot fix an npm publish failure, and treating it as the cause would send someone down a dead end while a real OIDC or trusted-publisher misconfiguration went unexamined.
2. **`README.md:401` omits `--provenance`.** It describes the publish step as `npm publish --access public`; the workflow runs `npm publish --provenance --access public`. The flag is not cosmetic — it produces the provenance attestation every recent release carries, and a local `npm publish` following the documented command would silently drop it.
3. **`docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md:7` asserts** that "Branch protection on `main` requires an approving review from a write-access reviewer who is not the PR author, so this step cannot be automated and is a permitted human gate." The live ruleset `protect-main` sets `required_approving_review_count: 0`. A pull request is still mandatory, but no approving review is. The runbook therefore documents a human gate that does not exist.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `gh api repos/drmoisan/drm-copilot/rulesets/15241672` reports the `pull_request` rule with `required_approving_review_count: 0`, against the runbook's claim of a required non-author approval.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

Low: no code is affected and no gate is wrong. The cost is misdirected debugging during a release,
which is exactly when time pressure is highest, plus a stale runbook that could justify blocking an
otherwise-automatable step. The severity is not Medium because a release will still succeed; only the
diagnosis of a failure is misdirected.

## Suspected Cause / Notes

Documentation drift. `NPM_TOKEN` was presumably the original mechanism and the workflow later moved
to OIDC trusted publishing without the README following. The runbook was written against classic
branch protection; protection is now implemented as a repository ruleset, and the approval count is
0 with `bypass_actors: []`.

Worth noting for scope: the ruleset's `required_approving_review_count: 0` is the current state, not
necessarily the intended one. If a non-author approval is actually wanted for release PRs, the
correct fix is to change the ruleset and keep the runbook, rather than to edit the runbook to match a
possibly-unintended setting. That decision belongs to the repository owner and should be made before
this is edited — do not assume the documentation is simply wrong.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: correct `README.md:402` to describe OIDC trusted publishing (`id-token: write` plus `npm publish --provenance`) and state plainly that no npm token is used, and add `--provenance` to the command at line 401.
- [x] Integration scenario to retest: after editing, `grep -rn 'NPM_TOKEN' README.md .github/workflows/` should show the README no longer claiming a credential the workflows do not reference.
- [ ] Decide the ruleset question above, then either update the runbook to match the 0-approval reality or change the ruleset to match the runbook.
- [ ] Consider whether the unused `NPM_TOKEN` secret should be removed, so its presence stops corroborating the incorrect documentation. Confirm no other consumer exists before deleting it.
- [x] Manual verification notes: `.github/workflows/README.md` documents CI reusable-workflow dispatch and does not mention either publish workflow, so it needs no change; the inaccuracy is confined to the root `README.md` and the one runbook.

## Scope Decisions

- D1: `README.md` lines 401-402 are corrected to describe OIDC trusted publishing and add `--provenance` to the documented `npm publish` command.
- D2: `docs/engineering/npm-token-rotation.runbook.md` gets a superseded notice at the top; its body is not rewritten. The byte-identical historical copy under `docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/` is not modified. Alternative: rewrite or delete the runbook.
- D3: The branch-protection runbook `docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md` is edited to match the live ruleset (`required_approving_review_count: 0`; a pull request is still required). Alternative for the repository owner: change the ruleset to require a non-author approval and keep the runbook as-is; that is a GitHub settings change outside this fix.
- D4: Deleting the unused `NPM_TOKEN` repository secret is out of scope for this fix (a credential-management action, not a file edit); recorded as a follow-up.

## Acceptance Criteria

- [ ] AC1. `README.md`'s npm publish release procedure documents the `--provenance` flag in the publish command. Check: `grep -n -- "--provenance" README.md` returns at least one match.
- [ ] AC2. `README.md`'s npm publish release procedure describes the OIDC trusted-publishing mechanism using the literal token `id-token: write`. Check: `grep -n "id-token: write" README.md` returns at least one match.
- [ ] AC3. `README.md` no longer claims that publication requires a repository secret; it contains zero occurrences of the literal token `NPM_TOKEN`. Check: `grep -c NPM_TOKEN README.md` returns `0`.
- [ ] AC4. `docs/engineering/npm-token-rotation.runbook.md` begins with a superseded notice: the literal token `superseded` appears within the file's first 5 lines. Check: `head -n 5 docs/engineering/npm-token-rotation.runbook.md | grep -c superseded` returns `1` or more.
- [ ] AC5. The historical copy `docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/runbooks/npm-token-rotation.runbook.md` remains untouched by this change: it still contains zero occurrences of the literal token `superseded`. Check: `grep -c superseded docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/runbooks/npm-token-rotation.runbook.md` returns `0`.
- [ ] AC6. `docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md` no longer describes the approval step as unautomatable: it contains zero occurrences of the literal token `cannot be automated`. Check: `grep -c "cannot be automated" docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md` returns `0`.
- [ ] AC7. The same runbook still documents that a pull request is required for the release merge: it contains at least one occurrence of the literal token `pull request`. Check: `grep -c "pull request" docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md` returns `1` or more.
- [ ] AC8. The existing docs-validation checks still hold: `README.md` and `LICENSE` are present and `README.md` is non-empty. Check: `test -f README.md && test -s README.md && test -f LICENSE` exits `0`.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
