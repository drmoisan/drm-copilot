# enforcement-hook-trigger-matches-whole-command-text (Spec)

- **Issue:** #545 (folds in #591)
- **Parent (optional):** epic `cleanup-merged-worktrees-hardening`, child E
- **Owner:** drmoisan
- **Last Updated:** 2026-09-06
- **Status:** Ready for planning
- **Version:** 1.2
- **Work Mode:** full-bug (this spec is the sole acceptance-criteria source; `user-story.md` exists in
  this folder only to satisfy the epic readiness gate and carries no acceptance criteria)

Revision history:

| Version | Date | Change |
| --- | --- | --- |
| 1.0 | 2026-08-25 | Initial specification. |
| 1.1 | 2026-08-25 | Added D10 (promotion-hook `gh` relocation in scope) and the acceptance criterion that pairs with it. The version marker was not bumped when those edits landed; this row records them retroactively. |
| 1.2 | 2026-09-06 | Epic child-E scope amendment: D11 widens scope to the full hook family, D12 records the consumed parser contract, D7 supporting text is corrected, and the two superseded acceptance criteria are replaced. Citation corrections from the 2026-09-06 re-derivation research are applied. |

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

Supplementary research, authored 2026-09-06 against base `be722eba` and authoritative for every
tree citation in this document:

- `research/2026-09-06T23-30-command-word-parser-rederivation-research.md` — re-derives 99 citations
  across `plan.2026-08-25T08-13.md` and this specification, extends the defect inventory to the gate
  hooks, and proposes the parser contract recorded in D12.
- `research/2026-09-06T23-40-shared-helper-registration-and-copyset-research.md` — verifies D7, D8,
  and D9 against the current tree, prices the `.psm1` alternative, and analyses
  `enforce-parallel-abandon-gate.ps1` and `validate-bash.ps1`.

Supporting evidence, same date:

- `evidence/baseline/baseline-copyset-and-pair-parity.2026-09-06T23-20.md` — verified line counts,
  copy set, and green pair parity at baseline.
- `evidence/other/live-reproduction-promotion-hook-overmatch.2026-09-06T23-35.md` — a fresh
  over-match reproduction on the current tree, twelve days after the original filing.

Where the two research artifacts disagreed on the shared-helper module form, D7 is confirmed and D11
records the decisive evidence. Where a citation in this document was found DRIFTED or STALE, it is
corrected in place and the correction is noted.

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
  - A new shared, dot-sourced, entrypoint-free PowerShell helper delivered as **two sibling `.ps1`
    files**, `hook-command-scanner.ps1` and `hook-command-invocation.ps1` (D7 as amended by D11),
    implementing the three cooperating pieces of the behavior contract (D2): a quote- and
    heredoc-aware command scanner producing per-segment masked text; per-segment masked trigger
    evaluation with a wrapper carve-out; and a structural invocation and relocation classifier with
    operand and flag retrieval.
  - The full Claude-side hook family that classifies Bash command text — nine files, listed in D11.
  - Reworking `Test-ImplementationCommand` in the orchestration preimplementation gate to
    evaluate its five **byte-unchanged** trigger pattern strings against per-segment scan text
    supplied by the scanner, plus the structural git relocation classifier.
  - `enforce-promotion-mcp-only.ps1`: its four-token `IndexOf` scan and its two `gh` regex legs
    evaluated against per-segment scan text from the same helper (D5).
  - `enforce-pr-author-skill-helpers.ps1`: the `gh pr create` / `gh pr edit` trigger decision
    evaluated against per-segment scan text, plus structural `gh` global-option relocation
    closure (D6).
  - Delivery across the synchronized copy set and the registration set required by the two new
    shared helper files (D9 as amended by D11: five registry files carrying fourteen entries, plus
    eight file copies).
  - New sibling Pester suites on both the Claude and Codex sides covering both regression
    directions, the wrapper deny pins, and the scanner's own unit surface; the single reversed
    heredoc assertion in each existing CommandExemption suite.
  - Additive supersession annotations in issue #539's `spec.md` (D8).
  - Closure of issue #591's operand mis-parse in `enforce-epic-merge-gate.ps1`; #591 is superseded by
    #545 and is closed, not worked separately.
- Out of scope / non-goals:
  - Obfuscated respellings (`git${IFS}add`, `\git add`). Ungated today, ungated after this fix
    (D4 residual risk 2).
  - **Two follow-ups, recorded so they are not silently lost** (D11.6). Neither is delivered here:
    the `$script:SharedModuleNames` registration gap for
    `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, and runtime confirmation
    of the equals-joined disposition bypass in `enforce-parallel-abandon-gate.ps1`.
  - Any change to the five trigger pattern strings themselves, to the block-reason texts, to the
    decision-JSON schemas, to `Test-OrchestrationReady`, `Test-ImplementationPath`, the delegation
    classifiers, or to any hook registration in `.claude/settings.json` or `.codex/config.toml`.
    Rule R2 governs the *text* of a trigger literal, not the *operator* it is compared with. D11
    records one deliberate operator change, in `validate-bash.ps1`, where `String.Contains` becomes
    token equality while all six literals stay byte-unchanged.
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

This table covers the three hooks in scope before the 2026-09-06 amendment. It is **incomplete as of
D11**: six further hooks are in scope, and their call-site rewrites are tabulated in D12 rather than
added here, so this table remains the record of the original three.

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

### D7 — Shared helper is a dot-sourced `.ps1` named `hook-command-scanner.ps1` (orchestrator decision, settled; supporting text corrected 2026-09-06)

The helper is named `hook-command-scanner.ps1`, **not** `enforce-hook-command-scanner.ps1` as the
research working name proposed, and it is a **dot-sourced `.ps1`**, not a `.psm1` under
`.claude/lib/`.

Naming rationale, **corrected**. The original rationale — "the `enforce-` prefix is reserved for
registered hooks" — is refuted by `$script:SharedModuleNames`'s own second member,
`enforce-orchestration-preimplementation-gate-helpers.ps1`, which is an unregistered,
`enforce-`-prefixed shared library sitting in that same array. On the Claude side the
prefixed-helper form is in fact the majority pattern. The name is retained on the sounder ground
that it is **not derived from any one of the consuming hooks**, which is correct for a helper that
serves the whole family, and that the existing shared module `codex-pretooluse-file-mapping.ps1`
establishes the unprefixed cross-hook form in the `$script:SharedModuleNames` contract array
(`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 30, verified 2026-09-06).

Module-form rationale. D11 records the decisive evidence and the rejected alternative; the summary
is that `.claude/lib` is not delivered to the Codex side and no `.codex/**` file contains a single
`Import-Module` call, so a `.psm1` cannot serve the Codex copies that are in scope.

Registration count, **corrected**. The earlier phrasing "six registrations and four copies" is
inaccurate on two counts. The accurate statement for a single helper file is **five registry files
carrying seven entries, plus four file copies**. Checklist item 6 in D9 — "the two bundle copies of
the helper file itself" — is a copy, not a registration, and double-counts against the four copies.
D11 doubles these figures for the two-file split.

Consequences of joining `$script:SharedModuleNames`, which each helper file must satisfy: it parses
cleanly, stays at or under 500 lines, contains no `$env:CLAUDE_` read, is byte-identical between the
Codex canonical and Codex bundle copies, and is listed in the Codex core pack manifest. It must also
be entrypoint-free (defines functions only, never reads stdin) — noting that membership *exempts* a
file from the stdin-read assertion rather than asserting its absence, so entrypoint-freeness is a
design obligation here, not a test-enforced one.

The two-file split is **not** a contingency. D11 fixes it as the planned shape.

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
- `hook-command-invocation.ps1` (new, D11) — all four locations, same contract.
- `enforce-pr-author-skill-helpers.ps1` and `enforce-pr-author-skill.ps1` — Claude canonical and
  Claude bundle only. There is no `.codex` copy of the pr-author hook.
