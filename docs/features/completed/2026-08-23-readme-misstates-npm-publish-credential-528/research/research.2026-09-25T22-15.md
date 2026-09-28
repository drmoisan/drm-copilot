# Research — readme-misstates-npm-publish-credential (Issue #528)

- Issue: #528
- Work mode: minor-audit (documentation-only)
- Date: 2026-09-25
- Requirements source: `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/issue.md` (read in full)

## Tooling constraint

This research session has no shell/`git`/`gh` execution tool available (Read, Grep, Glob, WebFetch, Write,
Edit only). Commit hashes `e11b669e` and `7efb7357` named in the delegation prompt, and the ruleset/secret
evidence already gathered by the orchestrator via `gh api`, are therefore reported as supplied and cross-checked
against the current tree content, not independently re-run against `git log`/`gh api` in this session. All
file-content findings below were verified by reading the current tree.

## 1. README.md publish procedure vs. the actual workflow

`README.md:397-403` ("npm publish release procedure"):

```
397  ### npm publish release procedure
398
399  - Trigger: push a git tag matching `mcp-server-v*` such as `mcp-server-v0.0.1`.
400  - Gate: the workflow runs the extension test matrix on Ubuntu and Windows before publish.
401  - Publish steps: install `packages/mcp-server` dependencies, run `prepack`, build `out/mcp-server.js`, then `npm publish --access public`.
402  - Credential: publication requires the repository secret `NPM_TOKEN`.
403  - Release prerequisite: keep `packages/mcp-server/package.json` and `extensions/drm-copilot/package.json` version values aligned before tagging.
```

`.github/workflows/publish-mcp-npm.yml` was read in full (129 lines). Verified facts:

- Line 45: `permissions: { contents: read, id-token: write }` on the `publish` job — this is the OIDC token grant that enables npm trusted publishing.
- Line 54: `registry-url: "https://registry.npmjs.org"` on the `actions/setup-node@v7` step.
- Line 56-57: `npm install -g npm@11.18.0`, with a comment "Upgrade npm for trusted publishing" — npm 11.5+ is required for OIDC trusted-publisher flows.
- Line 95: the publish step runs `npm publish --provenance --access public` (working directory `packages/mcp-server`), guarded by `if: startsWith(github.ref, 'refs/tags/mcp-server-v')`.
- No `NODE_AUTH_TOKEN` environment variable and no `secrets.NPM_TOKEN` reference appear anywhere in the file. A repository-wide grep for `NPM_TOKEN` (below, item 4) confirms this workflow is the only place the README's claim could be corroborated, and it is not.

Confirmed inaccuracies, matching the issue's description exactly:

1. `README.md:402` names `NPM_TOKEN` as the publish credential; the workflow uses OIDC trusted publishing (`id-token: write` + npm 11.18 + `registry-url`) and never references `NPM_TOKEN`.
2. `README.md:401` documents the publish command as `npm publish --access public`; the workflow runs `npm publish --provenance --access public`. The omitted flag is the one that produces the provenance attestation.

No third inaccuracy was found in this section; the trigger, gate, and version-alignment lines (399, 400, 403) match the workflow's tag pattern, `needs: drm-copilot-extension-tests` gate, and the `Verify tag version matches the mcp-server manifest` step.

## 2. `docs/engineering/npm-token-rotation.runbook.md` — stale given trusted publishing

### Current content and premise

The runbook (39 lines) is a "Human-Exception Runbook" whose `## Cue` section instructs the operator to rotate
the `NPM_TOKEN` GitHub Actions secret when `.github/workflows/publish-mcp-npm.yml`'s `Publish to npm` step fails
with `E404`. Its step-by-step instructions are entirely npmjs.com/GitHub UI navigation for generating a new
token and pasting it into the `NPM_TOKEN` secret value.

Given the confirmed facts in item 1 — the publish step authenticates via OIDC trusted publishing and reads no
`NPM_TOKEN` secret at all — rotating that secret cannot affect the outcome of a future `npm publish` failure.
The runbook's entire premise (an `E404` is caused by an expired/misscoped `NPM_TOKEN`, and rotating it fixes
the failure) no longer matches the live authentication mechanism. It is stale, in the same sense the issue
uses for the README lines.

### Duplicate copy and reference audit

