# Research: enforcement-hook trigger matches whole command text (Issue #545)

- Date: 2026-08-25
- Author: task-researcher
- Requirements source: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/issue.md`
- Related: issue #539 (spec D8, D4 rule-table row 14), PR #544

## 1. Current State Analysis

### 1.1 The classifier and its five trigger patterns

`Test-ImplementationCommand` (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`,
lines 112–145) trims the command text and matches five regexes against the entire string
(`$normalizedCommand`). A match on any pattern classifies the invocation as implementation and
requires a ready checkpoint. The only mitigation is the issue #539 allow-side exemption
(`Test-ExemptOrchestrationStagingCommand`), reachable only from pattern index 0.

Per-pattern exposure, characterized individually:

| # | Pattern | Over-match exposure | Under-match exposure |
| --- | --- | --- | --- |
| 1 | `(^|\s)git\s+(add\|commit)\b` | Any quoted string, heredoc body, JSON value, or prose containing the two adjacent words `git add` / `git commit` classifies (the `(^\|\s)` anchor is satisfied by any whitespace, including whitespace inside quotes). | Adjacency is required, so any git global option between name and subcommand defeats the trigger: `git -C <dir> add`, `git --git-dir=<x> commit`, `git --work-tree=<x> add` all pass by non-match. Also `(git add .)` and `$(git add .)` pass: the char before `git` is `(`, not whitespace or start. |
| 2 | `(^|\s)(poetry\s+run\s+)?(black\|ruff\|pyright\|pytest)\b` | Most severe over-match: the bare words match anywhere, including the English word `black` in prose (`echo "black box"` is denied) and any JSON/heredoc mention of `pytest`, `ruff`, `pyright`. The optional `poetry run` prefix means the tool word alone triggers. | Effectively none: the bare tool name matches regardless of intervening options (`poetry run -q pytest` matches on the bare `pytest`). |
| 3 | `(^|\s)npm\s+.*\s+(prettier\|lint\|typecheck\|test:unit)\b` | `.*` spans quotes AND segment boundaries: `npm --version && echo lint` classifies; any line mentioning `npm` anywhere plus a later `lint`/`test:unit` token anywhere (quoted or not) classifies. | The two mandatory `\s+` runs mean bare `npm lint` (no token between) does NOT match and passes by non-match. |
| 4 | `(^|\s)npx\s+(prettier\|eslint\|tsc\|jest)\b` | Quoted/heredoc mentions of `npx prettier` etc. classify. | Adjacency required: `npx --yes prettier` and `npx -p <pkg> eslint` pass by non-match. |
| 5 | `(^|\s)pwsh\s+.*(Invoke-Pester\|tests/scripts/)` | `.*` spans quotes and segments: any line containing `pwsh` anywhere plus `Invoke-Pester` or `tests/scripts/` anywhere later (including in prose or a heredoc) classifies. | Minimal in practice. Note the legitimate deny case `pwsh -NoProfile -Command "Invoke-Pester ..."` carries its payload INSIDE double quotes — any fix must keep classifying it (see the wrapper carve-out in section 3). |

The verified over-match instances from 2026-08-24 (issue.md): a JSON receipt value containing
`--body-file` (sibling hook), promotion tool names as receipt values (promotion hook), a memory
file quoting the staging literal, and a heredoc JSON body mentioning a Python tool name (pattern
2). The verified under-match record is spec #539 D4 row 14: a bare relocating spelling "never
reaches this classifier and passes by non-match — a pre-existing trigger limitation recorded with
D8."

### 1.2 The four gate copies and the parity mechanisms

The gate ships as two deliberately divergent PAIRS, not four copies of one file:

| Copy | Path | Trigger patterns | Notes |
| --- | --- | --- | --- |
| Claude canonical | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (382 lines) | Holds the five patterns inline in `Test-ImplementationCommand`; delegates the #539 exemption to the dot-sourced sibling helper | `HookPayload.psm1` transport |
| Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | Same | Must be byte-identical to Claude canonical |
| Codex canonical | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (382 lines) | Same five patterns inline, PLUS two upstream `apply_patch` marker legs (`*** Add/Update/Delete File:`, `*** Move to:`) before the pattern loop | stdin transport; content diverges from the Claude pair (equal line counts are incidental) |
| Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | Same | Must be byte-identical to Codex canonical |

