---
description: "Use when working on GitHub Project tasks: planning, triaging, implementing, or updating a task or goal (issues and milestones in the project, Status field, yo- commands, yo-gh script)."
---
# GitHub Project workflow rules

## Runtime
- On Windows, prefer opening this workspace in VS Code through WSL; Git Bash is a fallback if WSL is unavailable. Keep the agent hook, terminal commands, and local repo paths in the same environment. Use paths visible there for `YO_REPOS_ROOT` (for example, `/mnt/c/...` in WSL).
- The workflow requires Bash, `python3` for the Work Buddy hook, `gh`, `jq`, and `git`.

## Where the work lives
- GitHub Projects (Status and Priority fields are the source of truth) plus one **tracking repo** that holds goals (milestones). Run `./scripts/yo-gh config` once per session for the account, selected projects, tracking repo, `repoOwner` (default tracking repo owner for short code labels), `reposRoot` (where local clones live) and `branchPrefix`.
- Refer to issues as `owner/repo#n` (bare `#n` means the tracking repo).
- Use only direct `./scripts/yo-gh` commands from the workspace root for project and issue changes: one plain command per call, no `bash` or `wsl.exe` wrapper, pipes, chaining, `$`, or backticks (the guard checks the command path and blocks these). Pass comment bodies as one quoted argument. Run it with no arguments for usage.
- `YO_PROJECT` pins one project. When omitted, `yo-gh` discovers active (non-closed) projects owned by `YO_OWNER`, falling back to the tracking repo owner. `YO_REPO_OWNER` only controls short `repo:<name>` labels. Reads preserve one row per project membership; an issue in several projects may appear several times. `setup`, `status`, `priority`, and `create` apply to every discovered project; `create` creates the issue once. Multi-project writes are best-effort and may partially succeed.

| Command | Purpose |
|---|---|
| `yo-gh config` | Account, selected projects, tracking repo, clones folder, branch prefix |
| `yo-gh resolve-repos <repo:NAME>...` | Resolve one or more code repo labels, including explicit owners |
| `yo-gh today` / `yo-gh next` | Open memberships as JSON lines / top `Todo` item across projects |
| `yo-gh show <ref>` | Issue, comments, sub-issues, parent, goal, all project memberships |
| `yo-gh create <title> [--repo R] [--body B] [--status S] [--priority P] [--label L] [--milestone G] [--parent REF]` | Create one issue and add it to selected projects (default repo: tracking repo, status `Backlog`) |
| `yo-gh status <ref> <Status>` / `yo-gh priority <ref> <Priority>` | Change a field in selected projects |
| `yo-gh comment <ref> <body>` | Add a comment |
| `yo-gh sub-add <parent> <child>` | Link an existing issue as a sub-issue |
| `yo-gh goals` | Goals with due date, "done when", open/closed counts |
| `yo-gh goal-create <title> [--due YYYY-MM-DD] [--desc "done when ..."]` | New goal |
| `yo-gh milestone <ref> <goal\|none>` | Set or clear an issue's goal |

## Status field
| Status | Meaning | Who moves it next |
|---|---|---|
| `Backlog` | Idea, not chosen yet | Work Buddy (triage) |
| `Todo` | Chosen for now; needs a plan | Work Buddy (`/yo-plan`) |
| `Plan review` | Plan posted; waiting for the human | Human |
| `Approved` | Plan approved; ready to implement | Implementer |
| `In Progress` | Implementer working | Implementer |
| `Human review` | Changes ready for the human to review | Human |
| `Waiting feedback` | Needs an answer or clarification from the human | Human |
| `Blocked` | Stopped by an external factor | Human |
| `Done` | Finished; only the human sets it (or closes the issue) | — |

Priority values: `DO NOW`, `Urgent`, `High`, `Medium`, `Low`.

## Goals
- A **goal** is a milestone of the tracking repo: the final outcome several tasks work toward, with a due date and a "done when" description.
- Run `yo-gh goals` first and reuse an existing goal; follow the existing title style (for example `[AREA] Outcome`). Create one with `goal-create` only after the human agrees to the title.
- Tracking issues and tasks that live in the tracking repo carry the goal (`--milestone` on create, or `yo-gh milestone`). An issue in another repo cannot use the tracking repo's milestone; it belongs to the goal through its parent tracking issue.
- A goal is complete when all its issues are `Done`; only the human closes the milestone.

