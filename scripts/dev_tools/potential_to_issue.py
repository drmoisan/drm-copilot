"""Promote a potential feature file to a GitHub issue using the gh CLI."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING, Protocol

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable

PLACEHOLDER = "(not provided in potential file)"
ISSUE_URL_PATTERN = re.compile(r"https?://\S+/issues/(\d+)")
PROMOTION_TYPES = ("epic", "feature", "refactor", "bug")
WORK_MODES = ("minor-audit", "full")
TITLE_PREFIXES = {
    "epic": "Epic",
    "feature": "Feature",
    "refactor": "Refactor",
    "bug": "Bug",
}
BUG_SECTION_HEADINGS = [
    "Summary",
    "Environment",
    "Steps to Reproduce",
    "Expected Behavior",
    "Actual Behavior",
    "Logs / Screenshots",
    "Impact / Severity",
]
SMART_PUNCTUATION_MAP = {
    "\u201c": '"',
    "\u201d": '"',
    "\u2018": "'",
    "\u2019": "'",
    "\u2013": "-",
    "\u2014": "-",
    "\u00a0": " ",
}


class PromotionError(Exception):
    """Raised when a promotion precondition fails."""


@dataclass
class GhResult:
    """Capture gh command execution output and exit status.

    Purpose:
        Provide a typed transport object for gh subprocess results used by promotion
        workflows.

    Usage:
        Created by gh client implementations and consumed by promotion logic.

    Flow:
        Store output lines and integer exit code from a single gh invocation.

    Invariants / Constraints:
        `exit_code` is the process return code for the related command.

    Side Effects:
        None.

    Attributes:
        output (list[str]): Combined stdout/stderr lines from gh command execution.
        exit_code (int): Process return code from the gh command.
    """

    output: list[str]
    exit_code: int


class GhClient(Protocol):
    def is_authenticated(self) -> bool: ...

    def issue_create(self, title: str, body: str, promotion_type: str) -> GhResult: ...

    def issue_view(self, issue_number: str) -> GhResult: ...


@dataclass
class RealGhClient(GhClient):
    """Invoke the GitHub CLI and translate results into typed records.

    Purpose:
        Provide the concrete gh-backed implementation for issue creation/view flows.

    Usage:
        Instantiated by `promote_potential` unless a fake client is injected.

    Flow:
        Resolve `gh` path, validate authentication, execute commands, and return
        `GhResult` payloads.

    Invariants / Constraints:
        `gh_path` must resolve to an executable before command execution.

    Side Effects:
        Executes subprocess calls to the local `gh` CLI.

    Attributes:
        gh_path (str | None): Resolved gh executable path.
    """

    gh_path: str | None = None

    def __post_init__(self) -> None:
        if self.gh_path is None:
            self.gh_path = shutil.which("gh")
        if not self.gh_path:
            raise FileNotFoundError(
                "gh CLI not found on PATH. Install gh and authenticate first."
            )

    def is_authenticated(self) -> bool:
        """Check if gh CLI is authenticated by running gh auth status."""
        gh_exe = self.gh_path
        if gh_exe is None:
            return False

        result = subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
            [gh_exe, "auth", "status"],
            capture_output=True,
            check=False,
        )
        return result.returncode == 0

    def _run(self, args: list[str], body: str | None = None) -> GhResult:
        gh_exe = self.gh_path
        if gh_exe is None:
            raise RuntimeError("gh CLI path was not resolved")

        proc: subprocess.CompletedProcess[str] = (
            subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
                [gh_exe, *args],
                input=body,
                text=True,
                encoding="utf-8",
                capture_output=True,
                check=False,
            )
        )
        stdout = proc.stdout or ""
        stderr = proc.stderr or ""
        combined = stdout + stderr
        return GhResult(output=combined.splitlines(), exit_code=int(proc.returncode))

    def issue_create(self, title: str, body: str, promotion_type: str) -> GhResult:
        args = [
            "issue",
            "create",
            "--title",
            title,
            "--body-file",
            "-",
            "--label",
            promotion_type,
        ]
        return self._run(args, body)

    def issue_view(self, issue_number: str) -> GhResult:
        args = [
            "issue",
            "view",
            issue_number,
            "--json",
            "number,title,url,author,updatedAt",
        ]
        return self._run(args)


class FileSystem(Protocol):
    """Define filesystem operations required by promotion workflows.

    Purpose:
        Provide an abstraction boundary for filesystem interactions.

    Usage:
        Implemented by `RealFileSystem` and test doubles.

    Flow:
        Expose read/write/move/exists primitives used by promotion orchestration.

    Invariants / Constraints:
        Implementations must preserve UTF-8 behavior for markdown IO.

    Side Effects:
        Implementations may perform local disk IO.

    Attributes:
        None.
    """

    def resolve_path(self, path_str: str) -> Path: ...

    def exists(self, path: Path) -> bool: ...

    def read_text(self, path: Path) -> str: ...

    def write_text(self, path: Path, content: str) -> None: ...

    def write_lines(self, path: Path, lines: Iterable[str]) -> None: ...

    def ensure_dir(self, path: Path) -> None: ...

    def move(self, src: Path, dest: Path) -> None: ...


@dataclass
class RealFileSystem(FileSystem):
    """Concrete filesystem adapter using local disk operations.

    Purpose:
        Execute production file operations behind the `FileSystem` protocol.

    Usage:
        Used by default in promotion workflows and replaceable in tests.

    Flow:
        Resolve paths, read/write text, ensure directories, and move files.

    Invariants / Constraints:
        Paths are treated as UTF-8 text files when reading/writing markdown content.

    Side Effects:
        Reads/writes/moves files on the local filesystem.

    Attributes:
        None.
    """

    def resolve_path(self, path_str: str) -> Path:
        return Path(path_str).expanduser().resolve()

    def exists(self, path: Path) -> bool:
        return path.exists()

    def read_text(self, path: Path) -> str:
        return path.read_text(encoding="utf-8")

    def write_text(self, path: Path, content: str) -> None:
        path.write_text(content, encoding="utf-8")

    def write_lines(self, path: Path, lines: Iterable[str]) -> None:
        joined = "\n".join(lines)
        path.write_text(joined, encoding="utf-8")

    def ensure_dir(self, path: Path) -> None:
        path.mkdir(parents=True, exist_ok=True)

    def move(self, src: Path, dest: Path) -> None:
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(src), str(dest))


@dataclass
class PromotionOutcome:
    """Represent the final outcome of a potential-promotion execution.

    Purpose:
        Return deterministic status, emitted messages, and destination metadata.

    Usage:
        Returned by `promote_potential` and consumed by CLI entry points/tests.

    Flow:
        Capture run status and destination path after move operations complete.

    Invariants / Constraints:
        `exit_code` reflects the terminal success/failure result for the operation.

    Side Effects:
        None.

    Attributes:
        exit_code (int): Final process-style exit code.
        messages (list[str]): Ordered emitted status lines.
        destination (Path | None): Promoted file destination when successful.
    """

    exit_code: int
    messages: list[str]
    destination: Path | None = None


def _resolve_workspace() -> Path:
    """Resolve repository workspace root from script location.

    Purpose:
        Provide a stable workspace root for relative path computations.

    Args:
        None.

    Returns:
        Path: Repository root path.

    Raises:
        None.

    Side Effects:
        None.
    """

    return Path(__file__).resolve().parents[2]


def _strip_potential_marker(value: str) -> str:
    """Remove `(Potential...)` suffix markers from heading values.

    Purpose:
        Normalize feature names derived from potential-file headings.

    Args:
        value (str): Raw heading text.

    Returns:
        str: Cleaned heading text without potential marker noise.

    Raises:
        None.

    Side Effects:
        None.
    """

    cleaned = re.sub(r"\s*\(Potential[^)]*\)", "", value, flags=re.IGNORECASE).strip()
    return cleaned or value.strip()


def get_feature_name(content: str, file_path: Path) -> str:
    """Derive feature name from markdown heading or filename fallback.

    Purpose:
        Produce a deterministic feature name for issue title/path generation.

    Args:
        content (str): Potential markdown content.
        file_path (Path): Source potential file path.

    Returns:
        str: Best-available feature name.

    Raises:
        None.

    Side Effects:
        None.
    """

    heading_match = re.search(r"^\s*#\s+(.+)$", content, flags=re.MULTILINE)
    if heading_match:
        feature_name = _strip_potential_marker(heading_match.group(1))
        if feature_name:
            return feature_name

    name = file_path.name
    return name[:-3] if name.lower().endswith(".md") else name


def get_feature_path(feature_name: str) -> str:
    """Convert feature name into safe path token.

    Purpose:
        Generate deterministic folder slug segments from feature names.

    Args:
        feature_name (str): Human-readable feature name.

    Returns:
        str: Sanitized token suitable for folder naming.

    Raises:
        None.

    Side Effects:
        None.
    """

    replaced = re.sub(r"\s+", "_", feature_name)
    return re.sub(r"[^A-Za-z0-9_-]", "", replaced)


def get_section(content: str, heading: str) -> str:
    """Extract markdown section body for a top-level `##` heading.

    Purpose:
        Reuse structured section extraction across issue body builders.

    Args:
        content (str): Full markdown content.
        heading (str): Section heading name without `##`.

    Returns:
        str: Trimmed section body or empty string when missing.

    Raises:
        None.

    Side Effects:
        None.
    """

    escaped = re.escape(heading)
    pattern = rf"^##\s+{escaped}\s*\r?\n(.*?)(?=^##\s+|\Z)"
    match = re.search(pattern, content, flags=re.MULTILINE | re.DOTALL)
    if not match:
        return ""
    return match.group(1).strip()


def build_body(
    problem: str,
    behavior: str,
    criteria: str,
    constraints: str,
    tests: str,
    relative_path: str,
) -> str:
    """Construct the standard full-mode issue body.

    Purpose:
        Assemble deterministic full workflow issue content from extracted sections.

    Args:
        problem (str): Problem/why section text.
        behavior (str): Proposed behavior section text.
        criteria (str): Acceptance criteria section text.
        constraints (str): Constraints and risks section text.
        tests (str): Test conditions section text.
        relative_path (str): Source potential file path relative to workspace.

    Returns:
        str: Fully rendered issue body markdown.

    Raises:
        None.

    Side Effects:
        None.
    """

    return (
        f"## Problem / Why\n{problem}\n\n"
        f"## Proposed Behavior\n{behavior}\n\n"
        f"## Acceptance Criteria\n{criteria}\n\n"
        f"## Constraints & Risks\n{constraints}\n\n"
        f"## Test Conditions\n{tests}\n\n"
        f"## Source\nFrom: {relative_path}\n"
    )


def build_bug_body(sections: dict[str, str], relative_path: str) -> str:
    """Construct the bug issue body from canonical bug section headings.

    Purpose:
        Render bug issue content in a predictable section order.

    Args:
        sections (dict[str, str]): Heading-to-content mapping.
        relative_path (str): Source potential file path relative to workspace.

    Returns:
        str: Rendered bug issue body markdown.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Build bug issue sections in template order to preserve heading sequence.
    parts = [f"## {heading}\n{sections[heading]}" for heading in BUG_SECTION_HEADINGS]
    parts.append(f"## Source\nFrom: {relative_path}")
    return "\n\n".join(parts) + "\n"


