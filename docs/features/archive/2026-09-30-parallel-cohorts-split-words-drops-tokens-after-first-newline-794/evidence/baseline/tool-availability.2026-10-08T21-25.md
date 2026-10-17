# Tool availability (P0-T3)

Timestamp: 2026-10-09T06-51
Command: sh -c 'command -v bats kcov shfmt shellcheck gh'
EXIT_CODE: 0
Output Summary: paths found for shfmt, shellcheck, gh only; bats and kcov not found. BASH_VERSION under sh is non-empty (5.2.37(1)-release).

Output:
/c/Users/DanMoisan/AppData/Local/Microsoft/WinGet/Packages/mvdan.shfmt_Microsoft.Winget.Source_8wekyb3d8bbwe/shfmt
/c/Users/DanMoisan/AppData/Local/Microsoft/WinGet/Packages/koalaman.shellcheck_Microsoft.Winget.Source_8wekyb3d8bbwe/shellcheck
/c/Program Files/GitHub CLI/gh

(Observed via the Bash tool as a plain `command -v` invocation; the same tools resolve under `sh -c`.)

Command: sh -c 'echo "${BASH_VERSION-}"'
EXIT_CODE: 0
Output: 5.2.37(1)-release

BATS: absent
KCOV: absent
SHFMT: present
SHELLCHECK: present
GH: present
SH-IS-BASH: yes
