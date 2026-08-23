"""Synchronize packaged customizations from canonical repository surfaces."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Literal, cast

REPO_ROOT = Path(__file__).resolve().parents[2]
CODEX_BUNDLE_ROOT = Path(
    "extensions/drm-copilot/resources/codex-and-agents-customizations"
)
GITHUB_BUNDLE_ROOT = Path("extensions/drm-copilot/resources/customizations/.github")
CLAUDE_BUNDLE_ROOT = Path(
    "extensions/drm-copilot/resources/claude-customizations/.claude"
)
ROUTING_BUNDLE_ROOT = Path("extensions/drm-copilot/resources/config")

Family = Literal["reviewer", "orchestrator", "researcher", "routing"]


@dataclass(frozen=True)
class BundleMapping:
    """Bind one canonical repository surface to one packaged destination."""

    source: Path
    destination: Path
    family: Family


def _mapping(source: str, destination: Path, family: Family) -> BundleMapping:
    """Construct one normalized source-to-bundle mapping."""

    return BundleMapping(Path(source), destination, family)


def _codex_mapping(path: str, family: Family) -> BundleMapping:
    """Map one repository path into the Codex and shared-skills bundle."""

    source = Path(path)
    return _mapping(path, CODEX_BUNDLE_ROOT / source, family)


def _github_mapping(path: str, family: Family) -> BundleMapping:
    """Map one GitHub customization into its packaged GitHub root."""

    source = Path(path)
    return _mapping(path, GITHUB_BUNDLE_ROOT / source.relative_to(".github"), family)


def _claude_mapping(path: str, family: Family) -> BundleMapping:
    """Map one Claude customization into its packaged Claude root."""

    source = Path(path)
    return _mapping(path, CLAUDE_BUNDLE_ROOT / source.relative_to(".claude"), family)


PROFILE_SUFFIXES = ("", "-c1", "-c2", "-c3", "-c3-elevated", "-c4")


def _agent_family_mappings(name: str, family: Family) -> tuple[BundleMapping, ...]:
    """Return base and deployment-profile mappings for one Codex agent family."""

    return tuple(
        _codex_mapping(f".codex/agents/{name}{suffix}.toml", family)
        for suffix in PROFILE_SUFFIXES
    )


def required_mappings() -> tuple[BundleMapping, ...]:
    """Return the complete, exact source-to-bundle mapping contract."""

    reviewer = (
        _codex_mapping(".codex/agents/feature-review.toml", "reviewer"),
        *_agent_family_mappings("feature-reviewer", "reviewer"),
        _codex_mapping(".agents/skills/feature-review/SKILL.md", "reviewer"),
        _codex_mapping(".agents/skills/feature-review-workflow/SKILL.md", "reviewer"),
        _codex_mapping(
            ".agents/skills/remediation-handoff-atomic-planner/SKILL.md", "reviewer"
        ),
        _github_mapping(".github/agents/feature-review.agent.md", "reviewer"),
        _github_mapping(".github/prompts/review-feature.prompt.md", "reviewer"),
        _github_mapping(".github/skills/feature-review-workflow/SKILL.md", "reviewer"),
        _github_mapping(
            ".github/skills/remediation-handoff-atomic-planner/SKILL.md", "reviewer"
        ),
        _claude_mapping(".claude/agents/feature-review.md", "reviewer"),
        _claude_mapping(".claude/skills/feature-review-workflow/SKILL.md", "reviewer"),
        _claude_mapping(
            ".claude/skills/remediation-handoff-atomic-planner/SKILL.md", "reviewer"
        ),
    )
    orchestrator = (
        *_agent_family_mappings("orchestrator", "orchestrator"),
        _codex_mapping(".agents/skills/orchestrate/SKILL.md", "orchestrator"),
        _codex_mapping(".agents/skills/orchestrator-workflow/SKILL.md", "orchestrator"),
        _github_mapping(".github/agents/orchestrator.agent.md", "orchestrator"),
        _github_mapping(".github/agents/python-orchestrator.agent.md", "orchestrator"),
        _github_mapping(
            ".github/agents/powershell-orchestrator.agent.md", "orchestrator"
        ),
        _github_mapping(".github/agents/csharp-orchestrator.agent.md", "orchestrator"),
        _github_mapping(".github/prompts/orchestrate-work.prompt.md", "orchestrator"),
        _github_mapping(
            ".github/prompts/orchestrate-python-work.prompt.md", "orchestrator"
        ),
        _github_mapping(
            ".github/prompts/orchestrate-powershell-work.prompt.md", "orchestrator"
        ),
        _github_mapping(
            ".github/prompts/orchestrate-csharp-work.prompt.md", "orchestrator"
        ),
        _claude_mapping(".claude/agents/orchestrator.md", "orchestrator"),
        _claude_mapping(".claude/skills/orchestrate/SKILL.md", "orchestrator"),
        _claude_mapping(".claude/rules/orchestrator-state.md", "orchestrator"),
    )
    researcher = (
        *_agent_family_mappings("task-researcher", "researcher"),
        _codex_mapping(".agents/skills/research-issue/SKILL.md", "researcher"),
        _github_mapping(".github/agents/task-researcher.agent.md", "researcher"),
        _github_mapping(".github/prompts/research-issue.prompt.md", "researcher"),
        _claude_mapping(".claude/agents/task-researcher.md", "researcher"),
        _claude_mapping(".claude/skills/research-issue/SKILL.md", "researcher"),
    )
    routing = (
        _mapping(
            "config/orchestration-routing.json",
            ROUTING_BUNDLE_ROOT / "orchestration-routing.json",
            "routing",
        ),
    )
    return (*reviewer, *orchestrator, *researcher, *routing)


MAPPINGS = required_mappings()


def validate_mapping_inventory(mappings: tuple[BundleMapping, ...]) -> None:
    """Reject missing, extra, duplicate, or redirected bundle mappings."""

    required = set(required_mappings())
    actual = set(mappings)
    if len(actual) != len(mappings):
        raise ValueError("Customization bundle mappings contain a duplicate entry.")
    missing = sorted(required - actual, key=lambda item: item.destination.as_posix())
    extra = sorted(actual - required, key=lambda item: item.destination.as_posix())
    errors = [
        *(
            f"Missing source-to-bundle mapping: {item.source} -> {item.destination}"
            for item in missing
        ),
        *(
            f"Unexpected source-to-bundle mapping: {item.source} -> {item.destination}"
            for item in extra
        ),
    ]
    sources = [item.source for item in mappings]
    destinations = [item.destination for item in mappings]
    if len(set(sources)) != len(sources):
        errors.append("A canonical source is mapped more than once.")
    if len(set(destinations)) != len(destinations):
        errors.append("A packaged destination is mapped more than once.")
    if errors:
        raise ValueError("\n".join(errors))


def read_source(path: Path) -> bytes:
    """Read one required canonical source as unmodified bytes."""

    absolute_path = REPO_ROOT / path
    if not absolute_path.is_file():
        raise FileNotFoundError(f"Canonical customization source is missing: {path}")
    return absolute_path.read_bytes()


def _decoded_text(path: Path, content: bytes) -> str:
    """Decode one textual customization with an actionable failure."""

    try:
        return content.decode("utf-8")
    except UnicodeDecodeError as error:
        raise ValueError(f"Customization is not UTF-8 text: {path}") from error


def validate_bundle_semantics(
    files: dict[Path, bytes], mappings: tuple[BundleMapping, ...]
) -> None:
    """Reject weakened review, remediation, limit, or research contracts."""

    family_text: dict[Family, list[str]] = {
        "reviewer": [],
        "orchestrator": [],
        "researcher": [],
        "routing": [],
    }
    for mapping in mappings:
        content = files.get(mapping.destination)
        if content is None:
            raise ValueError(f"Expected bundle file is missing: {mapping.destination}")
        text = _decoded_text(mapping.destination, content)
        if "REVIEW_STATUS:" in text:
            raise ValueError(
                "Packaged binary-only REVIEW_STATUS decision path is forbidden: "
                f"{mapping.destination}"
            )
        family_text[mapping.family].append(text)

    reviewer = "\n".join(family_text["reviewer"])
    for token in (
        "REVIEW_VERDICT: PASS | BLOCKED",
        "REMEDIATION_ACTION: NONE | AUTONOMOUS",
        "NO_CANDIDATE",
        "no-delta disposition",
    ):
        if token not in reviewer:
            raise ValueError(f"Packaged reviewer contract is missing {token!r}.")

    orchestrator = "\n".join(family_text["orchestrator"])
    for token in (
        "blocked_stagnation",
        "one exact unused exception",
        "atomically set `consumed_at`",
        "can never authorize another transition",
        "blocked_remediation_loop_limit",
        "`blocked_cycle_limit` is rejected legacy input",
    ):
        if token not in orchestrator:
            raise ValueError(f"Packaged orchestrator contract is missing {token!r}.")

    researcher = "\n".join(family_text["researcher"])
    for token in ("docs/features/<feature>/research/", "docs/research/"):
        if token not in researcher:
            raise ValueError(f"Packaged researcher contract is missing {token!r}.")

    routing_text = "\n".join(family_text["routing"])
    loaded: object = json.loads(routing_text)
    if not isinstance(loaded, dict):
        raise ValueError("Packaged orchestration routing must be a JSON object.")
    cast("dict[str, object]", loaded)


def expected_bundle_files(
    mappings: tuple[BundleMapping, ...] = MAPPINGS,
) -> dict[Path, bytes]:
    """Return exact canonical bytes keyed by packaged destination."""

    validate_mapping_inventory(mappings)
    files = {mapping.destination: read_source(mapping.source) for mapping in mappings}
    validate_bundle_semantics(files, mappings)
    return files


def compare_bundle_files(
    actual: dict[Path, bytes], expected: dict[Path, bytes]
) -> list[str]:
    """Report missing, extra, and byte-divergent packaged files."""

    errors: list[str] = []
    for path in sorted(set(expected) - set(actual)):
        errors.append(f"Packaged customization is missing: {path}")
    for path in sorted(set(actual) - set(expected)):
        errors.append(f"Unexpected packaged customization: {path}")
    for path in sorted(set(actual) & set(expected)):
        if actual[path] == expected[path]:
            continue
        actual_digest = hashlib.sha256(actual[path]).hexdigest()
        expected_digest = hashlib.sha256(expected[path]).hexdigest()
        errors.append(
            f"Packaged customization is stale: {path} "
            f"(actual sha256:{actual_digest}; expected sha256:{expected_digest})"
        )
    return errors


def _is_managed_codex_agent(path: Path) -> bool:
    """Return whether a packaged Codex agent belongs to a synchronized family."""

    name = path.stem
    return name == "feature-review" or any(
        name == family or name.startswith(f"{family}-")
        for family in ("feature-reviewer", "orchestrator", "task-researcher")
    )


def discover_managed_bundle_paths() -> set[Path]:
    """Discover mapped and unexpected files inside synchronized bundle scopes."""

    paths: set[Path] = set()
    agent_root = REPO_ROOT / CODEX_BUNDLE_ROOT / ".codex/agents"
    if agent_root.is_dir():
        paths.update(
            path.relative_to(REPO_ROOT)
            for path in agent_root.glob("*.toml")
            if _is_managed_codex_agent(path)
        )
    for relative_root in (
        Path(".agents/skills/feature-review"),
        Path(".agents/skills/feature-review-workflow"),
        Path(".agents/skills/remediation-handoff-atomic-planner"),
        Path(".agents/skills/orchestrate"),
        Path(".agents/skills/orchestrator-workflow"),
        Path(".agents/skills/research-issue"),
    ):
        root = REPO_ROOT / CODEX_BUNDLE_ROOT / relative_root
        if root.is_dir():
            paths.update(
                path.relative_to(REPO_ROOT)
                for path in root.rglob("*")
                if path.is_file()
            )
    paths.update(
        mapping.destination
        for mapping in MAPPINGS
        if (REPO_ROOT / mapping.destination).is_file()
    )
    return paths


def synchronize(*, check: bool) -> list[str]:
    """Write or verify all deterministic source-to-bundle mappings."""

    expected = expected_bundle_files()
    if not check:
        for path, content in expected.items():
            absolute_path = REPO_ROOT / path
            if absolute_path.is_file() and absolute_path.read_bytes() == content:
                continue
            absolute_path.parent.mkdir(parents=True, exist_ok=True)
            absolute_path.write_bytes(content)
            print(f"UPDATED {path.as_posix()}")
    actual = {
        path: (REPO_ROOT / path).read_bytes()
        for path in discover_managed_bundle_paths()
    }
    errors = compare_bundle_files(actual, expected)
    if not errors:
        print(f"VERIFIED {len(expected)} packaged customization mappings")
    return errors


def build_parser() -> argparse.ArgumentParser:
    """Build the command-line parser."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check", action="store_true", help="Report package drift without writing."
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    """Synchronize or check the exact customization bundle inventory."""

    args = build_parser().parse_args(argv)
    try:
        errors = synchronize(check=bool(args.check))
    except (FileNotFoundError, json.JSONDecodeError, OSError, ValueError) as error:
        print(str(error), file=sys.stderr)
        return 1
    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
