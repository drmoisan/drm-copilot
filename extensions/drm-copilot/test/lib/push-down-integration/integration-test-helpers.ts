/**
 * Test helpers of the push-down integration tools (issue #1051).
 *
 * Every helper builds fresh in-memory state: an in-memory destination whose
 * write calls are recorded and whose `listFiles` can return entries in reverse
 * order. The bundled CI workflows are read once, read-only, from the tracked
 * `resources/ci-workflows/` folder. Nothing touches the disk otherwise.
 */

import { readFileSync } from "node:fs";
import { join } from "node:path";

import { type PushDownFileSystem } from "../../../src/lib/push-down/filesystem-adapter";
import {
  type DestinationManifestFileEntry,
  type DestinationManifestSelection,
  renderDestinationManifest,
} from "../../../src/lib/push-down/push-down-destination-manifest";
import { InMemoryPushDownFileSystem } from "../push-down/push-down.test-helpers";

/** Destination root of the fixtures (POSIX, no drive letter). */
export const DEST = "/dest";

/** Extension root of the fixtures. */
export const EXT = "/ext";

/** In-memory adapter that records every write call and can reverse listings. */
export class RecordingIntegrationFileSystem implements PushDownFileSystem {
  /** Paths passed to `writeTextFile` or `ensureDir`, in call order. */
  readonly writeCalls: string[] = [];
  readonly inner = new InMemoryPushDownFileSystem();

  /**
   * @param reverseListing Return `listFiles` entries in reverse order.
   */
  constructor(private readonly reverseListing = false) {}

  /** Seed one file without recording a write. */
  seed(path: string, text: string): this {
    this.inner.seedFile(path, text);
    return this;
  }

  listFiles(root: string): string[] {
    const listed = this.inner.listFiles(root);
    return this.reverseListing ? [...listed].reverse() : listed;
  }

  isDir(path: string): boolean {
    return this.inner.isDir(path);
  }

  isFile(path: string): boolean {
    return this.inner.isFile(path);
  }

  readTextFile(path: string): string {
    return this.inner.readTextFile(path);
  }

  writeTextFile(path: string, content: string): void {
    this.writeCalls.push(path);
    this.inner.writeTextFile(path, content);
  }

  ensureDir(path: string): void {
    this.writeCalls.push(path);
    this.inner.ensureDir(path);
  }
}

/**
 * Build a destination seeded with files relative to {@link DEST}.
 *
 * @param files Destination-relative path to text.
 * @param reverseListing Reverse `listFiles` order.
 * @returns The adapter.
 */
export function destination(
  files: Readonly<Record<string, string>>,
  reverseListing = false,
): RecordingIntegrationFileSystem {
  const fs = new RecordingIntegrationFileSystem(reverseListing);
  fs.inner.seedDir(DEST);
  for (const [path, text] of Object.entries(files)) {
    fs.seed(`${DEST}/${path}`, text);
  }
  return fs;
}

const RESOURCES = join(__dirname, "..", "..", "..", "resources");

/** Read one tracked bundle file by its resources-relative path. */
export function bundledResource(path: string): string {
  return readFileSync(join(RESOURCES, ...path.split("/")), "utf8");
}

/** Seed the four bundled harness workflows under {@link EXT}. */
export function seedHarnessWorkflows(fs: RecordingIntegrationFileSystem): void {
  for (const stem of ["python", "powershell", "typescript", "dotnet"]) {
    const path = `ci-workflows/workflows/harness-${stem}.yml`;
    fs.seed(`${EXT}/resources/${path}`, bundledResource(path));
  }
}

/** Render a destination manifest with the given selection and files. */
export function manifestText(
  selection: Readonly<Record<string, DestinationManifestSelection>>,
  files: Readonly<Record<string, DestinationManifestFileEntry>> = {},
): string {
  return renderDestinationManifest({
    schemaVersion: "1.0.0",
    payloadVersion: "9.8.7",
    selection,
    files,
  });
}

/** The CI data file text #1050 delivers. */
export const DATA_FILE_TEXT = `${JSON.stringify(
  {
    required_contexts: ["CI Required Gate"],
    schema_version: "1.0.0",
    workflow: "CI",
    workflow_file: ".github/workflows/drm-copilot-ci.yml",
  },
  null,
  2,
)}\n`;

/** A minimal caller that satisfies the data file. */
export const CALLER_TEXT = [
  "name: CI",
  "on:",
  "  pull_request:",
  "jobs:",
  "  python:",
  "    name: Python",
  "    uses: drmoisan/drm-copilot/.github/workflows/harness-python.yml@v9.8.7",
  "  ci-required-gate:",
  "    name: CI Required Gate",
  "    if: always()",
  "    needs:",
  "      - python",
  "    runs-on: ubuntu-latest",
  "",
].join("\n");
