# Research: Mermaid Validation Technology for the Claude Runtime (Issue #491)

- Timestamp: 2026-08-19T08-39
- Researcher: task-researcher
- Feature: `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/`
- Question: How should a Claude-native, deterministic Mermaid syntax validator be implemented in this repository, and what defect classes can it actually detect?
- Mermaid documentation version consulted: **11.17.0** (mermaid.js.org, fetched 2026-08-19); npm registry `mermaid@11.17.0`, `@mermaid-js/parser@1.2.1` (fetched 2026-08-19).

## 1. Current State Analysis

Verified facts about this repository:

- **Hook surface.** `.claude/settings.json` registers ten PreToolUse hooks on the matcher `Write|Edit` (lines 132–174), each invoked as a separate `pwsh -NoProfile -File` process. Path scoping is done inside each hook, not in the matcher. The established hook shape (verified in `.claude/hooks/enforce-evidence-locations.ps1`) is: read `$env:CLAUDE_TOOL_INPUT` JSON, emit a `hookSpecificOutput.permissionDecision` of `allow`/`deny`, dot-source guard for Pester, thin `exit` wiring. All 34 existing hooks are PowerShell; enforcement hooks in another language are prohibited (issue.md constraint; prior repo decision).
- **Library surface.** `.claude/lib/` already hosts testable PowerShell module families (`blast-radius/*.psm1`, `orchestrator-state/*.psm1`, etc.), so `.claude/lib/mermaid/` follows an existing pattern.
- **Node toolchain.** Root `package.json` has one runtime dependency (`@modelcontextprotocol/sdk`); `mermaid` is not a dependency anywhere. `run-node-tool.cjs` resolves tools from `<repo>/node_modules` and `extensions/drm-copilot/node_modules` and fails when the module is absent — it does not install anything. A fresh worktree (the parallel surface creates them routinely) has no `node_modules` until `npm install` runs, so any Node-based gate would be unavailable exactly when the parallel surface is most active.
- **Existing Mermaid emitters.**
  - `scripts/dev_tools/codex_native_converter/_reporting_topology.py` and the TypeScript port `extensions/drm-copilot/src/lib/codex-native-converter/reporting-topology.ts` emit fenced ` ```mermaid ` / `graph LR` blocks with quoted node labels and `-->` edges. Sampled output (`virtual/debug-artifacts/conversion-report.md` lines 17–40) is structurally valid flowchart syntax. One latent defect verified in both implementations: `mermaid_label`/`mermaidLabel` JSON-escapes labels, so a label containing `"` would emit `\"`, which Mermaid does not treat as an escape (the documented mechanism is the `#quot;` entity). File-path labels containing `"` are improbable, so this is a low-severity latent defect, in scope for the follow-up retrofit only.
  - The `render_subagent_tree` MCP tool does **not** emit Mermaid. Verified: `repo-automation-service-subagent-tree.ts` calls `formatTree`, and `lib/subagent-tree/tree-formatter.ts` renders plain indented text lines; a case-insensitive grep for `mermaid|flowchart|graph` across `src/lib/subagent-tree/` returns nothing. The issue.md statement that this tool emits Mermaid is incorrect and should be corrected during planning.
- **Existing Mermaid content.** No `.mmd` or `.mermaid` file exists in the repository. Fenced ` ```mermaid ` blocks exist only in the four `virtual/*/conversion-report.md` debug artifacts (12 blocks total).

## 2. Candidate Approaches

### a. Dependency-free structural validator (PowerShell, `.claude/lib/mermaid/`)

**Detectable defect classes** (deterministically, without a grammar):

