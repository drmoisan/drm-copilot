"""Repository-aware integrity checks for execution-ready epic plans."""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import TYPE_CHECKING, Any, Protocol, cast

from scripts.dev_tools.epic_kickoff_contract import (
    ParsedEpicKickoff,
    parse_epic_kickoff,
)
from scripts.dev_tools.epic_planner_git_integrity import (
    GitReadinessRepository,
    ReadinessGitRepository,
    validate_committed_file,
    validate_planning_git_integrity,
)
from scripts.dev_tools.epic_planner_launch_evidence import (
    validate_epic_planner_launch_evidence,
)

if TYPE_CHECKING:
    from scripts.dev_tools.pr_context.git import CommandRunner

ALL_CLEAR = "PREFLIGHT: ALL CLEAR"


class ReadinessFileSystem(Protocol):
    """Read-only filesystem operations needed by the readiness gate."""

    def is_file(self, path: Path) -> bool: ...

    def is_dir(self, path: Path) -> bool: ...

    def read_text(self, path: Path) -> str: ...

    def read_bytes(self, path: Path) -> bytes: ...

    def glob(self, directory: Path, pattern: str) -> list[Path]: ...


class LocalReadinessFileSystem:
    """Production readiness filesystem backed by pathlib."""

    def is_file(self, path: Path) -> bool:
        """Return whether the path is a regular file."""

        return path.is_file()

    def is_dir(self, path: Path) -> bool:
        """Return whether the path is a directory."""

        return path.is_dir()

    def read_text(self, path: Path) -> str:
        """Read UTF-8 text from the path."""

        return path.read_text(encoding="utf-8")

    def read_bytes(self, path: Path) -> bytes:
        """Read exact bytes from the path."""

        return path.read_bytes()

    def glob(self, directory: Path, pattern: str) -> list[Path]:
        """Return sorted paths matching the relative glob."""

        return sorted(directory.glob(pattern))


@dataclass(frozen=True)
class EpicReadinessContext:
    """Injected repository context for execution-readiness validation."""

    workspace_root: Path
    artifact_path: Path
    file_system: ReadinessFileSystem
    git: ReadinessGitRepository


def build_epic_readiness_context(
    workspace_root: Path,
    artifact_path: Path,
    *,
    runner: CommandRunner | None = None,
    file_system: ReadinessFileSystem | None = None,
) -> EpicReadinessContext:
    """Build the production readiness context with injectable I/O seams."""

    root = workspace_root.absolute()
    path = artifact_path if artifact_path.is_absolute() else root / artifact_path
    return EpicReadinessContext(
        workspace_root=root,
        artifact_path=path,
        file_system=file_system or LocalReadinessFileSystem(),
        git=GitReadinessRepository(root, runner),
    )


def _relative_path(value: object, *, field: str) -> tuple[str | None, list[str]]:
    """Validate and normalize a safe repository-relative POSIX path."""

    if not isinstance(value, str) or not value.strip():
        return None, [f"{field} must be a non-empty repository-relative path."]
    if "\\" in value:
        return None, [f"{field} must use forward slashes."]
    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts or "." in path.parts:
        return None, [f"{field} must stay within the workspace root."]
    return path.as_posix(), []


def _read_required(
    context: EpicReadinessContext, relative: str, *, label: str
) -> tuple[str | None, list[str]]:
    """Read one required file without allowing I/O exceptions to escape."""

    path = context.workspace_root / Path(relative)
    if not context.file_system.is_file(path):
        return None, [f"Execution readiness requires {label}: {relative}"]
    try:
        return context.file_system.read_text(path), []
    except (OSError, UnicodeError) as exc:
        return None, [f"Execution readiness could not read {label} {relative}: {exc}"]


def _validate_artifact_source(
    state_text: str, context: EpicReadinessContext
) -> list[str]:
    """Bind the supplied text to the canonical checkpoint path under the root."""

    expected = PurePosixPath("artifacts/orchestration/epic-planner-state.json")
    try:
        supplied = context.artifact_path.relative_to(context.workspace_root)
    except ValueError:
        return ["Epic planner artifact path must stay within the workspace root."]
    supplied_posix = PurePosixPath(*supplied.parts).as_posix()
    errors: list[str] = []
    if supplied_posix != expected.as_posix():
        errors.append(
            "Execution-ready epic planner artifact path must be "
            f"{expected.as_posix()!r}."
        )
    artifact_text, read_errors = _read_required(
        context, supplied_posix, label="the epic planner checkpoint"
    )
    errors.extend(read_errors)
    if artifact_text is not None and artifact_text != state_text:
        errors.append("Supplied epic planner text does not match artifact_path bytes.")
    return errors


