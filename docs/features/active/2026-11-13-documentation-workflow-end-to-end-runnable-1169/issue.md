# documentation-workflow-end-to-end-runnable (Issue #1169)

- Date captured: 2026-11-13
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/documentation-workflow-end-to-end-runnable/ (Issue #1169)

- Issue: #1169
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1169
- Last Updated: 2026-11-13
- Work Mode: full-feature

## Problem / Why

Make the documentation workflow end-to-end runnable (commit, push, PR) and fix defects found in a first consumer run.

A first full run of `/documentation-workflow` (docs-init → inventory → IA plan → author → reconcile → review → validate) was completed in a consumer repository: a Python package of 3,061 surface elements (2,610 public symbols, 386 architecture components, 65 config keys), 22 pages, docs-complete passing. The run exposed (A) gaps that prevent a docs run from committing, opening a PR, or merging without an orchestration checkpoint, and (B) defects in the docs tooling, hooks, templates and skills. Fix all items below. Each item states the observed behavior, the evidence and the required change. Follow the repository's toolchain, test, file-size and tonality rules; add a regression test per item.

Design principle for part A: a docs run writes no orchestration checkpoint by design. Give it a checkpoint-free path modelled on the cleanup-worktrees context (issue #1026: session-root manifest + consolidation branch + path restriction), using the docs profile and a passing docs-complete receipt as the readiness evidence.

## Proposed Behavior

### Part A — Let the documentation workflow commit, push and open PRs

**A1. Preimplementation gate blocks every docs commit**
- Observed: `git add -- docs/... && git commit -F <file>` from the root session is denied with `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json ...`.
- Evidence: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:137` (`git (add|commit)` pattern) and `:144` (`$isStaging`); the only checkpoint-free allow legs are the #539 bookkeeping exemption and the #1026 cleanup leg (`:415`).
- Change: add a docs-estate leg (new sibling, e.g. `enforce-orchestration-preimplementation-gate-docs.ps1`, mirroring `-cleanup.ps1`) that allows `git add -- <paths>` and `git commit -F <file>` (no pathspec on the commit) only when all of the following hold:
  1. `docs/documentation-estate/docs-profile.json` exists and validates.
  2. Every pathspec and every staged path is under a profile `documentation_roots[].path`, under the directory of the profile's `artifact_paths`, or in the docs-init output set (see A3).
  3. No other implementation pattern matches the same command line. Keep the existing loop semantics, so a chained `pytest`/`ruff` segment still denies.

  Fail closed. Add a deny suffix that names the failed condition, as the cleanup leg does.

**A2. PR-author delegation is denied without a checkpoint**
- Observed: a docs run cannot delegate `Agent(pr-author)`. `enforce-model-routing-receipt.ps1:376` requires a `model_routing_receipts` entry in a checkpoint; only the cleanup delegation is exempt (`:368`).
- Change: add a docs-estate delegation leg beside the cleanup leg. It admits `Agent(pr-author)` with no checkpoint when all of these hold:
  - the prompt carries exactly one `branch: <name>` label line;
  - the branch diff against the explicit base is limited to the A1 path set;
  - a passing docs-complete receipt exists at the profile's `artifact_paths.validation_receipt` (see A4 for the revision rule).

  Document the delegation-prompt contract in `.claude/skills/pr-author/SKILL.md` and in the documentation-workflow skill (A5).

**A3. Docs-only exemptions reject the files docs-init itself creates**
- Observed: `docs-init -Write` creates these files:
  - `.markdownlint.json`
  - `.vale.ini`
  - `.vale/styles/DocsBase/HeadingPunctuation.yml`
  - `.vale/styles/DocsBase/Placeholders.yml`
  - `.vale/styles/config/vocabularies/Project/accept.txt`
  - `.github/workflows/_docs-quality.yml`

  A docs branch therefore always contains non-`docs/` paths. The create-side exemption (E7 `DOCS_ONLY_EXEMPTION_NON_DOCS_PATH`, `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`) and the merge-side exemption (M9, `.claude/hooks/hook-docs-only-diff.ps1`) can never pass for a docs estate's first PR.
- Change (choose one and document it):
  - Preferred: have docs-init place the Vale and markdownlint configuration under `docs/documentation-estate/`, and pass `--config` paths in `_docs-quality.yml`. Then treat exactly the docs-init workflow file path as an allowed non-`docs/` path in E7/M9, sourced from one shared constant used by init (not a glob).
  - Alternative: extend E7/M9 to accept exactly the docs-init output paths from that single shared constant.

  Keep the exemptions fail-closed and ordinal. Add tests for a branch containing only docs paths plus the init outputs (allow), and for one with one extra non-docs path (deny).

**A4. Receipt revision rule makes the integration docs-complete gate unsatisfiable**
- Observed: `validate -Mode docs-complete -Revision <rev>` fails with `DOCS_REVISION_MISMATCH` unless `<rev>` equals the snapshot's `revision`. The snapshot is committed inside the PR, so the commit containing it can never be the snapshot's revision. A receipt is therefore only writable for the source revision, an ancestor of the PR head. But `.claude/hooks/enforce-docs-complete-gate.ps1:297` checks the receipt against the PR `headRefOid`. With `completion_gates.integration_pr_gate.enabled: true` the gate appears impossible to satisfy. This was inferred from the call site and the validate behavior; verify it in `Test-DocsCompleteGateReceipt`.
- Additional observation: after the docs branch was rebased onto a newer main, the snapshot revision was no longer in branch history at all, and the source had drifted (+52 / −40 / 13 changed elements).
- Change: define one revision rule used by both `validate` and the gate. For example:
  - the receipt revision equals the snapshot revision, which must be an ancestor of the head;
  - `git diff --name-only <receipt-rev> <head>` must contain no path under the profile's `surface_selection.source_roots`; otherwise deny, with a remediation that names the refresh steps.

  Make `validate -WriteReceipt` default `-Revision` to the snapshot revision, and say so in its help.

**A5. The documentation-workflow skill has no commit / PR stage**
- Observed: `.claude/skills/documentation-workflow/SKILL.md` ends at docs-validate. Nothing says when to commit, how the receipt relates to commits, or what to do after a rebase.
- Change: add a final, root-owned stage:
  1. Commit after docs-init and after docs-complete.
  2. Write the receipt per A4.
  3. Push.
  4. Delegate `Agent(pr-author)` per A2.

  Add a "refresh after rebase or source change" procedure:
  1. Re-inventory at the new revision.
  2. Regenerate reference pages.
  3. Update `surface_refs` of hand-written pages for added and removed elements.
  4. Re-review changed elements.
  5. Rebuild the ledger.
  6. Re-validate.
  7. Write a new receipt.

### Part B — Defects found in the run

**B1. docs-architect cannot finish a first inventory run (stop-hook loop)**
- Observed: `validate-docs-role-output.ps1` rejects every docs-architect report with `DOCS_ROLE_OUTPUT_BLOCKED: ... docs-snapshot path 'docs/documentation-estate/surface-inventory-snapshot.json' does not exist`. The role cannot create the snapshot: `run_docs_inventory` returns `written: false`, and persistence is a root step (`docs-inventory-surface/SKILL.md` step 3). On a first run the agent repeated its report until the run ended, with no real fault (inventory exit 0, 0 findings). The cost was about 93 minutes, 361 tool uses and about 652k tokens.
- Evidence: `.claude/hooks/docs-role-contract.ps1:173-175` passes `docs-snapshot` to `Get-DocsRolePathFinding`, whose `:153` requires existence for every `docs-result` value.
- Change: use one or more of these:
  - do not require `docs-snapshot` to exist; check only that it is repository-relative;
  - exempt `BLOCKED`/`FAIL`;
  - accept a `docs-snapshot-persisted: false` token;
  - have the workflow run the root `inventory -Write` before delegating step 2.

  Add a first-run test (profile present, snapshot absent).

**B2. update-ledger: no bulk operation, ~39 s per call, and quadratic in-process cost**
- Observed: one `update-ledger` CLI call takes about 39 s, almost all of it loading and re-validating the estate. A 3,061-element estate needs about 15,300 single-element calls (set-disposition, exists, owner_assigned, accurate, and pins): about 130 hours through the CLI or MCP.
- Applying the operations in one process is still quadratic: every merge copies, scans and re-sorts the whole collection. The first 500 operations took about 40 s and the last 500 about 12 min; 12,244 operations took about 2 h 40 min.
- Evidence:
  - `DocsLedger.psm1:471-474` (`Merge-DocsLedgerEntry`: `Copy-DocsLedgerValue`, `Where-Object` over all entries, `Get-DocsLedgerSortedEntry`);
  - `DocsParity.psm1:451-453` (`Merge-DocsParityDimension`);
  - `DocsEvidencePins.psm1:249-252` (`Merge-DocsEvidencePin`);
  - `DocsLedgerCommands.psm1:569` (another full scan per operation).
- Verified workaround:
  1. Run each element's operations through `Invoke-DocsLedgerOperation` against the empty documents, and collect the entries, rows and pins.
  2. Sort each collection once.
  3. Run the unchanged introduced-error check and one `Invoke-DocsArtifactWrite`.

  The output was byte-identical to sequential application on a 120-element / 560-operation sample, and the full 15,305 operations took about 3 min.
- Change:
  - Add a batch operation to `update-ledger` (CLI `-Operations <json path>`, plus the MCP `update_docs_ledger` equivalent). It loads once, applies N operations with keyed (dictionary) indexes instead of copy-scan-sort per operation, runs the introduced-error comparison once, and writes once.
  - Add a bulk "bind page refs" operation that sets `documented` plus page bindings for every element listed in pages' `surface_refs`. Today `sync-refs` only refreshes snapshot and ledger pins and plans no writes on an empty ledger, which is easy to mistake for that operation.
  - Update `docs-reconcile-behavior/SKILL.md` and the docs-reconciler agent accordingly.

**B3. `accurate = pass` requires an evidence pin, but the skill doesn't say so**
- Observed: 2,675 `set-dimension accurate pass` operations without a preceding `pin` introduced `DOCS_MATRIX_ACCURACY_UNPINNED` errors, and the write was refused. `set-dimension` attaches only pins that already exist.
- Change: document in `docs-reconcile-behavior/SKILL.md` that `pin` must precede `set-dimension accurate pass` for the same element and page. Consider having the batch operation (B2) accept a pin claim on the accurate dimension.

**B4. Page templates write `audience` as a string; the checker requires a list**
- Observed: every page from `.claude/skills/docs-author-page/templates/*.md` failed `run_docs_check` with `DOCS_PAGE_AUDIENCE_INVALID` until `audience` was changed to `["<id>"]`.
- Change: fix all templates to `audience: ["<audience-id>"]`. Add a test that renders each template's front matter through the page checker.

**B5. generate-reference writes one API page per output directory and exceeds the 1 MiB page bound**
- Observed: for 2,610 public symbols, `generate-reference -Write` produced one `api-reference.md` of about 1.4 MB / 28,720 lines, which `check` rejects with `DOCS_PAGE_TOO_LARGE` (1 MiB scan bound). The IA plan's per-module grouping cannot be expressed.
- The workaround was four runs with `-Snapshot` filtered copies and distinct `-OutputDirectory` values. Filtered snapshots must be repository-relative (`DOCS_CLI_ARGUMENTS ... is not a repository-relative path`), which forces scratch files into the repository.
- Change:
  - Split generated reference pages automatically below the bound (for example per source package, or by size), or support a grouping key (path prefix → page) in `diataxis_policy` or as a generate-reference option, with an index page.
  - Allow `-Snapshot` outside the repository, or add an element filter option so no filtered snapshot copy is needed.

**B6. docs-init defaults `source_roots` to `src` without checking it exists**
- Observed: the generated profile had `surface_selection.source_roots: ["src"]`. The repository has no `src/`: its package is at the root, declared in `pyproject.toml`. Both `init` and `validate-profile` passed without a finding.
- Change: detect the package root (pyproject `[tool.poetry].packages` or `[project]` name, `package.json`, `.csproj`), or at minimum emit a `validate-profile` error for a source root that does not exist.

**B7. A documentation root of `docs` makes `check` crash on non-documentation trees**
- Observed: with the default root `docs`, `check` scanned about 6,000 planning and evidence files under `docs/features/`. It failed with exit 3: `DOCS_CONTEXT_PATH_INVALID: 'docs/features/active/.../evidence/other/xlsx|xlsm|xls|csv' is not a repository-relative path` (a link target containing `|`).
- Change:
  1. A malformed link target must produce a page finding, not a runtime crash.
  2. docs-init should not default to a documentation root that contains `docs/features/`. Default to dedicated roots, or add a root-level exclusion list to the profile schema.

**B8. Inventory reads `__pycache__` and emits hundreds of warnings**
- Observed: 310 `DOCS_INPUT_NOT_UTF8` warnings from `supply_planning/**/__pycache__/*.pyc` until an exclusion was added manually.
- Change: exclude VCS-ignored files and bytecode caches by default (honor `.gitignore`, or use a built-in default exclusion list).

**B9. Python CLI analyzer captures no commands for subcommand registration across modules**
- Observed: zero `cli-command` and `cli-option` elements for an argparse CLI. Its subcommands are registered in `cli.py`, `cli_daily.py`, `cli_segments.py` and `cli_compare.py`, with help in `cli_help/`. The analyzer emitted `CLI_UNBOUND_REGISTRATION` (20, 16, 13, 6 and 2 occurrences). The CLI reference had to be hand-written with `surface_refs: []`, so nothing tracks its accuracy.
- Change: resolve registration functions that receive a subparsers object as a parameter (cross-module `add_parser` calls). Add a fixture with that layout.

**B10. Diagnostic counts differ between the MCP tool and the CLI**
- Observed (not investigated): the role summarized 509 snapshot diagnostics from the `run_docs_inventory` MCP result, while CLI `inventory -Write` on the same revision reported 819. The difference equals the 310 `DOCS_INPUT_NOT_UTF8` warnings. Either the MCP result omits that code, or the role left it out of its summary.
- Change: confirm that the two return identical diagnostics; add a parity test.

**B11. Estate hashes are not protected against line-ending conversion**
- Observed: committing the estate printed "LF will be replaced by CRLF" for every file (`core.autocrlf=true`, no `.gitattributes` rule). The ledger, pins and receipt store SHA-256 hashes of snapshot and ledger content, so a CRLF checkout probably invalidates them. Whether the library normalizes line endings before hashing has not been verified.
- Change: either docs-init writes `.gitattributes` rules (`docs/documentation-estate/*.json text eol=lf` and `<documentation_root>/** text eol=lf`), or the hashing normalizes line endings. Add a test either way.

**B12. A subagent harness guard blocked a planned page name**
- Observed: docs-author could not write `docs/developer/architecture/reporting-storage-normalization.md`. It was refused with "Subagents should return findings as text, not write report files", apparently because the name contains "report". The page had to be written by the root.
- Change: identify the guard. Exempt `.md` writes inside the profile's documentation roots for docs-author, or document the naming restriction in `docs-plan-ia` and `docs-author-page`.

**B13. docs-init adds a CI workflow without saying so in the skill**
- Observed: `docs-init -Write` creates `.github/workflows/_docs-quality.yml`. The dry-run preview lists it, but `docs-init/SKILL.md` does not mention that init adds a CI workflow.
- Change: state it in the skill's Steps and Result sections, and report it as a distinct line in the init output.

## Acceptance Criteria (early draft)

- [ ] A first-time `/documentation-workflow` run in a repository with no orchestration checkpoint reaches docs-complete, commits, pushes, and creates its PR through `Agent(pr-author)` with no hook denial and no manual workaround, and its first PR passes the docs-only exemptions.
- [ ] A non-docs path in the same branch is still denied at commit, PR-create and merge.
- [ ] Reconciling a ~3,000-element estate completes in minutes through the supported `update-ledger` path.
- [ ] The integration docs-complete gate accepts a receipt produced by the documented workflow and denies one whose source drifted.
- [ ] Every item above (A1-A5, B1-B13) has a regression test, and the full toolchain loop passes.

## Constraints & Risks

- Every new allow leg (A1, A2, A3) is fail-closed and ordinal, modelled on the #1026 cleanup legs. A non-docs path must still be denied at commit, PR-create and merge.
- A docs run writes no orchestration checkpoint by design; readiness evidence is the docs profile plus a passing docs-complete receipt.
- Follow the repository's toolchain, test, file-size and tonality rules. Hook changes stay PowerShell or bash (no Python in enforcement hooks). Mirrors and push-down bundles stay in parity.
- B10 and B11 are unverified observations; confirm each before changing behavior.
- Scope is large (5 Part A items and 13 Part B items across hooks, docs library, MCP tool, skills, templates and analyzers). Planning should assess whether it is epic-scale.

## Test Conditions to Consider

- [ ] Unit coverage areas: the A1/A2 allow legs (allow and each deny condition), the E7/M9 exemption with the init outputs (allow) plus one extra non-docs path (deny), the A4 revision rule (ancestor, drift deny), B1 first-run role output, B2 batch equivalence against sequential application, B4 template front matter through the page checker, B5 page splitting, B6 missing source root, B7 malformed link target as a finding, B8 default exclusions, B9 cross-module subparser registration fixture, B10 MCP/CLI diagnostic parity, B11 line-ending stability of hashes.
- [ ] Integration scenarios: a first-time end-to-end `/documentation-workflow` run with no orchestration checkpoint, through commit, push and PR creation.
- [ ] CLI/API examples: `update-ledger -Operations <json path>` and its MCP equivalent; `validate -WriteReceipt` with the default revision.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/documentation-workflow-end-to-end-runnable/` folder from the template
