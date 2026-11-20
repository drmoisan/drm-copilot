# Blast-radius under-reporting gaps (issue #452) — implementation research

- **Issue:** #452 (F1 follow-up, epic `parallel-orchestration`)
- **Timestamp:** 2026-08-08T10-15
- **Scope:** HOW to implement the three human-adopted resolutions. The resolutions themselves are fixed and are not re-litigated.
- **Explicitly out of scope:** `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`; the `.claude/rules/parallel-orchestration.md` validator byte-identity qualification (F3-remediated).

## 0. Source-document note (verified)

The authoritative promoted document `docs/features/potential/promoted/2026-08-07-blast-radius-under-reporting-gaps.md` does **not** exist in this worktree, and neither does `docs/features/potential/2026-08-07-blast-radius-under-reporting-gaps.md` (verified by `Glob docs/features/potential/**/*.md`, 24 files, neither present). The equivalent authoritative content is present verbatim at:

- `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5c761b8f1a691079\docs\features\active\2026-08-07-blast-radius-under-reporting-gaps-452\issue.md` (lines 26–104)

That file carries both defects with their verified reproductions and the three candidate resolutions (lines 96–104) in the wording quoted by the delegation prompt. All findings below are grounded in it plus direct source reading.

---

## A. `classify_path_token` — location, rule, return contract, callers

### A.1 Python

`scripts/dev_tools/_blast_radius_extraction.py`

- **Return contract (lines 89–92):**
  ```python
  PathTokenKind = Literal["concrete", "glob"]
  PATH_KIND_CONCRETE: PathTokenKind = "concrete"
  PATH_KIND_GLOB: PathTokenKind = "glob"
  ```
  `classify_path_token(token: str) -> PathTokenKind | None` — `None` means "not a repository path reference".

- **The `/` requirement (lines 243–246):**
  ```python
  if "/" not in token or token.startswith("/"):
      return None
  if ":" in token.split("/", 1)[0]:
      return None
  ```
  Line 243 is Gap 1. A separator-free token is rejected before any other rule runs.

- **Remaining acceptance rules (lines 250–268):** final-component extension read; acceptance requires `token.startswith(KNOWN_TOP_LEVEL_SEGMENTS)` (line 68–73) **or** `extension in RECOGNIZED_PATH_EXTENSIONS` (lines 77–82); then `"*" in token` selects `glob` over `concrete`.

- **Callers of `classify_path_token`:** exactly one production call site — `extract_paths_from_lines` at line 294 (`if classify_path_token(token) is not None`). It is also imported directly by `tests/scripts/dev_tools/test_blast_radius_extraction.py:18`.

- **Call chain above it:**
  - `extract_paths_from_lines(lines)` (line 271) ← `extract_plan_paths(plan_text)` (line 327) and ← `compute_blast_radius.derive_blast_radius` line 252 (`extract_paths_from_lines(normalize_lines(spec_text))`).
  - `extract_plan_paths` ← `compute_blast_radius.derive_blast_radius` line 251, and ← `_blast_radius_validation.validate_blast_radius` line 368 (`plan_concrete = concrete_entries(extract_plan_paths(plan_text))`).
  - `extract_plan_paths` is re-exported in `compute_blast_radius.__all__` (line 66) and is a frozen contract literal in the F1 spec (line 93).
- **No production consumer outside the blast-radius library exists** (verified by repo-wide grep; F1 has no callers yet). The blast radius of a signature change is therefore confined to the library plus its tests.

### A.2 PowerShell

`.claude/lib/blast-radius/BlastRadiusExtraction.psm1`

- `Get-PathTokenKind` (lines 261–327). Return type `[string]`, values `'concrete'` / `'glob'` / `$null` (script constants at lines 76–77).
- **The `/` requirement (lines 290–293):**
  ```powershell
  $separatorIndex = $Token.IndexOf('/')
  if ($separatorIndex -lt 0 -or $separatorIndex -eq 0) {
      return $null
  }
  ```
- **Callers:** `Get-PathFromLine` line 357 only. Chain: `Get-PathFromLine` ← `Get-PlanPaths` (line 402) and ← `BlastRadius.psm1:163` (spec lines); `Get-PlanPaths` ← `BlastRadius.psm1:162` and ← `BlastRadiusValidation.psm1:348`.
- All three functions are exported (`BlastRadiusExtraction.psm1:477–485`); `Get-PlanPaths` is re-exported by the facade (`BlastRadius.psm1:369`).

---

## B. Does `shared_surfaces` reach the extraction layer today? (No — plumbing must be added)

**Verified: there is no plumbing.** `_blast_radius_extraction.py` imports only `re`, `dataclasses`, `typing` (lines 41–46). It has no config parameter anywhere and no import of `_blast_radius_validation`. The PowerShell mirror `BlastRadiusExtraction.psm1` imports no sibling module at all.

The config **is** available at both entry points that must produce identical results:

| Function | File:line | Has `config`? |
| --- | --- | --- |
| `derive_blast_radius` | `compute_blast_radius.py:215-263` | yes (param `config`) |
| `validate_blast_radius` | `_blast_radius_validation.py:342-379` | yes (param `config`) |
| `Get-BlastRadius` | `BlastRadius.psm1:100-178` | yes (`-Config`) |
| `Test-BlastRadius` | `BlastRadiusValidation.psm1:299-359` | yes (`-Config`) |

This matters because AC "a derived radius passes V1 against its own plan" (`tests/scripts/dev_tools/test_blast_radius_invariants.py:247-254`) requires derivation and V1 to use the **same** extraction inputs. Both sides hold `config`, so both can compute the same root-surface set; no new coupling is required.

### B.1 Exact signatures needing a new optional parameter (Python)

All additions are keyword-only with an empty default, so every existing call site and every existing test remains source-compatible and byte-identical in behaviour when the parameter is omitted.

```python
# scripts/dev_tools/_blast_radius_extraction.py
def classify_path_token(
    token: str, *, root_surfaces: Sequence[str] = ()
) -> PathTokenKind | None: ...

def extract_paths_from_lines(
    lines: Sequence[str], *, root_surfaces: Sequence[str] = ()
) -> tuple[str, ...]: ...

def extract_plan_paths(
    plan_text: str, *, root_surfaces: Sequence[str] = ()
) -> tuple[str, ...]: ...
```

Plus one new config reader (see §J for its placement):

```python
def config_root_surfaces(config: Mapping[str, object]) -> tuple[str, ...]:
    """Separator-free entries of config["shared_surfaces"], sorted and deduplicated."""
```

