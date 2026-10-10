# Research — blast-radius path extractor misses real plan writes (Issue #797)

- **Issue:** #797
- **Branch:** bug/blast-radius-path-extractor-misses-real-plan-writes-797
- **Last Updated:** 2026-10-08T17-27
- **Work Mode:** full-bug
- **Requirements source:** `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/issue.md` and `spec.md` (spec is a Draft skeleton; Scope, Proposed Fix, and Acceptance Criteria are unpopulated)

All findings below come from reading files in this worktree with search and read tools. The session that produced this note had no shell tool, so nothing was executed. The reproduction in section 4 is a line-by-line static trace, and the note labels it that way. The implementer must run the reproduction command and save its output as baseline evidence before changing code (section 7).

---

## 1. Extraction pipeline (Python, authoritative)

### 1.1 Modules involved

| Module | Role |
|---|---|
| `scripts/dev_tools/_blast_radius_extraction.py` (476 lines) | Line normalization, plan partition, inline-code tokenizer, `classify_path_token`, `extract_paths_from_lines`, `extract_plan_paths`, `extract_contract_identifiers`. |
| `scripts/dev_tools/_blast_radius_token_shapes.py` (145 lines) | Leaf module holding the context-free shape rejections `contains_placeholder_marker` (#502) and `spans_multiple_feature_folders` (#489). It imports nothing from the library. |
| `scripts/dev_tools/_blast_radius_write_intent.py` (422 lines) | Write-intent rules W1–W6 (#722), `select_plan_paths` (the selector that derivation and V1/V2 share), and `select_write_intent_path_entries` (normalization). |
| `scripts/dev_tools/compute_blast_radius.py` | Facade: `derive_blast_radius` (`:298-337`) and `normalize_declared_radius` (`:340-415`). |
| `scripts/dev_tools/_blast_radius_validation.py` | `validate_blast_radius` (`:296-350`). V1 coverage findings come from `_coverage_findings` (`:353-379`). |

### 1.2 Stage order for a plan token (write-intent mode, which both committed configs enable)

1. `normalize_lines` → `str.splitlines()` (`_blast_radius_extraction.py:145-162`).
2. Attribution windows and W3: a task line opens a window. If `is_read_task_title` is true, every line in that window is skipped. An ATX heading closes the window (`_blast_radius_write_intent.py:298-305`, `:151-165`). Read verbs: `Read Verify Confirm Inspect Review Baseline` (`:76-78`). Write verbs: `Fix Write Update Edit Add Create Delete Remove Rename Author Append Replace` (`:79-83`). A write verb anywhere in the title overrides the read verb.
3. W2 command span: only inline spans that contain exactly one whitespace-separated word yield a token (`_single_word_tokens`, `:258-272`, using `INLINE_CODE_SPAN_RE` from `_blast_radius_extraction.py:68`).
4. **`classify_path_token`** (`_blast_radius_extraction.py:243-341`). The token must not return `None`.
5. Token rules (`_passes_token_rules`, `:238-255`):
   - W1 drops any token containing `*` or `?` (`:187-196`).
   - W4 drops a token whose first segment is not in `path_roots`, unless the token is a root surface (`:199-218`).
   - W6 drops a token whose final-component stem is in `PLACEHOLDER_STEMS` (`:84-89`, `:221-235`). The set is the single letters a–z plus `foo bar baz example sample placeholder`.
6. Back in the facade, `exclude_mandate_reads` drops entries matched by `mandate_reads` (`compute_blast_radius.py:326`). The feature-folder glob is added afterwards (`:327`).

Legacy mode (flag absent or false) runs `extract_plan_paths` over task titles, phase titles, and other lines. It splits every span on whitespace and runs the classifier on each token, with no W-rules (`_blast_radius_extraction.py:344-413`, `compute_blast_radius.py:311-318`).

### 1.3 `classify_path_token` decision sequence (line citations)

1. Root-surface exact ordinal membership → `concrete` (`:281-282`). The surfaces come from `config_root_surfaces(config)`, which is the separator-free subset of `shared_surfaces`.
2. Placeholder marker (`<`, `>`, `${`, `$(`, `%`) → `None` (`:297-298`, `_blast_radius_token_shapes.py:63`).
3. **Separator rule:** a token with no `/`, or with a leading `/`, → `None` (`:304-305`). A colon in the first segment → `None` (`:306-307`).
4. The final component is the text after the last `/`, with any `:<digits>` suffix stripped (`LINE_SUFFIX_RE`, `:88`, `:313`). The extension is the text after the last `.`, lower-cased (`:314-316`).
5. **Extension allowlist:** `has_extension = extension in RECOGNIZED_PATH_EXTENSIONS` (`:318`). The set at `:92-97` is `cfg cs csproj ini js json jsx lock md ps1 psd1 psm1 py sh sln toml ts tsx txt xml yaml yml`.
6. A wildcard-free token returns `concrete` only if `has_extension`; otherwise it returns `None` (`:324-325`). This rule also rejects directory-shaped tokens (#489).
7. A wildcard token is accepted when it starts with one of `KNOWN_TOP_LEVEL_SEGMENTS` (`:78-83`) or when `has_extension`. It is then rejected if it spans multiple feature folders, and otherwise returns `glob` (`:330-341`).

### 1.4 Configuration (`config/blast-radius.json`)

- `shared_surfaces` (`:3-14`). Its separator-free members (`poetry.lock`, `package-lock.json`, `quality-tiers.yml`) are the only bare tokens the classifier accepts.
- `mandate_reads` (`:20-33`) includes `.agents/skills/**`, `.claude/rules/**`, and `artifacts/**`.
- `mergeable_paths` (`:34-40`) is `**/*.csproj`, `**/packages.config`, `**/app.config`, `**/*.vbproj`, `**/*.props`. **Observation:** of these five entries, only `.csproj` has an allowlisted extension. Concrete `packages.config`, `app.config`, `.vbproj`, and `.props` files therefore never reach a derived radius, so four of the five mergeable classes (#643) can never match a derived entry. This is another instance of the same defect class.
- `write_intent_extraction: true` (`:51`). `path_roots` (`:52-70`) lists the 17 tracked top-level segments.
- Bundled copy `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`: `write_intent_extraction: true` (`:43`) and **`path_roots: []` (`:44`), which disables W4 in destination repositories**. The bundled config is deliberately different from the self-hosted one (#500). A fix that keeps the vocabulary as code constants does not touch either config.

### 1.5 Where the classifier is called

- Derivation: `compute_blast_radius.py:309` (via `select_plan_paths`) or `:312-317` (legacy).
- Normalization of a recorded radius: `compute_blast_radius.py:389-393`, which runs `classify_path_token` on every recorded entry, then W1/W4/W6 (`:396-399`), then mandate reads (`:400`). **Consequence:** at present, a planner-appended entry such as `extensions/drm-copilot/jest.config.cjs` is *removed* by normalization because the classifier rejects it.
- Validation V1/V2: `_blast_radius_validation.py:332-339` (via `select_plan_paths`).

V1 shares the extractor with derivation (`_blast_radius_extraction.py:20-22`, `:383-386`), so V1 cannot detect an extractor miss. The issue's diagnosis is correct.

---

## 2. Ports of the same logic

| Port | Location | Status |
|---|---|---|
| PowerShell | `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` (475 lines). `$script:RecognizedPathExtension` `:88-94` (HashSet, `[StringComparer]::Ordinal`, members identical to Python). `Get-PathTokenKind` `:242-373`: separator rule `:315-321`, extension `:327-335`, wildcard-free rule `:341-346`, known segments `:76-79`, `:348-361`. | Present. Must change. |
| PowerShell write-intent | `.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1`. Calls `Get-PathTokenKind` at `:285`. W1/W4/W6 `:191-218`. | Present. No change needed (consumes the classifier). |
| PowerShell facade / normalization | `.claude/lib/blast-radius/BlastRadius.psm1:190-195` (derivation), `:284` (normalization calls `Get-PathTokenKind`), `:293` (`Select-WriteIntentPathEntry`). Validation at `BlastRadiusValidation.psm1:363`. | Present. No change needed. |
| PowerShell token-shape leaf | `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` (about 190 lines). `Test-PlaceholderMarker` `:87`, `Test-MultipleFeatureFolderSpan` `:133`, export `:187`. | Present. Recommended home for the new predicate. |
| Bundled mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/*.psm1` (all ten modules; the same `RecognizedPathExtension` block at `:88-94`). | Present. Must be updated to match. |
| Bundled config | `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` | Present. Not affected by the recommended fix. |
| Bash port | `.claude/lib/bash/` | **None found.** The pattern `blast` matched only `parallel-items-validate.sh`, `parallel-common.sh`, `parallel-yaml-scan.sh`, and `parallel-lane-assertion.sh`. All of them validate manifest `blast_radius` field shapes; none extract or classify tokens. |
| `.codex/` copy | — | **None found.** Glob `{.claude/lib/bash/**,.codex/**}/*blast*` returned nothing, and a grep for `classify_path_token\|RecognizedPathExtension\|RECOGNIZED_PATH_EXTENSIONS` found no `.codex` hit. |
| TypeScript port | `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-*.ts` | **No extractor port.** These files derive a destination *module map* from directory observations (`claude-blast-radius-derive-core.ts:353`, `-manifests.ts:177`). A grep for `RECOGNIZED\|Recognized\|extension\|KnownTopLevel\|KNOWN_TOP` (case-insensitive) over them returned no matches. Research for #502 reached the same conclusion. |

**Mirror enforcement:** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) asserts that every distributable repo `.claude/**` file exists in the bundle with **identical text** (`read_text` equality). It therefore pins both `.psm1` mirrors and any `.claude/rules/*.md` or skill edit. `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1:62-74` checks only that each bundled file exists and that the module is listed in `core.json`. Adding a function to an existing module needs no manifest change. Adding a new `.psm1` would require a `pack-manifests/core.json` entry.

---

## 3. Existing tests and shared fixtures

### 3.1 Python (pytest)

| File | Relevance |
|---|---|
| `tests/scripts/dev_tools/test_blast_radius_extraction.py` | `:223-236` `test_classify_path_token_rejects_non_path_tokens` includes **`"alpha/beta.unknownext"`** (`:231`), which pins allowlist semantics, and `"alpha/beta"` (`:230`). `:203-211` covers the recognized-extension fallback. `:249-294` covers root-surface rules, including that `README.md` and `pyproject.toml` stay rejected as bare tokens. |
| `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` (about 176 lines) | Directory-shaped rejections `:28-49` (`extensions/drm-copilot`, `scripts/dev_tools`, `docs/features`, `.claude/rules/`, `artifacts/pr_context/`), line suffix, cross-corpus globs. **Recommended home for the #797 regression tests.** |
| `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` | Unit tests for the leaf predicates. Home for the new predicate's unit tests. |
| `tests/scripts/dev_tools/test_blast_radius_write_intent.py` | W-rule behavior. No change is expected, but it must stay green. |
| `tests/scripts/dev_tools/test_blast_radius_parity.py` | Runs every `tests/fixtures/blast_radius/*.json` (top level) through derivation and validation, with `MINIMUM_FIXTURE_COUNT = 30` (`:60`). A new fixture file is picked up automatically, and the floor need not move. |
| `tests/scripts/dev_tools/test_blast_radius_historical_runs.py` | AFTER tests (`:116-138`, `:218-255`) normalize recorded radii with the committed truth table and compare edges, cost, and benefit against fixture pins. **Affected** (section 3.4). |
| `tests/scripts/dev_tools/test_blast_radius_verification_integrity.py` | AFTER state normalizes with the committed `config/blast-radius.json`. Expected after-edges `[(486, 487)]`. Probably unaffected (section 3.4), but it must be re-run. |

### 3.2 Pester

| File | Relevance |
|---|---|
| `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1` (461 lines) | `:148-157` pins **`weird/thing.unknownext` → null**. `:159-168` pins case-insensitive matching (`src/app/Main.TS` → concrete). `:60-73` covers directory-shaped rejections, and `:250-259` covers bare `README.md`/`pyproject.toml` rejection. It has 39 lines of headroom under the 500-line limit, so it should take edits only. |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` (about 171 lines) | Home for the new predicate tests and a Python-source parity pin for the new name sets. |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1` | `:239-252` contains the vocabulary parity pattern (it reads the Python source with `Get-PythonVocabulary`, `:104-110`). This is the model for a new parity pin. |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` | Pester half of the shared fixture corpus, including historical-runs and verification-integrity. |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1` | `:123-140` compares AFTER edges, including `cost`, against the same fixture pins. **Affected.** |

### 3.3 Jest

No Jest test covers token classification, because no TypeScript port exists.

### 3.4 Pinned fixtures a widened classifier will move

- `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json`: items **588** (`:207`) and **622** (`:421`) both record `extensions/drm-copilot/jest.config.cjs` in `radius.paths`. In item 588 the entry is out of ordinal order at the end of the list, which suggests a planner appended it by hand after the extractor missed it. Today normalization drops it from both items. After the fix it survives W1 (no wildcard), W4 (`extensions` is in `path_roots`), W6 (stem `jest.config`), and the mandate filter. That adds one same-file overlapping pair. The AFTER edge `588–622` is already present (`:685-692`, `cost: 152`). Its pinned `cost` is expected to rise by at least the `same_file` weight (8). The exact value must be re-derived in both runtimes and re-pinned. The edge set and cohorts are not expected to change, because the edge already exists. This expectation is unverified until the tests run.
- `tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json`: `jest.config.cjs` appears only in 486 (`:302`). `extensions/drm-copilot/coverage/lcov.info` appears only in 487 (`:529`). `artifacts/python/lcov.info` and `artifacts/.coverage` (485, `:99`, `:106`) are dropped by W4 and the `artifacts/**` mandate read. No new shared entry was found by the targeted extension search, so `EXPECTED_AFTER_EDGES` is expected to hold. This is unverified until the tests run.
- `epic-655-followups.json:27-28` and `backlog-2026-09-26.json:252`: the `.out` and `.bats` entries are globs, which W1 drops in AFTER, so they are unaffected.
- Top-level parity corpus (`tests/fixtures/blast_radius/*.json`): every dotted backticked token in the `plan_text` fields carries an allowlisted extension, and the extensionless tokens are directories (`extensions/drm-copilot`, `scripts/dev_tools`). No existing expected radius changes under the recommended rule.

Search limitation: the fixture scan used a targeted list of 40+ non-allowlisted extensions, not an exhaustive enumeration. The implementer must run the full historical, verification-integrity, and parity suites before and after the change and diff the results (section 7).

---

## 4. Reproduction on current HEAD (static trace; not executed)

Command requested by the orchestrator (to be run by the implementer from the workspace root, with output saved to `<FEATURE>/evidence/baseline/`):

```
poetry run python -c "from scripts.dev_tools._blast_radius_extraction import classify_path_token as c; [print(t, c(t)) for t in ['tests/shell/foo.bats','extensions/drm-copilot/jest.config.cjs','tests/out/run.out','.agents/skills/x/refs/foo.bats','.claude/lib/x/.shellcheckrc','Sample.*','tests/fixtures/Sample.*','.agents/skills/x/SKILL.md','tests/Sample.cs']]"
```

Trace through `classify_path_token` with `root_surfaces=()`. None of the tokens contain a placeholder marker.

| Token | Path through code | Traced result |
|---|---|---|
| `tests/shell/foo.bats` | separator ok; ext `bats` not in set; no `*` → `:325` | `None` |
| `extensions/drm-copilot/jest.config.cjs` | ext `cjs` not in set → `:325` | `None` |
| `tests/out/run.out` | ext `out` not in set → `:325` | `None` |
| `.agents/skills/x/refs/foo.bats` | ext `bats` → `:325` | `None` |
| `.claude/lib/x/.shellcheckrc` | final `.shellcheckrc`; ext `shellcheckrc` (not `rc`, as the issue says) → `:325` | `None` |
| `Sample.*` | no `/` → `:304-305` | `None` |
| `tests/fixtures/Sample.*` | has `*`; starts with `tests/` → `:330`; not under `docs/features/` | `glob` |
| `.agents/skills/x/SKILL.md` | ext `md` → `:325` | `concrete` |
| `tests/Sample.cs` | ext `cs` → `:325` | `concrete` |

The trace matches the issue's "Actual Behavior".

**Pipeline-level corrections to the issue's framing (verified by reading code):**

1. Under the committed configs (`write_intent_extraction: true`), **W1 drops every wildcard token** (`_blast_radius_write_intent.py:252`). `Sample.*` and `tests/fixtures/Sample.*` are therefore dropped in production whether or not the classifier accepts them. Relaxing the separator rule would not change derived output for bare globs.
2. Tokens with placeholder stems (`foo.bats`, `Sample.cs`, `x/...` segments do not matter, only the final stem does) are dropped by **W6** after classification. Pipeline-level regression tests must use realistic stems, for example `tests/shell/parallel_lane_assertion.bats`.
3. `.agents/skills/**` is a configured `mandate_reads` entry (`config/blast-radius.json:30`), so **any** write under `.agents/skills/` is excluded at derivation regardless of the classifier. The issue's report of "misses under `.agents/`" may be partly explained by this configured exclusion (#489), not by the extractor. That is out of scope here. Confirm it against the run's per-plan evidence and, if confirmed, file it as a separate potential item.

---

## 5. Design options and recommendation

### 5.1 Evidence base: tokens real plans cite

Grep over `docs/features/**/plan*.md`, restricted to backticked tokens containing `/`:

- **Real writes rejected today**: `.bats` (for example `tests/shell/parallel_lane_assertion.bats`, `tests/shell/test_cleanup_worktrees_*.bats` in the #609 and #741 plans), `.cjs` (`extensions/drm-copilot/jest.config.cjs` in at least 7 active plans), `.mjs` (`extensions/drm-copilot/eslint.config.mjs`), `.out` (`tests/fixtures/cleanup_worktrees/scenarios/scan_roots_derived/worktree-list.out`), `.info` (`lcov.info`), `.log`, `.config` (test fixtures), dotfiles (`packages/mcp-server/.gitignore`, `extensions/drm-copilot/.vscodeignore`, `.gitkeep`), and extensionless names (`.devcontainer/codespaces/Dockerfile`, `packages/mcp-server/LICENSE`). Every one of these file types exists in the tree (verified by glob: `tests/shell/*.bats`, `extensions/drm-copilot/*.cjs|*.mjs`, `tests/fixtures/cleanup_worktrees/**/*.out`, `.gitattributes`, `.gitignore`, `extensions/drm-copilot/.vscodeignore`, `.devcontainer/*/Dockerfile`, `LICENSE` ×3). No `.shellcheckrc` exists in the tree; the issue's example is hypothetical.
- **Non-file `/` tokens that must stay rejected** (all seen in plans): directories (`extensions/drm-copilot`, `scripts/dev_tools`, `.claude/lib`, `tests/fixtures/push_down_exclusions`); **dot-directories** (`extensions/drm-copilot/resources/claude-customizations/.claude`, `good_wt/.git`, `/repo/main/.claude`); branch refs (`bug/...-623`, `origin/main`, `origin/epic/...`, `refs/heads/feature/...`); npm scopes (`@eslint/js`, `@jest/globals`); import specifiers (`./promotion-test-support`, `../../../src/lib/validate/...`); notation (`LH/LF`, `BRH/BRF`, `w/lf`, `a/b`, `a/../b`, `foo/bar`); git internals (`.git/worktrees/.../HEAD`).

Conclusions: (a) extensionless and dot-leading final components cannot be accepted by a general rule, because the plan corpus contains many directories and refs of those shapes. (b) A dotted final component whose extension starts with a letter is almost always a file. The non-file tokens in the corpus carry no dot, or a digit-led tail (versions).

### 5.2 Candidate A — expand the allowlist only

Add `bats cjs mjs out log info config props vbproj snap ...` and the dotfile names (`gitignore`, `vscodeignore`, ... which the code already reads as extensions) to both sets.

- Advantages: data-only change; no new false-positive class; existing `unknownext` tests stay valid; parity is trivial.
- Limitations: repeats the defect class. The next unlisted type (`.ps1xml`, `.svg`, `.html`, `.patch`, `.received.txt`-style suffixes, C# `.resx`) is silently under-reported, which is the dangerous direction. It does not handle extensionless names. It contradicts the module's stated design bias (`_blast_radius_extraction.py:34-35`: "the heuristic errs wide because radius under-reporting is the dominant design risk").

### 5.3 Candidate B — accept any `/`-bearing token (or any dotted final component, including dot-leading)

- Rejected. It re-admits directory-shaped tokens and dot-directories (`.../.claude`, `.git`), which #489 deliberately excluded. The plan corpus contains many such tokens (section 5.1).

### 5.4 Candidate C (recommended) — structural file-shape predicate plus closed name sets; separator rule unchanged

Replace `extension in RECOGNIZED_PATH_EXTENSIONS` with a predicate on the final component (after the existing `:<line>` strip). It returns true when either condition holds:

1. **Dotted file name:** the component has a **non-empty stem** before its last `.`, and the extension (lower-cased, as today) fully matches `[a-z][a-z0-9]*`, meaning an ASCII letter followed by ASCII letters or digits; or
2. **Known file name:** the component is an exact ordinal member of a closed set covering extensionless names and dotfiles. Suggested members, grounded in the tree and the plan corpus: `Dockerfile`, `Makefile`, `LICENSE`, `CODEOWNERS`, `NOTICE`, `.gitignore`, `.gitattributes`, `.gitkeep`, `.gitmodules`, `.vscodeignore`, `.npmignore`, `.npmrc`, `.nvmrc`, `.editorconfig`, `.prettierrc`, `.prettierignore`, `.eslintignore`, `.shellcheckrc`. The final membership is a spec decision.

Then use the predicate in both places `has_extension` is consulted today: the wildcard-free branch (`:324-325`) and the wildcard acceptance branch (`:330`).

Behavior of Candidate C on the critical shapes:

| Token | Today | Candidate C | Why |
|---|---|---|---|
| `tests/shell/parallel_lane_assertion.bats` | None | concrete | letter-led ext |
| `extensions/drm-copilot/jest.config.cjs` | None | concrete | letter-led ext |
| `tests/out/run.out` | None | concrete | letter-led ext |
| `.claude/lib/x/.shellcheckrc` | None | concrete | known dotfile |
| `.devcontainer/codespaces/Dockerfile` | None | concrete | known name |
| `src/app/Main.TS` | concrete | concrete | lower-cased before match (Pester `:159-168` still holds) |
| `extensions/drm-copilot`, `scripts/dev_tools`, `.claude/rules/` | None | None | no dot / empty final component (#489 tests hold) |
| `extensions/.../claude-customizations/.claude`, `good_wt/.git` | None | None | empty stem; not in known set |
| `actions/setup-node@v4.0.2`, `release/v1.2.0` | None | None | digit-led extension |
| `e.g./i.e.` | None | None | trailing dot → empty extension |
| `https://x/y.md`, `C:/x.md`, `/etc/hosts` | None | None | unchanged colon and leading-separator rules |
| `$script:X`, `scripts.dev_tools.x`, `1.2.3`, `foo.bar`, `e.g.` | None | None | no `/`, so the unchanged separator rule rejects them |
| `Sample.*`, `README.md`, `pyproject.toml` | None | None | separator rule unchanged |
| `alpha/beta.unknownext` | None | **concrete** | deliberate contract change; tests `:231` and Pester `:148-157` must be inverted |
| `src/TaskMaster.Domain` (C# project directory without trailing `/`) | None | **concrete** | accepted residual; see below |

**Accepted residuals (fail-closed direction).** A dotted directory name cited without a trailing slash (C#-style `TaskMaster.Domain`) and host-qualified tokens such as `example.com/page.html` or `owner/repo.git` are accepted. Each produces at most an extra contention edge, which serializes work. That is the safe direction under the doctrine at `.claude/rules/parallel-orchestration.md:231-236`. A missed write is the unsafe direction: it schedules concurrent edits. In the self-hosted repo, W4 (`path_roots`) removes the host-qualified cases. In destinations (`path_roots: []`), W2 (single-word span) and W3 (read windows) bound them. These residuals should be listed in the rules doc (section 6).

**Separator rule: keep unchanged.** Rationale:
1. W1 drops every glob in write-intent mode, so accepting bare `Sample.*` would change nothing in production.
2. A bare file name has no repository location. It can never compare equal to a path-anchored entry, so it cannot produce a correct same-file edge, and it would be dropped by W4 in the self-hosted repo anyway.
3. #452 deliberately limited bare tokens to configured root surfaces, and tests pin `README.md` and `pyproject.toml` rejection (`test_blast_radius_extraction.py:260-272`, Pester `:250-259`).
4. Bare dotted tokens in prose are frequently identifiers, module paths, or versions.

The remedy for bare citations is plan-authoring guidance: cite repository-relative paths. The planner's existing obligation to append a genuine write the rules drop (`parallel-orchestration.md:532-534`) and execution-time `detect_escaped_paths` (`:535-537`) remain the backstops.

**How plan-authoring conventions bound false positives.** In write-intent mode a token reaches the classifier only when all three hold:
- it is the sole word of an inline-code span (W2), so command lines and prose fragments inside spans are excluded;
- it lies outside a read-task window (W3);
- after classification it must still pass W4 in the self-hosted repo (first segment in a 17-entry root list), W6 (placeholder stems), and the mandate-read filter.

Atomic plans cite write targets as single backticked repository-relative paths in write-verb task titles. The widened classifier therefore mostly admits exactly those citations. The residual exposure is single-span prose tokens outside read windows, in destinations where W4 is off.

**Placement and file-size limits.** `_blast_radius_extraction.py` is 476 lines and `BlastRadiusExtraction.psm1` is 475 lines. Put the predicate, the regex, and the name set in the leaf modules `_blast_radius_token_shapes.py` (145 lines) and `BlastRadiusTokenShape.psm1` (about 190 lines). That follows the #502 precedent (`_blast_radius_token_shapes.py:21-26`). Remove `RECOGNIZED_PATH_EXTENSIONS` and `$script:RecognizedPathExtension`; the grep confirms no other code consumer. Update the comments and docstrings that describe the allowlist (`_blast_radius_extraction.py:90-91`, `:258-262`, `:309-312`; `BlastRadiusExtraction.psm1:86-87`, `:252-253`, `:323-326`).

**Cross-runtime regex parity.** Use explicit ASCII classes (`[a-z][a-z0-9]*`), not `\w`. Use whole-string anchoring that ignores a trailing newline: Python `re.fullmatch`, and .NET `\A...\z`, not `^...$`. Lower-case with `str.lower()` and `ToLowerInvariant()`, as the code does today. The name set should be pinned equal across runtimes by a Pester test that reads the Python source, mirroring `BlastRadiusWriteIntent.Tests.ps1:239-252`.

### 5.5 Rejected for this fix — independent V1 cross-check (issue proposal 3)

Any "independent" plan-side source, such as a file table or task markers, is another text heuristic over the same plan. It adds a second extractor to keep at parity across two runtimes and is outside the minimal-fix scope of a full-bug plan. Execution-time `detect_escaped_paths` already compares the declared radius against observed diffs. Recommend recording this as an explicit non-goal in `spec.md` and filing a follow-up potential item if the operator wants the V1 change.

### 5.6 Rejected alternatives (summary)

- **A (allowlist expansion only):** it leaves the defect class open for every future file type.
- **B (accept any `/` token or any dotted or dot-leading name):** it re-admits directories and dot-directories, regressing #489.
- **Relaxing the separator rule for bare file names or bare globs:** it has no production effect under W1, and bare names cannot anchor a same-file edge.

---

## 6. Documentation that describes the rules

- `.claude/rules/parallel-orchestration.md` (and its byte mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`): the allowlist is **not** documented. The section "Blast-Radius Contention Doctrine" (`:226-`) and "Known false negatives" (`:519-539`) describe the shape rejections and W-rules but say nothing about which file names are recognized. Recommended addition: a short "File-shape recognition (issue #797)" paragraph covering the dotted-name rule, the closed known-name set, the accepted dotted-directory residual, and a note in "Known false negatives" that a separator-free bare file name is not recorded and must be cited repository-relative or appended by the planner.
- `.claude/skills/parallel-plan/SKILL.md:243-246` (and its mirror) says the extractor rejects "a wildcard-free token naming a directory rather than a file". That statement remains accurate under Candidate C, so no edit is required. `:231-234` describes the separator-free root-surface rule, which is unchanged.
- `.claude/skills/parallel-orchestrate/SKILL.md:107` describes the root-surface rule, which is unchanged.
- Docstrings in `_blast_radius_extraction.py` and the comment-help in `BlastRadiusExtraction.psm1` (section 5.4) must be updated.

---

## 7. Toolchains, coverage, and mirror sync

**Python** (`.claude/rules/python.md:13-16`): `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → pytest. For focused coverage, use the dotted module form:

```
poetry run pytest tests/scripts/dev_tools/test_blast_radius_extraction.py tests/scripts/dev_tools/test_blast_radius_extraction_rules.py tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_blast_radius_write_intent.py tests/scripts/dev_tools/test_blast_radius_parity.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/dev_tools/test_blast_radius_verification_integrity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch --cov-report=term-missing
```

A file-path `--cov=<path>.py` measures nothing. Use the dotted form above.

**PowerShell** (`.claude/rules/powershell.md:15-20`): format → analyze → test via the PoshQC MCP tools (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`) with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. The MCP runner reads the installed extension's settings and returns no per-test output. For counts and coverage evidence, invoke the self-hosted runner directly (`scripts/dev-tools/run-pester.ps1` or the self-hosted PoshQC module). Target files: `BlastRadiusExtraction.Path.Tests.ps1`, `BlastRadiusTokenShape.Tests.ps1`, `BlastRadius.Parity.Tests.ps1`, `BlastRadius.HistoricalRuns.Tests.ps1`, `BlastRadiusWriteIntent.Tests.ps1`. Pester measures no branch coverage, so only the 85% line threshold applies.

**Jest:** not applicable, because there is no TypeScript port.

**Tiers:** `scripts/dev_tools` is T4 and `.claude/lib/blast-radius` is T3 (`quality-tiers.yml:16-18`, `:37-39`). No property-test or mutation obligation applies. Line coverage must be at least 85% and branch coverage at least 75% (Python), with no regression on changed lines.

**Mirror sync:** copy each edited `.claude/lib/blast-radius/*.psm1` and `.claude/rules/parallel-orchestration.md` byte-for-byte to `extensions/drm-copilot/resources/claude-customizations/<same relative path>`. `test_push_down_claude_resource_contracts.py:89-110` verifies text equality. No new `.psm1` file is proposed, so `pack-manifests/core.json` is unchanged. Neither `config/blast-radius.json` copy changes.

**Pre/post measurement (fail-closed evidence):** before editing, run the section 4 reproduction plus the historical-runs, verification-integrity, and parity suites in both runtimes, and save the output to `<FEATURE>/evidence/baseline/`. After the change, re-run them, save to `<FEATURE>/evidence/regression-testing/`, and record the exact pin deltas (expected: the `cost` of `backlog-2026-09-26` edge 588–622) together with the Python and PowerShell outputs that agree on them.

---

## 8. Recommended change set (files a fix would write)

Production:
1. `scripts/dev_tools/_blast_radius_token_shapes.py`: add the known-file-name set, the extension regex, and the file-shape predicate.
2. `scripts/dev_tools/_blast_radius_extraction.py`: replace the allowlist test at `:318`/`:324-330` with the predicate, remove `RECOGNIZED_PATH_EXTENSIONS`, and update docstrings and comments.
3. `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`: mirror the predicate and set, and export it.
4. `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`: replace the `$script:RecognizedPathExtension` usage and update the comment-help. Optionally re-export the new function, following the existing re-export pattern.
5. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`: byte mirror.
6. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1`: byte mirror.

Documentation:
7. `.claude/rules/parallel-orchestration.md`: file-shape recognition paragraph and a bare-name false-negative note.
8. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`: byte mirror.
9. `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md`: populate scope, non-goals (separator rule unchanged; V1 cross-check deferred; the `.agents/skills/**` mandate-read observation), and acceptance criteria.

Tests and fixtures:
10. `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py`: #797 regression rows (the issue tokens at classifier level; known dotfiles and names; dot-directory, digit-led, and trailing-dot negatives; bare `Sample.*` stays `None`).
11. `tests/scripts/dev_tools/test_blast_radius_extraction.py`: move `alpha/beta.unknownext` from the rejected to the accepted list (`:231`).
12. `tests/scripts/dev_tools/test_blast_radius_token_shapes.py`: predicate unit tests (positive, negative, boundary: empty string, lone `.`, trailing `.`, uppercase extension, digit-led extension).
13. `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1`: invert the `weird/thing.unknownext` case (`:148-157`). Edits only, to stay under 500 lines.
14. `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1`: predicate tests plus a Python-source parity pin for the known-name set.
15. `tests/fixtures/blast_radius/derivation-file-shaped-tokens.json` (new): shared parity fixture in write-intent mode with realistic non-placeholder stems (`.bats`, `.cjs`, `.out`, a known dotfile, `Dockerfile`), plus negatives (directory, dot-directory). Both parity suites consume it automatically.
16. `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json`: re-pin the `after` values that move (expected: the 588–622 `cost`). The same applies to any other historical or verification-integrity pin that the measurement in section 7 shows has changed.

Evidence (canonical locations): `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/{baseline,qa-gates,regression-testing,other}/...`.

---

## Numeric Derivation Evidence

This note proposes no numeric count, enumeration, or population for a `spec.md` acceptance criterion. The figures above are either quoted from the issue ("11 of 22 plans") or are line counts and file citations used for placement decisions, and none of them is proposed as an assertion. If the spec later adds a numeric criterion (for example the size of the known-name set, or a count of newly accepted file types), that criterion requires a complete primary and cross-check derivation in this section first.

---

## Automation Feasibility

Fully automatable; no human interaction is required. Every change is a deterministic edit to source, tests, fixtures, or documentation. Every verification step is a command-line toolchain run: pytest, Black, Ruff, Pyright, and the PoshQC format, analyze, and test runs. The fixture re-pin is mechanical (re-derive in both runtimes, confirm agreement, write the values). No external service, credential, UI interaction, or operator decision is needed during implementation. One operator decision is advisable but not blocking: accepting the closed known-name set membership and the dotted-directory residual, which can be settled during spec approval.
