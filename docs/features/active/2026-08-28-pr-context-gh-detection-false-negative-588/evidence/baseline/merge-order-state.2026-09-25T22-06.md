# Merge-Order State ([P0-T2])

Timestamp: 2026-09-26T21-10

Sync SHA: b67453837646fd2dd4f5ac692f76e6f7703fe798

Command:
- (a) `git grep -l -F -e "Unverified: the issues listed above come from feature metadata only" b67453837646fd2dd4f5ac692f76e6f7703fe798 -- "scripts/dev_tools/pr_context/*.py" "extensions/drm-copilot/src/lib/pr-context/*.ts"`
- (b) `git grep -l -F -e "export function buildIssuesToAutocloseSection(" b67453837646fd2dd4f5ac692f76e6f7703fe798 -- "extensions/drm-copilot/src/lib/pr-context/*.ts"`
- (c) `git grep -l -F -e "def build_issues_to_autoclose_section(" b67453837646fd2dd4f5ac692f76e6f7703fe798 -- "scripts/dev_tools/pr_context/*.py"`
- (d) `git show b67453837646fd2dd4f5ac692f76e6f7703fe798:extensions/drm-copilot/src/lib/pr-context/autoclose.ts | awk '/^\/\*\*/{d=NR} /^export function buildIssuesToAutocloseSection\(/{f=1; print "doc_start=" d; print "fn_start=" NR} f&&/ghAvailable/{print "gh_param=" NR} f&&/ghAvailable (=|[?][?]) true/{print "gh_default=" NR} f&&/^}$/{print "fn_end=" NR; exit}'`
- (e1) `git show b67453837646fd2dd4f5ac692f76e6f7703fe798:scripts/dev_tools/pr_context/render_pr_helpers.py | awk '/^def build_issues_to_autoclose_section\(/{f=1; s=NR; print "fn_start=" NR} f&&NR>s&&/^(def |class |@)/{print "next_def=" NR; exit} f&&/gh_available/{print "gh_param=" NR} f&&/gh_available: bool = True/{print "gh_default=" NR}'`
- (e2) `git show b67453837646fd2dd4f5ac692f76e6f7703fe798:scripts/dev_tools/pr_context/render_pr_helpers.py | wc -l`
- (f1) `git grep -c -F -e "None (GitHub CLI unavailable; closing issues not verified)" b67453837646fd2dd4f5ac692f76e6f7703fe798 -- extensions/drm-copilot/src/lib/pr-context/autoclose.ts extensions/drm-copilot/src/lib/pr-context/models.ts`
- (f2) `git grep -c -F -e "None (GitHub CLI unavailable; closing issues not verified)" b67453837646fd2dd4f5ac692f76e6f7703fe798 -- scripts/dev_tools/pr_context/render_pr_helpers.py scripts/dev_tools/pr_context/models.py`
- (g1) `git show b67453837646fd2dd4f5ac692f76e6f7703fe798:extensions/drm-copilot/src/lib/pr-context/collector-core.ts | awk '/buildIssuesToAutocloseSection\(\{/{f=1; print "call_start=" NR} f&&/ghAvailable/{print "gh_arg=" NR} f&&/^[[:space:]]*\}\);/{print "call_end=" NR; exit}'`
- (g2) `git show b67453837646fd2dd4f5ac692f76e6f7703fe798:scripts/dev_tools/pr_context/collector.py | awk '/build_issues_to_autoclose_section\($/{f=1; print "call_start=" NR} f&&/gh_available=/{print "gh_arg=" NR} f&&/^[[:space:]]*\)$/{print "call_end=" NR; exit}'`
- (h) `git ls-tree --name-only b67453837646fd2dd4f5ac692f76e6f7703fe798 -- tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py`
- (i) `git grep -n -F -e '"./src/lib/executable-resolver.ts": {' -e '"./src/lib/pr-context/render-pr-helpers.ts": {' -e '"./src/lib/pr-context/autoclose.ts": {' b67453837646fd2dd4f5ac692f76e6f7703fe798 -- extensions/drm-copilot/jest.config.cjs`
- (j) one `git grep -c -F -e "<title>" b67453837646fd2dd4f5ac692f76e6f7703fe798 -- <file>` per title: H1-H4 in `extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts`; K1, K2, and the describe name `collectPrContext autoclose body availability` in `extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts`; S1 in `extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts`. Python names were not searched because `PY_UNIT_TEST_FILE` is `ABSENT`.