def _validate_feature_files(
    feature: dict[str, Any], index: int, context: EpicReadinessContext
) -> tuple[str | None, list[str]]:
    """Require the prepared folder, documents, plan, and preflight evidence."""

    prefix = f"Epic planner checkpoint features[{index}]"
    folder, errors = _relative_path(
        feature.get("feature_folder"), field=f"{prefix}.feature_folder"
    )
    plan, plan_errors = _relative_path(
        feature.get("plan_path"), field=f"{prefix}.plan_path"
    )
    errors.extend(plan_errors)
    research_path, research_errors = _relative_path(
        feature.get("research_path"), field=f"{prefix}.research_path"
    )
    errors.extend(research_errors)
    if folder is None or plan is None or research_path is None:
        return plan, errors
    if not (
        folder.startswith("docs/features/active/")
        or folder.startswith("docs/features/completed/")
    ):
        errors.append(
            f"{prefix}.feature_folder must be under docs/features/active or completed."
        )
    folder_path = context.workspace_root / Path(folder)
    if not context.file_system.is_dir(folder_path):
        errors.append(f"Execution readiness requires feature folder: {folder}")
        return plan, errors
    if not (plan == folder or plan.startswith(f"{folder}/")):
        errors.append(f"{prefix}.plan_path must be inside its feature_folder.")
    for name in ("issue.md", "spec.md", "user-story.md"):
        _, file_errors = _read_required(
            context, f"{folder}/{name}", label=f"{prefix} {name}"
        )
        errors.extend(file_errors)
    _, plan_file_errors = _read_required(context, plan, label=f"{prefix} atomic plan")
    errors.extend(plan_file_errors)
    if not (
        research_path.startswith("artifacts/research/")
        or research_path.startswith(f"{folder}/")
    ):
        errors.append(
            f"{prefix}.research_path must be under artifacts/research or its "
            "feature_folder."
        )
    _, research_file_errors = _read_required(
        context, research_path, label=f"{prefix} research evidence"
    )
    errors.extend(research_file_errors)
    evidence_value = feature.get("preflight_evidence_path")
    evidence_paths: list[Path] = []
    if evidence_value is not None:
        evidence, evidence_errors = _relative_path(
            evidence_value, field=f"{prefix}.preflight_evidence_path"
        )
        errors.extend(evidence_errors)
        if evidence is not None:
            if not evidence.startswith(f"{folder}/"):
                errors.append(
                    f"{prefix}.preflight_evidence_path must be inside its "
                    "feature_folder."
                )
            evidence_paths.append(context.workspace_root / Path(evidence))
    else:
        evidence_paths.extend(
            context.file_system.glob(folder_path, "**/*preflight*.md")
        )
    all_clear = False
    for path in evidence_paths:
        if not context.file_system.is_file(path):
            continue
        try:
            all_clear = ALL_CLEAR in context.file_system.read_text(path)
        except (OSError, UnicodeError):
            continue
        if all_clear:
            break
    if not all_clear:
        errors.append(
            f"Execution readiness requires preflight evidence containing "
            f"{ALL_CLEAR!r} under {folder}."
        )
    return plan, errors


