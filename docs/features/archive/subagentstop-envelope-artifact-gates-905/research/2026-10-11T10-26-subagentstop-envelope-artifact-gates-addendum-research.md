# Research Addendum: Corpus Runs and False-Positive Rules for the E3 Artifact Gates (#905)

Addendum to `research/2026-10-11T12-05-subagentstop-envelope-artifact-gates-research.md`; it does not replace it. Scope: the epic coordinator's decision that each of the four validators is run against existing artifacts on main, and false positives are removed, before any of them switches to exit-2 blocking.

Method and limits. All citations are `path:line` in this worktree (branch `bug/subagentstop-envelope-artifact-gates-905`). This agent had Read/Grep/Glob only; it could not run `git`, so it did not read `origin/main` (2ef8d361e) directly. The inventory in section 2 is the orchestrator's recorded result; the worktree listing is used as a cross-check.

## 1. Documented research-file convention

- `.claude/agents/task-researcher.md:30-31`: feature research at `docs/features/<feature>/research/<timestamp>-<short-name>-research.md`; one-off research at `docs/research/<timestamp>-<short-name>-research.md`. `:33`: "The filename convention `<timestamp>-<short-name>-research.md` is unchanged."
- `.claude/skills/research-issue/SKILL.md:27-28` gives the same two forms; `:29` repeats that the convention is unchanged.
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` has no research-path text (Grep for `research`: no match). It defines the timestamp as `yyyy-MM-ddTHH-mm` (`:46-47`) and uses the `<kind>.<timestamp>.md` shape for other artifacts (`:144`, `:169`). That shape is the likely origin of `research.<TS>.md`, but no file documents it for research.
- `.claude/skills/orchestrate/SKILL.md:130` names only the research root (feature or `docs/research/`), not a filename.
- No `.claude/**`, `.agents/**`, `.codex/**` or `.github/**` Markdown file documents `research.<TS>.md` (Grep for `research\.(<|\{|\$|20)` over those trees: no match).
- The Copilot surface documents a different form: `YYYYMMDD-<short-feature-name>-implementation-research.md` (`.github/prompts/research-issue.prompt.md:38-39`) and `YYYYMMDD-task-description-research.md` (`.github/agents/task-researcher.agent.md:87-88`).

**Authoritative source:** `.claude/agents/task-researcher.md:30-33`. It is the persona that the validator gates (registered in its frontmatter, existing research §2.4), and `research-issue/SKILL.md:27-29` restates it. Documented form: `<timestamp>-<short-name>-research.md`, where `<timestamp>` is `yyyy-MM-ddTHH-mm` per `evidence-and-timestamp-conventions/SKILL.md:46`.

## 2. Inventory of research-file forms on main

Orchestrator command (verbatim):

```
git ls-tree -r --name-only origin/main -- docs | grep -E '/research/[^/]+$' | sed -E 's#.*/research/##' | sed -E 's/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}/<TS>/g; s/[0-9]{4}-[0-9]{2}-[0-9]{2}/<DATE>/g' | sed -E 's/^<TS>-.*-research\.md$/<TS>-<short-name>-research.md/; s/^<DATE>-.*-research\.md$/<DATE>-<short-name>-research.md/' | sort | uniq -c | sort -rn
```

Orchestrator result (verbatim): 235 files total under `*/research/`: 99 `<TS>-<short-name>-research.md`; 65 `research.<TS>.md`; 17 `<DATE>-<short-name>-research.md`; 2 `research-input.md`; 2 `research.<DATE>.md`; 1 `research-addendum.<TS>.md`; 1 `research-findings.md`; about 15 `YYYYMMDD-<short-name>-research.md` (compact date); and a long tail of single free-form names (for example `parallel-planner-surface.<TS>.md`, `hook-surface-inventory.<DATE>.md`, `orchestration-mechanics.research.md`, `claude-ecosystem.md`). `<TS>` = yyyy-MM-ddTHH-mm, `<DATE>` = yyyy-MM-dd.

Worktree cross-check: Grep `files_with_matches` over `docs/**/research/*` returned 239 files. The difference of 4 is consistent with the four epic-child research files added after main (`subagentstop-envelope-{artifact-gates-905,orchestrator-family-903,feature-review-coverage-896,core-897}/research/*`). That match is inferred, not verified with git. The worktree listing also shows forms that the orchestrator's sed does not collapse:
- compact time `<DATE>THHmm-<name>-research.md`: 3 files (`2026-07-04-bundle-model-routing-deps-312/research/2026-07-04T2240-…`, `…T2300-…`, `2026-07-17-legacy-discovery-publishing-372/research/2026-07-17T1930-…`);
- `<TS>-<name>.research.md`: 2 files (`…-621/research/2026-09-29T14-25-exclusion-manifest-design.research.md`, `…-512/research/2026-09-29T19-20-noqa-e501-rename.research.md`);
- compact date `YYYYMMDD-<name>-research.md`: 20 files (17 under `docs/research/`, plus `…-606`, `…-232`, `…-614`).

## 3. `validate-task-researcher-output.ps1`

All line numbers are from `.claude/hooks/validate-task-researcher-output.ps1` (294 lines).

**Path extraction.** `Get-ResearchPathFromOutput` (`:37-58`) runs one case-insensitive regex (`:45-46`): `research-path\s*[:=]\s*["']?([^\s"'\)`]+)` or the Markdown link `\[research-path\]\(([^)]+)\)`. It returns the first match only. The token can be anywhere in the text, not only at the start of a line. The path is used as given, with no root resolution.

**Lines 95-98 (re-derived; unchanged).** `Test-IsValidResearchFileName` (`:85-99`) normalizes `\` to `/` (`:93`), takes the file name (`:94`), and requires `^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$` (`:95-98`). This is the documented form only.

**Other checks, in order, in `Invoke-TaskResearcherOutputValidation` (`:226-282`):**
1. The payload is not empty (`:233-235`), parses as JSON (`:237-242`), and has a non-empty `output` (`:244-250`).
2. A `research-path` token is present (`:252-255`).
3. Root check `Test-IsUnderResearchRoot` (`:60-83`): the path is under `docs/features/` and contains `/research/` (`:76-78`), or is under `docs/research/` (`:79-80`). The check is `StartsWith`, so the path must be repo-relative.
4. Filename (`:261-263`).
5. The file exists, through the `Test-ResearchFile` seam (`:26-35`, `:265-267`), with `Test-Path` resolved against the process working directory.
6. `Test-AutomationFeasibilitySection` (`:101-162`, called at `:269-272`). It applies only when the file name or the agent output matches `autonomous-execution|human-interaction` (`:136-140`). When it applies, the file must contain a heading that matches `(?m)^\s{0,3}#{2,}\s+Automation\s+Feasibility\s*$` (`:151-155`). Content is read through the injectable `-ReadFileContent` seam (`:133`, `:146`).
7. `Test-NumericDerivationEvidence` (`:164-224`) is called at `:274-279` with a direct `Test-Path`/`Get-Content`, outside both seams. It applies only when the file has a line `- Numeric spec.md acceptance criterion: …<digit>` (`:173-176`). Of the research files in the worktree, 4 carry that label (Grep).

**Pure entry points (no stdin needed):** `Invoke-TaskResearcherOutputValidation -RawPayload <json>` (`:226-231`), and the helpers `Get-ResearchPathFromOutput -AgentOutput`, `Test-IsUnderResearchRoot -Path`, `Test-IsValidResearchFileName -Path`, `Test-AutomationFeasibilitySection -ResearchFilePath -AgentOutput [-ReadFileContent]` and `Test-NumericDerivationEvidence -Content`. The dot-source guard is at `:284-286`. After E3, the new pure entry should take the assistant text as a parameter, per the epic contract (existing research §1.3).

**What the validator inspects.** It validates the one path named in the final message (name, root, existence, and that file's content). It does not scan the research tree. **Corpus definition:** for each tracked file under `docs/**/research/` on main, build a synthetic final message `research-path: <repo-relative path>`. Wrap it in the post-E3 envelope (`last_assistant_message`), or pass it as the text parameter of the pure entry. Run with the working directory at the repo root so that step 5 resolves.

**Proposed accepted-filename rule** (replaces the regex at `:95-98`; anchored and case-sensitive, as now):

```
^(?:(?:\d{4}-\d{2}-\d{2}(?:T\d{2}-?\d{2})?|\d{8})-[A-Za-z0-9][A-Za-z0-9-]*[-.]research|research(?:-addendum)?\.\d{4}-\d{2}-\d{2}(?:T\d{2}-\d{2})?)\.md$
```

- Accepts the documented `<TS>-<name>-research.md`, plus `<DATE>-…-research.md`, `YYYYMMDD-…-research.md`, `<DATE>THHmm-…-research.md`, `<TS>-<name>.research.md`, `research.<TS>.md`, `research.<DATE>.md` and `research-addendum.<TS>.md`.
- Keeps two invariants: a leading or trailing date stamp, and the word `research` in the name.
- Keeps rejecting the unstamped names used by the current tests (`foo.md`, `bad-name.md`: `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1:94`, `:184`, `:207`), so no current test changes meaning.

**Names the rule would still reject:** 26 files in this worktree. None is an epic-child file, so the same 26 are expected on main; this was not verified with git. They fall into four groups:
- Unstamped (9): `research-input.md` (×2: `-361`, `-366`), `research-findings.md` (`-344`), `orchestration-mechanics.research.md` and `concurrency-and-hardening.research.md` (`-275`), `model-selection-enforcement.research.md` (`-305`), `python-to-typescript-inventory.md` (`-240`), `docs/research/push-down-claude-dir-149.md`, `docs/features/research/claude-ecosystem.md`.
- Stamp suffix on a free-form name (8): `pr-author-receipt-and-governance-inventory.2026-06-27.md` (`-261`), `hook-surface-inventory.2026-06-27.md` (`-259`), `caller-site-invocation-correctness.2026-08-29T16-30.md` (`-597`), `pr-context-bucket-gap.2026-09-06.md` (`-633`), `mermaid-validation-technology.2026-08-19T08-39.md` and `claude-runtime-integration-mechanics.2026-08-19T08-39.md` (`-491`), `parallel-planner-surface.2026-08-07T12-30.md` (`-443`), `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`.
- Stamp prefix without a `research` suffix (9): `2026-08-23T23-25-fix-all-cancel-propagation-race.md` (`-505`), `2026-09-06-detached-worktree-classification-and-consolidation-ordering.md` and `2026-09-06-cleanup-run-observations-user-context.md` (`-630`), `2026-07-07-implementation-surface-mapping.md` (`-331`), `2026-10-09T05-40-root-prettier-fixture-exclusion.md` (`-848`), `2026-07-22-npm-audit-fix-strategy.md` (`-397`), and three `docs/research/2026-07-09-*-audit.md`.

These 26 are enumerated from one manual classification of the 239-entry listing. No independent second derivation was done, so the count must not be written into `spec.md` as a numeric criterion. Instead, phrase the AC as: "every corpus rejection is recorded with its path and matches a name with no date stamp or no `research` token".

Rejected alternative: accept any `*.md` under a research root. This removes the naming convention entirely, and the documentation (`task-researcher.md:33`) states that the convention is unchanged.

## 4. `validate-prd-feature-output.ps1`

**Line 68 (re-derived; unchanged).** `Test-SpecNumericCriterion` (`:62-69`) takes the `## Acceptance Criteria` section, ending at the next `## ` heading (`:67`). It returns true when any checkbox line `^\s*[-*]\s*\[.\]` contains `\b\d+\b` (`:68`). It reads only `spec.md`; `user-story.md` is never consulted (`:82-85`). When the function returns true, `research-path:` must be a line-start label (`Get-ArtifactPathFromOutput`, `:13-21`, `:86-87`), and that file must pass `Test-NumericDerivationEvidence` (`:23-60`):
- 11 labelled fields (`:30-41`);
- a scope matching `(entire|all|complete)…(repository|repo|source tree|tree)` (`:42`);
- no `single|narrow|named-pattern` strategy (`:45`), and distinct strategies (`:46`);
- every family member named in both strategies (`:47-50`);
- integer counts equal to the member-set sizes (`:51-54`), and equal member sets (`:55-57`);
- a comparison stating equal/match/identical (`:58`).