1. Missing, misspelled, or unknown first-line diagram-type keyword (after skipping frontmatter, `%%{...}%%` directives, `%%` comments, and blank lines).
2. Unbalanced `[]`, `()`, `{}` on structural lines, computed with a quote-aware scanner, for diagram types where brackets are structural (flowchart, class, ER, state, requirement, block).
3. Unterminated double-quoted strings (odd quote count outside comments) and unterminated `%%{ ... }%%` directives.
4. Arrow/edge tokens invalid for the declared diagram type, on lines classified as edge statements (flowchart, sequence, class, ER, state).
5. Malformed YAML frontmatter: an opening `---` with no closing `---`, or a frontmatter body that is not `key: value` shaped.
6. Managed-diagram marker: frontmatter `id:` present (the Mermaid Chart sync marker documented in `.github/instructions/mermaid.instructions.md` lines 44–49) — the hand-edit block required by the issue.
7. `subgraph`/`end` pairing imbalance in flowcharts (count-based).
8. Empty or whitespace-only diagram body after the keyword line.

**Cannot catch:** semantic and deep-grammar errors — undefined node references in `click`/`style`/`linkStyle` statements, invalid statement grammar inside a known diagram type (e.g., a gantt task line with a malformed date, an invalid `classDef` property, wrong `section` structure in journey/gantt, invalid participant references in sequence diagrams), invalid config keys in frontmatter/directives, and any error whose detection requires the real parser's tokenizer (e.g., flowchart node-shape grammar like `A(((text)))` vs `A((text))` edge cases). It also cannot prove renderability. The gate is therefore weaker than the extension's validator: it rejects the defect classes the Copilot instruction file names (first-line keyword, arrows, bracket balance — `.github/instructions/mermaid.instructions.md` line 13) plus the classes above, and nothing more.

**Costs:** zero dependencies; one additional `pwsh -NoProfile` process per Write/Edit, identical to the ten already registered; pure string logic fully testable under Pester with here-string fixtures (no temp files); always available in every worktree.

### b. Real parse via `mermaid.parse()` (npm `mermaid`)

Verified facts:

- `mermaid.parse(text, { suppressErrors })` exists and validates without rendering (mermaid.js.org usage docs). The usage documentation contains **no** supported path for Node.js/DOM-less execution; all documented usage is browser-based.
- The ecosystem package `mermaid-isomorphic` exists specifically because mermaid cannot run in plain Node: outside a browser it launches **Playwright + Chromium** to host mermaid (README, verified 2026-08-19). This is the strongest available evidence that plain-Node `mermaid.parse()` is not a supported configuration; community workarounds use jsdom shims and break across versions.
- Parser split (verified against `packages/parser/src/language/` in the mermaid repo, develop branch): the Langium-based `@mermaid-js/parser` covers only `architecture`, `cynefin`, `eventmodeling`, `gitGraph`, `info`, `packet`, `pie`, `radar`, `railroad*`, `treeView`, `treemap`, `wardley`. Every principal diagram type — **flowchart, sequence, class, state, ER, gantt, journey, C4, mindmap, timeline, requirement, quadrant, sankey, xychart, block, kanban** — still uses jison parsers embedded in the main `mermaid` package, whose parse path runs DOMPurify-based sanitization and other DOM-touching code.
- Weight: `mermaid@11.17.0` is 83.9 MB unpacked with 24 direct dependencies (d3, cytoscape, katex, dompurify, marked, roughjs, ...). `@mermaid-js/parser@1.2.1` is 12.3 MB with one dependency, but covers none of the diagram types this repository actually emits (flowchart).
- `run-node-tool.cjs` compatibility: resolution would work when `node_modules` exists, but the gate would hard-fail in any worktree where `npm install` has not run — precisely the fresh-worktree case. `.claude/rules/general-code-change.md` restricts new dependencies; an 84 MB browser-oriented package to back a hook is not justifiable under that policy.

### c. `@mermaid-js/mermaid-cli` (`mmdc`)

Requires Puppeteer and a Chromium download (verified against the mermaid-cli README); no documented validate-only mode — validation happens as a side effect of rendering, which means launching Chromium per invocation. Startup latency is seconds, not milliseconds, and the Chromium binary is a per-machine install. Categorically unfit for a per-Write/Edit hook. It is viable as an optional **CI-side** deep check (GitHub runners ship Chrome), which is the correct home for it if deeper validation is ever wanted.

