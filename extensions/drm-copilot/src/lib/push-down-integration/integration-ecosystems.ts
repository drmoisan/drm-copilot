/**
 * Ecosystem detection of the push-down integration tools (issue #1051, S21
 * and S22).
 *
 * Purpose:
 *     Report which harness ecosystems (`claude`, `codex`, `copilot`) and which
 *     language packs a destination selected in its push-down manifest and which
 *     it shows evidence of on disk.
 *
 * Side effects:
 *     Reads the destination through the injected read-only seam only.
 */

import { compareCodePoint } from "../string-ordering";
import { isExcludedDirectoryName } from "../push-down/claude-blast-radius-derive-manifests";
import {
  type PushDownFileSystem,
  toPosixPath,
} from "../push-down/filesystem-adapter";
import {
  DESTINATION_MANIFEST_RELATIVE_PATH,
  type DestinationManifest,
  parseDestinationManifest,
} from "../push-down/push-down-destination-manifest";
import { joinPosix } from "../push-down/push-down-pipeline";

/** Read-only file-system seam of the integration tools (S48). */
export type IntegrationReadFileSystem = Pick<
  PushDownFileSystem,
  "listFiles" | "isFile" | "readTextFile"
>;

/** One reported ecosystem or pack. */
export interface EcosystemPresence {
  readonly name: string;
  readonly selected: boolean;
  readonly present: boolean;
}

/** Result of {@link detectIntegrationEcosystems}. */
export interface IntegrationEcosystems {
  readonly harness: ReadonlyArray<EcosystemPresence>;
  readonly packs: ReadonlyArray<EcosystemPresence>;
}

/** Root folders whose content never counts as language evidence (S22). */
const HARNESS_ROOTS: ReadonlySet<string> = new Set([
  ".agents",
  ".claude",
  ".codex",
  ".github",
]);

/**
 * Read the destination manifest, or return undefined when it is absent or
 * fails to parse.
 *
 * @param fs Read-only seam.
 * @param destinationRoot Destination root (POSIX).
 * @returns The manifest or undefined.
 */
export function readManifestOrUndefined(
  fs: IntegrationReadFileSystem,
  destinationRoot: string,
): DestinationManifest | undefined {
  const path = joinPosix(destinationRoot, DESTINATION_MANIFEST_RELATIVE_PATH);
  if (!fs.isFile(path)) {
    return undefined;
  }
  try {
    return parseDestinationManifest(fs.readTextFile(path));
  } catch {
    return undefined;
  }
}

/**
 * Return the destination-relative paths of every file under the root.
 *
 * @param fs Read-only seam.
 * @param destinationRoot Destination root (POSIX).
 * @returns Relative POSIX paths.
 */
function relativeFiles(
  fs: IntegrationReadFileSystem,
  destinationRoot: string,
): string[] {
  const prefix = `${toPosixPath(destinationRoot).replace(/\/+$/, "")}/`;
  return fs
    .listFiles(destinationRoot)
    .map(toPosixPath)
    .filter((path) => path.startsWith(prefix))
    .map((path) => path.slice(prefix.length));
}

/** Return the selected C# pack name of a manifest selection union. */
function selectedCsharpName(
  manifest: DestinationManifest | undefined,
): string | undefined {
  for (const selection of Object.values(manifest?.selection ?? {})) {
    for (const pack of selection.packs) {
      if (pack === "csharp-modern" || pack === "csharp-legacy") {
        return pack;
      }
      if (pack === "csharp") {
        return selection.csharpVariant === "legacy"
          ? "csharp-legacy"
          : "csharp-modern";
      }
    }
  }
  return undefined;
}

/**
 * Detect the harness ecosystems and language packs of a destination.
 *
 * @param fs Read-only seam.
 * @param destinationRoot Destination root (POSIX).
 * @returns Harness ecosystems in fixed order and packs sorted by name.
 */
export function detectIntegrationEcosystems(
  fs: IntegrationReadFileSystem,
  destinationRoot: string,
): IntegrationEcosystems {
  const manifest = readManifestOrUndefined(fs, destinationRoot);
  const selection = manifest?.selection ?? {};
  const at = (relative: string): string => joinPosix(destinationRoot, relative);
  const files = relativeFiles(fs, destinationRoot);
  const under = (root: string): boolean =>
    files.some((path) => path.startsWith(`${root}/`));
  const harness: EcosystemPresence[] = [
    {
      name: "claude",
      selected: selection["claude"] !== undefined,
      present: under(".claude"),
    },
    {
      name: "codex",
      selected: selection["codex"] !== undefined,
      present: under(".codex") || fs.isFile(at("AGENTS.md")),
    },
    {
      name: "copilot",
      selected: selection["copilot"] !== undefined,
      present: fs.isFile(at(".github/copilot-instructions.md")),
    },
  ];
  const evidence = files.filter((path) => {
    const segments = path.split("/");
    const directories = segments.slice(0, -1);
    return (
      !HARNESS_ROOTS.has(segments[0] ?? "") &&
      !directories.some((name) => isExcludedDirectoryName(name))
    );
  });
  const names = new Set(evidence);
  const fileName = (path: string): string => path.split("/").pop() ?? "";
  const hasExtension = (extensions: ReadonlyArray<string>): boolean =>
    evidence.some((path) =>
      extensions.some((extension) => fileName(path).endsWith(extension)),
    );
  const typescriptPresent = evidence.some((path) => {
    if (fileName(path) !== "package.json") {
      return false;
    }
    const directory = path.slice(0, path.length - "package.json".length);
    return names.has(`${directory}tsconfig.json`);
  });
  const selectedPacks = new Set(
    Object.values(selection).flatMap((entry) => entry.packs),
  );
  const csharpName = selectedCsharpName(manifest);
  const packs: EcosystemPresence[] = [
    {
      name: "powershell",
      selected: selectedPacks.has("powershell"),
      present: hasExtension([".ps1", ".psm1", ".psd1"]),
    },
    {
      name: "python",
      selected: selectedPacks.has("python"),
      present: evidence.some((path) =>
        ["pyproject.toml", "setup.py"].includes(fileName(path)),
      ),
    },
    {
      name: "typescript",
      selected: selectedPacks.has("typescript"),
      present: typescriptPresent,
    },
    {
      name: csharpName ?? "csharp",
      selected: csharpName !== undefined,
      present: hasExtension([".csproj", ".sln", ".slnx"]),
    },
  ];
  return {
    harness,
    packs: packs.sort((left, right) => compareCodePoint(left.name, right.name)),
  };
}