Updated call sites (three lines total):
- `compute_blast_radius.py:251` → `extract_plan_paths(plan_text, root_surfaces=root_surfaces)`
- `compute_blast_radius.py:252` → `extract_paths_from_lines(normalize_lines(spec_text), root_surfaces=root_surfaces)`
- `_blast_radius_validation.py:368` → `extract_plan_paths(plan_text, root_surfaces=config_root_surfaces(config))`

### B.2 Exact signatures needing a new optional parameter (PowerShell)

Optional array parameter defaulting to `@()`; named-parameter invocation means existing callers stay valid.

```powershell
function Get-PathTokenKind { param([string]$Token, [string[]]$RootSurface = @()) }
function Get-PathFromLine  { param([string[]]$Line,  [string[]]$RootSurface = @()) }
function Get-PlanPaths     { param([string]$PlanText,[string[]]$RootSurface = @()) }
function Get-ConfigRootSurface { param([object]$Config) }   # new, in BlastRadiusConfig.psm1
```

Updated call sites: `BlastRadiusExtraction.psm1:357`, `:402`; `BlastRadius.psm1:162`, `:163`; `BlastRadiusValidation.psm1:348`.

---

## C. `_entries_overlap` vs `is_path_subsumed` — the precise asymmetry

### C.1 `_entries_overlap` (Python) — `scripts/dev_tools/_blast_radius_conflicts.py:198-228`

```python
a_is_glob = is_glob_entry(entry_a)
b_is_glob = is_glob_entry(entry_b)

if not a_is_glob and not b_is_glob:
    return entry_a == entry_b                      # concrete x concrete: EQUALITY ONLY
if a_is_glob and not b_is_glob:
    return matches_glob(entry_a, entry_b)          # glob x concrete: fnmatch ONLY
if b_is_glob and not a_is_glob:
    return matches_glob(entry_b, entry_a)

prefix_a = _literal_prefix(entry_a)                # glob x glob: two-way literal-prefix nest
prefix_b = _literal_prefix(entry_b)
return prefix_a.startswith(prefix_b) or prefix_b.startswith(prefix_a)
```

Its only caller is `_smallest_path_overlap` (`_blast_radius_conflicts.py:253`), which is called only from `conflicts` (line 160).

PowerShell counterpart: `Test-EntryOverlap`, `.claude/lib/blast-radius/BlastRadiusGlob.psm1:271-322` — structurally identical (`[string]::Equals(...Ordinal)`, `Test-GlobMatch`, `Get-LiteralPrefix` two-way `StartsWith`). Caller: `Get-SmallestPathOverlap`, `BlastRadius.psm1:254`.

### C.2 `is_path_subsumed` (Python) — `scripts/dev_tools/_blast_radius_extraction.py:458-494`

```python
for entry in covering_paths:
    if entry == path:
        return True
    if "*" in entry or "?" in entry:
        if matches_glob(entry, path):
            return True
    elif path.startswith(entry.rstrip("/") + "/"):   # LISTED-DIRECTORY PREFIX RULE
        return True
return False
```

PowerShell counterpart: `Test-PathSubsumed`, `BlastRadiusGlob.psm1:181-232`, line 226 carries the identical `StartsWith($entry.TrimEnd('/') + '/', Ordinal)` rule.

### C.3 The asymmetry, stated precisely

`is_path_subsumed` treats **every wildcard-free entry as a possible listed directory** and applies the anchored prefix rule `path.startswith(entry.rstrip("/") + "/")`. `_entries_overlap` applies **no directory semantics at all**: a wildcard-free entry participates only in string equality (concrete branch) or as an fnmatch *candidate* (glob branch). Consequently:

| Pair | `is_path_subsumed` view | `_entries_overlap` today |
| --- | --- | --- |
| `("scripts/dev_tools/x.py", ["scripts/dev_tools"])` | `True` (prefix rule) | n/a |
| `_entries_overlap("scripts/dev_tools", "scripts/dev_tools/x.py")` | would be `True` | **`False`** (equality) |
| `_entries_overlap("scripts/dev_tools", "scripts/dev_tools/**")` | would be `True` | **`False`** (`matches_glob("scripts/dev_tools/**", "scripts/dev_tools")` → regex `scripts/dev_tools/.*` fails on a candidate with no trailing segment) |

Both reproductions in `issue.md:61-62` are confirmed by reading the code.

Note (already-correct case, do not "fix"): `_entries_overlap("scripts/dev_tools", "scripts/**")` is **already `True`** today, because `matches_glob("scripts/**", "scripts/dev_tools")` translates to regex `scripts/.*` which does match. Only the *narrower-or-equal-rooted* glob and the concrete-file cases are blind.

---

## D. Minimal, strictly-widening change to `_entries_overlap`

### D.1 Recommended form

Add one directory-prefix disjunct to each of the two non-glob-pair branches. Nothing is removed.

```python
def _directory_prefix(entry: str) -> str:
    """Render a wildcard-free entry as the directory prefix it may name."""
    return entry.rstrip("/") + "/"


def _prefixes_nest(left: str, right: str) -> bool:
    """Report whether two literal prefixes could share a common path."""
    return left.startswith(right) or right.startswith(left)


def _entries_overlap(entry_a: str, entry_b: str) -> bool:
    a_is_glob = is_glob_entry(entry_a)
    b_is_glob = is_glob_entry(entry_b)

    if not a_is_glob and not b_is_glob:
        return (
            entry_a == entry_b
            or entry_a.startswith(_directory_prefix(entry_b))
            or entry_b.startswith(_directory_prefix(entry_a))
        )
    if a_is_glob and not b_is_glob:
        return matches_glob(entry_a, entry_b) or _prefixes_nest(
            _literal_prefix(entry_a), _directory_prefix(entry_b)
        )
    if b_is_glob and not a_is_glob:
        return matches_glob(entry_b, entry_a) or _prefixes_nest(
            _literal_prefix(entry_b), _directory_prefix(entry_a)
        )

    return _prefixes_nest(_literal_prefix(entry_a), _literal_prefix(entry_b))
```

The mixed-branch disjunct is exactly "treat the wildcard-free entry as the glob `<entry>/**` and apply the existing glob×glob rule", because `_literal_prefix(dir + "/**") == dir + "/"`. That keeps the new rule *definitionally identical* to the conservatism the relation already applies to glob pairs, which is the strongest available consistency argument.

PowerShell mirror (`BlastRadiusGlob.psm1`): same three branches, using `$Entry.TrimEnd('/') + '/'` (matching `Test-PathSubsumed:226` exactly) and `[System.StringComparison]::Ordinal` on every `StartsWith`.

### D.2 Proof that no pair changes True → False

