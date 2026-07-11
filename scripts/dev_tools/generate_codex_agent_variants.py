"""Generate checked-in Codex agent profiles from canonical logical agents."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import cast

if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib

from scripts.dev_tools.resolve_codex_deployment import (
    BASE_PROFILES,
    C3_ELEVATED_PROFILE,
    GENERATED_AGENT_FAMILIES,
)

REPO_ROOT = Path(__file__).resolve().parents[2]
BUNDLE_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)
PACK_ROOT = BUNDLE_ROOT / "pack-manifests"

CORE_FAMILIES = (
    "orchestrator",
    "atomic-planner",
    "atomic-executor",
    "feature-reviewer",
    "task-researcher",
    "prd-feature",
    "pr-author",
)
PACK_FAMILIES: dict[str, tuple[str, ...]] = {
    "core.json": CORE_FAMILIES,
    "python.json": ("python-typed-engineer",),
    "powershell.json": ("powershell-typed-engineer",),
    "typescript.json": ("typescript-engineer",),
    "csharp-modern.json": ("csharp-typed-engineer",),
    "csharp-legacy.json": ("csharp-typed-engineer",),
}


@dataclass(frozen=True)
class AgentProfile:
    """One generated profile suffix and its exact model settings."""

    suffix: str
    model: str
    reasoning: str


PROFILES: tuple[AgentProfile, ...] = (
    AgentProfile(
        BASE_PROFILES["C1"]["suffix"],
        BASE_PROFILES["C1"]["model"],
        BASE_PROFILES["C1"]["model_reasoning_effort"],
    ),
    AgentProfile(
        BASE_PROFILES["C2"]["suffix"],
        BASE_PROFILES["C2"]["model"],
        BASE_PROFILES["C2"]["model_reasoning_effort"],
    ),
    AgentProfile(
        BASE_PROFILES["C3"]["suffix"],
        BASE_PROFILES["C3"]["model"],
        BASE_PROFILES["C3"]["model_reasoning_effort"],
    ),
    AgentProfile(
        C3_ELEVATED_PROFILE["suffix"],
        C3_ELEVATED_PROFILE["model"],
        C3_ELEVATED_PROFILE["model_reasoning_effort"],
    ),
    AgentProfile(
        BASE_PROFILES["C4"]["suffix"],
        BASE_PROFILES["C4"]["model"],
        BASE_PROFILES["C4"]["model_reasoning_effort"],
    ),
)


def generated_agent_name(family: str, profile: AgentProfile) -> str:
    """Return the discoverable agent name for a logical family and profile."""

    return f"{family}-{profile.suffix}"


def generated_agent_relative_path(family: str, profile: AgentProfile) -> Path:
    """Return the repo-relative path for one generated agent file."""

    return Path(".codex") / "agents" / f"{generated_agent_name(family, profile)}.toml"


def _detect_newline(text: str) -> str:
    """Preserve the canonical agent file's newline convention."""

    return "\r\n" if "\r\n" in text else "\n"


def _read_text_preserving_newlines(path: Path) -> str:
    """Read UTF-8 text without universal-newline translation."""

    with path.open("r", encoding="utf-8", newline="") as stream:
        return stream.read()


def _write_text_preserving_newlines(path: Path, text: str) -> None:
    """Write UTF-8 text without translating its explicit newline sequence."""

    with path.open("w", encoding="utf-8", newline="") as stream:
        stream.write(text)


def render_agent_variant(base_text: str, family: str, profile: AgentProfile) -> str:
    """Render one profile while preserving the logical agent contract body."""

    newline = _detect_newline(base_text)
    trailing_newline = base_text.endswith(("\n", "\r"))
    lines = base_text.splitlines()
    instruction_index = next(
        (
            index
            for index, line in enumerate(lines)
            if line.startswith("developer_instructions")
        ),
        len(lines),
    )
    filtered = [
        line
        for index, line in enumerate(lines)
        if not (
            index < instruction_index
            and (
                line.startswith("model = ")
                or line.startswith("model_reasoning_effort = ")
            )
        )
    ]

    expected_name = f'name = "{family}"'
    if expected_name not in filtered:
        raise ValueError(f"Canonical agent does not declare {expected_name}.")
    name_index = filtered.index(expected_name)
    filtered[name_index] = f'name = "{generated_agent_name(family, profile)}"'

    description_index = next(
        (
            index
            for index, line in enumerate(filtered)
            if line.startswith("description = ")
        ),
        None,
    )
    if description_index is None:
        raise ValueError(f"Canonical agent {family!r} has no description field.")
    filtered[description_index + 1 : description_index + 1] = [
        f'model = "{profile.model}"',
        f'model_reasoning_effort = "{profile.reasoning}"',
    ]
    rendered = newline.join(filtered)
    return rendered + newline if trailing_newline else rendered


