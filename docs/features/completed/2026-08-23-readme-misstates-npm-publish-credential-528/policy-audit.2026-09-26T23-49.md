# Policy Audit — Issue #528 (readme-misstates-npm-publish-credential)

- Timestamp: 2026-09-26T23-49
- Branch: `bug/readme-misstates-npm-publish-credential-528`
- HEAD reviewed: `d198c9c8`
- Merge base: `origin/main` at `ae8d2ce3`
- Work Mode: `minor-audit` (per `issue.md` header). AC source is `issue.md`'s `## Acceptance Criteria` section only, per the minor-audit routing rule.
- Scope: documentation-only bug fix. Full branch diff against `origin/main` was reviewed; no plan/task-level narrowing was applied.

## Policy Reading Order

Read in the order specified by `CLAUDE.md` and the `policy-compliance-order` skill:

1. `CLAUDE.md` — tone policy, policy compliance order, architecture.
2. `.claude/rules/general-code-change.md` — cross-language code change policy.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy.
4. `.claude/rules/quality-tiers.md` — tier/coverage gate matrix.
5. `.claude/rules/tonality.md` — tone policy detail.
6. Language-specific rules: none apply. All four files touched by this branch (`README.md`, `docs/engineering/npm-token-rotation.runbook.md`, `docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md`, `docs/features/active/.../issue.md`) are Markdown. No Python, PowerShell, TypeScript, or C# file appears in the diff.

## Rejected Scope Narrowing

None. The task prompt for this review did not attempt to narrow scope to a plan/task subset, did not mark any language "out of scope," and did not instruct skipping a toolchain or coverage check for a language with changed files. The full branch-vs-`origin/main` diff was used as the audit scope, confirmed via `git diff origin/main...HEAD --name-only` (30 changed files, all under `README.md`, `docs/engineering/`, `docs/features/completed/separate-version-bump-from-publish-214/`, and `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/`).

## Production/Test Code Scope Check

**PASS.** `git diff origin/main...HEAD --name-only -- "*.py" "*.ts" "*.tsx" "*.ps1" "*.psm1" "*.cs" "*.js" "*.json" "*.yml" "*.yaml"` returned zero files. No production code, test code, configuration, or GitHub Actions workflow file was created or modified by this branch. The only substantive edits are three Markdown files:

- `README.md` (lines 401-402, 2 lines changed)
- `docs/engineering/npm-token-rotation.runbook.md` (2 lines added at top)
- `docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md` (1 line replaced)

The remaining changed files are the feature-folder documentation set (`issue.md`, `plan.2026-09-25T22-06.md`, `research/research.2026-09-25T22-15.md`) and evidence artifacts under `evidence/baseline/` and `evidence/qa-gates/`, all consistent with the minor-audit documentation workflow.

## Mandatory Toolchain Loop

**N/A — justified.** The seven-stage toolchain (format, lint, type-check, architecture-boundary, unit test, contract/schema, integration) applies to code changes. This branch contains no code in any covered language (Python, PowerShell, TypeScript, C#) and no GitHub Actions workflow change. The repository's own `docs-validation` CI job only checks that `README.md` and `LICENSE` exist and that `README.md` is non-empty (AC8), which this audit independently re-verified (see feature-audit). No formatter, linter, or type-checker applies to prose Markdown edits in this repository.

## File Size Limit

**PASS (exempt).** Markdown documentation files are an explicit exception to the 500-line production/test/script file limit in `.claude/rules/general-code-change.md`. For completeness, line counts were checked directly: `README.md` = 415 lines, `docs/engineering/npm-token-rotation.runbook.md` = 40 lines, `release-pr-merge-approval.runbook.md` = 35 lines. All are well under the limit regardless of exemption.

## Coverage Verification

**N/A for all four coverage languages — not applicable, not a skipped gate.**

| Language | Changed files in branch diff | Coverage artifact required? | Verdict |
|---|---|---|---|
| TypeScript | 0 | No (zero changed files) | N/A |
| Python | 0 | No (zero changed files) | N/A |
| PowerShell | 0 | No (zero changed files) | N/A |
| C# | 0 | No (zero changed files) | N/A |

Per the Coverage Verification procedure, `N/A` is an acceptable verdict only for a language with zero changed files on the branch, which is the case for all four here (confirmed above via the extension-filtered `git diff --name-only`). No `coverage/lcov.info`, `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, or `artifacts/csharp/coverage.xml` artifact was inspected, because none is mandated when no file of that language changed. This is not a caller-instructed skip; it is derived directly from the branch diff contents.

## Coverage Exclusion Policy (`exclude` entries)

**N/A.** No toolchain configuration file (`jest.config`, `pytest.ini`/`pyproject.toml` coverage section, `.dependency-cruiser.cjs`, etc.) is touched by this branch, so no new or modified `exclude` entry exists to evaluate.

## Evidence Location Compliance

**PASS.** All evidence produced by the plan's execution is under the canonical path `docs/features/active/2026-08-23-readme-misstates-npm-publish-credential-528/evidence/{baseline,qa-gates}/`, consistent with the evidence-and-timestamp-conventions skill. Ran the repository's own validator:

```
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

Exit code: 0, no output (no violations reported). A manual scan of the branch diff for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` paths found none. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition applies; no delegation prompt in this review specified a non-canonical evidence path.

## Tonality / Professional Tone Compliance

**PASS.** The three edited prose passages were reviewed against `.claude/rules/tonality.md`:

- `README.md` credential line: "Credential: publication uses npm trusted publishing over OIDC (workflow permission `id-token: write`); no npm token secret is used." — factual, neutral, no hyperbole or metaphor.
- `npm-token-rotation.runbook.md` superseded notice: "This runbook is superseded; ... does not read the `NPM_TOKEN` secret. Rotating `NPM_TOKEN` will not resolve an `npm publish` failure. Retained for historical reference only." — direct, evidence-matched, no dramatization of the defect it documents.
- `release-pr-merge-approval.runbook.md` cue line: states the live ruleset's `required_approving_review_count: 0` plainly, without editorializing about the prior (now-corrected) claim.

No jokes, sarcasm, hyperbolic claims, or decorative metaphor were found in any of the three edits.

## AC5 Untouched-File Verification

**PASS.** `docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/runbooks/npm-token-rotation.runbook.md` (the historical copy) must remain untouched. Verified two ways:

1. `git diff origin/main...HEAD --stat -- "docs/features/completed/2026-07-03-npm-publish-404-and-vsce-bundling-warning-283/"` produced no output (zero diff against the merge base for that entire subtree).
2. `git log -1 --format="%H %ad" --date=iso -- <path>` reports the last commit touching that file as `e2dbb76a 2026-07-03 22:20:21 -0400`, which predates this session's work (started 2026-09-25) and predates 2026-09-26.

## Overall Policy Verdict

**PASS.** No Blocking or Warning findings. The change is confined to the declared documentation scope, evidence is in the canonical location, tone is compliant, and the toolchain/coverage gates are correctly not applicable given zero changed code files.
