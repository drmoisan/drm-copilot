Timestamp: 2026-09-30T08-55
Command: (in /c/Users/DanMoisan/repos/drm-copilot-wt/2026-09-29T13-45) grep -n -F '## Acceptance Criteria' docs/features/active/2026-09-30-npm-audit-brace-expansion-fast-uri-802/issue.md && grep -n 'AC-[123]:' docs/features/active/2026-09-30-npm-audit-brace-expansion-fast-uri-802/issue.md && ! test -e docs/features/active/2026-09-30-npm-audit-brace-expansion-fast-uri-802/spec.md && ! test -e docs/features/active/2026-09-30-npm-audit-brace-expansion-fast-uri-802/user-story.md && echo 'spec.md and user-story.md absent'
EXIT_CODE: 0
Output Summary:
    74:## Acceptance Criteria
    76:- [ ] AC-1: In all three manifests (`package.json`, `extensions/drm-copilot/package.json`, `packages/mcp-server/package.json`), `overrides` contains `"fast-uri": "^3.1.8"` and `"brace-expansion": "^5.0.12"`, and each `package-lock.json` is regenerated to match.
    77:- [ ] AC-2: `npm audit --audit-level=moderate` exits 0 in all three packages, and `npm ls brace-expansion fast-uri` shows only patched versions (brace-expansion >= 5.0.12, fast-uri >= 3.1.8).
    78:- [ ] AC-3: The root and extension TypeScript toolchains (format check, lint, type check, tests) pass with coverage not below baseline, the mcp-server build passes, and PR CI is green.
    spec.md and user-story.md absent
