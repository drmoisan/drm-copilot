# Research — Pre-implementation gate worktree selector (issue #671, epic F2)

- **Timestamp:** 2026-09-13T21-15
- **Issue:** #671
- **Epic:** `worktree-scoped-state-resolution`, feature F2, wave 0, complexity C3, `depends_on: []`
- **Worktree researched:** `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae81045c17a23cd1f`
- **Branch at time of research:** `epic/worktree-scoped-state-resolution-integration`

All line citations below were re-derived against the tree as it stands in this worktree. Where a
prior document (the epic manifest or the draft `spec.md`) states a different number, the
discrepancy is called out explicitly.

**Tooling limitation affecting this artifact.** This research session was provisioned with
read-only tools (`Read`, `Grep`, `Glob`, `WebFetch`, `Write`, `Edit`). No shell/execution tool was
available, so no PowerShell session could be started and no `git`, `diff`, or `Get-FileHash`
command could be run. Every claim below is therefore derived from full-file reads and content
searches, and the R10 reproduction is recorded as a **deterministic hand-trace with per-branch
line citations**, explicitly labelled as not executed. The exact command needed to convert it into
an executed artifact is given in `## Open Questions`.

---

## R1 — Current behavior

### The rejecting branch, quoted

`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` lines 227–236:

```powershell
    # Row 14: the command name leads and the subcommand follows immediately. Anything in
    # between - a relocating option or an env-style prefix - moves the pathspec base and is
    # rejected here rather than modelled.
    if ($Token[0] -cne 'git') {
        return $false
    }
    $subcommand = $Token[1]
    if ($subcommand -cne 'add' -and $subcommand -cne 'commit') {
        return $false
    }
```

`-C` is rejected by the **second** conjunct, not the first. For `git -C <dir> add ...` the
tokenizer produces `[git, -C, <dir>, add, ...]`, so `$Token[1]` is the literal `-C`, which is
neither `add` nor `commit`, and the function returns `$false` at line 235. The stated reason is
the comment at lines 227–229: a relocating option "moves the pathspec base", so the repo-relative
prefix test performed by `Test-ExemptOrchestrationOperand` would no longer be sound. The same
rationale is recorded normatively as D4 row 14 (reproduced in R2).

Note the ordering consequence: because the subcommand check runs before any option handling, the
`-C` form is rejected **before** the option table at lines 253–274 is ever consulted. There is no
existing code path that could be widened by adding an entry to that option table; the fix must
change the prologue of `Test-ExemptOrchestrationSegmentToken`.

### Current line numbers of the five helper functions

Identical on all four surface copies (see R6 — all four are content-identical):

| Function | Declared at | Body extent |
| --- | --- | --- |
| `Split-OrchestrationCommandLine` | line 39 | 39–89 |
| `ConvertTo-OrchestrationCommandToken` | line 91 | 91–146 |
| `Test-ExemptOrchestrationOperand` | line 148 | 148–204 |
| `Test-ExemptOrchestrationSegmentToken` | line 206 | 206–294 |
| `Test-ExemptOrchestrationStagingCommand` | line 296 | 296–349 |

Script-scoped constants: `$script:OrchestrationBookkeepingTrees` lines 22–28,
`$script:UnresolvableCommandCharacters` line 33, `$script:PathspecWildcardCharacters` line 37.

### Every call site of `Test-ExemptOrchestrationStagingCommand`

Exhaustive search over the whole worktree (`Grep` for the function name, then a structurally
independent `Grep` for `index -eq 0 -and`; both agree — see `## Numeric Derivation Evidence`
claim N1). **Four** call sites exist, one per surface, all in the gate file and none in
`-helpers.ps1` or `-modes.ps1`:

| Surface | File | Line |
| --- | --- | --- |
| Claude canonical | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 151 |
| Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 151 |
| Codex canonical | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 170 |
| Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 170 |

The Claude call site in context (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
lines 142–156):

```powershell
    for ($index = 0; $index -lt $implementationCommandPatterns.Count; $index++) {
        if (-not (($scanText | Where-Object { $_ -match $implementationCommandPatterns[$index] }) -or ($index -eq 0 -and $isStaging))) {
            continue
        }
        # Allow-side only (issue #539). Index 0 is the git staging trigger, ...
        if ($index -eq 0 -and (Test-ExemptOrchestrationStagingCommand -CommandText $normalizedCommand)) {
            continue
        }
        return $true
    }
    return $false
```

**What the caller does with each result.**

- **`$true`** — `continue`. The loop advances to the next implementation pattern **without**
  returning. This is deliberate: index 0 is the git staging leg only, so a chained line that also
  matches a non-git implementation pattern (pytest, black, npx, `pwsh … Invoke-Pester`) still
  reaches `return $true` at a later index. If no later pattern matches, the loop falls through to
  `return $false` at line 156, `Test-ImplementationCommand` reports "not an implementation
  command", `$requiresReadyCheckpoint` stays `$false` at gate line 387, and
  `Invoke-OrchestrationPreimplementationGateDecision` returns the allow decision at line 398.
- **`$false`** — the `if` is not taken and control reaches `return $true` at line 154.
  `Test-ImplementationCommand` reports "implementation command", `$requiresReadyCheckpoint`
  becomes `$true`, and the decision proceeds to the readiness checks. For a Bash payload the mode
  is always the default `single-feature` (gate lines 373–395 only move the mode on the delegation
  leg), so the terminal outcome is the readiness check at line 439 and, when the checkpoint is not
  ready, the generic deny reason at line 442.

The predicate is therefore **allow-side only and boolean-only**: a `$false` result carries no
reason of its own and reinstates the pre-change deny verbatim. This is stated in the function's
own contract at helpers lines 312–313 ("Consumed allow-side only. A false result restores the
caller's unchanged classification; it never suppresses the trigger.") and is load-bearing for the
deny-reason design in `## Deny Reason Codes`.

### Registration surface

`.claude/settings.json` registers the gate on **three** PreToolUse matchers: the Bash block
(line 107), `Write|Edit` (matcher at line 128, hook at line 152), and `Agent` (matcher at line
177, hook at line 185). The exemption is reachable only from the Bash leg, because
`Test-ImplementationCommand` is called only when the payload carries a `command` field and no
`file_path` (gate lines 380–389).

---

## R2 — The D4 fail-closed rule table

Source: the `spec.md` of the issue **#539** feature folder (the `active` folder whose slug ends
`-539`), section "D4 — Normative fail-closed rule table", lines 109–133. Reproduced complete,
row by row, with the code that realizes each row. The helpers file's own header (lines 12–14)
names this table as its normative contract.