Each branch is rewritten as `old_predicate OR new_predicate`; the glob×glob branch is untouched. Boolean disjunction is monotone, so for every input pair the new result is `>=` the old result under `False < True`. Therefore the set of pairs reported as overlapping strictly grows (or stays equal), and `conflicts` can never report *less* contention than before. Fail-closed semantics are preserved by construction — this is a proof about the code shape, not about enumerated cases, so it holds for all inputs.

Downstream monotonicity: `_smallest_path_overlap` (line 250–260) collects **all** overlapping pairs and returns `min(details)`; a superset of pairs can only keep or lower the minimum, never turn a non-`None` into `None`. `conflicts` therefore keeps every previously-true `path_overlap` verdict.

### D.3 Pairs whose result changes False → True

**Concrete × concrete (new: strict directory containment either way)**

| Pair | Before | After | Genuine? |
| --- | --- | --- | --- |
| `("scripts/dev_tools", "scripts/dev_tools/a.py")` | False | **True** | yes — the directory contains the file |
| `("scripts/dev_tools/", "scripts/dev_tools/a.py")` | False | **True** | yes (trailing separator normalised) |
| `("docs", "docs/features/active/x/spec.md")` | False | **True** | yes |
| `("scripts/dev_tools", "scripts/dev_toolsX/a.py")` | False | False (unchanged) | correct — anchored `/` guard, matches `test_is_path_subsumed_does_not_treat_a_sibling_prefix_as_a_directory` |
| `("scripts/dev_tools/a.py", "scripts/dev_tools/b.py")` | False | False (unchanged) | correct — neither is a directory prefix of the other |

**Concrete × glob (new: directory-expansion nest)**

| Pair | Before | After | Note |
| --- | --- | --- | --- |
| `("scripts/dev_tools", "scripts/dev_tools/**")` | False | **True** | the issue's reproduction |
| `("scripts/dev_tools", "scripts/dev_tools/*.py")` | False | **True** | genuine |
| `("scripts/dev_tools", "scripts/*/a.py")` | False | **True** | genuine (`*` fills `dev_tools`); this case is why the nest must be two-way — a one-way `literal_prefix.startswith(dirp)` rule would miss it and under-report |
| `("config/blast-radius.json", "config/*.yml")` | False | **True** | **conservative over-report.** The concrete entry is a file, but the relation cannot know that. Accepted: it is the same conservatism `_entries_overlap("config/blast-radius.json/**", "config/*.yml")` already exhibits today |
| `("docs/features/active/alpha", "docs/features/active/beta/**")` | False | False (unchanged) | prefixes diverge |
| `("scripts/a.py", "tests/**")` | False | False (unchanged) | prefixes diverge |

**Glob × glob:** no change whatsoever.

---

## E. Parity fixture corpus — schema, drivers, and how to add a fixture

### E.1 Location and size

`tests/fixtures/blast_radius/` — 21 committed JSON files (verified): 5 `derivation-*`, 6 `validation-*`, 10 `conflict-*`.

### E.2 Schema (two kinds, discriminated by `input.radius_a`)

Top level: `description` (string, free prose), `input` (object), `expected` (object).

**Derivation / validation fixture** — `input`:
- `plan_text` (string, may be empty; embeds literal `\n` / `\r\n` / `\r`)
- `spec_text` (string, may be empty)
- `feature_folder` (string, non-blank)
- `computed_at` (string)
- `tracked_file_count` (integer > 0)
- `config` (object — a *self-contained* truth table, deliberately not the committed `config/blast-radius.json`)
- `source` (optional string; defaults to `derived`)
- `radius` (optional object — a hand-authored declared radius validated *instead of* the derived one; the only way to express a V1/V2 failure, since a derived radius always passes V1/V2 against its own plan)

`expected`: `radius` (full six-key radius dict) and `findings` (ordered array of `{rule, severity, subject, message}`).

**Conflict fixture** — `input`: `radius_a`, `radius_b` (six-key radius dicts), `config`. `expected`: `conflict` (bool) and `reasons` (ordered array of `{kind, detail}`).

### E.3 Drivers

| Language | File | Mechanism |
| --- | --- | --- |
| Python | `tests/scripts/dev_tools/test_blast_radius_parity.py` | `FIXTURE_DIR.glob("*.json")` at import (line 170), partitioned into `DERIVATION_CASES` / `CONFLICT_CASES` (lines 221–226) by `CONFLICT_MARKER_KEY = "radius_a"` (line 60); four `@pytest.mark.parametrize` suites (lines 360, 381, 412, 439) |
| PowerShell | `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` | discovery-time `Get-ChildItem … ConvertFrom-Json -AsHashtable` (lines 37–51); four `-ForEach` `It` blocks (lines 235, 250, 271, 286); comparison via string signatures (`Get-RadiusSignature`, `Get-FindingSignature`, `Get-ReasonSignature`) with `Should -BeExactly` |

**Anti-vacuity guards that constrain corpus edits:** both suites assert a floor of **12** fixtures (`MINIMUM_FIXTURE_COUNT`, `test_blast_radius_parity.py:56`; `$minimumFixtureCount`, `BlastRadius.Parity.Tests.ps1:57`), assert that the discovery glob count equals the on-disk `.json` count, and assert both kinds are non-empty. Adding fixtures is therefore free; the floor need not be raised, but raising it to the new count would strengthen the guard.

### E.4 Adding a fixture

Drop a `.json` file into `tests/fixtures/blast_radius/`. **Both drivers pick it up automatically — no registration list exists in either language.** Name it `<kind>-<scenario>.json` following the existing convention.

**Template — Gap 1 (separator-free root surface reaches the radius):**

```json
{
  "description": "Separator-free repository-root shared surface: a plan citing `poetry.lock` in inline code is admitted as a concrete path because the token is an exact member of the config shared_surfaces list, so the derived radius enumerates the surface and V2 has force at plan time.",
  "input": {
    "plan_text": "### Phase 1 — Dependencies\n- [ ] [P1-T1] Regenerate `poetry.lock` and edit `scripts/dev_tools/a.py`.\n",
    "spec_text": "",
    "feature_folder": "2026-08-07-example-452",
    "computed_at": "2026-08-07T12-00",
    "tracked_file_count": 100,
    "config": {
      "version": 1,
      "shared_surfaces": ["config/orchestration-routing.json", "poetry.lock"],
      "shared_surface_globs": ["scripts/dev_tools/validate_*.py"],
      "modules": {
        "config": ["config/**"],
        "docs": ["docs/**"],
        "python-dev-tools": ["scripts/dev_tools/**"],
        "tests": ["tests/**"]
      },
      "over_breadth_fraction": 0.25
    }
  },
  "expected": {
    "radius": {
      "paths": [
        "docs/features/active/2026-08-07-example-452/**",
        "poetry.lock",
        "scripts/dev_tools/a.py"
      ],
      "modules": ["docs", "python-dev-tools"],
      "shared_surfaces": ["poetry.lock"],
      "contracts": [],
      "source": "derived",
      "computed_at": "2026-08-07T12-00"
    },
    "findings": []
  }
}
```