**Documented intent.** The requirement applies to a criterion that "contains a numeric count, enumeration, or population" (`.claude/agents/prd-feature.md:32`; same wording at `.claude/skills/fill-feature-docs/SKILL.md:15`, `.claude/skills/research-issue/SKILL.md:58`). Line 68 is broader than that intent.

**Survey.** Grep for the line-68 pattern over `docs/features/**/spec.md` found 1943 checkbox lines in 188 files (all sections; an upper bound for the AC-section count, and including the four epic-child specs). Numeral kinds observed:

| Kind | Example (path:line) | `\b\d+\b` hit |
|---|---|---|
| Threshold | `…-847/spec.md:143` (`>= 85%`); `…-905/spec.md:206-207` (85%, 500 lines) | yes |
| Exit code | `…-905/spec.md:190` (`exits 2`); `…-510/spec.md:173` (`exits 0`) | yes |
| Issue/PR number | `…-905/spec.md:210` (`#897`) | yes |
| AC identifier | `…-847/spec.md:142` (`AC-01`); `…-697/spec.md:295` (`AC-5.4`) | yes |
| File:line | `…-422/spec.md:198` (`typescript.md:57`); `…-409/spec.md:202` (`Pester.psm1:8567-8588`) | yes |
| Version | `…-173/spec.md:188` (`>=18.0.0`) | yes |
| Date in a path | `…-269/spec.md:220`; `…-136/v2/spec.md:338` | yes |
| Section ref | `…-697/spec.md:295` (`§12`) | yes |
| Task/receipt IDs `P1-T2`, `E4-ST3`, `AC11`, `.ps1` | `…-896/spec.md:226`; `…-823/spec.md:214` | no (digit adjacent to a letter) |
| Derived population count | `…-158/spec.md:178` ("All 12 agent files"); `…-501/spec.md:200` ("Each of the 24 PreToolUse hooks"); `…-790/spec.md:206` ("exactly 2 entries", which cites its derivation evidence); `…-823/spec.md:214` ("Each of the 8 edited repo-local files"); `…-509/spec.md:315` ("None of the nine Python files") | yes, except word numerals |