def evaluate_minor_audit_eligibility(content: str) -> tuple[bool, str]:
    """Evaluate deterministic eligibility for minor-audit mode."""

    lower = content.lower()
    if "bootstrapped" in lower or "pre-cooked" in lower:
        return True, "eligible: bootstrapped/pre-cooked"

    production_files = len(
        re.findall(r"^\s*-\s*(?:production\s+)?file\s*:", content, flags=re.MULTILINE)
    )
    has_low_risk = "low integration risk" in lower or "risk: low" in lower
    if production_files <= 3 and has_low_risk:
        return True, "eligible: <=3 production files and low integration risk"
    if production_files > 3:
        return False, "fallback: production file count exceeds 3"
    return False, "fallback: missing low integration risk signal"


def build_minor_audit_body(
    problem: str,
    implementation_intent: str,
    acceptance_criteria: str,
    dependencies_risks: str,
    verification_steps: str,
    evidence_checklist: str,
    relative_path: str,
) -> str:
    """Build required issue sections for the minor-audit mode."""

    return (
        f"## Problem / Why\n{problem}\n\n"
        f"## Implementation Intent\n{implementation_intent}\n\n"
        f"## Acceptance Criteria\n{acceptance_criteria}\n\n"
        f"## Dependencies / Risks\n{dependencies_risks}\n\n"
        f"## Verification Steps\n{verification_steps}\n\n"
        f"## Evidence Checklist\n{evidence_checklist}\n\n"
        f"## Source\nFrom: {relative_path}\n"
    )


