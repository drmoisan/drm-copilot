# Code Review: codex-agent-role-config (Issue #306)

**Review Date:** 2026-07-04
**Reviewer:** Codex feature-review workflow
**Feature Folder:** `docs/features/active/2026-07-04-codex-agent-role-config-306`
**Feature Folder Selection Rule:** Supplied by user and confirmed by PR context material scoping-doc changes for issue #306.
**Base Branch:** `main` / `origin/main`
**Head Branch:** `bug/codex-agent-role-config-306` at `0a8e29edbebfa6fc6ebfbbd7a92abb9c39218d18`
**Review Type:** Initial feature-branch review

## Executive Summary

The branch corrects Codex orchestrator role TOML shape, preserves MCP transport in config TOML, adds a Codex executable fallback through installed OpenAI/Codex extension package roots, and adds Python/Jest regression coverage. The core TypeScript resolver approach is bounded and testable, and no functional blocker was identified in the resolver itself.

The review found one code-review blocker: reusable orchestration skills now contain issue #306-specific plan-path instructions. That hardcoding affects future workflows and conflicts with the issue spec's explicit non-goal against reworking orchestration delegation rules or checkpoint semantics beyond TOML encoding.

**What changed:**
The diff modifies 59 files, including TypeScript runtime and test files, Python contract tests, Codex TOML role/config files, bundled customization resources, reusable orchestration skills, and issue #306 feature evidence.

**Top 3 risks:**
1. Issue-specific plan-path instructions in reusable skills can incorrectly affect future issues and feature folders.
2. Current branch hygiene fails `git diff --check`, so generated evidence is not merge-ready.
3. Current check-only Prettier validation fails on TypeScript files, while recorded evidence used `npm run format`, which writes rather than checks.

**PR readiness recommendation:** **Needs Revision** - remediation is required before merge because the branch contains a reusable-skill scope violation and current verification failures.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.agents/skills/orchestrate/SKILL.md`; `.agents/skills/orchestrator-workflow/SKILL.md`; `.agents/skills/feature-promotion-lifecycle/SKILL.md`; bundled copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/` | Root lines 130, 114, 113; bundled lines 130, 114, 113 | Reusable workflow skills contain an `Issue #306 invariant` that hardcodes `docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md`. | Remove issue-specific paths from reusable skill files. Keep only the generic deterministic `plan*.md` resolution rule, and record issue #306-specific plan-path evidence in the feature folder or checkpoint. | These skills are reusable policy/workflow sources. Hardcoding a single issue's feature folder changes behavior for future runs and conflicts with the spec non-goal at `spec.md:50`. | `Select-String` found issue #306 invariant text in six reusable skill files; `spec.md:50` excludes reworking orchestration delegation rules/checkpoint semantics beyond TOML encoding. |
| Major | `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/**`; `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md` | Multiple evidence files; `spec.md:88` | Current `git diff --check` fails on trailing whitespace and blank-at-EOF diagnostics in added feature artifacts. | Clean whitespace in added artifacts and rerun `git diff --check f530d0e3ae7c5d0974b72cf0956e862dd94041c5..HEAD`. | Repository review gates require clean diff hygiene. The recorded `git-diff-check.final.md` says pass, but current branch verification fails. | Current command exited 1 and reported trailing whitespace in `typescript-jest-coverage.final.md`, `typescript-resolver-command.pass-after.md`, `spec.md:88`, and blank-at-EOF diagnostics. |
| Major | `extensions/drm-copilot/src/**/*.ts`; `extensions/drm-copilot/test/**/*.ts` | Current formatter check | Check-only Prettier validation fails on six TypeScript files. | Run the repository formatter or reconcile whether the failures are pre-existing, then rerun a check-only Prettier command and record evidence. | The branch cannot claim a clean current TypeScript formatting gate while check-only verification exits 1. | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` exited 1 and listed `src/lib/codex-native-converter/rewrites.ts`, `src/remove-worktrees.ts`, `src/workflow-command-arguments.ts`, `test/extension.potential-to-issue.test.ts`, `test/extension.push-down-claude-customizations.test.ts`, and `test/mcp-repo-automation-tool-definitions.test.ts`. |

## Implementation Audit

### Python implementation audit

#### What changed well

- Python contract tests parse the root and bundled Codex TOML files directly.
- The tests assert both positive contract shape and prohibited role-local MCP transport.

#### Typing and API notes

- The tests use `dict[str, object]` and `cast` to make parsed TOML access explicit.
- No new Python production API was added.

#### Error handling and logging

- No new Python error-handling boundary was introduced.
- Assertions are deterministic over checked-in files.

### TypeScript implementation audit

#### What changed well

- `resolveCodexExecutable` preserves configured executable and PATH behavior before installed-extension fallback.
- Installed-extension probing is bounded to candidate roots and known relative executable locations.
- The command handler resolves the Codex executable before terminal creation, preserving fail-before-terminal behavior.

#### Type safety and maintainability

- The resolver uses `ReadonlyArray<string>` for candidate roots and keeps the fallback default empty.
- Test harness additions expose installed extension roots without requiring real VS Code extension state.

#### Error handling and logging

- Missing executable behavior continues to throw the existing explicit error message.
- No terminal is created when the executable cannot be resolved.

## Test Quality Audit

Reviewed evidence:

- `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/typescript-jest-coverage.final.md` - records 122 Jest suites and 1472 tests passing with 96.88% line coverage.
- `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/python-pytest-coverage.final.md` - records 1280 Pytest tests passing with 86% line coverage.
- `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/regression-testing/codex-doctor.pass-after.md` - records `codex doctor --json` exit 0 with no documented role-definition warning classes.
- `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/qa-gates/final-coverage-comparison.md` - records no coverage regression.

Quality assessment:

- **Determinism:** Tests use mocked filesystem and VS Code extension roots.
- **Isolation:** New tests target role/config contracts and executable resolution behavior directly.
- **Speed:** Recorded test runs are under 10 seconds for each language suite.
- **Diagnostics:** Test names and assertions identify the broken contract when they fail.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection found no new secrets or credentials. |
| No unsafe subprocess or command construction | PASS | Codex launch continues to use the PowerShell call operator with the resolved executable path. |
| Input validation at boundaries | PASS | Missing configured path or missing executable still throws before terminal creation. |
| Error handling remains explicit | PASS | Resolver preserves explicit failure message. |
| Configuration / path handling is safe | PARTIAL | Installed-extension probing is bounded; reusable skills contain an unsafe issue-specific path invariant. |

## Research Log

No external research was required. The review used repository policy files, canonical PR context artifacts, feature evidence, local git diff inspection, and current verification commands.

## Verdict

The TypeScript and Python implementation for the direct issue #306 behavior is broadly supported by tests and recorded coverage evidence. The branch is not ready for PR flow because it modifies reusable orchestration skills with issue-specific content and current branch verification fails on formatting/diff hygiene. Remediation is required before re-review.