The helper `enforce-orchestration-preimplementation-gate-helpers.ps1` (349 lines) exists in all
four locations with identical content; identity is enforced per pair, not across pairs.

Parity enforcement mechanisms a change must keep green:

- **Codex pair**: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (494 lines) —
  the It `'keeps the canonical hooks byte-identical to their bundled copies'` (line 111) hashes
  every name in `$script:StaticCheckNames` (`AllHookNames` + `$script:SharedModuleNames`, line 30)
  with `Get-FileHash` against the codex bundle; a second It (line 134) requires every shared
  module name to appear in the codex pack manifest
  `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
  The same suite parses each file and enforces the 500-line cap.
- **Claude pair**: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` asserts
  a byte-identical mirror of every non-memory `.claude/**` file into the claude bundle
  (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`), and the claude pack
  manifest `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
  already lists the gate and its helper (lines 35–36).
- **Coverage denominators**: both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  (lines 131, 135, 202, 206) and its mirror under
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` list the
  four canonical gate/helper paths; any new production helper file must be added to BOTH lists.
- **No-Python guard**: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
  scans hook files; any new helper must not invoke Python.

Consequence: introducing one new shared helper requires SIX registrations — (1) claude pack
manifest, (2) codex pack manifest, (3) `$script:SharedModuleNames` in
`legacy-codex-hook-contracts.Tests.ps1`, (4)+(5) both coverage lists, (6) the two bundle copies
themselves. This is the same checklist the #539 helper followed.

### 1.3 The sibling hook family (every hook classifying Bash by whole command text)

| Hook | Trigger mechanism | Confirmed over-match? | Under-match / bypass |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-pr-author-skill.ps1` + `enforce-pr-author-skill-helpers.ps1` (`Get-PrAuthorBypassReason`, lines 170–178) + `enforce-pr-author-skill.epic-base-branch.ps1` (line 67) | `(?i)\bgh\s+pr\s+create\b`, `\bgh\s+pr\s+edit\b`, `--body-file\b`, `--body(?!-file)\b` over whole text | YES — JSON receipt string quoting a body-file invocation blocked with `PR_BODY_PATH_NONCANONICAL` | `gh --repo <o/r> pr create` / `gh -R <o/r> pr create` never match (adjacency), so the PR-body gate is bypassable by a relocating spelling. Claude-side only; no `.codex` copy exists. |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` (lines 94, 101, 111) and its `.codex` + two bundle copies | `IndexOf` substring scan for four tool-name tokens; `\bgh\s+issue\s+(create\|new)\b`; a lookahead `gh api ... POST` pattern | YES — promotion tool names supplied as receipt VALUES were blocked | `gh --repo <o/r> issue create` never matches (adjacency). |
| `.claude/hooks/enforce-epic-merge-gate.ps1` (lines 146, 154) | `\bgh\s+pr\s+merge\b` + PR-number harvest over whole text | Not observed | `gh --repo <o/r> pr merge` unmatched; also matches mentions in prose (deny-biased). |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (line 63), `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (line 70) | `\bgit\s+worktree\s+remove\s+(?<path>\S+)` | Not observed | `git -C <x> worktree remove` unmatched — removal gates bypassable by relocation. |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` (lines 108, 133) | `Contains` token scan for disposition/confirm tokens | Not observed | Token-anywhere semantics; over-match direction forces confirmation (deny-biased). |
| `.claude/hooks/validate-bash.ps1` (line 73) and `.codex` copy | `Contains` substring blocklist (`rm -rf`, `git push --force`, ...) | Prose mentioning a blocked literal is denied (fail-closed) | Trivial respellings already pass; out of scope by design (documented as a deterrent). |

### 1.4 Existing in-repo parsing machinery

`Test-ExemptOrchestrationStagingCommand` and its helpers
(`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`) already implement:
quote-tracked segment splitting on `; & | \r \n` (`Split-OrchestrationCommandLine`), balanced-quote
token extraction (`ConvertTo-OrchestrationCommandToken`), a positive option table with
deny-on-unmodeled-token semantics, and unresolvable-character rejection (`$ ` `` ` `` `> <`). It
does NOT handle heredocs, subshell/group openers, `$(...)`, or env-assignment prefixes, and it is
confined to the allow side. It is the proven idiom the trigger fix should extend, not replace.