### d. Hybrid (structural always, deep parse when present)

The hybrid's premise fails: there is no deep-parse engine that is cheap when present. Option (b) needs a browser; option (c) needs Chromium; `@mermaid-js/parser` alone covers none of the principal types. The hybrid therefore adds a second code path, a capability-detection branch, and a two-tier result semantics ("passed structural" vs "passed deep") while the deep tier would almost never run and could disagree with the structural tier. The added complexity buys nothing today. The extensible alternative that costs nothing now: design the validator module's public function to return a structured result object, so a future CI-side deep check can be layered without changing the hook contract.

### Rejected alternatives (summary)

- **(b) `mermaid.parse()`**: not callable from plain Node without a browser (mermaid-isomorphic exists to bridge exactly this gap via Playwright); 84 MB / 24-dependency footprint; unavailable in fresh worktrees; violates the dependency policy's justification bar.
- **(c) `mmdc`**: Chromium-backed, seconds-level latency, no validate-only mode; wrong tool for a PreToolUse gate; acceptable only as a future CI follow-up.
- **(d) Hybrid**: no viable deep engine to hybridize with; complexity unjustified. Superseded by a structured-result seam in the module API.

## 3. Mermaid Grammar Facts (reference table, Mermaid 11.17.0 docs)

Frontmatter and directive rules are global (syntax-reference page, verified): a YAML frontmatter block delimited by `---` lines may precede the diagram keyword; meaningful keys include `title`, `config` (nesting `theme`, `layout`, `look`, and per-diagram config), `displayMode`; the Mermaid Chart extension additionally writes `id:` (the sync marker — `.github/instructions/mermaid.instructions.md` lines 44–49). `%%{init: {...}}%%` directives may also precede (and follow) the keyword. `%%` begins a line comment for all diagram types.

