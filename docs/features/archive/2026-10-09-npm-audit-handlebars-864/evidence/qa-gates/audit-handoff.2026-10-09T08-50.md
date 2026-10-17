# Evidence

Timestamp: 2026-10-09T08-18
Command: git -C WT status --porcelain
EXIT_CODE: 0
Output Summary: Four-file scope, all Phase 0/1/2 artifact paths, and AC evidence map listed; AC-3 PR-CI portion pending orchestrator.

## Printed output

```text
Scope: package.json, package-lock.json, extensions/drm-copilot/package.json, extensions/drm-copilot/package-lock.json (plus docs under the feature folder)

AC evidence map:
AC-1: lock-root, lock-extension, manifest-diff, scope-check (qa-gates)
AC-2: audit-*, ls-* (P1-T6) and final-audit-*, final-ls-* (P2-T9) (qa-gates)
AC-3 (toolchain portion): root-/extension- format-check, lint, typecheck, test-coverage (P2-T1..T8) and coverage-delta; PR-CI portion pending the orchestrator

Artifact paths:
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/audit-extension.2026-10-09T08-16.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/audit-mcp-server.2026-10-09T08-16.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/audit-root.2026-10-09T08-16.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/extension-ci.2026-10-09T08-16.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/extension-format-check.2026-10-09T08-24.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/extension-lint.2026-10-09T08-24.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/extension-test-coverage.2026-10-09T08-26.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/extension-typecheck.2026-10-09T08-24.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/git-baseline.2026-10-09T08-14.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/issue-ac-source.2026-10-09T08-14.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/ls-extension.2026-10-09T08-18.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/ls-mcp-server.2026-10-09T08-18.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/ls-root.2026-10-09T08-18.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/phase0-instructions-read.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/root-ci.2026-10-09T08-16.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/root-format-check.2026-10-09T08-20.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/root-lint.2026-10-09T08-20.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/root-test-coverage.2026-10-09T08-24.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/baseline/root-typecheck.2026-10-09T08-20.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/audit-extension.2026-10-09T08-32.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/audit-mcp-server.2026-10-09T08-32.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/audit-root.2026-10-09T08-32.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/coverage-delta.2026-10-09T08-48.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/extension-format-check.2026-10-09T08-44.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/extension-lint.2026-10-09T08-44.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/extension-test-coverage.2026-10-09T08-44.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/extension-typecheck.2026-10-09T08-44.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/final-audit-extension.2026-10-09T08-46.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/final-audit-mcp-server.2026-10-09T08-46.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/final-audit-root.2026-10-09T08-46.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/final-ls-extension.2026-10-09T08-46.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/final-ls-root.2026-10-09T08-46.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/lock-extension.2026-10-09T08-30.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/lock-root.2026-10-09T08-30.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/ls-extension.2026-10-09T08-32.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/ls-root.2026-10-09T08-32.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/manifest-diff.2026-10-09T08-32.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/phase1-push.2026-10-09T08-40.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/root-format-check.2026-10-09T08-44.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/root-lint.2026-10-09T08-44.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/root-test-coverage.2026-10-09T08-44.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/root-typecheck.2026-10-09T08-44.md
docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/scope-check.2026-10-09T08-34.md

git status --porcelain:
 M docs/features/active/2026-10-09-npm-audit-handlebars-864/issue.md
 M docs/features/active/2026-10-09-npm-audit-handlebars-864/plan.2026-10-09T08-05.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/coverage-delta.2026-10-09T08-48.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/extension-format-check.2026-10-09T08-44.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/extension-lint.2026-10-09T08-44.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/extension-test-coverage.2026-10-09T08-44.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/extension-typecheck.2026-10-09T08-44.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/final-audit-extension.2026-10-09T08-46.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/final-audit-mcp-server.2026-10-09T08-46.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/final-audit-root.2026-10-09T08-46.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/final-ls-extension.2026-10-09T08-46.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/final-ls-root.2026-10-09T08-46.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/phase1-push.2026-10-09T08-40.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/root-format-check.2026-10-09T08-44.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/root-lint.2026-10-09T08-44.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/root-test-coverage.2026-10-09T08-44.md
?? docs/features/active/2026-10-09-npm-audit-handlebars-864/evidence/qa-gates/root-typecheck.2026-10-09T08-44.md
```
