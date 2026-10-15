# AC-3 check (issue 895)

Timestamp: 2026-10-12T18-05
Command: git grep -n -F -A 1 "GNU find is required" -- .codex/codex-web-setup.sh
EXIT_CODE: 0
Output Summary: One matching comment line (line 29) immediately followed by the find line (line 30) that contains -printf:
.codex/codex-web-setup.sh:29:	# GNU find is required: -printf is a GNU extension, and other find implementations fail with the error hidden by 2>/dev/null.
.codex/codex-web-setup.sh-30-	find "$1" -maxdepth 1 -type f -name '*.sln' -printf '%f\n' 2>/dev/null
