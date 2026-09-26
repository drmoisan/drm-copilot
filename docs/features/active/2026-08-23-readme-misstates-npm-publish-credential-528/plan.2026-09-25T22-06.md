# readme-misstates-npm-publish-credential (Plan) — Issue #528

- **Issue:** #528
- **Branch:** bug/readme-misstates-npm-publish-credential-528
- **Owner:** drmoisan
- **Last Updated:** 2026-09-25T22-06
- **Status:** Draft
- **Work Mode:** minor-audit
- **Requirements source:** `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/issue.md`, section `## Acceptance Criteria` (AC1-AC8), read together with `## Scope Decisions` (D1-D4). This is the sole AC source. `spec.md` and `user-story.md` are intentionally absent for this minor-audit; their absence is not a blocker. `research/research.2026-09-25T22-15.md` is supporting context only and is not an AC source.

## Scope

Documentation-only change. No production code or test code, in any language, is created or modified.

- `README.md` (lines 401-402, "npm publish release procedure")
- `docs/engineering/npm-token-rotation.runbook.md` (superseded notice at top only)
- `docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md` (line 7 approval claim)
- `docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/runbooks/npm-token-rotation.runbook.md` (the historical copy) is explicitly **not** modified — see AC5.

No language toolchain applies to this change (Markdown only). The repository has no markdownlint or link-checker, and the `docs-validation` CI job (`.github/workflows/_docs-validation.yml`) only checks that `README.md` and `LICENSE` exist and that `README.md` is non-empty (AC8). No formatter, linter, type-checker, or coverage task is included for Python/TypeScript/PowerShell/C#, because none of those languages is in scope. No PoshQC MCP tool is used in this plan.

## Command-Translation Note (applies to every verification task below)

The executor's Bash allowlist is limited to `git`, `pwsh`, `poetry run black`/`ruff`/`pyright`/`pytest`, `npx prettier`/`eslint`/`tsc`/`jest`, plus the Read/Grep tools. There is no bare `grep`, `head`, or `test`. Every check command in `issue.md`'s Acceptance Criteria section is translated below to an equivalent allowlisted command:

- `grep -n -- "--provenance" README.md` → `git grep -n -e "--provenance" -- README.md` (hyphen-leading pattern uses `-e`).
- `grep -n "id-token: write" README.md` → `git grep -n -e "id-token: write" -- README.md`.
- `grep -c NPM_TOKEN README.md` → `git grep -c NPM_TOKEN -- README.md`.
- `head -n 5 docs/engineering/npm-token-rotation.runbook.md | grep -c superseded` → `git grep -n superseded -- docs/engineering/npm-token-rotation.runbook.md`, with the reported line number required to be `<= 5` (equivalent to confirming the match falls within the first 5 lines, without piping through `head`).
- `grep -c superseded docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/runbooks/npm-token-rotation.runbook.md` → `git grep -c superseded -- docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/runbooks/npm-token-rotation.runbook.md`.
- `grep -c "cannot be automated" docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md` → `git grep -c -e "cannot be automated" -- docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md`.
- `grep -c "pull request" docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md` → `git grep -c -e "pull request" -- docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md`.
- `test -f README.md && test -s README.md && test -f LICENSE` → `git ls-files --error-unmatch -- README.md`, `git grep -c -e "" -- README.md` (non-empty: at least one line matches the empty pattern), and `git ls-files --error-unmatch -- LICENSE`.

`git grep` (no `-c`) exits `0` when it finds at least one match and `1` when it finds none. `git grep -c` exits `0` and prints a `path:count` line when the count is `>= 1`, and exits `1` printing nothing when the count is `0`. AC3, AC5, and AC6 are zero-occurrence assertions, so their verification tasks below declare `ExpectedExitCode: 1` and assert empty output. `issue.md` itself is not altered by this translation; the translation is recorded here only.

`git grep` reads the current working-tree content of tracked files (not the index or a commit), so it observes an edit made by an earlier task in this same plan even before that edit is committed, provided the file is already tracked. Phase 0 confirms all three target files are tracked before any edit is made, so this holds for every verification task in Phase 2.