EXIT_CODE:
- (a) 0
- (b) 0
- (c) 0
- (d) 0
- (e1) 0
- (e2) 0
- (f1) 1
- (f2) 1
- (g1) 0
- (g2) 0
- (h) 0
- (i) 0
- (j) 1 for each of the eight titles (no match)

Output Summary:
- (a) `b67453837646fd2dd4f5ac692f76e6f7703fe798:extensions/drm-copilot/src/lib/pr-context/models.ts`; `b67453837646fd2dd4f5ac692f76e6f7703fe798:scripts/dev_tools/pr_context/models.py`
- (b) `b67453837646fd2dd4f5ac692f76e6f7703fe798:extensions/drm-copilot/src/lib/pr-context/autoclose.ts` (one line)
- (c) `b67453837646fd2dd4f5ac692f76e6f7703fe798:scripts/dev_tools/pr_context/render_pr_helpers.py` (one line)
- (d) `doc_start=228`, `fn_start=244`, `gh_param=248`, `gh_param=255`, `gh_default=255`, `gh_param=272`, `fn_end=287`
- (e1) `fn_start=237`, `gh_param=242`, `gh_default=242`, `gh_param=256`, `gh_param=283`, `next_def=299`
- (e2) `315`
- (f1) no output (exit 1)
- (f2) no output (exit 1)
- (g1) `call_start=240`, `gh_arg=244`, `call_end=246`
- (g2) `call_start=242`, `gh_arg=246`, `call_end=248`
- (h) no output (exit 0, empty)
- (i) `b67453837646fd2dd4f5ac692f76e6f7703fe798:extensions/drm-copilot/jest.config.cjs:47:    "./src/lib/pr-context/autoclose.ts": {`; `b67453837646fd2dd4f5ac692f76e6f7703fe798:extensions/drm-copilot/jest.config.cjs:63:    "./src/lib/pr-context/render-pr-helpers.ts": {`
- (j) no output for any title.
- Structure check (read-only, for [P3-T3]/[P4-T1] stop conditions): the TS builder's chain opens with `if (ordered.length > 0) {` and the line after the non-empty block is `} else if (pendingPrimaryExcluded) {`; the Python builder's chain opens with `if ordered:` and the line after the non-empty block is `elif pending_primary_excluded:`. Pure insertion is possible in both runtimes.

Recorded values:

ORDER: 622-MERGED
TS_BUILDER_FILE: extensions/drm-copilot/src/lib/pr-context/autoclose.ts
PY_BUILDER_FILE: scripts/dev_tools/pr_context/render_pr_helpers.py
TS_BUILDER_RANGE: 228-287
TS_PARAM: PRESENT
TS_DEFAULT: PRESENT
TS_BODY: ABSENT
TS_BUILDER_STATE: PARAM-ONLY
PY_BUILDER_RANGE: 237-298
PY_PARAM: PRESENT
PY_DEFAULT: PRESENT
PY_BODY: ABSENT
PY_BUILDER_STATE: PARAM-ONLY
TS_CALLSITE_RANGE: 240-246
TS_CALLSITE: PRESENT
PY_CALLSITE_RANGE: 242-248
PY_CALLSITE: PRESENT
PY_UNIT_TEST_FILE: ABSENT
JEST_KEY_EXECUTABLE_RESOLVER: ABSENT
JEST_KEY_RENDER_PR_HELPERS: PRESENT
JEST_KEY_AUTOCLOSE: PRESENT
REQUIRED_JEST_KEYS: ./src/lib/executable-resolver.ts, ./src/lib/pr-context/render-pr-helpers.ts, ./src/lib/pr-context/autoclose.ts
TITLE_COLLISIONS: none (every final name equals its planned name)

Consistency: no parameter is present without its default; neither builder state is `PARTIAL`; both call sites are `PRESENT` with builder state `PARAM-ONLY`, which is consistent. All ranges have start <= end.