## Repos and sub-issues
- A task may have several `repo:<repo-name>` labels. A short label resolves under `repoOwner`, which defaults to the tracking repo owner: `repo:service` means `<tracking-repo-owner>/service`. An explicit `repo:<owner>/<repo>` preserves that owner. Set `YO_REPO_OWNER` to override the short-label default without changing the tracking repo or Project owner.
- Use `repos` from `yo-gh show` or `yo-gh resolve-repos` for code targets. Labels take precedence over the issue's own repo; without labels, use the issue repo only when it is a code repo, otherwise ask. Never move or recreate an issue just to match its code targets.
- Find existing clones under `reposRoot` (up to 6 levels deep) and verify their origin matches the resolved owner/repo, not just the directory name. If none or several match, ask the human.
- Never clone or download a repo.

## Bolts
- Planning a main issue must produce **one or more bolt sub-issues**, even for a single repo. A bolt is a bounded, independently verifiable outcome, not a synonym for a repo: several bolts can target the same repo, and one bolt can target several repos when the change must be coordinated.
- Before creating anything, inspect the parent's existing sub-issues and comments. Reuse matching bolts; never recursively split an existing bolt just because it has a parent.
- Each bolt records its parent, scope, resolved code repos, acceptance criteria, verification, and dependencies (other bolt refs, or explicitly none). Title it `Bolt: <outcome>`. Create it with `yo-gh create ... --parent <main-ref> --status "Plan review"` in the tracking repo by default; use `--repo` only when the agreed plan calls for another issue home. Add the short `repo:*` labels where they exist; if a label is missing, ask the human to create it rather than silently dropping the target.
- The parent's `## Plan v<n>` lists every bolt ref, scope, dependencies, execution order, and branches based on the bolt's issue number. Confirm links using `yo-gh show` before offering approval. Ask before creating or changing more than three issues.
- Revisions update existing bolts through versioned plan comments; newly added or changed bolts stay in `Plan review` until that version is explicitly approved. Do not silently delete, close, or replace a bolt, or reset completed/in-progress work.
- Approval must name the parent plan version and exact covered bolt refs. Re-read each bolt to verify its parent link, scope, acceptance criteria, verification, and dependencies before setting `Approved`; stop if any are missing. Record `## Approved` with the version and bolt refs on the parent and covered bolts. New scope requires a new approval.
- Workers implement approved bolts, not the parent itself. Keep the parent open until every bolt is reviewed and the overall outcome is accepted. Do not run two workers in the same clone concurrently; direct branches share one checkout.

## Comments
- Plans, progress, questions, and handoffs are issue comments.
- Start each with a heading: `## Plan v<n>`, `## Approved`, `## Progress`, `## Question`, `## Blocked`, or `## Ready for review`.
- Read all comments (`yo-gh show`) before planning or implementing; the human's feedback lives there.

## Implementer rules
Only implement a bolt in `Approved` (or `In Progress` when resuming) with an explicit approval referencing the parent plan version. Read the parent plan and the bolt's latest scope; stop if scope changed after approval. Verify prerequisite bolts are accepted before starting dependent work.

In each resolved code repo clone for that bolt:
1. If `git status --porcelain` is not empty, stop and ask the human; do not stash, commit, or discard their changes.
2. `git fetch origin --prune`.
3. Default branch = `git symbolic-ref --short refs/remotes/origin/HEAD` without `origin/` (fall back to `main`, then `master`); `git switch <default>`.
4. `git pull --ff-only`; if it fails, stop and report instead of merging or resetting.
5. Branch `<branchPrefix>/<n>-<slug>` (n = issue number, slug = short kebab-case title, max 40 chars): `git switch -c <branch>`, or `git switch <branch>` if it already exists.

Then:
- Set Status `In Progress` and comment `## Progress` with the branch.
- Commit on the task branch only. Do not push, open PRs, merge, or touch the default branch unless the plan says so.
- Finish by commenting `## Ready for review` (summary, branch, how to verify) and setting `Human review`.
- Need a human answer: comment `## Question` and set `Waiting feedback`. External blocker: comment `## Blocked` and set `Blocked`. Then stop.