No task in this plan uses `git diff`, depends on `origin/main` or any remote ref, calls `gh api` or any networked command, or reads gitignored state or a Windows drive-root path.

---

### Phase 0 — Baseline Capture

- [ ] [P0-T1] Read `CLAUDE.md` in full. Acceptance: the file's Policy Compliance Reading Order and Architecture sections have been read.
- [ ] [P0-T2] Read `.claude/rules/general-code-change.md` in full. Acceptance: the file has been read.
- [ ] [P0-T3] Read `.claude/rules/general-unit-test.md` in full. Acceptance: the file has been read.
- [ ] [P0-T4] Determine and record that no language-specific rule file applies to this change. Acceptance: a one-line determination is recorded stating that the three target files (`README.md`, `docs/engineering/npm-token-rotation.runbook.md`, `docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md`) are all Markdown, so none of `.claude/rules/python.md`, `.claude/rules/powershell.md`, `.claude/rules/typescript.md`, or `.claude/rules/csharp.md` applies.
- [ ] [P0-T5] Write the Phase 0 policy-read evidence artifact at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/phase0-instructions-read.md`. Acceptance: the file exists and contains at minimum `Timestamp:`, `Policy Order:` (listing, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, and the P0-T4 determination that no language-specific rule applies), and an explicit list of the files read in P0-T1 through P0-T4.

- [ ] [P0-T6] Confirm `README.md` is tracked. Command: `git ls-files --error-unmatch -- README.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t6-readme-tracked.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the printed path).
- [ ] [P0-T7] Confirm `docs/engineering/npm-token-rotation.runbook.md` is tracked. Command: `git ls-files --error-unmatch -- docs/engineering/npm-token-rotation.runbook.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t7-rotation-runbook-tracked.md` with the four required fields plus `Output Summary:`.
- [ ] [P0-T8] Confirm `docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md` is tracked. Command: `git ls-files --error-unmatch -- docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t8-approval-runbook-tracked.md` with the four required fields plus `Output Summary:`.
- [ ] [P0-T9] Confirm `LICENSE` is tracked. Command: `git ls-files --error-unmatch -- LICENSE`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t9-license-tracked.md` with the four required fields plus `Output Summary:`.

- [ ] [P0-T10] Capture the pre-change AC1 discriminator. Command: `git grep -n -e "--provenance" -- README.md`. ExpectedExitCode: 1 (the literal `--provenance` is not yet present in `README.md`). Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t10-ac1-provenance-baseline.md` recording `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and `Output Summary: no match (confirms the Phase 2 AC1 check can fail before the fix)`.
- [ ] [P0-T11] Capture the pre-change AC2 discriminator. Command: `git grep -n -e "id-token: write" -- README.md`. ExpectedExitCode: 1 (the literal `id-token: write` is not yet present in `README.md`). Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t11-ac2-idtoken-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, `Output Summary: no match`.
- [ ] [P0-T12] Capture the pre-change AC3 discriminator. Command: `git grep -c NPM_TOKEN -- README.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t12-ac3-npmtoken-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary: README.md:1 (one pre-fix occurrence, confirms the Phase 2 zero-occurrence check can fail before the fix)`.
- [ ] [P0-T13] Capture the pre-change AC4 discriminator. Command: `git grep -n superseded -- docs/engineering/npm-token-rotation.runbook.md`. ExpectedExitCode: 1 (the literal `superseded` is not yet present). Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t13-ac4-superseded-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, `Output Summary: no match`.
- [ ] [P0-T14] Capture the pre-change AC5 discriminator (this file is never edited by this plan; the baseline is also the expected end state). Command: `git grep -c superseded -- docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/runbooks/npm-token-rotation.runbook.md`. ExpectedExitCode: 1. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t14-ac5-historical-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, `Output Summary: no match`.
- [ ] [P0-T15] Capture the pre-change AC6 discriminator. Command: `git grep -c -e "cannot be automated" -- docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t15-ac6-cannotbeautomated-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary: <path>:1 (one pre-fix occurrence, confirms the Phase 2 zero-occurrence check can fail before the fix)`.
- [ ] [P0-T16] Capture the pre-change AC7 discriminator (control: must remain true throughout). Command: `git grep -c -e "pull request" -- docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t16-ac7-pullrequest-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary: <path>:6 (six pre-fix occurrences)`.
- [ ] [P0-T17] Capture the pre-change AC8 non-empty check for `README.md`. Command: `git grep -c -e "" -- README.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t17-ac8-readme-nonempty-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary: positive line count confirms README.md is non-empty`.
- [ ] [P0-T18] Capture the pre-change AC8 non-empty check for `LICENSE`. Command: `git grep -c -e "" -- LICENSE`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/baseline/p0-t18-ac8-license-nonempty-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary: positive line count confirms LICENSE is non-empty`.

