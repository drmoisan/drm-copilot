# 2026-09-30-blast-radius-path-extractor-misses-real-plan-writes (Plan)

- **Issue:** #797
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T21-00
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug (resolved from the `- Work Mode: full-bug` marker in issue.md)
- **Branch:** bug/blast-radius-path-extractor-misses-real-plan-writes-797; every scope or diff check of this plan's own changes is anchored to the HEAD SHA recorded in P0-T3, never to origin/main (see "Execution context and diff anchor" below).
- **Feature folder (written `<FEATURE>` below):** docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797
- **Requirements sources:** spec.md (authoritative; 19 acceptance criteria, numbered AC-1 to AC-19 below in spec order), issue.md, research/research.2026-10-08T17-27.md

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Every evidence-producing task names its artifact. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; an expected-fail artifact also carries `ExpectedExitCode: 1`. Evidence lives only under `<FEATURE>/evidence/<kind>/` with kinds `baseline`, `regression-testing`, `qa-gates`, and `other`. `<ts>` in an artifact name is the `yyyy-MM-ddTHH-mm` timestamp of the run. Machine-readable tool outputs (coverage JSON, JaCoCo XML, and the one-line base-SHA file written by P0-T3) are written to the fixed evidence names given in the commands and carry no artifact header. No artifact contains an absolute filesystem path. A pytest condition stating `0 failed` means the final summary line contains neither `failed` nor `error` (pytest omits zero counts).

**Command routes:** Python commands run from the worktree root through `poetry run`. Tasks that say "in the PowerShell tool" run their command text in the executor's PowerShell tool from the worktree root. PoshQC MCP tools (`mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`) return only an `ok` flag and no output text, so no count or percentage is ever read from them; every count and percentage in this plan comes from a direct Pester, PSScriptAnalyzer, or pytest invocation. No task runs git fetch, git pull, git rebase, or git merge.

**Execution context and diff anchor:** before execution begins, the orchestrator commits and pushes the feature folder (issue.md, spec.md, the research note, and this plan) and the promoted lifecycle record to the branch, and may rebase the branch onto a newer origin/main. At P0-T3 the working tree is therefore expected to be clean and spec.md is tracked. P0-T3 records the HEAD SHA at execution start and writes it, alone on one line, to the base-SHA file docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt. Every later `git diff` that checks this plan's own changes names "the SHA recorded in P0-T3" and runs in the PowerShell tool with the concrete operand `(Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt)`, so neither a moving origin/main nor a rebase between preparation and execution changes what the check compares against. No task writes the base-SHA file after P0-T3.

**AC check-off rule (acceptance-criteria-tracking skill):** AC-n is the n-th checkbox item of the spec's `## Acceptance Criteria` section. As soon as every task in an AC's Tests column of the Acceptance Criteria Traceability table has passed, the executor checks that AC in spec.md at that point, changing only its `- [ ]` to `- [x]` and no other character. An AC whose evidence is PARTIAL or missing stays unchecked. If a later loop pass re-runs a verifying task and it fails, the executor reverts that AC to `- [ ]` until the task passes again. P8-T7 reconciles the checkboxes at close-out.

**Issue #510 guard:** the bundled-resource contract test (tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py) fails whenever a batch-budget state file exists under the gitignored .claude/state directory. Every task that runs that test first runs the P0-T6 listing command; a non-zero count stops the task and returns to the orchestrator for a reset decision. This plan never deletes state files and never edits hook files.

## Scope Notes (locked by spec.md)

- In scope: replace the extension allowlist in the Python authority (classify_path_token) and the PowerShell port (Get-PathTokenKind) with a final-component file-shape predicate plus a closed known-name set held in the token-shape leaf modules; byte-identical bundled mirrors; the parallel-orchestration rules documentation and its mirror; unit, regression, parity, and fixture updates in both runtimes.
- Out of scope (spec "Scope & Non-Goals"): the separator rule; an independent V1 cross-check; the mandate-read exclusion of the agents skills tree; rules W1-W6, path_roots, mandate_reads, mergeable_paths; both copies of the blast-radius config JSON; the core pack manifest; the TypeScript push-down module-map code; any bash or Codex port. These files are named here without inline-code formatting on purpose so that radius derivation does not record them.
- Policy documents: spec.md "In scope" and "Documentation" explicitly name `.claude/rules/parallel-orchestration.md` and its bundled mirror (verified at P0-T2). No other file under the rules or instructions trees is edited.
- File-size limit: every production and test file stays at or below 500 lines. The Python extraction module and the PowerShell extraction module only lose lines (the allowlist blocks are deleted); the new logic goes into the two leaf modules. The PowerShell path test file takes in-place edits only.
- Tests create no temporary files; fixtures are committed and read in place.
- Commit, push, and PR authoring are performed by the orchestrator after this plan completes; no task in this plan commits.

## Blast-Radius Declaration Notes (for the parallel run planner)

- Every repository file this plan writes is named in a write-verb task as a single-word inline-code span and again in the "Files Written" inventory below.
- `.claude/rules/parallel-orchestration.md` is matched by the configured mandate-read pattern for the rules tree, so derivation drops it. The run planner must append that exact path to this item's declared radius after normalization (rules doc, "Known false negatives", mitigation 1).
- P4-T5 through P4-T9 are conditional writes. They are listed in the inventory so the declared radius covers them; they are written only when P4-T1 through P4-T3 show that a pin moved.

## Fixed Literals

The literals below are the single source for later tasks and assertions. They are written in fenced blocks without inline-code markers so that radius derivation does not record them.

FL-1 — classifier tokens that must classify as `concrete` after the fix (pytest id, then token):

```text
bats              tests/shell/foo.bats
cjs               extensions/drm-copilot/jest.config.cjs
out               tests/out/run.out
agents-bats       .agents/skills/x/refs/foo.bats
shellcheckrc      .claude/lib/x/.shellcheckrc
dockerfile        .devcontainer/codespaces/Dockerfile
bats-line-suffix  tests/shell/parallel_lane_assertion.bats:12
```

FL-2 — false-positive guard tokens that must still classify as None / $null (pytest id, then token):

```text
directory-extension         extensions/drm-copilot
directory-scripts           scripts/dev_tools
directory-trailing-slash    .claude/rules/
dot-directory-bundle        extensions/drm-copilot/resources/claude-customizations/.claude
dot-git                     good_wt/.git
version-ref                 release/v1.2.0
action-version              actions/setup-node@v4.0.2
branch-ref                  origin/main
url                         https://x/y.md
drive                       C:/x.md
absolute                    /etc/hosts
dotted-module               scripts.dev_tools._blast_radius_extraction
bare-glob                   Sample.*
bare-readme                 README.md
bare-pyproject              pyproject.toml
```

FL-3 — predicate cases (id, component, expected). The non-ASCII case is U+00E9; Python builds it as `"notes." + chr(0xE9)` and PowerShell builds it as `'notes.' + [char]0xE9`, so neither test file contains a non-ASCII byte (checked in P2-T3 and P3-T3).

```text
letter-led-extension     parallel_lane_assertion.bats   True
uppercase-extension      Main.TS                        True
multi-dot-name           jest.config.cjs                True
alphanumeric-extension   Thing.psd1                     True
known-name               Dockerfile                     True
known-dotfile            .shellcheckrc                  True
empty-string             (empty string)                 False
lone-dot                 .                              False
trailing-dot             beta.                          False
dot-leading-unknown      .claude                        False
digit-led-extension      v1.2.0                         False
hyphenated-extension     archive.tar-gz                 False
non-ascii-extension      notes.(U+00E9)                 False
known-name-case-variant  dockerfile                     False
extensionless-unknown    thing                          False
```

FL-4 — exact content of the new shared fixture. The six-character JSON escapes \u0060 appear only because this plan must not contain a backtick inside a fenced block. The fixture file may hold either the escape or a literal backtick; both parse to the same plan_text.

```json
{
  "description": "File-shape recognition (issue #797). Write-task citations of files whose final component carries a letter-led extension outside the former allowlist, a known dotfile, or a known extensionless file name are recorded; a dot-directory and a directory cited in the same plan stay rejected.",
  "input": {
    "plan_text": "### Phase 1 — Work\n- [ ] [P1-T1] Update \u0060tests/shell/parallel_lane_assertion.bats\u0060 and \u0060extensions/drm-copilot/jest.config.cjs\u0060.\n- [ ] [P1-T2] Write \u0060tests/fixtures/cleanup_worktrees/scenarios/scan_roots_derived/worktree-list.out\u0060 and \u0060packages/mcp-server/.gitignore\u0060.\n- [ ] [P1-T3] Edit \u0060.devcontainer/codespaces/Dockerfile\u0060 and \u0060scripts/dev_tools/compute_blast_radius.py\u0060.\n- [ ] [P1-T4] Update \u0060extensions/drm-copilot/resources/claude-customizations/.claude\u0060 and \u0060scripts/dev_tools\u0060.\n",
    "spec_text": "",
    "feature_folder": "2026-10-08-file-shaped-tokens-797",
    "computed_at": "2026-10-08T12-00",
    "tracked_file_count": 100,
    "config": {
      "version": 1,
      "shared_surfaces": [
        "config/orchestration-routing.json",
        "quality-tiers.yml"
      ],
      "shared_surface_globs": [
        "scripts/dev_tools/validate_*.py"
      ],
      "modules": {
        "config": [
          "config/**"
        ],
        "python-dev-tools": [
          "scripts/dev_tools/**"
        ],
        "tests": [
          "tests/**"
        ]
      },
      "over_breadth_fraction": 0.25,
      "write_intent_extraction": true,
      "path_roots": [
        ".devcontainer",
        "extensions",
        "packages",
        "scripts",
        "tests"
      ]
    }
  },
  "expected": {
    "radius": {
      "paths": [
        ".devcontainer/codespaces/Dockerfile",
        "docs/features/active/2026-10-08-file-shaped-tokens-797/**",
        "extensions/drm-copilot/jest.config.cjs",
        "packages/mcp-server/.gitignore",
        "scripts/dev_tools/compute_blast_radius.py",
        "tests/fixtures/cleanup_worktrees/scenarios/scan_roots_derived/worktree-list.out",
        "tests/shell/parallel_lane_assertion.bats"
      ],
      "modules": [
        "python-dev-tools",
        "tests"
      ],
      "shared_surfaces": [],
      "contracts": [],
      "source": "derived",
      "computed_at": "2026-10-08T12-00"
    },
    "findings": []
  }
}
```

FL-5 — expected baseline reproduction output (one line per token, in command order):

```text
tests/shell/foo.bats None
extensions/drm-copilot/jest.config.cjs None
tests/out/run.out None
.agents/skills/x/refs/foo.bats None
.claude/lib/x/.shellcheckrc None
Sample.* None
tests/fixtures/Sample.* glob
.agents/skills/x/SKILL.md concrete
tests/Sample.cs concrete
```

