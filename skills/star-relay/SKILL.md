---
name: star-relay
description: Run one autonomous engineering relay on any registered Memo Labs project, using Situation, Task, Action, Result with verified evidence and a clear next handoff. Preserve project specs, priority rules and isolation.
---

# STAR Relay | one verified change per cycle

This skill applies to every registered Memo Labs project. It never supersedes local AGENTS.md, SPEC.md, PROJECTS.md, Stasis priorities, repo protection rules, or human approval gates. The method is universal; implementation permission is not.

## Preflight, always before writing

1. Read home and projects AGENTS.md, PROJECTS.md, current Stasis focus/sprint, and project AGENTS.md.
2. Read the actual spec: SPEC.md, docs/SPEC.md, openspec/specs, or an explicit authoritative project spec. Read SHARED_TASK_NOTES.md. Never invent requirements or treat a README as an authoritative spec without evidence.
3. Check Git worktree status, branch/PR status, in-flight work, blockers, tests and real runtime state. Use a separate worktree under ~/projects/_worktrees/<project>/<task> unless local policy is stricter.
4. Respect Stasis routing. Focus projects can take ordinary implementation slots. Support projects only serve focus. Background projects remain read-only/queued absent explicit owner authorization or incident response. One writer per task.
5. Select exactly one small unblocked task with explicit acceptance criteria. If it is large, break it down in SHARED_TASK_NOTES.md BEFORE implementing, and execute only the first piece.
6. Respect secrets, least privilege and deploy policies. Never execute PR code on privileged production runners. No unapproved merges or production deployment. Preserve rollback.

## STAR execution cycle

**Situation:** identify the spec requirement, real observed facts, impact, baseline, blockers and supporting proof. Separate facts from assumptions.

**Task:** one independently verifiable objective with Definition of Done, scope boundaries and safety conditions.

**Action:** smallest reversible change in an isolated worktree; build, test and verify behavior end to end. If a regression occurs, diagnose within scope. Do not add speculative work.

**Result:** PASSED, FAILED, or BLOCKED, with commands and observed results, code/PR references, runtime evidence, remaining risk and candid gaps. Green CI alone is not production health.

At the end update SHARED_TASK_NOTES.md, preserving earlier records: task, changed files, tests and runtime, decisions, gotchas, blocker, and exactly one recommended next task. Stop at that task boundary. Recheck Stasis prior to the next authorized cycle.

## Handoff and stop rules

- Use the versioned helper scripts/star_relay.py from this repo for read-only portfolio inventory and safe cycle bookkeeping in an explicitly selected isolated worktree.
- Never fabricate missing specs or completion claims. Inspect project-specific sources first.
- A failed test, missing permission, stale priority, security boundary, active concurrent writer, or production regression means STOP and record a BLOCKED/FAILED result. Do not spin indefinitely.
- Apply the method to all registered projects; do not automatically run implementations across all repos. Focus + explicit owner instructions define what can be changed.
- Autonomous loop means repeatable authorized cycles, not a claim to work unattended after the current invocation. Scheduling requires an explicit automation and safe scope.

## Minimal handoff example

    Situation: Veilleur candidate failed /ready and autodeploy rolled back, issue #7.
    Task: Reproduce startup failure in isolated staging, no production changes.
    Action: Inspect exact image digest and mounts, run constrained smoke test.
    Result: FAILED, cite command/logs, production remains on safe image.
    Next: Correct specific startup invariant and rerun isolated test.
