# Phase 0 — Python Source Signatures (F1 Port Targets)

Timestamp: 2026-06-25T22-33

Files Read:
- scripts/dev_tools/prompt_mode_contract.py
- scripts/dev_tools/json_config.py
- scripts/dev_tools/markdown_label_formatter.py
- scripts/dev_tools/pr_context/git.py
- scripts/dev_tools/pr_context/models.py

## Signatures

### prompt_mode_contract.py
- Constants:
  - `CANONICAL_WORK_MODES = ("minor-audit", "full-feature", "full-bug")`
  - `LEGACY_FULL_MODE = "full"`
  - `ACCEPTED_WORK_MODES = (*CANONICAL_WORK_MODES, LEGACY_FULL_MODE)`
- `normalize_requested_work_mode(requested_mode: str, promotion_type: str) -> str`
  - raises ValueError "work_mode must be one of: minor-audit, full-feature, full-bug, full"
  - minor-audit returned unchanged
  - legacy "full" -> "full-bug" if promotion_type=="bug" else "full-feature"
  - raises "full-bug may only be used with bug work" when full-bug and not bug
  - raises "full-feature may not be used with bug work" when full-feature and bug
- `parse_issue_work_mode(issue_content: str) -> tuple[str | None, bool]`
  - valid regex: `(?im)^-\s*Work Mode:\s*(minor-audit|full-feature|full-bug|full)\s*$`
  - malformed regex: `(?im)^-\s*Work Mode:\s*(.+)\s*$`
  - returns (mode, False) on valid; (None, malformed_detected) otherwise
- `resolve_selected_work_mode(issue_content: str | None) -> str`
  - None -> "full-feature"; valid legacy "full" -> "full-feature"; valid -> that mode; else "full-feature"
- `build_fallback_reason(issue_content: str | None) -> str`
  - None -> "issue.md missing; fail closed to full-feature"
  - valid legacy full -> "issue.md Work Mode marker uses legacy full; normalized to full-feature"
  - valid canonical -> "none"
  - malformed -> "issue.md Work Mode marker malformed; fail closed to full-feature"
  - missing -> "issue.md Work Mode marker missing; fail closed to full-feature"

### json_config.py
- `GOVERNED_GLOBS = ("scripts/**/*.json", "docs/**/*.json", "examples/**/*.json")`
- `EXCLUDE_GLOBS = ("data/**", "artifacts/**", "htmlcov/**", "coverage*/**", "**/node_modules/**", ".venv", ".venv/**", "**/.venv", "**/.venv/**")`
- `iter_governed_files(root: Path | str) -> Iterable[Path]`
  - glob includes from GOVERNED_GLOBS; build excluded set from EXCLUDE_GLOBS
  - skip path if any parent in excluded, or path in excluded; yield only if path.is_file()

### markdown_label_formatter.py (pure-logic + I/O; CLI glue deferred)
- `LABEL_PREFIXES = ("User:", "GitHub Copilot:")`
- `SEPARATOR_LINE = "---"`
- `is_label_line(line: str) -> bool` — startswith any LABEL_PREFIXES
- `is_separator_line(line: str) -> bool` — stripped == "" or "---"
- `format_label_heading(line: str) -> tuple[str, str]` — partition(":"); heading=`# {label.strip()}:`; trailing=remainder.lstrip()
- `ensure_separator_block(output_lines: list[str]) -> None` — pop trailing blanks; extend ["", "---", ""]
- `prefix_content_line(line: str) -> str` — `> {line}` if line else `>`
- `process_markdown(content: str) -> str` — splitlines; preserve trailing newline
- `read_content(source: Path | None) -> str` — stdin when None else read_text utf-8
- `write_output(content: str, target: Path | None) -> None` — stdout when None else write_text utf-8
- DEFERRED (not ported): parse_args, main, __main__ CLI glue

### pr_context/git.py + models.py (subprocess runner)
- `CommandResult` dataclass: `stdout: str`, `stderr: str`, `code: int`
- `CommandRunner` Protocol: `run(args: Sequence[str], *, cwd: Path | None = None, allow_error: bool = False) -> CommandResult`
- `SubprocessRunner.run(...)`:
  - subprocess.run(args, cwd, capture_output=True, text=True, encoding="utf-8", errors="replace", check=False, shell=False)
  - stdout = (completed.stdout or "").rstrip("\n"); stderr = (completed.stderr or "").rstrip("\n")
  - code = int(completed.returncode)
  - if not allow_error and code != 0: joined = (stdout + "\n" + stderr).strip(); raise RuntimeError(f"{' '.join(args)} failed ({code}): {joined}")
