# 2026-09-30-blast-radius-path-extractor-misses-real-plan-writes (Spec)

- **Issue:** #797
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T17-40
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria source: this `spec.md` only; no `user-story.md`)
- **Research:** `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/research/research.2026-10-08T17-27.md`

## Context

The blast-radius path extractor rejects several kinds of repository path that atomic plans write. The derived file list therefore omits them, and two items that write the same file can be scheduled concurrently. In 11 of 22 plans in parallel run `bug-burndown-2026-09-29`, the derived list omitted files the plan writes (figure quoted from the issue; not re-derived here and not asserted by any acceptance criterion). The V1 validation cannot detect this because it calls the same extractor on the plan side.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `classify_path_token` in `scripts/dev_tools/_blast_radius_extraction.py`, reached through `compute_blast_radius.py` derivation, `normalize_declared_radius`, and `_blast_radius_validation.py`
- Data source or fixture: atomic plans of parallel run `bug-burndown-2026-09-29`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

An omitted write produces a missing conflict edge, so conflicting items can share a cohort and run concurrently. Normalization of a recorded radius has the same defect: an entry that a planner appends by hand (for example `extensions/drm-copilot/jest.config.cjs`) is removed by `normalize_declared_radius` because the classifier rejects it.

## Repro & Evidence

Steps to Reproduce (from the workspace root):

```
poetry run python -c "from scripts.dev_tools._blast_radius_extraction import classify_path_token as c; [print(t, c(t)) for t in ['tests/shell/foo.bats','extensions/drm-copilot/jest.config.cjs','tests/out/run.out','.agents/skills/x/refs/foo.bats','.claude/lib/x/.shellcheckrc','Sample.*','tests/fixtures/Sample.*','.agents/skills/x/SKILL.md','tests/Sample.cs']]"
```

Expected: a token that names a file a plan writes is recorded as a path, so conflict edges are computed against it.

Actual (issue report on main at ae7c7779; matched by a static trace in the research note, section 4):

| Token | Current result |
|---|---|
| `tests/shell/foo.bats` | `None` |
| `extensions/drm-copilot/jest.config.cjs` | `None` |
| `tests/out/run.out` | `None` |
| `.agents/skills/x/refs/foo.bats` | `None` |
| `.claude/lib/x/.shellcheckrc` | `None` (extension parsed as `shellcheckrc`, not `rc`) |
| `Sample.*` | `None` (separator rule) |
| `tests/fixtures/Sample.*` | `glob` |
| `.agents/skills/x/SKILL.md` | `concrete` |
| `tests/Sample.cs` | `concrete` |

