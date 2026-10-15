# kcov subshell attribution limit (CR-14, issue 895)

Timestamp: 2026-10-12T17-58

## Constructs

Three lines of `.codex/codex-web-setup.sh` are reported as uncovered by kcov. They are identified by content; the line numbers are given for reference.

| Construct | Base-branch line | Post-edit line |
|---|---|---|
| Opening `(` of the subshell in `install_dotnet_tools` | 207 | 222 |
| Closing `)` of the same subshell in `install_dotnet_tools` | 210 | 225 |
| Opening `(` of the subshell in `verify_formatting_capability` | 302 | 317 |

The post-edit line numbers are 15 higher than the base-branch numbers because this change adds the logging function (13 lines), the GNU find comment (1 line), and the logging call in `main` (1 line) above them.

## Delimiter-line listing

Command: `git grep -n -E "^[[:space:]]*[()][[:space:]]*$" -- .codex/codex-web-setup.sh`

Output (exactly three bare delimiter lines):

```
.codex/codex-web-setup.sh:222:	(
.codex/codex-web-setup.sh:225:	)
.codex/codex-web-setup.sh:317:	(
```

## Mechanism

kcov traces bash scripts through xtrace. The trace prefix is the `PS4` value set at line 8 of `scripts/bash/kcov_trace_env.sh` (`kcov@${BASH_SOURCE}@${LINENO}@`). Bash emits a trace event only when it executes a simple command. A bare subshell delimiter line (`(` or `)` alone on a line) is syntax that opens or closes a subshell and is not a simple command, so it can never carry a trace event. kcov therefore has no event to attribute to those lines and reports them as uncovered even when the commands between them run. This is an attribution limit of the xtrace-based tracer, not a missing test.

## Covering tests for the enclosing functions

The commands inside each subshell are exercised by existing bats cases:

- C824-43 in `tests/shell/test_codex_web_setup_codex_dotnet.bats` runs `install_dotnet_tools` through the restore path (the `cd` and `dotnet tool restore` lines inside the subshell).
- C824-50 in `tests/shell/test_codex_web_setup_codex_verify.bats` runs `verify_formatting_capability` through the failing CSharpier path.
- C824-51 in `tests/shell/test_codex_web_setup_codex_verify.bats` runs `verify_formatting_capability` through the passing CSharpier path.

## Rejected restructuring option

The subshell delimiters could be removed by replacing each subshell with a brace group or a helper function that carries a `cd`. That change would alter working-directory behaviour: a subshell confines `cd "${REPO_ROOT}"` to the subshell, while a brace group leaves the caller in the new directory. It would also change the content of the script and of the bundled mirror, which must stay byte-identical. The restructuring is rejected because it changes behaviour to satisfy a reporting limit.

## CI kcov evidence

S9-EVIDENCE: RECORDED

Source: `cov.xml` in the `shell-coverage` artifact of CI run 38287725741 (https://github.com/drmoisan/drm-copilot/actions/runs/38287725741), job "shell-coverage / Shell Coverage (Bats + kcov)" (job 114939999004), PR #918, tested head 28dd119ab898f82379664da02d5a1c498054576a. The class entry for `.codex/codex-web-setup.sh` has line-rate 0.958 (206 of 215 recorded lines covered). The nine uncovered lines are 222, 225, 317, 332, 333, 334, 337, 338, and 339.

Hit counts for the three bare delimiter lines and for the neighbouring command lines in the same subshells (post-edit line numbers; `absent` means the line has no entry in `cov.xml`):

| Line | Content role | Hits |
|---|---|---|
| 221 | command before the `install_dotnet_tools` subshell | 1 |
| 222 | bare opening `(` in `install_dotnet_tools` | 0 |
| 223 | command inside the subshell | 1 |
| 224 | command inside the subshell | 1 |
| 225 | bare closing `)` in `install_dotnet_tools` | 0 |
| 314 | command before the `verify_formatting_capability` subshell | 1 |
| 315 | command before the `verify_formatting_capability` subshell | 1 |
| 317 | bare opening `(` in `verify_formatting_capability` | 0 |
| 318 | command inside the subshell | 1 |
| 319 | command inside the subshell | 1 |
| 320 | command inside the subshell | 1 |

All three bare delimiter lines record 0 hits while every command line adjacent to them records at least 1 hit, which matches the mechanism above: the enclosing commands run and only the delimiter syntax carries no trace event. The attribution limit is confirmed by CI evidence.

Lines 332 through 339 are also reported as uncovered in this run and were not part of CR-14; they are outside the scope of this change.

Whole-run figures from the same step log: `Bash coverage (lines): 94.8%` (3064 of 3232 lines in `cov.xml`), against the baseline of 94.5% in main run 38280367474.