def render_base_alias(base_text: str, family: str) -> str:
    """Pin the compatibility alias to the default C3 Terra/high profile."""

    c3_profile = next(profile for profile in PROFILES if profile.suffix == "c3")
    rendered = render_agent_variant(base_text, family, c3_profile)
    generated_name = f'name = "{generated_agent_name(family, c3_profile)}"'
    return rendered.replace(generated_name, f'name = "{family}"', 1)


def expected_variant_files() -> dict[Path, str]:
    """Return every generated repo-relative agent path and expected content."""

    files: dict[Path, str] = {}
    for family in sorted(GENERATED_AGENT_FAMILIES):
        base_path = REPO_ROOT / ".codex" / "agents" / f"{family}.toml"
        base_text = _read_text_preserving_newlines(base_path)
        for profile in PROFILES:
            relative_path = generated_agent_relative_path(family, profile)
            files[relative_path] = render_agent_variant(base_text, family, profile)
    return files


def render_manifest(path: Path, families: tuple[str, ...]) -> str:
    """Return a manifest containing every base and generated family path."""

    loaded: object = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(loaded, dict):
        raise ValueError(f"Pack manifest must be an object: {path}")
    document = cast("dict[str, object]", loaded)
    raw_paths = document.get("paths")
    if not isinstance(raw_paths, list):
        raise ValueError(f"Pack manifest paths must be a string array: {path}")
    path_items = cast("list[object]", raw_paths)
    if not all(isinstance(item, str) for item in path_items):
        raise ValueError(f"Pack manifest paths must be a string array: {path}")
    paths = cast("list[str]", path_items)
    required = [f".codex/agents/{family}.toml" for family in families]
    required.extend(
        str(generated_agent_relative_path(family, profile)).replace("\\", "/")
        for family in families
        for profile in PROFILES
    )
    for required_path in required:
        if required_path not in paths:
            paths.append(required_path)
    return json.dumps(document, indent=2) + "\n"


def _synchronize(*, check: bool) -> list[str]:
    """Write or check all generated agents and affected pack manifests."""

    errors: list[str] = []
    for family in sorted(GENERATED_AGENT_FAMILIES):
        relative_base = Path(".codex") / "agents" / f"{family}.toml"
        root_text = _read_text_preserving_newlines(REPO_ROOT / relative_base)
        bundle_text = _read_text_preserving_newlines(BUNDLE_ROOT / relative_base)
        expected_base = render_base_alias(root_text, family)
        if check:
            if root_text != expected_base or bundle_text != expected_base:
                errors.append(
                    f"Canonical Codex agent alias is stale or differs from bundle: "
                    f"{relative_base}"
                )
        else:
            _write_text_preserving_newlines(REPO_ROOT / relative_base, expected_base)
            _write_text_preserving_newlines(BUNDLE_ROOT / relative_base, expected_base)
        base_document = tomllib.loads(expected_base)
        if (
            base_document.get("model") != BASE_PROFILES["C3"]["model"]
            or base_document.get("model_reasoning_effort")
            != BASE_PROFILES["C3"]["model_reasoning_effort"]
        ):
            errors.append(
                f"Canonical Codex agent is not pinned to C3 Terra/high: {relative_base}"
            )
    for relative_path, expected_text in expected_variant_files().items():
        for root in (REPO_ROOT, BUNDLE_ROOT):
            target = root / relative_path
            actual = _read_text_preserving_newlines(target) if target.exists() else None
            if check:
                if actual != expected_text:
                    errors.append(f"Generated Codex agent is stale: {target}")
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                _write_text_preserving_newlines(target, expected_text)

    for manifest_name, families in PACK_FAMILIES.items():
        manifest_path = PACK_ROOT / manifest_name
        expected_manifest = render_manifest(manifest_path, families)
        actual_manifest = manifest_path.read_text(encoding="utf-8")
        if check:
            if actual_manifest != expected_manifest:
                errors.append(f"Codex pack manifest is stale: {manifest_path}")
        else:
            manifest_path.write_text(expected_manifest, encoding="utf-8")
    return errors


def build_parser() -> argparse.ArgumentParser:
    """Build the generator command-line parser."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check", action="store_true", help="Report drift without writing files."
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    """Generate or verify Codex agent deployment profiles."""

    args = build_parser().parse_args(argv)
    errors = _synchronize(check=bool(args.check))
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