E3's own spec triggers line 68 through exit codes and thresholds alone (`…-905/spec.md:190`, `:206`), with no population count. That is a direct false positive.

**Proposed definition (mechanically decidable).** Keep the existing AC-section and checkbox scoping (`:67-68`). A checkbox line is a *derived numeric criterion* if and only if it matches (case-insensitive):

```
\b(?:all|exactly|each of the|of the|the|these|those|only)\s+(?:[1-9]\d*|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty)\s+(?:[\w`.\/-]+\s+){0,3}?(?!(?:seconds|minutes|hours|days|lines|bytes|characters|percent)\b)[A-Za-z][\w-]*s\b
```

That is: a determiner, then a cardinal (digits or an English cardinal from two to twenty), then a plural noun within three words, where the noun is not a unit of size or duration.

- **Must not trigger:** thresholds and comparators (`>= 85%`, "at or above 85%", "<= 500", "500-line"), exit codes, `#n` references, AC/task/receipt identifiers, `file:line`, versions, dates and timestamps, path segments, `§n`, "zero"/0, durations and size units. Each of these fails the determiner + cardinal + whitespace + plural sequence; for example, `85%` and `500-line` have no whitespace after the number.
- **Must trigger:** `…-158/spec.md:178`, `…-501/spec.md:200`, `…-790/spec.md:206`, `…-823/spec.md:214`, `…-697/spec.md:295` ("The 12 entries"), `…-509/spec.md:315`.
- Known breadth: lines that list their members inline also trigger, for example `…-896/spec.md:222` ("The four Claude hook suites (…)") and `…-510/spec.md:173` ("The three affected test files"). These are enumerations under the documented intent (`prd-feature.md:32`), so they are true positives, not false positives.

