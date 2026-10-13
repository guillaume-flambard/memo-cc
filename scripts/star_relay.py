#!/usr/bin/env python3
"""Memo Labs STAR handoff: read-only inventory and explicit, append-only cycle logs.

This is bookkeeping, NOT a background agent or a permission to execute a task.
Only writes an explicitly selected isolated worktree with an existing spec.
"""
import argparse
from datetime import datetime, timezone
import fcntl
import json
from pathlib import Path
import re
import sys

MARKER_START = re.compile(r"<!-- STAR:START ([0-9TZa-zA-Z-]+) -->")
MARKER_END = re.compile(r"<!-- STAR:FINISH ([0-9TZa-zA-Z-]+) (PASSED|FAILED|BLOCKED) -->")


def registry(root):
    doc = (root / "PROJECTS.md").read_text(encoding="utf-8")
    section = doc.split("## Projets appartenant à Memo Labs", 1)
    if len(section) != 2:
        raise ValueError("Project registry section missing")
    section = section[1].split("\n## ", 1)[0]
    result = {}
    for line in section.splitlines():
        cols = [c.strip() for c in line.split("|")[1:-1]]
        if len(cols) >= 4 and cols[0] not in ("Name", "---", "") and not cols[0].startswith("-"):
            if not re.fullmatch(r"[a-z0-9][a-z0-9-]*", cols[0]):
                continue
            result[cols[0]] = {"path": cols[1], "status": cols[3]}
    return result


def inventory(root):
    out = []
    for name, meta in registry(root).items():
        directory = root / meta["path"]
        candidates = ("SPEC.md", "docs/SPEC.md", "openspec/specs")
        spec = next((s for s in candidates if (directory / s).exists()), None)
        wt_root = root / "_worktrees"
        nested = (wt_root / name).glob("*/SHARED_TASK_NOTES.md") if (wt_root / name).is_dir() else ()
        # Older agents also used flat worktree names, e.g. cuesheet-live-e2e.
        flat = wt_root.glob(name + "-*/SHARED_TASK_NOTES.md") if wt_root.is_dir() else ()
        existing_relay_notes = sorted({str(p) for p in (*nested, *flat) if p.is_file()})
        out.append({"project": name, "status": meta["status"],
                    "spec": spec,
                    "notes": (directory / "SHARED_TASK_NOTES.md").exists(),
                    "worktree_notes": len(existing_relay_notes)})
    return out


def workspace_for(root, name, selected):
    if name not in registry(root):
        raise ValueError("Project not registered: " + name)
    workspace = selected.resolve()
    worktree_root = (root / "_worktrees").resolve()
    if not workspace.is_relative_to(worktree_root) or not workspace.is_dir():
        raise ValueError("Use an existing isolated worktree under projects/_worktrees")
    if not (workspace / ".git").exists():
        raise ValueError("Workspace is not a Git worktree")
    return workspace


def spec_in(workspace, argument):
    workspace = workspace.resolve()
    choices = [argument] if argument else ["SPEC.md", "docs/SPEC.md", "openspec/specs"]
    for entry in choices:
        candidate = (workspace / entry).resolve()
        if candidate.is_relative_to(workspace) and candidate.exists():
            return str(candidate.relative_to(workspace))
    raise ValueError("No real project spec found in worktree; read/create an approved spec before starting")


def active_cycle(content):
    starts = MARKER_START.findall(content)
    ends = MARKER_END.findall(content)
    if len(ends) > len(starts):
        raise ValueError("Malformed STAR notes: more completed than started cycles")
    if len(starts) == len(ends):
        return None
    if len(starts) != len(ends) + 1:
        raise ValueError("Multiple unfinished STAR cycles: resolve before continuing")
    if starts[-1] in {e[0] for e in ends}:
        raise ValueError("Malformed STAR notes: latest ID already finished")
    return starts[-1]


def locked_edit(notes, handler):
    notes.parent.mkdir(parents=True, exist_ok=True)
    with notes.open("a+", encoding="utf-8") as out:
        fcntl.flock(out.fileno(), fcntl.LOCK_EX)
        try:
            out.seek(0)
            old = out.read()
            to_append, response = handler(old)
            out.seek(0, 2)
            if old and not old.endswith("\n"):
                out.write("\n")
            out.write(to_append)
            out.flush()
        finally:
            fcntl.flock(out.fileno(), fcntl.LOCK_UN)
    return response


def start(notes, project, spec, situation, task):
    cycle = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    def apply(old):
        if active_cycle(old):
            raise ValueError("Existing unfinished cycle: finish or hand it over before starting another")
        text = ("\n<!-- STAR:START " + cycle + " -->\n"
                + "## STAR " + cycle + " | " + project + "\n"
                + "**Spec:** " + spec + "\n"
                + "**Situation:** " + situation + "\n"
                + "**Task:** " + task + "\n"
                + "**Action:** IN PROGRESS (one task only)\n"
                + "**Result:** NOT YET VERIFIED\n")
        return text, cycle
    return locked_edit(notes, apply)


def finish(notes, status, action, result, verification, next_task):
    def apply(old):
        cycle = active_cycle(old)
        if not cycle:
            raise ValueError("No unfinished STAR cycle to finish")
        text = ("\n<!-- STAR:FINISH " + cycle + " " + status + " -->\n"
                + "**Action taken:** " + action + "\n"
                + "**Result (" + status + "):** " + result + "\n"
                + "**Verification evidence:** " + verification + "\n"
                + "**Next single task:** " + next_task + "\n")
        return text, cycle
    return locked_edit(notes, apply)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--projects-root", type=Path, default=Path.home() / "projects")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("inventory", help="Read-only scan of every registered project")
    starting = sub.add_parser("start", help="Append a STAR cycle in an isolated worktree")
    starting.add_argument("--project", required=True)
    starting.add_argument("--workspace", type=Path, required=True)
    starting.add_argument("--spec", help="Existing spec path relative to selected worktree")
    starting.add_argument("--situation", required=True)
    starting.add_argument("--task", required=True)
    ending = sub.add_parser("finish", help="Close latest STAR cycle; never auto-claim a pass")
    ending.add_argument("--project", required=True)
    ending.add_argument("--workspace", type=Path, required=True)
    ending.add_argument("--status", choices=("PASSED", "FAILED", "BLOCKED"), required=True)
    for field in ("action", "result", "verification", "next-task"):
        ending.add_argument("--" + field, required=True)
    args = parser.parse_args(argv)
    root = args.projects_root.expanduser().resolve()
    try:
        if args.command == "inventory":
            print(json.dumps(inventory(root), ensure_ascii=False, indent=2))
        else:
            workspace = workspace_for(root, args.project, args.workspace)
            notes = workspace / "SHARED_TASK_NOTES.md"
            if args.command == "start":
                spec = spec_in(workspace, args.spec)
                cycle = start(notes, args.project, spec, args.situation, args.task)
                print("Started STAR " + cycle + " in " + str(notes))
            else:
                cycle = finish(notes, args.status, args.action, args.result, args.verification, args.next_task)
                print("Finished STAR " + cycle + ": " + args.status)
    except (OSError, ValueError) as exc:
        print("STAR blocked: " + str(exc), file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