FL-6 — residual and contract-change tokens: the dotted-directory residual is src/TaskMaster.Domain (expected `concrete` in both runtimes); the Python contract-change token is alpha/beta.unknownext; the PowerShell contract-change token is weird/thing.unknownext.

FL-7 — Python names added to the leaf module (exact spellings): `FILE_EXTENSION_PATTERN_TEXT` with the value "[a-z][a-z0-9]*"; `FILE_EXTENSION_RE = re.compile(FILE_EXTENSION_PATTERN_TEXT)`; `KNOWN_FILE_NAMES: frozenset[str] = frozenset((...).split())` built from double-quoted string segments exactly like the vocabulary constants in the write-intent module; `def is_file_shaped_component(component: str) -> bool`. PowerShell names: `$script:FileExtensionPatternText = '[a-z][a-z0-9]*'`; `$script:FileExtensionPattern = [regex]::new('\A' + $script:FileExtensionPatternText + '\z')`; `$script:KnownFileName` as `[System.Collections.Generic.HashSet[string]]` with `[StringComparer]::Ordinal`; exported function `Test-FileShapedComponent` with mandatory parameter `-Component` carrying `[AllowEmptyString()]`.

FL-8 — the 18 known file names (spec "Design summary", condition 2), in this order:

```text
Dockerfile Makefile LICENSE CODEOWNERS NOTICE .gitignore .gitattributes .gitkeep .gitmodules .vscodeignore .npmignore .npmrc .nvmrc .editorconfig .prettierrc .prettierignore .eslintignore .shellcheckrc
```

FL-9 — predicate semantics (both runtimes, identical results for every input): return True when the component is an ordinal member of the known-name set; otherwise split at the last dot; return False when there is no dot or the text before the last dot is empty; otherwise lower-case the text after the last dot (Python `str.lower()`, PowerShell `ToLowerInvariant()`) and return whether it fully matches the extension pattern (Python `FILE_EXTENSION_RE.fullmatch(...) is not None`; PowerShell `$script:FileExtensionPattern.IsMatch(...)`). The predicate never raises.

FL-10 — documentation literals, each written on a single line in the rules document:

```text
### File-shape recognition (issue #797)
[a-z][a-z0-9]*
src/TaskMaster.Domain
separator-free bare file name
```

FL-11 — Pester `It` names added or changed by this plan (each name is unique among its siblings; no two differ only by letter case):

```text
classifies the file-shaped token <_> as concrete
still rejects the non-file token <_>
classifies the dotted-directory residual as concrete
reports the component case <Name>
pins the known file names to the Python source
pins the extension pattern text to the Python source
re-exports Test-FileShapedComponent from the extraction module
accepts a token outside the known segments with an unlisted letter-led extension
```

## Delegation and Batch Plan

`atomic-executor` delegates implementation to the typed engineers. Each batch touches at most three production files and at most three test files of one language. Bundled mirrors are produced with `Copy-Item` in the PowerShell tool, never with Write or Edit.

| Batch | Engineer | Tasks | Files |
|---|---|---|---|
| B1 | python-typed-engineer | P1-T1..P1-T5 | Python tests and the new fixture |
| B2 | powershell-typed-engineer | P1-T6..P1-T7 | Pester tests |
| B3 | python-typed-engineer | P2-T1..P2-T3 | two Python leaf/extraction modules, one Python test |
| B4 | powershell-typed-engineer | P3-T1..P3-T3 | two PowerShell modules, one Pester test |
| B5 | atomic-executor | P4-T4..P4-T9, P5-T1..P5-T6 | fixture JSON, conditional pins, rules document, mirrors |

## Phases

### Phase 0 — Policy Reads and Baseline Capture

