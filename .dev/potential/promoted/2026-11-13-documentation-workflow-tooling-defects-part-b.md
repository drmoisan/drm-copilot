# documentation-workflow-tooling-defects-part-b (Issue #1173)

- Date captured: 2026-11-13
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/documentation-workflow-tooling-defects-part-b/ (Issue #1173)

- Issue: #1173
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1173
- Last Updated: 2026-11-13
## Problem / Why

Issue #1169 reported two groups of findings from the first consumer run of `/documentation-workflow`:

- Part A (A1-A5): the workflow cannot commit, push, or open a PR without an orchestration checkpoint.
- Part B (B1-B13): defects in the docs tooling, hooks, templates, and skills.

On 2026-11-13 the owner directed that Part A be delivered first, under #1169. That PR closes #1169, so Part B is tracked here as a separate item. Its full text is unchanged and authoritative in the body of issue #1169, under `### Part B — Defects found in the run`. Each item there states the observed behavior, the evidence, and the required change.

## Proposed Behavior

Fix every Part B item as specified in #1169:

- B1: docs-architect cannot finish a first inventory run. The stop hook requires a snapshot that the role cannot persist.
- B2: `update-ledger` has no bulk operation, takes about 39 s per call, and its in-process merges cost quadratic time. Add a batch operation (CLI `-Operations` and the MCP equivalent) and a bulk "bind page refs" operation.
- B3: document that `pin` must precede `set-dimension accurate pass`.
- B4: page templates write `audience` as a string; the checker requires a list.
- B5: generate-reference exceeds the 1 MiB page bound. Split pages or support grouping, and allow a snapshot or element filter outside the repository.
- B6: docs-init defaults `source_roots` to `src` without checking that it exists.
- B7: a documentation root of `docs` makes `check` crash on `docs/features/` content. A malformed link must produce a finding, and init must use a safer default root.
- B8: inventory reads `__pycache__` and other VCS-ignored files.
- B9: the Python CLI analyzer misses subcommands registered across modules.
- B10: diagnostic counts differ between the MCP tool and the CLI (unverified; confirm first).
- B11: estate hashes are not protected against line-ending conversion (unverified; confirm first).
- B12: a subagent harness guard blocks a page name containing "report".
- B13: the docs-init skill does not state that init adds a CI workflow.

## Acceptance Criteria (early draft)

- [ ] Each of B1-B13 is fixed as specified in #1169, or, for B10 and B11, is confirmed or refuted with evidence before any behavior change.
- [ ] Reconciling a ~3,000-element estate completes in minutes through the supported `update-ledger` path (B2).
- [ ] Every item has a regression test, and the full toolchain loop passes.

## Constraints & Risks

- Depends on #1169 (Part A) only where the docs workflow skill and the docs hooks are shared. Plan after #1169 merges.
- Follow the repository's toolchain, test, file-size, and tonality rules. Hook changes stay PowerShell or bash. Mirrors and push-down bundles stay in parity.
- 13 independent defects. Planning should consider splitting them into parallel items or an epic.

## Test Conditions to Consider

- [ ] Unit coverage areas: as listed per item in #1169 (first-run role output, batch-versus-sequential equivalence, template front matter, page splitting, missing source root, malformed-link finding, default exclusions, cross-module subparser fixture, MCP/CLI parity, line-ending stability).
- [ ] Integration scenarios: a ~3,000-element ledger reconciliation through the batch path.
- [ ] CLI/API examples: `update-ledger -Operations <json path>` and its MCP equivalent.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/documentation-workflow-tooling-defects-part-b/` folder from the template