## 2. Candidate Approaches

### 2.1 Rejected alternatives (brief)

- **A. Naive segment-leading classifier** (classify only when a segment's leading word is a
  governed command): rejected as-is — this is exactly the fail-open change D8 warned about.
  `echo x | xargs git add` (denied today) and `bash -c 'git add .'` (denied today) would newly
  pass; pattern 5's standard spelling `pwsh -Command "Invoke-Pester ..."` would stop
  classifying. Wrapper modeling can repair it, but the repair converges on approach C with more
  moving parts and a larger behavioral diff against the existing deny suites.
- **B. Promote the #539 exemption parser wholesale to be the classifier** (every command line must
  fully parse or deny): rejected — the #539 parser is deliberately total ("every segment must
  parse in its entirety"), which is correct for an allow-side exemption but would deny nearly
  every ordinary command (any `echo`, any `ls`) if used as the trigger, or require modeling the
  entire command universe.
- **C-py. Any Python leg**: prohibited by standing policy (enforcement hooks must not use Python;
  bash preferred, PowerShell acceptable). Not considered.

### 2.2 Recommended approach: masked-trigger scanning with a wrapper carve-out, plus structural relocation classification

Keep the five trigger regexes textually unchanged. Change WHAT TEXT they run against, and add one
structural classifier for the relocation under-match. Three cooperating pieces, all pure string
logic in one new dot-sourced sibling helper:

**Piece 1 — scanner.** A single left-to-right scan of the raw command text producing an ordered
list of segments. State tracked: single-quote span, double-quote span, heredoc pending/body
(delimiter stack), escape character. Segment delimiters outside quotes and heredoc bodies: `;`,
`&`, `|`, newline, and the subshell/group and substitution openers `(`, `)`, `{`, `}`, `$(`, and
backtick (treating openers as delimiters closes today's `(git add .)` and `$(git add .)`
non-match bypasses — a fail-closed widening). Each segment records: raw text, masked text (quoted
spans and attached heredoc bodies replaced by single spaces), token list (quote-stripped, in the
#539 idiom), and two flags: `HasLiveSubstitution` (a `$(` or backtick occurred inside one of its
double-quoted spans) and `Unbalanced`.

**Piece 2 — masked trigger evaluation, per segment.** For each segment choose the scan text:

- If the segment's leading command word (after skipping `VAR=value` env-assignment prefixes) is in
  the **wrapper carve-out set** — `sh`, `bash`, `zsh`, `dash`, `ksh`, `pwsh`, `powershell`,
  `xargs`, `env`, `command`, `eval`, `nohup`, `time`, `timeout` — use the segment's RAW text.
  A wrapper's quoted argument is a nested command line, so it must stay visible to the regexes.
  This is what preserves today's deny for `bash -c 'git add .'`, `xargs git add`, and
  `pwsh -NoProfile -Command "Invoke-Pester ..."` (existing test at
  `enforce-orchestration-preimplementation-gate.Tests.ps1` line 140).
