# Feature Audit: F4 ts-collect-commit-context (Issue #240)

**Audit Date:** 2026-06-26
**Work Mode:** full-feature (from `issue.md`: `- Work Mode: full-feature`)

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main`).
- **Merge-base SHA:** `a23c2b32c1b953a396a095235dac509a5f42b857`.
- **Head SHA:** `5d181223d4223da8e902c95431b8dcffc004852b` (`feat/ts-port-collect-commit-context-240`).
- **Audit basis:** Full branch diff vs. the resolved base, from `git diff --name-status a23c2b32..HEAD`. The `artifacts/pr_context.summary.txt` artifact is stale (it classified the branch as "Core logic changes: 0 files" and omitted all TypeScript source/test changes); the authoritative git diff was used instead, per the SKILL scope invariant and the caller's note that the appendix git name-status / direct git diff are authoritative.
- **AC sources (full-feature):** `spec.md` (epic ACs AC-E1..AC-E5) and the per-feature F4 checklist in `plans/F4-collect-commit-context.plan.md` (AC-F4-1..AC-F4-9). `user-story.md` does not exist at the feature root; its content is folded into `spec.md` (the "User Story" section). This absence is documented; the spec's user-story section and epic ACs are used as the AC source.

## Acceptance Criteria Inventory

### Epic acceptance criteria (spec.md) — realized incrementally; fully met at F11

- AC-E1: Every Python command script invoked by the extension or MCP server has a TypeScript equivalent with behavior parity.
- AC-E2: TypeScript test coverage for ported modules meets policy (line >= 85%, branch >= 75%).
- AC-E3: `RepoAutomationService` methods invoke in-process TypeScript instead of spawning Python; the `"python"` runtime branch and bundled Python resources are removed (delivered by F11).
- AC-E4: No remaining runtime dependency on a `python` interpreter for extension or MCP command execution.
- AC-E5: All CI gates pass on each feature PR.

### Feature F4 acceptance criteria (plans/F4-collect-commit-context.plan.md)

- AC-F4-1: `collect-commit-context.ts` ports the Python source with byte-identical git arg lists, `allowError` semantics, section headers, placeholders, `.py` filter, last-commit formatting, and change-intent block.
- AC-F4-2: The port uses the injected F1 `CommandRunner` and `FileSystem` (with `ensureDir`); no direct `node:child_process`/`node:fs` in the library function.
- AC-F4-3: `collectCommitContext` calls the in-process TS function instead of spawning Python, preserving the return contract and writing to `artifacts/commit_context.txt`.
- AC-F4-4: The printed `Commit context written to: <path>` message is emitted via the injected output sink.
- AC-F4-5: The unit test mirrors every behavioral scenario from the Python test using Jest with mocked `CommandRunner`/`FileSystem`; tests are hermetic.
- AC-F4-6: Extension tests asserting a Python spawn for `collect_commit_context` are updated to the in-process expectation without weakening unrelated assertions; tool name, MCP handler, and input schema unchanged.
- AC-F4-7: No file exceeds 500 lines; ES modules; no `any`; kebab-case filenames; AAA tests.
- AC-F4-8: Format, lint, typecheck, and coverage-enabled test all pass; new file meets line >= 85% / branch >= 75% with no regression on overall `src/lib/**`.
- AC-F4-9: Python `scripts/dev_tools/**`, `resources/templates/*.py`, `command-runtime.ts`, and the `"python"` runtime branch are unmodified (removal is F11).

## Acceptance Criteria Evaluation

### Epic ACs (F4 increment)

| AC | Verdict | Evidence |
|---|---|---|
| AC-E1 | PARTIAL (epic-level; F4 increment PASS) | F4 delivers the TS equivalent of `collect_commit_context.py` with verified behavior parity. The epic AC spans all scripts and is satisfied incrementally; F4's slice is complete. |
| AC-E2 | PASS (for the F4 module) | `collect-commit-context.ts` 100% line / 96.96% branch; `file-system.ts` 96.83% line / 86.66% branch. Both exceed policy. |
| AC-E3 | PARTIAL (epic-level) | F4 makes `RepoAutomationService.collectCommitContext` invoke in-process TS. The `"python"` branch and bundled-resource removal are explicitly deferred to F11; F4 correctly leaves them in place. |
| AC-E4 | PARTIAL (epic-level) | This command no longer requires Python; other commands still spawn Python until their features land. Full realization at F11. |
| AC-E5 | PASS (for this branch) | Independent local toolchain pass: format/lint/typecheck/test all EXIT 0; 641/641 tests. CI status at HEAD not available in PR context; local equivalents of the gates pass. |

### Feature F4 ACs

| AC | Verdict | Evidence |
|---|---|---|
| AC-F4-1 | PASS | Source-by-source comparison of `src/lib/collect-commit-context.ts` against `resources/templates/collect_commit_context.py`: identical git arg lists in source order; identical `allowError` flags (mandatory `remote -v`, `rev-parse HEAD`, `status -sb` false; all diff/log/ls-files true); identical thirteen section headers, spacers, and placeholder strings; identical `.py` filter via `split("\n")`; identical last-commit field formatting; identical change-intent block. |
| AC-F4-2 | PASS | The function consumes only injected `CommandRunner` (`runGit`) and `FileSystem` (`ensureDir`, `writeTextFile`); only `node:path` is imported from Node. No direct `node:child_process`/`node:fs`. |
| AC-F4-3 | PASS | `repo-automation-service.ts` diff replaces the `executeScript({... runtimeKind: "python" ...})` body with `runCollectCommitContext({...})`; the return record preserves `tool`/`workspaceRoot`/`summary`/`artifacts` and writes to `artifacts/commit_context.txt`. |
| AC-F4-4 | PASS | The library calls `log?.("Commit context written to: " + outputPath)`; the service passes `(message) => this.output.appendLine(message)`. A test asserts the `log` callback receives the message. |
| AC-F4-5 | PASS | `test/lib/collect-commit-context.test.ts` (+ run-git + helpers) covers output write, parent-dir creation, all headers, every placeholder branch, `.py` filter, last-commit formatting, log callback, and `runGit` success/throw/allowError paths, using in-memory fakes. Hermetic: no real git/fs/temp files. |
| AC-F4-6 | PASS | New `extension.collect-commit-context-inprocess.test.ts` asserts no Python `.py` spawn; `extension.collect-commit-context.integration.test.ts` drives section-content/no-staged assertions via mocked git; tool name `collect_commit_context`, handler, and input-schema tests remain green (641/641). |
| AC-F4-7 | PASS (with pre-existing note) | No F4-added or F4-modified file exceeds 500 lines except two test files that were already over the limit at baseline (`extension.integration.test.ts` 658->573; `extension.workflow-commands.test.ts` 957->880) and were reduced by this branch. ES modules; no `any`; kebab-case; AAA structure confirmed. |
| AC-F4-8 | PASS | Independent run: `prettier --check` EXIT 0; `npm run lint` EXIT 0; `npm run typecheck` EXIT 0; `node run-jest.cjs --coverage` EXIT 0. New file >= 85% line / >= 75% branch; `src/lib/**` aggregate 97.96% line / 90.84% branch (no regression vs. ~97.3% baseline). |
| AC-F4-9 | PASS | Name-status grep confirms `command-runtime.ts`, the `"python"` branch, `resources/templates/*.py`, and `scripts/dev_tools/**` are unmodified. |

## Summary

All nine F4 acceptance criteria are PASS. The branch delivers the F4 slice of the epic ACs (AC-E1/E2/E5 for this module are met; AC-E3/E4 are deferred-to-F11 by design and F4 correctly leaves the Python branch in place). The toolchain passes independently in a single pass with new-file coverage at 100% line / 96.96% branch. Scope is contained to the F4 boundary. The only non-PASS observations are the two pre-existing oversize test files (reduced, not introduced, by this branch) and the deferred-by-design epic-level removal work (F11). Remediation is not required.

**PR readiness: Go.** No blocking findings; 0 blocking findings total.

## Acceptance Criteria Check-off

The following criteria were verified PASS in this audit and checked off in the authoritative source file `plans/F4-collect-commit-context.plan.md`: AC-F4-1 through AC-F4-9 (all were already marked `[x]` by the executor; verification confirms them).

Epic ACs in `spec.md` (AC-E1..AC-E5) remain `[ ]` because they are epic-scope and are realized incrementally; they are not fully satisfied until F11 and are therefore left unchecked per the no-phantom-criteria and evidence-before-check-off rules.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/plans/F4-collect-commit-context.plan.md` (F4 checklist) and `docs/features/active/2026-06-25-port-python-commands-to-typescript-240/spec.md` (epic ACs)
- Total AC items (F4 checklist): 9
- Checked off (delivered + verified): 9
- Remaining (unchecked) in F4 checklist: 0
- Epic ACs (spec.md): 5 total, 0 checked (incremental; full realization at F11)
- Items remaining: epic AC-E1, AC-E3, AC-E4 (deferred-to-F11 by design); AC-E2/AC-E5 met for the F4 module but left unchecked at epic scope pending all features.
