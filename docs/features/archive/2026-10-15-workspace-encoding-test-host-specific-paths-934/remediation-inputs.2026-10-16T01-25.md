# Remediation Inputs — Issue #934 — 2026-10-16T01-25

Review-Verdict: REMEDIATION_REQUIRED

- Feature folder: `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934`
- Base: `origin/main` at `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- Head: `bug/workspace-encoding-test-host-specific-paths-934` at `9fcf0909eb24a6c3a0cdb419149e2288baa7cc9f`
- Work mode: `minor-audit` (AC source: `issue.md` `## Acceptance Criteria`)
- Authored by: `feature-review`
- blocking_count: 1

## Source Artifacts

- `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/policy-audit.2026-10-16T01-25.md` (section 8, B1)
- `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/code-review.2026-10-16T01-25.md` (Findings Table, row 1)
- `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/feature-audit.2026-10-16T01-25.md` (Findings outside the AC set)

## Remediation-Required Findings

### B1 — Research artifact quotes the removed absolute host paths

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: the change is a text redaction inside one Markdown file in the feature folder; it needs no external system, no CI result, no policy change, and no user decision.
- File: `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/research/2026-10-15T17-50-workspace-encoding-host-paths-research.md`
- Location: line 55 (session-resolver note) and lines 107–111 (derivation table "Old" column).
- Current state: the lines contain the drive-letter absolute workspace paths with the host user segment (backslash and forward-slash forms), the corresponding encoded directory names (uppercase and lowercase), and the session-resolver absolute path with the truncated user name.
- Rule: `issue.md` §Suspected Cause — "never encode absolute host paths in artifacts".
- Expected end state: each quoted literal is replaced with a placeholder form, for example `<drive>:\\Users\\<host-user>\\repos\\drm-copilot`, `<drive>:/Users/<host-user>/repos/drm-copilot`, `<drive>--Users-<host-user>-repos-drm-copilot`, `<drive-lowercase>--users-<host-user>-repos-drm-copilot`, and `<drive>--Users-<host-user>-repos-some-other-repo`. Line-number references and the "New" column remain unchanged. The surrounding prose that names the bare search token without a path may remain.
- Verification (from the worktree root):
  - `grep -rnE '[A-Za-z]:[\\/]{1,2}Users[\\/]{1,2}[A-Za-z]' docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934` returns no output, excluding this remediation-inputs file and the three review artifacts, which quote only the regex.
  - `grep -rnE '[A-Za-z]--Users-[A-Za-z]' docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/research` returns only placeholder forms beginning with `<drive>`.
- Scope limits: do not edit the two test files, any production file, or the AC check-offs in `issue.md`.

## Non-Remediation Items (recorded, optional)

- N1: `encodedNameOf` `drive` parameter always receives `UPPER_DRIVE` (`workspace-encoding.test.ts` lines 21–23).
- N2: Parallel fixture constants in the two test files.
- N3: Coverage evidence is a Jest text log under untracked `SCRATCH/issue-934/`; numbers verified by the reviewer.
- N4: `test/` versus `tests/` directory name is a pre-existing extension convention.
- N5: `issue.md` line 5 Status names a folder path different from the actual feature folder; can be corrected in the same remediation commit.