def parse_issue_reference(output: Iterable[str]) -> tuple[str | None, str | None]:
    """Parse created issue URL/number from gh output lines.

    Purpose:
        Extract issue metadata required for post-create file updates.

    Args:
        output (Iterable[str]): gh command output lines.

    Returns:
        tuple[str | None, str | None]: (issue_url, issue_number) when found.

    Raises:
        None.

    Side Effects:
        None.
    """

    text = "\n".join(output)
    match = ISSUE_URL_PATTERN.search(text)
    if not match:
        return None, None
    return match.group(0), match.group(1)


def _extract_last_updated(issue_json: str) -> str | None:
    """Extract issue updated date from gh JSON payload.

    Purpose:
        Convert gh issue-view JSON into an ISO date for metadata stamping.

    Args:
        issue_json (str): JSON string from `gh issue view --json ...`.

    Returns:
        str | None: ISO date (`YYYY-MM-DD`) when parse succeeds.

    Raises:
        None.

    Side Effects:
        None.
    """

    try:
        data = json.loads(issue_json)
    except json.JSONDecodeError:
        return None

    updated_raw = data.get("updatedAt")
    if not isinstance(updated_raw, str):
        return None

    try:
        dt = datetime.fromisoformat(updated_raw.replace("Z", "+00:00"))
    except ValueError:
        return None
    return dt.date().isoformat()