An identical 39-line copy exists at
`docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/runbooks/npm-token-rotation.runbook.md`
(byte-for-byte identical text, verified by reading both files). That copy is the artifact the 2026-07-03
feature (issue #283) produced and referenced from its own `issue.md`, `plan`, `feature-audit`, and
`code-review` documents as the resolution path for the npm `E404` defect that feature scoped out of its own
fix. It is a historical record of what that feature delivered at the time.

The `docs/engineering/npm-token-rotation.runbook.md` copy is referenced from the active feature for issue #526
in two places:

- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/runbooks/burned-version-disposition.runbook.md:257` — cited only as "Runbook structure and register precedent," i.e., a formatting/structure example, not as an actionable instruction to rotate a token.
- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/research/research.2026-08-24T12-45.md:1088` — cited descriptively as an existing human-exception runbook example.

Neither reference depends on the runbook's `NPM_TOKEN`-rotation content being current; both cite it as a
structural precedent. A superseded-notice edit to `docs/engineering/npm-token-rotation.runbook.md` would not
break either reference, because the file's structure (headings: Cue, Prerequisites, Step-by-step Instructions,
Verification, Source and Citation) is unchanged by prepending a notice.

### Should `docs/features/completed/.../runbooks/npm-token-rotation.runbook.md` be edited?