| # | Form | Rule | Reason | Realized by |
| --- | --- | --- | --- | --- |
| 1 | `git add` with zero operands | DENY | Nothing parseable to scope | helpers L283–285 (`$operands.Count -eq 0`) |
| 2 | `git add -A` / `--all` / `-u` / `--update` / `--no-all` variants | DENY | Index-wide/tree-wide staging; no per-path claim | helpers L253–258 (dash-leading token on `add` returns `$false`) |
| 3 | `git add .` / `git add :/` / any `:/`-rooted operand | DENY | Whole-tree operand | `.` → helpers L198–203 (no tree prefix matches); `:/` → L169–171 (leading colon) |
| 4 | `git commit` with no pathspec operand (including `-m`-only) | DENY | Records already-staged content the parser cannot see; the index is not fully gated (`git rm`/`git mv`/`git checkout` are unmatched by the trigger), so staged state is unverifiable | helpers L283–285 |
| 5 | `git commit -a` / `--all` / `-i` / `--include` / `--interactive` / `-p` / `--amend` | DENY | Widens the recorded content beyond the named pathspecs, or rewrites history | helpers L260–273 (only `-m` / `--message` / `--message=` / `-m<value>` are modelled; everything else hits `return $false` at L273) |
| 6 | `--pathspec-from-file=` / `--pathspec-file-nul` | DENY | Pathspecs are off the command line | helpers L253–258 (on `add`) and L273 (on `commit`) |
| 7 | `--` separator | Tokens after `--` are pathspecs even when dash-leading; each must pass the prefix test; `--` with nothing after it and no earlier pathspec ⇒ DENY (rules 1/4) | — | helpers L246–251 (sets `$afterSeparator`) plus L283–285 |
| 8 | Dash-leading token before `--` not in the modeled option allowlist | DENY | Unknown option may be tree-wide; fail closed on the unmodeled | helpers L253–274 |
| 9 | Operand starting with `:` — `:(exclude)`, `:!`, `:/`, `:(top)`, `:(glob)`, `:(icase)`, any magic | DENY | Pathspec magic can escape or invert the tree scope | helpers L169–171 |
| 10 | Leading-dash operand without a preceding `--` | DENY | Indistinguishable from an option (rule 8) | helpers L253–274 |
| 11 | Quoted operands / operands with spaces | Strip balanced quotes, then apply the prefix test; unbalanced quoting ⇒ DENY | — | strip: `ConvertTo-OrchestrationCommandToken` L122–126; unbalanced: `Split-OrchestrationCommandLine` L86 `Balanced` flag, consumed at L332–335 |
| 12 | Operand containing `$` or a backtick, or the segment containing redirection (`>`, `<`) | DENY | Interpolation/redirection not resolvable statically | helpers L33 constant, tested line-wide at L327–329 |
| 13 | Chained/compound lines (`&&`, `;`, `\|\|`, `\|`, newline) | Split into segments outside quotes; every trigger-matching segment must independently pass (a non-git segment matching any other implementation pattern still requires readiness); unsplittable or ambiguous text ⇒ DENY | — | `Split-OrchestrationCommandLine` L74–79; all-segments loop at L342–347 |
| 14 | Anything between the command name and the subcommand (`-C <dir>`, `--git-dir=`, `--work-tree=`, env-style prefixes) | **NEVER EXEMPT** — the parser rejects the segment, so any trigger-matching line containing such a segment is denied. (Superseded in part by issue #545: the bare relocating spelling now classifies rather than passing by non-match; the NEVER-EXEMPT disposition is unchanged.) | Pathspec base relocated; the repo-relative prefix test is no longer sound | helpers L230–236 |
| 15 | Glob operands (`*`, `?`, `[`) | Allow only when the literal prefix before the first wildcard is strictly inside an exempt tree and the token has no `..` segment; otherwise DENY (`docs/features/*` DENIES) | — | helpers L37 constant, L190–196 literal-prefix truncation, L186–188 `..` check |
| 16 | Absolute operands (`/...`, `C:\...`, `\\...`) | DENY | Base not provably the repository root (mirrors the #516 posture) | helpers L178–183 |
| 17 | Any `..` segment | DENY | Escapes the prefix | helpers L186–188 |
| 18 | Backslash separators in an otherwise relative operand | Normalize `\` → `/` before the prefix test | — | helpers L174 |
| 19 | Mixed operand set (one exempt + one production path) | DENY | All-operands-exempt is the invariant | helpers L288–292 |

**This fix touches row 14 and nothing else.** Rows 1–13 and 15–19 must be provably byte-unchanged.
Row 14's disposition is narrowed from "every relocating spelling is NEVER EXEMPT" to "every
relocating spelling except a lexically-resolvable single `-C` selector is NEVER EXEMPT"; the
stated *reason* for row 14 ("Pathspec base relocated; the repo-relative prefix test is no longer
sound") is what the new constraint must answer, and R3 is that answer.

The #539 spec also pins two invariants the fix must not break (lines 192–195): "the block-decision
reason keeps the `PREIMPLEMENTATION_GATE_BLOCKED` prefix and the phrases `route metadata` and
`lifecycle readiness`, which existing tests assert", and "the Codex pair stays byte-identical; the
Claude pair stays content-equal".

---

## R3 — `git -C` semantics and the pathspec base

### Documented semantics (verified against the git manual)

Fetched from `https://git-scm.com/docs/git` during this research. Verbatim, for `-C <path>`:

> Run as if git was started in *<path>* instead of the current working directory. When multiple
> `-C` options are given, each subsequent non-absolute `-C` *<path>* is interpreted relative to
> the preceding `-C` *<path>*. If *<path>* is present but empty, e.g. `-C ""`, then the current
> working directory is left unchanged.
>
> This option affects options that expect path name like `--git-dir` and `--work-tree` in that
> their interpretations of the path names would be made relative to the working directory caused
> by the `-C` option.

Three consequences that bear on the exemption:

1. `-C` changes the **process working directory** before the subcommand runs. Git then performs
   ordinary repository discovery from that directory upward.
2. A relative pathspec on `git add` / `git commit` is resolved against the **current working
   directory inside the repository**, not against the repository root. This is standard git
   pathspec behavior and is why row 14's reason is correct as written: relocating into a
   subdirectory silently changes what `docs/features/active/X` denotes.
3. The documented spelling is space-separated, `-C <path>`. The manual documents **no attached
   `-C<path>` form**. See `## Open Questions` for the residual verification.

### Decision matrix: does `docs/features/active/…` still mean the same thing under `git -C <dir>`?

"Same thing" = the operand denotes a path whose repository-relative form begins with one of the
five exempt tree prefixes at helpers lines 22–28.

| `<dir>` | Repository git resolves | Base for a relative pathspec | Repo-relative form of `docs/features/active/X` | Same meaning? | Recommended verdict |
| --- | --- | --- | --- | --- | --- |
| Absolute path that is the **root of a worktree in this repo's worktree set** (the target case) | this repository, that worktree | that worktree root | `docs/features/active/X` | **Yes** | ALLOW |
| Absolute path that is the **root of a worktree of a different repository** | that repository | that root | `docs/features/active/X` (in that repo) | Yes, relative to that repo's root | ALLOW — the content class is preserved; see R4(a) |
| Absolute path that is a **nested subdirectory** of a worktree, e.g. `<root>/tests/fixtures/resolve_execute_plan_prompt` | containing repository | that subdirectory | `tests/fixtures/resolve_execute_plan_prompt/docs/features/active/X` | **No — escape** | ALLOW, recorded as a measured accepted widening (see below) |
| Absolute path **outside every repository** | none; git exits non-zero with "not a git repository" | n/a | n/a — nothing is staged | n/a | ALLOW but **inert**: the exemption grants permission to run a command that does nothing |
| **Relative** path (`../other-worktree`, `subdir`) | depends on the caller's cwd, which the hook cannot observe | caller cwd + `<dir>` | indeterminate | **No** | DENY |
| Path containing a `..` segment (absolute or not) | indeterminate | indeterminate | **No** | DENY |
| Empty selector (`-C ""`) | caller cwd, unchanged | caller cwd | indeterminate | No | DENY |
| Repeated `-C a -C b` (composed; second relative to first per the manual) | composed | composed | **No** | DENY |
| UNC (`\\server\share\…` → `//server/share/…`) | possibly a repository on a remote share | that share | indeterminate host | No | DENY |
| Globbed selector (`C:/wt-*`) — git does not expand it; the shell might | indeterminate | indeterminate | No | DENY |

### The one genuine escape, and its measured exposure

The nested-subdirectory row is the only case that both passes a purely lexical constraint and
changes the operand's repository-relative meaning. Its practical exposure is measurable, and was
measured in this worktree.

- `Glob '*/**/docs/features/**/*.md'` (nested `docs/features` trees only, root excluded) returns
  exactly **seven** files, all under `tests/fixtures/resolve_execute_plan_prompt/docs/features/active/`:
  `2025-12-18-docs-v3-upgrade-alt/{plan,research,spec}.md` and
  `2025-12-18-docs-v3-upgrade/{plan,research,spec,user-story}.md`.
- `Glob '**/artifacts/orchestration/*.json'` returns exactly **one** file,
  `artifacts/orchestration/orchestrator-state.json` — the real checkpoint, at the repository root.

So the total exposure of the nested-subdirectory escape in this repository is seven Markdown test
fixtures. All seven are `.md`, and the gate's own implementation-path classifier
(`Test-ImplementationPath`, gate line 119) matches only
`\.(py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml)$` — `.md` is absent — so a *write* to any of those
seven files is already non-implementation on the `file_path` leg today. Staging them via a nested
`-C` therefore grants nothing the gate withholds elsewhere.

This is the same form of reasoning, on the same hook, that the gate file already uses and
documents for an analogous accepted widening at lines 101–110 ("Accepted widening: this also
exempts a path OUTSIDE the workspace whose tail is an `artifacts/orchestration/` segment … Measured
exposure in this repository is one matching file, the real checkpoint"). The precedent is
established and its justification format is available for reuse.

---

## R4 — The worktree-set design question

### (a) Must the selector resolve to the root of a worktree in `git worktree list`?

**No. A weaker, purely lexical constraint is sufficient.**

The exemption's invariant is a **content-class** invariant, not a repository-identity invariant.
The #539 spec states it directly at D1 (line 89): "The property that makes a planner commit safe is
*what it stages*, not who runs it or when." The correct extension for this feature — and the
epic's own phrasing of fix 4 (epic.md line 110) — is: *nor from where*. A `-C` selector naming a
foreign repository cannot introduce implementation code into **this** repository; the worst it can
do is stage an orchestration-bookkeeping-tree path in some other repository, which is exactly the
class the exemption already deems safe.

Worktree-set membership would also be the wrong predicate even if it were free. A parallel or epic
child worktree is created and removed during a run. A membership check performed at hook time
against a `git worktree list` taken from the **hook process's own cwd** would answer for whichever
repository the hook happens to be standing in — reintroducing, inside the fix, precisely the
cwd-dependence the epic exists to eliminate.

### (b) What does the gate do with a selector outside that set?

Under the recommendation it is **not denied for being outside the set**, because set membership is
not the predicate. What *is* denied is a selector that is **not lexically resolvable without the
caller's cwd**: relative, `..`-bearing, empty, repeated, UNC, or globbed. Those denials are silent
withholdings of the exemption — the decision JSON is byte-unchanged and the pre-existing generic
deny applies — with distinct greppable diagnostic tokens proposed in `## Deny Reason Codes`.

The reason a lexically-unresolvable selector must deny is not safety-by-analogy but a hard
epistemic limit: the hook receives a `command` string and nothing else. It has no `cwd` field in
the Bash `tool_input` it reads (`Get-StringProperty -Value $toolInput -Name 'command'`, gate line
385, is the only field consulted on this leg). A relative selector is therefore literally
undecidable, and D3 of the #539 spec makes undecidable equal deny.

### (c) The purity tension

The helpers module's contract (lines 5–10) is explicit: "Pure string logic only: no disk, process,
network, or environment access… Every parse ambiguity answers false." A worktree-set membership
check needs `git worktree list` (a subprocess) or a `.git` file/dir probe (disk). Neither can live
in the helpers file without repealing its declared contract — and the sibling `-modes.ps1` file
was created for issue #554 specifically to avoid repealing it (modes file lines 18–25:
"leaving that file byte-untouched is the proof the issue #539 exemption is behaviourally
unchanged").

Could the check live in the caller instead? The caller has host access, but two hard constraints
rule it out:

1. **No headroom.** `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` is 496 lines
   and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is **exactly 500** — zero
   headroom against the cap, which is asserted by a live test
   (`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 106:
   `(Get-Content -LiteralPath $path).Count | Should -BeLessOrEqual 500`). Any reason-plumbing or
   host-probe added to the gate forces a **new extraction from the gate file on all four
   surfaces**, in the same change that must prove the other constraints byte-unchanged. That is
   the exact opposite of the risk posture the must-not-regress list demands.
2. **Latency and reentrancy.** The gate is registered on three PreToolUse matchers (Bash,
   `Write|Edit`, `Agent` — `.claude/settings.json` lines 107, 152, 185), so it runs before every
   Bash call, every file write, and every delegation. It is already a `pwsh -NoProfile` process
   start per call. Adding a `git worktree list` child process puts a second process start plus
   repository discovery on that path for **every** governed tool call, not only staging calls, and
   on Windows with a cold filesystem cache that is a tens-to-hundreds-of-milliseconds tax paid
   unconditionally. Reentrancy: the gate would shell out to `git` from inside a hook that fires on
   `git` invocations. The child is not itself a Bash tool call, so the Claude hook chain is not
   re-entered — but the design creates a hard dependency on `git` being on `PATH` inside the hook
   process and on the hook process's cwd being inside a repository, which is the failure mode the
   epic is fixing. It also makes the classifier non-deterministic and untestable without an
   `Invoke-GitExe` wrapper seam (`.claude/rules/powershell.md`, "Design Seams (Minimal DI)"), a
   seam the helpers module's purity forbids and the gate has no room for.

### The two viable designs

**Design A — Lexical absolute-canonical selector (RECOMMENDED).**
Permit exactly one leading `-C <selector>` between `git` and the subcommand, where the selector is
lexically absolute, canonical, and literal. No disk, no process, no environment access. The
repo-relative pathspec prefix test (rows 3, 9, 15–19) is untouched.

*Failure modes:* (i) the nested-subdirectory escape of R3 — a selector naming a subdirectory of a
worktree passes lexically but relocates the operand's repo-relative meaning; measured exposure is
seven `.md` test fixtures that the gate's other leg already treats as non-implementation. (ii) A
selector naming a nonexistent or non-repository directory is allowed but inert — git itself
errors. Neither failure mode admits implementation content into a governed repository.

**Design B — Host-verified worktree-set membership.**
The gate resolves `git worktree list --porcelain` (or probes for `.git`), canonicalizes the
selector, and requires an exact match against a worktree root; the helpers file exposes a new
parameter carrying the verified verdict.

*Failure modes:* (i) requires gate-file edits on files with 4 and **0** lines of headroom, forcing
an extraction from the gate on all four surfaces inside the change that must prove the rest
byte-unchanged; (ii) requires an `Invoke-GitExe`-style seam and mocks, adding non-determinism to a
currently pure, deterministic classifier; (iii) pays a subprocess on every Bash/Write/Edit/Agent
call; (iv) answers from the hook process's own cwd, reintroducing cwd-dependence inside the fix;
(v) fails closed in a hostile way when `git` is absent or the hook's cwd is outside a repository —
the exemption would silently become unreachable again, which is the reported defect.

**Recommendation: Design A.** Rationale in `## Recommended Design`.

### (d) Does the answer change for a relative selector?

**No — relative selectors must be denied outright, and that is a load-bearing part of Design A.**
A relative selector is undecidable from the payload the hook receives (R4(b)). Denying it also has
a concrete engineering payoff: the three existing D4 row-14 deny cases in both command-exemption
suites use relative or non-`-C` spellings —
`git -C ../other add …` (claude suite line 223, codex suite line 227),
`git --git-dir=../other/.git commit …` (claude 224 / codex 228), and
`git --work-tree=../other add …` (claude 225 / codex 229) — so **all three stay deny under Design
A with no assertion reversal**. Design A produces zero expectation changes in the existing suites.

### (e) May F2 depend on F1?

**No, and Design A does not.** The epic manifest gives F2 `depends_on: []` with F1 in the same
wave (epic.md lines 17–22, 246–250). Design A adds no module import, no dot-source, no call into
`.claude/lib/`, and no new file. The entire change is confined to
`enforce-orchestration-preimplementation-gate-helpers.ps1` on four surfaces. If F1's resolution
module later ships, F2's rule composes with it unchanged — the same way row 16 was written to
"compose upstream" with issue #516 (helpers lines 176–177).

There is a second, non-obvious dependency that must also be avoided. `hook-command-invocation.ps1`
(483 lines, dot-sourced by the gate at line 24) already carries an authoritative git global-option
table at lines 32–45, including `-C` in `WithArgument`. It is tempting to reuse it. **Do not.**
That file is also dot-sourced by `.claude/hooks/enforce-epic-merge-gate.ps1` (lines 45–46,
verified), so any change to its option table would widen the epic-merge gate's matcher as a side
effect — explicitly forbidden by the epic's non-goals (epic.md line 117) and by RULING 1. The
table may be cited as a cross-check for R5, and must not be edited or consumed by this fix.

---

## R5 — Other selector spellings

Cross-checked against the git manual (fetched above) and against the repository's own modeled git
global-option table at `.claude/hooks/hook-command-invocation.ps1` lines 32–45
(`WithArgument = @('-C', '-c', '--git-dir', '--work-tree', '--namespace', '--exec-path')`,
`Standalone = @('-p', '--paginate', '--no-pager', '--literal-pathspecs', '--no-optional-locks', '--bare')`).

| Spelling | Moves pathspec base? | Moves repository target? | Other hazard | Disposition |
| --- | --- | --- | --- | --- |
| `-C <dir>` | Yes (to `<dir>`) | Yes (discovery from `<dir>`) | none beyond the above | **PERMIT** when lexically absolute, canonical, literal, and singular |
| `-C<dir>` (attached) | — | — | not a documented spelling | **DENY** — unmodeled; fail closed (see Open Questions) |
| `git -C a -C b` (repeated) | Yes, composed: a non-absolute `b` is resolved relative to `a` (manual, verbatim above) | Yes | composition is the exact ambiguity the rule excludes | **DENY** |
| `-C ""` (empty) | No (manual: cwd left unchanged) | No | tokenizer yields an empty token, so the subcommand no longer immediately follows the selector | **DENY** |
| `--git-dir=<path>` / `--git-dir <path>` | No, but it *disables repository discovery* and asserts the caller is at the worktree top level | Yes | pairs with `--work-tree`; splitting repo from tree makes the operand base doubly indeterminate | **DENY (unchanged)** |
| `--work-tree=<path>` / `--work-tree <path>` | Yes — it *is* the tree root | Partly | same as above | **DENY (unchanged)** |
| `-c <name>=<value>` | Indirectly **yes** — `-c core.worktree=<path>` relocates the working tree through configuration | Indirectly yes | arbitrary config override: also `core.hooksPath`, `alias.*`, `safe.directory` | **DENY (unchanged)** — this is a general config-injection vector, not merely a relocation |
| `--exec-path[=<path>]` | No | No | selects the directory git executes its subcommand binaries from — arbitrary code execution | **DENY (unchanged)** |
| `--no-pager` / `-P` | No | No | harmless, but unmodeled | **DENY (unchanged)** — minimal allow-list |
| `-p` / `--paginate` | No | No | harmless, but unmodeled | **DENY (unchanged)** |
| `--namespace=<path>` | No | Ref namespace only | does not affect `add`/`commit` pathspecs | **DENY (unchanged)** — no need, keep the list minimal |
| `--bare` | n/a | Asserts bare repo | `add`/`commit` are meaningless in a bare repo | **DENY (unchanged)** |
| `--literal-pathspecs` | No | No | would actually *narrow* pathspec semantics | **DENY (unchanged)** — unmodeled |
| `--no-optional-locks`, `--no-replace-objects` | No | No | unmodeled | **DENY (unchanged)** |
| Env-style prefix `GIT_DIR=… git add …` | Yes | Yes | equivalent to `--git-dir` | **DENY (unchanged)** — already denied at helpers L230 (`$Token[0] -cne 'git'`) |
| Transparent wrapper `env git …`, `command git …` | Yes, if the wrapper carries env | Yes | `hook-command-invocation.ps1` L23 recognizes five such wrappers structurally; the #539 parser does not model them at all | **DENY (unchanged)** — helpers L230 |

**Recommended minimal positive allow-list (one member):**

```
-C <absolute-canonical-literal-dir>
```

occurring **at most once**, **immediately after `git`**, with the subcommand **immediately after
the selector value**. Every other dash-leading token between `git` and the subcommand denies, and
every attached or repeated spelling denies. This is the same positive-modelling posture the option
handler already takes after the subcommand (helpers lines 253–274) and the same fail-closed
posture as D4 row 8.

---

## R6 — Mirror surfaces and byte-identity

### Correction to the delegation brief and to the epic

The brief and `spec.md` line 79–83 describe **three** surfaces and nine files. There are **four**
surfaces and **twelve** production files. The fourth is
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, and it is
governed by a hash-binding contract test (below), so omitting it breaks CI. See
`## Numeric Derivation Evidence` claim N2.

`spec.md` line 79 and epic.md line 211 also state the gate file is **495** lines. Re-derived: it is
**496**. Epic.md line 218 states
`enforce-orchestration-preimplementation-gate-helpers.ps1` is **495 lines**; re-derived: it is
**349**. That second error is material — it is the premise for the epic's claim that F2 "requires a
helpers extraction as part of the change" (epic.md line 217). It does not: the helpers file has
151 lines of headroom. See `## Proposed Helpers Extraction`.

### Content comparison — method and results

Method: full reads of all four copies of `-helpers.ps1` and line-by-line comparison of the rendered
text; plus a content-anchored `Grep` for each file family's `.SYNOPSIS` literal to enumerate the
complete copy set. No `Get-FileHash` or `diff` could be run (see the tooling note at the top).

| File family | Copies found | Comparison result |
| --- | --- | --- |
| `-helpers.ps1` | 4 (`.claude/hooks`, `.codex/hooks`, both bundles) | **Content-identical across all four.** All four read as 349 lines with byte-for-byte identical text, including the `.SYNOPSIS` at line 3 and every comment. No deliberate divergence. |
| `enforce-…-gate.ps1` | 4 | **Deliberately divergent between the Claude pair and the Codex pair.** Claude copies are 496 lines; Codex copies are 500. The Codex copies add a `codex-pretooluse-file-mapping.ps1` dot-source (L11), two `apply_patch` file-marker scan loops in `Test-ImplementationCommand` (L137–148), and an extra comment paragraph in `Test-ImplementationPath` (L115–118). Within each pair the copies are the same length and the call site sits at the same line (151 Claude / 170 Codex). |
| `-modes.ps1` | 4 | Claude copies 480 lines; Codex copies 477. Divergent between pairs; consistent within each pair. |

### Line counts and headroom against the 500-line cap

Derived by counting lines matching `^` in each file (equivalent to `(Get-Content).Count`, which is
the expression the 500-line contract test uses).

| # | Surface | File | Lines | Headroom |
| --- | --- | --- | --- | --- |
| 1 | Claude canonical | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 496 | **4** |
| 2 | Claude canonical | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 | **151** |
| 3 | Claude canonical | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 480 | 20 |
| 4 | Claude bundle | `extensions/.../claude-customizations/.claude/hooks/…-gate.ps1` | 496 | **4** |
| 5 | Claude bundle | `extensions/.../claude-customizations/.claude/hooks/…-gate-helpers.ps1` | 349 | **151** |
| 6 | Claude bundle | `extensions/.../claude-customizations/.claude/hooks/…-gate-modes.ps1` | 480 | 20 |
| 7 | Codex canonical | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | **500** | **0** |
| 8 | Codex canonical | `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 | **151** |
| 9 | Codex canonical | `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 477 | 23 |
| 10 | Codex bundle | `extensions/.../codex-and-agents-customizations/.codex/hooks/…-gate.ps1` | **500** | **0** |
| 11 | Codex bundle | `extensions/.../codex-and-agents-customizations/.codex/hooks/…-gate-helpers.ps1` | 349 | **151** |
| 12 | Codex bundle | `extensions/.../codex-and-agents-customizations/.codex/hooks/…-gate-modes.ps1` | 477 | 23 |

**Files at or over the cap:** rows 7 and 10 sit at exactly 500 and **cannot absorb a single new
line**. Rows 1 and 4 have four lines. Consequently **no design that edits any gate file is viable
without a prior extraction from that file**, which is the decisive constraint behind the
recommendation.

### Pack manifests and manifest tests

| Question | Answer | Evidence |
| --- | --- | --- |
| Does a **new** Claude hook file need a manifest entry? | **Yes** — `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (currently 37 `.claude/hooks/…` entries; the gate trio is at lines 35–37). | `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest` (line 139) enumerates every bundled hook script (`hooks_dir.iterdir()`, lines 86–91) and asserts each appears in some pack manifest, with three documented exceptions (lines 55–56). |
| Does a **new** Codex hook module need a manifest entry? | **Yes** — `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (gate helpers/modes at lines 41–42). | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 134: *"lists every shared hook module in the core pack manifest"*, asserting `@($manifest.paths) \| Should -Contain ".codex/hooks/$name"` for each member of `$script:SharedModuleNames` (line 30). A new Codex shared module must be added to that array at line 30 **and** to the manifest. |
| Does a new file need a coverage entry? | **Yes** — see R8. |
| **Does Design A need any of this?** | **No.** Design A adds no new file, so no manifest, coverage, or `SharedModuleNames` edit is required. |

### Parity tests, and exactly what each compares

| Test | Scope | Comparison |
| --- | --- | --- |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 111, *"keeps the canonical hooks byte-identical to their bundled copies"* | `$script:StaticCheckNames` = `$AllHookNames` (11, incl. `enforce-orchestration-preimplementation-gate.ps1` at line 13) + `$SharedModuleNames` (4, incl. `enforce-orchestration-preimplementation-gate-helpers.ps1` at line 30) | **Hash**: `(Get-FileHash -LiteralPath …).Hash` of `.codex/hooks/<name>` vs `extensions/…/codex-and-agents-customizations/.codex/hooks/<name>`, asserted equal. |
| same file, line 93 | same set | **Parse check** plus `(Get-Content).Count \| Should -BeLessOrEqual 500` on **both** roots. |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (line 118) | **every** non-memory file under `.claude/**`, excluding `.claude/settings.local.json` | **Text equality**: `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)` (lines 140–143, UTF-8 decoded). Automatic — a Claude hook edit is required in the bundle with no registration step. |

**Gap worth recording:** `enforce-orchestration-preimplementation-gate-modes.ps1` appears in
**neither** `$script:AllHookNames` nor `$script:SharedModuleNames` (lines 10–30), so on the Codex
side that file is currently outside the parse check, the 500-line check, the byte-identity check,
and the pack-manifest assertion — even though it *is* listed in the Codex `core.json` at line 42.
This is a pre-existing gap, not caused by this feature, and closing it is a candidate follow-up
rather than F2 scope (adding a name to line 30 would consume a test-file slot and expand the
change beyond the one-axis rule).

---

## R7 — Existing test surface

### Files, sizes, and how they drive the hook

Ten suites reference this hook set. None dot-sources `-helpers.ps1` directly; every suite
dot-sources the **gate** file (which transitively dot-sources helpers at gate line 14, modes at
line 20, and the shared scanner/invocation parser at lines 23–24) and drives the pure seam
`Invoke-OrchestrationPreimplementationGateDecision`.

| File | Lines | Under test | Entry |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | 461 | `.claude` gate | dot-source at L6–7 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | **296** | `.claude` gate | dot-source at L17–18 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | 332 | `.claude` gate | L47–48 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | 491 | gate **and** modes | L14–15, L21–22 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` | 159 | gate **and** modes | L34–35, L41–42 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | 223 | `.claude` gate | L141–142 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | **302** | `.codex` gate | L23–25 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | 350 | `.codex` gate | L48–50 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` | 205 | `.codex` gate | L32–34 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | 332 | gate and modes | L37–39, L44–45 |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | 242 | `.codex` gate | L132–133 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 494 | Codex static contracts + process-level runs | see R6 |

### Envelope construction (the pattern the new rows must follow)

`…CommandExemption.Tests.ps1` lines 20–60 define three helpers inside `BeforeAll`:

- `ConvertTo-ExemptionCommandPayload` (L20–32) builds
  `@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5`.
- `ConvertTo-NotReadyCheckpointRaw` (L34–48) builds an explicitly **not-ready** checkpoint
  (`route_id = ''`, `lifecycle_ready = $false`) so that any `allow` must come from the exemption
  alone.
- `Get-ExemptionDecisionForCommand` (L50–60) is the single Act step:
  `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw … -CheckpointRaw …`.

No disk I/O, no child process, no temporary file (stated at L8–10). The Codex suite mirrors this
with `$script:RepoRoot`/`Join-Path` resolution at L23–25.

### Mandatory matrix — what exists today, and what is new

| Mandatory row | Status | Existing coverage |
| --- | --- | --- |
| `git -C <worktree> add docs/features/active/…` → **allow** | **NEW** | No case exists. The nearest is D4 row 14b (claude L223 / codex L227), which is a **relative** `-C ../other` **chained** with a second `git add`, asserting deny. It must remain deny under Design A. |
| `git -C <worktree> add` with a non-exempt pathspec → **deny** | **NEW** | No case exists. |
| `git add` with `-A`, extra options, or `;` / `&&` / `\|` → **deny** | **REGRESSION GUARD (exists)** | claude L190–194 (`-A`, `--all`, `-u`, `--update`, `--no-all`), L208 (`--sparse`), L220–221 (chained non-exempt segment; quote spanning a chain operator). |
| bare `git add` with exempt pathspec, cwd = target → **allow** | **REGRESSION GUARD (exists)** | claude L64–158, eight allow cases covering all five exempt trees, the quoted form, the backslash form, the `-m … --` integration form, and a chained all-exempt line. |
| unbalanced quotes / interpolation / redirection → **deny** | **REGRESSION GUARD (exists)** | claude L215 (unbalanced quote), L216–217 (`$`, backtick), L218–219 (`>`, `<`). |
| D4 row 14a/14c/14d (env prefix, `--git-dir`, `--work-tree`) → **deny** | **REGRESSION GUARD (exists, must not reverse)** | claude L222, L224, L225; codex L226, L228, L229. All stay deny under Design A. |

**Zero assertion reversals.** Every currently-passing expectation in both command-exemption suites
remains correct under Design A. This is a direct consequence of the R4(d) decision to deny
relative selectors: the only existing `-C` fixture uses `../other`.

### The cwd axis — a specification clarification the plan needs

The epic and `spec.md` require a cross product over **cwd** (session root vs item worktree), **path
form** (relative vs absolute), and **target** (own item / sibling / absent). The gate is
session-agnostic: `Invoke-OrchestrationPreimplementationGateDecision` accepts only
`ToolInputRaw`, `CheckpointRaw`, `EpicCheckpointRaw`, `ParallelCheckpointRaw` (gate lines 338–361),
and the Bash leg reads only the `command` field (line 385). There is no cwd input to vary.

For this site the three axes must therefore be **re-expressed** as:

- **cwd axis** → selector **absent** (equivalent to "cwd = target") vs selector **present**
  (equivalent to "cwd ≠ target").
- **path form axis** → **selector** form: absolute vs relative vs `..`-bearing vs UNC vs empty vs
  repeated. The **operand** form stays repo-relative on every row, because D4 row 16 is unchanged
  and an absolute operand still denies.
- **target axis** → selector naming the own worktree root / a sibling worktree root / a
  non-worktree directory. All three are lexically indistinguishable and therefore produce the same
  decision under Design A; the rows still belong in the table as explicit pins of that fact.

---

## R8 — Coverage mechanics

- **Configuration:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, mirrored
  verbatim at `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
  `Run.Path` = `@('scripts', 'tests/powershell', 'tests/scripts')` (line 3). Coverage block at
  lines 17–286: `Enabled = $true`, `OutputFormat = 'CoverageGutters'`,
  `OutputPath = 'artifacts/pester/powershell-coverage.xml'`.
- **`CodeCoverage.Path` is an explicit per-file allow-list, not a glob** (lines 23–283). The
  comment at lines 24–26 says so, and several inline comments (e.g. lines 156–162, 170–174)
  restate that "without this entry the new production module … would sit outside the coverage
  denominator, which the Coverage Exclusion Policy forbids."
- **Existing entries for this hook set:** `.codex/hooks/…-gate.ps1` line 131,
  `.codex/hooks/…-gate-helpers.ps1` line 135, `.codex/hooks/…-gate-modes.ps1` line 139,
  `.claude/hooks/…-gate.ps1` line 225, `.claude/hooks/…-gate-helpers.ps1` line 229,
  `.claude/hooks/…-gate-modes.ps1` line 233. The two bundled copies are **not** listed on either
  surface — they are published payload, not measured production.
- **Is a NEW `.ps1` under `.claude/hooks/` automatically in the denominator?** **No.** It must be
  added explicitly. **File to edit:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`,
  **key:** `CodeCoverage.Path` (the array beginning at line 23). The mirror at
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` must be
  edited identically.
- **Threshold.** `CoveragePercentTarget = 0` at line 285, with the comment *"Optional: don't fail
  the run on coverage percentage"*. The runsettings therefore does **not** enforce the >= 85% line
  threshold; that threshold is a policy gate (`.claude/rules/general-unit-test.md`,
  `.claude/rules/quality-tiers.md`) evaluated by reviewers and CI against the emitted coverage
  report. Branch coverage is **not measured** for Pester at all — `.claude/rules/powershell.md`
  line 64 states Pester reports command (instruction) and line coverage only, and
  `.claude/rules/quality-tiers.md` exempts PowerShell from the branch threshold as a capability
  limit, not a measurement exemption.
- **MCP runner caveat (carry into the plan).** `mcp__drm-copilot__run_poshqc_test` resolves its
  settings from the **installed extension's** payload, not from the repository tree. A newly added
  `CodeCoverage.Path` entry in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` can
  therefore be ignored by the MCP runner until the extension is rebuilt and reinstalled. If a new
  production file is introduced and its coverage must be demonstrated, invoke the self-hosted
  PoshQC module directly against the repository settings file rather than relying on the MCP
  runner's coverage figure. **Design A introduces no new file, so this caveat does not bite** — it
  is recorded because it *would* bite the rejected extraction designs.

---

## R9 — Batch budget

`.claude/hooks/enforce-powershell-batch-budget.ps1` (458 lines):

- **Caps:** 3 production PowerShell files and 3 test PowerShell files per batch (documented at
  lines 10–11; defaults bound at lines 316–317 and 426–427). Overridable per session via
  `CLAUDE_POWERSHELL_BUDGET_PROD` / `CLAUDE_POWERSHELL_BUDGET_TEST` (lines 428–433) or by writing
  `prodCap` / `testCap` into the state file (lines 214–215).
- **Classification (line 284):** `(^|/)tests/.*\.ps1$` **or** `\.Tests\.ps1$` ⇒ test; every other
  `.ps1` / `.psm1` / `.psd1` ⇒ **production**. Note this makes
  `pester.runsettings.psd1` a *production* file for budget purposes.
- **State key:** `.claude/state/powershell-batch-budget.<session_id>.json` (lines 352, 366). The
  session id resolves in order: explicit argument, `CLAUDE_SESSION_ID`,
  `.claude/state/current-session-id`, then a worktree-derived `worktree-<leaf>-<8-hex>` identifier
  built from a SHA-256 of the normalized root (lines 139–173).
- **Containment:** entries resolving outside the batch-budget root are dropped on rehydrate (lines
  217–225) and out-of-root candidates are discarded rather than denied (lines 277–282), so a state
  file carried between worktrees cannot spend this worktree's budget.
- **Reset:** delete the state file. The deny reason names the exact path (line 296). Only
  **distinct** paths consume slots; repeated edits to the same file are free (lines 289–291).

### Files this fix plausibly touches, under Design A

**Production PowerShell (4):**

1. `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
2. `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
3. `extensions/.../claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
4. `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`

**Test PowerShell (2):**

1. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
2. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`

**Verdict:** production count 4 > cap 3, so **exactly one reset point is required**, scheduled
between the third and fourth helpers edit. Test count 2 ≤ 3, so **no test-side reset is required**.
The plan must place the reset explicitly; the hook denies the fourth file with a message naming the
state file to delete.

For comparison, the rejected extraction designs (Design B, or any new helpers file) would touch
4 edited helpers + 4 new files + 2 runsettings `.psd1` = **10 production files** (3 reset points)
and 3 test files including `legacy-codex-hook-contracts.Tests.ps1` (at the cap). That is a further
argument for Design A.

---

## R10 — Reproduction

**Not executed.** This session had no shell tool (see the tooling note at the top of this
artifact), so no PowerShell session could be started. The table below is a **deterministic
hand-trace** of `Test-ExemptOrchestrationStagingCommand`, with the exact terminating line cited for
each input. The function is pure string logic with no branching on time, environment, or disk, so
the trace is total and reproducible; but it is **not** an executed result and must not be cited as
one. `## Fail-Before Evidence` records it in the evidence schema with the execution gap declared.

The invocation that would produce the executed artifact is given in `## Open Questions`.

| # | Command text | Hand-traced result | Terminating line (helpers file) |
| --- | --- | --- | --- |
| 1 | `git add -- docs/features/active/x/spec.md` | **TRUE** (exempt) | L293 `return $true` after L199 prefix match on `docs/features/active/` |
| 2 | `git -C C:/some/worktree add -- docs/features/active/x/spec.md` | **FALSE** | L235 — `$Token[1]` is `-C`, neither `add` nor `commit` |
| 3 | `git -C C:/some/worktree commit -m "msg" -- docs/features/active/x/spec.md` | **FALSE** | L235 — same branch |
| 4 | `git add -A -- docs/features/active/x/spec.md` | **FALSE** | L258 — dash-leading token with `$subcommand -cne 'commit'` |
| 5 | `git add -- src/foo.ts` | **FALSE** | L203 — no exempt tree prefix matches `src/foo.ts`, propagated by L290 |
| 6 | `cd C:/some/worktree && git add -- docs/features/active/x/spec.md` | **FALSE** | L231 — segment 1 tokenizes to `[cd, C:/some/worktree]`, `$Token[0] -cne 'git'` |
| 7 | `git add -- docs/features/active/x/spec.md \| tee out.txt` | **FALSE** | L231 — segment 2 tokenizes to `[tee, out.txt]` |
| 8 | `git add -- "docs/features/active/x/spec.md` (unbalanced quote) | **FALSE** | L334 — `$split.Balanced` is `$false` (quote opened at L69 and never closed) |

Rows 2 and 3 are the defect. Row 1 is the control that proves the exemption itself is intact. Rows
4–8 are the constraints that must remain unchanged.

---

## Recommended Design

**Name: Lexical Absolute-Canonical Selector (LACS).**

A single `-C <selector>` is permitted between `git` and the subcommand when, and only when, the
selector token satisfies all of the following **purely lexical** conditions, evaluated on the
already-tokenized, already-quote-stripped token:

| # | Condition | Rationale |
| --- | --- | --- |
| L1 | The selector option is exactly the token `-C` (case-sensitive `-ceq`, matching the existing `-ceq`/`-cne` posture at helpers L230, L234, L246, L260) | An attached `-C<dir>` spelling is undocumented; case variance is unmodeled |
| L2 | `-C` appears at token index 1 (immediately after `git`) and at most once in the segment | The manual's repeated-`-C` composition is the ambiguity being excluded |
| L3 | A value token exists at index 2 and the subcommand is at index 3 | Preserves row 14's "subcommand immediately follows" shape, one selector deep |
| L4 | After `\` → `/` normalization, the value matches `^[A-Za-z]:/` or `^/` and does **not** start `//` | Absolute so it is resolvable without the caller's cwd; UNC excluded because host resolution is unbounded |
| L5 | No path segment of the normalized value is `..` or `.` | Traversal and non-canonical forms are undecidable |
| L6 | The value contains no character from `$script:PathspecWildcardCharacters` (`*`, `?`, `[`) | A globbed selector is not one directory |
| L7 | The value contains no `:` other than the drive colon at index 1 | Excludes pathspec-magic-shaped and stream-suffixed spellings |
| L8 | The value is non-empty | `-C ""` leaves cwd unchanged (manual) and is therefore not a selector |

Everything after the subcommand — the option handler, the `--` separator, the operand collection,
the all-operands-exempt loop, the prefix test — is **byte-unchanged**. The exempt-tree constant,
the unresolvable-character constant, the wildcard constant, `Split-OrchestrationCommandLine`,
`ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, and
`Test-ExemptOrchestrationStagingCommand` are all **byte-unchanged**. Exactly one function body
changes: the prologue of `Test-ExemptOrchestrationSegmentToken`, plus one new predicate and one new
constant block.

### Why LACS

1. **It widens exactly one axis.** The change is confined to the ten lines of helpers L227–236,
   and every other rule of the D4 table is left textually untouched — which is directly provable by
   diff, and is the evidence the must-not-regress constraint asks for.
2. **It keeps the module's declared purity.** No disk, no process, no environment. The header
   contract at helpers lines 5–10 survives verbatim, so the #554 rationale for the sibling modes
   file ("leaving that file byte-untouched is the proof the exemption is unchanged") is not
   contradicted.
3. **It touches no file that lacks headroom.** The two Codex gate files are at exactly 500 lines.
   LACS edits none of the four gate files and none of the four modes files.
4. **It has no F1 dependency and no shared-parser dependency.** It does not import
   `.claude/lib/**` and does not edit `hook-command-invocation.ps1`, whose option table is also
   consumed by `enforce-epic-merge-gate.ps1` (verified at that file's lines 45–46) — so it cannot
   widen the merge gate's matcher as a side effect.
5. **It reverses no existing assertion.** All three existing D4 row-14 deny fixtures use relative
   or non-`-C` spellings and stay deny.
6. **Its residual exposure is measured, bounded, and precedented.** The nested-subdirectory escape
   costs seven `.md` test fixtures that the gate's own `file_path` leg already classifies as
   non-implementation, and the gate file already carries an accepted-widening record of the same
   shape at lines 101–110.

### Rejected alternatives

| Alternative | Rejected because |
| --- | --- |
| **Host-verified worktree-set membership** (Design B) — resolve `git worktree list` and require an exact root match | Requires edits to gate files with 4 and **0** lines of headroom, forcing a gate-file extraction on four surfaces inside a change whose central requirement is that everything else be provably byte-unchanged. Adds a subprocess to every Bash/Write/Edit/Agent call. Answers from the hook process's own cwd, reintroducing the cwd-dependence the epic exists to remove. Becomes unreachable (the reported defect, restored) when `git` is absent from the hook process's `PATH`. |
| **Reuse `Get-CommandLineOperand` / the shared option table in `hook-command-invocation.ps1`** | That table is shared with `enforce-epic-merge-gate.ps1`; editing it widens the merge gate's matcher, forbidden by epic non-goal (epic.md line 117) and RULING 1. Consuming it unedited would also silently absorb `-c`, `--git-dir`, `--work-tree`, `--namespace`, `--exec-path`, `--bare`, `--force` and friends, widening far past one axis. It would additionally create an implicit load-order dependency: every existing suite dot-sources the gate, but a future suite dot-sourcing only the helpers would break. |
| **Permit `--work-tree` / `--git-dir` alongside `-C`** | Three relocating options interact (the manual: `-C` changes how `--git-dir` and `--work-tree` are interpreted), so the combined base is a product space the lexical rule cannot bound. `-c core.worktree=<path>` makes `-c` a relocation vector too, and `-c` is a general config-injection surface. Keep the allow-list at one member. |
| **Permit relative selectors** (`git -C ../other add …`) | Undecidable from the payload: the Bash leg reads only the `command` field. Also would force reversal of three existing deny assertions. |
| **Relax D4 row 14 wholesale ("any relocating option is fine because the pathspec must still be exempt")** | The reason row 14 gives is exactly right for the nested case: relocating changes what the operand denotes. A wholesale relaxation would also admit `-c`, whose hazard is code and config injection rather than relocation. |
| **Introduce a new helpers file for the selector logic** | Unnecessary: the helpers file has 151 lines of headroom (the epic's premise that it is 495 lines is wrong). A new file would additionally cost two pack-manifest edits, two runsettings edits, a `$SharedModuleNames` edit, and three batch-budget reset points, for no benefit. |

---

## Proposed Helpers Extraction

**No extraction is required.** This section records the projected line counts that demonstrate it,
and corrects the epic manifest's premise.

### Correction

Epic.md line 218 states `enforce-orchestration-preimplementation-gate-helpers.ps1` is **495
lines** and concludes that "F2's extraction targets a second helpers file or a redistribution
across the existing three-file set" (line 220). The file is **349 lines** on every surface. The
495/496 figure belongs to the **gate** file, not the helpers file. With the corrected number, F2
requires no extraction.

### Function placement

All new logic lands in `enforce-orchestration-preimplementation-gate-helpers.ps1` on all four
surfaces:

| Element | File | Kind |
| --- | --- | --- |
| `$script:OrchestrationSelectorOptionName` (+ a short comment block) | `-helpers.ps1` | new constant, ~6 lines |
| `Test-ExemptOrchestrationSelector` — the L1–L8 predicate, `[OutputType([bool])]`, comment-based help citing D4 row 14 | `-helpers.ps1` | new function, ~35 lines |
| Selector absorption in the prologue of `Test-ExemptOrchestrationSegmentToken` (between current L232 and L233) | `-helpers.ps1` | ~14 changed/added lines |
| — | `-gate.ps1` | **unchanged** |
| — | `-modes.ps1` | **unchanged** |

### Projected line counts after the change

| Surface | File | Now | Projected | Headroom after |
| --- | --- | --- | --- | --- |
| Claude canonical | `…-gate.ps1` | 496 | **496** (unchanged) | 4 |
| Claude canonical | `…-gate-helpers.ps1` | 349 | **~404** | ~96 |
| Claude canonical | `…-gate-modes.ps1` | 480 | **480** (unchanged) | 20 |
| Claude bundle | `…-gate.ps1` | 496 | **496** | 4 |
| Claude bundle | `…-gate-helpers.ps1` | 349 | **~404** | ~96 |
| Claude bundle | `…-gate-modes.ps1` | 480 | **480** | 20 |
| Codex canonical | `…-gate.ps1` | 500 | **500** | 0 |
| Codex canonical | `…-gate-helpers.ps1` | 349 | **~404** | ~96 |
| Codex canonical | `…-gate-modes.ps1` | 477 | **477** | 23 |
| Codex bundle | `…-gate.ps1` | 500 | **500** | 0 |
| Codex bundle | `…-gate-helpers.ps1` | 349 | **~404** | ~96 |
| Codex bundle | `…-gate-modes.ps1` | 477 | **477** | 23 |
| Test | `…CommandExemption.Tests.ps1` (Claude) | 296 | **~356** | ~144 |
| Test | `…-command-exemption.Tests.ps1` (Codex) | 302 | **~362** | ~138 |

**No file reaches 500 after the change.** The two files that are already at the cap are not
edited. The ~55-line helpers budget is a ceiling estimate (constant block, one fully-documented
advanced function, and the prologue absorption); if the implementation lands under it, headroom
only improves. If the implementation would exceed ~150 added lines, that is the signal that the
design has drifted beyond one axis and should be re-reviewed rather than split into a new file.

---

## Deny Reason Codes

### Existing reason literals emitted by this hook set (enumerated first)

All three carry the `PREIMPLEMENTATION_GATE_BLOCKED:` prefix, which downstream reason-matching
reads and which the #539 spec pins as unchanged (its lines 192–195).

1. **Payload anomaly** — gate lines 365–368:
   `PREIMPLEMENTATION_GATE_BLOCKED: payload anomaly - <anomaly reason>. The gate fails closed on an envelope it cannot read.`
2. **Mode-scoped readiness failure** — gate lines 333–335:
   `PREIMPLEMENTATION_GATE_BLOCKED: this <mode>-mode delegation was evaluated against <path>, and the failed readiness predicate is '<failure>'. Implementation operations require that checkpoint to satisfy every readiness predicate before implementation begins.`
   The `<failure>` token set is closed and greppable:
   `declared-checkpoint-path` (gate L406); and from the modes file —
   `checkpoint-absent` (L387, L446), `route_id` (L389, L448), `epic_feature_folder` (L392),
   `epic_manifest_path` (L396), `integration_branch` (L399), `features` (L402),
   `parallel_slug` (L451), `parallel_manifest_path` (L454), `items` (L457),
   `target-record` (L404, L459), `merge_status` (L405, L460).
3. **Single-feature generic deny** — gate line 442:
   `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.`

**There is no reason code on the exemption leg at all.** The predicate is `[OutputType([bool])]`
and a `$false` result falls through to literal 3.

### Proposal

**The decision JSON must stay byte-identical.** Adding a reason to the exemption leg requires
changing the predicate's return shape and plumbing a string through the gate — and the two Codex
gate files have **zero** lines of headroom, so that plumbing forces a gate extraction on four
surfaces inside the change that must prove the rest unchanged. It would also contradict the #539
invariant that the block-reason text is unchanged, which three suites assert (`Should -Match
'route metadata'` / `'lifecycle readiness'`, claude suite lines 177–178).

Instead, satisfy the epic's "distinct, greppable reason code" NFR with **`Write-Debug` diagnostic
tokens emitted from the new predicate**, which are greppable in a verbose hook run and in any
transcript, cost nothing at normal verbosity, and change no decision. `Write-Debug` is already used
in this hook set for exactly this purpose (`-modes.ps1` line 94, `Write-Debug "Property probe
failed for '$Name': …"`), so the idiom is precedented and does not breach the purity contract
(it is neither disk, process, network, nor environment access).

| Proposed code | Emitted when | Maps to LACS condition |
| --- | --- | --- |
| `PREIMPL_SELECTOR_UNMODELLED_OPTION` | a token between `git` and the subcommand that is not exactly `-C` (including `--git-dir`, `--work-tree`, `-c`, `--exec-path`, `-P`, an attached `-C<dir>`, or an env-style prefix) | L1 |
| `PREIMPL_SELECTOR_REPEATED` | more than one `-C` in the segment | L2 |
| `PREIMPL_SELECTOR_MALFORMED` | `-C` present with no value token, or the subcommand does not immediately follow the value, or the value is empty | L3, L8 |
| `PREIMPL_SELECTOR_NOT_ROOTED` | the value is relative, or is a UNC spelling | L4 |
| `PREIMPL_SELECTOR_TRAVERSAL` | the value carries a `..` or `.` segment | L5 |
| `PREIMPL_SELECTOR_NOT_LITERAL` | the value carries a wildcard or a stray colon | L6, L7 |

Each token is a distinct literal, greppable, and stable. The plan should pin each one with a Pester
case that asserts the *decision* (deny) rather than the debug text, so the tokens remain diagnostic
rather than contractual.

---

## Fail-Before Evidence

```
Timestamp: 2026-09-13T21-15
Command: (see ExecutionGap below — no shell tool was available in this research session)
EXIT_CODE: n/a
ExecutionStatus: NOT EXECUTED — deterministic hand-trace only
```

**ExecutionGap.** This research session was provisioned with `Read`, `Grep`, `Glob`, `WebFetch`,
`Write`, and `Edit` only. No PowerShell session could be started, so
`Test-ExemptOrchestrationStagingCommand` could not be invoked. The table below is a hand-trace
against the cited lines of
`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and must be re-derived by
execution before it is cited as fail-before evidence for any acceptance criterion.

| # | Command string passed to `-CommandText` | Expected (hand-traced) | Terminating line |
| --- | --- | --- | --- |
| 1 | `git add -- docs/features/active/x/spec.md` | `True` | L293 |
| 2 | `git -C C:/some/worktree add -- docs/features/active/x/spec.md` | `False` | L235 |
| 3 | `git -C C:/some/worktree commit -m "msg" -- docs/features/active/x/spec.md` | `False` | L235 |
| 4 | `git add -A -- docs/features/active/x/spec.md` | `False` | L258 |
| 5 | `git add -- src/foo.ts` | `False` | L203 → L290 |
| 6 | `cd C:/some/worktree && git add -- docs/features/active/x/spec.md` | `False` | L231 |
| 7 | `git add -- docs/features/active/x/spec.md \| tee out.txt` | `False` | L231 |
| 8 | `git add -- "docs/features/active/x/spec.md` | `False` | L334 |

Rows 2 and 3 are the fail-before rows the plan must cite: after the fix they must return `True`.
Rows 1 and 4–8 must return the same value before and after.

**The exact invocation that converts this into an executed artifact** (one PowerShell session,
read-only, no residue, no temporary file):

```powershell
# Run from the worktree root.
. .\.claude\hooks\enforce-orchestration-preimplementation-gate-helpers.ps1
@(
  'git add -- docs/features/active/x/spec.md'
  'git -C C:/some/worktree add -- docs/features/active/x/spec.md'
  'git -C C:/some/worktree commit -m "msg" -- docs/features/active/x/spec.md'
  'git add -A -- docs/features/active/x/spec.md'
  'git add -- src/foo.ts'
  'cd C:/some/worktree && git add -- docs/features/active/x/spec.md'
  'git add -- docs/features/active/x/spec.md | tee out.txt'
  'git add -- "docs/features/active/x/spec.md'
) | ForEach-Object {
  [pscustomobject]@{
    Command = $_
    Result  = Test-ExemptOrchestrationStagingCommand -CommandText $_
  }
} | Format-Table -AutoSize
```

The helpers file has no entry-point body (it declares constants and functions only), so
dot-sourcing it executes nothing and leaves no residue.

---

## Numeric Derivation Evidence

### N1 — Number of call sites of `Test-ExemptOrchestrationStagingCommand` in production code

- **Complete Family:** every textual invocation of the predicate `Test-ExemptOrchestrationStagingCommand` in any `.ps1` file under a hook directory on any of the four surfaces. The predicate has exactly one parameter set and one spelling (`-CommandText`), so the family has no overloads.
- **Exhaustive Search Scope:** the entire worktree `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae81045c17a23cd1f`, unfiltered by directory or extension, in both searches.
- **Inclusion Rules:** a line in a `.ps1` file that calls the predicate. Both the declaration site and the `.SYNOPSIS` mention are excluded as non-calls.
- **Exclusion Rules:** Markdown under `docs/**` (feature documentation and evidence artifacts quoting the line); the declaration at `-helpers.ps1` line 296; the `.SYNOPSIS` mention at `-helpers.ps1` line 6.
- **Primary Search Strategy or Query Expression:** `Grep` for the literal function name `Test-ExemptOrchestrationStagingCommand`, whole worktree, `output_mode: content`.
- **Primary Member Set:** `{ .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:151, .codex/hooks/enforce-orchestration-preimplementation-gate.ps1:170, extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:151, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:170 }`
- **Primary Count:** 4
- **Cross-check Search Strategy or Query Expression:** `Grep` for the structurally distinct guard expression `index -eq 0 -and` — a different token sequence that does not contain the function name — whole worktree, `output_mode: content`. This returns two hits per gate file (the trigger guard and the exemption guard); the exemption guard is the one whose line also contains the call.
- **Cross-check Member Set:** `{ .claude/hooks/…gate.ps1:151, .codex/hooks/…gate.ps1:170, extensions/…/claude-customizations/.claude/hooks/…gate.ps1:151, extensions/…/codex-and-agents-customizations/.codex/hooks/…gate.ps1:170 }` (the sibling hits at 143/161 are the trigger guard and carry no call; two Markdown hits in the #545 evidence artifact are excluded by rule).
- **Cross-check Count:** 4
- **Member-set Comparison:** the normalized primary and cross-check member sets are **identical** — same four files, same four line numbers. **Asserted count: 4.**

### N2 — Number of surface copies of the three-file hook set

- **Complete Family:** every copy, on every surface in this repository, of each of the three files `enforce-orchestration-preimplementation-gate.ps1`, `enforce-orchestration-preimplementation-gate-helpers.ps1`, and `enforce-orchestration-preimplementation-gate-modes.ps1`. The family covers all three members, not one.
- **Exhaustive Search Scope:** the entire worktree, both searches, with no directory restriction.
- **Inclusion Rules:** production `.ps1` copies of the three named files.
- **Exclusion Rules:** test files (`tests/**/*.Tests.ps1`), which share the filename stem but are not copies of the hook set; documentation.
- **Primary Search Strategy or Query Expression:** filename-based — `Glob '**/enforce-orchestration-preimplementation-gate*'`, whole worktree, then partition the 22 results into production copies and `.Tests.ps1` suites.
- **Primary Member Set:** 12 production files = `{.claude/hooks, .codex/hooks, extensions/…/claude-customizations/.claude/hooks, extensions/…/codex-and-agents-customizations/.codex/hooks}` × `{gate, gate-helpers, gate-modes}`. The remaining 10 results are `.Tests.ps1` suites.
- **Primary Count:** 12 production files across 4 surfaces (4 × 3).
- **Cross-check Search Strategy or Query Expression:** content-based and per-member, not filename-based — three separate `Grep` runs over the whole worktree for each file's distinct `.SYNOPSIS` literal: `Pathspec classifier for the orchestration-bookkeeping staging exemption` (helpers), `Blocks implementation operations before orchestration readiness exists` (gate), `Mode dispatch and per-mode readiness predicates` (modes). This covers every member of the family independently and cannot be satisfied by a single pattern.
- **Cross-check Member Set:** helpers → 4 `.ps1` hits (one per surface, all at line 3; one Markdown hit in the #554 spec excluded by rule). modes → 4 `.ps1` hits (one per surface, all at line 3). gate → 4 `.ps1` hits (the `.SYNOPSIS` at line 3 on the Claude copies and line 4 on the Codex copies, the Codex file having a leading blank line). Union = the same 12 files.
- **Cross-check Count:** 12 production files across 4 surfaces.
- **Member-set Comparison:** the normalized primary and cross-check member sets are **identical** — the same twelve paths. **Asserted count: 4 surfaces, 12 production files.** This supersedes the "three surfaces / nine files" framing in the delegation brief and the "three-file hook set" framing at `spec.md` lines 79–83, which omit the Codex bundle surface.

---

## Open Questions

| # | Question | What would settle it |
| --- | --- | --- |
| Q1 | Does git accept the **attached** spelling `-C<dir>` (no space)? The manual documents only `-C <path>` and shows no attached form, and git's top-level option handler compares whole tokens, but this was not verified by execution. | Run `git -Cfoo status` in a shell and observe whether it reports `unknown option: -Cfoo`. **This does not block the design**: LACS denies the attached form either way, which is fail-closed regardless of git's behavior. It matters only for the accuracy of the R5 row. |
| Q2 | Byte-identity of the four `-helpers.ps1` copies was established by full-text comparison of rendered reads, not by `Get-FileHash`. Invisible divergence (BOM, trailing-newline, CRLF vs LF) would not be detected. | `Get-FileHash` on all four copies, or `git diff --no-index` between each pair. The Codex pair is already hash-asserted by `legacy-codex-hook-contracts.Tests.ps1` line 111, so only the Claude pair's encoding parity is genuinely unverified here — and that pair is text-asserted by `test_push_down_claude_resource_contracts.py` line 140, which decodes as UTF-8 and would not catch a BOM difference. |
| Q3 | The R10 results are a hand-trace, not an executed run. | The PowerShell block in `## Fail-Before Evidence`, run from the worktree root, with the output captured into `<FEATURE>/evidence/regression-testing/`. |
| Q4 | Should `git -C` also be permitted on a **chained** all-exempt line (e.g. `git -C <wt> add … && git -C <wt> commit -m … -- …`)? The all-segments rule (helpers L342–347) already permits chaining when every segment independently qualifies, so LACS admits this automatically. Whether that is desired, or whether the selector should be restricted to unchained segments, is a spec decision. | A user/spec ruling. The brief's phrasing "single segment" suggests restricting it; the existing all-segments rule and the existing allow case at claude suite L136–146 suggest not. Recommend: **allow**, because forbidding it would make the selector rule inconsistent with the rest of the table for no safety gain — but flag it for explicit confirmation. |
| Q5 | Should the nested-subdirectory escape (R3) be recorded as an accepted widening in the helpers file's comments, mirroring the gate file's lines 101–110 precedent, or should the feature file a follow-up issue for a future F1-based closure? | A spec decision. Recommend recording it as an accepted widening with the measured exposure (seven `.md` test fixtures), and noting that F1's resolution module composes upstream to close it later without a schema change — the same posture row 16 takes toward issue #516. |
| Q6 | `enforce-orchestration-preimplementation-gate-modes.ps1` is absent from `$script:SharedModuleNames` (`legacy-codex-hook-contracts.Tests.ps1` line 30), so on the Codex side it is outside the parse, 500-line, byte-identity, and pack-manifest assertions. Is closing that gap in F2 scope? | Recommend **no** — it is a pre-existing gap unrelated to the selector axis, and adding a name to line 30 consumes a test-file slot and expands the change beyond one axis. File it as a follow-up. |
| Q7 | `CoveragePercentTarget = 0` means the runsettings does not enforce the >= 85% line threshold. Where is the threshold actually gated for PowerShell — reviewer inspection of `artifacts/pester/powershell-coverage.xml`, or a CI step? | Inspect the CI workflow that consumes `artifacts/pester/powershell-coverage.xml`. Not blocking: Design A changes one existing, already-measured file, so the changed-lines coverage obligation is satisfied by the new Pester rows in the existing suites. |