**Pure entry and corpus.** `Test-SpecNumericCriterion -SpecContent` (`:62-69`) is pure; `Test-NumericDerivationEvidence -Content` (`:23-60`) is pure. `Invoke-PrdFeatureOutputValidation -RawPayload` (`:71-89`) reads disk and calls the dependency guard first (`:75-76`). The corpus has two parts:
- (a) **Trigger corpus:** every `docs/features/**/spec.md` on main, passed through the new criterion function. Record each triggering line. Pass condition: no triggered line lacks a determiner + cardinal + plural count.
- (b) **Evidence corpus:** every tracked research file containing `## Numeric Derivation Evidence` (62 in this worktree, 3 of them epic-child files), passed through `Test-NumericDerivationEvidence`. Every failure is recorded, and is classified as either a defect in the checker or in the artifact.

Specs that trigger in (a) but have no evidence are reported and not treated as gate failures. The hook only evaluates a spec named in a new prd-feature run, and the evidence requirement appears to post-date many of those specs (the contract test is `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:71`, from feature `2026-08-29-claude-planning-integrity-593`).

## 5. Discovery and pr-author validators

**`validate-discovery-artifact-gate.ps1`.**
- Pure entry: `Invoke-DiscoveryArtifactGateValidation -RawPayload [-RequiredArtifactReader]` (`:194-248`). The text scan is `Find-DiscoveryArtifactReference -OutputText` (`:156-192`), which is pure.
- In production the declaration reader always returns absent: the default `ProfileReader` is `{ $null }` (`:144`, `:147-151`, `:206`). The hook therefore allows every non-empty, well-formed payload (`:232-236`). Blocking happens only through payload errors or the dependency guard.
- Tracked corpus: none. No file exists at a `discovery/<type>` path (Glob over the eight type prefixes matched only `scripts/dev_tools/discovery/profile_cli.py`), and no fixture or `docs/discovery`/`discovery/` tree exists.
- Latent false positive: `Get-DiscoveryArtifactType` (`:116`) matches `(^|/)discovery/profile` as a prefix. A final message that mentions `scripts/dev_tools/discovery/profile_cli.py` would be classified as a `profile` artifact. With a declaration present, the hook would then validate a `.py` file. With the default reader this cannot happen.
- Proposed substitute: synthetic final messages built from the text of the 13 tracked files that mention a `discovery/<type>` path (Grep; for example `docs/features/completed/2026-07-17-legacy-discovery-hooks-366/spec.md`). Run them through `Find-DiscoveryArtifactReference` and record which tokens are classified. Then run the full entry with the default reader and expect allow on every message. Add one message containing `scripts/dev_tools/discovery/profile_cli.py` to pin the prefix behaviour. Rationale: this exercises real repository prose against the only code path that is live in production.

