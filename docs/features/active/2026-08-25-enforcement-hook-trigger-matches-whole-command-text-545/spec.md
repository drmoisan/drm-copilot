# enforcement-hook-trigger-matches-whole-command-text (Spec)

- **Issue:** #545
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-25
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-bug (this spec is the sole acceptance-criteria source; no `user-story.md` exists for this feature)

## Context

`Test-ImplementationCommand` in the orchestration preimplementation gate classifies a Bash
invocation by matching regexes against the entire raw command string, with no notion of where a
command begins and no awareness of quoting. The single design choice produces two opposite
defects: the gate blocks command text that merely *mentions* a governed token (false positive),
and it fails to classify a genuine governed command whose subcommand is not adjacent to the
command name (false negative, a latent bypass).

This is the follow-up recorded as "R2" during issue #539, deliberately left unfiled by that PR's
scope. It is filed now because the over-match direction was hit five times in a single working
session on 2026-08-24.

Authoritative research:
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/research/2026-08-25T09-45-enforcement-hook-trigger-matches-whole-command-text-research.md`.
This spec adopts the research's recommended approach (section 2.2), its fail-open analysis
(section 3), and its behavior semantics (section 4) as the normative contract, and records the
orchestrator's resolutions of the four questions the research left open (section 10).

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (the hooks are PowerShell; no Python leg by standing policy)
- Command/flags used: any Bash invocation whose text contains a governed token; see Repro below
- Data source or fixture: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
  (canonical Claude copy), and the three mirrored copies under `.codex/hooks/` and
  `extensions/drm-copilot/resources/`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Rationale for Medium rather than High, stated so it can be revised deliberately:

- The **over-match** direction is confirmed and recurrent — five instances in one session — but
  its cost is friction, not incorrectness. A documented workaround exists (reword the prose), and
  applying it is disclosed, not a bypass. It never causes an unsafe action to succeed.
- The **under-match** direction is the more serious of the two in principle, because it is a
  latent bypass of an enforcement control rather than an annoyance. It is rated Medium only
  because no agent has been observed using a relocating spelling in practice, and the failure is
  fail-open by *omission* rather than by an incorrect allow decision.

Raise to High if the under-match is ever observed in a real session, or if an agent is found to
emit relocating spellings routinely.

## Repro & Evidence

Steps to Reproduce:

**Direction 1 — over-match (fires on text that is not a command):**

1. With any orchestrator checkpoint state, issue a Bash command whose text merely quotes a
   governed token inside a string, a heredoc body, or a JSON value — for example a receipt
   payload whose value is a promotion tool name, or a document write whose prose quotes the
   two-word staging invocation.
2. Observe the gate classify the invocation as an implementation command.
3. The command is denied with the `PREIMPLEMENTATION_GATE_BLOCKED:` prefix even though no
   governed command is being executed.

**Direction 2 — under-match (never fires on a command that is real):**

1. Ensure the checkpoint is NOT ready, so a governed staging command would normally be denied.
2. Issue a relocating spelling that separates the command name from the subcommand, such as
   `git -C ../some-other-worktree add .` with no other trigger-matching text on the line.
3. Observe that the trigger regex `(^|\s)git\s+(add|commit)\b` does not match, so the classifier
   never runs and the command is not evaluated at all.

Expected:

The gate should classify based on what the command line *executes*, not on what its text
*contains*. Specifically:

- Quoted prose, heredoc bodies, and string literals that mention a governed token should not be
  classified as invocations of that token.
- A governed command should be classified regardless of options appearing between the command
  name and its subcommand.

Actual:

The five trigger patterns are matched against `$normalizedCommand`, the whole command text:

```text
(^|\s)git\s+(add|commit)\b
(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b
(^|\s)npm\s+.*\s+(prettier|lint|typecheck|test:unit)\b
(^|\s)npx\s+(prettier|eslint|tsc|jest)\b
(^|\s)pwsh\s+.*(Invoke-Pester|tests/scripts/)
```

`(^|\s)` anchors only to a whitespace boundary, which any quoted string satisfies.
`git\s+(add|commit)` requires adjacency, which git does not.

Observed consequences, both directions, in one session on 2026-08-24:

- A JSON receipt string containing `--body-file` was classified as a PR-body invocation by the
  sibling hook `enforce-pr-author-skill.ps1`, which shares the same whole-command-text design.
  Blocked with `PR_BODY_PATH_NONCANONICAL`.
- Promotion tool names supplied as required receipt *values* were classified as promotion
  invocations by `enforce-promotion-mcp-only.ps1`. Blocked.
- Writing a memory file documenting this very defect was blocked, because the file necessarily
  quotes the token it warns about.
- A heredoc whose JSON body merely mentions a Python tool name is classified as a lint
  invocation by the second pattern.
- Conversely, `git -C <dir> add ...` passes ungated by non-match. Issue #539's `spec.md` D4 rule
  table, row 14, records this explicitly: such a line "never reaches this classifier and passes by
  non-match — a pre-existing trigger limitation."

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:

From `spec.md` of issue #539, design decision D8, recorded as out of scope for that fix:

> The trigger regex is not narrowed in this fix because trigger scoping to a segment-leading
> command name is a fail-open change (wrapper bypasses via `xargs`, nested shells). D3 bounds the
> practical interaction. The same trigger property produces an under-match in the opposite
> direction: a relocating spelling that separates the command name from the subcommand is never
> classified at all and passes by non-match; this direction is part of the same follow-up
> candidate. Follow-up candidate for a separate issue; not filed here.

## Scope & Non-Goals

- In scope:
  - A new shared, dot-sourced, entrypoint-free PowerShell helper `hook-command-scanner.ps1`
    (D7) implementing the three cooperating pieces of the behavior contract (D2): a quote- and
    heredoc-aware command scanner producing per-segment masked text; per-segment masked trigger
    evaluation with a wrapper carve-out; and a structural relocation classifier.
  - Reworking `Test-ImplementationCommand` in the orchestration preimplementation gate to
    evaluate its five **byte-unchanged** trigger pattern strings against per-segment scan text
    supplied by the scanner, plus the structural git relocation classifier.
  - `enforce-promotion-mcp-only.ps1`: its four-token `IndexOf` scan and its two `gh` regex legs
    evaluated against per-segment scan text from the same helper (D5).
  - `enforce-pr-author-skill-helpers.ps1`: the `gh pr create` / `gh pr edit` trigger decision
    evaluated against per-segment scan text, plus structural `gh` global-option relocation
    closure (D6).
  - Delivery across the synchronized copy set and all six registrations required by a new shared
    helper (D9).
  - New sibling Pester suites on both the Claude and Codex sides covering both regression
    directions, the wrapper deny pins, and the scanner's own unit surface; the single reversed
    heredoc assertion in each existing CommandExemption suite.
  - Additive supersession annotations in issue #539's `spec.md` (D8).
- Out of scope / non-goals:
  - **The remaining hook-family members**, to be filed as a single follow-up candidate citing
    this specification and the research: `enforce-epic-merge-gate.ps1`,
    `enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`,
    `enforce-parallel-abandon-gate.ps1`, and `validate-bash.ps1`. The follow-up covers `gh` and
    `git` global-option relocation in the merge and removal gates.
  - Obfuscated respellings (`git${IFS}add`, `\git add`). Ungated today, ungated after this fix
    (D4 residual risk 2).
  - Any change to the five trigger pattern strings themselves, to the block-reason texts, to the
    decision-JSON schemas, to `Test-OrchestrationReady`, `Test-ImplementationPath`, the delegation
    classifiers, or to any hook registration in `.claude/settings.json` or `.codex/config.toml`.
  - Any change to the issue #539 exemption layer (`Test-ExemptOrchestrationStagingCommand` and its
    helpers file). It remains allow-side only and is consulted exactly where it is today (D2, rule
    R5).
  - Any Python leg anywhere in the change (standing repository policy for enforcement hooks).
- Explicitly excluded systems, integrations, or datasets:
  - `.github/instructions/` and `.claude/rules/` — no file under either tree is modified. Research
    section 6 verified by grep that no rule file documents the trigger limitation; the "D4 rule
    table" lives in issue #539's `spec.md`, not under `.claude/rules/`.
  - `.claude/skills/epic-plan/SKILL.md` and `.claude/skills/parallel-plan/SKILL.md` — verified to
    describe only the #539 exemption, not the trigger; no change required.
  - Issue #516 absolute-path normalization — unrelated leg, composes independently.

## Root Cause Analysis

The root cause is a single property shared by the whole hook family: classification is a regex or
substring match over raw command text rather than a structural read of the command line. Two
consequences follow directly from that one property:

1. **Over-match.** `(^|\s)` is satisfied by any whitespace, including whitespace inside a quoted
   span, a heredoc body, or a JSON value. Patterns 3 and 5 additionally use `.*`, which spans both
   quote boundaries and segment boundaries, so a line containing `npm` anywhere and `lint`
   anywhere later classifies. Pattern 2's bare tool names match the English word `black` in prose.
   The promotion hook's `IndexOf` scan and the pr-author hook's `\bgh\s+pr\s+create\b` share the
   same exposure.
2. **Under-match.** Adjacency between the command name and the subcommand is required, and git and
   gh both accept global options in between. `git -C <dir> add`, `git --git-dir=<x> commit`,
   `git --work-tree=<x> add`, `npx --yes prettier`, `gh --repo <o/r> pr create`, and
   `gh -R <o/r> issue create` all pass by non-match. `(git add .)` and `$(git add .)` also pass,
   because the character preceding `git` is `(` rather than whitespace or start-of-string.

The parsing machinery the fix needs already exists in-repo.
`Test-ExemptOrchestrationStagingCommand` and its helpers in
`enforce-orchestration-preimplementation-gate-helpers.ps1`, added by issue #539, already implement
quote-tracked segment splitting outside quotes (`Split-OrchestrationCommandLine`), balanced-quote
token extraction (`ConvertTo-OrchestrationCommandToken`), a positive option table with
deny-on-unmodeled-token semantics, and unresolvable-character rejection. It does not handle
heredocs, subshell/group openers, `$(...)`, or env-assignment prefixes, and it is confined to the
allow side. It is the proven idiom this fix extends, not replaces.

Issue #539 identified this defect class as "R2" and deliberately declined to fix it (D8), on the
grounds that narrowing the trigger to a segment-leading command name is fail-open. That objection
is correct against the naive narrowing it describes and is answered form by form in D3 below
against the model this specification actually adopts, which does not narrow to segment-leading
command names.

## Proposed Fix

The following design decisions are fixed. They are the normative contract; the atomic-planner
decides sequencing, batching, and final function boundaries within these constraints.

### D1 — Selected remedy: masked-trigger scanning with a wrapper carve-out, plus structural relocation classification

Keep every trigger pattern string byte-unchanged. Change **what text those patterns run against**,
and add one structural classifier that closes the relocation under-match. All logic is pure string
processing: no filesystem access, no child process, no external module.

Rejected alternatives, recorded so they are not re-litigated:

- **A — naive segment-leading classifier** (classify only when a segment's leading word is a
  governed command). Rejected as-is: this is exactly the fail-open change #539 D8 warned about.
  `echo x | xargs git add` (denied today) and `bash -c 'git add .'` (denied today) would newly
  pass, and pattern 5's standard spelling `pwsh -NoProfile -Command "Invoke-Pester ..."` would stop
  classifying. Wrapper modeling repairs it, but the repair converges on the selected model with
  more moving parts and a larger behavioral diff against the existing deny suites.
- **B — promote the #539 exemption parser wholesale to be the classifier** (every command line must
  fully parse or deny). Rejected: the #539 parser is deliberately total, which is correct for an
  allow-side exemption but as a trigger would deny nearly every ordinary command (any `echo`, any
  `ls`) or require modeling the entire command universe.
- **C — any Python leg.** Prohibited by standing policy: enforcement hooks must not use Python;
  bash is preferred and PowerShell is acceptable. A Python leg would create a second implementation
  that drifts. Not considered further.

### D2 — Behavior contract (normative)

Three cooperating pieces. Each is stated precisely enough to test against.

#### Piece 1 — the command scanner

A single left-to-right scan of the raw command text producing an **ordered list of segments**.

State tracked during the scan: single-quote span, double-quote span, backslash escape, and a
heredoc state machine (pending-delimiter list plus in-body flag).

Segment delimiters, recognized **only outside quoted spans and heredoc bodies**: `;`, `&`, `|`,
newline, and the subshell/group/substitution openers and closers `(`, `)`, `{`, `}`, `$(`, and the
backtick. Treating the openers as delimiters is what closes today's `(git add .)` and
`$(git add .)` non-match bypasses; it is a fail-closed widening.

Each segment records exactly five properties:

| Property | Definition |
| --- | --- |
| `RawText` | The segment's original text, unmodified. |
| `MaskedText` | The segment's text with every quoted span and every attached heredoc body replaced by single spaces. Replacement preserves nothing of the masked content. |
| `Tokens` | Quote-stripped token list, produced in the #539 `ConvertTo-OrchestrationCommandToken` idiom. |
| `HasLiveSubstitution` | `$true` when a `$(` or a backtick occurred inside one of the segment's double-quoted spans. |
| `Unbalanced` | `$true` when a quote span or a heredoc did not close before end of text. |

Heredoc handling is real delimiter tracking, bounded:

- Trigger on `<<` or `<<-` occurring outside quotes. `<<<` is a here-string with no body and is not
  a heredoc.
- Read the delimiter word, which may itself be quoted (`<<'NOTE'`, `<<"NOTE"`).
- From the next newline, mask lines until a line whose content — after optional leading tabs for
  the `<<-` form — equals the delimiter exactly.
- Support multiple pending heredocs on one physical line, consumed in the order they appear.
- An unterminated heredoc masks to end of text. This matches shell semantics: the body is consumed
  to EOF and never executes.
- A non-literal delimiter (produced by expansion, for example `<<$VAR`) is **unmaskable**; the
  containing segment is treated as unresolvable and scans raw (today's behavior).

The narrower alternative — falling back to whole-text matching whenever `<<` appears anywhere — is
rejected: heredoc bodies were the majority of the observed friction (the memory-file write and the
JSON-body instances), so that alternative would leave the primary reported defect in place.

#### Piece 2 — masked trigger evaluation, per segment

For each segment, select the **scan text** by applying these clauses in order; the first matching
clause wins:

1. If the segment is `Unbalanced` **or** `HasLiveSubstitution`, use `RawText`. Text whose execution
   content cannot be resolved statically keeps today's whole-text behavior.
2. If the segment's leading command word — determined after skipping any `VAR=value`
   env-assignment prefixes — is a member of the **wrapper carve-out set**, use `RawText`. A
   wrapper's quoted argument is a nested command line, so it must stay visible to the patterns.
3. Otherwise, use `MaskedText`. A quoted string in a non-wrapper segment is an argument — data, not
   execution — so a governed token inside it is a mention, never an invocation.

The wrapper carve-out set is a named script-scope constant with exactly these members:

```text
sh   bash   zsh   dash   ksh   pwsh   powershell
xargs   env   command   eval   nohup   time   timeout
```

Clause 2 is what preserves today's deny for `bash -c 'git add .'`, `xargs git add`, and
`pwsh -NoProfile -Command "Invoke-Pester ..."` (pinned today by
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` line 140).

Each hook then runs its own **byte-unchanged** trigger expressions against each segment's chosen
scan text. A match on any segment classifies. Per-segment evaluation — rather than one whole-line
masked string — also ends the cross-segment `.*` bridging of patterns 3 and 5, so
`npm --version && echo lint` stops classifying. That is over-match removal, not a bypass: no
governed command executes on that line.

#### Piece 3 — structural relocation classifier

Evaluated per segment, independently of piece 2, against the segment's `Tokens`:

1. Skip any leading `VAR=value` env-assignment prefixes.
2. Skip the transparent wrappers `command`, `env`, `nohup`, `time`, `timeout`.
3. If the first remaining token is `git`, absorb the modeled git global options — `-C <arg>`,
   `-c <arg>`, `--git-dir[=…]`, `--work-tree[=…]`, `--namespace[=…]`, `-p`, `--paginate`,
   `--no-pager`, `--exec-path[=…]`, `--literal-pathspecs`, `--no-optional-locks`, `--bare`.
4. The first non-option token is the subcommand. Classify when it is `add` or `commit`.
5. An **unmodeled dash-leading token** between `git` and the subcommand classifies. This is
   fail-closed: over-classification only forces checkpoint readiness.
6. A **non-dash token that is not `add`/`commit`** terminates the scan without classifying. This is
   what prevents an arbitrary later token from classifying: `git log --grep add` stops at `log`.

The same shape applies to the `gh` surface with the gh global options `-R <arg>`, `--repo <arg>`,
and `--repo=<arg>`, and the subcommand paths `pr create` and `pr edit` (D6).

The git and gh option tables, like the wrapper set, are named script-scope constants pinned by
test.

#### Decision rules (normative, from research section 4)

- **R1.** Masking never denies. It only removes matches. Every deny reachable today, except the
  quoted/heredoc-mention class, remains reachable.
- **R2.** The five trigger pattern strings are **byte-unchanged**; only the text they scan changes.
  The same holds for the promotion hook's four forbidden-token literals and its two `gh` regexes,
  and for the pr-author hook's `gh pr create` / `gh pr edit` expressions.
- **R3.** Unbalanced quoting, live substitution inside double quotes, or an unresolvable heredoc
  delimiter causes that segment to scan raw — today's behavior.
- **R4.** Structural git classification order is: env-prefix skip, transparent-wrapper skip, `git`,
  modeled global-option absorption, subcommand test. An unknown dash-leading token classifies; a
  non-dash non-target token stops the scan without classifying.
- **R5.** The issue #539 exemption remains allow-side only and is consulted at exactly the point it
  is consulted today. `Test-ImplementationCommand` classifies via pieces 2 and 3; when the
  classification came from the git leg, `Test-ExemptOrchestrationStagingCommand` is still
  consulted. Relocating spellings remain NEVER EXEMPT under #539 D4 row 14, so a newly classified
  `git -C ../x add …` is denied — the row's documented intent.
- **R6.** The wrapper carve-out set and the git/gh option tables are named script-scope constants,
  pinned by test.

#### Per-hook application

| Hook | Trigger expressions moved onto segment scan text | Structural relocation classifier | Downstream logic |
| --- | --- | --- | --- |
| `enforce-orchestration-preimplementation-gate.ps1` (4 copies) | All five patterns | git leg (`add` / `commit`) | #539 exemption unchanged; `Test-ImplementationPath`, `Test-OrchestrationReady`, delegation classifiers, block-reason text, decision JSON all unchanged. Codex `apply_patch` marker legs sit upstream of the pattern loop and are untouched. |
| `enforce-promotion-mcp-only.ps1` (4 copies) | Four forbidden-token `IndexOf` scan; `\bgh\s+issue\s+(?:create\|new)\b`; the `gh api … POST` lookahead conjunction | gh leg (`issue create` / `issue new`), per D10 | Block-reason getters and decision shape unchanged. |
| `enforce-pr-author-skill-helpers.ps1` (2 copies, Claude side only) | `\bgh\s+pr\s+create\b` and `\bgh\s+pr\s+edit\b` | gh leg (`pr create` / `pr edit`) | `--body-file` / `--body` flag parsing, receipt verification, and every `PR_*` reason code stay on raw text and are unchanged. Because the receipt path is reachable only after `isPrCreate`/`isPrEdit` is true, gating the trigger closes the reported `PR_BODY_PATH_NONCANONICAL` over-match without touching any receipt check. |

Note on the promotion hook's `gh api … POST` pattern: it is a whole-text lookahead conjunction, so
per-segment evaluation narrows it — a conjunction whose parts straddle a segment boundary no longer
matches. This is over-match removal in the same class as patterns 3 and 5: a genuine
`gh api repos/<o>/<r>/issues -X POST …` is one segment and still matches.

### D3 — The fail-closed argument (form by form)

Issue #539 D8 declined this fix because scoping the trigger to a segment-leading command name is
fail-open: wrappers legitimately relocate the command name. The model selected here does **not**
scope the regex triggers to segment-leading command names. It masks only provably-inert text and
keeps wrapper-led segments on raw text. The objection is therefore re-examined form by form. This
table is the single most load-bearing content in this specification; every row is an obligation on
the test surface.

| Form | Today | Under this specification | Direction |
| --- | --- | --- | --- |
| `echo x \| xargs git add` | deny (regex hits ` git add`) | deny — the `xargs` segment is wrapper-led and scans raw | neutral |
| `bash -c 'git add .'` / `sh -c "git add ."` | deny | deny — wrapper carve-out scans raw | neutral |
| `env git add .` / `command git add .` / `nohup git add .` | deny | deny — wrapper-led raw scan; the structural classifier also skips transparent wrappers | neutral |
| `pwsh -NoProfile -Command "Invoke-Pester …"` | deny | deny — `pwsh` is in the wrapper set | neutral |
| `bash <<EOF … git add … EOF` | deny | deny — `bash` is in the wrapper set, so the segment scans raw and the heredoc body stays visible | neutral (deliberate direction reversal against masking) |
| `echo "$(git add .)"` (live substitution inside quotes) | deny | deny — `HasLiveSubstitution` forces a raw scan | neutral |
| `git -C ../x add .` (bare relocating spelling) | **allow by non-match** — the confirmed latent bypass | **deny** — structural classifier | fail-closed |
| `git --git-dir=<x> commit` / `git --work-tree=<x> add` | allow by non-match | deny — structural classifier | fail-closed |
| `(git add .)`, `$(git add .)`, `` `git add .` `` | allow by non-match | deny — openers are segment delimiters | fail-closed |
| `npx --yes prettier`, `npx -p <pkg> eslint` | allow by non-match | deny — modeled option absorption | fail-closed |
| `gh --repo <o/r> pr create` / `gh -R <o/r> pr edit` | allow by non-match | deny — structural gh classifier (D6) | fail-closed |
| `gh --repo <o/r> issue create` / `gh -R <o/r> issue new` | allow by non-match | deny — structural gh classifier (D10) | fail-closed |
| `echo "run git add docs/x"`; heredoc prose; JSON receipt values; the word `black` in prose (all in non-wrapper segments) | **deny** — the confirmed over-match | **allow** — masked; the quoted span is an argument, not an execution | deliberate allowance, not a bypass: nothing on the line executes a governed command |
| `npm --version && echo lint` | deny (`.*` bridges segments) | allow — per-segment evaluation ends the bridge | deliberate allowance; no governed command executes |
| `git${IFS}add`, `\git add`, other obfuscated respellings | allow (no whitespace boundary / escaped name) | unchanged — already ungated; this model widens nothing here | neutral |

**Conclusion.** The net change is fail-closed. Every wrapper form D8 cited **that denies today**
keeps its denial. Three of the forms D8 cited — `bash -c 'git add .'`, `sh -c "git add ."`, and
`echo "$(git add .)"` — were **already ungated before this change**, as the preflight measurement
of 2026-08-25 against an explicitly not-ready checkpoint established; they are ungated after it as
well, so they move from an incorrectly-recorded neutral to a correctly-recorded neutral and no
denial is lost. See residual risk D4.4 for the boundary reason and the accepted-residual ruling.
Four classes of genuine bypass newly deny: git global-option relocation, subshell and command-group
openers, command substitution, and adjacency-defeating options on `npx` and `gh`. The only forms
that newly pass are quoted or heredoc mentions in non-wrapper segments — text the shell never
executes — and cross-segment `.*` bridges where no governed command executes.

Measured exposure of the under-match closure: no `.claude` skill or rule instructs a
`git -C … add/commit`, `--git-dir`, or `--work-tree` staging form (research section 3, verified by
grep across `.claude/**`), and during normal execution phases the checkpoint is ready, so the gate
allows regardless. The practical exposure is limited to relocating staging spellings issued before
readiness — precisely the case the gate exists to deny, and which #539 D4 row 14 already documents
as NEVER EXEMPT.

### D4 — Residual accepted risks and the hook family's posture

These are accepted, recorded rather than omitted, and must survive into review:

1. **Over-match persists inside wrapper-led segments.** `bash -c 'echo "pytest"'` still denies,
   because clause 2 keeps the whole wrapper segment on raw text. This is rare and deny-biased.
   Narrowing it would require recursively scanning the nested command line, which reintroduces the
   fail-open surface this design exists to avoid.
2. **Obfuscated respellings remain ungated, exactly as today.** `git${IFS}add` and `\git add` are
   not classified before this change and are not classified after it. The hook family is a **policy
   deterrent, not a security boundary** — the same posture already documented for the pr-author
   receipt mechanism. No claim of tamper-resistance is made or implied by this fix.
3. **An unlisted wrapper whose quoted argument is a command line would newly pass.** For example
   `parallel 'git add x'`. No such wrapper appears in any repository skill, rule, or test. The
   wrapper set is a named constant pinned by test, so adding a member later is a one-line,
   test-pinned change.

### D5 — `enforce-promotion-mcp-only.ps1` is IN SCOPE (orchestrator decision, settled)

Its token scan is masked through the same shared helper.

Rationale: its over-match is the confirmed checkpoint-bootstrap blocker. A checkpoint's
required-MCP-tool list must name the promotion tools by name, so any Bash write of a complete
checkpoint is denied. Fixing the preimplementation gate while leaving this one would leave the same
defect class in the one place where it structurally blocks orchestrator bootstrap.

This decision is settled and is not to be reopened at planning, execution, or review.

### D6 — The pr-author under-match is IN SCOPE (orchestrator decision, settled)

The `gh` global-option relocation is closed alongside the masking, using the same helper and the
same suite.

Rationale: closing one hook's relocation bypass while leaving the sibling's open in the same change
is arbitrary.

This decision is settled and is not to be reopened.

### D7 — Shared helper name: `hook-command-scanner.ps1` (orchestrator decision, settled)

The helper is named `hook-command-scanner.ps1`, **not** `enforce-hook-command-scanner.ps1` as the
research working name proposed.

Rationale: the `enforce-` prefix is reserved for registered hooks, and this file is a shared
library. The existing shared module `codex-pretooluse-file-mapping.ps1` already establishes the
unprefixed form in the `$script:SharedModuleNames` contract array
(`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 30, verified).

The name propagates into six registrations and four copies, so it is fixed here and is not to be
reopened.

Consequences of joining `$script:SharedModuleNames`, which the helper must satisfy: it is
entrypoint-free (defines functions only, never reads stdin), parses cleanly, stays at or under 500
lines, contains no `$env:CLAUDE_` read, is byte-identical between the Codex canonical and Codex
bundle copies, and is listed in the Codex core pack manifest.

If implementation pressure pushes the helper past roughly 450 lines, it splits into two sibling
files, each of which then requires the same six registrations.

### D8 — Issue #539's spec is annotated additively, never rewritten (orchestrator decision, settled)

Its historical rule table, deny map, and design decision D8 are a closed feature's record. Each
affected row and decision receives a supersession note pointing at issue #545; **nothing is edited
in place**.

The affected locations in
`docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md`:

| Location | Current statement | Required annotation |
| --- | --- | --- |
| Line 128 — D4 rule table, row 14 | "…passes by non-match — a pre-existing trigger limitation recorded with D8, unchanged by this fix" | Additive note: the bare relocating spelling now classifies as of issue #545; the NEVER-EXEMPT disposition is unchanged. |
| Line 150 — deny map, `allow-by-non-match` row | Records allow-by-non-match as current behavior | Same additive supersession note. |
| Line 153 — deny map, heredoc/message-body row | Records the heredoc deny as current behavior | Additive note: a heredoc mention in a non-wrapper segment now allows as of issue #545; a heredoc feeding a wrapper still denies. |
| Lines 184–186 — design decision D8 | Defers the trigger scoping as a fail-open change | Additive note: resolved by issue #545 with a masked-trigger model that does not scope to segment-leading command names; see this spec's D3. |
| Line 278 — Rollout & Follow-up, "Known deferrals" | Records the deferral | Additive note: the deferral is closed by issue #545. |

This decision is settled and is not to be reopened.

### D9 — Synchronization contract

The gate ships as **two deliberately divergent synchronized pairs, not four copies of one file**.
The Codex canonical copy carries two upstream `apply_patch` marker legs the Claude copy does not
have; equal line counts between the pairs are incidental. Identity is enforced **per pair**, never
across pairs.

| Copy | Path | Pair contract |
| --- | --- | --- |
| Claude canonical | `.claude/hooks/…` | Content-equal to the Claude bundle |
| Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/…` | Content-equal to Claude canonical |
| Codex canonical | `.codex/hooks/…` | **Byte-identical** to the Codex bundle |
| Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/…` | **Byte-identical** to Codex canonical |

Copy sets in this change:

- `enforce-orchestration-preimplementation-gate.ps1` — all four locations.
- `enforce-promotion-mcp-only.ps1` — all four locations (verified present in each).
- `hook-command-scanner.ps1` (new) — all four locations. Because the helper is pure string logic
  with no transport dependency, the same content is expected to serve both pairs; only per-pair
  identity is contractual.
- `enforce-pr-author-skill-helpers.ps1` and `enforce-pr-author-skill.ps1` — Claude canonical and
  Claude bundle only. There is no `.codex` copy of the pr-author hook.

Mechanisms that enforce each pair, all of which must be green in the same change:

| Pair | Mechanism | What a change must do |
| --- | --- | --- |
| Codex | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, the `It` at line 111, hashing every name in `$script:StaticCheckNames` with `Get-FileHash` against the Codex bundle | Update canonical and bundle byte-identically in the same commit |
| Codex | Same suite, the `It` at line 134 | Every `$script:SharedModuleNames` entry must appear in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` |
| Codex | Same suite — parse check, 500-line cap, stdin-read exclusion for shared modules, no-`$env:CLAUDE_` check | The new helper must satisfy all four |
| Claude | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | Every non-memory `.claude/**` file must mirror byte-identically into the Claude bundle |
| Claude | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | The new helper must be listed |
| Both | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | Both `.claude/hooks/hook-command-scanner.ps1` and `.codex/hooks/hook-command-scanner.ps1` must join **both** coverage lists |
| Both | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | The new helper must invoke no Python |

**The six registrations a new shared helper requires**, restated as a checklist:

1. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
2. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
3. `$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
   (line 30)
4. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` coverage list
5. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` coverage
   list
6. The two bundle copies of the helper file itself

`legacy-codex-hook-contracts.Tests.ps1` is at 494 of 500 lines. Registration 3 appends to an
existing single-line array and adds no line, which fits. **Any new scenario for that side must go
in a new test file**, not into that suite.

### D10 — Promotion-hook gh relocation is IN SCOPE (orchestrator decision, settled, reverses the prior Non-Goal)

This decision **supersedes D5's masking-only scoping** of `enforce-promotion-mcp-only.ps1`. D5
brought the promotion hook into scope for masking alone and left its `gh` global-option relocation
deferred to the follow-up candidate. That deferral is overruled: the structural `gh` classifier of
D2 Piece 3 is applied to the promotion hook's issue-creation subcommands in this change, in all
four copies.

The rationale has two parts, and both are load-bearing.

**First, the promotion hook's adjacency-requiring `gh` issue-creation expression admits exactly the
same relocating bypass as its siblings.** `.claude/hooks/enforce-promotion-mcp-only.ps1` line 101
carries `\bgh\s+issue\s+(?:create|new)\b`, which requires `issue` to be adjacent to `gh`. A
relocating spelling such as `gh --repo <o/r> issue create` therefore passes there by non-match,
precisely as `gh --repo <o/r> pr create` passes in the pr-author hook and as `git -C <dir> add`
passes in the preimplementation gate. It is one defect class in one hook family, not a distinct
condition peculiar to the promotion surface.

**Second, closing three of four relocation bypasses while leaving the fourth open — in the very
change that builds the classifier that closes it — would be arbitrary.** This change already
closes the relocation under-match in the preimplementation gate (D2 Piece 3, the `git` leg) and in
the pr-author hook (D6, the `gh` leg). The classifier those two require is the same one the
promotion hook needs, so the marginal cost here is applying an existing constant table to a third
call site rather than designing anything new. The consistency argument that put the pr-author
relocation in scope under D6 applies unchanged to the promotion hook.

This decision is settled and is not to be reopened at planning, execution, or review.

### Boundaries and invariants to preserve

- Fail-closed default preserved by construction: masking removes matches only (R1), and every
  unresolvable form falls back to today's raw-text behavior (R3).
- The trigger expression strings in all three hooks are byte-unchanged (R2).
- The #539 exemption layer stays allow-side and is consulted at the same point (R5).
- Block-reason texts, reason-code strings, decision-JSON schemas, and hook registrations are
  unchanged.
- The Codex `apply_patch` marker legs remain upstream of the pattern loop and are untouched.
- Per-pair identity contracts hold (D9).
- No production file leaves the coverage denominator.

### Dependencies or blocked work

- None blocking.
- Change budget: this change touches well beyond the direct-mode cap of 2 production PowerShell
  files (`.claude/rules/powershell.md`). Execution routes through `powershell-orchestrator` or uses
  explicit approved batching at a per-batch cap of 3 production and 3 test files. The four-copy and
  two-copy fan-outs must be batched accordingly; the #539 execution is the precedent.
- Enforcement hooks must not gain a Python leg. This fix is PowerShell-only.

### Rollback considerations

No feature flag. Rollback is reverting the hook, helper, and registration edits. Reverting restores
the previous behavior, which is stricter in the masked directions and looser in the relocation
directions; the relocation looseness is the pre-existing state, so rollback restores a known
posture rather than creating a new one. The #539 spec annotations are additive and are harmless if
the code change is reverted, though they should be corrected if the revert is permanent.

## Assumptions, Constraints, Dependencies

- Assumptions:
  - `HookPayload.psm1` remains available to the Claude pair and `codex-pretooluse-file-mapping.ps1`
    to the Codex pair. No module change is required, and the new helper introduces no transport
    dependency.
  - The dot-sourced sibling `.ps1` idiom remains the only sharing mechanism that works on both
    pairs, because the `.codex` side has no `lib/` directory.
- Constraints:
  - PowerShell only, PowerShell 7+ compatible. Advanced functions with `CmdletBinding()`, approved
    verbs, `[OutputType()]` on predicates, no `Invoke-Expression`, no global or mutable
    script-scoped state beyond the named read-only constant tables.
  - 500-line cap on every production, test, and reusable script file.
  - Pester line coverage >= 85% on every changed or added production PowerShell file. There is no
    PowerShell branch-coverage gate (Pester does not measure branch coverage), and no production
    file may be excluded from the coverage denominator.
  - Toolchain: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` →
    `mcp__drm-copilot__run_poshqc_test`, restarting from format on any failure or auto-fix until a
    clean single pass.
  - Tests must be deterministic: no temporary files, no network, no child processes, no live
    executables. Decision tests drive the pure seams directly, following the #539 pattern.
  - Do not modify anything under `.github/instructions/` or `.claude/rules/`.
  - All evidence artifacts are written to
    `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/<kind>/`.
- External dependencies: none. Verification is entirely local.

## Data / API / Config Impact

- User-facing or API changes: none. Hook decision schemas, reason codes, block-reason texts,
  PreToolUse matchers, and registrations are unchanged. The behavioral change is confined to which
  text the trigger expressions are evaluated against and to the added structural classifier.
- Data or migration considerations: none.
- Configuration: no configuration file, environment variable, or settings key is added or read. The
  wrapper carve-out set and the git/gh option tables are script-scoped constants.
- Logging/telemetry: unchanged.
- Compatibility: both pair contracts are maintained; both bundle copies ship the fix to push-down
  destinations through the existing publish path. Two registration files
  (`pack-manifests/core.json` on each side) and two coverage settings files gain one entry each.

## Test Strategy

Both existing gate suites are near the 500-line cap
(`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` at 461 lines;
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` at 494), so new scenarios land in
new sibling files. All decision tests are driven through the pure seams with an explicitly
not-ready checkpoint: no disk I/O, no child processes, no temporary files.

### Regression-first (both directions must fail before the fix)

1. **Over-match repro.** A heredoc prose mention currently denied, asserted allow. Today's
   assertion in `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
   lines 245–266 (`cat <<'NOTE' … Run git add … NOTE`) is invalidated by this change and its
   expected decision reverses to allow. That single `It` and its D8 rationale comment are rewritten
   on both sides (the Codex analogue sits at approximately line 249 of
   `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`), and a sibling deny
   case is added where the same heredoc feeds a wrapper (`bash <<EOF`).
2. **Under-match repro.** `git -C ../x add .` against a not-ready checkpoint, currently allowed,
   asserted deny.

Both fail before the fix by construction. Fail-before output is recorded under
`…-545/evidence/regression-testing/`.

### New test files

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`
  — over-match allow cases (quoted mention, heredoc body, JSON value, the prose word `black`,
  cross-segment `npm … && echo lint`); under-match deny cases (`git -C … add`, `--git-dir`,
  `--work-tree`, unmodeled dash-leading token, subshell `(git add .)`, substitution `$(git add .)`,
  `npx --yes prettier`); the non-classifying stop case `git log --grep add`; and explicit **wrapper
  deny pins** (`xargs git add`, `bash -c 'git add .'`, `sh -c "git add ."`, `env git add .`,
  `pwsh -NoProfile -Command "Invoke-Pester …"`, heredoc-into-bash, `echo "$(git add .)"`), so the
  fail-open risk is pinned by test rather than by prose.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`
  — the same scenario set in the Codex idiom, plus assertions that the `apply_patch` marker legs
  are unaffected.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` — a quoted
  `--body-file` mention in a JSON receipt value allowed; `gh --repo <o/r> pr create` and
  `gh -R <o/r> pr edit` classified; wrapper deny pins; and assertions that every `PR_*` reason code
  and receipt check is unchanged on genuine invocations.
- A promotion-hook trigger-scoping suite per side — promotion tool names supplied as receipt
  *values* allowed; genuine `<tool>` invocations and `gh issue create` still denied; the
  `gh api … POST` single-segment case still denied.
- Scanner unit suite(s) for `hook-command-scanner.ps1`, mirrored per side following the #539
  precedent: segmentation (all delimiters, openers, newline), masking, the heredoc table
  (`<<`, `<<-` with leading tabs, quoted delimiter, multiple pending heredocs on one line,
  unterminated body, `<<<` not a heredoc, non-literal delimiter), tokenizer edge cases, the
  `HasLiveSubstitution` and `Unbalanced` flags, the wrapper-set constant, and the git/gh option
  tables.

### Deny preservation

Both existing decision suites run unmodified apart from the single reversed heredoc `It` per side.
Every other existing deny assertion must pass untouched — the issue requires that no existing
denial weakens. This explicitly includes:

- The existing Claude suite denials for `git add .`, `git commit -m "test"`, `poetry run black …`,
  `npm --prefix … test:unit …`, and `pwsh -NoProfile -Command "Invoke-Pester …"` (lines 112–149).
- The `Test-ImplementationCommand` classification table in `legacy-codex-hook-contracts.Tests.ps1`
  (lines 348–358), including `git commit -m "wip"` returning `$true`, `poetry run pytest` returning
  `$true`, `echo hello` returning `$false`, and the `apply_patch` legs.
- The #539 D4 rows 14a–14d chained relocating denials in both CommandExemption suites
  (lines 219–228 on the Claude side).
- The `file_path`-branch absolute-path suites, which are unaffected.
- The existing pr-author suites, whose command fixtures are all genuine unquoted `gh pr create` /
  `gh pr edit` invocations.

### Parity and gate verification

The Codex `Get-FileHash` `It`, the Codex pack-manifest `It`, the Claude push-down mirror pytest,
the Claude pack-manifest completeness check, the no-Python scan, and the 500-line checks must all
be green in the same change. Recomputed pair-hash evidence (SHA-256 per pair member, line counts,
method) is recorded under `…-545/evidence/other/`, following the #539 artifact shape. Hashes must be
recomputed at the final commit, not carried forward from an earlier batch.

### Coverage

Line coverage >= 85% on every changed or added production PowerShell file, with the new helper
inside the denominator in **both** runsettings lists. Verification gotcha: the MCP PoshQC test
runner reads the installed extension's settings, so newly added coverage entries are invisible to
it. Coverage evidence for the new helper must be produced by invoking the self-hosted PoshQC module
directly.

### Manual validation

Replay the five 2026-08-24 over-match instances and confirm each proceeds: the JSON receipt write
containing `--body-file`; a checkpoint write whose required-MCP-tool list names the promotion
tools; the memory-file write quoting the staging literal; the heredoc JSON body mentioning a Python
tool name; and prose quoting the two-word staging invocation. Then confirm `git -C <dir> add .`
denies against a not-ready checkpoint.

## Acceptance Criteria

- [ ] A regression test demonstrating the **over-match** direction exists and is recorded as
      failing against the unfixed hooks: a heredoc prose mention of a governed token in a
      non-wrapper segment is asserted to allow, with fail-before output recorded under
      `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/`.
- [ ] A regression test demonstrating the **under-match** direction exists and is recorded as
      failing against the unfixed hooks: `git -C ../x add .` against an explicitly not-ready
      checkpoint is asserted to deny, with fail-before output recorded under the same evidence
      path.
- [ ] Both regression tests pass after the fix, on both the Claude and the Codex sides, with
      pass-after output recorded under the same evidence path.
- [ ] The scanner produces, for each segment, the five properties named in D2 Piece 1 (`RawText`,
      `MaskedText`, `Tokens`, `HasLiveSubstitution`, `Unbalanced`), and a named Pester case exists
      for each heredoc rule in D2 Piece 1: `<<`, `<<-` with leading tabs, a quoted delimiter,
      multiple pending heredocs on one physical line, an unterminated body masking to end of text,
      `<<<` not treated as a heredoc, and a non-literal delimiter forcing a raw scan.
- [ ] Scan-text selection follows the three ordered clauses of D2 Piece 2, and the wrapper
      carve-out set contains exactly the fourteen members listed in D2, pinned by a named test
      against the script-scope constant.
- [ ] The structural relocation classifier implements the six numbered steps of D2 Piece 3, with
      named Pester cases asserting: `git -C <dir> add` classifies; `git --git-dir=<x> commit`
      classifies; `git --work-tree=<x> add` classifies; an unmodeled dash-leading token between
      `git` and the subcommand classifies; and `git log --grep add` does **not** classify.
- [ ] The five trigger pattern strings in the preimplementation gate are **byte-unchanged**, and
      the promotion hook's four forbidden-token literals, its two `gh` expressions, and the
      pr-author hook's `gh pr create` / `gh pr edit` expressions are likewise byte-unchanged;
      verified by diff inspection recorded in the scope-and-size evidence artifact.
- [ ] Every row of the D3 fail-closed table has at least one named Pester case per applicable side
      asserting the stated post-fix decision, including all seven wrapper deny pins (`xargs`,
      `bash -c`, `sh -c`, `env`, `pwsh -Command`, heredoc-into-`bash`, and live substitution inside
      double quotes).
- [ ] **No existing denial is weakened.** Both existing decision suites pass with no assertion
      modified except the single reversed heredoc `It` on each side; the existing Claude gate suite
      denials (lines 112–149), the Codex `Test-ImplementationCommand` classification table
      (lines 348–358, including `git commit -m "wip"` returning `$true`), the #539 D4 rows 14a–14d
      chained relocating denials, the absolute-path suites, and the existing pr-author suites all
      pass unmodified.
- [ ] The issue #539 exemption layer is unchanged: `Test-ExemptOrchestrationStagingCommand` and
      `enforce-orchestration-preimplementation-gate-helpers.ps1` carry no functional edit, the
      exemption remains allow-side only, and it is consulted at the same point in the decision flow
      (D2 rule R5).
- [ ] `enforce-promotion-mcp-only.ps1` is changed in all four copies so that its four-token
      `IndexOf` scan and both `gh` expressions evaluate against per-segment scan text from
      `hook-command-scanner.ps1`, with named cases asserting that promotion tool names supplied as
      receipt *values* allow while a genuine promotion-script invocation, `gh issue create`,
      `gh issue new`, and a single-segment `gh api repos/<o>/<r>/issues -X POST` still deny.
- [ ] `enforce-pr-author-skill-helpers.ps1` is changed in both Claude copies so that the
      `isPrCreate` / `isPrEdit` trigger decision evaluates against per-segment scan text and so that
      `gh --repo <o/r> pr create` and `gh -R <o/r> pr edit` classify; named cases assert that a
      quoted `--body-file` mention inside a JSON receipt value allows, and that every `PR_*` reason
      code and receipt check is unchanged for genuine invocations.
- [ ] The new shared helper is named exactly `hook-command-scanner.ps1`, exists at
      `.claude/hooks/`, `.codex/hooks/`, and both bundle locations, defines functions only, reads
      no stdin, and contains no `$env:CLAUDE_` reference.
- [ ] All six registrations from D9 are complete: both pack manifests, `$script:SharedModuleNames`
      in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, both PoshQC coverage
      lists, and both bundle copies of the helper.
- [ ] **Both parity mechanisms are green in the same change:** the Codex byte-identity `It` in
      `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes with every Codex
      canonical/bundle pair member byte-identical, and
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes with the Claude
      pair content-equal; both pack-manifest assertions pass.
- [ ] Recomputed pair-hash parity evidence (SHA-256 per pair member, line counts, and the method
      used) is recorded under
      `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/other/`,
      computed at the final commit rather than carried forward from an earlier batch.
- [ ] Every production, test, and reusable script file touched or added by this change is at or
      under **500 lines**, verified by the Codex contract suite's line-cap check and by an explicit
      line-count artifact under `…-545/evidence/qa-gates/`.
- [ ] Pester **line coverage is >= 85%** on every changed or added production PowerShell file, with
      `hook-command-scanner.ps1` inside the coverage denominator on both sides; coverage evidence is
      produced by invoking the self-hosted PoshQC module directly (the MCP runner reads the
      installed extension's settings and cannot see newly added coverage entries).
- [ ] **No Python is introduced anywhere in the change**:
      `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes with
      the new helper in its scan set, and no file added or modified by this change invokes a Python
      interpreter or adds a `.py` production file.
- [ ] Issue #539's `spec.md` is annotated **additively** at all five locations listed in D8 (D4 rule
      table row 14; deny-map rows at lines 150 and 153; design decision D8; and the Rollout &
      Follow-up deferral), each note citing issue #545, with **no existing sentence, table row, or
      decision text edited in place** — verified by reviewing the diff of that file for additions
      only.
- [ ] No out-of-scope hook is modified: `enforce-epic-merge-gate.ps1`,
      `enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`,
      `enforce-parallel-abandon-gate.ps1`, and `validate-bash.ps1` carry no diff, and no file under
      `.github/instructions/` or `.claude/rules/` is modified.
- [ ] A single follow-up candidate is filed covering the out-of-scope family members and `gh`/`git`
      global-option relocation in the merge and removal gates, citing this specification and the
      #545 research.
- [ ] The PoshQC toolchain passes clean in a single pass over all changed and added PowerShell
      files: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` →
      `mcp__drm-copilot__run_poshqc_test`, restarting from format on any failure or auto-fix, with
      final results recorded under `…-545/evidence/qa-gates/`.
- [ ] Manual replay is recorded: the five 2026-08-24 over-match instances each proceed, and
      `git -C <dir> add .` denies against a not-ready checkpoint, with results recorded under
      `…-545/evidence/qa-gates/`.
- [ ] `enforce-promotion-mcp-only.ps1` in **all four copies** classifies a relocating `gh`
      issue-creation spelling through the structural `gh` classifier of D2 Piece 3, per D10, so
      that `gh --repo <o/r> issue create` and `gh -R <o/r> issue new` are denied where they pass by
      non-match today; a named Pester case per side — Claude and Codex — asserts the deny.

## Risks & Mitigations

- **Scanner defects.** A quote-, escape-, and heredoc-aware scanner is the largest and most
  defect-prone piece of the remedy. Mitigation: every unresolvable form falls back to raw text
  (rule R3), which is today's behavior, so a scanner defect degrades toward the current posture
  rather than toward an allow; the scanner has its own mirrored unit suite; and the wrapper deny
  pins are asserted independently of the scanner's masking logic.
- **Fail-open regression on a wrapper form.** A missed wrapper member would allow a form denied
  today. Mitigation: the D3 table is an acceptance criterion with a named test per row, and the
  wrapper set is a constant pinned by test (residual risk D4.3 records the unlisted-wrapper case
  explicitly).
- **Heredoc masking is deny-reversing.** Masking a heredoc body is the one place the change removes
  a denial that exists today for a reason a reader might defend. Mitigation: D3 shows the shell
  never executes a non-wrapper heredoc body, and the `bash <<EOF` case keeps its deny because
  `bash` is in the wrapper set; both are pinned by test.
- **Copy divergence.** Fixing one pair leaves the defect live in the other runtime or in push-down
  destinations. Mitigation: four-copy (and two-copy, for pr-author) delivery is an acceptance
  criterion; the Codex hash-binding test and the Claude content-equality pytest enforce their pairs
  automatically; recomputed pair-hash evidence is a separate criterion, and prior work has produced
  pair-hash artifacts recording stale hashes, so recomputation at the final commit is mandated.
- **Registration omission.** Missing any of the six registrations produces a late, confusing
  failure (a pack-manifest assertion, a byte-identity failure, or a silent coverage-denominator
  gap). Mitigation: D9 states the checklist and it is an acceptance criterion; the coverage entry
  in particular is invisible to the MCP runner, so the criterion mandates a self-hosted PoshQC
  invocation.
- **Line-cap exhaustion.** `legacy-codex-hook-contracts.Tests.ps1` is at 494 of 500 lines and the
  two existing gate suites are at 461 and 271. Mitigation: only the single-line
  `$script:SharedModuleNames` edit lands in the 494-line file; all new scenarios go into new
  sibling files; D7 provides a helper-split path if the scanner exceeds roughly 450 lines.
- **Change-budget violation.** The production file count far exceeds the direct-mode cap of 2.
  Mitigation: route through `powershell-orchestrator` or explicit approved batching at 3 production
  and 3 test files per batch, settled at planning time.
- **The hook family is a deterrent, not a boundary.** This fix does not, and does not claim to,
  make the gates tamper-resistant (D4.2). Mitigation: the posture is stated in D4 and must be
  carried into any downstream summary of this change.
- Rollback: reverting restores the pre-existing posture, which is stricter in the masked directions
  and looser in the relocation directions. No new gap is created by a revert.

## Rollout & Follow-up

- Release/rollout steps: land the new helper (four copies), the three modified hooks (four, four,
  and two copies respectively), the six registration edits, the new test suites, the two reversed
  heredoc assertions, and the #539 spec annotations in one feature branch and pull request. Both
  bundle copies ship the fix to push-down destinations through the existing publish path. No
  configuration or registration-matcher change is required.
- Post-merge validation: after push-down, confirm in a destination repository that a checkpoint
  write naming the promotion tools proceeds, that a PR-receipt JSON write containing `--body-file`
  proceeds, and that `git -C <dir> add .` denies against a not-ready checkpoint.
- Follow-up candidate to file (single issue): `gh` and `git` global-option relocation in
  `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, and
  `enforce-parallel-worktree-removal-gate.ps1`; token-anywhere semantics in
  `enforce-parallel-abandon-gate.ps1`; and the substring blocklist in `validate-bash.ps1`. The
  shared helper delivered here is the intended mechanism for all of them.
- Known deferrals recorded, not fixed here: over-match inside wrapper-led segments (D4.1),
  obfuscated respellings (D4.2), and unlisted wrappers whose quoted argument is a command line
  (D4.3).
- Links: issue #545 (https://github.com/drmoisan/drm-copilot/issues/545); research
  `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/research/2026-08-25T09-45-enforcement-hook-trigger-matches-whole-command-text-research.md`;
  predecessor issue #539 and PR #544, with spec
  `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md`
  (design decision D8, D4 rule-table row 14).
