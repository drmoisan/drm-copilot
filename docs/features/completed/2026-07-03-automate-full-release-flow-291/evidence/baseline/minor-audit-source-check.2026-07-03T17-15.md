Timestamp: 2026-07-03T17-24
Issue: #291
Command: $issue = 'docs/features/active/2026-07-03-automate-full-release-flow-291/issue.md'; $spec = 'docs/features/active/2026-07-03-automate-full-release-flow-291/spec.md'; $story = 'docs/features/active/2026-07-03-automate-full-release-flow-291/user-story.md'; $content = Get-Content -Raw $issue; $ok = $content.Contains('- Work Mode: minor-audit') -and ($content -match '(?m)^## Acceptance Criteria$') -and -not (Test-Path $spec) -and -not (Test-Path $story); if ($ok) { 'PASS: issue #291 minor-audit source is valid; spec.md absent; user-story.md absent.'; exit 0 } else { 'FAIL: issue #291 minor-audit source validation failed.'; exit 1 }
EXIT_CODE: 0
Output Summary:
- PASS: issue #291 minor-audit source is valid.
- `docs/features/active/2026-07-03-automate-full-release-flow-291/issue.md` contains `- Work Mode: minor-audit`.
- `docs/features/active/2026-07-03-automate-full-release-flow-291/issue.md` contains the exact heading line `## Acceptance Criteria`.
- `docs/features/active/2026-07-03-automate-full-release-flow-291/spec.md` is absent.
- `docs/features/active/2026-07-03-automate-full-release-flow-291/user-story.md` is absent.