No policy or validator found in this repository declares files under `docs/features/completed/` immutable at
the content level. A grep across `.claude/` and `scripts/` for `features/completed` found only references to
the *lifecycle path* changing when a feature moves from `active/` to `completed/` (in
`.claude/skills/epic-orchestrate/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, and
`.claude/rules/plan-acceptance-gates.md`, itself citing a completed-tree evidence path after a feature moved).
None of these treat completed-folder file *content* as write-protected. The "historical records under
`docs/features/completed/` should normally not be rewritten" instruction in the delegation prompt is therefore
a documentation norm, not a tool-enforced constraint; it is followed here as a matter of scope discipline
(issue #528 is scoped to the credential/provenance and ruleset-vs-runbook questions, not to auditing every
historical feature folder), not because a validator would block the edit.

### Recommendation

Edit only `docs/engineering/npm-token-rotation.runbook.md` (the copy actively cross-referenced by newer work)
by adding a superseded/stale notice at the top of the file, pointing to trusted publishing as the current
mechanism, rather than deleting the file or rewriting its body. Do not touch the
`docs/features/completed/2026-07-03-.../runbooks/npm-token-rotation.runbook.md` copy — it is the historical
record of what issue #283 delivered, and neither active reference to the engineering copy depends on that
historical copy changing.

Rationale: the underlying npmjs.com/GitHub UI navigation the runbook documents (generating an access token,
updating a repository secret) remains factually correct process documentation and has independent value if a
future incident required reverting to token-based auth; only the *applicability* of the runbook to a current
`npm publish` failure is wrong. A superseded notice corrects the applicability claim with a minimal, additive
diff, consistent with the minor-audit/documentation-only work mode and with the README fix's own minimal-diff
approach (add the missing fact, do not restructure the surrounding document).

## 3. Branch-protection approval count vs. `release-pr-merge-approval.runbook.md`

`docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md:7`
states: "Branch protection on `main` requires an approving review from a write-access reviewer who is not the
PR author, so this step cannot be automated and is a permitted human gate."

Orchestrator-supplied evidence (`gh api repos/drmoisan/drm-copilot/rulesets/15241672`, captured 2026-09-25):
ruleset `protect-main`, enforcement active, targets `~DEFAULT_BRANCH` and `refs/heads/development`;
`pull_request` rule has `required_approving_review_count: 0`, `required_reviewers: []`,
`require_code_owner_review: false`; `required_status_checks` is strict with 11 contexts; `bypass_actors` now
contains one entry (`actor_id 54180981`, `actor_type User`, `bypass_mode pull_request`) — the issue text's
`bypass_actors: []` is stale; ruleset `updated_at` is 2026-08-29.

This confirms the issue's core claim: the runbook documents a mandatory non-author-approval gate that the live
ruleset does not impose (`required_approving_review_count: 0`). A PR is still required (the ruleset still
targets the branch with status-check and PR rules), but no approving review is required to merge it.

### Three options

**Option A — treat 0 approvals as intended; edit the runbook to match.** Rewrite step 7 (and the
`## Prerequisites` line "You are not the author... GitHub prohibits authors from approving their own pull
requests") to state that a release PR merges once required status checks pass, with no approval gate, and
reclassify the merge step from a human-exception runbook target to an automatable step.

**Option B — treat 0 approvals as unintended; change the ruleset, keep the runbook.** Restore
`required_approving_review_count` to 1 (or higher) on the `protect-main` ruleset via the GitHub UI or API, so
the runbook's documented behavior becomes true again. This is a GitHub repository-settings change, not a file
edit, and cannot be performed by this agent or by any in-repo automation (no workflow or script found in
`.github/` or `scripts/` that calls the rulesets API to write configuration; the orchestrator's own evidence
was gathered via a read-only `gh api` GET).

**Option C — annotate the runbook as historical/superseded, without deciding A or B.** Add a note stating the
ruleset's approval count is currently 0, that this may not reflect intent, and that the step described may not
currently function as a gate, without changing the substantive Instructions/Verification content or touching
the ruleset. This defers the actual policy question but corrects the immediate inaccuracy (the runbook no
longer describes an existing gate).

### Recommendation: Option A, with a scoped rationale

Recommend **Option A** — edit the runbook to match the 0-approval reality — for this documentation-only fix,
for the following reasons drawn from the delegation prompt's own framing:

- This repository is agent-operated by a single owner (`Git user: Dan Moisan`, confirmed from git status in
  this session's environment). A required non-author approval on every release PR is structurally difficult
  for a single-operator repository to satisfy without a second human or a bypass actor, which is presumably
  why `bypass_actors` now contains one entry.
- `.claude/skills/orchestrate/SKILL.md`'s autonomous-execution mandate (referenced by the delegation prompt)
  treats manual gates as defects to be minimized; a stale runbook asserting a mandatory human approval gate
  that does not exist would misdirect an agent into treating an already-automatable release merge as blocked,
  which is the same class of harm the issue describes for the `NPM_TOKEN` line (misdirected effort during a
  release).
- Changing the ruleset (Option B) is explicitly out of scope for a file-edit fix: it requires a GitHub
  repository-settings API write, which this issue's minor-audit/documentation-only work mode does not extend
  to, and which no in-repo automation currently performs.
- The ruleset's `updated_at: 2026-08-29` postdates the runbook's original writing (captured 2026-06-19 per its
  own citation), and the addition of a `bypass_actors` entry between the issue's capture and the orchestrator's
  2026-09-25 evidence suggests the 0-approval configuration is a deliberate, evolving repository-operations
  decision rather than an accidental drift — supporting treating it as the source of truth to document against,
  not as an error to silently correct via a ruleset change bundled into a documentation fix.

Editing this runbook is a second historical-completed-folder edit (see item 2's immutability discussion): the
same conclusion applies — no validator blocks it, and the file is being corrected for the same reason the
README is being corrected (documentation drift against current live state), not rewritten for style. Because
the file is under `docs/features/completed/separate-version-bump-from-publish-214/`, apply the same
minimal-diff discipline: correct the specific inaccurate claim and its immediate prerequisite bullet, and do
not restructure the rest of the runbook (Verification and Source and Citation sections describe generic GitHub
mechanics that remain accurate).

If the repository owner instead confirms Option B is intended (a deliberate decision the delegation prompt
says "belongs to the repository owner"), that decision requires a `human-exception` or `scope_change`
response outside this documentation fix's scope, per the Automation Feasibility section below.

## 4. Unused `NPM_TOKEN` secret — removal scope

Repository-wide search for `NPM_TOKEN` (excluding documentation/research/runbook prose already covered above)
across `.github/`, `scripts/`, `packages/`, and `extensions/`:

- `.github/workflows/publish-mcp-npm.yml` — no match (confirmed in item 1).
- `.github/workflows/verify-published-releases.yml` — read in full (96 lines); no `NPM_TOKEN` reference; its
  registry check uses unauthenticated `npm view` (read-only, no publish credential needed).
- `.github/workflows/publish-extension.yml`, `.github/workflows/npm-audit-gate.yml`, and every other file under
  `.github/workflows/` — no match (the sole hit in `.github/` overall is the README line already discussed).
- `packages/` — no match.
- `extensions/` — no match.
- `scripts/` — no match.

No workflow or script anywhere in the current tree references the `NPM_TOKEN` secret. Its only remaining
function is to exist as a leftover from before trusted publishing was adopted (per the issue's own
"Suspected Cause" note, corroborated by `docs/research/2026-05-04-publish-mcp-server-to-npm-research.md:15,172,177`
and `docs/features/completed/2026-05-06-publish-mcp-server-to-npm-173/spec.md:39,49,98,168`, which document
`NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}` as the original 2026-05 design, before the 2026-07 switch to OIDC
trusted publishing described in `docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/`).

### Recommendation: out of scope for this fix

Deleting a GitHub Actions repository secret is a repository-settings action (`gh secret delete NPM_TOKEN` or
the Settings UI), not a file edit, and requires a decision the delegation prompt itself frames as separate
("Recommend in or out of scope for this fix (deleting a secret is not a file edit)"). Recommend **out of
scope**: this issue's work mode is minor-audit/documentation-only, and the secret's removal has no bearing on
the README or runbook text corrections — a reader can no longer be misdirected by `NPM_TOKEN` once the README
and runbook text stop pointing at it, independent of whether the secret value itself still exists in GitHub
settings. Record the unused-secret finding as a follow-up item (e.g., a `scope_change` or a separate low-effort
housekeeping task) rather than bundling a secret-deletion action into this documentation fix.

## 5. Documentation validation tooling

### CI job

`.github/workflows/_docs-validation.yml` (reusable workflow, invoked from `ci.yml:17-18` as job
`docs-validation`) runs three shell steps on `ubuntu-latest`:

1. `Validate README exists and is not empty` — `[ ! -f README.md ] || [ ! -s README.md ]` fails the step with
   `ERROR: README.md is missing or empty` if either condition holds.
2. `Check for LICENSE file` — `[ ! -f LICENSE ]` fails the step with `ERROR: LICENSE file is missing`.
3. `Validate instruction documents exist` — checks `.github/copilot-instructions.md` and
   `docs/code-change.instructions.md`; each missing file prints a `WARNING:` line but does not fail the step
   (no `exit 1` in this block).

This is the entirety of the repository's docs-validation CI job. No markdownlint, no link-checker, and no
content-correctness check (e.g., no scan for stale credential names) exists in this workflow or elsewhere in
the tree: a repository-wide search for `markdownlint`, `remark`-as-a-linter, and `markdown-link-check` found
no configuration or invocation (the `remark` hits are all the English word "remark" in prose, not the tool).
No `docs`-specific lint/check script was found under `scripts/`.

### Local reproduction

Each of the three checks is a plain file-existence/non-emptiness test with no external state:

- Bash/WSL: `test -f README.md && test -s README.md`; `test -f LICENSE`; `test -f .github/copilot-instructions.md`; `test -f docs/code-change.instructions.md`.
- PowerShell (Windows or `pwsh` on Linux): `Test-Path README.md`, `(Get-Item README.md).Length -gt 0`, `Test-Path LICENSE`, `Test-Path .github/copilot-instructions.md`, `Test-Path docs/code-change.instructions.md`.

All five checks are runnable on Windows and Linux, depend on no `origin/main` ref (the CI checkout in this
workflow is a plain `actions/checkout@v7` with no depth or ref argument beyond default, and none of the three
steps invokes `git diff` against any remote ref), touch no gitignored state, and use only repository-relative
paths (no Windows drive-letter path appears in the workflow). No prior recorded run's stdout for this exact
workflow was found in this session's search scope, so the printed success-case output could not be verified
beyond the literal `Write-Output`/`echo`-equivalent statements read directly from the workflow source above (a
successful run of steps 1–2 prints nothing on the success path — bash `if` blocks here have no positive-branch
output — and step 3 prints nothing when both instruction files are present).

Because this validation only checks the *existence* of README.md, LICENSE, and two instruction files, it
cannot and does not detect the README's stale `NPM_TOKEN`/`--provenance` text described in item 1, or a stale
runbook claim. The issue's own proposed verification — `grep -rn 'NPM_TOKEN' README.md .github/workflows/` —
is therefore the correct and only available local reproduction for the specific defect this issue addresses;
no existing repository tool performs this content check automatically.

## Numeric Derivation Evidence

Not applicable. No numeric count, enumeration, or population claim is proposed in this research or in the
Acceptance Criteria below (the criteria are presence/absence checks of specific literal tokens at specific file
locations, not counts).

## Automation Feasibility

| Step | Requires human interaction? | Recommended response |
|---|---|---|
| README.md:401-402 credential/`--provenance` correction | No — pure text edit, fully automatable | (in scope; not a gate) |
| `docs/engineering/npm-token-rotation.runbook.md` superseded notice | No — pure text edit, fully automatable | (in scope; not a gate) |
| Decide runbook-vs-ruleset (item 3) | Yes, if Option B (changing `protect-main`'s `required_approving_review_count`) is chosen — that is a GitHub repository-settings API/UI write outside file-edit scope. Option A (editing the runbook) requires no human interaction. | Recommend Option A (edit the runbook), which needs no human step. If the repository owner later decides Option B is correct instead, that decision is a **human_exception** (a settings change no in-repo automation can perform) and should be recorded as a follow-up, not blended into this fix. |
| Remove unused `NPM_TOKEN` secret | Yes — `gh secret delete` or Settings UI is a credential-management action outside this fix's file-edit scope, and the delegation prompt frames it as a separate decision. | **scope_change** — defer to a separate, explicitly-scoped follow-up (or a `human_exception` runbook) rather than bundling into this minor-audit documentation fix. |

No step in this issue's actual documentation fix (README + runbook text corrections) requires human
interaction; both open items (the ruleset question and the secret deletion) are separable and are recommended
as out-of-scope follow-ups rather than blockers.

## Proposed Acceptance Criteria

```markdown
## Acceptance Criteria

- [ ] AC1. `README.md`'s npm publish procedure line no longer contains the literal `NPM_TOKEN`; `grep -c 'NPM_TOKEN' README.md` returns `0`.
- [ ] AC2. `README.md`'s publish-steps line states the credential mechanism as OIDC trusted publishing (contains the literal `id-token: write` or `trusted publishing`) rather than a repository secret.
- [ ] AC3. `README.md`'s publish-steps line contains the literal `--provenance` immediately preceding `--access public` in the documented `npm publish` command.
- [ ] AC4. `grep -rn 'NPM_TOKEN' README.md .github/workflows/` reports only the (corrected or absent) README occurrence and no workflow file, confirming no workflow contradicts the README's stated mechanism.
- [ ] AC5. `docs/engineering/npm-token-rotation.runbook.md` begins with a notice (within its first 5 lines) containing the literal `superseded` or `no longer` that states the workflow uses trusted publishing and does not read `NPM_TOKEN`.
- [ ] AC6. `docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md` no longer states an approving-review requirement as a blocking gate; it does not contain the literal `cannot be automated` in reference to merge approval.
- [ ] AC7. No file under `docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/` is modified by this change (historical-record folder left untouched; verify via `git diff --name-only` against that path prefix showing no output).
- [ ] AC8. `.github/workflows/_docs-validation.yml`'s three existing checks still pass unchanged (README.md present and non-empty, LICENSE present) after the edits — no new failure mode introduced by the documentation change.
```

## Summary of recommendations (items 2-4)

- **Item 2** (`docs/engineering/npm-token-rotation.runbook.md`): add a superseded/stale notice at the top
  pointing to OIDC trusted publishing; do not rewrite the body and do not touch the identical historical copy
  under `docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/runbooks/`.
- **Item 3** (branch-protection runbook claim): edit
  `docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md`
  to match the live `required_approving_review_count: 0` ruleset state (Option A), on the grounds that this is
  a single-operator, autonomous-execution-oriented repository where a mandatory non-author-approval gate is
  both structurally awkward and, per the live ruleset, not actually configured; changing the ruleset instead
  (Option B) is a repository-settings action outside this fix's scope and should be raised separately if the
  owner determines 0 approvals was unintended.
- **Item 4** (unused `NPM_TOKEN` secret): confirmed unreferenced anywhere in `.github/`, `scripts/`,
  `packages/`, or `extensions/`; recommend leaving its removal **out of scope** for this documentation fix and
  tracking it as a separate housekeeping follow-up, since deleting a secret is a credential-management action,
  not a file edit, and is not required to resolve the documentation inaccuracy.