- `enforce-epic-merge-gate.ps1` and `enforce-epic-worktree-removal-gate.ps1` (D11) — all four
  locations each.
- `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1`, and
  `enforce-pr-author-skill.epic-base-branch.ps1` (D11) — Claude canonical and Claude bundle only;
  no `.codex` copy exists for any of the three.
- `validate-bash.ps1` (D11) — all four locations, but a **deliberately divergent** pair: the Claude
  copy is 230 lines and carries the `cd`-chained leg, the Codex copy is 185 lines and does not. Only
  per-pair identity is contractual, and the Codex copy is not required to gain the `cd`-chained leg.

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

**The registrations a new shared helper requires**, restated as a checklist. The 2026-09-06
re-derivation corrected the earlier count: there are **five registry files**, not six, and the
earlier item 6 was a copy rather than a registration.

| # | Registry file | Entry required per helper file |
| --- | --- | --- |
| 1 | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | one `.claude/hooks/` path |
| 2 | `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | one `.codex/hooks/` path |
| 3 | `$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (line 30) | one array member |
| 4 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` coverage list | **two** entries, the `.claude/hooks/` and `.codex/hooks/` paths |
| 5 | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` coverage list | the same **two** entries, textually identical to registry 4 |

So a single helper file costs **five registry files carrying seven entries, plus four file copies**.
Under D11's two-file split the figure doubles to **fourteen entries across the same five registry
files, plus eight file copies**. The registry-file count does not grow; only the entry count does.