A companion negative fixture should pin the false-positive guard: the same plan citing `` `README.md` `` (separator-free, **not** in `shared_surfaces`) must yield a radius without it.

**Template — Gap 2 (listed directory versus glob beneath it):**

```json
{
  "description": "Listed-directory contention: one radius names a directory and the other a glob rooted at that directory. The pair provably shares files, so path_overlap must fire; the concrete entry is compared as the directory it may name, matching the coverage relation is_path_subsumed already applies.",
  "input": {
    "radius_a": {
      "paths": ["scripts/dev_tools"],
      "modules": [], "shared_surfaces": [], "contracts": [],
      "source": "declared", "computed_at": "2026-08-07T12-00"
    },
    "radius_b": {
      "paths": ["scripts/dev_tools/**"],
      "modules": [], "shared_surfaces": [], "contracts": [],
      "source": "declared", "computed_at": "2026-08-07T12-00"
    },
    "config": { "version": 1, "shared_surfaces": [], "shared_surface_globs": [],
                "modules": {}, "over_breadth_fraction": 0.25 }
  },
  "expected": {
    "conflict": true,
    "reasons": [
      { "kind": "path_overlap", "detail": "scripts/dev_tools ~ scripts/dev_tools/**" }
    ]
  }
}
```

Empty `modules` is essential in the Gap 2 fixtures: the issue notes (`issue.md:69-72`) that the coarse module map masks this defect, so the fixture must isolate the path level. A second Gap 2 fixture should use concrete×concrete (`scripts/dev_tools` vs `scripts/dev_tools/a.py`), and a third should pin the *non*-regression (`scripts/dev_toolsX/a.py` vs `scripts/dev_tools` → `conflict: false`).

Detail-string ordering caution: `_smallest_path_overlap` orders the pair ordinally before joining with `" ~ "`. `*` (U+002A) sorts before `/` (U+002F) and before all letters, so `"scripts/dev_tools"` < `"scripts/dev_tools/**"` — the detail above is correct as written.

---

## F. Bundled-mirror contract — which test, and how strict

**Enforcing test:** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 100–125).