The research trace is static (not executed). The implementer runs the command above before any code change and saves the output under `<FEATURE>/evidence/baseline/`.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- The PowerShell port `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` carries the same extension set (`$script:RecognizedPathExtension`, lines 88-94), and its bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/` carries the identical block.

## Root Cause Analysis

1. **Extension allowlist (primary cause).** A wildcard-free token is accepted only when its final extension is in `RECOGNIZED_PATH_EXTENSIONS` (`_blast_radius_extraction.py:92-97`, consulted at `:318` and used at `:324-325` and `:330`). The set (`cfg cs csproj ini js json jsx lock md ps1 psd1 psm1 py sh sln toml ts tsx txt xml yaml yml`) was written against the file types present when the extractor was built. It omits file types that plans write (`.bats`, `.cjs`, `.mjs`, `.out`, `.info`, `.log`, `.config`, `.props`, `.vbproj`, and others) and every extensionless file name or dotfile (`Dockerfile`, `LICENSE`, `.gitignore`, `.vscodeignore`). The PowerShell port mirrors the same set at `BlastRadiusExtraction.psm1:88-94`, consulted at `:335`.
2. **Allowlist doubles as the directory rejection.** Issue #489 rejects directory-shaped tokens. The rejection is implemented by the same allowlist test: a token with no recognized extension is treated as a directory. Any fix must therefore keep rejecting directories through a separate structural rule rather than by listing extensions.
3. **Separator rule (contributing, not changed).** A token without `/` is accepted only as an exact configured root surface (`:281-282`, `:304-305`). This drops bare `Sample.*`. Under the committed configurations (`write_intent_extraction: true`), rule W1 drops every wildcard token regardless (`_blast_radius_write_intent.py:252`), so relaxing this rule has no production effect for bare globs.
4. **V1 circularity.** V1 validates the derived list using the same extractor (`_blast_radius_validation.py:332-339`), so a shared extractor defect cannot be detected by V1. This is recorded and deferred (see Non-Goals).

Secondary observation: `config/blast-radius.json` `mergeable_paths` lists `**/*.csproj`, `**/packages.config`, `**/app.config`, `**/*.vbproj`, and `**/*.props`. Only `.csproj` has an allowlisted extension, so concrete `packages.config`, `app.config`, `.vbproj`, and `.props` entries never reach a derived radius today. The fix corrects this as a side effect.

## Scope & Non-Goals

- In scope:
  - Replace the extension allowlist in the Python authority (`classify_path_token`) and the PowerShell port (`Get-PathTokenKind`) with a final-component file-shape predicate plus a closed set of known extensionless file names and dotfiles.
  - Place the predicate, its regular expression, and the known-name set in the token-shape leaf modules `scripts/dev_tools/_blast_radius_token_shapes.py` and `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`.
  - Byte-identical bundled mirrors of every edited `.claude/**` file under `extensions/drm-copilot/resources/claude-customizations/`.
  - Documentation of the file-shape rule, the accepted residuals, and the bare-name false negative in `.claude/rules/parallel-orchestration.md` and its bundled mirror.
  - Unit, regression, parity, and fixture updates in both runtimes, including the re-pin of `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json`.
- Out of scope / non-goals:
  - **Separator rule.** The separator-free rule is unchanged. Bare `Sample.*` and other separator-free tokens remain rejected unless they are configured root surfaces.
  - **Independent V1 cross-check** (issue proposal 3). Not implemented here. Follow-up candidate: file a potential item for a V1 check against an independent plan-side source.
  - **`.agents/skills/**` mandate-read exclusion.** Writes under `.agents/skills/` are excluded by the configured `mandate_reads` entry (`config/blast-radius.json:30`), independent of the classifier. Behavior unchanged. Follow-up candidate: confirm against the per-plan evidence of run `bug-burndown-2026-09-29` and, if confirmed as a cause of misses, file a separate potential item.
  - Changes to rules W1-W6, `path_roots`, `mandate_reads`, `mergeable_paths`, or root-surface handling.
- Explicitly excluded systems, integrations, or datasets:
  - Both copies of `config/blast-radius.json` (self-hosted and bundled) are not edited.
  - `pack-manifests/core.json` is not edited (no new `.psm1` module is added).
  - The TypeScript push-down module-map code (`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-*.ts`) is not an extractor port and is not edited.
  - No bash or `.codex/` port exists; none is created.

## Proposed Fix

### Design summary (what changes where):

Replace `extension in RECOGNIZED_PATH_EXTENSIONS` with a file-shape predicate evaluated on the final path component, after the existing `:<digits>` line-suffix strip. The predicate returns true when either condition holds:

1. **Dotted file name.** The component has a non-empty stem before its last `.`, and the text after the last `.`, lower-cased, fully matches `[a-z][a-z0-9]*` (an ASCII letter followed by zero or more ASCII letters or digits). Matching is case-insensitive through lower-casing, as today.
2. **Known file name.** The component is an exact, case-sensitive (ordinal) member of a closed set of extensionless file names and dotfiles. Adopted membership (grounded in the repository tree and the plan corpus, research section 5.1 and 5.4): `Dockerfile`, `Makefile`, `LICENSE`, `CODEOWNERS`, `NOTICE`, `.gitignore`, `.gitattributes`, `.gitkeep`, `.gitmodules`, `.vscodeignore`, `.npmignore`, `.npmrc`, `.nvmrc`, `.editorconfig`, `.prettierrc`, `.prettierignore`, `.eslintignore`, `.shellcheckrc`.

The predicate replaces `has_extension` in both places it is consulted: the wildcard-free branch (returns `concrete` only when the predicate holds) and the wildcard acceptance branch (a wildcard token not under a known top-level segment is accepted only when the predicate holds). All other steps of `classify_path_token` are unchanged: root-surface membership, placeholder-marker rejection, the separator rule, the first-segment colon rule, the line-suffix strip, the known top-level segment rule, and the multiple-feature-folder rejection.

`RECOGNIZED_PATH_EXTENSIONS` and `$script:RecognizedPathExtension` are removed. A repository search found no other code consumer.

### Boundaries and invariants to preserve:

- Directory-shaped tokens remain rejected (#489): no dot in the final component, a trailing `/`, or a dot-leading final component that is not in the known-name set (for example `.claude`, `.git`, `extensions/drm-copilot/resources/claude-customizations/.claude`).
- Version strings remain rejected: a digit-led or non-alphanumeric tail (for example `release/v1.2.0`, `actions/setup-node@v4.0.2`) fails the extension pattern.
- A trailing dot (empty extension) remains rejected.
- URLs and drive-qualified tokens remain rejected by the unchanged first-segment colon rule; rooted tokens (`/etc/hosts`) remain rejected by the unchanged leading-separator rule.
- Branch refs without a dotted final component (`origin/main`, `refs/heads/feature/x`) remain rejected.
- Dotted module names and other separator-free tokens (`scripts.dev_tools._blast_radius_extraction`, `$script:X`, `1.2.3`, `e.g.`) remain rejected by the unchanged separator rule.
- Bare `README.md` and `pyproject.toml` remain rejected (#452); only configured root surfaces are accepted without `/`.
- Placeholder-marker rejection (#502) and multiple-feature-folder rejection (#489) are unchanged.
- Case-insensitive extension matching is preserved (`src/app/Main.TS` stays `concrete`).
- Python is the authority; the PowerShell port produces identical classifications for every token.

### Dependencies or blocked work:

- None blocking. The change builds on the token-shape leaf modules introduced for #502.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production:
- `scripts/dev_tools/_blast_radius_token_shapes.py` — add the known-file-name set, the compiled extension pattern, and the file-shape predicate.
- `scripts/dev_tools/_blast_radius_extraction.py` — call the predicate in place of the allowlist; remove `RECOGNIZED_PATH_EXTENSIONS`; update the comments and docstrings that describe the allowlist (around `:74`, `:90-91`, `:258-262`, `:309-312`).
- `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` — add and export the equivalent predicate and name set.
- `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` — call the predicate in place of `$script:RecognizedPathExtension`; remove the set; update comment-help (around `:72`, `:86-87`, `:252-253`, `:323-326`).
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` — byte mirror.
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1` — byte mirror.

Documentation:
- `.claude/rules/parallel-orchestration.md` — the allowlist is not documented there today (verified by search). Add a short "File-shape recognition (issue #797)" subsection under "Blast-Radius Contention Doctrine" describing the dotted-name rule, the closed known-name set, and the accepted residuals; add a "Known false negatives" note that a separator-free bare file name is not recorded and must be cited repository-relative or appended by the planner.
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` — byte mirror.

Tests and fixtures:
- `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` — predicate unit tests.
- `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` — #797 classifier-level regression rows and false-positive guards.
- `tests/scripts/dev_tools/test_blast_radius_extraction.py` — move `alpha/beta.unknownext` from the rejected list to the accepted list.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` — predicate tests and a Python-source parity pin for the known-name set and extension pattern.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1` — invert the `weird/thing.unknownext` case; edits only (file is near the 500-line limit).
- `tests/fixtures/blast_radius/derivation-file-shaped-tokens.json` (new) — shared Python/PowerShell parity fixture in write-intent mode.
- `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json` — re-pin moved values.
- `tests/fixtures/blast_radius/derivation-directory-shaped-rejected.json` — update the `description` text only if it still refers to a "recognized extension"; expected values are not expected to change.

#### Functions/classes/CLI commands impacted:

- Python: `classify_path_token` (behavior); new public predicate in `_blast_radius_token_shapes.py` (suggested name `is_file_shaped_component`). Indirectly: `extract_paths_from_lines`, `extract_plan_paths`, `select_plan_paths`, `derive_blast_radius`, `normalize_declared_radius`, `validate_blast_radius`.
- PowerShell: `Get-PathTokenKind` (behavior); new exported function in `BlastRadiusTokenShape.psm1` (suggested name `Test-FileShapedComponent`). Indirectly: `BlastRadiusWriteIntent.psm1`, `BlastRadius.psm1`, `BlastRadiusValidation.psm1` callers.
- CLI: `compute_blast_radius.py` derivation and normalization outputs change for the newly accepted shapes; no flag or argument changes.

#### Data flow and validation changes:

- Tokens with a letter-led extension or a known file name now reach rules W1, W4, W6, and the mandate-read filter instead of being dropped at classification. Derived and normalized radii gain those entries; conflict edges and integration cost are computed against them.
- No change to the order of stages in the pipeline.

#### Error handling and logging updates:

- None. The classifier returns `None` / `$null` for rejected tokens as today; no exception paths are added. Empty strings and a lone `.` return false from the predicate.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. Rollback is a revert of the change set; the fixture re-pins revert with it.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Predicate input: one final path component (string). Output: boolean.
- Cross-runtime pattern parity: use explicit ASCII classes (`[a-z][a-z0-9]*`), not `\w`. Anchor the whole string without admitting a trailing newline: Python `re.fullmatch`; .NET `\A[a-z][a-z0-9]*\z`. Lower-case with `str.lower()` in Python and `ToLowerInvariant()` in PowerShell. Known-name membership is ordinal (Python `in frozenset`; .NET `HashSet[string]` with `[StringComparer]::Ordinal`).
- `classify_path_token` / `Get-PathTokenKind` return values are unchanged in type (`"concrete"`, `"glob"`, or `None` / `$null`).

#### Required configuration keys and defaults:

- None added. The known-name set is a code constant in both runtimes, so neither `config/blast-radius.json` copy changes and the deliberate self-hosted/bundled configuration difference (#500) is unaffected.

#### Backward-compatibility expectations:

- Deliberate contract change: wildcard-free `/`-bearing tokens with a letter-led extension not previously listed (for example `alpha/beta.unknownext`) are now `concrete`. Existing tests pinning the old rejection are inverted.
- Accepted residual (fail-closed direction): a dotted directory name cited without a trailing slash, such as the C#-style `src/TaskMaster.Domain`, is now classified `concrete`. Host-qualified tokens such as `example.com/page.html` or `owner/repo.git`, and refs whose final segment has a letter-led dotted tail, are likewise accepted. Each produces at most an extra contention edge, which serializes work; a missed write schedules concurrent edits and is the unsafe direction (`.claude/rules/parallel-orchestration.md`, Blast-Radius Contention Doctrine). In the self-hosted repository W4 removes host-qualified cases; in destinations (`path_roots: []`) W2 and W3 bound them.
- Side effect: concrete `packages.config`, `app.config`, `*.vbproj`, and `*.props` entries now reach derived radii, so the corresponding `mergeable_paths` classes (#643) can match derived entries.

#### Performance constraints (latency/throughput/memory):

- One precompiled regex match and one set lookup per final component replace one set lookup. No measurable change is expected; no performance criterion is set.

## Assumptions, Constraints, Dependencies

- Assumptions (recorded; no operator questions were asked):
  - A1. The separator-free `Sample.*` case is out of scope: W1 drops every wildcard token under the committed write-intent configurations, so accepting it would not change derived output, and a bare name cannot anchor a same-file edge.
  - A2. The `.agents/skills/**` mandate-read exclusion is a separate configured behavior and is out of scope (follow-up candidate).
  - A3. An independent V1 cross-check is out of scope (follow-up candidate).
  - A4. The `mergeable_paths` file types `packages.config`, `app.config`, `.vbproj`, and `.props` become recognized as a side effect; this is accepted and not separately tested beyond classifier rows.
  - A5. The adopted known-name set membership listed in the design is final for this fix; extending it later is a data-only change in both leaf modules with a parity pin.
  - A6. The C#-style dotted-directory residual is accepted (see Backward-compatibility expectations).
  - A7. The issue's `.shellcheckrc` example is hypothetical (no such file exists in the tree); it is covered by the known-name set.
  - A8. Pipeline-level tests use realistic, non-placeholder stems (for example `tests/shell/parallel_lane_assertion.bats`), because W6 drops placeholder stems such as `foo` and `sample` after classification. Classifier-level tests may use the issue's literal tokens.
  - A9. The research expectation that only the `cost` of edge 588-622 in `backlog-2026-09-26.json` moves, and that `verification-integrity-485-486-487.json` expected edges hold, is unverified until the suites run; whatever both runtimes produce in agreement is pinned and recorded.
- Constraints (budget, performance, compatibility):
  - File-size limit of 500 lines per production and test file. `_blast_radius_extraction.py` (476 lines) and `BlastRadiusExtraction.psm1` (475 lines) are near the limit, which is why the new logic goes in the leaf modules; `BlastRadiusExtraction.Path.Tests.ps1` (461 lines) takes edits only.
  - Tiers: `scripts/dev_tools` is T4; `.claude/lib/blast-radius` is T3. No property-test or mutation obligation applies. Line coverage >= 85% for both languages and branch coverage >= 75% for Python; Pester measures no branch coverage.
  - Bundled mirrors must be byte-identical to their repository sources.
- External dependencies (services, libraries, releases): none.

## Data / API / Config Impact

- User-facing or API changes: `classify_path_token` and `Get-PathTokenKind` accept more file-shaped tokens; `RECOGNIZED_PATH_EXTENSIONS` (Python module constant) is removed. One new predicate is exported from each leaf module.
- Data or migration considerations: historical-run fixture pins that depend on normalization of recorded radii are re-derived and re-pinned.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag or config schema change. Destination repositories receive the new behavior through the bundled PowerShell modules on the next push-down.

## Test Strategy

Seeded from issue (disposition):

- [ ] Extend `RECOGNIZED_PATH_EXTENSIONS` and the PowerShell mirror to cover at least `bats`, `cjs`, `mjs`, `rc`, `out`, and other types the plans write, or replace the allowlist with a rule that does not depend on extension. — Addressed by replacing the allowlist (design above).
- [ ] Decide how extensionless files and bare-name globs such as `Sample.*` are handled without re-admitting directory-shaped tokens (#489). — Extensionless files: closed known-name set. Bare-name globs: unchanged (A1).
- [ ] Add a V1 check that compares the derived list with an independent source, for example the plan's own file-table or task-level write markers, so a shared extractor defect is detectable. — Deferred (A3).
- [ ] Add tests for each newly recognized type, and a parity row for the PowerShell mirror. — Addressed by the acceptance criteria below.

- Regression tests to add or update: classifier-level rows for the issue tokens in `test_blast_radius_extraction_rules.py`; pipeline-level shared fixture `derivation-file-shaped-tokens.json` exercised by `test_blast_radius_parity.py` and `BlastRadius.Parity.Tests.ps1`; inversion of the `unknownext` tests in both runtimes.
- Unit tests (pytest) for the fixed behavior and boundaries: predicate tests in `test_blast_radius_token_shapes.py` covering letter-led extensions, uppercase extensions, multi-dot names (`jest.config.cjs`), known names, and negatives.
- Edge cases and negative scenarios: empty string; lone `.`; trailing `.`; dot-leading directory not in the known set; digit-led extension; extension containing `-`; non-ASCII letter extension; case variants of known names (for example `dockerfile`, which is not an ordinal member); line-suffixed tokens (`a/b.bats:12`).
- Error handling and logging verification: none required (no new error paths).
- Coverage impact and targets for changed lines/modules: Python line >= 85% and branch >= 75% on `_blast_radius_extraction` and `_blast_radius_token_shapes`; PowerShell line >= 85% on `BlastRadiusTokenShape.psm1` and `BlastRadiusExtraction.psm1`; no regression on changed lines.
- Toolchain commands to run (format → lint → type-check → test):
  - Python: `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → pytest with dotted-module coverage:
    `poetry run pytest tests/scripts/dev_tools/test_blast_radius_extraction.py tests/scripts/dev_tools/test_blast_radius_extraction_rules.py tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_blast_radius_write_intent.py tests/scripts/dev_tools/test_blast_radius_parity.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/dev_tools/test_blast_radius_verification_integrity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch --cov-report=term-missing`
    (a file-path `--cov=<path>.py` measures nothing; use the dotted form).
  - PowerShell: PoshQC format → analyze → test with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Because the PoshQC MCP results carry no per-test output, count and coverage evidence comes from a direct self-hosted run (`scripts/dev-tools/run-pester.ps1` or the self-hosted PoshQC module) over `BlastRadiusTokenShape.Tests.ps1`, `BlastRadiusExtraction.Path.Tests.ps1`, `BlastRadiusWriteIntent.Tests.ps1`, `BlastRadius.Parity.Tests.ps1`, and `BlastRadius.HistoricalRuns.Tests.ps1`.
- Manual validation steps (if required): none. Evidence is saved to `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/{baseline,qa-gates,regression-testing}/`.

## Acceptance Criteria

- [ ] Baseline evidence: before any production edit, the reproduction command in "Repro & Evidence" and the Python and Pester historical-runs, verification-integrity, and parity suites are run on the unmodified branch, and their output is saved under `<FEATURE>/evidence/baseline/`, showing `None` for `tests/shell/foo.bats`, `extensions/drm-copilot/jest.config.cjs`, `tests/out/run.out`, `.agents/skills/x/refs/foo.bats`, and `.claude/lib/x/.shellcheckrc`.
- [x] Classifier regression (Python): new tests in `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` assert that `classify_path_token` returns `concrete` for `tests/shell/foo.bats`, `extensions/drm-copilot/jest.config.cjs`, `tests/out/run.out`, `.agents/skills/x/refs/foo.bats`, `.claude/lib/x/.shellcheckrc`, and `.devcontainer/codespaces/Dockerfile`; these tests fail against the baseline code and pass after the change (fail-before/pass-after recorded in evidence).
- [ ] Classifier regression (PowerShell): `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` or `BlastRadiusExtraction.Path.Tests.ps1` asserts that `Get-PathTokenKind` returns `concrete` for the same tokens as the Python classifier regression criterion, and the run passes.
- [x] Pipeline-level regression: the new shared fixture `tests/fixtures/blast_radius/derivation-file-shaped-tokens.json`, in write-intent mode with realistic non-placeholder stems (for example `tests/shell/parallel_lane_assertion.bats`, `extensions/drm-copilot/jest.config.cjs`, a `.out` fixture path, a known dotfile, and a `Dockerfile` path), expects those paths in the derived radius; it fails against the baseline code and passes after the change under `poetry run pytest tests/scripts/dev_tools/test_blast_radius_parity.py`.
- [ ] Python/PowerShell parity: `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` passes on the same fixture corpus including `derivation-file-shaped-tokens.json`, producing the same derived radius as the Python parity test.
- [ ] Known-name and pattern parity: a Pester test in `BlastRadiusTokenShape.Tests.ps1` reads `scripts/dev_tools/_blast_radius_token_shapes.py` and asserts that the PowerShell known-name set equals the Python known-name set and that the extension pattern text is equivalent, following the pattern at `BlastRadiusWriteIntent.Tests.ps1:239-252`.
- [x] Predicate unit tests: `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` covers the new predicate for a letter-led extension, an uppercase extension, a multi-dot name, a known name, an empty string, a lone `.`, a trailing `.`, a dot-leading name not in the known set, a digit-led extension, and a case variant of a known name; all pass.
- [ ] False-positive guards unchanged: tests in both runtimes assert that `classify_path_token` and `Get-PathTokenKind` still return `None` / `$null` for `extensions/drm-copilot`, `scripts/dev_tools`, `.claude/rules/`, `extensions/drm-copilot/resources/claude-customizations/.claude`, `good_wt/.git`, `release/v1.2.0`, `actions/setup-node@v4.0.2`, `origin/main`, `https://x/y.md`, `C:/x.md`, `/etc/hosts`, `scripts.dev_tools._blast_radius_extraction`, `Sample.*`, `README.md`, and `pyproject.toml`; the pre-existing directory-shaped, root-surface, and placeholder-marker tests remain unmodified and pass.
- [ ] Accepted behavior change recorded: `alpha/beta.unknownext` (`test_blast_radius_extraction.py`) and `weird/thing.unknownext` (`BlastRadiusExtraction.Path.Tests.ps1`) are asserted as `concrete`, and a test in each runtime asserts that `src/TaskMaster.Domain` returns `concrete` as the documented dotted-directory residual.
- [ ] Allowlist removed: `rg -n "RECOGNIZED_PATH_EXTENSIONS|RecognizedPathExtension" scripts .claude extensions tests` returns no matches.
- [ ] Bundled mirrors byte-identical: `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`, `.../BlastRadiusExtraction.psm1`, and `.../.claude/rules/parallel-orchestration.md` are byte-identical to their repository sources (verified by `git diff --no-index --exit-code` per pair, saved to evidence) and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes.
- [x] Documentation: `.claude/rules/parallel-orchestration.md` contains a "File-shape recognition (issue #797)" subsection describing the dotted-name rule, the known-name set, and the accepted dotted-directory residual, and its "Known false negatives" section states that a separator-free bare file name is not recorded.
- [ ] Historical fixture re-pin: `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json` is updated to the values that the Python and PowerShell runs produce in agreement; every changed pin (expected: the `cost` of edge 588-622) is listed with before and after values in `<FEATURE>/evidence/regression-testing/`; `test_blast_radius_historical_runs.py` and `BlastRadius.HistoricalRuns.Tests.ps1` pass.
- [ ] Other suites stay green: `test_blast_radius_verification_integrity.py`, `test_blast_radius_write_intent.py`, `test_blast_radius_extraction.py`, and `BlastRadiusWriteIntent.Tests.ps1` pass; any pin change in `verification-integrity-485-486-487.json` is re-derived in both runtimes and recorded in evidence with its rationale.
- [x] Python coverage: the focused pytest command in "Test Strategy" reports >= 85% line and >= 75% branch coverage for `scripts.dev_tools._blast_radius_extraction` and `scripts.dev_tools._blast_radius_token_shapes`, with no uncovered changed lines; output saved under `<FEATURE>/evidence/qa-gates/`.
- [ ] PowerShell coverage: a direct self-hosted Pester run reports >= 85% line coverage for `BlastRadiusTokenShape.psm1` and `BlastRadiusExtraction.psm1`; output saved under `<FEATURE>/evidence/qa-gates/`.
- [x] Python toolchain clean: `poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`, and the focused pytest command complete without errors in a single pass.
- [ ] PowerShell toolchain clean: PoshQC format, analyze, and test complete without findings or failures in a single pass for the edited `.psm1` and `.Tests.ps1` files.
- [ ] File-size limit: every production and test file created or edited by this change, including `_blast_radius_extraction.py`, `_blast_radius_token_shapes.py`, `BlastRadiusExtraction.psm1`, `BlastRadiusTokenShape.psm1`, `BlastRadiusExtraction.Path.Tests.ps1`, and `BlastRadiusTokenShape.Tests.ps1`, is at most 500 lines (line counts recorded in evidence).

## Risks & Mitigations

- Technical or operational risks:
  - Over-acceptance of non-file tokens (dotted directories without a trailing slash, host-qualified tokens, dotted refs). Effect: extra contention edges and reduced parallelism.
  - A fixture pin outside the research's targeted search moves unexpectedly.
  - Python and PowerShell regex or lower-casing semantics diverge on edge inputs.
  - Destination repositories run with `path_roots: []`, so W4 does not filter host-qualified residuals there.
- Mitigations and rollbacks:
  - Over-acceptance is the fail-closed direction by doctrine and is documented; W2, W3, W4, W6, and the mandate-read filter bound exposure.
  - Baseline-versus-after runs of every fixture suite in both runtimes, with recorded deltas, detect unexpected pin movement.
  - Explicit ASCII classes, whole-string anchoring, and a Python-source parity pin plus the shared fixture corpus guard cross-runtime divergence.
  - Rollback by reverting the change set.

## Rollout & Follow-up

- Release/rollout steps: merge to main; destinations receive the PowerShell behavior on the next extension release and push-down.
- Post-fix monitoring or clean-up tasks:
  - Follow-up candidate: independent V1 cross-check against a plan-side source (issue proposal 3).
  - Follow-up candidate: confirm whether the `.agents/skills/**` mandate-read exclusion accounts for the reported misses under `.agents/` in run `bug-burndown-2026-09-29`.
- Links: issue https://github.com/drmoisan/drm-copilot/issues/797; research `research/research.2026-10-08T17-27.md`; related #489, #452, #500, #502, #643, #722.