def _find_meta_end(lines: list[str]) -> int:
    """Locate insertion point where header metadata block ends.

    Purpose:
        Keep metadata updates above markdown content sections.

    Args:
        lines (list[str]): Markdown document lines.

    Returns:
        int: Index where metadata entries should stop being inserted.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Scan for the first section header to determine where metadata ends.
    for idx, line in enumerate(lines):
        if line.lstrip().startswith("## "):
            return idx
    return len(lines)


def normalize_smart_punctuation(text: str) -> str:
    """
    Replace common smart quotes/dashes/non-breaking spaces with ASCII equivalents.

    Purpose:
        GitHub issue bodies/titles can mis-render smart punctuation copied from
        source files; normalize to plain ASCII before submission.

    Args:
        text (str): Arbitrary text to normalize.

    Returns:
        str: Text with smart punctuation replaced by ASCII characters.

    Side Effects:
        None.
    """

    return text.translate(str.maketrans(SMART_PUNCTUATION_MAP))


def _set_line_value(lines: list[str], label: str, value: str, meta_end: int) -> int:
    """Set or insert a metadata list line and return updated boundary index.

    Purpose:
        Apply deterministic metadata updates without duplicating labels.

    Args:
        lines (list[str]): Markdown document lines.
        label (str): Metadata label (for `- Label: value`).
        value (str): Value to assign.
        meta_end (int): Current metadata insertion boundary.

    Returns:
        int: Updated metadata insertion boundary index.

    Raises:
        None.

    Side Effects:
        Mutates `lines` in place.
    """

    pattern = re.compile(rf"^- {re.escape(label)}:")
    for idx, line in enumerate(lines):
        # Update existing metadata entry before inserting a new line.
        if pattern.match(line):
            lines[idx] = f"- {label}: {value}"
            return meta_end
    lines.insert(meta_end, f"- {label}: {value}")
    return meta_end + 1


def update_metadata_lines(
    lines: list[str],
    feature_name: str,
    issue_number: str,
    issue_url: str,
    last_updated: str | None,
    feature_path: str,
) -> list[str]:
    """Apply issue metadata updates to potential markdown lines.

    Purpose:
        Keep promoted potential files synchronized with created issue metadata.

    Args:
        lines (list[str]): Original markdown lines.
        feature_name (str): Feature heading text.
        issue_number (str): Created issue number.
        issue_url (str): Created issue URL.
        last_updated (str | None): Optional issue updated date.
        feature_path (str): Active feature path token used in status line.

    Returns:
        list[str]: Updated markdown lines with metadata edits applied.

    Raises:
        None.

    Side Effects:
        Mutates list content used for file write-back.
    """

    if lines:
        lines[0] = f"# {feature_name} (Issue #{issue_number})"

    meta_end = _find_meta_end(lines)
    meta_end = _set_line_value(lines, "Issue", f"#{issue_number}", meta_end)
    meta_end = _set_line_value(lines, "Issue URL", issue_url, meta_end)
    if last_updated:
        meta_end = _set_line_value(lines, "Last Updated", last_updated, meta_end)
    status_value = (
        f"Promoted -> docs/features/active/{feature_path}/ (Issue #{issue_number})"
    )
    _set_line_value(lines, "Status", status_value, meta_end)
    return lines


def _default(message: str) -> None:
    """Default emitter that prints messages to stdout.

    Purpose:
        Provide a fallback logger callback for CLI-visible status messages.

    Args:
        message (str): Message line to emit.

    Returns:
        None.

    Raises:
        None.

    Side Effects:
        Writes to standard output.
    """

    print(message)


def promote_potential(
    potential_path: str,
    promotion_type: str = "feature",
    *,
    fs: FileSystem | None = None,
    gh: GhClient | None = None,
    workspace: Path | None = None,
    work_mode: str = "full",
    emit: Callable[[str], None] = _default,
) -> PromotionOutcome:
    """Promote a potential file to a GitHub issue and archive the source.

    Purpose:
        Orchestrate validation, issue body generation, gh issue creation, metadata
        stamping, and promoted-file relocation.

    Args:
        potential_path (str): Path to potential markdown file.
        promotion_type (str): One of supported promotion labels.
        fs (FileSystem | None): Optional filesystem adapter override.
        gh (GhClient | None): Optional gh client adapter override.
        workspace (Path | None): Optional workspace root override.
        work_mode (str): Work-mode routing (`minor-audit` or `full`).
        emit (Callable[[str], None]): Status message emitter callback.

    Returns:
        PromotionOutcome: Final exit code, emitted messages, and destination path.

    Raises:
        PromotionError: When validation or promotion preconditions fail.
        RuntimeError: When gh path is unavailable in command execution.

    Side Effects:
        Executes gh CLI subprocesses and mutates filesystem state.
    """

    if promotion_type not in PROMOTION_TYPES:
        raise PromotionError(f"Invalid promotion type: {promotion_type}")
    if work_mode not in WORK_MODES:
        raise PromotionError(f"Invalid work mode: {work_mode}")

    filesystem = fs or RealFileSystem()
    gh_client = gh or RealGhClient()
    workspace_path = workspace or _resolve_workspace()

    if not gh_client.is_authenticated():
        raise PromotionError(
            "GitHub CLI is not authenticated. Run 'gh auth login' first."
        )

    resolved = filesystem.resolve_path(potential_path)
    if not filesystem.exists(resolved):
        raise PromotionError(f"Potential file not found: {potential_path}")

    content = filesystem.read_text(resolved)
    if not content.strip():
        raise PromotionError(f"Potential file is empty: {resolved}")

    feature_name = get_feature_name(content, resolved)
    feature_path = get_feature_path(feature_name)
    prefix = TITLE_PREFIXES.get(promotion_type, "Feature")
    issue_title = normalize_smart_punctuation(f"{prefix}: {feature_name}")

    def _relative_path() -> str:
        try:
            return os.path.relpath(resolved, workspace_path)
        except ValueError:
            return str(resolved)

    relative_path = Path(_relative_path()).as_posix()

    selected_mode = "full"
    fallback_reason = ""
    if work_mode == "minor-audit" and promotion_type != "bug":
        eligible, eligibility_reason = evaluate_minor_audit_eligibility(content)
        if eligible:
            selected_mode = "minor-audit"
        else:
            fallback_reason = eligibility_reason

    # Route issue-body generation based on promotion type and eligible work mode.
    if promotion_type == "bug":
        bug_sections = {
            heading: get_section(content, heading) or PLACEHOLDER
            for heading in BUG_SECTION_HEADINGS
        }
        body = build_bug_body(bug_sections, relative_path)
    elif selected_mode == "minor-audit":
        problem = get_section(content, "Problem / Why") or PLACEHOLDER
        implementation_intent = get_section(content, "Proposed Behavior") or PLACEHOLDER
        acceptance_criteria = (
            get_section(content, "Acceptance Criteria (early draft)") or PLACEHOLDER
        )
        dependencies_risks = get_section(content, "Constraints & Risks") or PLACEHOLDER
        verification_steps = (
            get_section(content, "Test Conditions to Consider") or PLACEHOLDER
        )
        evidence_checklist = get_section(content, "Evidence Checklist")
        if not evidence_checklist:
            evidence_checklist = (
                "- [ ] Baseline\n- [ ] End-state\n- [ ] Targeted verification"
            )
        body = build_minor_audit_body(
            problem,
            implementation_intent,
            acceptance_criteria,
            dependencies_risks,
            verification_steps,
            evidence_checklist,
            relative_path,
        )
    else:
        problem = get_section(content, "Problem / Why") or PLACEHOLDER
        behavior = get_section(content, "Proposed Behavior") or PLACEHOLDER
        criteria = (
            get_section(content, "Acceptance Criteria (early draft)") or PLACEHOLDER
        )
        constraints = get_section(content, "Constraints & Risks") or PLACEHOLDER
        tests = get_section(content, "Test Conditions to Consider") or PLACEHOLDER
        body = build_body(
            problem, behavior, criteria, constraints, tests, relative_path
        )
    body = normalize_smart_punctuation(body)

    messages: list[str] = []

    def _emit(msg: str) -> None:
        messages.append(msg)
        emit(msg)

    _emit(f"Selected mode: {selected_mode}")
    if fallback_reason:
        _emit(f"Fallback reason: {fallback_reason}")
    _emit(f"Creating issue: {issue_title} (label: {promotion_type})")
    create_result = gh_client.issue_create(issue_title, body, promotion_type)

    if create_result.exit_code != 0:
        output_lines = create_result.output or [
            f"gh CLI exited with code {create_result.exit_code}"
        ]
        for line in output_lines:
            _emit(line)
        return PromotionOutcome(exit_code=create_result.exit_code, messages=messages)

    # Emit every gh output line to preserve context for callers.
    for line in create_result.output:
        _emit(line)

    issue_url, issue_number = parse_issue_reference(create_result.output)

    last_updated: str | None = None
    if issue_number:
        view_result = gh_client.issue_view(issue_number)
        if view_result.exit_code == 0 and view_result.output:
            last_updated = _extract_last_updated("\n".join(view_result.output))

    if issue_number and issue_url:
        lines = content.splitlines()
        updated_lines = update_metadata_lines(
            lines,
            feature_name,
            issue_number,
            issue_url,
            last_updated,
            feature_path,
        )
        filesystem.write_lines(resolved, updated_lines)
        _emit(f"Updated potential file with issue metadata: {resolved}")

    promoted_dir = workspace_path / "docs" / "features" / "potential" / "promoted"
    filesystem.ensure_dir(promoted_dir)
    dest_path = promoted_dir / resolved.name
    filesystem.move(resolved, dest_path)
    _emit(f"Moved potential file to promoted folder: {dest_path}")

    return PromotionOutcome(exit_code=0, messages=messages, destination=dest_path)


def parse_args() -> argparse.Namespace:
    """Parse CLI arguments for potential-promotion command execution.

    Purpose:
        Define and parse deterministic CLI inputs for promotion scripts.

    Args:
        None.

    Returns:
        argparse.Namespace: Parsed CLI arguments.

    Raises:
        SystemExit: Raised by argparse on invalid CLI input.

    Side Effects:
        Reads process CLI argv through argparse.
    """

    parser = argparse.ArgumentParser(
        description="Create a GitHub issue from a potential feature file using gh CLI.",
    )
    parser.add_argument(
        "--potential-path",
        required=True,
        help="Path to the potential feature markdown file.",
    )
    parser.add_argument(
        "--promotion-type",
        choices=PROMOTION_TYPES,
        default="feature",
        help="Promotion type label to attach to the issue.",
    )
    parser.add_argument(
        "--work-mode",
        choices=WORK_MODES,
        default="full",
        help="Work mode routing for full vs minor-audit issue body generation.",
    )
    return parser.parse_args()


def main() -> None:
    """CLI entry point for potential-to-issue promotion.

    Purpose:
        Execute argument parsing, run promotion, and return process-style exit code.

    Args:
        None.

    Returns:
        None.

    Raises:
        SystemExit: Raised with success/error exit code for CLI execution.

    Side Effects:
        Invokes promotion workflow and prints status/error messages.
    """

    args = parse_args()
    try:
        outcome = promote_potential(
            potential_path=args.potential_path,
            promotion_type=args.promotion_type,
            work_mode=args.work_mode,
        )
    except (PromotionError, FileNotFoundError) as exc:
        print(str(exc))
        raise SystemExit(1) from exc
    except subprocess.SubprocessError as exc:  # pragma: no cover
        print(f"gh CLI execution failed: {exc}")
        raise SystemExit(1) from exc

    raise SystemExit(outcome.exit_code)


if __name__ == "__main__":
    main()
