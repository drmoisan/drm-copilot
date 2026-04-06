"""Promote a potential feature file to a GitHub issue using the gh CLI."""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, Protocol

from dev_tools.potential_to_issue_content import (
    BUG_SECTION_HEADINGS,
    PLACEHOLDER,
    build_body,
    build_bug_body,
    build_minor_audit_body,
    extract_last_updated,
    get_feature_name,
    get_feature_path,
    get_section,
    normalize_smart_punctuation,
    parse_issue_reference,
    update_metadata_lines,
)
from dev_tools.prompt_mode_contract import (
    ACCEPTED_WORK_MODES,
    normalize_requested_work_mode,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable

PROMOTION_TYPES = ("epic", "feature", "refactor", "bug")
WORK_MODES = ACCEPTED_WORK_MODES
TITLE_PREFIXES = {
    "epic": "Epic",
    "feature": "Feature",
    "refactor": "Refactor",
    "bug": "Bug",
}
FEATURE_LABEL_COLOR = "0e8a16"
FEATURE_LABEL_DESCRIPTION = "Feature work"


class PromotionError(Exception):
    """Raised when a promotion precondition fails."""


@dataclass
class GhResult:
    output: list[str]
    exit_code: int


class GhClient(Protocol):
    def is_authenticated(self) -> bool: ...

    def issue_create(self, title: str, body: str, promotion_type: str) -> GhResult: ...

    def ensure_label(self, label: str) -> GhResult: ...

    def issue_view(self, issue_number: str) -> GhResult: ...


@dataclass
class RealGhClient(GhClient):
    gh_path: str | None = None

    def __post_init__(self) -> None:
        if self.gh_path is None:
            self.gh_path = shutil.which("gh")
        if not self.gh_path:
            raise FileNotFoundError(
                "gh CLI not found on PATH. Install gh and authenticate first."
            )

    def is_authenticated(self) -> bool:
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

    def ensure_label(self, label: str) -> GhResult:
        args = [
            "label",
            "create",
            label,
            "--color",
            FEATURE_LABEL_COLOR,
            "--description",
            FEATURE_LABEL_DESCRIPTION,
        ]
        return self._run(args)

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
    def resolve_path(self, path_str: str) -> Path: ...

    def exists(self, path: Path) -> bool: ...

    def read_text(self, path: Path) -> str: ...

    def write_text(self, path: Path, content: str) -> None: ...

    def write_lines(self, path: Path, lines: Iterable[str]) -> None: ...

    def ensure_dir(self, path: Path) -> None: ...

    def move(self, src: Path, dest: Path) -> None: ...


@dataclass
class RealFileSystem(FileSystem):
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
    exit_code: int
    messages: list[str]
    destination: Path | None = None


def _resolve_workspace() -> Path:
    return Path.cwd()


def _default(message: str) -> None:
    print(message)


def _is_missing_label_failure(output: list[str], label: str) -> bool:
    """Return whether gh output reports a missing-label create failure."""
    expected_fragment = f"could not add label: '{label}' not found"
    return any(expected_fragment in line.lower() for line in output)


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

    try:
        selected_mode = normalize_requested_work_mode(work_mode, promotion_type)
    except ValueError as exc:
        raise PromotionError(str(exc)) from exc
    fallback_reason = ""

    if selected_mode == "minor-audit":
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
            selected_mode,
            problem,
            implementation_intent,
            acceptance_criteria,
            dependencies_risks,
            verification_steps,
            evidence_checklist,
            relative_path,
        )
    elif promotion_type == "bug":
        bug_sections = {
            heading: get_section(content, heading) or PLACEHOLDER
            for heading in BUG_SECTION_HEADINGS
        }
        body = build_bug_body(selected_mode, bug_sections, relative_path)
    else:
        problem = get_section(content, "Problem / Why") or PLACEHOLDER
        behavior = get_section(content, "Proposed Behavior") or PLACEHOLDER
        criteria = (
            get_section(content, "Acceptance Criteria (early draft)") or PLACEHOLDER
        )
        constraints = get_section(content, "Constraints & Risks") or PLACEHOLDER
        tests = get_section(content, "Test Conditions to Consider") or PLACEHOLDER
        body = build_body(
            selected_mode,
            problem,
            behavior,
            criteria,
            constraints,
            tests,
            relative_path,
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

    # Recover only from the known missing-label failure for the selected
    # promotion label so other gh errors still fail fast with their original
    # output.
    if _is_missing_label_failure(create_result.output, promotion_type):
        _emit("Missing promotion label detected; ensuring label exists and retrying.")
        ensure_label_result = gh_client.ensure_label(promotion_type)
        for line in ensure_label_result.output:
            _emit(line)
        if ensure_label_result.exit_code == 0:
            create_result = gh_client.issue_create(issue_title, body, promotion_type)

    if create_result.exit_code != 0:
        output_lines = create_result.output or [
            f"gh CLI exited with code {create_result.exit_code}"
        ]
        for line in output_lines:
            _emit(line)
        return PromotionOutcome(exit_code=create_result.exit_code, messages=messages)

    for line in create_result.output:
        _emit(line)

    issue_url, issue_number = parse_issue_reference(create_result.output)

    last_updated: str | None = None
    if issue_number:
        view_result = gh_client.issue_view(issue_number)
        if view_result.exit_code == 0 and view_result.output:
            last_updated = extract_last_updated("\n".join(view_result.output))

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
        help=(
            "Work mode routing. Canonical values are minor-audit, full-feature, "
            "and full-bug; full is accepted as a backward-compatible alias."
        ),
    )
    return parser.parse_args()


def main() -> None:
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
