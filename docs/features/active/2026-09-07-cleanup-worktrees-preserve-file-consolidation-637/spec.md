# cleanup-worktrees-preserve-file-consolidation (Spec)

- **Issue:** #637
- **Parent:** epic `cleanup-merged-worktrees-hardening` (child F; gap 5)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-07
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** `full-bug` — this document is the authoritative acceptance-criteria source.

## Document Conventions

- **Claim strength is stated per claim.** Three strengths are used and are not interchangeable:
  - *Verified by execution on 2026-09-07* — the delegating agent ran the command and observed the
    result. Six such facts are recorded in "Verified facts" below.
  - *Verified by reading* — established by the research artifact
    `research/2026-09-07-preserve-file-consolidation-research.md` (sections R0–R17) or by this
    document's own reading of the cited file. The research agent had no Bash tool (R0.1), so no
    finding it recorded is an execution result.
  - *Not verified* — neither established. Stated as such rather than upgraded.
- **Line numbers are navigational aids, not identifiers.** Sibling children #630, #631, #632 and
  #635 fan into `epic/cleanup-merged-worktrees-hardening-integration` ahead of or alongside this
  child and move line numbers in `SKILL.md`, `cleanup_worktrees_lib.sh`, and
  `cleanup-worktrees.sh`. File names, function names, constant names, record-type discriminators,
  and result tokens are the stable identifiers. Every `path:line` citation must be re-derived at
  execution time.
- **Sibling issue numbers.** Issue #635 and `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`
  refer to this child as "#904". That is a stale placeholder. This document uses the real numbers
  throughout: B = #631, C = #632, D = #635, F = #637. See "Documentation corrections".
- **No acceptance criterion in this document asserts a count, an enumeration size, or a
  population.** The research withheld every such assertion with a stated reason (R15.1: children
  #631 and #632 add report record types before this child executes, so "there are N record types"
  is false at execution time; R15.2: two of six line counts rest on a single derivation).
  Cap conformance is therefore written as a per-file predicate, following R15.2's recommendation
  and #635's AC-27. Consequently no `## Numeric Derivation Evidence` record is required or cited
  for any criterion below.
- **Evidence location.** No non-canonical evidence path was supplied by the delegation, so no
  override was rejected. All evidence artifacts produced under this specification go to
  `docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/evidence/<kind>/`
  per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

## Context

The `cleanup-merged-worktrees` consolidation step can only carry committed residual content.
Report mode emits `COMMIT|<branch>|<sha>|UNIQUE|...` records for committed residuals and emits
nothing for untracked or modified working-tree files. During the 2026-09-06 run approximately 140
never-committed `.claude/agent-memory/**` lesson files and feature-folder drafts sat untracked or
modified across 20 worktrees and were invisible to the script. The consolidation was performed by
hand: copy the files into a manually created `documentationandmemories` worktree, append each
file's `MEMORY.md` index line taken from the source worktree, normalize line endings, sanitize
account and host tokens, commit, push.

Environment:

- OS/version: Windows 11 Pro 10.0.26200, with the bash toolchain under WSL Ubuntu.
- Python version: not applicable. The affected surface is native bash under `scripts/bash/`.
- Command/flags used: `bash scripts/bash/cleanup-worktrees.sh` (report mode), then an attempted
  `--consolidate` pass. See the correction below.
- Data source or fixture: 20 live agent worktrees under `.claude/worktrees/`.

Impact / Severity:

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The manual substitute is error-prone in three specific ways, each observed in the 2026-09-06 run: a
dropped `MEMORY.md` index line leaves a lesson file unreachable from the index; an LF line appended
to a CRLF index file produces mixed endings; and an unsanitized account or host token reaches a
pushed commit.

### Correction that supersedes part of the original defect report