| Diagram type | Valid first-line keyword form(s) | Edge/arrow token set (structural subset) |
|---|---|---|
| Flowchart | `flowchart` or `graph`, optionally followed by direction `TB`\|`TD`\|`BT`\|`LR`\|`RL` (direction optional, default TB); `flowchart-elk` variant exists | `-->`, `---`, `-.->`, `-.-`, `==>`, `===`, `~~~`, `--o`, `--x`, `o--o`, `x--x`, `<-->`; length variants add repeated `-`/`.`/`=`; text forms `-- text -->`, `-->|text|`, `-. text .->`, `== text ==>` |
| Sequence | `sequenceDiagram` | `->`, `-->`, `->>`, `-->>`, `<<->>`, `<<-->>`, `-x`, `--x`, `-)`, `--)`; half-arrow variants added v11.12.3+ (`-\`, `-/` families). Arrow scanning must stop at the first `:` (message text is free text) |
| Class | `classDiagram` (`classDiagram-v2` accepted, legacy) | `<\|--`, `--\|>`, `*--`, `--*`, `o--`, `--o`, `-->`, `<--`, `--`, `..>`, `<..`, `..\|>`, `<\|..`, `..`; two-way composed as `[relTail][--\|..][relHead]`; optional quoted cardinalities `"1" -- "0..*"`; generics in `~T~` |
| State | `stateDiagram-v2` (preferred), `stateDiagram` (legacy) | `-->` only; `[*]` start/end pseudo-states; `state ... { }` composite blocks |
| ER | `erDiagram` | `<left><line><right>` where left ∈ `\|o`, `\|\|`, `}o`, `}\|`; right ∈ `o\|`, `\|\|`, `o{`, `\|{`; line ∈ `--` (identifying), `..` (non-identifying); word aliases (`one or zero`, `zero or more`, `only one`, `1+`, `0+`, `many(0)`, `many(1)`, `to`, `optionally to`); attribute blocks `ENTITY { type name PK "comment" }` |
| User journey | `journey` | none (section/task lines: `Task: score: Actor1, Actor2`) |
| Gantt | `gantt` | none (free-text task lines; date/duration grammar not structurally checkable) |
| Pie | `pie`, optionally `pie showData` | none |
| Quadrant | `quadrantChart` | none |
| Requirement | `requirementDiagram` | relationship arrows `->` / `<-` inside `element - arrow -> element` statements; `{ }` blocks |
| Git graph | `gitGraph`, optionally `gitGraph LR:` / `gitGraph TB:` / `gitGraph BT:` (trailing colon) | none (statement keywords: `commit`, `branch`, `checkout`, `merge`, `cherry-pick`) |
| Mindmap | `mindmap` | none (indentation-structured) |
| Timeline | `timeline` | none |
| ZenUML | `zenuml` | requires the external `@mermaid-js/mermaid-zenuml` plugin even in browser Mermaid; validator should keyword-accept and otherwise fail open |
| Sankey | `sankey-beta` | none (CSV-like body) |
| XY chart | `xychart-beta`, optionally `xychart-beta horizontal` | none |
| Block | `block-beta` | flowchart-style arrows between blocks; `space`, column declarations |
| Packet | `packet` (11.17 docs); `packet-beta` was the earlier keyword and remains accepted (inferred from version history; mark as unverified-alias in the allowlist) | none (`start-end: "name"` rows) |
| Kanban | `kanban` | none (indentation-structured) |
| Architecture | `architecture-beta` | `--` / `-->` style edges with port syntax `L`/`R`/`T`/`B` (e.g., `db:L -- R:server`) |
| Radar | `radar-beta` | none |
| Treemap | `treemap-beta` | none (indentation + `"label": value`) |
| C4 | `C4Context`, `C4Container`, `C4Component`, `C4Dynamic`, `C4Deployment` (capital `C4`; verified against c4.html) | `Rel(...)`, `BiRel(...)` call-style statements, not arrow tokens |
| Info | `info` | none |
| New in 11.x docs sidebar, keyword forms not individually verified | `swimlanes`, `eventmodeling`, `venn`, `ishikawa`, `wardley`, `cynefin`, `treeView`, railroad variants | treat as keyword-accept + fail open |

**Version-drift risk and mitigation.** The keyword allowlist hard-codes a snapshot of Mermaid 11.17.0. Mermaid adds diagram types several times per year (`radar-beta`, `treemap-beta`, and the 11.17 sidebar additions are all recent). Mitigations, in order of importance: (1) make the unknown-keyword outcome **fail open with a warning**, never a block — an out-of-date allowlist then costs a warning, not a false rejection (see §4); (2) record the pinned docs version and source URL in the module header so staleness is auditable; (3) keep the allowlist in one data structure in one module file so an update is a one-line-per-keyword diff; (4) note in the skill that `get-syntax-docs-mermaid`'s replacement (bundled reference + WebFetch fallback) is also the mechanism for confirming a new keyword before adding it.

## 4. False-Positive Risk Analysis

Constructs that naive validators reject wrongly, and the rule that avoids each:

| Construct | Required rule |
|---|---|
| Brackets in quoted labels: `A["foo[bar](baz)"]` | Bracket balance must be computed by a quote-aware scanner: characters inside a double-quoted span are excluded from balance counting. |
| HTML entities: `#quot;`, `#35;`, `&amp;` | No action needed for balance (they contain no structural chars), but the validator must not implement `\"` as a quote escape — Mermaid has none; `#quot;` is the mechanism. A quote counter that special-cases backslashes would be wrong. |
| Markdown strings: ``A["`**bold**`"]`` | Backtick spans live inside quoted spans; the quote-aware rule already covers them. Do not treat backticks as structural. |
| Unicode text | Scan by character; only ASCII structural characters (`[](){}"%`, arrow chars) participate in any rule. Never assume ASCII-only content. |
| `%%` comments | Strip `%%`-to-end-of-line **outside quoted spans only** (`A["50%% off"]` is content), and recognize `%%{...}%%` directives before comment stripping so directives are not deleted as comments. |
| `subgraph` blocks | `subgraph id [title]` ... `end`: count-match `subgraph`/`end`; `direction` statements inside are legal; do not arrow-check the `subgraph` header line (its title is free text). |
| `click`, `style`, `classDef`, `linkStyle`, `class`, `accTitle`, `accDescr`, `title` | Statement-keyword lines carry URLs, CSS, and free text. Classify by first token and exempt them from arrow and bracket rules entirely (quote-termination check may still apply). |
| Multi-line node text with `<br/>` | Never balance-check `<` `>`: HTML tags in labels are legal and arrows themselves contain `>`. Angle brackets are not structural for this validator. |
| Sequence message text | Everything after the first `:` on a message line is free text (may contain `-`, `>`, brackets). Apply arrow validation only to the pre-colon segment. |
| Free-text diagram types (gantt, journey, timeline, mindmap, pie, quadrant, kanban) | Bracket balance is not structural there (a gantt task named `Deploy (phase 1` is ugly but must not be blocked as unbalanced — the parser tolerates it). Restrict deep checks to the types in the table's arrow column; for free-text types check only the first-line keyword. |
| Escaped characters generally | Mermaid has no backslash-escape system; treat backslash as an ordinary character everywhere. |

**Fail-open policy (recommended, explicit).** The validator must decline to judge — allow, optionally with a warning in the decision reason — on:

1. First-line token not in the allowlist but shaped like a plausible keyword (letters/digits/hyphen). Blocks only a *missing* or clearly non-keyword first line (e.g., a line starting with an arrow or bracket), never an unknown name. This is the version-drift safety valve.
2. Diagram types outside the deep-checked set: keyword check only; no arrow or balance judgment.
3. Any single line the classifier cannot categorize: skip the line; never reject on "unclassifiable".
4. `Edit` tool calls where the fenced block or diagram is not fully reconstructable from the tool input (see §5): allow.
5. Malformed or absent `CLAUDE_TOOL_INPUT`: allow (issue.md test condition "malformed hook input fails open"). Planning note: this deliberately differs from `enforce-evidence-locations.ps1`, which exits 1 on malformed JSON; the difference should be recorded in the hook's comment so a reviewer does not "fix" it into a hard failure.
6. Content inside a `mermaid` fence that is itself nested inside another open fence (documentation showing example Mermaid, possibly deliberately invalid): not a diagram; allow.
7. ZenUML bodies (external-plugin grammar): keyword check only.

## 5. Detection Surface

- **`.mmd` / `.mermaid` files.** Whole file is one diagram (frontmatter + directives + body). Full validation applies. Zero such files exist today, so there is no migration burden and the negative-control fixture will be the first `.mmd` content in the repo (place fixtures under `tests/`, which coverage excludes, or as string literals inside Pester files to avoid the hook gating its own fixtures — string literals are the safer choice since a PreToolUse hook fires on fixture writes too; this interaction must be decided at planning time: either the hook exempts `tests/**` paths or fixtures live in here-strings).
- **Fenced ` ```mermaid ` blocks in Markdown.** In-scope for `Write` (full content available). For `Edit`, the hook receives only `old_string`/`new_string`; a complete fenced block fully contained in `new_string` can be validated, anything partial cannot — fail open per §4. Reconstructing post-edit file state by reading the target file inside the hook is possible but adds I/O and failure modes to a per-call gate; recommend against it in v1.
- **How much Markdown must be parsed.** Not a full CommonMark parser. A line-based fence tracker suffices: recognize opening fences of 3+ backticks or 3+ tildes, indented up to 3 spaces, optionally prefixed by blockquote markers (`> `), with an info string whose first word is `mermaid` (case-insensitive); a closing fence uses the same character, at least the same length, and the same blockquote nesting; maintain a fence stack so a `mermaid` fence inside an outer 4+-backtick fence is recognized as example text and skipped (§4 item 6); treat a 4-space-indented line outside any fence as an indented code block and skip fence recognition there only if trivially detectable — otherwise fail open. Tilde fences may contain backtick runs and vice versa. This tracker is ~5 rules, all unit-testable.
- **Existing emitters.** The converter topology renderers (Python + TS) currently produce valid flowchart Mermaid for their actual inputs (verified against emitted artifacts); the `\"`-escaping latent defect (§1) only manifests for labels containing a double quote. `render_subagent_tree` emits plain text, not Mermaid. **Retrofit is a follow-up, not in scope** — this matches issue.md's scope-containment constraint, and the research adds: the retrofit for the converter should replace JSON-escaping with `#quot;`-entity escaping in `mermaid_label`/`mermaidLabel`, and the issue.md claim about `render_subagent_tree` should be corrected rather than acted on.

## Automation Feasibility

Capabilities named in `.github/instructions/mermaid.instructions.md` that a Claude Code session cannot invoke, with the required disposition:

| Capability | Automatable from Claude Code? | Disposition |
|---|---|---|
| `mermaid-diagram-validator` LM tool | No (VS Code LM API) | `scope_change` — replaced by the in-repo structural validator + PreToolUse hook. The replacement is weaker than a real parse (§2a lists the uncatchable classes); record that delta in the skill so "validated" is not overclaimed. |
| `mermaid-diagram-preview` LM tool / `mermaidChart.preview` | No (webview in VS Code) | `scope_change` — the skill documents render paths that need no extension: GitHub renders ` ```mermaid ` fences natively in Markdown/PRs/issues; a human can open any `.mmd` in the extension or paste into mermaid.live. An enforced "always preview" rule is not portable; it becomes a documented option, not a gate. |
| `get-syntax-docs-mermaid` LM tool | Yes, by substitution | `scope_change` — bundled per-type syntax reference under the skill directory (pinned to 11.17.0) plus a documented WebFetch fallback to mermaid.js.org. |
| Diagram generation commands / `@mermaid-chart` slash commands (`generateDiagramFromCode`, ER, Docker, cloud, C4, ownership, dependency) | The UI commands: no. The capability: yes | `scope_change` — generation is a native LLM capability; the skill carries eight recipe sections matching the eight slash-command intents. |
| `mermaidChart.repairDiagram` / `improveDiagram` (Mermaid AI credits / Copilot LM) | No (cloud credits, extension UI) | `scope_change` — the validator's specific-defect error messages plus Claude's own editing replace "repair"; no credit-consuming path exists to warn about. |
| `mermaidChart.login` / `logout` / `connectDiagramToMermaidChart` | No (interactive OAuth to Mermaid Chart cloud) | `exception` — human runbook: connecting a diagram to Mermaid Chart is a human action in VS Code; the Claude surface only needs to *recognize* the result (the `id:` frontmatter). |
| `mermaidChart.syncDiagramWithMermaid` / Review Mermaid Sync (`reviewAppCommits`) / GitHub Sync app accept/reject UI | No (cloud service + extension UI) | `exception` — human runbook for the sync/review flow itself; the automatable half is the guard, which is in scope: the hook blocks hand-edits of any diagram whose frontmatter carries `id:`, which is exactly the "do not manually rewrite managed diagrams" rule made deterministic. |
| `mermaidChart.createMermaidFile`, `installAiSkills` | No | `scope_change` — creating a `.mmd` file is a plain `Write`; the install command is the Copilot-surface distribution mechanism and is irrelevant to the Claude surface (pack-manifest mirroring is the Claude distribution mechanism). |

No capability requires `halt`: every hard rule in the Copilot file either ports to a deterministic mechanism or degrades to a documented human step without blocking the feature.

## Requirements Mapping (design consequences)

- `.claude/lib/mermaid/` — one or more `.psm1` modules (500-line limit applies; expect a split like `MermaidValidation.psm1` for orchestration/keyword table, `MermaidLineScanner.psm1` for the quote/comment-aware scanner, `MermaidMarkdownFences.psm1` for the fence tracker). Public entry returns a structured result (verdict + findings + diagram type), preserving the seam a future CI deep check can consume.
- `.claude/hooks/enforce-mermaid-validation.ps1` — thin: parse tool input, scope by extension/content, call the module, emit allow/deny JSON. Deny reasons name the specific defect and line number (issue AC).
- Managed-diagram rule: deny an `Edit`/`Write` to an existing `.mmd`/`.mermaid` whose current frontmatter has `id:` unless the write preserves it untouched — planning must define "hand-edit" precisely; the simplest deterministic rule is: block any Edit to a file whose on-disk frontmatter contains `id:`, with the deny message pointing at the sync workflow.
- Mirroring: repo `.claude` files + `extensions/drm-copilot/resources/claude-customizations/.claude/` copies + `pack-manifests/core.json` entries move together (hard gate: `claude-pack-manifest-completeness.test.ts`).
- Latency: the structural validator is a single in-process string pass; the dominant cost is pwsh startup, already paid ten times per Write/Edit. The eleventh hook matches the existing per-hook budget. Early-exit ordering matters: the extension/content scope check must run before any content scan so non-Mermaid writes pay only the JSON parse.

## Testing Implications

- Pester tests under `tests/.claude/lib/mermaid/` and `tests/.claude/hooks/` (mirroring the production tree, `*.Tests.ps1`), >= 85% line coverage, no temp files: all diagram content supplied as here-strings, filesystem and `CLAUDE_TOOL_INPUT` injected via parameters per the repo's seam rules.
- Matrix per issue.md: valid diagram per deep-checked type; keyword misspellings; each unbalanced bracket class; each invalid-arrow-per-type case; CRLF/LF; frontmatter with `title`/`config`/`id`; every fail-open input in §4 asserted to allow; the fence tracker's five rules (nested, indented, tilde, blockquote, unclosed).
- Negative control: one deliberately invalid fixture proven rejected (gate shown capable of failing), stored as a here-string, not a file, to avoid the hook gating its own fixtures.

## Recommendation

**Implement the dependency-free structural validator as PowerShell modules under `.claude/lib/mermaid/`, invoked by a thin PreToolUse hook, with an explicit fail-open policy and a structured-result API seam. Do not add the `mermaid` npm package, `@mermaid-js/parser`, or `mermaid-cli`. Record CI-side deep validation via `mmdc` as an optional follow-up, out of scope.**

The three facts that decide it:

1. **No real Mermaid parse is available without a browser.** `mermaid.parse()` has no documented Node/DOM-less mode; the ecosystem's bridge package (`mermaid-isomorphic`) exists precisely to launch Playwright + Chromium for Node use; and the DOM-free `@mermaid-js/parser` covers only the Langium types (gitGraph, pie, packet, architecture, radar, treemap, ...) — none of the principal types this repository writes, above all flowchart. Every "real parse" option is therefore a browser process in disguise.
2. **The gate must be available in every worktree and cheap on every Write/Edit.** `mermaid` is not a dependency, fresh worktrees have no `node_modules`, and `run-node-tool.cjs` fails rather than installs. A Node-backed gate would be absent exactly where the parallel surface operates. The PowerShell module costs one more `pwsh -NoProfile` process alongside the ten hooks already registered on `Write|Edit`, and it can never be "not installed".
3. **The dependency policy bars the alternative on its own terms.** `mermaid@11.17.0` is 83.9 MB unpacked with 24 dependencies (d3, cytoscape, katex, dompurify, ...); `mmdc` adds Chromium. Neither is justifiable under `.claude/rules/general-code-change.md` for a validator whose enforceable target — the defect classes the Copilot instruction file itself names (first-line keyword, arrow forms, bracket balance) — is fully covered by the structural approach.

The accepted cost is a validator weaker than the extension's (§2a "cannot catch" list), mitigated by the fail-open policy (never blocks what it cannot judge), the pinned-version keyword table with warn-not-block drift behavior, and the structured-result seam that leaves room for a CI-side `mmdc` deep check later.
