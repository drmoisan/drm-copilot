import { createHash } from "node:crypto";

import { describe, expect, it } from "@jest/globals";

import { validateEpicPlannerLaunchEvidence } from "../../../src/lib/validate/epic-planner-launch-evidence";
import {
  launchEvidenceFixture,
  type LaunchEvidenceFixture,
} from "./epic-planner-launch-evidence-test-support";

const ROOT = "C:/workspace";
type JsonRecord = Record<string, unknown>;

function features(value: LaunchEvidenceFixture): JsonRecord[] {
  return value.state["features"] as JsonRecord[];
}

function absolute(relative: string): string {
  return `${ROOT}/${relative}`;
}

function receiptPath(value: LaunchEvidenceFixture, index = 0): string {
  return absolute(String(features(value)[index]?.["launch_receipt_path"]));
}

function statusPath(value: LaunchEvidenceFixture): string {
  return absolute(String(features(value)[0]?.["launch_status_path"]));
}

function readJson(value: LaunchEvidenceFixture, path: string): JsonRecord {
  return JSON.parse(value.files.get(path) ?? "null") as JsonRecord;
}

function writeJson(
  value: LaunchEvidenceFixture,
  path: string,
  item: unknown,
): void {
  value.files.set(path, JSON.stringify(item));
}

function errors(value: LaunchEvidenceFixture): string[] {
  return validateEpicPlannerLaunchEvidence(value.state, value.context);
}

describe("epic planner launch receipt evidence", () => {
  it("accepts a sealed completed preparation wave", () => {
    const value = launchEvidenceFixture();

    expect(errors(value)).toEqual([]);
  });

  it.each([
    ["issue_num", "pending:feature-101", ".issue_num must match the feature"],
    ["feature_folder", "docs/features/active/other", ".feature_folder"],
    ["delegation_id", "other", ".delegation_id"],
    ["deployment_agent", "orchestrator-c1", ".deployment_agent"],
    ["model", "gpt-5.6-luna", ".model must match"],
    ["model_reasoning_effort", "low", ".model_reasoning_effort"],
    ["execution_context", "epic_execution_child", ".execution_context"],
    ["branch_name", "feature/other", ".branch_name"],
    ["worktree_path", "/repo/worktrees/other", ".worktree_path"],
  ])(
    "cross-binds receipt field %s to the final feature",
    (field, replacement, expected) => {
      const value = launchEvidenceFixture();
      const path = receiptPath(value);
      const receipt = readJson(value, path);
      receipt[String(field)] = replacement;
      writeJson(value, path, receipt);

      expect(
        errors(value).some((error) => error.includes(String(expected))),
      ).toBe(true);
    },
  );

  it.each([
    [{ schema_version: 1 }, "schema 2 completed"],
    [{ state: "active" }, "schema 2 completed"],
    [{ exit_code: 1 }, "exit_code must be 0"],
    [{ codex_session_id: "" }, "codex_session_id must be a non-empty"],
    [{ session_bound_at: "not-a-time" }, "session_bound_at must be"],
    [{ completed_at: "not-a-time" }, "completed_at must be"],
    [
      {
        session_bound_at: "2026-07-11T09:00:00+00:00",
        completed_at: "2026-07-10T09:00:00+00:00",
      },
      "completed_at must not precede",
    ],
  ])(
    "rejects an incomplete or invalid terminal session binding %#",
    (mutations, expected) => {
      const value = launchEvidenceFixture();
      const path = receiptPath(value);
      const receipt = { ...readJson(value, path), ...mutations };
      writeJson(value, path, receipt);

      expect(
        errors(value).some((error) => error.includes(String(expected))),
      ).toBe(true);
    },
  );

  it("binds receipt path, launch ID, and immutable specification bytes", () => {
    const value = launchEvidenceFixture();
    const path = receiptPath(value);
    const receipt = readJson(value, path);
    receipt["receipt_path"] =
      `${ROOT}/artifacts/orchestration/epic-child-launches/` +
      "preparation/other.receipt.json";
    receipt["launch_id"] = "other";
    receipt["spec_sha256"] = "0".repeat(64);
    receipt["status_path"] =
      `${ROOT}/artifacts/orchestration/epic-child-launches/` +
      "preparation/other.status.json";
    writeJson(value, path, receipt);

    const actual = errors(value).join("\n");

    expect(actual).toContain("receipt_path must identify");
    expect(actual).toContain("launch_id must match the receipt filename");
    expect(actual).toContain("spec_sha256 does not match");
    expect(actual).toContain("exactly one specification launch");
    expect(actual).toContain("status_path must match the feature");
  });

  it("cross-binds the selected specification launch to the feature", () => {
    const value = launchEvidenceFixture();
    const path = receiptPath(value);
    const receipt = readJson(value, path);
    const specPath = String(receipt["spec_path"]);
    const spec = readJson(value, specPath);
    const launches = spec["launches"] as JsonRecord[];
    launches[0]!["model"] = "gpt-5.6-luna";
    const specText = JSON.stringify(spec);
    value.files.set(specPath, specText);
    receipt["spec_sha256"] = createHash("sha256")
      .update(specText, "utf8")
      .digest("hex");
    writeJson(value, path, receipt);

    expect(errors(value).join("\n")).toContain(
      "specification launch.model must match",
    );
  });
});

