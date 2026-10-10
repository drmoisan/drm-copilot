# Evidence

Timestamp: 2026-10-09T08-14
Command: grep -n '^## Acceptance Criteria' issue.md; grep AC-N items; ls spec.md user-story.md
EXIT_CODE: 0
Output Summary: Heading present at line 71; AC-1, AC-2, AC-3 present; spec.md and user-story.md absent.

## Printed output

```text
71:## Acceptance Criteria
73:- [ ] AC-1: In both manifests (`package.json` and `extensions/drm-copilot/package.json`), `overrides` contains `"handlebars": "^4.7.10"` next to the existing overrides; no other dependency is bumped; `packages/mcp-server` is untouched; and both `package-lock.json` files (root and `extensions/drm-copilot`) are regenerated with npm install to match.
74:- [ ] AC-2: `npm audit --audit-level=moderate` exits 0 in all three packages (root, `extensions/drm-copilot`, `packages/mcp-server`), and `npm ls handlebars` shows only versions >= 4.7.10.
75:- [ ] AC-3: The root and extension TypeScript toolchains (format check, lint, type check, tests) pass with coverage not below baseline, except the pre-existing root `format:check` failure on `tests/fixtures/**` JSON (excluded as in #802, tracked in #848). PR CI is green on all checks, including Publish to Marketplace, verified against the full check list rather than only the required checks.
ls: cannot access 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-10-09-npm-audit-handlebars/docs/features/active/2026-10-09-npm-audit-handlebars-864/spec.md': No such file or directory
ls: cannot access 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-10-09-npm-audit-handlebars/docs/features/active/2026-10-09-npm-audit-handlebars-864/user-story.md': No such file or directory
```