Registrations that are automatic and require no file edit, verified 2026-09-06: the Claude bundle
mirror (`test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates `.claude/**`
from disk) and the no-Python guard (`enforcement-hooks-no-python-invocation.Tests.ps1` walks
`.claude/hooks` and `.claude/lib` with `Get-ChildItem -Recurse`). Note that the no-Python guard does
**not** scan `.codex/**`, so the Codex copies are outside its reach; the policy still binds but the
automated check does not extend there.

Registry 5 is held **textually identical** to registry 4 by
`tests/scripts/dev_tools/test_poshqc_bundled_parity.py`, so the two edits must match character for
character, not merely be equivalent.

`legacy-codex-hook-contracts.Tests.ps1` is at 494 of 500 lines. Registration 3 appends to an
existing single-line array and adds no line, which fits even for two members. **Any new scenario for
that side must go in a new test file**, not into that suite.

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

### D11 — The whole Bash-classifying hook family is IN SCOPE (orchestrator decision, settled, reverses the prior Non-Goal)

This decision **supersedes the Scope & Non-Goals bullet that deferred five hooks to a single
follow-up candidate**. That bullet brought the preimplementation gate, the promotion hook, and the
pr-author helpers into scope and deferred `enforce-epic-merge-gate.ps1`,
`enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`,
`enforce-parallel-abandon-gate.ps1`, and `validate-bash.ps1`. That deferral is overruled: all five
move into scope, together with a ninth site the 2026-09-06 re-derivation discovered.

The Non-Goal bullet is withdrawn from the Scope & Non-Goals list rather than edited into a different
claim, and its full prior text is quoted here so the record of what was deferred survives the
withdrawal:

> **The remaining hook-family members**, to be filed as a single follow-up candidate citing this
> specification and the research: `enforce-epic-merge-gate.ps1`,
> `enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`,
> `enforce-parallel-abandon-gate.ps1`, and `validate-bash.ps1`. The follow-up covers `gh` and `git`
> global-option relocation in the merge and removal gates.

This is the same additive discipline D8 imposes on issue #539's specification: the superseded
statement is preserved verbatim next to the decision that supersedes it, rather than being silently
rewritten.

The rationale has two parts, and both are load-bearing.

**First, every deferred hook carries the identical defect at a verified file and line.** The defect
class is classification of a Bash command by regex or substring match over raw command text, with no
notion of where a command begins and no awareness of quoting. Each deferred member exhibits it:

| Hook | Lines | Defect site (verified 2026-09-06) | Deny code |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 452 | L377 scope filter `(?i)\bgh\s+pr\s+merge\b` conjoined with `--merge\b` over raw text; L146 anchored PR-number branch; L154 unanchored PR-number branch | `EPIC_MERGE_GATE_BLOCKED` |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 419 | L347 scope filter `(?i)\bgit\s+worktree\s+remove\b`; L147 operand extractor `(?i)\bgit\s+worktree\s+remove\s+(?<path>\S+)` | `EPIC_WORKTREE_REMOVAL_BLOCKED` |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 281 | L206 scope filter and L70 operand extractor, both **byte-identical** to the epic gate's | `PARALLEL_WORKTREE_REMOVAL_BLOCKED` |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 256 | L108 and L133, two `String.Contains(..., OrdinalIgnoreCase)` tests over whole command text; tokens declared once each at L41 and L42 | `PARALLEL_ABANDON_BLOCKED` |
| `.claude/hooks/validate-bash.ps1` | 230 | L48–L55 six denylist literals compared with `$Command.Contains($pattern)` at L73; L89 `cd`-chained regex matched at L105 | prose reasons, no reason-code token |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 104 (`wc -l`) | L67 `(?i)\bgh\s+pr\s+create\b` in `Test-EpicBaseBranchOverride` | `EPIC_BASE_BRANCH_MISMATCH` |

The last row is the ninth site. It appeared in no prior scope list — not in this specification, not
in the plan, not in the epic brief, and not in issue #591's lifecycle record. It is dot-sourced by
`enforce-pr-author-skill.ps1` at line 144, immediately above the helpers dot-source at line 148, so
it already loads into the same scope as the hook D6 puts in scope. It is the same defect class in
the same family, so it is included here rather than deferred.

**Second, closing the defect on part of the family in the very change that builds the classifier
would leave the family asserting against two different matchers.** Both worktree-removal gates carry
byte-identical regex literals — a copy-paste duplication of one concern across two files — so fixing
one and deferring the other would create a divergence where none exists today. The marginal cost of
each additional site is applying an existing constant table and an existing predicate to another
call site, not designing anything new. The consistency argument that put the pr-author relocation in
scope under D6, and the promotion-hook relocation in scope under D10, applies unchanged.

The full in-scope set is therefore **nine Claude-side hook files**:

| Hook | Lines (`Get-Content`) | Prior status |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 490 | in scope (originally filed) |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 275 | in scope (D5, D10) |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 228 | in scope (D6) |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 452 | out of scope -> **in scope** |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 419 | out of scope -> **in scope** |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 281 | out of scope -> **in scope** |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 256 | out of scope -> **in scope** |
| `.claude/hooks/validate-bash.ps1` | 230 | out of scope -> **in scope** |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 104 (`wc -l`) | newly discovered -> **in scope** |

Two prior scope questions are answered explicitly rather than left to inference:
`enforce-parallel-abandon-gate.ps1` is **in scope**, and `validate-bash.ps1` is **in scope**. The
supplementary research recommended deferring both; that recommendation is not adopted, for the
consistency reason above.

Two acceptance criteria are void under this decision and have been replaced in the Acceptance
Criteria section. Their prior text is preserved here:

> - No out-of-scope hook is modified: `enforce-epic-merge-gate.ps1`,
>   `enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`,
>   `enforce-parallel-abandon-gate.ps1`, and `validate-bash.ps1` carry no diff, and no file under
>   `.github/instructions/` or `.claude/rules/` is modified.
> - A single follow-up candidate is filed covering the out-of-scope family members and `gh`/`git`
>   global-option relocation in the merge and removal gates, citing this specification and the #545
>   research.

The first is void because all five named hooks are now in scope and must carry a diff. The second is
void because issue #591 already exists for the merge-gate instance, is open with no work done
against it, and is superseded by this issue rather than joined by a new one.

#### D11.1 — The module form stays as D7 records it: a dot-sourced `.ps1`, not a `.psm1`

The two 2026-09-06 research artifacts disagreed on this. It is settled in favor of D7.

Decisive evidence, verified on the current tree: a content search for `Import-Module` across the
entire `.codex/` tree returns **zero matches**. Every Codex hook that consumes shared code does so by
dot-sourcing a sibling, in the shape `. (Join-Path $PSScriptRoot '<sibling>.ps1')`. Independently, a
content search for `claude/lib` across
`extensions/drm-copilot/resources/codex-and-agents-customizations/` also returns zero matches, and
the Codex core manifest's `paths` array carries no `.claude/**` entry: `.claude/lib` is never
delivered to the Codex side. A `.psm1` under `.claude/lib/` therefore cannot serve the Codex copies
of `enforce-orchestration-preimplementation-gate.ps1` and `enforce-promotion-mcp-only.ps1`, both of
which are in scope and both of which carry the originally-filed defect.

**Why narrowing to Claude-only is rejected, recorded so it is not re-litigated.** One research
artifact proposed placing the parser under `.claude/lib/` and declaring the Codex hooks out of
scope. That would fix the originally-filed defect on one runtime while leaving it live on the other.
That divergence is worse than the current state, in which both runtimes are equally affected: it
converts a uniform, documented defect into a runtime-dependent one, and it is the "second
implementation that drifts" outcome the repository's enforcement-hook policy exists to prevent (D1,
rejected alternative C, states the same principle for a Python leg).

#### D11.2 — The parser ships as two files, planned from the start

Both research artifacts independently estimated the parser at roughly 420–620 lines against the
500-line cap, from two different methods (a per-function line budget, and a measured
lines-per-function density against three in-repo comparators). Treating the split as a contingency,
as D7 originally did, is what would force a mid-execution rework of both pack manifests, both
runsettings files, and the `$script:SharedModuleNames` array.

The parser therefore ships as **two dot-sourced siblings**:

| File | Contents |
| --- | --- |
| `hook-command-scanner.ps1` | D2 Piece 1 and Piece 2: segmentation, quote and heredoc masking, tokenization, the `HasLiveSubstitution` and `Unbalanced` determinations, the wrapper carve-out constant, and scan-text selection. |
| `hook-command-invocation.ps1` | D2 Piece 3 and the retrieval surface: the git, gh, and npx global-option tables, the transparent-wrapper set, structural invocation matching, operand retrieval, and flag presence and value retrieval. |

Each requires the same registration set. The consequence, stated so no planner discovers it late:
**fourteen entries across the same five registry files, plus eight file copies.** The registry-file
count is unchanged at five.

Independent confirmation that the scanner cannot be inline code: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
is at 490 of 500 lines and its Codex copy at 495 of 500. Neither can absorb a reworked classifier
body.

#### D11.3 — `validate-bash.ps1` needs a matching-primitive change, not only a scan-text change

`Get-BlockedBashPattern` returns six literals at lines 48–55 and `Get-BlockedPatternMatch` tests each
with `$Command.Contains($pattern)` at line 73. That primitive has three properties, each of which is
a defect: no token boundary of any kind, ordinal case-sensitive comparison, and required adjacency.
Two consequences are in scope and **both must be fixed and both must be tested**:

1. `git push --force-with-lease origin HEAD` is **denied today**, because the literal
   `git push --force` is a prefix substring of it. The lease-safe form the repository's own workflow
   prescribes is blocked by the gate meant to protect against the unsafe form.
2. `git -C ../wt push --force` **passes ungated today**, because the `-C ../wt` global option breaks
   adjacency and none of the six literals is a substring of the line.

Moving the scan onto per-segment masked text fixes neither. The fix is to compare each literal
against the segment's `Tokens` by **token equality** rather than by `String.Contains`, and to apply
the D2 Piece 3 structural `git` classifier so the relocating spelling classifies.

Stated explicitly so a later reviewer does not read rule R2 as prohibiting it: **R2 governs the text
of a trigger literal, not the operator it is compared with.** All six literals stay byte-unchanged.
Changing `Contains` to token equality is inside the contract, and this paragraph is the record of
that ruling.

#### D11.4 — The wrapper carve-out set stays pinned as a single named constant

Whether the set grows from its current fourteen members — the supplementary research proposed adding
`sudo`, `doas`, `nice`, `stdbuf`, `setsid`, `script`, and `parallel`, which would take it to
twenty-one — is an implementation judgment, not a decision fixed here. `parallel` is already recorded
as a known unlisted wrapper in residual risk D4.3.

Whatever the final membership, two conditions bind. The set is a **single named script-scope
constant**, and it is pinned by a named test asserting its exact membership against that constant
(rule R6). And if the count changes, **the acceptance criterion that names the member count must be
amended in the same change**, so the specification never contradicts the code.

#### D11.5 — A cross-runtime divergence is folded in as an in-scope defect

`.codex/hooks/enforce-epic-worktree-removal-gate.ps1` line 35 already parses a leading `--force` and
quoted operands structurally:

```powershell
'(?i)\bgit\s+worktree\s+remove(?:\s+--force)?\s+(?:"(?<double>[^"]+)"|''(?<single>[^'']+)''|(?<bare>\S+))'
```

The Claude copies do not. Consequently
`git worktree remove --force /repo/worktrees/item-a-101` captures the literal `--force` as the
worktree path on the Claude side, matches no checkpoint record, and **falsely denies a legitimate
removal**. This behavior is currently unpinned by any test: the existing case at
`tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` line 78 uses the
flag-after-path spelling, which the current regex handles. Closing the divergence is in scope, and
the new operand retrieval must resolve the path for both spellings.

The divergence runs the other way for the merge gate. `.codex/hooks/enforce-epic-merge-gate.ps1`
carries only the anchored PR-number branch at line 33; it has no analogue of the Claude copy's
unanchored branch at line 154. **The issue #591 operand mis-parse is therefore Claude-only**, and the
Codex merge gate must not acquire it while being brought onto the shared parser.

#### D11.6 — Two follow-ups that are NOT delivered here

Recorded so they are not silently lost. Neither is in scope, and neither may be counted as delivered
by this change.

1. **`.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` is unregistered.** It is
   477 lines, was added by issue #554, and is **not** a member of `$script:SharedModuleNames`. Nothing
   therefore pins its byte identity against its bundle mirror, its parse, its 500-line cap, or its
   pack-manifest membership. Its bundle mirror exists, but no test compares them. This is a
   pre-existing registration gap not caused by this change, and it must be **filed separately**
   rather than folded in.
2. **The `--disposition=abandon` bypass in `enforce-parallel-abandon-gate.ps1` is derived, not
   executed.** The finding follows from `scripts/dev_tools/parallel_mutation_abandon_cli.py` line
   236 registering `--disposition` as an ordinary `argparse` optional with `choices`, and from
   standard `argparse` acceptance of the `--option=value` spelling; the hook's substring is the
   space-separated form only. It has not been run. **Runtime confirmation is required before the
   corresponding acceptance criterion is checked off.**

A third constraint applies to any fix in that hook and is not a follow-up but a binding requirement:
`tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` parses both the hook and the CLI at run
time and fails if either side's token declaration changes shape, so both token literals must stay in
their current single-assignment form at lines 41 and 42.

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

## D12 — Public Parser Contract (normative; consumed by epic children D and G)

The parser's public function signatures are a **consumed contract**, not an implementation detail.
Two other children of the `cleanup-merged-worktrees-hardening` epic edit two of these hooks
immediately after this work lands:

- **Child D** adds cleanup-manifest acceptance to `enforce-epic-worktree-removal-gate.ps1`.
- **Child G** adds a consolidation-PR checkpoint shape to `enforce-epic-merge-gate.ps1`.

Both depend on this child. **Edits to those two hooks must stay confined to the command-detection
call site and its immediate helpers.** A child that reaches past the call site into the parser, or
that reintroduces a raw-text match alongside it, breaks this contract and must be rejected at review.

The signatures below are normative. They are stated in the dot-sourced `.ps1` form settled by D7 and
D11.1, so there is no `Export-ModuleMember`; each file defines advanced functions only and is
consumed with `. (Join-Path $PSScriptRoot 'hook-command-scanner.ps1')` and
`. (Join-Path $PSScriptRoot 'hook-command-invocation.ps1')`.

### Defined in `hook-command-scanner.ps1`

```powershell
function Read-CommandLineSegment {
    <#
    .SYNOPSIS
        Scan a raw Bash command line into an ordered list of segment records.
    .DESCRIPTION
        A single left-to-right scan tracking single-quote spans, double-quote spans,
        backslash escapes, and a heredoc delimiter state machine. Segment delimiters,
        recognized only outside quoted spans and heredoc bodies: ';', '&', '|', newline,
        and the subshell/group/substitution openers and closers '(', ')', '{', '}',
        '$(' and the backtick.

        Pure: reads no file, starts no process, reads no clock, mutates no input.
    .PARAMETER CommandText
        The raw Bash command text, exactly as delivered by
        Get-ClaudeHookToolInputString -Name 'command'.
    .OUTPUTS
        System.Management.Automation.PSCustomObject[] - one record per segment, in
        source order. Each record carries:
          RawText             [string]   the segment's original text, unmodified
          MaskedText          [string]   quoted spans and attached heredoc bodies
                                         replaced by single spaces
          Tokens              [string[]] quote-stripped, whitespace-delimited tokens
          CommandWord         [string]   the first token after any VAR=value prefixes,
                                         or '' when the segment has no command word
          IsWrapperLed        [bool]     $true when CommandWord is a member of the
                                         wrapper carve-out set
          HasLiveSubstitution [bool]     $true when '$(' or a backtick occurred inside
                                         one of the segment's double-quoted spans
          Unbalanced          [bool]     $true when a quote span or heredoc did not
                                         close before end of text
          ScanText            [string]   the clause-ordered selection: RawText when
                                         Unbalanced or HasLiveSubstitution or
                                         IsWrapperLed; MaskedText otherwise
        Returns an empty array for null, empty, or whitespace-only input.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $CommandText
    )
}
```

### Defined in `hook-command-invocation.ps1`

```powershell
function Test-CommandLineInvocation {
    <#
    .SYNOPSIS
        Report whether a command line invokes a named command word with a named
        subcommand path, structurally rather than by raw-text adjacency.
    .DESCRIPTION
        Scans every segment produced by Read-CommandLineSegment. For each segment:
        skips VAR=value env-assignment prefixes; skips the transparent wrappers
        (command, env, nohup, time, timeout); requires the next token to equal
        CommandWord case-insensitively; absorbs the modeled global options for that
        command word; then matches SubcommandPath token-for-token against the
        following non-option tokens.

        FAIL-CLOSED RULES, all mandatory:
          - An unmodeled dash-leading token between the command word and the
            subcommand classifies as a match. Over-classification only forces a
            checkpoint check; under-classification is a bypass.
          - A non-dash token that is not the next expected subcommand element
            terminates that segment's scan without a match, so 'git log --grep add'
            does not classify as 'git add'.
          - A segment whose Unbalanced flag is set classifies as a match, because its
            structure could not be resolved.
          - A wrapper-led segment (IsWrapperLed) classifies as a match whenever its
            RawText contains the command word and every subcommand element, in any
            arrangement. This preserves today's denial for xargs, env, nested shells,
            and the pwsh -Command wrapper, and is the direct answer to issue #539 D8.
          - A segment whose HasLiveSubstitution flag is set is evaluated against
            RawText by the same wrapper rule.
    .PARAMETER CommandText
        The raw Bash command text.
    .PARAMETER CommandWord
        The command name, e.g. 'git' or 'gh'. Compared case-insensitively.
    .PARAMETER SubcommandPath
        One or more ordered subcommand tokens, e.g. @('worktree','remove'),
        @('pr','merge'), @('issue','create'), @('add'). Compared case-insensitively.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $CommandText,

        [Parameter(Mandatory)]
        [string] $CommandWord,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $SubcommandPath
    )
}

function Get-CommandLineOperand {
    <#
    .SYNOPSIS
        Return the positional operands of a matched invocation, in source order.
    .DESCRIPTION
        Locates the first segment in which CommandWord + SubcommandPath match
        structurally, then returns the non-option tokens that follow the subcommand
        path in that segment only. Modeled option-with-argument pairs are consumed
        (so '--force' contributes nothing and '-C <arg>' consumes both tokens);
        a token after a bare '--' separator is always an operand; a dash-leading
        token that is not modeled terminates operand collection, because its arity
        is unknown and a wrong guess would silently return a flag as a path.

        The operand list comes from the MATCHED segment only. A 'cd <path>' segment
        chained before the invocation contributes nothing, which is the direct fix
        for issue #591.
    .PARAMETER CommandText
        The raw Bash command text.
    .PARAMETER CommandWord
        The command name.
    .PARAMETER SubcommandPath
        The ordered subcommand tokens.
    .OUTPUTS
        System.String[] - operands with balanced quotes already stripped, in source
        order. An empty array when no segment matched, or when the matched segment
        carries no operand. Never $null.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $CommandText,

        [Parameter(Mandatory)]
        [string] $CommandWord,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $SubcommandPath
    )
}

function Get-CommandLineFlagValue {
    <#
    .SYNOPSIS
        Return the value of a named flag belonging to a matched invocation.
    .DESCRIPTION
        Locates the matched segment as Test-CommandLineInvocation does, then searches
        that segment's tokens for FlagName. Recognizes both the separated form
        ('--merge 688') and the equals form ('--merge=688'). Returns $null when the
        flag is absent, when the flag is present with no following value token, or
        when the following token is itself dash-leading.

        The $null-on-missing-value contract is mandatory and is pinned by issue #591's
        first constraint: downstream logic treats a missing explicit pull-request
        number as a fail-closed condition, so a bare 'gh pr merge --merge' must yield
        $null, never 0 and never ''.
    .PARAMETER CommandText
        The raw Bash command text.
    .PARAMETER CommandWord
        The command name.
    .PARAMETER SubcommandPath
        The ordered subcommand tokens.
    .PARAMETER FlagName
        The flag as written, including leading dashes, e.g. '--merge' or '--body-file'.
        Compared case-insensitively.
    .OUTPUTS
        System.String or $null. Quotes are already stripped. Callers that need an
        integer cast the result themselves after a $null check.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $CommandText,

        [Parameter(Mandatory)]
        [string] $CommandWord,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $SubcommandPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $FlagName
    )
}

function Test-CommandLineFlag {
    <#
    .SYNOPSIS
        Report whether a named flag is present on a matched invocation, regardless of
        whether it carries a value.
    .DESCRIPTION
        Presence-only companion to Get-CommandLineFlagValue, for boolean flags such as
        '--merge', '--force', and '--body'. Matches both '--flag' and '--flag=value'.
        Exact token comparison after quote stripping: '--body' does not match
        '--body-file', which is the distinction the pr-author hook's negative lookahead
        currently expresses as '--body(?!-file)\b'.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $CommandText,
        [Parameter(Mandatory)][string] $CommandWord,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $SubcommandPath,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $FlagName
    )
}

function Test-CommandLineMention {
    <#
    .SYNOPSIS
        Report whether a command line merely MENTIONS a command word and subcommand
        path without invoking it.
    .DESCRIPTION
        Convenience inverse used by hooks that want to log or explain an allow. True
        when the raw text contains the command word and every subcommand element but
        Test-CommandLineInvocation returns false. Purely informational; no hook makes
        a deny decision from this predicate.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $CommandText,
        [Parameter(Mandatory)][string] $CommandWord,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $SubcommandPath
    )
}
```

### Constant accessors

The named constant tables are exposed through getters rather than as bare script-scope variables, so
the pinning tests required by rule R6 and D11.4 assert against a public surface:

- `Get-CommandLineWrapperName` — the wrapper carve-out set (D2 Piece 2).
- `Get-CommandLineTransparentWrapperName` — the transparent-wrapper set used by the structural
  matcher's skip step (D2 Piece 3, step 2): `command`, `env`, `nohup`, `time`, `timeout`. These five
  appear in both sets deliberately, so `env git worktree remove x` classifies by both mechanisms.
- `Get-CommandLineGlobalOption -CommandWord <name>` — the modeled global-option table for `git`,
  `gh`, or `npx`.

### Why `Test-CommandLineFlag` is part of the contract and not optional

`Get-CommandLineFlagValue` returns `$null` both when a flag is absent and when it is present without
a value, so it cannot express presence. The 2026-09-06 call-site walkthrough established that three
call sites cannot be served without a presence test:

| Call site | Flag | Why the value getter is insufficient |
| --- | --- | --- |
| `enforce-epic-merge-gate.ps1` scope filter, line 377 | `--merge` | Boolean flag with an optional adjacent number. |
| `enforce-pr-author-skill-helpers.ps1`, line 178 | `--body` | The hook asks only whether it is present *and distinct from* `--body-file`. |
| Both worktree-removal gates | `--force` | Boolean flag. |

With `Test-CommandLineFlag` present, all call sites in the table below are served and none remains
unserved.

### Call-site rewrites for the D11 hooks

| Call site (verified 2026-09-06) | Replacement |
| --- | --- |
| `enforce-epic-worktree-removal-gate.ps1` L347 scope filter | `Test-CommandLineInvocation -CommandWord 'git' -SubcommandPath @('worktree','remove')` |
| `enforce-epic-worktree-removal-gate.ps1` L147–148 operand extractor | `Get-CommandLineOperand` with the same command word and subcommand path; the function keeps its name, signature, and `$null`-on-miss contract, so the pinning cases at `enforce-epic-worktree-removal-gate.Tests.ps1` lines 136 and 141 are unaffected |
| `enforce-parallel-worktree-removal-gate.ps1` L206 and L70–71 | Identical rewrites; the two files then delegate the duplicated concern to one implementation |
| `enforce-epic-merge-gate.ps1` L377 scope filter | `Test-CommandLineInvocation … @('pr','merge')` conjoined with `Test-CommandLineFlag … -FlagName '--merge'` |
| `enforce-epic-merge-gate.ps1` L146 anchored branch | `Get-CommandLineOperand … @('pr','merge')`, first all-digit operand; preserves the `gh pr merge 410 --merge` behavior |
| `enforce-epic-merge-gate.ps1` L154 unanchored branch | **Deleted.** Replaced by `Get-CommandLineFlagValue … -FlagName '--merge'`, which returns `$null` for a bare `--merge` and the correct number for a `cd`-prefixed line |
| `enforce-pr-author-skill-helpers.ps1` L170–171 | `Test-CommandLineInvocation … @('pr','create')` and `… @('pr','edit')` |
| `enforce-pr-author-skill-helpers.ps1` L177–178 | `Test-CommandLineFlag … -FlagName '--body-file'` and `… -FlagName '--body'`. The downstream `--body-file` **path value** and every `PR_*` reason code stay on the existing raw-text logic, unchanged |
| `enforce-pr-author-skill.epic-base-branch.ps1` L67 | `Test-CommandLineInvocation … @('pr','create')`; the `--base` value then comes from `Get-CommandLineFlagValue … -FlagName '--base'` |
| `enforce-promotion-mcp-only.ps1` token loop | Iterate `Read-CommandLineSegment` and run the four **byte-unchanged** literals against each segment's `ScanText` |
| `enforce-promotion-mcp-only.ps1` L101 | `Test-CommandLineInvocation … @('issue','create')` or `… @('issue','new')` (D10) |
| `enforce-promotion-mcp-only.ps1` L110–111 | The **byte-unchanged** lookahead pattern, evaluated per segment against `ScanText` |
| `enforce-orchestration-preimplementation-gate.ps1` L137 | The five **byte-unchanged** patterns evaluated per segment against `ScanText`, plus the structural `git` legs for `add` and `commit` |
| `enforce-parallel-abandon-gate.ps1` L108 and L133 | Per-segment token tests that accept both the space-separated and `=`-joined spellings; both token literals stay byte-unchanged in their single-assignment form at lines 41 and 42 |
| `validate-bash.ps1` L73 | Token-equality comparison of each byte-unchanged literal against the segment's `Tokens`, plus the structural `git` classifier (D11.3) |
| `validate-bash.ps1` L105 | The `cd`-chained pattern evaluated per segment against `ScanText` |

## Assumptions, Constraints, Dependencies

- Assumptions:
  - `HookPayload.psm1` remains available to the Claude pair and `codex-pretooluse-file-mapping.ps1`
    to the Codex pair. No module change is required, and the new helper introduces no transport
    dependency.
  - The dot-sourced sibling `.ps1` idiom remains the only sharing mechanism that works on both
    pairs, because the `.codex` side has no `lib/` directory. Re-verified 2026-09-06: zero
    `Import-Module` occurrences anywhere under `.codex/`, and zero `claude/lib` references under
    `extensions/drm-copilot/resources/codex-and-agents-customizations/`. This is the evidence D11.1
    rests on.
- Constraints:
  - PowerShell only, PowerShell 7+ compatible. Advanced functions with `CmdletBinding()`, approved
    verbs, `[OutputType()]` on predicates, no `Invoke-Expression`, no global or mutable
    script-scoped state beyond the named read-only constant tables.
  - 500-line cap on every production, test, and reusable script file.
  - **Binding size constraints, measured 2026-09-06 with `@(Get-Content -LiteralPath $path).Count`,
    which is the method the repository's own cap tests use.** The `wc -l` figures recorded in the
    epic brief and in the baseline artifact are one lower for a file with no terminating newline;
    the `Get-Content` figure is the one the gates evaluate.

    | File | Lines | Headroom under 500 |
    | --- | --- | --- |
    | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 495 | **5** |
    | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 490 | **10** |
    | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 494 | 6 |
    | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 500 | **0** |
    | `.claude/lib/hook-payload/HookPayload.psm1` | 496 | 4 |

    The Codex preimplementation gate at 495 is the binding constraint on the whole change. **Neither
    preimplementation-gate copy can absorb inline scanner code**; the scanner must be separate files
    dot-sourced in, which is what D7 and D11.2 require. `legacy-codex-hook-contracts.Tests.ps1` at
    494 can absorb only the single-line `$script:SharedModuleNames` append, so **any new scenario for
    the Codex side must go in a new test file**. `enforcement-hooks-no-python-invocation.Tests.ps1`
    is exactly at the cap and can absorb nothing; a new scenario there needs a sibling file, and the
    new helper files are covered by that suite automatically through its directory walk.
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
   on both sides (the Codex analogue sits at line 250 of
   `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, re-verified
   2026-09-06; the earlier citation of "approximately line 249" is corrected), and a sibling deny
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
- Invocation unit suite(s) for `hook-command-invocation.ps1`, mirrored per side: structural
  invocation matching, the fail-closed rules, operand retrieval, flag presence, flag value, and the
  constant accessors.
- New sibling suites for the six hooks D11 brings into scope, one per hook, each carrying its
  over-match allow cases, its relocation deny cases, and its existing-deny preservation pins:
  `enforce-epic-merge-gate`, `enforce-epic-worktree-removal-gate`,
  `enforce-parallel-worktree-removal-gate`, `enforce-parallel-abandon-gate`, `validate-bash`, and
  `enforce-pr-author-skill.epic-base-branch`. None of these scenarios may be added to an existing
  suite; the four suites nearest the cap are listed under Risks.

### Acceptance test cases the current hooks fail

Each is a concrete, runnable input string with an expected classification, drivable through the
hooks' pure decision seams — no temporary file, no child process, no live executable. AT-1 through
AT-5 and AT-7 fail against the current hooks by construction; AT-6 passes today and must keep
passing.

| ID | Seam | Command text | Today | Required |
| --- | --- | --- | --- | --- |
| **AT-1** | `Invoke-EpicWorktreeRemovalGateDecision` | `git -C /repo/main worktree remove /repo/worktrees/item-a-101`, against an epic checkpoint with no authorizing record | **allow** — no match, so an unauthorized destructive removal proceeds | **deny** with `EPIC_WORKTREE_REMOVAL_BLOCKED` |
| **AT-2** | `Get-EpicMergeGateCommandPrNumber` | `cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688` | returns `2026` | returns `688` |
| **AT-3** | `Get-PromotionBypassReason` | a `cat > … <<'JSON'` heredoc whose body names promotion tools as JSON receipt values | returns the `PROMOTION_MCP_ONLY_BLOCKED` reason | returns `$null` |
| **AT-4** | `Invoke-EpicMergeGateDecision` | a `printf` whose double-quoted text mentions `gh pr merge --merge` | **deny** with `EPIC_MERGE_GATE_BLOCKED` | **allow** |
| **AT-5** | `Get-PromotionBypassReason` | `gh --repo drmoisan/drm-copilot issue create --title "x" --body "y"` | returns `$null` | returns the `gh`-issue blocked reason |
| **AT-6** | `Test-ImplementationCommand` | `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"` | classifies (`$true`) | **still classifies** |
| **AT-7** | `Get-ParallelWorktreeRemovalCommandPath` and the epic twin | `git worktree remove --force /repo/worktrees/item-a-101` | returns the literal `--force`, so a legitimate removal is denied | returns `/repo/worktrees/item-a-101` |

AT-1 is the **mandatory latent-bypass case**: it is the one that demonstrates an unauthorized
destructive command proceeding today. AT-6 is the **deny-preservation pin**: it does not fail today,
and it is the assertion that breaks if the issue #539 D8 fail-open objection is answered wrongly. It
must run in the same suite as AT-1 through AT-5 and AT-7 so a regression is visible in one place.

Paired negatives that must hold in the same suites:

- With AT-2: `gh pr merge --merge` carrying no number still returns `$null` (issue #591 constraint
  1), and `gh pr merge 410 --merge` still returns `410` (issue #591 constraint 2).
- With AT-3: a genuine promotion-script invocation still returns the same blocked reason.
- With AT-5: `gh --repo drmoisan/drm-copilot issue list` still returns `$null`.

The `validate-bash.ps1` equivalents required by D11.3:

| ID | Seam | Command text | Today | Required |
| --- | --- | --- | --- | --- |
| **AT-8** | `Get-BlockedPatternMatch` | `git push --force-with-lease origin HEAD` | **deny** — `git push --force` is a prefix substring | **allow** |
| **AT-9** | `Get-BlockedPatternMatch` | `git -C ../wt push --force origin HEAD` | **allow** by non-match, so a force push executes ungated | **deny** |
| **AT-10** | `Get-BlockedPatternMatch` | `git commit -m "docs: explain why rm -rf is banned"` | **deny** on the quoted mention | **allow** |

The six existing denylist pins and the eight existing `cd`-chain pins in
`tests/scripts/claude-hooks/validate-bash.Tests.ps1` must all pass unmodified alongside AT-8 through
AT-10.

The `enforce-parallel-abandon-gate.ps1` equivalents:

| ID | Seam | Command text | Today | Required |
| --- | --- | --- | --- | --- |
| **AT-11** | `Test-ParallelAbandonCommandInScope` | a `grep` whose quoted search term is the abandon disposition token | `$true`, so searching the repository for the token is denied | `$false` |
| **AT-12** | `Test-ParallelAbandonCommandInScope` | the `=`-joined spelling of the disposition option | `$false`, so the destructive path runs without a confirmation check | `$true` |

AT-12 rests on a finding derived from `argparse` semantics rather than from an executed run. D11.6
requires runtime confirmation before the corresponding acceptance criterion is checked off.

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
  (lines **222–225** on the Claude side; the earlier citation of `lines 219–228` was incorrect —
  that span covers rows 12d through 15c — and is corrected here per the 2026-09-06 re-derivation).
- The `file_path`-branch absolute-path suites, which are unaffected.
- The existing pr-author suites, whose command fixtures are all genuine unquoted `gh pr create` /
  `gh pr edit` invocations.

### Parity and gate verification

The Codex `Get-FileHash` `It`, the Codex pack-manifest `It`, the Claude push-down mirror pytest,
the Claude pack-manifest completeness check, the no-Python scan, and the 500-line checks must all
be green in the same change. Recomputed pair-hash evidence (SHA-256 per pair member, line counts,
method) is recorded under `…-545/evidence/other/`, following the #539 artifact shape. Hashes must be
recomputed at the final commit, not carried forward from an earlier batch.

Baseline pair parity is green: as of 2026-09-06 all nine in-scope Claude hooks are byte-identical to
their Claude bundle copies, and all seven Codex-side files checked are byte-identical to their Codex
bundle copies. Any pair failure observed later in this work is therefore caused by this change and is
not inherited.

**Unobservable-gate correction.** Any acceptance condition that depends on the state of
`.claude/state/` must be **re-grounded or removed before it is used**. The directory **does not exist
in this checkout**, so a gate phrased as a delta against a pre-existing
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` failure rests on a condition that
may never be observed, and an instruction to "rerun until the pre-existing failure is observed" is
unsatisfiable. The correct replacement is an absolute gate — that pytest passes — rather than a
zero-delta gate against a baseline failure that does not reproduce here.

### Coverage

Line coverage >= 85% on every changed or added production PowerShell file, with both new helper
files inside the denominator in **both** runsettings lists. Verification gotcha: the MCP PoshQC test
runner reads the installed extension's settings, so newly added coverage entries are invisible to
it. Coverage evidence for the new helpers must be produced by invoking the self-hosted PoshQC module
directly, with an explicit `-SettingsPath` pointing at the in-repo settings file.

**Measurement conflict, recorded so neither figure is carried forward.** This specification and its
plan previously cited an aggregate of approximately `61.6%` and a `CodeCoverage.Path` allow-list
length of `83` entries. Both are unreliable:

- The `61.6%` aggregate is contradicted by the plan's own baseline artifact
  `evidence/baseline/baseline-selfhosted-coverage.2026-08-25T13-37.md`, which records a report-level
  LINE coverage of `96.1433%`. The two figures cannot both describe the same measurement, and this
  specification does not adjudicate between them.
- The `83`-entry count is stale. The list has grown since 2026-08-25 — issue #554 added two
  `-modes.ps1` entries among others — and it contains a pre-existing duplicate of
  `.claude/hooks/enforce-pr-author-skill.ps1`, so any arithmetic phrased as "the list length
  increases by exactly N" is wrong on two independent grounds.

Both figures **must be re-measured at execution**. No acceptance criterion in this specification
cites either number, and none may be added that does so without first re-deriving the value
programmatically.

Reading a per-file percentage out of the emitted report requires a **package-qualified** selection:
the `counter` element whose `type` is `LINE`, on the `sourcefile` element whose `name` equals the
bare filename, selected within the enclosing `package` element whose `name` ends with that file's
directory. A bare-filename lookup is ambiguous because several filenames occur under both
`.claude/hooks` and `.codex/hooks`.

### Manual validation

Replay the five 2026-08-24 over-match instances and confirm each proceeds: the JSON receipt write
containing `--body-file`; a checkpoint write whose required-MCP-tool list names the promotion
tools; the memory-file write quoting the staging literal; the heredoc JSON body mentioning a Python
tool name; and prose quoting the two-word staging invocation. Then confirm `git -C <dir> add .`
denies against a not-ready checkpoint.

## Acceptance Criteria

- [x] A regression test demonstrating the **over-match** direction exists and is recorded as
      failing against the unfixed hooks: a heredoc prose mention of a governed token in a
      non-wrapper segment is asserted to allow, with fail-before output recorded under
      `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/`.
- [x] A regression test demonstrating the **under-match** direction exists and is recorded as
      failing against the unfixed hooks: `git -C ../x add .` against an explicitly not-ready
      checkpoint is asserted to deny, with fail-before output recorded under the same evidence
      path.
- [ ] Both regression tests pass after the fix, on both the Claude and the Codex sides, with
      pass-after output recorded under the same evidence path.
- [x] The scanner produces, for each segment, the five properties named in D2 Piece 1 (`RawText`,
      `MaskedText`, `Tokens`, `HasLiveSubstitution`, `Unbalanced`), and a named Pester case exists
      for each heredoc rule in D2 Piece 1: `<<`, `<<-` with leading tabs, a quoted delimiter,
      multiple pending heredocs on one physical line, an unterminated body masking to end of text,
      `<<<` not treated as a heredoc, and a non-literal delimiter forcing a raw scan.
- [x] Scan-text selection follows the three ordered clauses of D2 Piece 2, and the wrapper
      carve-out set is pinned by a named Pester case asserting its **exact** membership against the
      script-scope constant through the accessor `Get-CommandLineWrapperName`. The set contains the
      fourteen members listed in D2 Piece 2 unless the optional additions recorded in D11.4 are
      adopted; if they are, **this criterion and D2 Piece 2 are amended in the same change** so the
      specification and the constant state the same membership. The criterion is satisfied only when
      the asserted membership in the test, the constant in the code, and the list in D2 Piece 2 all
      agree.
- [x] The structural relocation classifier implements the six numbered steps of D2 Piece 3, with
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
- [x] `enforce-promotion-mcp-only.ps1` is changed in all four copies so that its four-token
      `IndexOf` scan and both `gh` expressions evaluate against per-segment scan text from
      `hook-command-scanner.ps1`, with named cases asserting that promotion tool names supplied as
      receipt *values* allow while a genuine promotion-script invocation, `gh issue create`,
      `gh issue new`, and a single-segment `gh api repos/<o>/<r>/issues -X POST` still deny.
- [ ] `enforce-pr-author-skill-helpers.ps1` is changed in both Claude copies so that the
      `isPrCreate` / `isPrEdit` trigger decision evaluates against per-segment scan text and so that
      `gh --repo <o/r> pr create` and `gh -R <o/r> pr edit` classify; named cases assert that a
      quoted `--body-file` mention inside a JSON receipt value allows, and that every `PR_*` reason
      code and receipt check is unchanged for genuine invocations.
- [x] The shared parser ships as exactly two dot-sourced `.ps1` files named
      `hook-command-scanner.ps1` and `hook-command-invocation.ps1`, each existing at
      `.claude/hooks/`, `.codex/hooks/`, and both bundle locations (eight files total), each
      defining functions only, reading no stdin, containing no `$env:CLAUDE_` reference, and at or
      under 500 lines. Neither is a `.psm1`, and no file is added under `.claude/lib/` by this
      change.
- [x] The registration set from D9 as amended by D11.2 is complete: **fourteen entries across five
      registry files** — one entry per helper in each of the two pack manifests, one array member per
      helper in `$script:SharedModuleNames` in
      `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, and two entries per helper
      (the `.claude/hooks/` and `.codex/hooks/` paths) in each of the two PoshQC coverage lists. The
      two coverage-list edits are **textually identical**, as
      `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` requires.
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
- [ ] **All nine in-scope hooks carry a diff, and each is delivered across its full copy set** (D11).
      `enforce-orchestration-preimplementation-gate.ps1`, `enforce-promotion-mcp-only.ps1`,
      `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, and
      `validate-bash.ps1` are changed in all four locations each;
      `enforce-pr-author-skill-helpers.ps1`, `enforce-parallel-worktree-removal-gate.ps1`,
      `enforce-parallel-abandon-gate.ps1`, and `enforce-pr-author-skill.epic-base-branch.ps1` are
      changed in their two Claude locations each. No file under `.github/instructions/` or
      `.claude/rules/` is modified, and no hook outside this list of nine is modified.
- [ ] **Issue #591 is recorded as superseded by issue #545 and closed on merge.** No separate
      follow-up candidate is filed for the merge-gate, worktree-removal, abandon-gate, or
      `validate-bash` instances, because D11 delivers all of them here. The pull-request body states
      the supersession and names issue #591.
- [ ] The PoshQC toolchain passes clean in a single pass over all changed and added PowerShell
      files: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` →
      `mcp__drm-copilot__run_poshqc_test`, restarting from format on any failure or auto-fix, with
      final results recorded under `…-545/evidence/qa-gates/`.
- [ ] Manual replay is recorded: the five 2026-08-24 over-match instances each proceed, and
      `git -C <dir> add .` denies against a not-ready checkpoint, with results recorded under
      `…-545/evidence/qa-gates/`.
- [x] `enforce-promotion-mcp-only.ps1` in **all four copies** classifies a relocating `gh`
      issue-creation spelling through the structural `gh` classifier of D2 Piece 3, per D10, so
      that `gh --repo drmoisan/drm-copilot issue create` and
      `gh -R drmoisan/drm-copilot issue new` are denied where they pass by non-match today; a named
      Pester case per side — Claude and Codex — asserts the deny (AT-5). The paired negative
      `gh --repo drmoisan/drm-copilot issue list` still allows, asserted in the same file.
      (Concrete owner/repo values are used in place of the earlier angle-bracket placeholders so the
      asserted tokens are real literals.)
- [ ] **AT-1, the mandatory latent-bypass case, denies.** A named Pester case drives
      `Invoke-EpicWorktreeRemovalGateDecision` with the command text
      `git -C /repo/main worktree remove /repo/worktrees/item-a-101` against an epic checkpoint
      carrying no authorizing record, and asserts a deny decision whose reason begins with
      `EPIC_WORKTREE_REMOVAL_BLOCKED`. The same case is recorded failing (as an allow) against the
      unfixed hook, with fail-before output under
      `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/`,
      and passing after the fix in the same suite run.
- [ ] **AT-2, the issue #591 operand mis-parse, is fixed.** A named Pester case drives
      `Get-EpicMergeGateCommandPrNumber` with the command text
      `cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688` and
      asserts the returned value is `688`, not `2026`. Two paired negatives pass in the same file:
      `gh pr merge --merge` with no number returns `$null`, and `gh pr merge 410 --merge` returns
      `410`.
- [ ] **AT-4, the merge-gate over-match, allows.** A named Pester case drives
      `Invoke-EpicMergeGateDecision` with a `printf` command whose double-quoted text mentions the
      gated `gh pr merge --merge` phrase and asserts an allow decision. The case is recorded failing
      (as a deny with `EPIC_MERGE_GATE_BLOCKED`) against the unfixed hook.
- [ ] **AT-6, the wrapper deny pin, still denies.** `Test-ImplementationCommand` returns `$true` for
      `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"`, asserted by a
      named case that runs in the **same suite** as AT-1 through AT-5 and AT-7 so a fail-open
      regression is visible in one place. The existing pin at
      `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` line 140
      also passes unmodified.
- [ ] **AT-7, the cross-runtime divergence, is closed.** Named Pester cases assert that
      `Get-ParallelWorktreeRemovalCommandPath` and `Get-EpicWorktreeRemovalCommandPath` both return
      `/repo/worktrees/item-a-101` for the command text
      `git worktree remove --force /repo/worktrees/item-a-101`, where both return the literal
      `--force` today. The existing flag-after-path case at
      `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` line 78 passes
      unmodified.
- [ ] **`validate-bash.ps1` matching-primitive change is delivered and pinned (D11.3).** Named
      Pester cases assert AT-8 (`git push --force-with-lease origin HEAD` allows), AT-9
      (`git -C ../wt push --force origin HEAD` denies), and AT-10 (a `git commit` whose quoted
      message mentions the recursive-remove literal allows). All six denylist literals returned by
      `Get-BlockedBashPattern` are **byte-unchanged**, verified by diff inspection recorded in the
      scope-and-size evidence artifact, and the six existing denylist pins plus the eight existing
      `cd`-chain pins in `tests/scripts/claude-hooks/validate-bash.Tests.ps1` pass unmodified.
- [ ] **`enforce-parallel-abandon-gate.ps1` is fixed in both Claude copies and pinned.** Named Pester
      cases assert AT-11 (a `grep` whose quoted search term is the abandon disposition token is out
      of scope) and AT-12 (the equals-joined spelling of the disposition option is in scope). Both
      token literals remain in their current single-assignment form at lines 41 and 42, and
      `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` passes. The 24 existing cases in
      `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1` pass unmodified,
      including the order-independence case at line 62. **AT-12 may not be checked off until the
      equals-joined bypass is confirmed by an executed run**, per D11.6, because the finding is
      currently derived from `argparse` semantics rather than observed.
- [ ] **`enforce-pr-author-skill.epic-base-branch.ps1` is fixed in both Claude copies.**
      `Test-EpicBaseBranchOverride` evaluates its trigger through `Test-CommandLineInvocation`, and
      named Pester cases assert that a relocating `gh --repo drmoisan/drm-copilot pr create`
      spelling is classified in epic mode where it is skipped today, and that a quoted mention of
      the `gh pr create` phrase no longer produces `EPIC_BASE_BRANCH_MISMATCH`. The 113-line existing
      suite `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1` passes
      unmodified.
- [ ] **The Codex merge gate does not acquire the Claude copy's defect.** After the change,
      `.codex/hooks/enforce-epic-merge-gate.ps1` still contains no unanchored whole-text digit scan;
      its PR-number resolution goes through `Get-CommandLineOperand` and `Get-CommandLineFlagValue`
      only. Verified by diff inspection recorded in the scope-and-size evidence artifact.
- [x] **The D12 parser contract is documented and honoured.** The public signatures of
      `Read-CommandLineSegment`, `Test-CommandLineInvocation`, `Get-CommandLineOperand`,
      `Get-CommandLineFlagValue`, `Test-CommandLineFlag`, and `Test-CommandLineMention` in the
      delivered code match the param blocks, types, and return shapes stated in D12, verified by a
      named Pester case per function asserting the parameter names and the `OutputType` attribute.
      The three constant accessors `Get-CommandLineWrapperName`,
      `Get-CommandLineTransparentWrapperName`, and `Get-CommandLineGlobalOption` exist and are
      pinned by membership cases.
- [ ] **`Test-CommandLineFlag` exists and is exercised by all three presence-only call sites.** Named
      Pester cases assert that it distinguishes an absent flag from a valueless present flag, and
      that `--body` does not match `--body-file`. A criterion asserting only
      `Get-CommandLineFlagValue` would leave the `--merge`, `--body`, and `--force` call sites
      unserved.
- [ ] **The two deferred follow-ups from D11.6 are filed as separate potential entries, not folded
      in**: the `$script:SharedModuleNames` registration gap for
      `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, and runtime
      confirmation of the equals-joined disposition bypass in `enforce-parallel-abandon-gate.ps1`.
      Each entry cites this specification and D11.6.

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
- **Registration omission.** Missing any of the fourteen registration entries produces a late,
  confusing failure (a pack-manifest assertion, a byte-identity failure, a runsettings text-parity
  failure, or a silent coverage-denominator gap). Mitigation: D9 as amended states the checklist as
  a table and it is an acceptance criterion; the coverage entry in particular is invisible to the
  MCP runner, so the criterion mandates a self-hosted PoshQC invocation with an explicit
  `-SettingsPath`.
- **Widened blast radius.** D11 raises the production surface from three hooks to nine, across
  mixed two-copy and four-copy sets, plus two new helper files in four copies each. Mitigation: the
  copy set and baseline pair parity are recorded in
  `evidence/baseline/baseline-copyset-and-pair-parity.2026-09-06T23-20.md` and were green at
  baseline, so any pair failure is attributable to this change; delivery is batched under the
  change-budget rule below; and each hook has its own sibling suite so a failure localizes to one
  hook rather than to the shared parser.
- **Downstream contract breakage.** Epic children D and G edit two of these hooks immediately after
  this work. If the parser's public signatures drift from D12 during execution, both children break
  after this child has merged. Mitigation: D12 states the signatures normatively, an acceptance
  criterion pins each signature by test, and the children are constrained to the command-detection
  call site and its immediate helpers.
- **Line-cap exhaustion.** The bare pair `461 and 271` recorded here previously did not name its
  files and was ambiguous. Corrected and named, all re-measured 2026-09-06:
  `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` is at **494**;
  `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` at **461**;
  `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
  at **267**; and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
  at **271**. Four further suites are also near the cap and cannot absorb a new scenario:
  `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` at 500,
  `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
  at 491, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` at 455, and
  `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` at 447. Mitigation: only the
  single-line `$script:SharedModuleNames` edit lands in the 494-line file; all new scenarios go into
  new sibling files; and D11.2 fixes the two-file parser split from the start rather than leaving it
  as a mid-execution contingency.
- **Change-budget violation.** The production file count far exceeds the direct-mode cap of 2.
  Mitigation: route through `powershell-orchestrator` or explicit approved batching at 3 production
  and 3 test files per batch, settled at planning time.
- **The hook family is a deterrent, not a boundary.** This fix does not, and does not claim to,
  make the gates tamper-resistant (D4.2). Mitigation: the posture is stated in D4 and must be
  carried into any downstream summary of this change.
- Rollback: reverting restores the pre-existing posture, which is stricter in the masked directions
  and looser in the relocation directions. No new gap is created by a revert.

## Rollout & Follow-up

- Release/rollout steps: land the two new helper files (four copies each), the nine modified hooks
  across their copy sets per D11, the fourteen registration entries across five registry files, the
  new test suites, the two reversed heredoc assertions, and the #539 spec annotations in one feature
  branch and pull request. The pull-request body records that issue #591 is superseded. Both
  bundle copies ship the fix to push-down destinations through the existing publish path. No
  configuration or registration-matcher change is required.
- Post-merge validation: after push-down, confirm in a destination repository that a checkpoint
  write naming the promotion tools proceeds, that a PR-receipt JSON write containing `--body-file`
  proceeds, and that `git -C <dir> add .` denies against a not-ready checkpoint.
- The previously recorded single follow-up candidate is **withdrawn by D11**: `gh` and `git`
  global-option relocation in `enforce-epic-merge-gate.ps1`,
  `enforce-epic-worktree-removal-gate.ps1`, and `enforce-parallel-worktree-removal-gate.ps1`,
  token-anywhere semantics in `enforce-parallel-abandon-gate.ps1`, and the substring blocklist in
  `validate-bash.ps1` are all delivered here. Issue #591, which captured the merge-gate instance
  separately, is superseded by issue #545 and is closed when this work merges.
- Follow-ups that remain to file, neither delivered here (D11.6): the `$script:SharedModuleNames`
  registration gap for `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, and
  runtime confirmation of the equals-joined disposition bypass in
  `enforce-parallel-abandon-gate.ps1`.
- Known deferrals recorded, not fixed here: over-match inside wrapper-led segments (D4.1),
  obfuscated respellings (D4.2), and unlisted wrappers whose quoted argument is a command line
  (D4.3).
- Links: issue #545 (https://github.com/drmoisan/drm-copilot/issues/545); issue #591
  (https://github.com/drmoisan/drm-copilot/issues/591), superseded by #545; research
  `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/research/2026-08-25T09-45-enforcement-hook-trigger-matches-whole-command-text-research.md`,
  `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/research/2026-09-06T23-30-command-word-parser-rederivation-research.md`,
  and
  `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/research/2026-09-06T23-40-shared-helper-registration-and-copyset-research.md`;
  epic
  `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md` (this is child E, gap 8);
  predecessor issue #539 and PR #544, with spec
  `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md`
  (design decision D8, D4 rule-table row 14).
