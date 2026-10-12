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

S9-EVIDENCE: PENDING

The orchestrator replaces the line above with the `cov.xml` hit counts cited from the `shell-coverage` artifact of the PR run: the hit counts for the three bare delimiter lines and for the neighbouring command lines inside the same subshells.
