# Regression: #527 CHANGELOG entry ([P7-T23], AC-28)

Timestamp: 2026-10-09T21-41
Command: git grep -n -E -e "^##+ " -- extensions/drm-copilot/CHANGELOG.md
EXIT_CODE: 0
Output Summary: four heading lines; the first three are, in order, `## [Unreleased]`, `### Changed`, `## [0.0.1] - 2026-05-02`:

```
extensions/drm-copilot/CHANGELOG.md:8:## [Unreleased]
extensions/drm-copilot/CHANGELOG.md:10:### Changed
extensions/drm-copilot/CHANGELOG.md:21:## [0.0.1] - 2026-05-02
extensions/drm-copilot/CHANGELOG.md:23:### Added
```

## Block 2

Command: git grep -n -F -e "config/poshqc-coverage.json" -- extensions/drm-copilot/CHANGELOG.md
EXIT_CODE: 0
Output Summary: two lines (13 and 19).

[P7-T22] check: `git diff --numstat 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a -- extensions/drm-copilot/CHANGELOG.md` printed `11	0` (11 added, 0 deleted). Merge-base substitution: 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a used in place of the plan literal e7d3779b398604af919678c16c877c8539a86cc0.

Acceptance (AC-28): first three headings in the stated order with `## [Unreleased]` at line 8; second block prints at least one line. PASS.