- Scope: `SCOPED_ROOTS = (Path(".claude"),)` (line 19) — every file under `.claude/**` in the repo root.
- Exclusions: `.claude/settings.local.json` and the `.claude/agent-memory/**` subtree only (lines 112–116).
- Strictness: **content identity, not merely existence** — line 122:
  ```python
  assert read_text(BUNDLED_ROOT, relative_path) == read_text(REPO_ROOT, relative_path)
  ```
  `read_text` decodes UTF-8 (line 48), so it is text-identity, which for these ASCII `.psm1` files is equivalent to byte identity (a BOM or encoding difference would be caught; a line-ending difference would also be caught, since `read_text` does not enable universal-newline translation for comparison purposes here beyond Python's default text-mode newline handling — treat CRLF/LF consistency as required).
- `BUNDLED_ROOT = extensions/drm-copilot/resources/claude-customizations` (lines 16–18).

**Secondary, structural test:** `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1`
- Discovers `.claude/lib/blast-radius/*.psm1` **from disk** (lines 26–31), so any *new* module is automatically required to appear in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths` (line 46) and to have a bundled counterpart file (lines 63–74). Existence only, no content check.

**Consequence for this change:** every edited `.psm1` under `.claude/lib/blast-radius/` must be copied verbatim to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`. Five mirror files exist today (verified). `config/blast-radius.json` has **no** mirrored copy (verified by `Glob **/blast-radius.json` → one hit), so the config needs no mirror edit.

**If a new `.psm1` is introduced**, four extra edits are required:
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (append near lines 97–101)
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path` (append near lines 122–126)
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (identical append, lines 122–126)
- the bundled mirror file itself

---

## G. F1 spec text to amend — verbatim

Source: `docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md`

### G.1 Lines 35–50 (verbatim)

```
35:   - **V3 — Over-breadth (Advisory).** At most one Advisory finding when the radius's concrete coverage exceeds `over_breadth_fraction` (config key, initial value 0.25) of `tracked_file_count`. An over-broad radius is safe but serializes the batch.
36: 5. **The contention relation (§5.4):** `conflicts(a, b) = path_overlap OR module_overlap OR shared_surface_overlap OR contract_dependency`, failing closed (see `## Public API Contract` for exact semantics).
37:
38: ### Derivation heuristic details (research §4)
39:
40: - **Line handling.** Normalize with `text.splitlines()` in Python and the equivalent `\r\n|\r|\n` split in PowerShell, matching the plan-validator CRLF fix (commit `b845c505`, PR #437). Strip trailing carriage returns from extracted tokens defensively.
41: - **Task-line parsing.** Reuse the exact regex text of `PLAN_PHASE_RE` and `PLAN_TASK_RE` from `scripts/dev_tools/validate_orchestration_artifacts.py` in both languages so the derivation parser and the plan validator agree on what a task line is. Non-task plan lines are also scanned; task bodies are the primary signal.
42: - **Path extraction.** Extract backtick-delimited inline-code spans first; accept a token as a concrete repository path when it contains `/` and starts with a known top-level segment (`scripts/`, `tests/`, `docs/`, `config/`, `schemas/`, `packages/`, `extensions/`, `.claude/`, `.codex/`, `.github/`, `.agents/`, `artifacts/`) or matches `<segment>/.../<name>.<ext>` for a recognized extension set. Tokens containing `*` are recorded as globs in `paths`.
43: - **False-positive posture.** Over-inclusion of read-only path references is accepted; no ignore list in v1. Over-inclusion widens the radius, which errs in the fail-closed direction and is surfaced by V3 (Advisory). An ignore list is an under-reporting mechanism and under-reporting is the dominant design risk (§13.1).
44: - **V1 consistency.** Derivation and V1 share one extraction function per language (`extract_plan_paths` / `Get-PlanPaths`), so a radius produced by `derive_blast_radius` from plan P always passes V1 against P. V1's force is against hand-edited or stale `declared` radii and planner drift.
45:
46: ### Behavior semantics (research §8)
47:
48: - Derivation never fails on well-formed text inputs; a plan with zero extractable paths yields a radius containing only the feature folder. Malformed inputs (non-string, absent feature folder, unknown `source` string) raise specific exceptions / `throw` at construction (fail fast).
49: - Findings are sorted (rule, then subject) for deterministic output.
50: - `conflicts` returns all triggered reasons, not just the first, ordered `path_overlap`, `module_overlap`, `shared_surface_overlap`, `contract_dependency`.
```

### G.2 Lines 110–125 (verbatim)

```
110: #   kind: "path_overlap"|"module_overlap"|"shared_surface_overlap"|"contract_dependency"
111: #   and detail: str (the overlapping path/glob pair, module, surface, or identifier).
112: ```
113:
114: `tracked_file_count` is an input (the caller runs `git ls-files` or equivalent) so the library stays free of subprocess and filesystem I/O.
115:
116: `conflicts` semantics (§5.4, fails closed):
117:
118: - `path_overlap`: any pair from `a.paths × b.paths` overlaps. Concrete×concrete: equality. Glob×concrete: fnmatch. Glob×glob: **any pair not provably disjoint counts as overlapping** — the implementation may use a conservative shared-literal-prefix test, and when it cannot decide, it returns overlap. This is the fail-closed clause made concrete.
119: - `module_overlap`, `shared_surface_overlap`: non-empty set intersection.
120: - `contract_dependency`: non-empty intersection of `contracts` sets (v1 scope: identifier equality; a richer provides/consumes distinction is a future refinement that would only narrow, never widen, so deferring it is fail-closed).
121: - Empty-versus-empty radii do not conflict; an empty radius against a non-empty one has no overlap at any level. Under-reporting via emptiness is V1's problem at plan time and F8's at run time, not the relation's.
122: - `conflicts` returns the verdict plus **all** triggered reason kinds, ordered `path_overlap`, `module_overlap`, `shared_surface_overlap`, `contract_dependency`.
123:
124: ### PowerShell surface — `.claude/lib/blast-radius/BlastRadius.psm1`
125:
```

### G.3 Proposed amendment text (drafted against the verbatim above)

**Replace line 42** with:

> - **Path extraction.** Extract backtick-delimited inline-code spans first; accept a token as a concrete repository path when it contains `/` and starts with a known top-level segment (`scripts/`, `tests/`, `docs/`, `config/`, `schemas/`, `packages/`, `extensions/`, `.claude/`, `.codex/`, `.github/`, `.agents/`, `artifacts/`) or matches `<segment>/.../<name>.<ext>` for a recognized extension set. **A separator-free token is additionally accepted as a concrete repository path when it is an exact member of the `shared_surfaces` list in `config/blast-radius.json` (issue #452); the configured list is the sole source of separator-free acceptance, and no second hardcoded list exists.** Tokens containing `*` are recorded as globs in `paths`.

**Replace the second sentence of line 118** (`Concrete×concrete: equality. Glob×concrete: fnmatch.`) with:

> Concrete×concrete: equality, **or one entry is a listed-directory prefix of the other (`b.startswith(a.rstrip("/") + "/")`), the same rule `is_path_subsumed` applies for coverage (issue #452)**. Glob×concrete: fnmatch, **or the glob's literal prefix nests with the concrete entry's directory prefix — that is, the concrete entry is compared as though it were the glob `<entry>/**`, which reduces the case to the glob×glob rule below**.

**Add to the `## Behavior semantics` list (after line 52)**:

> - Listed-directory semantics are honoured symmetrically: a directory entry covers everything beneath it for both the coverage relation (V1) and the contention relation (`conflicts`). Comparing a concrete entry as a possible directory can over-report when the entry is in fact a file; that over-report is the same conservatism the glob×glob branch already applies and is the fail-closed direction.

Also update the F1 spec's Python surface block (line 93) to show the new keyword-only parameter, and the PowerShell surface list (lines 128–132) if `Get-PlanPaths` is documented with its parameters.

---

## H. Risk analysis — every test/fixture that asserts current behaviour

### H.1 Fixtures — **zero existing expectations change** (verified)

**Gap 1.** `poetry.lock` / `package-lock.json` / `quality-tiers.yml` appear in the corpus **only** inside `input.config.shared_surfaces`, inside `input.radius_*.shared_surfaces`, and inside `expected.reasons` details — **never inside any `plan_text` or `spec_text`** (verified by grep across all 21 files). No derived radius therefore gains a new path entry, and no `findings` list changes.

**Gap 2.** Every one of the ten `conflict-*.json` fixtures declares a **single-element** `paths` array per radius (verified). Case by case:

| Fixture | `paths` pair | Before | After |
| --- | --- | --- | --- |
| `conflict-path-overlap` | `shared.py` / `shared.py` | True (equality) | True, same detail |
| `conflict-multi-reason` | `shared.py` / `shared.py` | True | True, same detail |
| `conflict-glob-concrete` | `scripts/dev_tools/**` / `scripts/dev_tools/compute_blast_radius.py` | True (fnmatch) | True, same detail |
| `conflict-module-overlap` | `scripts/dev_tools/a.py` / `scripts/dev_tools/b.py` | False | **False** — neither is a directory prefix of the other |
| `conflict-shared-surface` | `scripts/dev_tools/a.py` / `tests/scripts/b.py` | False | **False** |
| `conflict-contract` | `scripts/dev_tools/a.py` / `tests/scripts/b.py` | False | **False** |
| `conflict-none-disjoint` | `scripts/dev_tools/alpha.py` / `docs/notes.md` | False | **False** |
| `conflict-glob-undecidable` | `scripts/*/alpha.py` / `scripts/*/beta.py` | True | True (glob×glob untouched) |
| `conflict-empty-vs-empty`, `conflict-empty-vs-nonempty` | empty side | False | **False** (no pairs) |

Because `_smallest_path_overlap` selects `min` over the pair set and every fixture has exactly one candidate pair, no `detail` string can change either.

**Conclusion:** the corpus is EXTENDED only. No fixture file needs modification. This satisfies the "extend rather than weaken" constraint outright.

### H.2 Existing tests that assert the CURRENT (defective) behaviour — must be inverted

Exactly **one** test in the repository documents a Gap 2 defect as intended behaviour:

- `tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1:309-316`
  ```powershell
  It 'does not treat a directory entry as overlapping a file beneath it' {
      $overlap = Test-EntryOverlap -EntryA 'scripts/dev_tools' -EntryB 'scripts/dev_tools/a.py'
      # Assert: the contention relation compares entries, not coverage; the
      # prefix rule belongs to subsumption only.
      $overlap | Should -BeFalse
  }
  ```
  **Verdict: INVERT.** This asserted the defect. Rename to something like `'treats a directory entry as overlapping a file beneath it'`, flip to `Should -BeTrue`, and rewrite the rationale comment to cite issue #452 and the `is_path_subsumed` alignment.

No Python counterpart exists — `_entries_overlap` has no direct pytest and `test_blast_radius_conflicts.py` contains no directory-versus-file case (verified by grep for `_entries_overlap` across `tests/**`, which matched only the PowerShell file). A Python equivalent should be **added** (see §K).

No test anywhere asserts `extract_plan_paths` drops a separator-free shared surface (verified by grep for `poetry.lock` / `package-lock` / `quality-tiers` across `tests/scripts/**`; every hit is a config or radius fixture value, none an extraction expectation). Gap 1 therefore inverts nothing.

### H.3 Existing tests that must be PRESERVED unchanged (they document correct behaviour, not the defect)

| Test | File:line | Why it survives |
| --- | --- | --- |
| `test_classify_path_token_rejects_non_path_tokens` (`"derive_blast_radius"`, `"alpha/beta"`, URLs, absolute, drive) | `test_blast_radius_extraction.py:217-230` | with the default empty `root_surfaces`, and with `derive_blast_radius` not being in any `shared_surfaces` list, all six tokens still return `None` |
| `'rejects a token with no separator'` | `BlastRadiusExtraction.Path.Tests.ps1:106-112` | same reasoning; `'derive_blast_radius'` is not a configured surface |
| `'returns nothing when no line cites a path'` (`'nor `here`'`) | `BlastRadiusExtraction.Path.Tests.ps1:153-162` | `here` is not a configured surface |
| `test_distinct_concrete_paths_do_not_overlap` (`a.py` vs `b.py`) | `test_blast_radius_conflicts.py:90-98` | neither is a directory prefix of the other |
| `test_provably_disjoint_globs_do_not_conflict`, `test_two_feature_folder_globs_do_not_conflict` | `test_blast_radius_conflicts.py:134-152` | glob×glob branch untouched |
| `'reports overlap only for equal entries'` (`a/1.py` vs `a/2.py` → False) | `BlastRadiusGlob.Tests.ps1:303-307` | unchanged; note the *first* assertion on line 305 (equal entries → True) also unchanged |
| `test_is_path_subsumed_does_not_treat_a_sibling_prefix_as_a_directory` | `test_blast_radius_extraction.py:373-375` | `is_path_subsumed` is not modified; the new `_entries_overlap` disjunct uses the same anchored `+ "/"` guard so the sibling case stays disjoint |
| `test_a_derived_radius_passes_v1_against_its_own_plan` / `..._v2_...` | `test_blast_radius_invariants.py:247-259` | preserved **only if** derivation and V1 receive the same `root_surfaces` from the same `config` — this is the single most important regression risk of Gap 1 |
| `test_widening_a_radius_never_removes_a_conflict`, `test_widening_a_disjoint_radius_can_only_create_a_conflict` | `test_blast_radius_invariants.py:158-204` | `disjoint = ["schemas/other.json"]` vs `["docs/a.md"]` — no directory relation; still False before widening |
| conflict symmetry / reason-symmetry suites | `test_blast_radius_invariants.py:124-138` | the new disjuncts are symmetric by construction (`a.startswith(dirp(b)) or b.startswith(dirp(a))`, and `_prefixes_nest` is symmetric) |
| config shape pinning (both languages) | `test_blast_radius_config.py`; `BlastRadius.Parity.Tests.ps1:302-378` | unchanged; §K proposes an additive assertion |

### H.4 Behavioural risks (non-test)

1. **Over-serialization from Gap 2.** Any plan citing a directory-shaped token (`scripts/dev_tools`, accepted today by the known-top-level-segment rule) will now contend with any item citing a glob rooted at or above that directory. Mitigation: in almost every such case the coarse `modules` map already forced a conflict (`issue.md:69-72`), so the marginal cohort serialization is small. The genuinely new cases are exactly the ones the issue names as unmasked: `artifacts/**` (accepted by extraction, absent from the module map) and deserialized radii with empty `modules`.
2. **Concrete-file-treated-as-directory over-report.** `("config/blast-radius.json", "config/*.yml")` becomes True. Accepted as fail-closed and consistent with the existing glob×glob conservatism (see §D.3). Should be recorded in the amended spec so a later reader does not treat it as a defect.
3. **V3 (over-breadth) sensitivity from Gap 1.** `_over_breadth_findings` counts `len(concrete_entries(radius.paths))`; a plan touching all three separator-free surfaces adds at most 3 concrete entries. With `over_breadth_fraction = 0.25` and realistic `tracked_file_count`, this cannot flip the committed fixtures (verified: `validation-v3-at-threshold` uses `tracked_file_count: 100`, threshold 25, and its plan cites no root surface). It is a theoretical boundary risk for hand-authored plans only.
4. **Contract/path double counting.** `extract_contract_identifiers` (`_blast_radius_extraction.py:385-387`) records *any* separator-free inline-code token inside an interface section as a `contracts` entry. After Gap 1, a spec that names `` `poetry.lock` `` inside a `## Public API Contract` section will produce that string at **both** the `paths`/`shared_surfaces` level and the `contracts` level. This is fail-closed (more overlap) and harmless, but it should be documented. Do **not** exclude root surfaces from `contracts` — that would narrow the relation and is out of the adopted scope.

---

## I. Gap 1 false-positive analysis and the recommended containment rule

### I.1 What the tokenizer does today

`extract_inline_code_tokens` (`_blast_radius_extraction.py:191-219`) is the sole token source. It:
1. matches `INLINE_CODE_SPAN_RE = re.compile(r"`([^`]+)`")` per line (line 60) — **only backtick-delimited inline code is ever considered**;
2. strips a defensive trailing `\r`;
3. splits each span on whitespace (`span.split()`), because a span may hold a whole command line.

`test_extract_plan_paths_ignores_path_references_outside_inline_code` (`test_blast_radius_extraction.py:275-279`) pins the backtick requirement. The PowerShell mirror is identical (`BlastRadiusExtraction.psm1:243-256`).

### I.2 Residual false-positive surface after the fix

The token must simultaneously (a) sit inside a backtick span, and (b) be **exactly equal** to one of three configured strings. Concretely:

| Plan/spec text | Token(s) produced | Admitted? |
| --- | --- | --- |
| ``Regenerate `poetry.lock`.`` | `poetry.lock` | yes (intended) |
| ``Run `poetry lock --no-update`.`` | `poetry`, `lock`, `--no-update` | no |
| ``Run `npm ci --package-lock-only`.`` | `npm`, `ci`, `--package-lock-only` | no |
| `Do not touch poetry.lock.` (no backticks) | none | no |
| ``Do not touch `poetry.lock`.`` | `poetry.lock` | yes — over-inclusion of a read-only reference |
| ``See `quality-tiers.yml` for tiers.`` | `quality-tiers.yml` | yes — over-inclusion |

The last two rows are the only residual class, and they are exactly the posture the F1 spec already ratified at line 43: *"Over-inclusion of read-only path references is accepted; no ignore list in v1. Over-inclusion widens the radius, which errs in the fail-closed direction."* The new rule introduces no *new kind* of false positive — it makes separator-free surfaces behave like separator-bearing ones already do.

### I.3 Recommended containment rule

**Exact, case-sensitive (ordinal) set membership in the configured `shared_surfaces` list, evaluated on tokens already constrained to backtick-delimited inline-code spans.** Specifically:

- Source the set **only** from `config["shared_surfaces"]`, filtered to entries with no `/`. From the committed `config/blast-radius.json` (lines 3–14) this is exactly `{"package-lock.json", "poetry.lock", "quality-tiers.yml"}`.
- Do **not** source from `shared_surface_globs` (all three committed entries contain `/`; a separator-free glob would be a different acceptance class and is not what the adopted resolution asks for).
- Do **not** add an extension-based fallback for separator-free tokens. Admitting "any separator-free token with a recognized extension" would swallow `README.md`, `settings.json`, `main.ts`, `pyproject.toml` and every other bare filename in prose — a large, unbounded false-positive class with no fail-closed justification, because those tokens are not shared surfaces.
- Do **not** use substring, suffix, or case-insensitive matching. `RECOGNIZED_PATH_EXTENSIONS` lowercases extensions (line 253), but surface membership must stay ordinal to match `resolve_shared_surfaces` (`_blast_radius_validation.py:334`, plain `in listed`) and the PowerShell `HashSet[string]` with `[StringComparer]::Ordinal` (`BlastRadiusConfig.psm1:408-410`). Any looser comparison here would desynchronize extraction from surface resolution.
- The classification result is `concrete`. Add a config-pinning assertion (see §K) that every separator-free `shared_surfaces` entry is wildcard-free, so the `concrete` result can never be wrong.

This is the narrowest rule that reaches all three affected surfaces, and it keeps the false-positive bias strictly inside the already-approved over-inclusion posture.

---

## J. Enabling constraint: the 500-line file-size limit

`.claude/rules/general-code-change.md` forbids any production file exceeding 500 lines. Verified current sizes:

| File | Lines | Change required | Headroom |
| --- | --- | --- | --- |
| `scripts/dev_tools/_blast_radius_extraction.py` | 494 | Gap 1 (+~20–25) | **negative** |
| `scripts/dev_tools/_blast_radius_validation.py` | 497 | `config_root_surfaces` + call site (+~25) | **negative** |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 278 | Gap 2 (+~20) | fine |
| `scripts/dev_tools/compute_blast_radius.py` | 322 | 2 call sites | fine |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 486 | Gap 1 (+~30, three param blocks + `.PARAMETER` docs) | **negative** |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | 368 | Gap 2 (+~15) | fine |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | 439 | `Get-ConfigRootSurface` (+~35) | fine |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | 362 | 1 call site | fine |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 374 | 2 call sites | fine |

Three files cannot absorb their change. The recommended relief is a **structure-aligning split, not a behaviour change**:

**Python — create `scripts/dev_tools/_blast_radius_glob.py`,** the exact counterpart of the existing `BlastRadiusGlob.psm1`. Move in (no logic edits except the Gap 2 change):
- from `_blast_radius_extraction.py`: `_glob_to_regex_text`, `matches_glob`, `is_path_subsumed` (lines 392–494, ~103 lines) → extraction drops to ~391, then +25 for Gap 1 = ~416;
- from `_blast_radius_validation.py`: `GLOB_WILDCARDS`, `is_glob_entry`, `concrete_entries` (lines 57–60, 177–202, ~34 lines) → validation drops to ~463, then +25 = ~488;
- from `_blast_radius_conflicts.py`: `_literal_prefix`, `_entries_overlap` (lines 180–228) → conflicts drops to ~230, and the Gap 2 fix lands in the new module.

Resulting `_blast_radius_glob.py` ≈ 220–240 lines. The resulting Python module set (`_blast_radius_extraction`, `_blast_radius_glob`, `_blast_radius_validation`, `_blast_radius_conflicts`, `compute_blast_radius`) becomes a near-exact structural mirror of the five PowerShell modules, which is itself a parity improvement and makes the "authoritative reference" claim in every module header easier to audit. Import graph stays acyclic: `extraction` (no deps), `glob` (no deps), `validation` (extraction, glob), `conflicts` (glob, validation), `compute_blast_radius` (all).

Validation at ~488 leaves only ~12 lines of headroom. If that is judged too tight, the fallback is to additionally create `scripts/dev_tools/_blast_radius_config.py` (counterpart of `BlastRadiusConfig.psm1`) holding `require_text` / `require_str_tuple` / `require_mapping` / `config_string_list` / `config_modules` / `config_over_breadth_fraction` / `resolve_modules` / `resolve_shared_surfaces` / `config_root_surfaces`, leaving `_blast_radius_validation.py` at ~250 lines. This is the more durable option; it costs more import-site churn.

**PowerShell — no new module needed.** Move `Get-OrdinalSortedEntry` (`BlastRadiusExtraction.psm1:84-119`, 36 lines) into `BlastRadiusGlob.psm1`, where its sibling ordinal primitive `Get-OrdinalSmallestEntry` (lines 324–358) already lives. Then:
- `BlastRadiusExtraction.psm1` adds `Import-Module … BlastRadiusGlob.psm1` (Glob imports nothing, so no cycle) and **re-exports** `Get-OrdinalSortedEntry` in its `Export-ModuleMember` list, keeping every existing call site and every existing test (`BlastRadiusExtraction.Tests.ps1`, `BlastRadiusConfig.psm1`, `BlastRadiusValidation.psm1`, `BlastRadius.psm1`) source-compatible.
- Net: 486 − 36 + 1 + 30 ≈ 481 lines. `BlastRadiusGlob.psm1` → 368 + 36 + 15 ≈ 419.

Avoiding a new `.psm1` avoids four extra coupled edits (`core.json`, two `pester.runsettings.psd1` copies, the bundled mirror) and keeps the `BlastRadius.Manifest.Tests.ps1` disk-discovery assertion satisfied without change.

---

## K. Test strategy (no test code written here)

Consistent with `.claude/rules/general-unit-test.md` and `.claude/rules/python.md` / `.claude/rules/powershell.md`. All additions are extensions; the only modification is the single inversion in §H.2.

**Gap 1 — extraction**
- Python `tests/scripts/dev_tools/test_blast_radius_extraction.py`: parametrized positive cases for each of the three committed separator-free surfaces through `classify_path_token(token, root_surfaces=(...))` → `PATH_KIND_CONCRETE`; negative cases for a separator-free token **not** in the set (`README.md`, `pyproject.toml`, `derive_blast_radius`) → `None`; a default-argument case proving `classify_path_token(token)` with no `root_surfaces` still returns `None` (backward compatibility); prose-without-backticks case → `()`; a case-variant case (`Poetry.Lock`) → `None` (ordinal membership).
- Python `test_blast_radius_validation.py`: V2 now fires for a hand-authored declared radius omitting `poetry.lock` while the plan cites it — the behaviour the issue names as the consumer-visible payoff.
- Python `test_blast_radius_invariants.py`: extend `PLANS` with a plan citing a separator-free surface so the existing V1/V2 self-consistency and determinism suites cover the new path with no new test bodies.
- PowerShell `BlastRadiusExtraction.Path.Tests.ps1`: the same positive/negative/default matrix against `Get-PathTokenKind -RootSurface`.
- PowerShell `BlastRadiusConfig.Tests.ps1`: `Get-ConfigRootSurface` returns exactly the separator-free subset, sorted ordinally, and `@()` for a config with no `shared_surfaces`.

**Gap 2 — contention**
- Python (new direct coverage in `test_blast_radius_conflicts.py`, since none exists): concrete directory vs file beneath it → True; concrete directory vs `dir/**` → True; concrete directory vs `scripts/*/a.py` → True (the two-way-nest necessity case); sibling-prefix `scripts/dev_toolsX/a.py` vs `scripts/dev_tools` → False; `a.py` vs `b.py` → False (regression guard); trailing-slash `scripts/dev_tools/` normalisation.
- PowerShell `BlastRadiusGlob.Tests.ps1`: the same matrix, plus the **inverted** `It` from §H.2.
- Monotonicity invariant (both languages): assert that for a fixed pair set, no pair reported as overlapping before the change is reported as non-overlapping after — expressed as a parametrized table of the historically-True pairs listed in §H.1.

**Corpus (both languages, automatic pickup)**
- Add the four fixtures sketched in §E.4: one Gap 1 positive, one Gap 1 negative, one Gap 2 concrete×glob, one Gap 2 concrete×concrete, plus one Gap 2 non-regression (`conflict: false`). Consider raising `MINIMUM_FIXTURE_COUNT` / `$minimumFixtureCount` from 12 to the new total in both drivers so the anti-vacuity floor tracks the corpus.

**Config pinning (both languages)**
- Add one assertion to `tests/scripts/dev_tools/test_blast_radius_config.py` and the mirrored `Describe 'Committed blast-radius truth table shape'` in `BlastRadius.Parity.Tests.ps1`: every separator-free `shared_surfaces` entry must be wildcard-free, so a configured root surface can never classify as a glob.

**Mirror contract**
- No new test needed; `test_push_down_claude_resource_contracts.py` already fails if any `.claude/lib/blast-radius/*.psm1` edit is not mirrored.

**Toolchain**
- Python: Black → Ruff → Pyright → `pytest --cov --cov-branch`. Coverage floors (85% line / 75% branch) apply to the new `_blast_radius_glob.py` as a production module.
- PowerShell: `run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. All five modules are already in `CodeCoverage.Path` (lines 122–126); no settings edit is required unless a new `.psm1` is created.

---

## L. Rejected implementation alternatives (brief)

- **One-way prefix test for concrete×glob** (`_literal_prefix(glob).startswith(dir + "/")` only). Rejected: it under-reports `("scripts/dev_tools", "scripts/*/a.py")`, which genuinely overlaps because `*` fills `dev_tools`. Under-reporting is a fail-closed violation and is precisely the defect class this issue exists to remove.
- **Blanket rewrite of every concrete entry as `<entry>/**` before comparison.** Rejected: it discards the exact `Glob×concrete: fnmatch` decision the spec fixes at line 118, turning e.g. `("scripts/dev_tools/a.py", "scripts/*.py")` into a false positive for no fail-closed benefit. The additive disjunct preserves exact matching and only widens.
- **Extension-based acceptance of separator-free tokens** (accept any bare filename with a recognized extension). Rejected: unbounded false-positive class (`README.md`, `settings.json`, every bare filename in prose) with no shared-surface justification; see §I.3.
- **A second hardcoded list of root surfaces in the extraction module.** Rejected explicitly by adopted resolution 1, and independently by the drift risk: a second list would silently desynchronize from `config/blast-radius.json`, which is itself an enumerated shared surface.
- **Excluding configured root surfaces from `extract_contract_identifiers`.** Rejected: it narrows the contention relation, is outside the adopted scope, and the double-count it would prevent is harmless and fail-closed (§H.4 item 4).

---

## M. Summary of required file changes

**Production (Python)**
1. `scripts/dev_tools/_blast_radius_glob.py` — new; receives the moved glob/subsumption/overlap primitives and the Gap 2 fix.
2. `scripts/dev_tools/_blast_radius_extraction.py` — Gap 1 (`classify_path_token`, `extract_paths_from_lines`, `extract_plan_paths` keyword-only `root_surfaces`); glob helpers moved out.
3. `scripts/dev_tools/_blast_radius_validation.py` — new `config_root_surfaces`; line 368 passes it; `is_glob_entry` / `concrete_entries` moved out.
4. `scripts/dev_tools/_blast_radius_conflicts.py` — `_literal_prefix` / `_entries_overlap` moved out; imports updated.
5. `scripts/dev_tools/compute_blast_radius.py` — lines 251–252 pass `root_surfaces`; re-export set updated if the module split changes import origins.

**Production (PowerShell, each mirrored byte-for-byte under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`)**
6. `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` — Gap 1 `-RootSurface`; `Get-OrdinalSortedEntry` moved out and re-exported.
7. `.claude/lib/blast-radius/BlastRadiusGlob.psm1` — Gap 2 in `Test-EntryOverlap`; receives `Get-OrdinalSortedEntry`.
8. `.claude/lib/blast-radius/BlastRadiusConfig.psm1` — new `Get-ConfigRootSurface`.
9. `.claude/lib/blast-radius/BlastRadiusValidation.psm1` — line 348 passes `-RootSurface`.
10. `.claude/lib/blast-radius/BlastRadius.psm1` — lines 162–163 pass `-RootSurface`.

**Docs**
11. `docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md` — amend lines 42, 118, and the behavior-semantics list (§G.3).
12. `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/spec.md` — populate from this research.

**Tests and fixtures** — per §K; the only *modification* to an existing expectation is `BlastRadiusGlob.Tests.ps1:309-316`.

**Not changed:** `config/blast-radius.json` (no new key; the existing `shared_surfaces` list is the source), `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `.claude/skills/atomic-plan-contract/SKILL.md`.
