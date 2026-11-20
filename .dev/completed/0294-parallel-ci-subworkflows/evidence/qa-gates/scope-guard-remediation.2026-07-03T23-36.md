# Scope-Guard — Remediation Cycle (Issue #294)

Timestamp: 2026-07-03T23-36

Command: `git diff --stat 9a36e9b3dd9da626a33a45b2318165f5e49c69ec..HEAD` (merge-base with `main`)

EXIT_CODE: 0

Raw Output:

```
 .github/workflows/README.md                        |  84 +++++
 .github/workflows/_build-check.yml                 |  35 ++
 .github/workflows/_docs-validation.yml             |  37 ++
 .github/workflows/_drm-copilot-extension-tests.yml |  30 ++
 .github/workflows/_poshqc.yml                      |  52 +++
 .github/workflows/_quality-checks.yml              |  81 ++++
 .github/workflows/_security-scan.yml               |  30 ++
 .github/workflows/_shell-coverage.yml              |  85 +++++
 .github/workflows/ci.yml                           | 308 +---------------
 .../code-review.2026-07-03T23-36.md                | 168 +++++++++
 .../baseline-actionlint-ci-yml.2026-07-03T18-07.md |   9 +
 .../baseline-git-status.2026-07-03T18-07.md        |  23 ++
 ...line-required-status-checks.2026-07-03T18-07.md |  39 ++
 .../evidence/baseline/phase0-instructions-read.md  |  19 +
 .../branch-protection-update.2026-07-03T18-07.md   |  46 +++
 ...required-status-check-names.2026-07-03T18-07.md |  61 +++
 .../other/scope-guard-git-diff.2026-07-03T18-07.md |  42 +++
 ...-dispatch-substitution-note.2026-07-03T18-07.md |  59 +++
 .../final-qa-loop-actionlint.2026-07-03T18-07.md   |  21 ++
 ...loop-language-applicability.2026-07-03T18-07.md |  23 ++
 .../green-run-branch-head.2026-07-03T18-07.md      |  72 ++++
 .../yaml-validation-phase2.2026-07-03T18-07.md     |  17 +
 .../baseline-git-status.2026-07-03T23-36.md        |  42 +++
 .../phase0-instructions-read.2026-07-03T23-36.md   |  22 ++
 .../feature-audit.2026-07-03T23-36.md              | 196 ++++++++++
 .../issue.md                                       |  79 ++++
 .../plan.2026-07-03T18-07.md                       | 204 ++++++++++
 .../policy-audit.2026-07-03T23-36.md               | 410 +++++++++++++++++++++
 .../remediation-inputs.2026-07-03T23-36.md         | 101 +++++
 .../remediation-plan.2026-07-03T23-36.md           | 184 +++++++++
 ...7-03T19-00-parallel-ci-subworkflows-research.md | 335 +++++++++++++++++
 .../spec.md                                        | 241 ++++++++++++
 .../user-story.md                                  | 127 +++++++
 33 files changed, 2981 insertions(+), 301 deletions(-)
```

## Second Command (Remediation-Cycle-Only Scope, Narrower Range)

Command: `git diff --stat 5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3..HEAD` (the branch head at which
`feature-audit.2026-07-03T23-36.md` was produced, through the current branch head)

EXIT_CODE: 0

Raw Output:

```
 .../code-review.2026-07-03T23-36.md                | 168 +++++++++
 ...required-status-check-names.2026-07-03T18-07.md |  21 +-
 .../green-run-branch-head.2026-07-03T18-07.md      |  26 +-
 .../baseline-git-status.2026-07-03T23-36.md        |  42 +++
 .../phase0-instructions-read.2026-07-03T23-36.md   |  22 ++
 .../feature-audit.2026-07-03T23-36.md              | 196 ++++++++++
 .../policy-audit.2026-07-03T23-36.md               | 410 +++++++++++++++++++++
 .../remediation-inputs.2026-07-03T23-36.md         | 101 +++++
 .../remediation-plan.2026-07-03T23-36.md           | 184 +++++++++
 .../spec.md                                        |  51 ++-
 .../user-story.md                                  |   9 +-
 11 files changed, 1198 insertions(+), 32 deletions(-)
```

## Path-Filtered Confirmations

- `git diff --stat 5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3..HEAD -- .github/workflows/` → **empty
  output** (0 files). Confirms zero `.github/workflows/**` YAML content changed during this
  remediation cycle.
- `git diff --stat 9a36e9b3dd9da626a33a45b2318165f5e49c69ec..HEAD -- src/ extensions/drm-copilot/src/`
  → **empty output** (0 files). Confirms zero `src/` or `extensions/drm-copilot/src` files were
  touched anywhere on this branch (original feature or remediation).
- `git diff --stat 9a36e9b3dd9da626a33a45b2318165f5e49c69ec..HEAD -- .github/workflows/publish-extension.yml .github/workflows/publish-mcp-npm.yml`
  → **empty output** (0 files). Confirms both publish workflow files are absent from the diff.

## Output Summary

- **Whole-branch diff (merge-base `9a36e9b3d...`..HEAD):** contains the original feature's 8
  `.github/workflows/**` files (created/rewritten by the original feature work, `plan.2026-07-03T18-07.md`,
  not by this remediation cycle) plus this feature's own documentation/evidence folder. No `src/`,
  no `extensions/drm-copilot/src`, no publish-workflow file appears.
- **Remediation-cycle-only diff (`5cd712c9d1...`..HEAD, spanning commits `cb43997` and `5a428db`):**
  changes only 11 files, all under this feature's documentation/evidence folder
  (`code-review.*.md`, `feature-audit.*.md`, `policy-audit.*.md`, `remediation-inputs.*.md`,
  `remediation-plan.*.md`, two `evidence/remediation-baseline/*.md` files, the two refreshed
  `evidence/qa-gates/green-run-branch-head.*.md` and `evidence/other/required-status-check-names.*.md`
  files, and `spec.md`/`user-story.md` reviewer-correction checkbox edits). **Zero
  `.github/workflows/**` YAML files appear in this range.**
- No `git commit`/`git push` in any task executed during this remediation cycle touched a file under
  `src/` or `extensions/drm-copilot/src`, and neither `.github/workflows/publish-extension.yml` nor
  `.github/workflows/publish-mcp-npm.yml` appears in either diff range.
- **Branch-protection statement:** no `gh api repos/{owner}/{repo}/branches/main/protection` PATCH
  command appears in any task of `remediation-plan.2026-07-03T23-36.md` (Phases 1–3 use only
  `gh workflow run`, `gh run list`, `gh run view`, and read-only `gh api .../check-runs` GET calls).
  No branch-protection change on `main` was made as part of this remediation cycle.

**Conclusion:** Scope guard confirmed. This remediation cycle made no `.github/workflows/**` YAML
content change, no `src/`/`extensions/drm-copilot/src` change, did not touch either publish workflow
file, and did not modify branch protection on `main`.