**`validate-pr-author-output.ps1`.**
- Pure entry: `Get-PrAuthorOutputDecision -HookInputRaw` (`:72-125`). The detector `Test-PrAuthorOutputReportsPr -OutputText` (`:32-70`) is pure.
- Tracked corpus: none. `/artifacts` is gitignored (`.gitignore:6`). The only tracked `pr_body_*.md` files are three test fixtures under `tests/fixtures/worktree-resolution/pr-author/*/artifacts/`. Those are PR bodies, not final messages. No evidence file records a pr-author final message; the closest, `…-824/evidence/other/pr-author-hook-live-smoke.2026-10-08T22-52.md:22-30`, records a command outcome.
- Proposed substitute: synthetic final messages in the two forms the persona is told to report (`.claude/agents/pr-author.md:87-88`: a PR URL and `PR #<n>`), plus the `gh pr create`/`gh pr edit` + `#n` form (`:65`), each expected to allow. Add a `Refs #897`-only message, expected to block. Use real PR numbers from tracked evidence (for example `…-606/evidence/issue-updates/pr-607.2026-08-30T08-54.md`).
- Observation for the plan (no change proposed): `:60` allows any text containing `PR #n`, including a message that only refers to an earlier PR.

## 6. Policy-file check

- `.claude/rules/**`: no match for `-research\.md`, `research\.<`, or numeric-derivation text (Grep).
- `.github/instructions/**` and `.github/copilot-instructions.md`: no match. The only `.github` matches are `.github/prompts/research-issue.prompt.md:38-39` and `.github/agents/task-researcher.agent.md:87-88` (the `YYYYMMDD-…-research.md` form). These are prompt/agent files, not policy files; the proposed rule already accepts that form.
- **Neither rule change requires a policy-file edit.**
- Non-policy text affected:
  - The rejection message at `validate-task-researcher-output.ps1:262` names only `<timestamp>-<short-name>-research.md`. It stays accurate as a statement of the convention to write, but no longer describes the full accepted set.
  - `task-researcher.md:33` and `research-issue/SKILL.md:29` remain correct as writer instructions.
  - `prd-feature.md:32`, `fill-feature-docs/SKILL.md:15` and `research-issue/SKILL.md:58` already describe "count, enumeration, or population"; the proposed rule aligns the hook to them.
- Message strings pinned by `test_claude_planning_integrity_contracts.py` must be preserved (E3 spec AC at `…-905/spec.md:202`).
- Both hooks have byte-identical mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` (Grep hits at the same line numbers, `:180` and `:29`) that must change in step (`…-905/spec.md:203`).

## 7. Re-derived line numbers on this branch

| Hook | `.output` read | `$env:CLAUDE_HOOK_INPUT` | `exit 1` |
|---|---|---|---|
| `validate-discovery-artifact-gate.ps1` | `:222-225` (presence `:223`, read `:224`) | `:258` | `:261` (after `Write-Error` `:260`) |
| `validate-pr-author-output.ps1` | `:109` | `:135` | `:139` (after `Write-Error` `:138`) |
| `validate-prd-feature-output.ps1` | `:80` | `:95` | `:96` (same line as `Write-Error`) |
| `validate-task-researcher-output.ps1` | `:244-247` (presence `:245`, read `:246`) | `:288` | `:291` (after `Write-Error` `:290`) |

These match the existing research (§2.1-2.4, lines 40-77): no change. The filename regex is still at `:95-98` and the numeric test is still at `:68`.

## Automation Feasibility

No human interaction is required. Every corpus run above uses pure functions or synthetic payloads against tracked files, from the repo-root working directory. The orchestrator must run the `git ls-tree origin/main` enumeration (section 2) itself, because this agent could not execute git. The live per-agent smoke runs remain the follow-up already recorded at `…-905/spec.md:186`; they are not a merge gate.