- If the segment is `Unbalanced` or `HasLiveSubstitution`, use RAW text (fail-closed: text whose
  execution content cannot be resolved statically keeps today's whole-text behavior).
- Otherwise use MASKED text. A quoted string in a non-wrapper segment is an argument — data, not
  execution — so a governed token inside it is a mention, never an invocation.

Run the five unchanged patterns against each segment's chosen scan text; any match classifies.
Per-segment evaluation (rather than one whole-line masked string) also ends the cross-segment
`.*` bridging of patterns 3 and 5 (`npm --version && echo lint` stops classifying), which is
over-match removal, not a bypass: no governed command executes in that line.

**Piece 3 — structural relocation classifier (closes the under-match).** For each segment,
independent of piece 2: skip env-assignment prefixes and the transparent wrappers
`command`/`env`/`nohup`/`time`/`timeout`; if the first remaining token is `git`, absorb the
modeled git global options (`-C <arg>`, `-c <arg>`, `--git-dir[=…]`, `--work-tree[=…]`,
`--namespace[=…]`, `-p`, `--paginate`, `--no-pager`, `--exec-path[=…]`, `--literal-pathspecs`,
`--no-optional-locks`, `--bare`); the first non-option token is the subcommand — classify when it
is `add` or `commit`. An UNMODELED dash-leading token between `git` and the subcommand classifies
(fail-closed: over-classification only forces checkpoint readiness). A non-dash token that is not
`add`/`commit` terminates the scan without classifying — this is what prevents an arbitrary later
token from classifying (`git log --grep add` stops at `log`). Apply the same shape to the
pr-author trigger with the gh global options (`-R`, `--repo <arg>`) and subcommand path
`pr create` / `pr edit` if the sibling is in scope.

**Ordering and the #539 exemption.** The exemption layer is untouched and stays allow-side:
`Test-ImplementationCommand` classifies via pieces 2+3; when the classification came from the git
leg, `Test-ExemptOrchestrationStagingCommand` is still consulted exactly as today (relocating
spellings remain NEVER EXEMPT under D4 row 14, so a newly classified `git -C ../x add …` is
denied, which is the row's documented intent).

**Heredoc recommendation: full delimiter tracking, bounded.** Implement real heredoc handling in
the scanner: on `<<` or `<<-` (not `<<<`, which is a here-string with no body) outside quotes,
read the delimiter word (optionally quoted); from the next newline, mask lines until a line whose
content (after optional leading tabs for `<<-`) equals the delimiter; support multiple pending
heredocs on one physical line in order. An unterminated heredoc masks to end of text — this
matches shell semantics (the body is consumed to EOF and never executes). The narrower
alternative (fall back to whole-text matching whenever `<<` appears) is rejected because heredoc
bodies were the majority of the observed friction (the memory-file write and the JSON-body
instances); it would leave the primary reported defect in place. Residual risk of full tracking:
exotic forms (heredoc delimiter produced by expansion, `<<$VAR`) — mitigate by treating a
non-literal delimiter as unmaskable (raw text, today's behavior). One deliberate direction
reversal: `bash <<EOF …body… EOF` pipes the body INTO a shell; because `bash` is in the wrapper
carve-out set, that segment scans raw and the body stays visible — deny-biased, correct.

**File placement and size.** The scanner + wrapper table + structural classifiers are one new
dot-sourced sibling helper (working name
`enforce-hook-command-scanner.ps1`), estimated 250–350 lines including the mandated comment
density — inside the 500-line cap with headroom. If implementation pressure pushes it past ~450
lines, split scanner and classifiers into two sibling files (each needs the six registrations).
The gate file itself changes only inside `Test-ImplementationCommand` (~15 lines) and gains one
dot-source line; the #539 helpers file is unchanged. The sibling dot-sourced `.ps1` idiom is the
only sharing mechanism that works on both pairs (`.codex` has no `lib/`).

## 3. Fail-Open Analysis (D8 resolved)

D8's objection: scoping the trigger to a segment-leading command name is fail-open because
wrappers legitimately relocate the command name. The recommended model does NOT scope to
segment-leading names for the regex triggers — it masks only provably-inert text — so the
objection must be re-examined form by form:

| Form | Today | Under recommended model | Direction |
| --- | --- | --- | --- |
| `echo x \| xargs git add` | deny (regex hits ` git add`) | deny — `xargs` segment is wrapper-led, scans raw | neutral |
| `bash -c 'git add .'` / `sh -c "git add ."` | deny | deny — wrapper carve-out scans raw | neutral |
| `env git add .` / `command git add .` / `nohup git add .` | deny | deny — wrapper-led raw scan; also structural classifier skips transparent wrappers | neutral |
| `pwsh -NoProfile -Command "Invoke-Pester …"` | deny | deny — `pwsh` in wrapper set | neutral |
| `git -C ../x add .` (bare relocating spelling) | ALLOW by non-match (the confirmed latent bypass) | deny — structural classifier | fail-closed |
| `(git add .)`, `$(git add .)`, `` `git add .` `` | ALLOW by non-match | deny — openers are segment delimiters | fail-closed |
| `npx --yes prettier`, `gh --repo o/r pr create` (if sibling in scope) | ALLOW by non-match | deny — structural handling per hook | fail-closed |
| `echo "run git add docs/x"` ; heredoc prose ; JSON values (non-wrapper segments) | deny (the confirmed over-match) | allow — masked; the quoted span is an argument, not an execution | deliberate allowance, not a bypass: nothing on the line executes a governed command |
| `git${IFS}add`, `\git add`, obfuscated respellings | ALLOW today (no whitespace boundary / escaped name) | unchanged (already ungated; scoping widens nothing here — shown, not asserted) | neutral |
| `echo "$(git add .)"` (live substitution inside quotes) | deny | deny — `HasLiveSubstitution` forces raw scan | neutral |

**Conclusion: the net change is fail-closed.** Every form that newly passes is a quoted or
heredoc mention in a non-wrapper segment, which the shell never executes; every wrapper form that
D8 cited keeps today's deny; and four classes of genuine bypass (git relocation, subshell,
substitution, adjacency-defeating options) newly deny. The under-match closure is itself a
fail-closed change; measured exposure of newly denied legitimate commands: no `.claude` skill or
rule instructs a `git -C … add/commit`, `--git-dir`, or `--work-tree` staging form (verified by
grep across `.claude/**`), and during normal execution phases the checkpoint is ready, so the
gate allows anyway. The practical exposure is limited to relocating staging spellings issued
before readiness — precisely the case the gate exists to deny, and D4 row 14 already documents
those spellings as NEVER EXEMPT.

Residual accepted risks, recorded rather than hidden: (1) over-match persists inside wrapper-led
segments (`bash -c 'echo "pytest"'` still denies) — rare, deny-biased; (2) obfuscated
respellings (`git${IFS}add`) remain ungated exactly as today — the hook family is a policy
deterrent, not a security boundary (same posture as the pr-author receipt docs); (3) a wrapper
not in the carve-out set whose quoted argument is a command line (`parallel 'git add x'`) would
newly pass — no such wrapper appears in any repo skill or test; the set is a named constant so a
later addition is a one-line, test-pinned change.

## 4. Behavior Semantics (decision rules for the planner)

1. Masking never denies: it only removes matches. Every deny reachable today except the
   quoted/heredoc-mention class remains reachable.
2. The five pattern strings are byte-unchanged; only the scan text changes.
3. Unbalanced quoting, live substitution inside double quotes, or an unresolvable heredoc
   delimiter ⇒ that segment scans raw (today's behavior).
4. Structural git classification: env-prefix skip → transparent-wrapper skip → `git` → modeled
   global-option absorption → subcommand test; unknown dash token ⇒ classify; non-dash non-target
   token ⇒ stop without classifying.
5. The #539 exemption remains allow-side only and is consulted exactly where it is today.
6. Wrapper carve-out set and git/gh option tables are named script-scope constants, pinned by
   test.

## 5. Test Surface

### 5.1 Existing suites and what they assert

| File (lines) | Relevant assertions | Effect of this change |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` (461) | Denies unquoted `git add .`, `git commit -m "test"`, `poetry run black …`, `npm --prefix … test:unit …`, `pwsh -NoProfile -Command "Invoke-Pester …"` (lines 112–149) | All remain valid; the pwsh case is the wrapper-carve-out regression pin |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` (267) | D4 rows incl. 14a–14d chained relocating denials (lines 219–228) — remain valid. **Lines 245–266: heredoc prose deny (`cat <<'NOTE' … Run git add … NOTE`) is INVALIDATED — the expected decision reverses to allow** | Rewrite that It (and its D8 rationale comment) to assert the new allow; keep a sibling deny case where the heredoc feeds a wrapper (`bash <<EOF`) |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (271) | Same structure; heredoc case at ~line 249 likewise INVALIDATED | Same rewrite, codex idiom |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (494) | `Test-ImplementationCommand` table (lines 348–358: `git commit -m "wip"` true, `poetry run pytest` true, `echo hello` false, apply_patch legs) — remains valid. Byte-identity It (111), pack-manifest It (134), `$script:SharedModuleNames` (line 30) | Add the new helper name to `SharedModuleNames` and the codex pack manifest; file is at 494/500 lines — the array edit fits, but any new scenario needs a NEW test file |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` (223), `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` (242) | `file_path` branch only | Unaffected |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (447) + `.Payload` (103), `.OrchestratorStatePreflight` (104), `.epic-base-branch` (113) | All command fixtures are genuine unquoted `gh pr create/edit` invocations | All remain valid; new over-match/under-match cases go in a new file |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | Scans hook files for Python invocation | New helper must stay Python-free |

### 5.2 New test files (both existing gate suites are near the 500-line cap)

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`
  — over-match allow cases (quoted mention, heredoc body, JSON value, prose word `black`),
  under-match deny cases (`git -C … add`, `--git-dir`, `--work-tree`, subshell, substitution),
  and explicit wrapper deny pins (`xargs git add`, `bash -c 'git add .'`, `sh -c`, heredoc-into-
  bash) so the fail-open risk is pinned by test rather than prose.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`
  — same scenario set in the codex idiom (plus apply_patch-leg non-interference).
- `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` — quoted
  body-file mention allowed; `gh --repo o/r pr create` classified; wrapper deny pins.
- Scanner unit suite(s) for the new helper (segmentation, masking, heredoc table, tokenizer
  edge cases) — mirrored per side following the #539 precedent.

Coverage: line coverage >= 85% (no branch gate for Pester, but the new helper joins the
denominator in BOTH runsettings lists). Verification gotcha: the MCP PoshQC test runner reads the
installed extension's settings, so new coverage entries are invisible to it — coverage evidence
for the new file must be produced by invoking the self-hosted PoshQC module directly.

## 6. Documentation Surface

Files that document the whole-command-text behavior as intended or accepted:

| File | Current statement | Required correction |
| --- | --- | --- |
| `docs/features/active/2026-08-24-…-539/spec.md` line 128 (D4 row 14) | "…passes by non-match — a pre-existing trigger limitation recorded with D8, unchanged by this fix" | Additive supersession note: the bare relocating spelling now classifies (issue #545); the NEVER-EXEMPT disposition is unchanged |
| Same spec, deny-map line 150 (`allow-by-non-match` row) and line 153 (heredoc deny row) | Records allow-by-non-match and heredoc deny as current behavior | Same supersession annotation (do not rewrite the historical table; annotate) |
| Same spec, D8 (line 184–186) and Rollout line 278 | Defers the trigger scoping | Annotate as resolved by #545 |
| `docs/features/active/2026-08-25-…-545/spec.md` and `issue.md` | Defect description | Update with outcomes at close (plan phase 5) |
| Test comments citing D8 in both CommandExemption suites (claude line 247–251, codex ~249–253) | "deliberately NOT narrowed by this fix (D8)" | Rewritten together with the reversed assertion |
| `.claude/skills/epic-plan/SKILL.md` (176–201) and `.claude/skills/parallel-plan/SKILL.md` (~530) | Describe the #539 exemption only, not the trigger | No change required (verified) |
| `.claude/rules/**` | No rule file documents the trigger limitation (verified by grep; the "D4 rule table" lives in the #539 spec, not under `.claude/rules/`) | No rule-file edit required; recorded here so the plan does not hunt for one |

## 7. Requirements Mapping / File-by-File Impact

Production files:

1. NEW `.claude/hooks/enforce-hook-command-scanner.ps1` (name final at planning) — scanner,
   wrapper set, masked-trigger evaluator, structural git (and gh) classifier.
2. NEW `.codex/hooks/enforce-hook-command-scanner.ps1` — identical content.
3. NEW both bundle copies (claude-customizations, codex-and-agents-customizations).
4. `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — dot-source the scanner;
   rework `Test-ImplementationCommand` body (~15 lines); patterns unchanged.
5. `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` — same rework in the codex
   idiom (apply_patch legs untouched, upstream of the loop).
6. Both gate bundle copies (byte-mirrors of 4 and 5).
7. `.claude/hooks/enforce-pr-author-skill-helpers.ps1` — trigger decision (`isPrCreate`/
   `isPrEdit`) evaluated against scanner output; downstream flag/receipt parsing stays on raw
   text. Parent hook gains the dot-source line. Plus the claude bundle mirrors of both files.
8. Registrations: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`;
   `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`;
   `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`;
   `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.

Test files: the four new suites of section 5.2; edits to the two CommandExemption suites
(reversed heredoc assertion); `legacy-codex-hook-contracts.Tests.ps1` `SharedModuleNames` array.

Documentation files: the #539 spec annotations and #545 spec/issue closure edits of section 6.

Scope decision offered to the orchestrator (severable): `enforce-promotion-mcp-only.ps1` has a
confirmed over-match instance and exists in both pairs; masking its token scan through the same
helper is a small per-copy change (mask before the `IndexOf` loop) but adds 4 production copies
and its test surface to the batch plan. Recommended: include if batch capacity allows, else file
as an immediate follow-up citing this research. The remaining family members (epic-merge,
worktree-removal gates' relocating-spelling bypasses; abandon gate; validate-bash) are OUT of
scope here and should be filed as one follow-up candidate covering `gh`/`git` global-option
relocation in the merge/removal gates.

Constraints restated for the plan: no Python leg anywhere in the change; PowerShell 7+, PoshQC
format → analyze → Pester loop via the standard toolchain; 500-line cap on every file (the codex
contract test at 494 lines tolerates only the one-array edit); PowerShell per-batch cap of 3
production files means the four-copy fan-out must be batched; all evidence artifacts go to
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/<kind>/`.

## 8. Testing Implications (strategy, no code)

- Regression-first (plan phase 2): the failing tests are (a) an over-match repro — heredoc prose
  mention currently denied, asserted allow — and (b) an under-match repro — `git -C ../x add .`
  against a not-ready checkpoint currently allowed, asserted deny. Both fail before the fix by
  construction.
- Deny-preservation: run both existing decision suites unmodified except the single reversed
  heredoc It; every other existing deny assertion must pass untouched (the issue requires that no
  existing denial weakens).
- Wrapper pinning: `xargs`, `sh -c`, `bash -c`, `pwsh -Command`, `env`, heredoc-into-bash as
  explicit deny cases in the new suites, per side.
- Manual verification: replay the five 2026-08-24 over-match instances (receipt JSON write,
  promotion-token receipt value if promotion is in scope, memory-file heredoc, JSON heredoc with
  tool name, body-file JSON string) and confirm each proceeds; confirm `git -C <dir> add .`
  denies against a not-ready checkpoint.
- Parity gates: codex `Get-FileHash` It, claude push-down mirror pytest, both pack-manifest
  assertions, no-Python scan, 500-line checks — all must be green in the same change.

## 9. Automation Feasibility

This feature touches only repository-local PowerShell hooks, Pester suites, JSON manifests, and
Markdown documentation. No third-party UI, external service, credential, or interactive surface
is involved at any step. No human-interaction requirement is expected for this feature; the
orchestrator-state `human_interaction` block should not be needed.

## 10. Open Questions (resolvable by the orchestrator without further research)

1. **Promotion hook scope**: include `enforce-promotion-mcp-only.ps1` masking in this change
   (confirmed instance, +4 copies and tests) or file the prepared follow-up? Default
   recommendation: include if the batch plan absorbs it cleanly, otherwise follow-up.
2. **pr-author under-match**: closing `gh --repo … pr create` relocation is recommended alongside
   the masking (same helper, same suite); confirm it is in scope, since the issue's confirmed
   sibling instance covers only the over-match direction.
3. **Helper file name**: confirm `enforce-hook-command-scanner.ps1` (or an alternative name); it
   propagates into six registrations and four copies, so it must be fixed before execution.
4. **#539 spec annotation style**: confirm additive supersession notes (recommended) rather than
   in-place rewriting of the closed feature's rule table.