- [x] [P0-T1] Read the policy files in this order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/powershell.md`, `.claude/rules/plan-acceptance-gates.md`, `.claude/rules/parallel-orchestration.md`; then record `<FEATURE>/evidence/baseline/phase0-instructions-read.<ts>.md` with `Timestamp:`, `Policy Order:`, and the nine files in that order. Acceptance: the artifact exists and lists all nine files in order.
- [x] [P0-T2] Read the requirements sources `<FEATURE>/spec.md`, `<FEATURE>/issue.md`, and `<FEATURE>/research/research.2026-10-08T17-27.md`, then in the PowerShell tool run `$t=@(Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md); $i=[array]::IndexOf($t,'## Acceptance Criteria'); $j=[array]::IndexOf($t,'## Risks & Mitigations'); @($t[$i..$j] | Where-Object { $_.StartsWith('- [ ] ') }).Count; @($t | Where-Object { $_.Contains('.claude/rules/parallel-orchestration.md') }).Count; @(Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/issue.md | Where-Object { $_ -ceq '- Work Mode: full-bug' }).Count` and record `<FEATURE>/evidence/baseline/requirements-source.<ts>.md`. Acceptance: the three printed integers are `19`, at least `2`, and `1`; any other value stops the plan for re-triage.
- [x] [P0-T3] Baseline the branch position and the diff anchor: run `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, and `git status --porcelain`; then in the PowerShell tool run `git rev-parse HEAD | Set-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt -Encoding ascii` followed by `(Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt).Length`; record `<FEATURE>/evidence/baseline/git-baseline.<ts>.md` with the SHA on a `BaseSha:` line. Acceptance: the branch is bug/blast-radius-path-extractor-misses-real-plan-writes-797; `git rev-parse HEAD` prints a 40-character hexadecimal SHA and the length command prints `40`; and the porcelain listing is empty or lists only paths under `<FEATURE>` and, if present, the promoted lifecycle record docs/features/potential/promoted/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes.md. Any other porcelain line stops the plan for re-triage. This SHA is "the SHA recorded in P0-T3" in every later task. `git ls-files --error-unmatch -- docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md` exits 0 and prints that path, and no porcelain line names spec.md; otherwise the plan stops for re-triage.
- [x] [P0-T4] Baseline line counts: in the PowerShell tool run `foreach ($p in @('scripts/dev_tools/_blast_radius_extraction.py','scripts/dev_tools/_blast_radius_token_shapes.py','.claude/lib/blast-radius/BlastRadiusExtraction.psm1','.claude/lib/blast-radius/BlastRadiusTokenShape.psm1','tests/scripts/dev_tools/test_blast_radius_extraction.py','tests/scripts/dev_tools/test_blast_radius_extraction_rules.py','tests/scripts/dev_tools/test_blast_radius_token_shapes.py','tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1','tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1','tests/scripts/dev_tools/test_blast_radius_verification_integrity.py','tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1')) { "$p $(@(Get-Content -LiteralPath $p).Count)" }` and record `<FEATURE>/evidence/baseline/line-counts.<ts>.md`. Acceptance: eleven lines, each with an integer; these are the comparison values for P8-T2.
- [x] [P0-T5] Baseline the reproduction (AC-1): run `poetry run python -c "from scripts.dev_tools._blast_radius_extraction import classify_path_token as c; [print(t, c(t)) for t in ['tests/shell/foo.bats','extensions/drm-copilot/jest.config.cjs','tests/out/run.out','.agents/skills/x/refs/foo.bats','.claude/lib/x/.shellcheckrc','Sample.*','tests/fixtures/Sample.*','.agents/skills/x/SKILL.md','tests/Sample.cs']]"` and record `<FEATURE>/evidence/baseline/repro-classifier.<ts>.md` with the verbatim output. Acceptance: `EXIT_CODE: 0` and the nine output lines equal FL-5 in order; any difference is recorded and stops the plan for re-triage.
- [x] [P0-T6] Baseline the issue #510 state guard: in the PowerShell tool run `@(Get-ChildItem -LiteralPath .claude/state -Filter '*-batch-budget.*.json' -File -ErrorAction SilentlyContinue).Count` and record `<FEATURE>/evidence/baseline/claude-state-check.<ts>.md`. Acceptance: the printed integer is `0`; a non-zero value stops the plan and is returned to the orchestrator.
- [x] [P0-T7] Baseline Python formatting in check mode (no source is rewritten): run `poetry run black --check .` and record `<FEATURE>/evidence/baseline/black-check.<ts>.md`. Acceptance: the summary line is recorded; the success case prints a line ending `would be left unchanged.` with `EXIT_CODE: 0`; every `would reformat` line is recorded verbatim as pre-existing drift.
- [x] [P0-T8] Baseline Python linting: run `poetry run ruff check .` and record `<FEATURE>/evidence/baseline/ruff.<ts>.md`. Acceptance: the literal `All checks passed!` or the verbatim diagnostics, with the exit code.
- [x] [P0-T9] Baseline Python type checking: run `poetry run pyright` and record `<FEATURE>/evidence/baseline/pyright.<ts>.md`. Acceptance: the summary line (success case begins `0 errors`) and the exit code.
- [x] [P0-T10] Baseline focused Python tests with coverage: run `poetry run pytest tests/scripts/dev_tools/test_blast_radius_extraction.py tests/scripts/dev_tools/test_blast_radius_extraction_rules.py tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_blast_radius_write_intent.py tests/scripts/dev_tools/test_blast_radius_parity.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/dev_tools/test_blast_radius_verification_integrity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/python-coverage-baseline.json` (after the P0-T6 command prints `0`) and record `<FEATURE>/evidence/baseline/pytest-focused-coverage.<ts>.md`. Acceptance: `Output Summary:` records the pytest final line and the two terminal-table rows for `_blast_radius_extraction.py` and `_blast_radius_token_shapes.py` (Stmts, Miss, Branch, BrPart, Cover); a run without both rows fails the task.
- [x] [P0-T11] Baseline the numeric Python coverage values: run `poetry run python -c "import json; d=json.load(open('docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/python-coverage-baseline.json', encoding='utf-8')); [print(k, v['summary']['covered_lines'], v['summary']['num_statements'], v['summary']['covered_branches'], v['summary']['num_branches']) for k, v in d['files'].items() if k.replace(chr(92), '/').endswith(('dev_tools/_blast_radius_extraction.py', 'dev_tools/_blast_radius_token_shapes.py'))]"` and record `<FEATURE>/evidence/baseline/python-coverage-derived.<ts>.md`. Acceptance: exactly two printed lines; the artifact states, per module, line percent = covered_lines / num_statements and branch percent = covered_branches / num_branches as numbers.
- [x] [P0-T12] Baseline the Python fixture suites (AC-1): run `poetry run pytest tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/dev_tools/test_blast_radius_verification_integrity.py tests/scripts/dev_tools/test_blast_radius_parity.py -q` and record `<FEATURE>/evidence/baseline/python-fixture-suites.<ts>.md`. Acceptance: `EXIT_CODE: 0`, `0 failed`, and the passed count recorded; this is the comparison value for P4-T10.
- [x] [P0-T13] Baseline the AFTER-section derivation of the three historical runs: run `poetry run python -c "import json; from scripts.dev_tools.compute_blast_radius import BlastRadius, normalize_declared_radius; from scripts.dev_tools._blast_radius_scheduling import SchedulingItem, schedule_conflict_edges; from scripts.dev_tools.parallel_cohort_computation import compute_cohorts; L=lambda n: json.load(open('tests/fixtures/blast_radius/historical-runs/'+n+'.json', encoding='utf-8')); S=lambda f: schedule_conflict_edges([SchedulingItem(key=i['issue_num'], radius=normalize_declared_radius(BlastRadius.from_dict(i['radius']), f['after']['config']), band=i['complexity_band']) for i in f['items']], f['after']['config']); [print(n, json.dumps({'edges': [e.to_dict() for e in r.edges], 'tolerated_overlaps': [o.to_dict() for o in r.tolerated_overlaps], 'cohorts': compute_cohorts([i['issue_num'] for i in f['items']], [(e.a, e.b) for e in r.edges])}, sort_keys=True)) for n in ['epic-655-followups', 'backlog-2026-09-26', 'followups-2026-09-27'] for f in [L(n)] for r in [S(f)]]"` and record `<FEATURE>/evidence/baseline/historical-after-derivation.<ts>.md` with the verbatim output. Acceptance: `EXIT_CODE: 0` and exactly three lines, one per run name; the backlog-2026-09-26 line contains an edge with `"a": 588`, `"b": 622`, and `"cost": 152`.
- [x] [P0-T14] Baseline the full Python suite: run `poetry run pytest -q` (after the P0-T6 command prints `0`) and record `<FEATURE>/evidence/baseline/pytest-full.<ts>.md`. Acceptance: the passed, failed, and skipped counts and every failing node ID (one per line) are recorded; this failing set is the comparison value for P6-T9.
- [x] [P0-T15] Baseline PowerShell formatting without rewriting source: in the PowerShell tool run `foreach ($p in @('.claude/lib/blast-radius/BlastRadiusExtraction.psm1','.claude/lib/blast-radius/BlastRadiusTokenShape.psm1','tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1','tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1')) { $s=(Get-Content -Raw -LiteralPath $p).Replace([string][char]13 + [char]10, [string][char]10); $f=Invoke-Formatter -ScriptDefinition $s -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; "$p $($s -ceq $f)" }` and record `<FEATURE>/evidence/baseline/powershell-format.<ts>.md`. Acceptance: four lines, each ending `True` or `False`; a `False` line is recorded as pre-existing drift.
- [x] [P0-T16] Baseline PowerShell analysis: in the PowerShell tool run `$set='scripts/powershell/PoshQC/settings/pssa.settings.psd1'; $null=@(Invoke-ScriptAnalyzer -ScriptDefinition '$a=1' -Settings $set -ErrorAction SilentlyContinue); foreach ($p in @('.claude/lib/blast-radius/BlastRadiusExtraction.psm1','.claude/lib/blast-radius/BlastRadiusTokenShape.psm1','tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1','tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1')) { $e=$null; $n=@(Invoke-ScriptAnalyzer -Path $p -Settings $set -Severity Error,Warning,Information -ErrorVariable e -ErrorAction SilentlyContinue).Count; "$p Findings=$n Errors=$(@($e).Count)" }` (the first statement is a warm-up call) and record `<FEATURE>/evidence/baseline/powershell-analyze.<ts>.md`. Acceptance: four lines, each showing `Errors=0`, with the `Findings=` integers recorded.
- [x] [P0-T17] Baseline Pester with line coverage for the two modules: in the PowerShell tool run `$o='docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/pester-coverage-baseline.xml'; $c=New-PesterConfiguration; $c.Run.Path=@('tests/scripts/claude-lib/blast-radius'); $c.Run.PassThru=$true; $c.Output.Verbosity='Normal'; $c.CodeCoverage.Enabled=$true; $c.CodeCoverage.Path=@('.claude/lib/blast-radius/BlastRadiusTokenShape.psm1','.claude/lib/blast-radius/BlastRadiusExtraction.psm1'); $c.CodeCoverage.OutputFormat='JaCoCo'; $c.CodeCoverage.OutputPath=$o; $r=Invoke-Pester -Configuration $c; [xml]$x=Get-Content -Raw -LiteralPath $o; foreach ($s in @($x.SelectNodes('//sourcefile'))) { $l=@($s.counter | Where-Object { $_.type -eq 'LINE' })[0]; "$($s.name) LineCovered=$($l.covered) LineMissed=$($l.missed)" }; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"; @($r.Failed | ForEach-Object { $_.ExpandedName + ' | ' + [System.IO.Path]::GetFileName($_.ScriptBlock.File) })` and record `<FEATURE>/evidence/baseline/pester-coverage.<ts>.md` with `EXIT_CODE:` set to `1` when the failed count is non-zero and `0` otherwise. Acceptance: two sourcefile lines (one per module) and the Passed/Failed line are recorded, each module's line percent = covered / (covered + missed) is stated numerically, and every failing test is listed as its name and test-file leaf name; a missing coverage XML fails the task.
- [x] [P0-T18] Baseline the Pester fixture suites (AC-1): in the PowerShell tool run `$r=Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1,tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 -PassThru -Output None; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"; @($r.Failed | ForEach-Object { $_.ExpandedName })` and record `<FEATURE>/evidence/baseline/pester-fixture-suites.<ts>.md`. Acceptance: `Failed=0` and the passed count recorded (the verification-integrity Describe lives in the parity file); this is the comparison value for P4-T11.
- [x] [P0-T19] Baseline the PoshQC analyzer gate: call `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders: [".claude/lib/blast-radius", "tests/scripts/claude-lib/blast-radius"]` and record `<FEATURE>/evidence/baseline/poshqc-analyze.<ts>.md` with `Command:` naming the tool and folders, `EXIT_CODE:` 0 for `ok:true` and 1 for `ok:false`, and `Output Summary:` stating the `ok` value only. Acceptance: the artifact has all four fields and the exit code matches the `ok` value.
- [x] [P0-T20] Baseline the PoshQC test gate: call `mcp__drm-copilot__run_poshqc_test` and record `<FEATURE>/evidence/baseline/poshqc-test.<ts>.md` with `EXIT_CODE:` 0 for `ok:true` and 1 for `ok:false` and `Output Summary:` stating the `ok` value only. Acceptance: the artifact has all four fields; no count is recorded from the tool.
- [x] [P0-T21] Baseline mirror equality: run `git diff --no-index --exit-code .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`, `git diff --no-index --exit-code .claude/lib/blast-radius/BlastRadiusExtraction.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, and `git diff --no-index --exit-code .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`, and record `<FEATURE>/evidence/baseline/mirror-equality.<ts>.md`. Acceptance: all three exit 0 with empty output; a non-zero exit is recorded as pre-existing drift and stops the plan for re-triage.
- [x] [P0-T22] Baseline the allowlist occurrences: run `git grep -n -E "RECOGNIZED_PATH_EXTENSIONS|RecognizedPathExtension" -- scripts .claude extensions tests` and record `<FEATURE>/evidence/baseline/allowlist-occurrences.<ts>.md`. Acceptance: exactly six lines (two in each of the Python extraction module, the PowerShell extraction module, and its bundled mirror).
- [x] [P0-T23] Baseline the architecture-boundary tool presence: run `git grep -c -F "importlinter" -- pyproject.toml` and `git ls-files -- .importlinter` and record `<FEATURE>/evidence/baseline/architecture-tool-presence.<ts>.md`. Acceptance: both outputs recorded; empty output from both records `Architecture stage: no tool configured for Python or PowerShell`, which authorizes the not-configured branch of P6-T5.

### Phase 1 — Fail-Before Regression Tests

- [x] [P1-T1] Add, at the end of `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py`, the test `test_classify_path_token_admits_a_file_shaped_token_797`, parametrized with `pytest.param(token, id=...)` over the seven FL-1 rows, asserting `classify_path_token(token) == PATH_KIND_CONCRETE` with a failure message that names the token and the observed kind, and a docstring citing issue #797. Append only: no existing line of the file changes. Acceptance: the function exists once and carries seven parameters with the FL-1 ids.
- [x] [P1-T2] Add, at the end of `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py`, the test `test_classify_path_token_still_rejects_a_non_file_token_797`, parametrized over the fifteen FL-2 rows with their ids, asserting `classify_path_token(token) is None`. Append only. Acceptance: the function exists once and carries fifteen parameters.
- [x] [P1-T3] Add, at the end of `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py`, the test `test_classify_path_token_admits_the_dotted_directory_residual_797`, asserting that the FL-6 residual token classifies as `PATH_KIND_CONCRETE`, with a docstring stating that this is the documented fail-closed residual. Append only. Acceptance: the function exists once.
- [x] [P1-T4] Update `tests/scripts/dev_tools/test_blast_radius_extraction.py`: delete the FL-6 Python contract-change token from the parameter list of `test_classify_path_token_rejects_non_path_tokens` and insert it as a fourth parameter of `test_classify_path_token_accepts_recognized_extension_outside_known_segments`. No other test function changes. Acceptance: the token appears exactly once in the file, inside the accepting test's parameter list.
- [x] [P1-T5] Create `tests/fixtures/blast_radius/derivation-file-shaped-tokens.json` whose parsed JSON equals the FL-4 content. Acceptance: `poetry run python -c "import json; d=json.load(open('tests/fixtures/blast_radius/derivation-file-shaped-tokens.json', encoding='utf-8')); print(d['input']['plan_text'].count(chr(96)), len(d['expected']['radius']['paths']))"` prints `16 7`.
- [x] [P1-T6] Add, at the end of `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1`, a `Describe 'File-shaped token classification (issue #797)'` containing the FL-11 Its `classifies the file-shaped token <_> as concrete` (`-ForEach` over the seven FL-1 tokens, asserting `Should -Be 'concrete'`), `still rejects the non-file token <_>` (`-ForEach` over the fifteen FL-2 tokens, asserting `Should -BeNullOrEmpty`), and `classifies the dotted-directory residual as concrete`. Every string is single-quoted, so the file keeps its documented no-double-quote constraint. Append only. Acceptance: in the PowerShell tool, `@(Select-String -LiteralPath tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 -Pattern ([string][char]34) -SimpleMatch).Count` prints `0`.
- [x] [P1-T7] Edit `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1` in place: in the `It` that classifies the FL-6 PowerShell contract-change token, rename it to the FL-11 name `accepts a token outside the known segments with an unlisted letter-led extension`, reword its two comments to state that a letter-led extension names a file (issue #797), and change its assertion to `$kind | Should -Be 'concrete'`. No line is added or deleted. Acceptance: the file's line count equals its P0-T4 value.
- [x] [P1-T8] [expect-fail] Verify the Python fail-before state: run `poetry run pytest "tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_admits_a_file_shaped_token_797" "tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_admits_the_dotted_directory_residual_797" "tests/scripts/dev_tools/test_blast_radius_extraction.py::test_classify_path_token_accepts_recognized_extension_outside_known_segments[alpha/beta.unknownext]" "tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_radius[derivation-file-shaped-tokens]" -q` and record `<FEATURE>/evidence/regression-testing/python-fail-before.<ts>.md` with `ExpectedExitCode: 1`. Acceptance: `EXIT_CODE: 1` and the final summary line reads `10 failed` with no `passed` term (seven FL-1 cases, the residual, the contract-change case, and the fixture radius).
- [x] [P1-T9] Verify the Python guards pass on the unmodified classifier: run `poetry run pytest "tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_still_rejects_a_non_file_token_797" -q` and record `<FEATURE>/evidence/regression-testing/python-guards-before.<ts>.md`. Acceptance: `EXIT_CODE: 0` and the final summary line reads `15 passed`.
- [x] [P1-T10] [expect-fail] Verify the Pester fail-before state: in the PowerShell tool run `$r=Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1,tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 -PassThru -Output None; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"; @($r.Failed | ForEach-Object { $_.ExpandedName })` and record `<FEATURE>/evidence/regression-testing/pester-fail-before.<ts>.md` with `ExpectedExitCode: 1` and `EXIT_CODE:` set to `1` when the failed count is non-zero. Acceptance: `Failed=9`, and the failed names are exactly the seven `classifies the file-shaped token ... as concrete` expansions for the FL-1 tokens, `classifies the dotted-directory residual as concrete`, and `accepts a token outside the known segments with an unlisted letter-led extension`; no `still rejects the non-file token` expansion fails.

