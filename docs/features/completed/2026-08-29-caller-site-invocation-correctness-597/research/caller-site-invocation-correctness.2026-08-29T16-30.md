# Research: caller-site-invocation-correctness (Issue #597)

- Date: 2026-08-29T16-30
- Scope: re-verification of current-tree facts named in the epic and in `issue.md`/`spec.md`. This
  is a scoped bug fix; no alternative-approach comparison is warranted (single mechanical
  correction, applied identically at three call sites).

## 1. Current state of the three call sites (line numbers have drifted from the epic/issue text)

`issue.md`/`spec.md` (as promoted) cite `parallel-plan/SKILL.md:185`, `parallel-add/SKILL.md:64`,
and `parallel-planner.md:151`. Re-reading the live files on this branch shows **two of the three
line numbers have drifted**; the plan/spec authors must use the numbers below, not the promoted
issue text.

### `.claude/skills/parallel-plan/SKILL.md` — Import-Module is at line **183**, not 185

```
176	## Radius Computation and Validation
177	
178	Reach blast-radius derivation, validation, and contention through the **destination-runtime
179	PowerShell port** under `.claude/lib/blast-radius/`, which is published by push-down and needs no
180	Python interpreter:
181	
182	```powershell
183	Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force
184	```
185	
186	The facade re-exports the five functions this skill needs: `Get-PlanPaths` (port of
```

The statement is inside a fenced ```` ```powershell ```` block opened at line 182 and closed at
line 184; the instruction itself is line 183.

### `.claude/skills/parallel-add/SKILL.md` — Import-Module is at line **62**, not 64

This site is inline prose (parenthetical), not a fenced code block:

```
59	3. **Compute conflict edges over ALL items, including in-flight ones.** Invoke the contention
60	   relation `Test-BlastRadiusConflict` from the destination-runtime PowerShell port
61	   `.claude/lib/blast-radius/BlastRadius.psm1`, which is published by push-down and needs no Python
62	   interpreter (`Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force`). Its two radius
63	   arguments are the two items' radius hashtables, not strings, and the third argument is the
64	   required parsed `config/blast-radius.json` mapping, which push-down publishes into the
```

### `.claude/agents/parallel-planner.md` — Import-Module is at line **151** (matches the issue text)

```
147	**Blast radius — PowerShell port.** Radius derivation, V1-V3 validation, and the contention
148	relation come from `.claude/lib/blast-radius/BlastRadius.psm1`:
149	
150	```powershell
151	Import-Module .claude/lib/blast-radius/BlastRadius.psm1 -Force
152	```
153	
154	The facade exports `Get-PlanPaths`, `Get-BlastRadius`, `Get-BlastRadiusFromObservedPaths`,
```

**Action for the spec/plan:** correct the two drifted line references (185→183, 64→62) before
citing them in acceptance criteria. The `parallel-add/SKILL.md` site is a parenthetical inline
sentence fragment, not a standalone fenced block — the fix at that site must preserve the
parenthetical prose form, e.g. by fixing the quoted command text without disrupting the sentence
structure, rather than dropping in a multi-line code fence.

## 2. Existing truthiness warnings — both confirmed present, but one line range in the issue text is off by 3

### `.claude/lib/blast-radius/BlastRadius.psm1:432-441` — confirmed, matches issue text exactly

```
428	    .OUTPUTS
429	        System.Collections.Hashtable. Keys conflict (a boolean) and reasons (an
430	        array of hashtables with keys kind and detail).
431	
432	        Read the verdict from the conflict key of the returned hashtable.
433	        Do not test the returned object itself: the hashtable is
434	        unconditionally truthy under PowerShell boolean coercion, so
435	        'if ($result)' treats every pair as contending.
436	        System.Collections.Hashtable implements IDictionary and ICollection but
437	        not IList, and the count-based truthiness rule applies only to IList
438	        implementations, so a hashtable falls under the rule for any other
439	        non-collection type and is always $true. The Python port agrees with its
440	        own verdict; this mirror provably cannot, because PowerShell exposes no
441	        hook by which a type can decline or change the conversion.
```

### `.claude/skills/parallel-plan/SKILL.md` sibling warning — actual lines **307-311**, not 310-314

The issue/spec text cites `310-314`; the current text is:

```
304	1. Invoke `compute-cohorts.sh` exactly once per plan run, over the full conflict graph, after every
305	   item is `prepared` and radius-validated. Derive the conflict edge set by applying
306	   `Test-BlastRadiusConflict` to every unordered pair of `declared` radii, then pass the pairs as
307	   `--edges "<a>:<b> ..."` and the item keys as `--keys "<k1> <k2> ..."`.
308	   Read the verdict from the conflict key of the returned hashtable.
309	   The hashtable itself is always truthy, so a bare boolean test on the result treats every pair as
310	   conflicting and serializes the whole run. This is the sibling hazard to the `@(...)` warning
311	   above for `Test-BlastRadius`: that function writes an `IList`-shaped pipeline result whose
312	   emptiness is falsy, while this one returns a hashtable whose emptiness is not expressible at all.
```

The warning prose itself ("Read the verdict from the conflict key... hashtable itself is always
truthy...") runs lines 307-311 (the numbered list item's sentence content), not 310-314. This
warning must not be edited or regressed by Feature C's changes — it is cited, not modified.

## 3. Bundle mirror parity

The bundle mirrors exist at:

- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`