---

### Phase 1 — Constrained Implementation

- [ ] [P1-T1] Edit `README.md`. Replace the two-line block:

```
- Publish steps: install `packages/mcp-server` dependencies, run `prepack`, build `out/mcp-server.js`, then `npm publish --access public`.
- Credential: publication requires the repository secret `NPM_TOKEN`.
```

with exactly:

```
- Publish steps: install `packages/mcp-server` dependencies, run `prepack`, build `out/mcp-server.js`, then `npm publish --provenance --access public`.
- Credential: publication uses npm trusted publishing over OIDC (workflow permission `id-token: write`); no npm token secret is used.
```

Acceptance: the two lines in `README.md`'s "npm publish release procedure" section read exactly as the replacement text above (no other line in the section is changed).

- [ ] [P1-T2] Edit `docs/engineering/npm-token-rotation.runbook.md`. Replace the three-line block at the top of the file:

```
# Human-Exception Runbook — Rotate the `NPM_TOKEN` GitHub Actions Secret for `@danmoisan/drm-copilot-mcp`

Contract-conformant per `.claude/skills/human-exception-runbook/SKILL.md`.
```

with exactly:

```
# Human-Exception Runbook — Rotate the `NPM_TOKEN` GitHub Actions Secret for `@danmoisan/drm-copilot-mcp`

> **Note:** This runbook is superseded; `.github/workflows/publish-mcp-npm.yml` now publishes via npm trusted publishing over OIDC (`id-token: write`) and does not read the `NPM_TOKEN` secret. Rotating `NPM_TOKEN` will not resolve an `npm publish` failure. Retained for historical reference only.

Contract-conformant per `.claude/skills/human-exception-runbook/SKILL.md`.
```

Acceptance: the literal token `superseded` appears in the file, on line 3, which is within the first 5 lines. No other line in the file is changed (the `## Cue` section and everything below it shift down by two lines but are otherwise byte-identical).

- [ ] [P1-T3] Edit `docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md`. Replace the single line (currently line 7):

```
Act when the orchestrator has recorded an `exception` for the `branch-protection-merge-approval` requirement — that is, when the release version-bump task has opened a pull request against `main` that patch-bumps `extensions/drm-copilot/package.json` and `packages/mcp-server/package.json`, and that PR is waiting for review. Branch protection on `main` requires an approving review from a write-access reviewer who is not the PR author, so this step cannot be automated and is a permitted human gate.
```

with exactly:

```
Act when the release version-bump task has opened a pull request against `main` that patch-bumps `extensions/drm-copilot/package.json` and `packages/mcp-server/package.json`. The `protect-main` ruleset requires a pull request and passing status checks but sets `required_approving_review_count: 0`, so merging this pull request requires no approving review.
```

Acceptance: the file no longer contains the literal token `cannot be automated`; the file still contains the literal token `pull request` at least once; no other line in the file is changed.

---

### Phase 2 — Final QC / Verification

Each task below runs exactly one verification command against the post-edit tree, records one evidence artifact under `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/qa-gates/`, and is immediately followed by a task instructing the executor to check off the corresponding item in `issue.md`'s `## Acceptance Criteria` section once the verification evidence confirms a pass. No task in this phase may report `EXIT_CODE: SKIPPED`; every command listed below is executed and its result recorded.