describe("epic planner launch file and status evidence", () => {
  it.each(["receipt", "status", "spec"])(
    "requires %s evidence to exist and contain a JSON object",
    (target) => {
      const value = launchEvidenceFixture();
      const receipt = readJson(value, receiptPath(value));
      const paths: Readonly<Record<string, string>> = {
        receipt: receiptPath(value),
        status: statusPath(value),
        spec: String(receipt["spec_path"]),
      };
      const path = paths[target];
      expect(path).toBeDefined();
      if (path === undefined) {
        throw new Error(`missing fixture path for ${target}`);
      }
      value.files.delete(path);

      expect(errors(value).join("\n")).toContain("requires");
      value.files.set(path, "[]");

      expect(errors(value).join("\n")).toContain("must be a JSON object");
    },
  );

  it("requires the shared wave status to record the exact successful session", () => {
    const value = launchEvidenceFixture();
    const path = statusPath(value);
    const status = readJson(value, path);
    Object.assign(status, {
      schema_version: 1,
      state: "failed",
      failure: "boom",
    });
    status["wave_id"] = "other";
    const launches = status["launches"] as Record<string, JsonRecord>;
    Object.assign(launches["feature-101"]!, {
      state: "failed",
      exit_code: 1,
      receipt_path:
        `${ROOT}/artifacts/orchestration/epic-child-launches/` +
        "preparation/other.receipt.json",
      codex_session_id: "other-session",
      completed_at: "2026-07-10T09:31:00+00:00",
    });
    writeJson(value, path, status);

    const actual = errors(value).join("\n");

    expect(actual).toContain("schema 2 completed status");
    expect(actual).toContain("must not contain a failure");
    expect(actual).toContain("wave_id must match");
    expect(actual).toContain("completed with exit_code 0");
    expect(actual).toContain("receipt_path must match");
    expect(actual).toContain("codex_session_id must match");
    expect(actual).toContain("completed_at must match");
  });

  it("requires all features in the preparation batch to share one complete status", () => {
    const value = launchEvidenceFixture();
    const path = statusPath(value);
    const status = readJson(value, path);
    const launches = status["launches"] as Record<string, JsonRecord>;
    delete launches["feature-101"];
    writeJson(value, path, status);
    features(value)[1]!["launch_status_path"] =
      "artifacts/orchestration/epic-child-launches/preparation/other.json";

    const actual = errors(value).join("\n");

    expect(actual).toContain("must contain launch_id");
    expect(actual).toContain("must share one launch_status_path");
  });
});