Direct read of each mirror at the corresponding line ranges confirms **byte-identical** content to
the repo counterpart, including the drifted line numbers noted above (the mirror's Import-Module
lines are also at 183 / 62 / 151, and the sibling warning is also at 307-311 in the mirror). Six
files total need edits (three repo + three mirror), consistent with `issue.md`'s statement.

The enforcing test is `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`,
function `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 101-126):

```python
101	def test_bundled_claude_payload_contains_all_repo_runtime_contracts() -> None:
102	    """Require every non-memory repo `.claude` file to exist in the bundle.
103	
104	    Excludes settings.local.json and the `.claude/agent-memory/**` subtree.
105	    Agent memories are distributed by scope (general memories live in the
106	    bundle but not at the gitignored root), so they are not subject to the
107	    byte-identical mirror assertion.
108	    """
109	
110	    bundled_files = list_scoped_files(BUNDLED_ROOT)
111	    # Enumerate repo .claude files, excluding the local-only settings file and
112	    # the scope-filtered agent-memory subtree.
113	    repo_runtime_files = [
114	        f
115	        for f in list_scoped_files(REPO_ROOT)
116	        if f != Path(".claude/settings.local.json") and not _is_agent_memory_path(f)
117	    ]
118	
119	    for relative_path in repo_runtime_files:
120	        assert (
121	            relative_path in bundled_files
122	        ), f"Repo file missing from bundle: {relative_path}"
123	        assert read_text(BUNDLED_ROOT, relative_path) == read_text(
124	            REPO_ROOT,
125	            relative_path,
126	        ), f"Bundle content differs from repo for: {relative_path}"
```

This is a whole-file byte-equality assertion (not line-scoped), so any edit to a repo `.claude/**`
file requires the identical edit landed in the bundle mirror in the same PR or this test fails.

## 4. Feature A's prepared convention — folder does not exist yet on this branch

Searched `docs/features/active/**` for a folder matching
`blast-radius-powershell-calling-convention` or the issue placeholder `901`: no feature folder
exists. The only hits for those search terms are the epic manifest itself and this feature's own
`issue.md`/`spec.md` (which reference Feature A as a dependency, not a fanned-in feature).
**Feature A has not fanned in on this branch as of this research pass.**

Per the escalation rule, the expected convention is described from the epic manifest text
(`docs/features/epics/claude-runtime-portability/epic.md`, approx. lines 80-115) instead of an
assumed/invented convention:

```
80	### Feature A (901, wave 0, C3) — Blast-radius PowerShell calling-convention hardening
81	
82	Establishes the fail-fast import convention for the shared `.claude/lib/**` modules and corrects the
83	JSON date-coercion hazard at the parse sites that actually exist.
84	
85	Verified scope inputs:
86	
87	- **Confirmed.** No file under `.claude/lib/**` (37 files across nine subdirectories) sets
88	  `$ErrorActionPreference`. It appears only in `.claude/hooks/*.ps1`. The fail-fast import guard is
89	  genuine, unambiguous work.
90	- **Corrected.** `.claude/lib/blast-radius/BlastRadiusValidation.psm1:124` delegates to
91	  `Get-RequiredText` (`BlastRadiusConfig.psm1:52-94`), which enforces a **non-empty** string, not
92	  merely a string: it throws `"computed_at must be a string, got <Type>."` on a type mismatch and
93	  `"computed_at must not be empty."` on whitespace.
94	- **Corrected.** The premise that `-DateKind` is used nowhere is false, and the premise that a
95	  `-DateKind String` helper is needed by "every JSON parse touching a radius object" has no call
96	  sites. No module under `.claude/lib/blast-radius/` calls `ConvertFrom-Json` at all; those modules
97	  operate on an already-parsed mapping supplied by the caller. `-DateKind String` is already used
98	  correctly on the test side at `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1:318`,
99	  with an explanatory comment at lines 314-316. The real production exposure is the checkpoint parse
100	  at `.claude/lib/orchestrator-state/OrchestratorState.psm1:175`, with
101	  `.claude/lib/hook-payload/HookPayload.psm1:262` and
102	  `.claude/lib/discovery-validation/DiscoveryValidation.psm1:338` as the other two `ConvertFrom-Json`
103	  sites under `.claude/lib/**`. Feature A retargets the date-coercion work to those sites.
104	- **Corrected — already satisfied.** The `if ($result)` truthiness hazard is already pinned by a
105	  regression test. `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:87-108`
106	  asserts `$result['conflict']` is `$false` while `[bool]$result` is `$true`, and a companion test at
107	  lines 110-118 asserts the comment-based help documents the divergence. The warning text at
108	  `.claude/lib/blast-radius/BlastRadius.psm1:432-441` is present as described. This item is a
109	  verification-only acceptance criterion; no new test is required unless preparation finds a gap the
110	  existing pair does not cover.
111	
112	**Complexity C3.** Signal `cross_module_contract_change`: changing JSON date coercion at the
113	checkpoint parse site alters a value contract consumed across module boundaries, and adding a
114	fail-fast preference to shared library modules changes error propagation for every caller.
```

Feature A's own scope is a fail-fast `-ErrorAction Stop` **import guard added to `.claude/lib/**`
modules themselves** (i.e., inside the `.psm1`/library files that import their own sibling
modules), plus a JSON date-coercion fix at three specific `ConvertFrom-Json` call sites
(`OrchestratorState.psm1:175`, `HookPayload.psm1:262`, `DiscoveryValidation.psm1:338`). It does not
touch skill/agent prose call sites at all — those are Feature C's exclusive territory. The epic
text explicitly states the truthiness-hazard warning in `BlastRadius.psm1:432-441` is already
correct and "verification-only," which corroborates finding #2 above (do not modify that warning).

**Implication for Feature C's spec:** because Feature A's fanned-in spec does not exist yet, Feature
C's spec should cite the epic manifest passage above (not an invented "Feature A's spec says X")
and should independently justify its own `-ErrorAction Stop` / `pwsh` / root-anchored-path
correction at the three prose call sites, since that correction is Feature C's own scope, not
something it inherits verbatim from Feature A's convention (Feature A's `-ErrorAction Stop` guard
is inside library modules; Feature C's is at prose invocation instructions — related but distinct
call sites).

## 5. `-DateKind` / JSON date-coercion is out of scope for issue #597 — confirmed

None of the three call sites, nor `BlastRadius.psm1`, nor any module under
`.claude/lib/blast-radius/**`, calls `ConvertFrom-Json` (confirmed by the epic manifest text quoted
above and independently by inspection — the three sites under correction are pure `Import-Module`
invocations with no JSON parsing involved). Issue #597 concerns only the `Import-Module` invocation
form (host qualifier, path anchoring, `-ErrorAction Stop`, and the `$result['conflict']` read
pattern which is a truthiness/hashtable-key concern, not a JSON date type concern). The spec for
#597 should state explicitly that JSON date-coercion is out of scope and belongs to Feature A, to
guard against scope creep during implementation.

## 6. Root-anchored path form — no existing precedent covers prose (markdown) invocation sites; open question for the spec

Searched all `Import-Module` invocations under `.claude/**` (script and markdown). Two patterns
exist among `.ps1`/`.psm1` files, and one weaker precedent exists among markdown skill files:

- **Dominant script pattern** (`.claude/lib/**/*.psm1`, `.claude/hooks/*.ps1` — the large majority
  of the ~70 call sites found): `Import-Module (Join-Path -Path $PSScriptRoot -ChildPath
  '<Sibling>.psm1') -Force`, e.g. `.claude/lib/blast-radius/BlastRadius.psm1:54-58`,
  `.claude/hooks/enforce-mermaid-validation.ps1:62`, `.claude/hooks/enforce-discovery-artifact-gate.ps1:66-72`.
  This pattern anchors to the *importing script's own directory* via `$PSScriptRoot`, which is not
  directly transferable to a markdown prose instruction — there is no script file, hence no
  `$PSScriptRoot`, at the three defect sites.
- **`-ErrorAction Stop` co-occurs with the `$PSScriptRoot`-anchored form** at
  `.claude/hooks/enforce-mermaid-validation.ps1:83`, `.claude/hooks/enforce-discovery-artifact-gate.ps1:72`,
  and `.claude/hooks/validate-discovery-artifact-gate.ps1:73` — all guarded by an existence check
  (`Test-Path`) before the import in the mermaid case, so the pattern for hardened imports in this
  repo is: resolve path, optionally check existence, then `Import-Module -Name <path> -Force
  -ErrorAction Stop`.
- **Only prose precedent found**: `.claude/skills/mermaid-diagram/SKILL.md:28` —
  `Import-Module ./.claude/lib/mermaid/MermaidValidation.psm1 -Force`. This is a repo-root-relative
  path with an explicit `./` prefix (assumes cwd = repository root), not an absolute path and not
  `-ErrorAction Stop`-qualified. It is the same underlying assumption as the three defect sites
  (repo-root-relative, cwd-dependent) — it is not itself a corrected/hardened example, and citing it
  as "the prevailing pattern to match" would import the same defect class this issue is fixing.

**Conclusion:** there is no existing hardened, root-anchored `Import-Module` convention in this
repository for markdown prose instruction sites (only for `.ps1`/`.psm1` script files, where
`$PSScriptRoot` is available and does not apply here). The spec/plan for #597 must define what
"root-anchored" concretely means for a prose instruction aimed at an agent invoking `pwsh` from an
unknown working directory — the two candidate forms observed in the codebase are (a) an absolute
path constructed from a known repo-root discovery expression (e.g., `git rev-parse --show-toplevel`
piped into `pwsh -Command`, since no `$PSScriptRoot`-equivalent exists for prose), or (b) an
explicit instruction to `cd` or otherwise establish the repository root as the working directory
before running the repo-root-relative path already in use. Because Feature A's spec (which could
have settled this by precedent) does not exist yet, this is an open scoping decision for #597's
spec authors, not a re-derivable fact from the current tree.

## 7. Automation Feasibility

Not applicable. This is a documentation/instruction-text-only correction (three markdown files plus
their three byte-identical bundle mirrors); no third-party UI is involved. No `## Automation
Feasibility` section is required for this research note.

## Testing Implications

- No production test code is added or changed; this is a prose-only correction.
- The existing `test_bundled_claude_payload_contains_all_repo_runtime_contracts` test (quoted in
  §3) is the enforcement mechanism for the mirror-parity requirement and must pass after all six
  edits land together.
- The existing `BlastRadius.Conflict.Tests.ps1` regression pair (`tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:87-118`,
  per the epic manifest quoted in §4) already pins the `$result['conflict']` truthiness hazard at the
  library level and must remain green; it is not modified by this feature.
- Verification for the prose corrections themselves should be a literal-token search (as `issue.md`
  already proposes) confirming the corrected invocation text — including `pwsh`, the resolved
  root-anchored path form, `-ErrorAction Stop`, and the `$result['conflict']` read — is present at
  each of the six files (three repo + three mirror), plus a confirmation that the un-cited/adjacent
  content (the two existing truthiness warnings in §2, and the out-of-scope `parallel_lane_assertion`
  line at `parallel-plan/SKILL.md:317`) is unchanged.

## Summary of drift found vs. the promoted issue/spec text

| Item | Issue/spec text | Current tree |
|---|---|---|
| `parallel-plan/SKILL.md` Import-Module line | 185 | **183** |
| `parallel-add/SKILL.md` Import-Module line | 64 | **62** |
| `parallel-planner.md` Import-Module line | 151 | 151 (unchanged) |
| `parallel-plan/SKILL.md` sibling warning lines | 310-314 | **307-311** |
| `BlastRadius.psm1` warning lines | 432-441 | 432-441 (unchanged) |
| Feature A feature folder | assumed dependency | **does not exist yet** |