The run observations state that the consolidation step "had nothing to do". That is not what
happened. **The consolidation step was never reachable.** `issue.md` carries this correction under
`## Actual Behavior` and it is restated here because the previous draft of this specification
carried the uncorrected repro step 3 ("Run the consolidation step (`--consolidate`), which
cherry-picks the reported commits") and the uncorrected Actual paragraph. Both are replaced by this
document.

## Repro & Evidence

Steps to Reproduce:

1. Run `bash scripts/bash/cleanup-worktrees.sh` in report mode across a set of worktrees whose only
   unique content is never-committed: untracked `.claude/agent-memory/**` lesson files and modified
   feature-folder drafts.
2. Observe that report mode emits `COMMIT|` records only for committed residuals and emits nothing
   for untracked or modified working-tree files.
3. Attempt the consolidation step. `bash scripts/bash/cleanup-worktrees.sh --consolidate` falls to
   the wrapper's `*)` arm, prints usage to stderr, and returns 2. There is no consolidation
   command.

Expected: the consolidation step stages the untracked and modified files that the editorial pass
marked `PRESERVE`, carrying each new lesson file's `MEMORY.md` index line, normalizing line endings
to the target file's existing convention, and refusing to commit any file still carrying account or
host tokens. Each such file is reported as a `PRESERVE|` record.

Actual: no preserve-staging path exists anywhere in `scripts/bash/`.

### Verified facts (verified by execution on 2026-09-07)

These six facts were re-verified by running commands. They take precedence over any reading-derived
statement that disagrees with them.

| # | Fact |
| --- | --- |
| F1 | `scripts/bash/cleanup-worktrees.sh` `main` dispatches only `"" \| report`, `--apply \| apply`, `--help \| -h \| help`, and `*)` → `usage >&2; return 2`. `main` reads only `${1:-}`; there is no `shift`, no `$2`, and no option loop, so a manifest path cannot arrive as a second CLI argument. **`--consolidate` does not exist.** |
| F2 | Three of the four consolidation functions are dead code. `create_consolidation_worktree` (`cleanup_worktrees_actions_lib.sh`:70), `cherry_pick_candidates` (:103), and `cleanup_consolidation_on_abort` (:165) have no production call site; only `tests/shell/test_cleanup_worktrees_consolidation.bats` and `tests/shell/test_cleanup_worktrees_hard_failures.bats` invoke them. Only `verify_consolidation_merged` (:198) is reached from production, at `run_apply`:354. `select_cherry_pick_candidates` is a different function, in `cleanup_worktrees_lib.sh`:254, called from `run_report` at :437. |
| F3 | `.gitattributes` is one line: `* text=auto eol=lf`. `git ls-files --eol` reports `i/lf  w/lf  attr/text=auto eol=lf` for tracked files. A CRLF ending is unreachable for any tracked path in this repository. The defect report's "normalize the index files to CRLF" therefore describes a destination outside the tracked tree. |
| F4 | `.gitignore:67` is `.claude/agent-memory`, anchored to the repository root. `git check-ignore -v` confirms the root `.claude/agent-memory/**` tree is ignored and confirms that `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/**` is NOT ignored. That mirror carries 13 tracked files today. |
| F5 | The push-down mirror of the skill is byte-identical today. `cmp` on `.claude/skills/cleanup-merged-worktrees/SKILL.md` against `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` returns equal; both md5 to `a7a3d102d01028b239113d994b4247be`. |
| F6 | Line counts: `cleanup_worktrees_lib.sh` 479, `cleanup_worktrees_actions_lib.sh` 382, `cleanup-worktrees.sh` 92, `SKILL.md` 264, `tests/fixtures/cleanup_worktrees/stub-bin/git` 208. |

## Root Cause Analysis

1. **No preserve-staging code path exists.** `cherry_pick_candidates` consumes only `COMMIT|`
   records from stdin (`[[ $line == COMMIT\|* ]] || continue`) and emits only `COMMIT|` and
   `ACTION|cherry-pick*` results. There is no untracked/modified staging path anywhere in
   `scripts/bash/`. Verified by reading (R1.3).
2. **No machine-readable record carries the editorial finding to the script.**
   `.claude/skills/cleanup-merged-worktrees/SKILL.md` `## Report Line Contract` defines no
   `PRESERVE|` record type, although `PRESERVE` is already a disposition token in the skill text
   (`SKILL.md:141`, :201, :204, :211) and step 9 already routes `PRESERVE` findings through the
   consolidation flow. Verified by reading (R2.6).
3. **The consolidation driver itself does not exist end to end** (F2). This is a larger defect than
   gap 5 and subsumes it. See "Out of scope / non-goals" for the boundary this child draws around
   it.
4. **The named token pattern set does not exist.** `_shared_no_absolute_host_paths` has no
   implementation, test, fixture, configuration entry, hook, or schema anywhere in the repository;
   the only matches are prose documents asking for it to exist. There is no redaction or
   sanitization precedent in `scripts/` at all. Verified by reading (R3, R4.1). Issue #635 assigns
   ownership of the pattern set and its identifier to this child.
5. **The advisory line-ending field is trusted by nobody yet.** Issue #635 defines
   `preserved_files[].line_ending` as **ADVISORY** and requires the consumer to re-derive and
   compare rather than trust it, because a stale value "would drive exactly the mixed-ending defect
   gap 5 exists to fix".

## Scope

1. A new bash library `scripts/bash/cleanup_worktrees_preserve_lib.sh` implementing preserve
   staging: manifest consumption, fail-closed record validation, the host-token content scan,
   line-ending re-derivation, `MEMORY.md` index-line rendering, and the staging driver (D1, D3–D8).
2. A new narrow dispatch arm on `scripts/bash/cleanup-worktrees.sh` (`preserve | --preserve`) and a
   new environment seam `CLEANUP_WT_MANIFEST_PATH` (D2).
3. The host-token pattern set `cleanup-wt-host-tokens-v1`, defined by this specification (D5).
4. One new bullet in the `## Report Line Contract` of
   `.claude/skills/cleanup-merged-worktrees/SKILL.md`, mirrored into the push-down bundle (D9).
5. Extension of the recording git stub `tests/fixtures/cleanup_worktrees/stub-bin/git` with `add`
   and `check-ignore` cases and their KEY documentation (D10).
6. A narrow `.gitattributes` exception scoped to one new fixture directory so a genuinely CRLF
   fixture can be checked in (D7).
7. A new bats suite plus checked-in fixture scenario directories under
   `tests/fixtures/cleanup_worktrees/preserve/`.

## Out of scope / non-goals

Each exclusion carries its reason. None is silent.

- **Wiring the missing consolidation driver.** `create_consolidation_worktree`,
  `cherry_pick_candidates`, and `cleanup_consolidation_on_abort` remain without a production call
  site after this child (F2). Reason: restoring the full consolidation driver requires deciding the
  worktree-creation policy and an abort contract for a partially completed cherry-pick sequence —
  `cleanup_consolidation_on_abort` undoes exactly a worktree registration and a branch ref and
  undoes no commit, staged change, or file copy (R1.4). That is a distinct defect of larger scope
  than gap 5. **Recommended follow-up: file a separate issue for the dead consolidation driver.**
  This specification does not open it; issue creation runs through
  `.claude/skills/feature-promotion-lifecycle/SKILL.md` and is the skill's action, not this
  document's.
- **Creating the consolidation worktree.** The `preserve` arm requires an existing consolidation
  worktree and fails closed when the resolved path is not a directory (D2). Reason: the same abort
  contract above. This child's all-or-nothing write phase (D6) means there is never partial work to
  undo, which is only true because it does not also create the worktree.
- **Committing and pushing.** This child stages; it does not commit. Reason: the commit is the
  operator's confirmed action in step 3–4 of the skill's End-to-End Workflow, and the host-token
  refusal is enforced at the staging boundary, which is strictly earlier (D5).
- **Any change to `scripts/bash/cleanup_worktrees_lib.sh`.** It is at 479 of the 500-line cap (F6)
  and three sibling children (#630, #631, #632) each add call sites to its `run_report`, serialized
  ahead of this child. Reason: `epic.md:206-209` states the separation constraint directly. This
  includes the duplicate record-type list in that file's header comment at :40-46, which this child
  deliberately leaves stale rather than create a fan-in conflict for one comment line (D9).
- **`git status` discovery of preserved files.** The consumer never enumerates dirty or ignored
  content; every file it touches is named by the manifest. Reason: enumeration is child #631's
  and #632's surface. A consequence is that R8.6b's blocking constraint — the stub's `status` KEY
  is flag-insensitive, so `status --porcelain` and `status --porcelain --ignored` collide on one
  fixture — is **not** blocking for this child and is left to the sibling that needs it.
- **`.claude/hooks/**`.** Children #545, #635 and #591 own those files. This child adds no hook and
  changes none.
- **Freshness validation of the manifest** (`generated_at`, `run_id`). Reason: freshness is the
  removal-gate hooks' authorization concern (#635, allow-predicate condition 3). A stale manifest
  reaching this consumer resolves to `MISSING-SOURCE` skips because the named files no longer
  exist, which is already reported and already non-zero.
- **Injecting `metadata.scope` frontmatter into a preserved memory file or a newly created
  index.** Reason: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:262-306`
  requires `metadata.scope: repo` on every bundled `MEMORY.md` and exactly `metadata.scope: general`
  on every other bundled memory file (R7.4). Synthesizing frontmatter would invent content the
  editorial pass did not author. The consumer instead reports index creation loudly (D8) so the
  operator supplies it before committing.
- **UNC paths (`\\host\share`) and bare hostnames in the pattern set.** Reason recorded in D5.
- **Patching consumer-repository copies.** All fixes land in `drm-copilot` and reach consumers
  through push-down.

## Design Decisions

### D1 — A new sibling library, not a change to an existing one

**Decision.** All new production code lands in `scripts/bash/cleanup_worktrees_preserve_lib.sh`,
sourced by `scripts/bash/cleanup-worktrees.sh` **after** the three existing libraries, using the
same three-line block the wrapper already uses for each (`# shellcheck source=...`,
`# shellcheck disable=SC1091`, `source "$SCRIPT_DIR/<file>"`).

**Justification.** `cleanup_worktrees_lib.sh` has 21 lines of headroom (F6) and is contended by
three serialized siblings. The new library depends on `cleanup_wt_git` (defined in
`cleanup_worktrees_enumerate_lib.sh`) and on `consolidation_worktree_path` (defined in
`cleanup_worktrees_actions_lib.sh`), so it must be sourced last. It honors the same sourcing
contract every sibling library states in its header: **it defines functions only and never runs
work at source time**, an observable property the CLI suite's source-guard test already asserts for
the existing files.

**Pre-authorized split.** If the library approaches the 500-line cap, the line-ending and index
group (`preserve_derive_line_ending`, `preserve_render_index_append`, `preserve_index_has_entry`)
moves to a second file `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` sourced immediately
before it. The executor is authorized to make that split without a spec amendment. The same
pre-authorization applies to the bats suite, which may split into
`tests/shell/test_cleanup_worktrees_preserve.bats` and
`tests/shell/test_cleanup_worktrees_preserve_eol.bats`.

### D2 — The manifest reaches the code through an environment seam, not through argument parsing

**Decision.** A new dispatch arm `preserve | --preserve` is added to `main` in
`scripts/bash/cleanup-worktrees.sh`. It takes **no operand**. The manifest path is supplied by a
new environment override `CLEANUP_WT_MANIFEST_PATH`, defaulting to
`artifacts/orchestration/cleanup-worktrees-manifest.json` (the path #635 owns). The consolidation
worktree path continues to resolve through the existing `CLEANUP_WT_CONSOLIDATION_PATH` override
and `consolidation_worktree_path()`.

**This is the explicit answer the requirements ask for: the design routes around the argument
limitation rather than addressing it.**

**Justification, in order of weight:**

1. Every existing override in this tool is an environment variable. `cleanup-worktrees.sh:47-54`
   documents exactly three — `CLEANUP_WT_GIT_BIN`, `CLEANUP_WT_STUB_SCENARIO`, and
   `CLEANUP_WT_CONSOLIDATION_PATH`. A fourth of the same shape is the smallest coherent increment
   and needs no new parsing machinery.
2. Adding a `shift` plus an option loop would change `main`'s argument contract, which every
   existing dispatch arm and the CLI suite depend on, in a file three other children may also touch.
   `shell-qc.sh:62-83` shows the in-repo precedent for a flag loop, so the option exists; it is
   rejected on blast radius, not on feasibility.
3. A test seam is required regardless. `artifacts/` is gitignored (`.gitignore:6`), so a bats
   fixture manifest cannot live at the production path and must be pointed at from
   `tests/fixtures/` (R9.3). An environment override supplies that seam and the production
   configuration with one mechanism.
4. `main` silently discards a second argument today (F1), so a CLI-operand design would be a
   defect-prone shape until the option loop lands.

**Fail-closed preconditions of the arm.** Before any record is read:

- The resolved consolidation worktree path must be an existing directory. Otherwise emit
  `ACTION|preserve-stage||MISSING-WORKTREE` to stdout, a diagnostic to stderr, and return 1. The
  arm never creates the worktree.
- The resolved manifest path must be an existing readable file. Otherwise emit
  `ACTION|preserve-manifest|<manifest-path>|MISSING` and return 1.

**Usage text.** The wrapper's `usage()` heredoc gains the new command, the new environment
override, and the new report record shape. That heredoc is a second copy of the record-type list
(R2.4); it is updated here because the change already touches that block and 408 lines of headroom
exist, and because no sibling child edits this file's usage text.

### D3 — JSON is read through `jq`, resolved by a seam, failing closed when absent

**Decision.** `preserved_files[]` is extracted with a single `jq` invocation. The binary is resolved
by `CLEANUP_WT_JQ_BIN` when that value is non-empty and executable, otherwise by `command -v jq`.
When neither resolves, the function writes a diagnostic to stderr and returns **127**, staging
nothing. This mirrors `cleanup_wt_git`'s resolution and 127 contract exactly
(`cleanup_worktrees_enumerate_lib.sh:45-56`).

**Justification.** A hand-rolled bash JSON parser is not viable under this repository's rules. The
prior in-repo assessment of exactly this question
(`docs/features/completed/2026-08-15-enforcement-hooks-must-not-invoke-python-475/research/2026-08-15T15-30-full-parity-check-inventory-and-bash-json-research.md`,
section 4.3) sizes a hand-rolled parser at 500–800 lines, which exceeds the 500-line cap on its own
before any validator logic, and records that its failure mode on unsupported constructs is silent.
`.claude/rules/general-code-change.md` permits an unavoidable dependency when it is well-maintained
and widely used and the reason is documented; `jq` qualifies and the reason is recorded here.
A Python leg is not available: the bash toolchain has no Python or Poetry dependency
(`.claude/rules/shell.md:12-13`).

**Dependency consequences, stated rather than assumed:**

- The same source records that GitHub-hosted `ubuntu-latest` preinstalls `jq` and that
  `.github/workflows/_shell-coverage.yml` installs shellcheck, bats, shfmt and kcov but not `jq`.
  **That preinstall is a property of an external runner image and is not verified by this
  specification.** No workflow change is made, and none is needed for the test suite, because every
  test drives a checked-in `jq` stub through `CLEANUP_WT_JQ_BIN` and no test invokes a real `jq`.
  CI risk is therefore confined to production use, which CI does not exercise.
- Local WSL Ubuntu does not install `jq` by default. The operator installs it once. The failure
  mode without it is a loud 127 with a diagnostic naming the tool, never a silent no-op.

**The extraction contract.** One `jq` invocation emits one record per `preserved_files[]` entry as
tab-separated columns (`@tsv`, which escapes embedded tabs and newlines), in this fixed column
order:

`worktree_path`, `source_path`, `change_class`, `disposition`, `verdict`, `target_path`,
`memory_index_line_present` (`true`/`false`, from `has("memory_index_line")`),
`memory_index_line_is_null` (`true`/`false`), `memory_index_line`, `line_ending`,
`host_token_scan_type` (the JSON type of `.host_token_scan`), `host_token_scan_result`,
`host_token_scan_pattern_set_id`, `evidence`.

The key-presence and null columns exist because #635 distinguishes "key absent ⇒ skip and report"
from "`null` is valid" for `memory_index_line`, and the type column exists because #635 requires a
refusal when `host_token_scan` is present but is not an object. Tab is the internal transport
delimiter precisely because `memory_index_line` may legitimately contain `|`. The exact filter text
is an implementation detail and is pinned by behavior tests, not by a literal-text assertion.

**Top-level validation.** Before any record is processed the consumer requires
`tool == "cleanup-merged-worktrees"` and `schema_version == 1`. Either failing emits
`ACTION|preserve-manifest|<manifest-path>|REJECTED` and returns 1 with nothing staged. A parse
failure is treated identically. This matches #635's fail-closed conventions and its statement that
the manifest is written by an LLM editorial pass, so every field must be validated at consumption.

### D4 — Fail-closed per-record validation, and deterministic ordering

**Decision.** Each record is validated against #635's `preserved_files[]` contract before anything
else happens to it. The consumer's obligations, taken verbatim from that contract:

| Field | Requirement | Consumer behavior on violation |
| --- | --- | --- |
| `worktree_path` | non-empty string | skip and report |
| `source_path` | non-empty, repo-relative (not absolute, no `..` segment) | skip and report |
| `change_class` | `untracked` or `modified` | skip and report |
| `disposition` | exactly `PRESERVE` | skip, silently permitted by #635; this consumer also reports |
| `verdict` | in `DEAD_ONE_OFF`, `ALREADY_SOLVED_ELSEWHERE`, `STALE_OR_CONTRADICTED`, `GENUINELY_NEW`, `STILL_RELEVANT` | skip and report |
| `target_path` | non-empty, repo-relative | skip and report; never guessed |
| `memory_index_line` | key present; string or `null` | key absent ⇒ skip and report; `null` is valid and means "no index line to carry" |
| `line_ending` | `crlf`, `lf`, or `absent` | **ADVISORY.** Never used to decide what is written (D7) |
| `host_token_scan` | object carrying `result` and `pattern_set_id` | absent, non-object, or missing either member ⇒ **refuse to stage** that record and report |
| `evidence` | non-empty string | skip and report |

`change_class` is validated for vocabulary but does not change the staging action: an `untracked`
and a `modified` record are both copied to `target_path` and staged. This is stated explicitly so no
implementation invents a divergent path for one of them.

**Ordering.** Records are processed in `LC_ALL=C` order of the pair (`worktree_path`,
`source_path`), not in manifest array order. `SKILL.md:59` makes `LC_ALL=C` ordering normative for
the report stream, and the manifest is authored by an LLM whose array order is not a contract.

### D5 — The host-token pattern set: `cleanup-wt-host-tokens-v1`

**This specification creates the pattern set. It reuses nothing.** `_shared_no_absolute_host_paths`
is named in the run observations but has no implementation, test, fixture, configuration entry,
hook, or schema anywhere in this repository, and no redaction or sanitization precedent exists in
`scripts/` at all (R3, R4.1). Issue #635 explicitly assigns ownership here: "This child defines the
field contract only; child F owns the pattern set and its identifier."

**Identifier.** `cleanup-wt-host-tokens-v1`. It is the value this child's implementation carries as
its own pattern-set identity and is the value the skill's editorial pass should write into
`preserved_files[].host_token_scan.pattern_set_id`. Issue #635's example JSON uses the placeholder
literal `child-f-host-tokens-v1`; that value was an example only ("#635 gives it only as an example
value in a JSON block", R9.2) and is superseded. See "Documentation corrections".

**Allowed values of `host_token_scan.result`** (undefined upstream, R9.2/O7): exactly `clean` and
`tokens_present`. A value outside that set is treated as a malformed `host_token_scan` and the
record is refused.

**Scan scope — stated precisely, because a naive scan is not viable.**

- **What is scanned:** the bytes of the file named by (`worktree_path`, `source_path`) — that is,
  the file being staged — and the bytes of the `memory_index_line` string that will be appended.
  Nothing else.
- **What is NOT scanned, and why:**
  - **The manifest itself.** #635's own `preserved_files[]` example encodes `worktree_path` as
    `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-0f1c2d`. The manifest that feeds
    this child therefore legitimately contains the very tokens the scan refuses in staged content.
  - **The existing content of the destination `MEMORY.md`, and any other file already on the
    consolidation branch.** Only the incoming bytes are this child's responsibility.
  - **The repository tree, the push-down bundle, or the staged set as a whole.** `C:/Users/` occurs
    1117 times across 468 tracked files and `C:\Users\` 283 times across 175, and
    `.claude/settings.json:75` is a tracked, runtime-read permission entry whose value is an
    absolute host path containing the account name — held text-equal to its bundle mirror by
    `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. A repository-wide refusal
    scan would flag a file that must contain that string (R4.3). The same scoping lesson is already
    recorded in that test at :396-407 for a different scan.
  - **Environment variables, command lines, and the consolidation worktree path.** Not content.
- **Consequence for fixtures.** The bats fixture that exercises the refusal path is a checked-in
  file containing a host token. Because the scan reads only the file a manifest record names, that
  fixture is inert repository content and needs no exemption. It lives under
  `tests/fixtures/cleanup_worktrees/preserve/host-token/`.

**The patterns.** Matching is POSIX ERE under `LC_ALL=C`, case-insensitive, treating input as text
(`grep -a`), evaluated one pattern at a time in ascending identifier order so the first match can be
named in the diagnostic.

| ID | What it matches | Normative ERE | Why it is in the set |
| --- | --- | --- | --- |
| HT1 | A Windows absolute user-profile path with an account segment, either separator form, any drive letter | `[A-Za-z]:[\\/]+users[\\/]+[^\\/[:space:]"']+` | The two largest observed families: `C:\Users\` 283 occurrences / 175 files and `C:/Users/` 1117 / 468 (R4.2). The account segment is the token that identifies the host operator. |
| HT2 | The WSL mount form of the same path | `/mnt/[a-z]/users/[^/[:space:]"']+` | `epic.md:295` documents the WSL invocation form; the family occurs 192 times across 53 files (R4.2). |
| HT3 | A POSIX home directory with an account segment | `/home/[a-z][a-z0-9._-]*` | Same family; a Linux or devcontainer author records the account name this way. |
| HT4 | A Windows 8.3 short-name path segment | `[\\/][a-z0-9]{1,6}~[0-9][\\/]` | The short form defeats HT1 when the shortened segment is not literally `Users` (for example the scratchpad path this run used). Both delimiters are required so that ordinary revision syntax such as `HEAD~1` is not matched. |
| HT5 | An email address | `[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}` | Git author identity and account email. One occurrence was found under `docs/features/active/` (R4.2). |
| HT6 | The literal Windows environment-variable spellings for account and host | `%(userprofile\|username\|computername\|homepath)%` | Recorded in R4.2 as a family the evidence suggests but that was not independently searched. It is included because it encodes the same account or host fact and is a trivially checkable literal with no false-positive surface in prose. |

**Deliberately excluded, with reasons (this answers research open question O8):**

- **UNC paths (`\\host\share`).** R4.2 records that the attempted search's UNC branch returned
  1552 occurrences across 655 files but also matched any doubled backslash inside an escaped JSON
  string, so that figure is not a UNC count and no independent UNC search was run. A `\\\\`-anchored
  pattern would match every escaped Windows path in tracked JSON. Excluded as an accepted residual
  and a follow-up candidate. **Not verified** that UNC paths occur in preserved content at all.
- **Bare hostnames and machine names.** No lexical form distinguishes a hostname from an ordinary
  identifier, so any pattern would be either unbounded or arbitrary. Excluded for the same reason.
- **IP addresses and non-`C:` drive letters written without a `Users` segment.** Not established by
  any search (R4.2 records them as gaps rather than findings). HT1 already covers any drive letter
  when a `Users` segment is present.

**The refusal is a hard stop. Definition, in terms the tests pin:**

1. The scan runs as a **read-only pre-pass over every valid record** before any write of any kind
   occurs.
2. If any valid record's source bytes or `memory_index_line` matches any pattern, or if any valid
   record carries `host_token_scan.result == "tokens_present"`, then **the write phase is not
   entered at all**. No file is copied, no `MEMORY.md` is appended to or created, and no `git add`
   is invoked — **for any record, not only the matching one**.
3. The pass emits the `PRESERVE|` record for every valid record it examined, plus
   `ACTION|preserve-stage|<target_path>|HOST-TOKEN-BLOCKED` for each matching record naming the
   pattern identifier on stderr, and returns **exit code 3**.
4. Everything is left unstaged and the consolidation worktree is byte-unchanged, so there is
   nothing to undo. That property is what allows this child to add no abort contract (D1's
   justification for not creating the worktree, and the reason `cleanup_consolidation_on_abort`'s
   inability to undo staged files is not a blocker here).
5. The operator sanitizes and re-runs. The pass is idempotent (D8).

All-or-nothing is chosen over per-file skipping because a partially staged index invites a commit
that silently omits the blocked file while appearing to have succeeded, and because it removes the
partial-failure recovery problem entirely.

**Exit-code contract of the `preserve` arm:**

| Code | Meaning |
| --- | --- |
| 0 | Every valid record staged; no record skipped; no index created; no token match. |
| 1 | At least one record was skipped, refused, or failed, or an index file was created; no token match. Everything else that could be staged was staged. |
| 2 | Usage error from the wrapper. Existing meaning, unchanged. |
| 3 | Host-token hard stop. The write phase was not entered; nothing is staged. |
| 127 | A required tool (`jq` or `git`) could not be resolved. Nothing is staged. |

### D6 — Two phases, and where the writes are

**Decision.** The driver is strictly two-phase.

- **Phase 1 (`preserve_plan`) performs no writes.** It reads and validates the manifest, validates
  each record, verifies each source file exists, runs the host-token scan, derives each index
  target's line-ending convention, detects duplicate index entries, and emits the `PRESERVE|` and
  `ACTION|...|SKIPPED-*` records plus an internal plan stream on a separate channel.
- **Phase 2 (`preserve_commit_plan`) is the only function that writes.** It consumes the plan stream
  and performs exactly four kinds of operation: `mkdir -p` of the destination directory, a byte copy
  of the source to `<consolidation-worktree>/<target_path>`, an append (or creation) of the
  destination `MEMORY.md`, and `git -C <consolidation-worktree> add -- <target_path>` (and the index
  path when it changed). It is entered only when phase 1 reports no host-token match.

This split is required by `.claude/rules/general-code-change.md` ("keep pure logic separate from
I/O") and by the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`, which directs
that untestable lines be minimized by refactoring rather than excluded from measurement. Phase 2 is
the thinnest possible wiring; every decision lives in phase 1 and in the pure helpers.

**Byte copy, not transformation.** The preserved file's own content is copied verbatim. No
line-ending transformation is applied to it. Reason: transforming it would alter content the
editorial pass judged worth preserving, and `git add` re-normalizes tracked text to LF anyway under
`.gitattributes:1` (F3). The line-ending obligation is scoped to the `MEMORY.md` index append,
where the defect actually occurred.

**The ignored-destination rule.** After the copy is planned and before it is staged, phase 1 runs
`git -C <consolidation-worktree> check-ignore -q -- <target_path>`. When the path is ignored the
record is refused: emit `ACTION|preserve-stage|<target_path>|IGNORED-TARGET`, do not copy, do not
stage, contribute to exit 1. **`-f` / `--force` is never passed to `git add`.** Reason: forcing an
ignored path produces a commit that appears to preserve the lesson while push-down never
distributes it, because the root `.claude/agent-memory/**` tree is gitignored and only the bundle
mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/agent-memory/**` is
tracked (F4). Refusing to force is also consistent with the library-global no-force policy
(`cleanup_worktrees_actions_lib.sh:168-169`) and `SKILL.md:236-237`.

**The source file is read with plain file I/O, never through git.** The root
`.claude/agent-memory/**` tree is gitignored (F4), so a git-mediated read would be blocked or would
require `-f`. Reading bytes directly sidesteps that entirely and is why this child needs no
`status --porcelain --ignored` call.

### D7 — Line-ending re-derivation is normative, and the advisory value never wins

**Normative requirement.** The convention used to write the `MEMORY.md` index append is **derived
from the target file's current bytes at run time**. `preserved_files[].line_ending` is never read as
an input to that decision. It is read for exactly one purpose: comparison.

**Derivation.** `preserve_derive_line_ending <path>` echoes exactly one token:

| Condition | Token |
| --- | --- |
| Path does not exist, or exists with zero bytes | `absent` |
| Terminated lines exist and none ends `\r\n` | `lf` |
| Terminated lines exist and every one ends `\r\n` | `crlf` |
| Some but not all terminated lines end `\r\n` | `mixed` |

**Write rule, covering all three required cases plus the two edge cases R5.4 identifies:**

- `absent` → the index file is **created** containing the index line terminated with **LF**.
  Justification for LF as the default: `.gitattributes:1` guarantees LF for every tracked path in
  this repository (F3), so LF is the only convention a newly tracked file can hold. Creation also
  emits `ACTION|preserve-index|<index-path>|CREATED` and contributes to exit 1 (see D8).
- `lf` → append with `\n`.
- `crlf` → append with `\r\n`.
- `mixed` → **refuse and report.** Emit `ACTION|preserve-index|<index-path>|EOL-MIXED`, skip that
  record entirely (no copy, no stage, no append), contribute to exit 1. This resolves research open
  question O5. Refusal is chosen over a majority rule because there is no convention to normalize
  to and a majority rule would silently rewrite the operator's file.
- **Unterminated final line.** Before appending, if the target's final byte is not `\n`, the derived
  terminator is written first. `wc -l` counts newline characters, so a file whose last line lacks a
  terminator otherwise concatenates the new index line onto the existing last entry (R5.4).

**Mismatch signal.** When the advisory `line_ending` value differs from the re-derived value, the
pass emits `ACTION|preserve-eol|<index-path>|ADVISORY-MISMATCH` and proceeds with the **re-derived**
value. The advisory value never changes what is written. This is the detectable signal a test pins:
a manifest entry whose `line_ending` is deliberately stale must produce the correct on-disk result
**and** the mismatch record.

**Reachability of the CRLF case.** Within the tracked tree the re-derived answer is always LF (F3),
so the CRLF branch is reachable only for an untracked or foreign target — the gitignored root
`.claude/agent-memory/**` tree, or a consumer checkout without this `.gitattributes`. The obligation
is therefore load-bearing precisely for the case the defect report described and is cosmetic for a
tracked target, where `git add` re-normalizes to LF. This specification states that plainly rather
than asserting a CRLF guarantee the repository's own `.gitattributes` overrides.

**Decision on the `.gitattributes` exception (research open question O9): add one, narrowly
scoped.** A single line is appended to the repository's `.gitattributes`:

```
tests/fixtures/cleanup_worktrees/preserve/eol-crlf/** -text
```

`-text` unsets the `text` attribute for that subtree, so git performs no end-of-line conversion and
the fixture's CRLF bytes survive `git add` and checkout on every platform. Later rules override
earlier ones, so the exception is effective against the leading `* text=auto eol=lf` line.

**Justification.** Without an exception a checked-in CRLF fixture is impossible (F3, R8.6d): git
normalizes it to LF in the index and checks it out as LF, so the fixture silently becomes LF for
every developer and in CI, and the CRLF branch — the branch the defect is actually about — would be
unreachable by any test and permanently uncovered. The alternative of constructing CRLF bytes at run
time is prohibited by the no-temporary-files rule. The exception is confined to one fixture
directory, contains no wildcard outside it, and its effect is pinned by a test that asserts the
checked-out fixture still contains a carriage return — a test that fails if the exception is
removed, reordered, or misspelled.

### D8 — Carrying the `MEMORY.md` index line

**Where the index sits.** `MEMORY.md` is a sibling of the lesson file in the same agent-namespace
directory; index links are bare filenames with no directory component (R7.1). The index line
therefore belongs to the **destination** namespace, derived from `target_path`'s directory, not from
the source's. #635 explicitly permits re-namespacing during consolidation.

**The line is carried verbatim.** The source bytes of `memory_index_line` are appended unchanged. No
separator normalization is performed. The two tracked indexes use a spaced em-dash `—` while #635's
example uses a hyphen-minus (R7.2); because #635 defines the field as "the `MEMORY.md` index line
from the source worktree", re-rendering the separator would drift from both conventions. Only the
line **terminator** is supplied by this child, per D7.

**Append position.** End of file. Neither tracked index is sorted or grouped; both are in append
order (R7.3). Appending is also safe for all three observed index layouts and never lands inside
YAML frontmatter (R7.4).

**`memory_index_line: null`** is valid and means the file is not a memory entry. The file is copied
and staged; no index file is read, created, or appended.

**Duplicate handling (research open question O4): skip, do not replace, do not duplicate.** A
duplicate exists when the destination index already contains a line whose markdown link target — the
text between `](` and `)` — equals the basename of `target_path`. On a duplicate the append is
skipped, the file is still copied and staged, and
`ACTION|preserve-index|<index-path>|SKIPPED-DUPLICATE` is emitted. **A duplicate does not affect the
exit code.** Reason: skipping makes the pass idempotent, and idempotence is load-bearing here
because the host-token hard stop and the partial-failure path both end in the operator re-running
the pass.

**Index creation is reported and is not a clean success.** When the destination index does not
exist, it is created containing the index line, and
`ACTION|preserve-index|<index-path>|CREATED` is emitted with the pass returning 1. Reason: two
incompatible index layouts exist in this repository — the tracked bundle variant carries YAML
frontmatter declaring `metadata.scope: repo`, while the agent-created variant carries none (R7.4) —
and a bundled `MEMORY.md` without that frontmatter fails
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. This child does not have the
information to choose a layout and does not synthesize frontmatter; it surfaces the obligation
loudly so the operator supplies it before committing. The non-zero return is deliberate: creating an
index is not a state in which the pass should report a clean run.

### D9 — The `PRESERVE|` report record and the single `SKILL.md` hunk

**Record shape, field order fixed:**

```
PRESERVE|<worktree-path>|<source-path>|<verdict>
```

Field 1 is the type discriminator, field 2 the worktree that holds the file, field 3 the
repo-relative path **within that worktree** (`source_path`), field 4 the step-5 verdict. The
defect report writes field 3 as `<path>`; this specification resolves that ambiguity to the
**source** path, because the record identifies a finding at its origin exactly as
`DIRTY|<worktree-path>|<status-porcelain-line>` does, and because the destination is reported
separately.

**Per-file outcomes travel on the existing result channel.** `ACTION|<verb>|<target>|<result>` is
already the report contract's result record, so this child adds no second outcome vocabulary. The
verbs and results it introduces:

| Record | Meaning |
| --- | --- |
| `ACTION\|preserve-stage\|<target-path>\|OK` | Copied and staged. |
| `ACTION\|preserve-stage\|<target-path>\|HOST-TOKEN-BLOCKED` | Matched the pattern set. Hard stop (D5). |
| `ACTION\|preserve-stage\|<target-path>\|IGNORED-TARGET` | Destination is gitignored; refused without `-f` (D6). |
| `ACTION\|preserve-stage\|<target-path>\|MISSING-SOURCE` | Named source file does not exist in the named worktree. |
| `ACTION\|preserve-stage\|<target-path>\|SKIPPED-INVALID` | A required manifest field was absent or out of vocabulary (D4). |
| `ACTION\|preserve-stage\|<target-path>\|FAILED` | The copy or `git add` returned non-zero. |
| `ACTION\|preserve-stage\|\|MISSING-WORKTREE` | The consolidation worktree does not exist (D2). |
| `ACTION\|preserve-manifest\|<manifest-path>\|MISSING` / `\|REJECTED` | Manifest absent, unparseable, or failing top-level validation (D3). |
| `ACTION\|preserve-index\|<index-path>\|OK` / `\|CREATED` / `\|SKIPPED-DUPLICATE` / `\|EOL-MIXED` | Index outcomes (D7, D8). |
| `ACTION\|preserve-eol\|<index-path>\|ADVISORY-MISMATCH` | Advisory `line_ending` disagreed with the re-derived value (D7). |
| `ACTION\|preserve-scan\|<target-path>\|PATTERN-SET-MISMATCH` | `host_token_scan.pattern_set_id` is not `cleanup-wt-host-tokens-v1`. Advisory; the local scan governs regardless. Does not affect the exit code. |

`MISSING-SOURCE` resolves research open question O6, which #635's fail-closed column does not cover:
a missing source is a skip-and-report, contributing to exit 1, never a hard stop.

**The `SKILL.md` change is one narrow hunk.** Exactly one bullet is **appended immediately after the
`ACTION|<verb>|<target>|<result>` bullet**, which is the last bullet of the `## Report Line Contract`
list (`SKILL.md:71` on this branch, immediately before the blank line at :72 and the
`## End-to-End Workflow` heading at :73). Every preceding bullet is left byte-unchanged. The
insertion point is named by its anchor bullet rather than by a line number because children #631 and
#632 also edit this list and will move the numbers (R2.5).

The bullet follows the list's observed conventions — an inline code span holding the shape, a spaced
em-dash, angle-bracketed lowercase-hyphenated placeholders, an inline enumerated value set with
` | ` separators, and two-space continuation indents:

```
- `PRESERVE|<worktree-path>|<source-path>|<verdict>` — a manifest `preserved_files[]` finding
  staged onto the consolidation branch; `verdict` in `DEAD_ONE_OFF | ALREADY_SOLVED_ELSEWHERE |
  STALE_OR_CONTRADICTED | GENUINELY_NEW | STILL_RELEVANT`. The per-file outcome is reported by the
  companion `ACTION|preserve-stage|...` record.
```

**The other two copies of the record-type list:**

- `scripts/bash/cleanup-worktrees.sh:42-45` (the `usage()` heredoc) **is updated** (D2).
- `scripts/bash/cleanup_worktrees_lib.sh:40-46` (the library header comment) **is not updated**.
  That file is at 479 of 500 (F6) and is contended by three serialized siblings; adding one comment
  line there would create a fan-in conflict for a documentation-only change. The resulting
  inconsistency is recorded here deliberately and belongs to whichever sibling next has that file
  open.

### D10 — What the git stub must gain

The recording stub `tests/fixtures/cleanup_worktrees/stub-bin/git` has no case for `add` or
`check-ignore`; both fall to the default arm `*) exit 0 ;;`, so a scenario cannot express "the add
failed" or "the path is ignored" (R8.6a). Two cases and two KEY forms are added, documented in the
stub's KEY-scheme header comment alongside the existing entries:

| Invocation | KEY |
| --- | --- |
| `add [--] <path>` (with `-C <wt>`) | `add.<sanitized path>` |
| `check-ignore [-q] [--] <path>` (with `-C <wt>`) | `check-ignore.<sanitized path>` |

**A trap worth stating.** `respond()` defaults to exit 0 when no `<KEY>.rc` file exists, and
`git check-ignore -q` exits 0 when the path **is** ignored. A scenario that omits the `.rc` file
therefore reports "ignored" and every record is refused. That default is fail-closed and is kept;
each happy-path scenario directory must carry `check-ignore.<key>.rc` containing `1`.

`commit`, `ls-files`, `hash-object`, `cat-file`, and `diff --cached` are **not** added: this child
issues none of them (D6). The stub's flag-insensitive `status` KEY (R8.6b) is likewise not changed,
because this child issues no `status` call.

The stub is at 208 of the 500-line cap (F6), leaving ample headroom.

### D11 — How phase 2 is exercised without a temporary file

`.claude/rules/general-unit-test.md` and `.claude/rules/shell.md:90-93` prohibit creating or using
temporary files in tests. Phase 2 writes to
`<consolidation-worktree>/<target_path>`, so a naive test would have to create one.

**Primary technique.** A test sets `CLEANUP_WT_CONSOLIDATION_PATH=/dev` and uses a manifest fixture
whose `target_path` is `null`, so the destination resolves to `/dev/null`. `mkdir -p /dev` succeeds
against the existing directory, the byte copy and the append both write to the null device, and no
file is created anywhere. The `git add` argv remains observable through the stub's
`stub-git: <argv>` stderr log, which is the established assertion idiom (R8.4). `/dev/null` is a
character device, not a temporary file, so the rule is satisfied in substance as well as in letter.

**Fallback, pre-authorized.** If that technique proves brittle on any supported platform, phase 2's
filesystem lines are left exercised only by the production path. That is acceptable under the
Coverage Exclusion Policy's own guidance — minimize the untestable surface by refactoring rather
than exclude it from measurement — because D6 already reduces phase 2 to `mkdir -p`, a copy, an
append, and a `git add`. No `exclude` entry is added for any production path under any
circumstances.

### D12 — The consumer re-derives, and trusts, nothing advisory

Two upstream values are advisory and are both re-derived locally:

- `line_ending` — #635 marks it ADVISORY and requires re-derivation (D7).
- `host_token_scan` — the consumer performs its own scan of the source bytes **unconditionally**,
  whatever `result` says. A `result` of `tokens_present` short-circuits to a refusal without
  scanning (cheap fail-closed gate); a `result` of `clean` does not skip the local scan. A
  `pattern_set_id` other than `cleanup-wt-host-tokens-v1` produces an advisory
  `PATTERN-SET-MISMATCH` record and changes nothing else.

The justification is #635's own: the manifest is written by the skill's editorial pass — an LLM —
not by a script, so every field must be validated fail-closed at consumption, and the hooks never
read `preserved_files` at all, so nothing upstream has validated that array.

## Proposed Fix

### Design summary (what changes where)

| File | Change |
| --- | --- |
| `scripts/bash/cleanup_worktrees_preserve_lib.sh` (NEW) | The whole preserve-staging function group: `preserve_resolve_jq`, `preserve_read_manifest`, `preserve_validate_record`, `preserve_scan_host_tokens`, `preserve_derive_line_ending`, `preserve_index_has_entry`, `preserve_render_index_append`, `preserve_plan`, `preserve_commit_plan`, `run_preserve` |
| `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` (NEW, only if the cap requires it) | The line-ending and index group split out of the above (D1) |
| `scripts/bash/cleanup-worktrees.sh` | One new `source` block; one new `preserve \| --preserve` dispatch arm; usage text gains the command, the `CLEANUP_WT_MANIFEST_PATH` override, and the `PRESERVE\|` record shape |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | One appended bullet in `## Report Line Contract` (D9) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` | The identical mirrored bullet |
| `.gitattributes` | One appended line scoping `-text` to the CRLF fixture directory (D7) |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | `add` and `check-ignore` cases plus their KEY documentation (D10) |
| `tests/fixtures/cleanup_worktrees/preserve/**` (NEW) | Checked-in scenario directories, manifest fixtures, source-file fixtures, index-target fixtures, and the `jq` stub |
| `tests/shell/test_cleanup_worktrees_preserve.bats` (NEW) | The suite |
| `scripts/bash/cleanup_worktrees_lib.sh` | **No change** (D9, Out of scope) |
| `.claude/hooks/**` | **No change** (Out of scope) |

### Boundaries and invariants to preserve

- `cleanup_worktrees_lib.sh`, `cleanup_worktrees_actions_lib.sh`, and
  `cleanup_worktrees_enumerate_lib.sh` carry no diff.
- The existing dispatch arms of `main` return exactly what they return today; the unknown-argument
  arm still prints usage to stderr and returns 2.
- The six existing report record shapes are byte-unchanged in `SKILL.md`, in the wrapper usage
  heredoc, and in the library header comment.
- No force flag is added to any git invocation, ever — not to `git add`, not to `git worktree
  remove`.
- The new library defines functions only and runs no work at source time.
- No `exclude` entry is added to any coverage configuration.
- No temporary file is created by any test.

### Inputs, outputs, and formats

- **Input:** `artifacts/orchestration/cleanup-worktrees-manifest.json` (#635, section "Technical
  specification — the normative manifest contract"), or the path in `CLEANUP_WT_MANIFEST_PATH`.
  Only `preserved_files[]` and the top-level `tool` and `schema_version` fields are read.
  `removals[]` is never read; #635 pins `removals` and `preserved_files` as sibling arrays, never
  nested.
- **Output:** the report stream on stdout — `PRESERVE|` records and `ACTION|preserve-*` records,
  `LC_ALL=C`-ordered, pipe-delimited, one record per line. Diagnostics on stderr. Exit code per D5.
- **Configuration keys:** `CLEANUP_WT_MANIFEST_PATH` (new, default
  `artifacts/orchestration/cleanup-worktrees-manifest.json`), `CLEANUP_WT_JQ_BIN` (new, no default;
  falls back to `command -v jq`), and the three existing `CLEANUP_WT_*` overrides, unchanged.
- **Backward compatibility:** purely additive. No existing flag, record shape, exit code, or
  environment variable changes meaning.

## Test Strategy

All tests are bats suites under `tests/shell/`, driven through the `CLEANUP_WT_GIT_BIN` /
`CLEANUP_WT_STUB_SCENARIO` seam plus the new `CLEANUP_WT_JQ_BIN` and `CLEANUP_WT_MANIFEST_PATH`
seams, against **new checked-in fixture scenario directories**. No temporary file is created. There
is no shared bats helper library in this tree (R8.2), so the new suite duplicates the setup block
the consolidation suite uses and adds the new library path.

**The four scenarios the requirements name, and how each is expressible:**

| Scenario | Fixture group | What makes it expressible |
| --- | --- | --- |
| Untracked preserve file | `preserve/untracked/` | Source file checked in; `check-ignore.<key>.rc` = `1`; `add.<key>` absent so the stub exits 0; argv asserted from the `stub-git:` log |
| Modified preserve file | `preserve/modified/` | Same shape; `change_class: "modified"`. D4 pins that the staging action is identical, so no `status` call and no stub change are needed |
| Host-token match, hard stop | `preserve/host-token/` | A checked-in source fixture containing a host token. Not a git interaction; the scan reads file bytes (D5). Asserts exit 3 and that the output carries no `stub-git: add` line |
| Stale advisory `line_ending` | `preserve/eol-stale/` and `preserve/eol-crlf/` | A manifest fixture asserting `"line_ending": "crlf"` against an LF index target, and the converse against the `-text`-scoped CRLF fixture (D7) |

Further required coverage: top-level manifest rejection; unresolvable `jq` returning 127; the
fail-closed field matrix of D4, one case per field; `memory_index_line` key-absent versus `null`;
missing source; ignored target; mixed line endings; unterminated final line; duplicate index entry;
index creation; `LC_ALL=C` ordering against an out-of-order manifest; the scan-scope negative case
(a manifest and a destination index that both contain host tokens must not trigger a refusal); the
`pattern_set_id` advisory; each pattern HT1 through HT6; the exit-code contract; the wrapper
dispatch arm; the unknown-argument arm still returning 2; the source-guard property; and the CRLF
fixture's integrity in the working tree.

Fail-before evidence is required: the new suite must be shown failing against the pre-change tree
for the untracked-staging, line-ending, and host-token cases, recorded under
`evidence/regression-testing/`.

### Toolchain — recorded verbatim

    pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/<worktree path with forward slashes and no drive colon> && bash scripts/bash/shell-qc.sh <check|format|test|test --coverage>'"

A bare `wsl` invocation matches no Bash grant and is denied. The order is format → check → test, and
the loop restarts from format if any stage fails or rewrites a file. The coverage headline is
printed as `Bash coverage (lines): NN.N%`; kcov writes a merged Cobertura `cov.xml` under
`artifacts/pester/kcov`. Fallback: dispatch `.github/workflows/_shell-coverage.yml` with
`gh workflow run --ref <branch>`. **CI is canonical when local and CI disagree.**

## Delivery Obligations

- **Push-down parity.** Any `.claude/**` edit is mirrored into
  `extensions/drm-copilot/resources/claude-customizations/.claude/**` in the same change, enforced
  by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. The mirror of
  `cleanup-merged-worktrees/SKILL.md` is byte-identical today (F5), so the mirrored hunk must be
  identical, not merely equivalent.
- **Coverage.** kcov line coverage >= 85%. There is no bash branch-coverage gate
  (`.claude/rules/shell.md:68-70`). Because the kcov include pattern covers all of `scripts/`, a new
  under-tested library lowers the whole repository's bash line coverage.
- **500-line cap** on every production, test, and reusable script file. Markdown is exempt.
- **No temporary files in tests.**
- **Evidence** to `evidence/qa-gates/` (coverage, toolchain) and `evidence/regression-testing/`
  (fail-before), timestamped `yyyy-MM-ddTHH-mm`.

## Assumptions, Constraints, Dependencies

**Assumptions:**

- `jq` is available on the host that runs the `preserve` arm in production. **Not verified** for CI;
  see D3 for why CI does not need it.
- Issue #635 lands before this child and the manifest exists at the contracted path with the
  contracted `preserved_files[]` shape. If #635 has not landed, this child's behavior is still fully
  testable through `CLEANUP_WT_MANIFEST_PATH` against fixture manifests.
- Children #630, #631 and #632 land ahead of this child and move line numbers in `SKILL.md` and
  `cleanup-worktrees.sh`. Anchors, not line numbers, are used throughout.

**Constraints:**

- `scripts/bash/cleanup_worktrees_lib.sh` must not grow (F6, `epic.md:206-209`).
- `main` reads only `${1:-}` (F1), which is routed around rather than addressed (D2).
- A CRLF fixture is impossible without the `.gitattributes` exception (F3, D7).
- The host-token scan must be per-file and scope-bounded; a repository-wide scan is not viable
  (R4.3, D5).

**External dependencies:**

- Issue #635 owns `artifacts/orchestration/cleanup-worktrees-manifest.json` and the
  `preserved_files[]` contract this child consumes (#635, sections "Technical specification — the
  normative manifest contract" and "Vocabulary").
- Children #631 and #632 contend for the `## Report Line Contract` range in `SKILL.md`.

## Documentation corrections

Recorded here as required. None of these is fixed by this child except where stated.

1. **Stale child-F issue number.** Issue #635's specification and
   `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md` (manifest entry
   `issue_num: 904` at :49-51; decomposition rows `| B | 901 |`, `| C | 902 |`, `| D | 903 |`,
   `| F | 904 |` at :98-108; prose at :135 and :171-173) refer to this child as **#904**. The real
   number is **#637**, and B/C/D are **#631/#632/#635**. **`epic.md` is not edited by this child**;
   correcting it is the epic planner's call (research open question O11).
2. **`pattern_set_id` example literal.** #635's example JSON carries
   `"pattern_set_id": "child-f-host-tokens-v1"`. That was an example value, not a normative
   literal (R9.2). This specification defines the identifier as **`cleanup-wt-host-tokens-v1`**.
   The manifest-writing step in `SKILL.md`, which #635 owns, should carry the corrected value.
3. **`--consolidate` does not exist.** The previous draft of this `spec.md` carried the uncorrected
   repro step 3 and Actual paragraph; both are replaced by this document (research open question
   O12, now closed for this file).
4. **Contradictory tracked memories about `.claude/agent-memory`.**
   `extensions/.../agent-memory/epic-orchestrator/MEMORY.md:11` records that the repo-root tree is
   gitignored and only the bundle mirror is tracked, which matches `.gitignore:67` (F4). The
   orchestrator counterpart (`.../orchestrator/MEMORY.md:16` and
   `.../orchestrator/feedback_commit_push_memory_before_pr.md:9`) still describes agent-memory files
   as repo-committed and instructs staging them directly. Observed, recorded, not fixed (research
   open question O13).
5. **`user-story.md` for a `full-bug`.** `.claude/hooks/enforce-prd-feature-before-planner.ps1`
   `Get-PrdFeatureRequiredFile` carries a docstring stating that `user-story.md` "is required to be
   ABSENT for full-bug and minor-audit work", while `scripts/dev_tools/epic_planner_readiness.py:187`
   requires `issue.md`, `spec.md`, **and** `user-story.md` in every prepared epic-child folder.
   Verified by reading: the hook's predicate `Get-PrdFeatureMissingFile` reports only *missing*
   required files and never inspects for extra ones, so it does not deny when `user-story.md` is
   additionally present. The two statements conflict in prose; the enforced behavior does not.
   Recorded, not fixed. See `user-story.md` for the operative consequence.

## Acceptance Criteria

Each criterion has a stable ID. Criteria naming a bats test assert that the named test exists in the
named file and passes in a `bash scripts/bash/shell-qc.sh test` run. No criterion asserts a count,
an enumeration size, or a population.

- [ ] **AC-01** `scripts/bash/cleanup_worktrees_preserve_lib.sh` exists, and the bats test
      `preserve library defines functions only and runs no work at source time` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-02** The bats test `preserve subcommand dispatches to the preserve driver` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-03** The bats test `an unknown subcommand still prints usage to stderr and returns 2` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-04** `scripts/bash/cleanup-worktrees.sh` contains the single-line token
      `CLEANUP_WT_MANIFEST_PATH` in its usage heredoc, and the bats test
      `the manifest path is taken from CLEANUP_WT_MANIFEST_PATH` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-05** The bats test `an unresolvable jq returns 127 and stages nothing` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-06** The bats test `a manifest with a wrong tool or schema_version is rejected and stages
      nothing` in `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-07** The bats test `a missing consolidation worktree reports MISSING-WORKTREE and stages
      nothing` in `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-08** The bats test `an untracked preserve record is staged and reported` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-09** The bats test `a modified preserve record is staged and reported` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-10** The bats test `records are emitted in LC_ALL=C order regardless of manifest order`
      in `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-11** The bats test `the memory index line is appended verbatim to the destination index`
      in `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-12** The bats test `a null memory_index_line stages the file and touches no index` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-13** The bats test `an absent destination index is created and reported as CREATED` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-14** The bats test `a duplicate index entry is skipped and does not change the exit code`
      in `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-15** The bats test `an unterminated final line receives a terminator before the append`
      in `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-16** The bats test `a stale advisory crlf value does not override an LF target` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-17** The bats test `an advisory line ending mismatch emits ADVISORY-MISMATCH` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-18** The bats test `a crlf target receives a crlf terminated index line` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-19** The bats test `a mixed line ending target is refused and reported as EOL-MIXED` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [x] **AC-20** The bats test `the crlf fixture still contains a carriage return in the working
      tree` in `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [x] **AC-21** `.gitattributes` contains the single-line token
      `tests/fixtures/cleanup_worktrees/preserve/eol-crlf/** -text`.
- [ ] **AC-22** The bats test `a host token match aborts the pass before any staging` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes, asserting exit status 3 and that
      the output carries no `stub-git: add` line.
- [ ] **AC-23** The bats test `each host token pattern is detected` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes, with one fixture per pattern
      identifier HT1 through HT6.
- [ ] **AC-24** The bats test `HEAD~1 and other revision syntax do not match the short-name pattern`
      in `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-25** The bats test `the host token scan reads only the named source file` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes, using a manifest fixture and a
      destination index fixture that both contain host tokens and must not trigger a refusal.
- [ ] **AC-26** The bats test `an absent or malformed host_token_scan refuses to stage the record`
      in `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-27** The bats test `a pattern set id mismatch is reported and the local scan governs` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-28** The bats test `each missing or out of vocabulary field skips the record and reports`
      in `tests/shell/test_cleanup_worktrees_preserve.bats` passes, with one case per field in the
      D4 table.
- [ ] **AC-29** The bats test `a missing source file is reported as MISSING-SOURCE` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [ ] **AC-30** The bats test `an ignored target path is refused without a force flag` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` passes, asserting the output contains
      `IGNORED-TARGET` and contains no `--force`.
- [ ] **AC-31** The bats test `the preserve exit codes distinguish clean, skipped, and blocked runs`
      in `tests/shell/test_cleanup_worktrees_preserve.bats` passes.
- [x] **AC-32** The bats tests `the git stub replays a scenario response for add` and
      `the git stub replays a scenario response for check-ignore` in
      `tests/shell/test_cleanup_worktrees_preserve.bats` pass.
- [x] **AC-33** `.claude/skills/cleanup-merged-worktrees/SKILL.md` contains the single-line token
      `PRESERVE|` and that token appears in the `## Report Line Contract` bullet list.
- [x] **AC-34** `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
      is byte-identical to `.claude/skills/cleanup-merged-worktrees/SKILL.md`, verified with `cmp`.
- [x] **AC-35** `python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
      exits 0.
- [x] **AC-36** `git diff --stat epic/cleanup-merged-worktrees-hardening-integration -- scripts/bash/cleanup_worktrees_lib.sh`
      prints nothing, and `git status --porcelain -- scripts/bash/cleanup_worktrees_lib.sh` prints
      nothing.
- [x] **AC-37** `git diff --stat epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks`
      prints nothing, and `git status --porcelain -- .claude/hooks` prints nothing.
- [x] **AC-38** Every file created or changed by this work is at or below 500 lines, verified per
      file with `wc -l` against the changed-file list. Markdown files are exempt.
- [ ] **AC-39** A single pass of `bash scripts/bash/shell-qc.sh format`, then
      `bash scripts/bash/shell-qc.sh check`, then `bash scripts/bash/shell-qc.sh test` completes
      with every stage exiting 0 and no file rewritten by the format stage. The transcript is
      recorded under `evidence/qa-gates/`.
- [ ] **AC-40** `bash scripts/bash/shell-qc.sh test --coverage` prints the headline
      `Bash coverage (lines): NN.N%` and the printed value is at least 85.0; the merged
      `artifacts/pester/kcov/cov.xml` is produced and its summary is recorded under
      `evidence/qa-gates/`.
- [x] **AC-41** No coverage configuration in the change adds an `exclude` entry matching any path
      under `scripts/`.
- [x] **AC-42** Fail-before evidence is recorded under `evidence/regression-testing/` showing the
      tests named in AC-08, AC-16, and AC-22 failing against the pre-change tree.
- [x] **AC-43** No test creates or reads a temporary file; the changed test files and fixtures
      contain no `mktemp` and no `BATS_TEST_TMPDIR`.

## Open Questions

Carried forward from the research. Those the specification resolves are marked with the resolving
decision; the rest remain open.

| ID | Question | Status |
| --- | --- | --- |
| O1 | Dispatch arm versus library-only? | **Resolved** by D2: a bare `preserve` arm plus an environment seam. |
| O2 | Does the preserve step create the consolidation worktree? | **Resolved** by D2 and Out of scope: no; it fails closed when the worktree is absent. |
| O3 | Is the consolidation destination the gitignored root `.claude/agent-memory/**`, the tracked bundle mirror, or both? | **OPEN — escalate to the epic planner.** #635's `target_path` example names the ignored root path, which cannot be committed without `-f` and which push-down never distributes (F4). This child defines behavior for both cases (D6: an ignored target is refused, never forced), but the contract question is cross-child and is not this child's to settle. |
| O4 | Duplicate index line: skip, replace, or duplicate? | **Resolved** by D8: skip, report, do not affect the exit code. |
| O5 | Mixed line endings: majority, first terminator, or refuse? | **Resolved** by D7: refuse and report. |
| O6 | A `source_path` that does not exist in the named worktree? | **Resolved** by D9: `MISSING-SOURCE`, skip and report, exit 1. |
| O7 | Allowed values of `host_token_scan.result`, and the `pattern_set_id` literal? | **Resolved** by D5: `clean` and `tokens_present`; identifier `cleanup-wt-host-tokens-v1`. |
| O8 | Does the pattern set cover UNC paths and hostnames? | **Resolved** by D5: no, with the reason recorded and both listed as accepted residuals. |
| O9 | Add a `.gitattributes` exception for a CRLF fixture? | **Resolved** by D7: yes, one line scoped to `tests/fixtures/cleanup_worktrees/preserve/eol-crlf/`. |
| O10 | Does the stub's KEY scheme gain flag awareness? | **OPEN, and not blocking here.** This child issues no `status` call (D6), so the collision is not on its path. Left to the sibling that needs it. |
| O11 | Who corrects the 901–904 placeholders in `epic.md`? | **OPEN — epic planner.** Recorded in "Documentation corrections"; `epic.md` is not edited here. |
| O12 | `issue.md` and `spec.md` describe a `--consolidate` flag that does not exist. | **Resolved for these two files**: `issue.md` already carries the correction and this document replaces the stale text. |
| O13 | The two tracked orchestrator memories contradict each other about `.claude/agent-memory`. | **OPEN.** Observed and recorded; not corrected by this child. |
| O14 (new) | Should `.github/workflows/_shell-coverage.yml` install `jq` explicitly rather than rely on the runner image preinstalling it? | **OPEN.** No workflow change is made (D3). The tests need no real `jq`, so CI is unaffected today; the question matters only if a future test invokes a real `jq`. |
| O15 (new) | Who supplies the `metadata.scope` frontmatter for a preserved bundled memory file or a newly created bundled index? | **OPEN.** This child reports index creation loudly (D8) and never synthesizes frontmatter. The editorial pass or the operator owns it. |

## Risks & Mitigations

| Risk | Mitigation |
| --- | --- |
| The `jq` dependency is absent on the operator's host, so the arm cannot run. | Fail-closed 127 with a diagnostic naming the tool, matching `cleanup_wt_git`'s contract. Documented install step. No silent no-op — which is the exact failure mode this defect is about. |
| The host-token pattern set produces false positives on a legitimately path-bearing lesson file. | The scan is scoped to the file being staged and nothing else (D5). A false positive costs one sanitize-and-re-run cycle; the pass is idempotent (D8). The alternative — a missed token in a pushed commit — is the failure the defect records. |
| Sibling children move the `SKILL.md` insertion point. | The hunk is anchored to the `ACTION|` bullet, not to a line number, and is a single appended bullet (D9). |
| The new library lowers repository-wide bash line coverage. | The two-phase split (D6) puts every decision in testable functions; AC-40 gates the headline. |
| `.gitattributes` exception is later removed or reordered, silently converting the CRLF fixture to LF. | AC-20's test asserts the checked-out fixture still contains a carriage return and fails if the exception stops working; AC-21 pins the line itself. |
| The manifest's `target_path` names the gitignored root tree, so nothing is stageable in practice. | O3 escalates the contract question. The behavior is defined and reported (`IGNORED-TARGET`), never forced, so the failure is visible rather than silent. |

## Rollout & Follow-up

- Rollout is a normal merge into `epic/cleanup-merged-worktrees-hardening-integration` and thence to
  `main`. Consumer repositories receive the `SKILL.md` change through push-down; the bash library is
  repository-local and reaches consumers only if a later change publishes it.
- Post-fix follow-up candidates, none opened by this document:
  1. The dead consolidation driver (F2) — the larger defect this child's boundary excludes.
  2. UNC-path and hostname patterns for `cleanup-wt-host-tokens-v1`, pending an independent search
     that R4.2 records as not performed.
  3. The stale record-type list in `cleanup_worktrees_lib.sh:40-46` (D9).
  4. The `epic.md` placeholder issue numbers (O11) and the contradictory orchestrator memories
     (O13).
- Links: issue #637 (https://github.com/drmoisan/drm-copilot/issues/637); upstream contract issue
  #635; epic `cleanup-merged-worktrees-hardening`; research artifact
  `research/2026-09-07-preserve-file-consolidation-research.md`.