- [ ] [P2-T1] Verify AC1. Command: `git grep -n -e "--provenance" -- README.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/qa-gates/p2-t1-ac1-provenance.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the matched line and its line number).
- [ ] [P2-T2] In `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/issue.md`, check off `AC1` in the `## Acceptance Criteria` section (`- [ ] AC1.` → `- [x] AC1.`), citing the P2-T1 evidence file.
- [ ] [P2-T3] Verify AC2. Command: `git grep -n -e "id-token: write" -- README.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/qa-gates/p2-t3-ac2-idtoken.md` with the four required fields plus `Output Summary:`.
- [ ] [P2-T4] In `issue.md`, check off `AC2`, citing the P2-T3 evidence file.
- [ ] [P2-T5] Verify AC3. Command: `git grep -c NPM_TOKEN -- README.md`. ExpectedExitCode: 1. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/qa-gates/p2-t5-ac3-npmtoken.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, `Output Summary: no match (zero occurrences, versus one occurrence recorded in P0-T12)`.
- [ ] [P2-T6] In `issue.md`, check off `AC3`, citing the P2-T5 evidence file.
- [ ] [P2-T7] Verify AC4. Command: `git grep -n superseded -- docs/engineering/npm-token-rotation.runbook.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/qa-gates/p2-t7-ac4-superseded.md` with the four required fields plus `Output Summary:` recording the reported line number and confirming it is `<= 5`.
- [ ] [P2-T8] In `issue.md`, check off `AC4`, citing the P2-T7 evidence file and the recorded line number.
- [ ] [P2-T9] Verify AC5. Command: `git grep -c superseded -- docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/runbooks/npm-token-rotation.runbook.md`. ExpectedExitCode: 1. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/qa-gates/p2-t9-ac5-historical-untouched.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, `Output Summary: no match (unchanged from P0-T14 baseline, confirming the historical copy was not modified)`.
- [ ] [P2-T10] In `issue.md`, check off `AC5`, citing the P2-T9 evidence file.
- [ ] [P2-T11] Verify AC6. Command: `git grep -c -e "cannot be automated" -- docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md`. ExpectedExitCode: 1. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/qa-gates/p2-t11-ac6-cannotbeautomated.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, `Output Summary: no match (zero occurrences, versus one occurrence recorded in P0-T15)`.
- [ ] [P2-T12] In `issue.md`, check off `AC6`, citing the P2-T11 evidence file.
- [ ] [P2-T13] Verify AC7. Command: `git grep -c -e "pull request" -- docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/qa-gates/p2-t13-ac7-pullrequest.md` with the four required fields plus `Output Summary:` recording the observed count (at least 1; the P1-T3 wording change is expected to raise the file's total from the 6 recorded in P0-T16, since the replacement line itself contains the token twice).
- [ ] [P2-T14] In `issue.md`, check off `AC7`, citing the P2-T13 evidence file.
- [ ] [P2-T15] Verify AC8, part 1 (README tracked and present). Command: `git ls-files --error-unmatch -- README.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/qa-gates/p2-t15-ac8-readme-present.md` with the four required fields plus `Output Summary:`.
- [ ] [P2-T16] Verify AC8, part 2 (README non-empty). Command: `git grep -c -e "" -- README.md`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/qa-gates/p2-t16-ac8-readme-nonempty.md` with the four required fields plus `Output Summary:` (positive line count).
- [ ] [P2-T17] Verify AC8, part 3 (LICENSE present). Command: `git ls-files --error-unmatch -- LICENSE`. ExpectedExitCode: 0. Write evidence at `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/qa-gates/p2-t17-ac8-license-present.md` with the four required fields plus `Output Summary:`.
- [ ] [P2-T18] In `issue.md`, check off `AC8`, citing the P2-T15, P2-T16, and P2-T17 evidence files (all three must show a pass; AC8 remains satisfied because none of this plan's edits touch `README.md`'s existence/non-emptiness or `LICENSE`).
- [ ] [P2-T19] Commit the three documentation edits and the `issue.md` checklist updates in a single commit using the pathspec form: `git commit -m "docs: correct npm publish credential and release approval claims (#528)" -- README.md docs/engineering/npm-token-rotation.runbook.md docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/issue.md`. Acceptance: `git log -1 --pretty=%s` reports the commit subject `docs: correct npm publish credential and release approval claims (#528)`, and `git ls-files --error-unmatch -- README.md docs/engineering/npm-token-rotation.runbook.md docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/issue.md` exits `0` for all four paths post-commit.