def _validate_kickoff_against_state(
    parsed: ParsedEpicKickoff, state: dict[str, Any], *, label: str
) -> list[str]:
    """Cross-check parsed kickoff references and feature rows with planner state."""

    errors: list[str] = []
    slug = state.get("epic_feature_folder")
    if parsed.slug != slug or parsed.invocation_slug != slug:
        errors.append(
            f"{label} kickoff slug and /epic-run slug must match state {slug!r}."
        )
    if parsed.manifest_path != state.get("epic_manifest_path"):
        errors.append(
            f"{label} kickoff manifest reference must match epic_manifest_path."
        )
    if parsed.integration_branch != state.get("integration_branch"):
        errors.append(f"{label} kickoff integration branch must match planner state.")
    expected: list[tuple[object, object, object, object, object]] = []
    features = state.get("features")
    if isinstance(features, list):
        for feature in cast("list[object]", features):
            if isinstance(feature, dict):
                item = cast("dict[str, Any]", feature)
                expected.append(
                    (
                        item.get("issue_num"),
                        item.get("feature_folder"),
                        item.get("wave"),
                        item.get("complexity_band"),
                        item.get("plan_path"),
                    )
                )
    actual = [
        (row.issue_num, row.feature_folder, row.wave, row.complexity, row.plan_path)
        for row in parsed.features
    ]
    if actual != expected:
        errors.append(
            f"{label} kickoff feature table must exactly match planner state "
            "order and values."
        )
    return errors


def validate_epic_readiness_integrity(
    state: dict[str, Any], state_text: str, context: EpicReadinessContext
) -> list[str]:
    """Run repository, kickoff, artifact, and Git readiness checks."""

    errors = _validate_artifact_source(state_text, context)
    slug = state.get("epic_feature_folder")
    if not isinstance(slug, str) or re.fullmatch(r"[a-z0-9][a-z0-9-]*", slug) is None:
        return [*errors, "Epic planner checkpoint epic_feature_folder must be a slug."]
    expected_manifest = f"docs/features/epics/{slug}/epic.md"
    if state.get("epic_manifest_path") != expected_manifest:
        errors.append(
            f"Execution-ready epic_manifest_path must be {expected_manifest!r}."
        )
    expected_branch = f"epic/{slug}-integration"
    if state.get("integration_branch") != expected_branch:
        errors.append(
            f"Execution-ready integration_branch must be {expected_branch!r}."
        )
    manifest_text, manifest_errors = _read_required(
        context, expected_manifest, label="the epic manifest"
    )
    errors.extend(manifest_errors)
    ignored = state.get("kickoff_prompt_path")
    ignored_path, ignored_path_errors = _relative_path(
        ignored, field="Epic planner checkpoint kickoff_prompt_path"
    )
    errors.extend(ignored_path_errors)
    durable_path = f"docs/features/epics/{slug}/epic-kickoff.md"
    durable_text, durable_errors = _read_required(
        context, durable_path, label="the committed epic kickoff"
    )
    errors.extend(durable_errors)
    ignored_text: str | None = None
    if ignored_path is not None:
        ignored_text, ignored_errors = _read_required(
            context, ignored_path, label="the ignored epic kickoff"
        )
        errors.extend(ignored_errors)
    parsed: ParsedEpicKickoff | None = None
    if durable_text is not None:
        parsed, parse_errors = parse_epic_kickoff(durable_text)
        errors.extend(parse_errors)
        if parsed is not None:
            errors.extend(
                _validate_kickoff_against_state(parsed, state, label="Committed")
            )
    if ignored_text is not None:
        ignored_parsed, ignored_parse_errors = parse_epic_kickoff(ignored_text)
        errors.extend(ignored_parse_errors)
        if ignored_parsed is not None:
            errors.extend(
                _validate_kickoff_against_state(ignored_parsed, state, label="Ignored")
            )
        if durable_text is not None and ignored_text != durable_text:
            errors.append("Committed and ignored epic kickoff bytes must match.")
    plans: list[str] = []
    features = state.get("features")
    if isinstance(features, list):
        for index, item in enumerate(cast("list[object]", features)):
            if not isinstance(item, dict):
                continue
            plan, feature_errors = _validate_feature_files(
                cast("dict[str, Any]", item), index, context
            )
            errors.extend(feature_errors)
            if plan is not None:
                plans.append(plan)
    errors.extend(validate_epic_planner_launch_evidence(state, context))
    if parsed is not None:
        branch = cast("str", state.get("integration_branch"))
        errors.extend(
            validate_planning_git_integrity(state, parsed, plans, context.git)
        )
        errors.extend(
            validate_committed_file(
                context.git, branch, durable_path, label="durable kickoff"
            )
        )
        if manifest_text is not None:
            errors.extend(
                validate_committed_file(
                    context.git, branch, expected_manifest, label="epic manifest"
                )
            )
    return errors