### Phase 2 — Python Implementation

- [ ] [P2-T1] Add to `scripts/dev_tools/_blast_radius_token_shapes.py` the FL-7 Python names with the FL-8 membership and the FL-9 semantics, with a Google-style docstring on the predicate and a comment block on each constant; extend the module docstring's Responsibilities and Invariants to name the predicate, its use by the classifier (issue #797), and the PowerShell parity pin. The module still imports nothing from the blast-radius library. Acceptance: `poetry run python -c "from scripts.dev_tools._blast_radius_token_shapes import KNOWN_FILE_NAMES as k, FILE_EXTENSION_PATTERN_TEXT as p, is_file_shaped_component as f; print(len(k), p, f('jest.config.cjs'), f('.claude'), f(''))"` prints `18 [a-z][a-z0-9]* True False False`.
- [ ] [P2-T2] Update `scripts/dev_tools/_blast_radius_extraction.py`: import `is_file_shaped_component` from the leaf module; delete the `RECOGNIZED_PATH_EXTENSIONS` constant and its comment; in `classify_path_token` replace the extension read and the allowlist membership test with one predicate call on the line-suffix-stripped final component, used at both former consult sites (the wildcard-free branch and the wildcard acceptance branch); reword the comments on `KNOWN_TOP_LEVEL_SEGMENTS` and `LINE_SUFFIX_RE`, the Returns section of the `classify_path_token` docstring, and the final-component comment so that they describe the file-shape rule (issue #797) instead of a recognized extension. No other behavior changes. Acceptance: the P2-T4 run passes and the file's line count does not exceed its P0-T4 value.
- [ ] [P2-T3] Add to `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` (imports inserted as new lines; tests appended at the end; no existing line changes) the test `test_is_file_shaped_component_classifies_a_component` parametrized over the fifteen FL-3 rows with their ids, the test `test_known_file_names_are_the_adopted_set` asserting equality with the FL-8 names and a size of 18, and the test `test_file_extension_pattern_text_uses_explicit_ascii_classes` asserting the FL-7 pattern text. Acceptance: the three functions exist once each, the FL-3 parametrization carries fifteen ids, and `poetry run python -c "print(all(b < 128 for b in open('tests/scripts/dev_tools/test_blast_radius_token_shapes.py', 'rb').read()))"` prints `True`.
- [ ] [P2-T4] Verify the Python pass-after state: re-run the exact P1-T8 command and record `<FEATURE>/evidence/regression-testing/python-pass-after.<ts>.md`. Acceptance: `EXIT_CODE: 0` and the final summary line reads `10 passed`.
- [ ] [P2-T5] Verify the Python unit files: run `poetry run pytest tests/scripts/dev_tools/test_blast_radius_extraction_rules.py tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_blast_radius_extraction.py -q` and record `<FEATURE>/evidence/regression-testing/python-unit-after.<ts>.md`. Acceptance: `EXIT_CODE: 0`, `0 failed`, and the passed count recorded.

### Phase 3 — PowerShell Implementation

- [ ] [P3-T1] Add to `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` the FL-7 PowerShell names with the FL-8 membership (single-quoted literals) and the FL-9 semantics, with comment-based help on `Test-FileShapedComponent`; add the function to `Export-ModuleMember`; extend the `.DESCRIPTION` parity notes to cover the new predicate. The module still imports no sibling and keeps its `CONVENTION:` line. Acceptance: the P3-T4 run passes.
- [ ] [P3-T2] Update `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`: delete the `$script:RecognizedPathExtension` block and its comment; in `Get-PathTokenKind` replace the extension read and `$hasExtension` with one `Test-FileShapedComponent -Component $finalComponent` call used at both former consult sites; add `Test-FileShapedComponent` to the module's `Export-ModuleMember` list beside the other re-exported token-shape predicates; reword the comment-based help and the comments on the known-segment list, the line-suffix pattern, and the final-component read to describe the file-shape rule (issue #797). Acceptance: the P3-T4 run passes and the file's line count does not exceed its P0-T4 value.
- [ ] [P3-T3] Add to `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` (append only; single-quoted strings only) a `Describe 'Test-FileShapedComponent (issue #797)'` with the FL-11 Its `reports the component case <Name>` (`-ForEach` over the fifteen FL-3 rows as hashtables with `Name`, `Component`, `Expected`), `pins the known file names to the Python source`, `pins the extension pattern text to the Python source`, and `re-exports Test-FileShapedComponent from the extraction module`. The two parity Its read the Python leaf module source with `Get-Content -Raw`, extract the `KNOWN_FILE_NAMES` body and the `FILE_EXTENSION_PATTERN_TEXT` value with single-quoted regular expressions that match the Python double quote with the escape \x22 (for example '\x22([^\x22]*)\x22') and never contain a literal double-quote character, in the style of the write-intent vocabulary pin, read the module-scoped values through `& (Get-Command -Name Test-FileShapedComponent).Module { ... }`, compare the known names after ordinal sorting with `Should -BeExactly`, and assert a count of 18. Acceptance: the P1-T6 double-quote count command still prints `0`, and in the PowerShell tool `@([System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1).Path) | Where-Object { $_ -gt 127 }).Count` prints `0`.
- [ ] [P3-T4] Verify the Pester pass-after state: re-run the exact P1-T10 command and record `<FEATURE>/evidence/regression-testing/pester-pass-after.<ts>.md`. Acceptance: `Failed=0`, no failed name is printed, and the passed count is recorded.

### Phase 4 — Fixture Re-Pin and Suite Reconciliation

- [ ] [P4-T1] Verify the Python fixture suites after the classifier change: run `poetry run pytest tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/dev_tools/test_blast_radius_verification_integrity.py tests/scripts/dev_tools/test_blast_radius_parity.py -q` and record `<FEATURE>/evidence/regression-testing/python-fixture-suites-pre-repin.<ts>.md`, listing every failing node ID with its assertion message. Acceptance: every failing node ID is one of `test_after_edges_match_pins`, `test_after_tolerated_overlaps_match_pins`, or `test_after_cohorts_match_pins` (any run), or a test in the verification-integrity file; any other failing node stops the plan for re-triage.
- [ ] [P4-T2] Verify the Pester fixture suites after the classifier change: re-run the exact P0-T18 command and record `<FEATURE>/evidence/regression-testing/pester-fixture-suites-pre-repin.<ts>.md`. Acceptance: every failing name belongs to the historical-runs AFTER Its or the verification-integrity Describe; any other failure stops the plan for re-triage.
- [ ] [P4-T3] Verify the AFTER-section derivation after the classifier change: re-run the exact P0-T13 command and record `<FEATURE>/evidence/regression-testing/historical-after-derivation-post.<ts>.md`, followed by a per-run, per-field comparison with the P0-T13 output listing each changed value as before and after. Acceptance: three output lines; every run whose line differs from P0-T13 is named with each changed field; an unchanged run is recorded as `NO-CHANGE`.
- [ ] [P4-T4] Update `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json` so that its `after` section's `edges`, `edge_count`, `tolerated_overlaps`, `cohorts`, `cohort_count`, and `max_cohort_width` equal the P4-T3 values for that run, editing only values that differ; record every changed pin with its before and after value in `<FEATURE>/evidence/regression-testing/historical-repin.<ts>.md`. If P4-T3 records `NO-CHANGE` for this run, leave the file untouched and record the deviation from the spec's expected cost change. Acceptance (diffs against the SHA recorded in P0-T3, run in the PowerShell tool): `git diff --numstat (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt) -- tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json` prints a line if and only if P4-T3 recorded a difference for this run; and `git diff -U0 (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt) -- tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json` shows only hunks whose old-side start line (the number after the minus sign in each hunk header) is greater than the line of the `after` key, read with `(Select-String -LiteralPath tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json -Pattern '  "after": {' -SimpleMatch).LineNumber` (570 when this plan was written; the executor uses the printed value).
- [ ] [P4-T5] Update `tests/fixtures/blast_radius/historical-runs/epic-655-followups.json` with the P4-T3 values for that run only when P4-T3 records a difference for it, appending each changed pin to the P4-T4 artifact; otherwise leave it untouched and record `NO-CHANGE`. Acceptance: in the PowerShell tool, `git diff --numstat (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt) -- tests/fixtures/blast_radius/historical-runs/epic-655-followups.json` prints a line if and only if P4-T3 recorded a difference for this run.
- [ ] [P4-T6] Update `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json` with the P4-T3 values for that run only when P4-T3 records a difference for it, appending each changed pin to the P4-T4 artifact; otherwise leave it untouched and record `NO-CHANGE`. Acceptance: in the PowerShell tool, `git diff --numstat (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt) -- tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json` prints a line if and only if P4-T3 recorded a difference for this run.
- [ ] [P4-T7] Update `tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json` only when P4-T1 or P4-T2 recorded a verification-integrity failure whose cause is a pin stored in this fixture, using the value that both runtimes report in agreement; record the rationale in `<FEATURE>/evidence/regression-testing/verification-integrity-repin.<ts>.md`; otherwise leave it untouched and record `NO-CHANGE`. Acceptance: in the PowerShell tool, `git diff --numstat (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt) -- tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json` prints a line if and only if such a failure was recorded.
- [ ] [P4-T8] Update `tests/scripts/dev_tools/test_blast_radius_verification_integrity.py` (the `EXPECTED_AFTER_EDGES` pin) only when P4-T1 recorded a failure of that pin and P4-T2 recorded the same observed edges from the PowerShell suite; append the rationale to the P4-T7 artifact; otherwise leave it untouched and record `NO-CHANGE`. Acceptance: in the PowerShell tool, `git diff --numstat (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt) -- tests/scripts/dev_tools/test_blast_radius_verification_integrity.py` prints a line if and only if both conditions held.
- [ ] [P4-T9] Update `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` (the verification-integrity Describe pins) only when P4-T2 recorded a failure of those pins and P4-T1 recorded the same observed value from the Python suite; append the rationale to the P4-T7 artifact; otherwise leave it untouched and record `NO-CHANGE`. Acceptance: in the PowerShell tool, `git diff --numstat (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt) -- tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` prints a line if and only if both conditions held.
- [ ] [P4-T10] Verify the Python fixture suites pass after the re-pin: re-run the exact P4-T1 command and record `<FEATURE>/evidence/regression-testing/python-fixture-suites-after.<ts>.md`. Acceptance: `EXIT_CODE: 0`, `0 failed`, and a passed count equal to the P0-T12 count plus 2 (the two parametrized cases the new fixture adds to the parity file).
- [ ] [P4-T11] Verify the Pester fixture suites pass after the re-pin: re-run the exact P0-T18 command and record `<FEATURE>/evidence/regression-testing/pester-fixture-suites-after.<ts>.md`, together with the output of `@($r.Passed | Where-Object { $_.ExpandedName.Contains('derivation-file-shaped-tokens') }).Count` run in the same session. Acceptance: `Failed=0` and the second count is at least `1`, which shows the PowerShell parity suite derived the same radius as Python from the shared fixture.
- [ ] [P4-T12] Verify the remaining suites named by AC-14: run `poetry run pytest tests/scripts/dev_tools/test_blast_radius_write_intent.py tests/scripts/dev_tools/test_blast_radius_extraction.py -q`, and in the PowerShell tool run `$r=Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 -PassThru -Output None; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"`; record `<FEATURE>/evidence/regression-testing/other-suites-after.<ts>.md`. Acceptance: pytest `EXIT_CODE: 0` with `0 failed`, and `Failed=0` from Pester.

### Phase 5 — Documentation and Bundled Mirrors

- [ ] [P5-T1] Update the `description` value of `tests/fixtures/blast_radius/derivation-directory-shaped-rejected.json`, replacing the phrase that says the final component carries no recognized extension with wording that says the final component names no file (no letter-led extension and no known file name). No other value changes. Acceptance: in the PowerShell tool, `git diff --numstat (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt) -- tests/fixtures/blast_radius/derivation-directory-shaped-rejected.json` (against the SHA recorded in P0-T3) prints `1	1` followed by the path.
- [ ] [P5-T2] Add to `.claude/rules/parallel-orchestration.md`, inside "Blast-Radius Contention Doctrine (issue #489)" directly before the `### Module-map granularity criterion` heading, the subsection headed with the first FL-10 line. It states: the classifier accepts a wildcard-free separator-bearing token when its final component, after the line-suffix strip, has a non-empty stem and a lower-cased extension fully matching the second FL-10 line, or is an ordinal member of the closed known-name set (list the FL-8 names); directory-shaped tokens, dot-directories, digit-led tails, and trailing dots remain rejected (#489); the accepted residuals are a dotted directory cited without a trailing slash (the third FL-10 line), host-qualified tokens, and refs with a letter-led dotted tail, each producing at most an extra contention edge, which is the fail-closed direction; and the known-name set is a code constant in both runtimes pinned equal by a Pester test. Acceptance: the P5-T8 checks pass.
- [ ] [P5-T3] Append a seventh item to the numbered list under `#### Known false negatives` in `.claude/rules/parallel-orchestration.md`, written on one line, stating that a genuine file cited only as a separator-free bare file name (the fourth FL-10 line) is not recorded, because only repository-relative paths and configured root surfaces are accepted, and that the planner cites the repository-relative path or appends it to the declared radius. The list lead-in sentence and items 1 to 6 stay unchanged. Acceptance: the P5-T8 checks pass.
- [ ] [P5-T4] Replace `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` with a byte copy of its source: in the PowerShell tool run `Copy-Item -LiteralPath .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 -Destination extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1 -Force`. Acceptance: the matching P5-T7 diff exits 0.
- [ ] [P5-T5] Replace `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1` with a byte copy of its source: in the PowerShell tool run `Copy-Item -LiteralPath .claude/lib/blast-radius/BlastRadiusExtraction.psm1 -Destination extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1 -Force`. Acceptance: the matching P5-T7 diff exits 0.
- [ ] [P5-T6] Replace `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` with a byte copy of its source: in the PowerShell tool run `Copy-Item -LiteralPath .claude/rules/parallel-orchestration.md -Destination extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md -Force`. Acceptance: the matching P5-T7 diff exits 0.
- [ ] [P5-T7] Verify mirror equality (AC-11): re-run the three P0-T21 commands, run the P0-T6 command, then run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`; record `<FEATURE>/evidence/regression-testing/mirror-equality.<ts>.md`. Acceptance: all three diffs exit 0 with empty output, the state count is `0`, and pytest shows `EXIT_CODE: 0` with `0 failed`.
- [ ] [P5-T8] Verify the documentation literals (AC-12): run `git grep -n -F "### File-shape recognition (issue #797)" -- .claude/rules/parallel-orchestration.md`, `git grep -c -F "[a-z][a-z0-9]*" -- .claude/rules/parallel-orchestration.md`, `git grep -c -F "src/TaskMaster.Domain" -- .claude/rules/parallel-orchestration.md`, and `git grep -c -F "separator-free bare file name" -- .claude/rules/parallel-orchestration.md`, and record `<FEATURE>/evidence/regression-testing/docs-literals.<ts>.md`. Acceptance: the first command prints exactly one line whose line number is greater than the line of `### Placeholder-shape rejection (issue #502)` and less than the line of `### Module-map granularity criterion`; each count command prints a count of at least 1.

### Phase 6 — Final QA Loop: Python

Loop rule: run P6-T1 through P6-T9 in order. If any task fails or changes a file, correct the cause, re-run P5-T4 through P5-T7 when a mirrored source changed, and restart from P6-T1 until one full pass completes with no failure and no file change. Every command is mandatory; `EXIT_CODE: SKIPPED` is not a passing outcome.

- [ ] [P6-T1] Run the formatter in write mode on the changed Python files: record `git status --porcelain` before and after `poetry run black scripts/dev_tools/_blast_radius_token_shapes.py scripts/dev_tools/_blast_radius_extraction.py tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_blast_radius_extraction_rules.py tests/scripts/dev_tools/test_blast_radius_extraction.py` in `<FEATURE>/evidence/qa-gates/black-write.<ts>.md`. Acceptance: the summary line is the success-case literal `5 files left unchanged.` with no `reformatted` term, and the two porcelain listings are identical; a `reformatted` line restarts the loop.
- [ ] [P6-T2] Confirm repository formatting in check mode: run `poetry run black --check .` and record `<FEATURE>/evidence/qa-gates/black-check.<ts>.md`. Acceptance: Either `EXIT_CODE: 0` with a summary line ending `would be left unchanged.`; or, only when P0-T7 recorded pre-existing drift, `EXIT_CODE: 1` with the `would reformat` lines equal to the P0-T7 lines exactly and none naming a file in the Files Written inventory. The second branch passes the task; the artifact cites both runs and AC-17 is reported PARTIAL, not PASS.
- [ ] [P6-T3] Confirm linting: run `poetry run ruff check .` and record `<FEATURE>/evidence/qa-gates/ruff.<ts>.md`. Acceptance: Either `EXIT_CODE: 0` with the literal `All checks passed!`; or, only when P0-T8 recorded diagnostics, `EXIT_CODE: 1` with every diagnostic present in P0-T8 and none in a Files Written file. That branch passes the task and AC-17 is reported PARTIAL.
- [ ] [P6-T4] Confirm type checking: run `poetry run pyright` and record `<FEATURE>/evidence/qa-gates/pyright.<ts>.md`. Acceptance: Either `EXIT_CODE: 0` with a summary line beginning `0 errors`; or, only when P0-T9 recorded errors, every error line present in P0-T9 and none naming a Files Written file. That branch passes the task and AC-17 is reported PARTIAL.
- [ ] [P6-T5] Confirm the architecture-boundary, contract, and integration stages: record `<FEATURE>/evidence/qa-gates/stages-4-6-7.<ts>.md` stating, from P0-T23, `Architecture stage: no tool configured for Python or PowerShell` (or the result of the configured tool when P0-T23 found one), the contract stage as the shared parity corpus results of P4-T10 and P4-T11, and the integration stage as not applicable because no adapter in scope calls an external system. Acceptance: the artifact names each stage and cites the evidence artifact for each.
- [ ] [P6-T6] Confirm the focused tests with coverage (AC-15): run the P0-T6 command, then `poetry run pytest tests/scripts/dev_tools/test_blast_radius_extraction.py tests/scripts/dev_tools/test_blast_radius_extraction_rules.py tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_blast_radius_write_intent.py tests/scripts/dev_tools/test_blast_radius_parity.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/dev_tools/test_blast_radius_verification_integrity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/qa-gates/python-coverage-final.json`, and record `<FEATURE>/evidence/qa-gates/pytest-focused-coverage.<ts>.md`. Acceptance: `EXIT_CODE: 0`, `0 failed`, and both module rows of the terminal table recorded.
- [ ] [P6-T7] Confirm the numeric Python coverage values: re-run the P0-T11 command with the JSON path changed to `evidence/qa-gates/python-coverage-final.json` under `<FEATURE>` and record `<FEATURE>/evidence/qa-gates/python-coverage-derived.<ts>.md`. Acceptance: two printed lines; each module's line percent is at least 85 and branch percent is at least 75, each stated numerically.
- [ ] [P6-T8] Confirm changed-line coverage: in the PowerShell tool run `git diff -U0 (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt) -- scripts/dev_tools/_blast_radius_token_shapes.py scripts/dev_tools/_blast_radius_extraction.py` (against the SHA recorded in P0-T3), then run `poetry run python -c "import json; d=json.load(open('docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/qa-gates/python-coverage-final.json', encoding='utf-8')); [print(k, v['missing_lines'], v['missing_branches']) for k, v in d['files'].items() if k.replace(chr(92), '/').endswith(('dev_tools/_blast_radius_extraction.py', 'dev_tools/_blast_radius_token_shapes.py'))]"`, and record `<FEATURE>/evidence/qa-gates/changed-line-coverage.<ts>.md` listing the added line ranges from the hunk headers beside the missing lines and branches. Acceptance: no added executable line number appears in either module's `missing_lines`, and no branch whose source line is an added line appears in `missing_branches`.
- [ ] [P6-T9] Confirm the full Python suite: run the P0-T6 command, then `poetry run pytest -q`, and record `<FEATURE>/evidence/qa-gates/pytest-full.<ts>.md`. Acceptance: every failing node ID is also in the P0-T14 failing set, and the passed count is at least the P0-T14 passed count.

### Phase 7 — Final QA Loop: PowerShell

Loop rule: run P7-T1 through P7-T7 in order. If any task fails or changes a file, correct the cause, re-run P5-T4 through P5-T7 when a mirrored source changed, and restart from P7-T1 until one full pass completes with no failure and no file change. Every command is mandatory; `EXIT_CODE: SKIPPED` is not a passing outcome.

- [ ] [P7-T1] Run the PoshQC formatter: before and after calling `mcp__drm-copilot__run_poshqc_format` with `scan_folders: [".claude/lib/blast-radius", "tests/scripts/claude-lib/blast-radius"]`, record both `git status --porcelain` and, in the PowerShell tool, the SHA256 hash listing `foreach ($p in @('.claude/lib/blast-radius/BlastRadiusExtraction.psm1','.claude/lib/blast-radius/BlastRadiusTokenShape.psm1','tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1','tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1','tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1')) { "$p $((Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash)" }` in `<FEATURE>/evidence/qa-gates/poshqc-format.<ts>.md`, with `EXIT_CODE:` 0 for `ok:true` and 1 for `ok:false`. The hash listing is needed because these files are already modified, so a formatter rewrite of them leaves the porcelain listing unchanged; the parity test file is hashed whether or not P4-T9 changed it. Acceptance: `ok:true`, the two porcelain listings are identical, and the two hash listings are identical (the tool returns no output text, so these tree observations are the success signal). A changed hash or porcelain listing restarts the loop, including P5-T4 through P5-T7 when a mirrored source changed; a change to a file outside the Files Written inventory stops the plan for re-triage.
- [ ] [P7-T2] Confirm formatting without rewriting source: re-run the exact P0-T15 command and record `<FEATURE>/evidence/qa-gates/powershell-format.<ts>.md`. Acceptance: four lines, each ending `True`.
- [ ] [P7-T3] Confirm the PoshQC analyzer gate: re-run the P0-T19 call and record `<FEATURE>/evidence/qa-gates/poshqc-analyze.<ts>.md` in the same shape. Acceptance: `ok:true` and `EXIT_CODE: 0`. When P0-T19 recorded `ok:false` and this run is also `ok:false`, the task passes only when the exact P0-T16 command, run in this task and recorded in the same artifact, prints `Findings=0 Errors=0` on all four lines; the artifact cites P0-T19, P0-T16 and this run, and AC-18 is reported PARTIAL.
- [ ] [P7-T4] Confirm analyzer counts: re-run the exact P0-T16 command and record `<FEATURE>/evidence/qa-gates/powershell-analyze.<ts>.md`. Acceptance: four lines, each showing `Findings=0 Errors=0`; when P0-T16 recorded a non-zero baseline for a file, its count is not above the baseline and AC-18 is reported PARTIAL with both artifacts cited.
- [ ] [P7-T5] Confirm Pester with line coverage (AC-16): re-run the P0-T17 command with `$o` set to `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/qa-gates/pester-coverage-final.xml` and record `<FEATURE>/evidence/qa-gates/pester-coverage.<ts>.md`. Acceptance: each of the two sourcefile lines yields a line percent of at least 85, stated numerically; and either `Failed=0`, or every failing name also appears in the P0-T17 failing list and none belongs to a test file in the Files Written inventory (judged by the test-file leaf name the command prints), in which case the artifact cites both runs and AC-16 is still decided by the coverage values.
- [ ] [P7-T6] Confirm Pester name uniqueness: in the PowerShell tool run `$r=Invoke-Pester -Path tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 -PassThru -Output None; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"` and record `<FEATURE>/evidence/qa-gates/pester-name-uniqueness.<ts>.md`. Acceptance: `Failed=0` and a passed count of at least 1.
- [ ] [P7-T7] Confirm the PoshQC test gate: re-run the P0-T20 call and record `<FEATURE>/evidence/qa-gates/poshqc-test.<ts>.md` in the same shape. Acceptance: `ok:true` and `EXIT_CODE: 0`. When P0-T20 recorded `ok:false` and this run is also `ok:false`, the task passes only when P7-T5 passed; the artifact then cites P0-T20, P7-T5, and this run, and AC-18 is reported PARTIAL.

### Phase 8 — Coverage Comparison, Scope, and Close-Out

- [ ] [P8-T1] Confirm the coverage comparison: record `<FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md` tabulating, per module, the baseline values (P0-T11 and P0-T17), the post-change values (P6-T7 and P7-T5), and the changed-line result (P6-T8). Acceptance: every value is numeric; Python line is at least 85 and branch at least 75; PowerShell line is at least 85; no post-change value is below its baseline unless it still meets the threshold and the changed-line result shows no uncovered added line.
- [ ] [P8-T2] Confirm the file-size limit (AC-19): re-run the exact P0-T4 command and record `<FEATURE>/evidence/qa-gates/line-counts.<ts>.md`. Acceptance: eleven lines (the same eleven paths, in the same order, as P0-T4), each count at most 500; the two extraction modules are not above their P0-T4 counts; the PowerShell path test file equals its P0-T4 count.
- [ ] [P8-T3] Confirm the allowlist removal (AC-10): run `git grep -n -E "RECOGNIZED_PATH_EXTENSIONS|RecognizedPathExtension" -- scripts .claude extensions tests` and record `<FEATURE>/evidence/qa-gates/allowlist-removed.<ts>.md` with `ExpectedExitCode: 1`. Acceptance: `EXIT_CODE: 1` and empty output.
- [ ] [P8-T4] Confirm the pre-existing tests are unmodified (AC-8): in the PowerShell tool, against the SHA recorded in P0-T3, run `git diff --numstat (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt) -- tests/scripts/dev_tools/test_blast_radius_extraction_rules.py tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1`, `git diff -U0 (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt) -- tests/scripts/dev_tools/test_blast_radius_extraction.py tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1`, and `git status --porcelain`, and record `<FEATURE>/evidence/qa-gates/unmodified-tests.<ts>.md`. Acceptance: the numstat deleted column is `0` for all three files; in the second diff every deleted line belongs to the `test_classify_path_token_rejects_non_path_tokens` or `test_classify_path_token_accepts_recognized_extension_outside_known_segments` parameter lists or to the single inverted Pester `It`, and none belongs to the directory-shaped, root-surface, or placeholder-marker tests.
- [ ] [P8-T5] Confirm final mirror equality: re-run the P5-T7 commands and record `<FEATURE>/evidence/qa-gates/mirror-equality.<ts>.md`. Acceptance: the three diffs exit 0 with empty output and pytest reports `0 failed`.
- [ ] [P8-T6] Confirm the change scope against the SHA recorded in P0-T3: in the PowerShell tool run `git diff --name-only (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt)` and `git status --porcelain`, and record `<FEATURE>/evidence/qa-gates/scope-check.<ts>.md`. Acceptance: every listed path is in the Files Written inventory or lies under `<FEATURE>` (the promoted lifecycle record is also tolerated when P0-T3 listed it); every unconditional inventory path appears in at least one of the two listings; each conditional inventory path appears only when its Phase 4 task recorded a change.
- [ ] [P8-T7] Update `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md` by reconciling acceptance-criteria checkboxes. Each AC is checked when its mapped verification task passes (per the acceptance-criteria-tracking skill and the plan-level AC check-off rule, check-off happens as each verifying task passes); this task checks any passed AC still unchecked and changes only `- [ ]` to `- [x]`. An AC whose evidence is PARTIAL or missing stays unchecked; its gap is recorded in the P8-T8 plan update, not in spec.md. Acceptance: in the PowerShell tool, `$t=@(Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md); $i=[array]::IndexOf($t,'## Acceptance Criteria'); $j=[array]::IndexOf($t,'## Risks & Mitigations'); @($t[$i..$j] | Where-Object { $_.StartsWith('- [x] ') }).Count` prints the number of AC rows whose evidence passed; and `git diff -U0 (Get-Content -LiteralPath docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt) -- docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md` (against the SHA recorded in P0-T3) shows only removed and added line pairs whose sole difference is the checkbox character, each inside the Acceptance Criteria section, and the number of removed/added line pairs in that diff equals the printed `- [x] ` count.
- [ ] [P8-T8] Update `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/plan.2026-10-08T17-24.md` so that `Last Updated` and `Status` reflect completion, each task checkbox matches its evidence on disk, and a `## Close-Out Notes` section lists each AC left unchecked by P8-T7 with its ID and the gap (PARTIAL or missing evidence, citing the artifacts). Acceptance: every checked task names an artifact that exists, every unchecked task has a recorded reason, and every unchecked AC in spec.md has a Close-Out Notes entry.

## Files Written

Unconditional (production):

- `scripts/dev_tools/_blast_radius_token_shapes.py`
- `scripts/dev_tools/_blast_radius_extraction.py`
- `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`
- `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1`

Unconditional (documentation):

- `.claude/rules/parallel-orchestration.md` (dropped by the mandate-read filter; the run planner appends it manually)
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`

Unconditional (tests and fixtures):

- `tests/scripts/dev_tools/test_blast_radius_token_shapes.py`
- `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py`
- `tests/scripts/dev_tools/test_blast_radius_extraction.py`
- `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1`
- `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1`
- `tests/fixtures/blast_radius/derivation-file-shaped-tokens.json` (new)
- `tests/fixtures/blast_radius/derivation-directory-shaped-rejected.json`
- `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json`

Conditional (written only when Phase 4 records a moved pin):

- `tests/fixtures/blast_radius/historical-runs/epic-655-followups.json`
- `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json`
- `tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json`
- `tests/scripts/dev_tools/test_blast_radius_verification_integrity.py`
- `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`

Feature folder:

- `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/plan.2026-10-08T17-24.md`
- `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md`
- evidence files under the feature folder's evidence tree (not enumerated individually)

Not written (explicit): both blast-radius config JSON copies, the core pack manifest, the extension Jest configuration, every TypeScript push-down file, every hook file, and every other file under the rules and instructions trees.

## Acceptance Criteria Traceability

| AC | Spec criterion (short) | Implementation | Tests | Evidence |
|---|---|---|---|---|
| AC-1 | Baseline evidence before any production edit | P0-T5, P0-T12, P0-T18 | P0-T5, P0-T12, P0-T18 | baseline/repro-classifier, python-fixture-suites, pester-fixture-suites |
| AC-2 | Python classifier regression, fail-before/pass-after | P1-T1, P2-T1, P2-T2 | P1-T8, P2-T4 | regression-testing/python-fail-before, python-pass-after |
| AC-3 | PowerShell classifier regression | P1-T6, P3-T1, P3-T2 | P1-T10, P3-T4 | regression-testing/pester-fail-before, pester-pass-after |
| AC-4 | Shared pipeline fixture, fail-before/pass-after | P1-T5, P2-T2 | P1-T8, P2-T4 | regression-testing/python-fail-before, python-pass-after |
| AC-5 | Python/PowerShell parity on the corpus | P1-T5, P3-T2 | P4-T11, P7-T5 | regression-testing/pester-fixture-suites-after |
| AC-6 | Known-name and pattern parity pin | P3-T3 | P3-T4 | regression-testing/pester-pass-after |
| AC-7 | Predicate unit tests | P2-T3 | P2-T5 | regression-testing/python-unit-after |
| AC-8 | False-positive guards unchanged | P1-T2, P1-T6 | P1-T9, P2-T5, P3-T4, P8-T4 | regression-testing/python-guards-before, qa-gates/unmodified-tests |
| AC-9 | Accepted behavior change recorded | P1-T3, P1-T4, P1-T6, P1-T7 | P2-T4, P3-T4 | regression-testing/python-pass-after, pester-pass-after |
| AC-10 | Allowlist removed | P2-T2, P3-T2, P5-T5 | P8-T3 | qa-gates/allowlist-removed |
| AC-11 | Bundled mirrors byte-identical | P5-T4, P5-T5, P5-T6 | P5-T7, P8-T5 | regression-testing/mirror-equality, qa-gates/mirror-equality |
| AC-12 | Documentation subsection and false-negative note | P5-T2, P5-T3 | P5-T8 | regression-testing/docs-literals |
| AC-13 | Historical fixture re-pin | P4-T3, P4-T4, P4-T5, P4-T6 | P4-T10, P4-T11 | regression-testing/historical-repin |
| AC-14 | Other suites stay green | P4-T7, P4-T8, P4-T9 | P4-T12, P6-T9, P7-T5 | regression-testing/other-suites-after, qa-gates/pytest-full |
| AC-15 | Python coverage thresholds | Phases 1-2 | P6-T6, P6-T7, P6-T8 | qa-gates/python-coverage-derived, changed-line-coverage |
| AC-16 | PowerShell coverage threshold | Phase 3 | P7-T5 | qa-gates/pester-coverage |
| AC-17 | Python toolchain clean | Phases 1-2 | P6-T1, P6-T2, P6-T3, P6-T4, P6-T6 | qa-gates/black-write, black-check, ruff, pyright |
| AC-18 | PowerShell toolchain clean | Phase 3 | P7-T1, P7-T2, P7-T3, P7-T4, P7-T5, P7-T7 | qa-gates/poshqc-format, powershell-analyze, pester-coverage |
| AC-19 | File-size limit | P2-T2, P3-T2, P1-T7 | P8-T2 | qa-gates/line-counts |

## Risks and Notes

- Python `str.lower()` and .NET `ToLowerInvariant()` can differ on a small number of non-ASCII letters whose lower-case form maps into ASCII. The extension pattern admits ASCII only, the FL-3 non-ASCII case pins one input, and the shared fixture corpus guards the common shapes; a divergence on another non-ASCII input is a residual this plan does not test exhaustively.
- If P4-T3 shows that a historical run other than backlog-2026-09-26 moved, P4-T5 or P4-T6 writes it; the inventory already names both files so the declared radius covers them.
- The validator gate (`mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type: "plan"`) and the executor preflight are run by the orchestrator; this plan is not approved until both clear.

## Planner Self-Review

SELF-REVIEW: RE-DERIVED THIS PASS

Revision pass for preflight round 2 (deltas E1-E6; acceptance wording only, no task added, removed, or reordered). Citations touched by this revision, re-derived against the current tree in this pass:

S1. docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md — the file exists in the worktree (E1, P0-T3 tracked-file check; tracked status is asserted at execution time because the orchestrator commits the feature folder before P0-T3, per "Execution context and diff anchor"); line 231 `## Acceptance Criteria`, lines 233-251 nineteen `- [ ] ` items, line 253 `## Risks & Mitigations`, so at the base SHA every AC is unchecked and the P8-T7 removed/added pair count equals the `- [x] ` count (E1, P8-T7).
S2. tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json — line 570 is still the `"after": {` key (sibling of the E2 wording change in P4-T4).
S3. tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json, tests/scripts/dev_tools/test_blast_radius_verification_integrity.py, tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 — P4-T7, P4-T8, P4-T9 numstat clauses now biconditional (E2); P4-T5 and P4-T6 already used the biconditional form (sibling check).
S4. Recorded clean-run literals in existing evidence (E3): docs/features/completed/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t5.python-format-check.2026-04-18T18-50.md line 8 `184 files would be left unchanged.`; p5-t6.python-lint.2026-04-18T18-50.md line 7 `All checks passed!`; p5-t7.python-typecheck.2026-04-18T18-50.md line 7 `0 errors, 0 warnings, 0 informations`. These match the P0-T7, P0-T8, P0-T9 success literals, so the P6-T2, P6-T3, P6-T4 literals are unchanged.
S5. P0-T16 (this plan) — iterates four paths and prints one `"$p Findings=$n Errors=..."` line per path, so the E4 clause in P7-T3 ("`Findings=0 Errors=0` on all four lines") matches its output shape; P7-T4 (sibling) keeps its own baseline clause.
S6. tests/scripts/dev_tools/test_blast_radius_verification_integrity.py — 273 lines; tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 — 409 lines (E5; both at most 500, so the P8-T2 limit is satisfiable; both are conditional Files Written entries already in the inventory).
S7. P0-T4 and P8-T2 (this plan) — P8-T2 re-runs the exact P0-T4 command, so its path list follows P0-T4; both now state eleven lines; siblings P1-T7, P2-T2, P3-T2 compare against P0-T4 values of paths whose positions are unchanged (E5).
S8. tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 — P3-T3 byte check now resolves the path with Resolve-Path before ReadAllBytes (E6), because .NET resolves a relative path against the process directory rather than the PowerShell location; sibling P1-T6 double-quote count uses Select-String -LiteralPath, which resolves against the PowerShell location, and is unchanged.
S9. FL-4 (this plan, line 103) — sixteen JSON backtick escapes still present after the edits (no edit touched the fenced block); line 97 escape mention unchanged.

Revision pass for preflight round 1 (defects D1-D9). Citations touched by this revision, re-derived against the current tree in this pass:

R1. tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json — line 570 is the `"after": {` key (P4-T4 hunk floor); lines 685-692 still hold edge 588-622 with `"cost": 152` (sibling of the P4-T4 anchor; P0-T13 acceptance).
R2. docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md — line 231 `## Acceptance Criteria`; lines 233-251 the nineteen `- [ ] ` AC items (AC-1 at 233, AC-19 at 251); line 253 `## Risks & Mitigations` (P0-T2 and P8-T7 slice bounds); lines 23, 25, 26, 57, 214-217 are checkbox lines outside the slice, which is why P8-T7 counts within the slice only.
R3. .claude/skills/acceptance-criteria-tracking/SKILL.md — lines 56-59 check-off protocol (evidence first, one at a time, change only the checkbox, leave unmet items unchecked); line 71 check-off timing as each task passes (plan-level AC check-off rule and P8-T7).
R4. tests/scripts/dev_tools/test_blast_radius_token_shapes.py — zero bytes above 127 today, so the P2-T3 ASCII acceptance is satisfiable once FL-3 builds U+00E9 with chr(0xE9).
R5. tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 — zero bytes above 127 today (P3-T3 byte acceptance); lines 19-31 single-quote constraint (P3-T3 \x22 regex rule); lines 41-46 single import of the extraction module (P3-T3 module-scope read).
R6. tests/fixtures/blast_radius/derivation-directory-shaped-rejected.json — line 2 description still says "no recognized extension" (P5-T1, anchor changed only).
R7. tests/scripts/dev_tools/test_blast_radius_extraction.py — line 207 accepting test, line 231 alpha/beta.unknownext, line 234 rejecting test (P8-T4 diff scope, anchor changed only).
R8. tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 — line 150 weird/thing.unknownext inside the It at lines 148-157 (P8-T4 diff scope).
R9. .claude/rules/plan-acceptance-gates.md — lines 40-41 G8 and G8b definitions; every new anchored diff carries a non-flag operand, and the P8-T6 name-only diff keeps its porcelain companion.
R10. FL-4 (this plan, line 103) — sixteen JSON backtick escapes in plan_text (four per task line, P1-T1 through P1-T4) and seven expected radius paths, re-counted for the P1-T5 `16 7` acceptance.

Citations from the initial authoring pass (unchanged by this revision; listed for completeness):

1. scripts/dev_tools/_blast_radius_extraction.py — lines 90-97 RECOGNIZED_PATH_EXTENSIONS; line 243 classify_path_token; lines 281-282 root-surface test; lines 304-307 separator and colon rules; lines 313-318 final component, extension, has_extension; lines 324-325 wildcard-free branch; line 330 wildcard branch; lines 48-51 leaf import; last line 475 (file ends with a newline).
2. scripts/dev_tools/_blast_radius_token_shapes.py — 145 lines; line 63 PLACEHOLDER_MARKERS; lines 72 and 105 the two predicates; no import from the library.
3. .claude/lib/blast-radius/BlastRadiusExtraction.psm1 — lines 86-94 RecognizedPathExtension; line 57 TokenShape import; lines 242 and 335 Get-PathTokenKind and the allowlist test; lines 341-346 and 359 the two consult sites; lines 465-474 Export-ModuleMember including the re-exported token-shape predicates.
4. .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 — line 52 CONVENTION line; lines 87 and 133 the two functions; lines 187-189 Export-ModuleMember.
5. tests/scripts/dev_tools/test_blast_radius_extraction.py — 462 lines; lines 203-211 accepting test; lines 223-236 rejecting test with alpha/beta.unknownext at line 231; lines 249-294 root-surface tests.
6. tests/scripts/dev_tools/test_blast_radius_extraction_rules.py — lines 15-21 imports include PATH_KIND_CONCRETE and classify_path_token; lines 28-49 directory-shaped test; lines 169-192 placeholder tests; ends at line 225.
7. tests/scripts/dev_tools/test_blast_radius_token_shapes.py — lines 13-17 import block; ends at line 146.
8. tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 — 460 content lines; lines 148-157 weird/thing.unknownext It; lines 60-73 directory-shaped Its; lines 250-259 bare README/pyproject Its.
9. tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 — lines 19-31 single-quote constraint; lines 45-46 single import of the extraction module; lines 181-195 export-surface It.
10. tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 — lines 104-110 Get-PythonVocabulary; lines 239-252 vocabulary parity It.
11. tests/scripts/dev_tools/test_blast_radius_parity.py — line 60 MINIMUM_FIXTURE_COUNT = 30; line 174 top-level glob; lines 364-382 radius test with ids from fixture stems.
12. tests/scripts/dev_tools/test_blast_radius_historical_runs.py — lines 49-53 RUNS; lines 116-138 after_scheduling; lines 218-255 AFTER tests.
13. tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json — lines 207 and 421 jest.config.cjs entries; lines 685-692 edge 588-622 with cost 152.
14. tests/fixtures/blast_radius/derivation-directory-shaped-rejected.json — line 2 description cites a recognized extension.
15. tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json — fixture shape used for FL-4.
16. scripts/dev_tools/_blast_radius_write_intent.py — lines 76-83 READ_VERBS and WRITE_VERBS; lines 151-165 is_read_task_title (write verb anywhere, case-insensitive); lines 221-235 W6 stem; lines 258-315 single-word spans and read windows.
17. scripts/dev_tools/compute_blast_radius.py — lines 298-328 derivation with write-intent selection and mandate-read exclusion.
18. config/blast-radius.json — line 21 rules-tree mandate read; line 51 write_intent_extraction true; lines 52-70 path_roots including .claude, .devcontainer, extensions, packages, scripts, tests.
19. tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py — lines 89-110 repo-to-bundle text equality.
20. .claude/rules/parallel-orchestration.md — line 226 doctrine heading; line 327 placeholder subsection; line 385 module-map heading; lines 519-528 Known false negatives items 1-6.
21. extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1 — lines 88 and 335 mirror allowlist occurrences.
22. scripts/powershell/PoshQC/settings/pester.runsettings.psd1 — lines 17-27 coverage population derived from config; no blast-radius path list.
23. config/poshqc-coverage.json — line 5 includes the .claude lib tree.
24. scripts/powershell/PoshQC/settings/pssa.settings.psd1 — exists.
25. pyproject.toml — line 116 addopts LCOV-only reporter.
26. tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 — exists.
27. docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md — lines 231-251 nineteen AC items; lines 75 and 131 name the rules document; line 95 eighteen known names.
28. docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/issue.md — line 13 Work Mode full-bug.

Sibling re-checks performed in this revision: every `git diff` in the plan (P0-T21 no-index pairs left unchanged; P4-T4 through P4-T9, P5-T1, P6-T8, P8-T4, P8-T6, P8-T7 now anchored to the SHA recorded in P0-T3); P0-T17 failing-test output format, changed to name plus test-file leaf so that P7-T5 can apply its Files Written test; P8-T8, extended to receive the AC gaps that P8-T7 no longer writes into spec.md; the FL-4 fenced block, confirmed to contain no literal backtick. Sibling re-checks from the initial pass: the root-surface and placeholder tests adjacent to the edited parameter lists; the export list of the PowerShell extraction module adjacent to the deleted allowlist; the single-quote constraint header adjacent to the appended Pester Describes; the rules-document headings adjacent to the inserted subsection.

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
CITATION: scripts/dev_tools/_blast_radius_extraction.py | lines 90-97 RECOGNIZED_PATH_EXTENSIONS; lines 313-330 classify_path_token consult sites
CITATION: scripts/dev_tools/_blast_radius_token_shapes.py | 145 lines; leaf module, no library import
CITATION: .claude/lib/blast-radius/BlastRadiusExtraction.psm1 | lines 86-94 RecognizedPathExtension; line 335 test; lines 465-474 exports
CITATION: .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | lines 187-189 Export-ModuleMember
CITATION: tests/scripts/dev_tools/test_blast_radius_extraction.py | lines 203-236 accepting and rejecting parameter lists
CITATION: tests/scripts/dev_tools/test_blast_radius_extraction_rules.py | lines 15-21 imports; lines 28-49 directory-shaped test
CITATION: tests/scripts/dev_tools/test_blast_radius_token_shapes.py | lines 13-17 imports
CITATION: tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | lines 148-157 weird/thing.unknownext It
CITATION: tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 | lines 19-31 single-quote constraint; lines 45-46 import
CITATION: tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 | lines 239-252 vocabulary parity It
CITATION: tests/scripts/dev_tools/test_blast_radius_parity.py | line 60 MINIMUM_FIXTURE_COUNT; lines 364-382 radius test
CITATION: tests/scripts/dev_tools/test_blast_radius_historical_runs.py | lines 116-138 after_scheduling
CITATION: tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json | lines 685-692 edge 588-622 cost 152
CITATION: tests/fixtures/blast_radius/derivation-directory-shaped-rejected.json | line 2 description
CITATION: scripts/dev_tools/_blast_radius_write_intent.py | lines 151-165 is_read_task_title; lines 258-315 write-intent extraction
CITATION: config/blast-radius.json | line 21 rules-tree mandate read; lines 51-70 write-intent flag and path_roots
CITATION: tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py | lines 89-110 bundle text equality
CITATION: .claude/rules/parallel-orchestration.md | lines 327, 385, 519-528 insertion anchors
CITATION: docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md | line 231 AC heading; lines 233-251 nineteen AC items; line 253 Risks heading
CITATION: .claude/skills/acceptance-criteria-tracking/SKILL.md | lines 56-59 check-off protocol; line 71 check-off timing
CITATION: .claude/rules/plan-acceptance-gates.md | lines 40-41 G8 and G8b
CITATION: tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json | line 570 after key
CITATION: tests/scripts/dev_tools/test_blast_radius_verification_integrity.py | 273 lines (P0-T4/P8-T2 line-count scope)
CITATION: tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 | 409 lines (P0-T4/P8-T2 line-count scope)
CITATION: docs/features/completed/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t5.python-format-check.2026-04-18T18-50.md | line 8 black clean-run summary literal
CITATION: docs/features/completed/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t7.python-typecheck.2026-04-18T18-50.md | line 7 pyright clean-run summary literal
AC-INVENTORY: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19
AC-MAPPING: AC-1 | IMPLEMENTATION: P0-T5, P0-T12, P0-T18 | TESTS: P0-T5, P0-T12, P0-T18 | EVIDENCE: evidence/baseline/repro-classifier
AC-MAPPING: AC-2 | IMPLEMENTATION: P1-T1, P2-T1, P2-T2 | TESTS: P1-T8, P2-T4 | EVIDENCE: evidence/regression-testing/python-fail-before
AC-MAPPING: AC-3 | IMPLEMENTATION: P1-T6, P3-T1, P3-T2 | TESTS: P1-T10, P3-T4 | EVIDENCE: evidence/regression-testing/pester-pass-after
AC-MAPPING: AC-4 | IMPLEMENTATION: P1-T5, P2-T2 | TESTS: P1-T8, P2-T4 | EVIDENCE: evidence/regression-testing/python-pass-after
AC-MAPPING: AC-5 | IMPLEMENTATION: P1-T5, P3-T2 | TESTS: P4-T11, P7-T5 | EVIDENCE: evidence/regression-testing/pester-fixture-suites-after
AC-MAPPING: AC-6 | IMPLEMENTATION: P3-T3 | TESTS: P3-T4 | EVIDENCE: evidence/regression-testing/pester-pass-after
AC-MAPPING: AC-7 | IMPLEMENTATION: P2-T3 | TESTS: P2-T5 | EVIDENCE: evidence/regression-testing/python-unit-after
AC-MAPPING: AC-8 | IMPLEMENTATION: P1-T2, P1-T6 | TESTS: P1-T9, P2-T5, P3-T4, P8-T4 | EVIDENCE: evidence/qa-gates/unmodified-tests
AC-MAPPING: AC-9 | IMPLEMENTATION: P1-T3, P1-T4, P1-T6, P1-T7 | TESTS: P2-T4, P3-T4 | EVIDENCE: evidence/regression-testing/python-pass-after
AC-MAPPING: AC-10 | IMPLEMENTATION: P2-T2, P3-T2, P5-T5 | TESTS: P8-T3 | EVIDENCE: evidence/qa-gates/allowlist-removed
AC-MAPPING: AC-11 | IMPLEMENTATION: P5-T4, P5-T5, P5-T6 | TESTS: P5-T7, P8-T5 | EVIDENCE: evidence/qa-gates/mirror-equality
AC-MAPPING: AC-12 | IMPLEMENTATION: P5-T2, P5-T3 | TESTS: P5-T8 | EVIDENCE: evidence/regression-testing/docs-literals
AC-MAPPING: AC-13 | IMPLEMENTATION: P4-T3, P4-T4, P4-T5, P4-T6 | TESTS: P4-T10, P4-T11 | EVIDENCE: evidence/regression-testing/historical-repin
AC-MAPPING: AC-14 | IMPLEMENTATION: P4-T7, P4-T8, P4-T9 | TESTS: P4-T12, P6-T9, P7-T5 | EVIDENCE: evidence/regression-testing/other-suites-after
AC-MAPPING: AC-15 | IMPLEMENTATION: P2-T1, P2-T2, P2-T3 | TESTS: P6-T6, P6-T7, P6-T8 | EVIDENCE: evidence/qa-gates/python-coverage-derived
AC-MAPPING: AC-16 | IMPLEMENTATION: P3-T1, P3-T2, P3-T3 | TESTS: P7-T5 | EVIDENCE: evidence/qa-gates/pester-coverage
AC-MAPPING: AC-17 | IMPLEMENTATION: P2-T1, P2-T2, P2-T3 | TESTS: P6-T1, P6-T2, P6-T3, P6-T4, P6-T6 | EVIDENCE: evidence/qa-gates/ruff
AC-MAPPING: AC-18 | IMPLEMENTATION: P3-T1, P3-T2, P3-T3 | TESTS: P7-T1, P7-T2, P7-T3, P7-T4, P7-T5, P7-T7 | EVIDENCE: evidence/qa-gates/powershell-analyze
AC-MAPPING: AC-19 | IMPLEMENTATION: P1-T7, P2-T2, P3-T2 | TESTS: P8-T2 | EVIDENCE: evidence/qa-gates/line-counts
UNRESOLVED-GAPS: NONE
