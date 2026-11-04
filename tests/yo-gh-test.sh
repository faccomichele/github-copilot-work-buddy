#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT
mkdir -p "$TEST_HOME/scripts"
cp -p "$SOURCE_ROOT/scripts/yo-gh" "$TEST_HOME/scripts/yo-gh"
cd "$TEST_HOME"
unset YO_PROJECT YO_REPO_OWNER
export YO_REPO=tracker/to-do YO_OWNER=person YO_BRANCH_PREFIX=person
export YO_TEST_LOG="$TEST_HOME/gh.log"
: >"$YO_TEST_LOG"

gh() {
  printf '%s\n' "$*" >>"$YO_TEST_LOG"
  case "$1 $2" in
    'issue view')
      if [[ "${YO_TEST_NO_LABELS:-}" == 1 ]]; then
        printf '%s\n' '{"number":12,"labels":[],"comments":[]}'
      else
        printf '%s\n' '{"number":12,"labels":[{"name":"repo:emailage-infrastructure-vpc"},{"name":"repo:another-org/service"},{"name":"bug"}],"comments":[]}'
      fi
      ;;
    'project list')
      [[ "$*" == *"--owner person"* ]] || { printf 'Wrong project owner: %s\n' "$*" >&2; return 1; }
      [[ "$*" == *"--limit 200"* ]] || { printf 'Missing project limit: %s\n' "$*" >&2; return 1; }
      [[ "$*" != *"--closed"* ]] || { printf 'Closed projects should not be listed: %s\n' "$*" >&2; return 1; }
      if [[ "${YO_TEST_EMPTY_PROJECTS:-}" == 1 ]]; then
        printf '%s\n' '{"projects":[]}'
      elif [[ "${YO_TEST_PROJECT_LIMIT:-}" == 1 ]]; then
        jq -cn '{projects:[range(1;201) | {number: ., title: ("Project " + tostring)}]}'
      elif [[ "${YO_TEST_FORBID_LIST:-}" == 1 ]]; then
        printf 'Unexpected project discovery: %s\n' "$*" >&2
        return 1
      else
        printf '%s\n' '{"projects":[{"number":4,"title":"Personal"},{"number":7,"title":"Side"}]}'
      fi
      ;;
    'project view')
      case "$3" in
        4) project_id=PVT_4; project_title=Personal ;;
        7) project_id=PVT_7; project_title=Side ;;
        *) printf 'Unexpected project number: %s\n' "$3" >&2; return 1 ;;
      esac
      if [[ "$*" == *"--jq .id"* ]]; then
        printf '%s\n' "$project_id"
      else
        printf '{"id":"%s","number":%s,"title":"%s"}\n' "$project_id" "$3" "$project_title"
      fi
      ;;
    'project field-list')
      if [[ "${YO_TEST_NO_STATUS_PROJECT:-}" == "$3" ]]; then
        jq -cn --arg p "$3" '{fields:[{id:("F_PRIORITY_" + $p),name:"Priority",options:[{id:("O_PRIORITY_" + $p + "_High"),name:"High"},{id:("O_PRIORITY_" + $p + "_Urgent"),name:"Urgent"},{id:("O_PRIORITY_" + $p + "_DO_NOW"),name:"DO NOW"},{id:("O_PRIORITY_" + $p + "_Medium"),name:"Medium"},{id:("O_PRIORITY_" + $p + "_Low"),name:"Low"}]}]}'
      else
        jq -cn --arg p "$3" '{fields:[{id:("F_STATUS_" + $p),name:"Status",options:[{id:("O_STATUS_" + $p + "_Backlog"),name:"Backlog"},{id:("O_STATUS_" + $p + "_Todo"),name:"Todo"},{id:("O_STATUS_" + $p + "_Plan review"),name:"Plan review"},{id:("O_STATUS_" + $p + "_Approved"),name:"Approved"},{id:("O_STATUS_" + $p + "_In Progress"),name:"In Progress"},{id:("O_STATUS_" + $p + "_Human review"),name:"Human review"},{id:("O_STATUS_" + $p + "_Waiting feedback"),name:"Waiting feedback"},{id:("O_STATUS_" + $p + "_Blocked"),name:"Blocked"},{id:("O_STATUS_" + $p + "_Done"),name:"Done"}]},{id:("F_PRIORITY_" + $p),name:"Priority",options:[{id:("O_PRIORITY_" + $p + "_High"),name:"High"},{id:("O_PRIORITY_" + $p + "_Urgent"),name:"Urgent"},{id:("O_PRIORITY_" + $p + "_DO_NOW"),name:"DO NOW"},{id:("O_PRIORITY_" + $p + "_Medium"),name:"Medium"},{id:("O_PRIORITY_" + $p + "_Low"),name:"Low"}]}]}'
      fi
      ;;
    'project item-list')
      [[ "$*" == *"--limit 200"* ]] || { printf 'Missing item limit: %s\n' "$*" >&2; return 1; }
      if [[ "${YO_TEST_ITEM_LIMIT:-}" == 1 ]]; then
        jq -cn '{items:[range(1;201) | {content:{repository:"tracker/to-do",number: .,url:"https://github.com/tracker/to-do/issues"},title:"Issue",status:"Todo"}]}'
      else
        case "$3" in
          4) printf '%s\n' '{"items":[{"content":{"repository":"tracker/to-do","number":12,"url":"https://github.com/tracker/to-do/issues/12"},"title":"Shared issue","status":"Todo","priority":"High","milestone":{"title":"Goal"}}]}' ;;
          7) printf '%s\n' '{"items":[{"content":{"repository":"tracker/to-do","number":12,"url":"https://github.com/tracker/to-do/issues/12"},"title":"Shared issue","status":"Todo","priority":"Medium","milestone":{"title":"Goal"}}]}' ;;
          *) printf 'Unexpected project number: %s\n' "$3" >&2; return 1 ;;
        esac
      fi
      ;;
    'project item-add')
      case "$3" in
        4) printf '%s\n' ITEM_4 ;;
        7) printf '%s\n' ITEM_7 ;;
        *) printf 'Unexpected project number: %s\n' "$3" >&2; return 1 ;;
      esac
      ;;
    'project item-edit')
      if [[ "${YO_TEST_FAIL_EDIT_PROJECT:-}" != '' && "$*" == *"PVT_${YO_TEST_FAIL_EDIT_PROJECT}"* ]]; then
        printf 'Forced edit failure for project %s\n' "$YO_TEST_FAIL_EDIT_PROJECT" >&2
        return 1
      fi
      ;;
    'project field-create') ;;
    'issue create') printf '%s\n' 'https://github.com/tracker/to-do/issues/99' ;;
    'api repos/tracker/to-do/issues/12/sub_issues') printf '%s\n' '[]' ;;
    'api repos/tracker/to-do/issues/12/parent') printf '%s\n' 'null' ;;
    *) printf 'Unexpected gh invocation: %s\n' "$*" >&2; return 1 ;;
  esac
}
export -f gh

./scripts/yo-gh resolve-repos repo:emailage-infrastructure-vpc repo:another-org/service repo:emailage-infrastructure-vpc |
  jq -e '. == ["another-org/service", "tracker/emailage-infrastructure-vpc"]' >/dev/null
YO_REPO_OWNER=custom ./scripts/yo-gh resolve-repos repo:service |
  jq -e '. == ["custom/service"]' >/dev/null
for label in repo: repo:../bad repo:owner/repo/extra unrelated; do
  if ./scripts/yo-gh resolve-repos "$label" >/dev/null 2>&1; then
    printf 'Accepted invalid label: %s\n' "$label" >&2
    exit 1
  fi
done
./scripts/yo-gh config |
  jq -e '.repoOwner == "tracker" and .owner == "person" and .trackingRepo == "tracker/to-do" and .project == null and .projects == [{"number":4,"title":"Personal"},{"number":7,"title":"Side"}]' >/dev/null
./scripts/yo-gh today |
  jq -s -e 'length == 2 and ([.[].project.number] | sort == [4, 7]) and all(.[]; .ref == "tracker/to-do#12")' >/dev/null
./scripts/yo-gh next |
  jq -e '.project.number == 4 and .priority == "High"' >/dev/null
./scripts/yo-gh show 12 |
  jq -e '.repos == ["another-org/service", "tracker/emailage-infrastructure-vpc"] and .number == 12 and .project == null and ([.project_memberships[].number] | sort == [4, 7])' >/dev/null
YO_REPO_OWNER=custom ./scripts/yo-gh show 12 |
  jq -e '.repos == ["another-org/service", "custom/emailage-infrastructure-vpc"]' >/dev/null
YO_TEST_NO_LABELS=1 ./scripts/yo-gh show 12 |
  jq -e '.repos == []' >/dev/null

: >"$YO_TEST_LOG"
YO_TEST_FORBID_LIST=1 YO_PROJECT=4 ./scripts/yo-gh config |
  jq -e '.project == 4 and .projects == [{"number":4,"title":"Personal"}]' >/dev/null
if grep -q '^project list ' "$YO_TEST_LOG"; then
  printf '%s\n' 'Explicit YO_PROJECT unexpectedly performed discovery' >&2
  exit 1
fi

: >"$YO_TEST_LOG"
./scripts/yo-gh status 12 'In Progress'
grep -Fq 'project item-edit --id ITEM_4 --project-id PVT_4 --field-id F_STATUS_4 --single-select-option-id O_STATUS_4_In Progress' "$YO_TEST_LOG"
grep -Fq 'project item-edit --id ITEM_7 --project-id PVT_7 --field-id F_STATUS_7 --single-select-option-id O_STATUS_7_In Progress' "$YO_TEST_LOG"

: >"$YO_TEST_LOG"
./scripts/yo-gh priority 12 Urgent
grep -Fq 'project item-edit --id ITEM_4 --project-id PVT_4 --field-id F_PRIORITY_4 --single-select-option-id O_PRIORITY_4_Urgent' "$YO_TEST_LOG"
grep -Fq 'project item-edit --id ITEM_7 --project-id PVT_7 --field-id F_PRIORITY_7 --single-select-option-id O_PRIORITY_7_Urgent' "$YO_TEST_LOG"

: >"$YO_TEST_LOG"
./scripts/yo-gh create 'Created once' --status Todo --priority High >/dev/null
[[ "$(grep -c '^issue create ' "$YO_TEST_LOG")" -eq 1 ]]
[[ "$(grep -c '^project item-add ' "$YO_TEST_LOG")" -eq 4 ]]

: >"$YO_TEST_LOG"
./scripts/yo-gh setup >/dev/null
grep -Fq 'project field-list 4 ' "$YO_TEST_LOG"
grep -Fq 'project field-list 7 ' "$YO_TEST_LOG"

: >"$YO_TEST_LOG"
if YO_TEST_NO_STATUS_PROJECT=4 ./scripts/yo-gh setup >/dev/null 2>&1; then
  printf '%s\n' 'setup succeeded despite a missing Status field' >&2
  exit 1
fi
grep -Fq 'project field-list 7 ' "$YO_TEST_LOG"

: >"$YO_TEST_LOG"
if YO_TEST_EMPTY_PROJECTS=1 ./scripts/yo-gh status 12 Todo >/dev/null 2>&1; then
  printf '%s\n' 'status succeeded without any project targets' >&2
  exit 1
fi
if grep -q '^project item-add ' "$YO_TEST_LOG"; then
  printf '%s\n' 'status mutated an issue without any project targets' >&2
  exit 1
fi
if YO_TEST_EMPTY_PROJECTS=1 ./scripts/yo-gh create 'No project' >/dev/null 2>&1; then
  printf '%s\n' 'create succeeded without any project targets' >&2
  exit 1
fi
if grep -q '^issue create ' "$YO_TEST_LOG"; then
  printf '%s\n' 'create opened an issue without any project targets' >&2
  exit 1
fi
if YO_TEST_EMPTY_PROJECTS=1 ./scripts/yo-gh setup >/dev/null 2>&1; then
  printf '%s\n' 'setup succeeded without any project targets' >&2
  exit 1
fi

if ! YO_TEST_PROJECT_LIMIT=1 ./scripts/yo-gh config >/dev/null 2>"$TEST_HOME/project-limit.err"; then
  printf '%s\n' 'config failed at the project discovery limit' >&2
  exit 1
fi
grep -Fq 'project discovery reached its limit of 200' "$TEST_HOME/project-limit.err"
if ! YO_TEST_ITEM_LIMIT=1 ./scripts/yo-gh today >/dev/null 2>"$TEST_HOME/item-limit.err"; then
  printf '%s\n' 'today failed at the item limit' >&2
  exit 1
fi
grep -Fq 'reached its item limit of 200' "$TEST_HOME/item-limit.err"

: >"$YO_TEST_LOG"
if YO_TEST_FAIL_EDIT_PROJECT=4 ./scripts/yo-gh status 12 Todo >/dev/null 2>"$TEST_HOME/partial-failure.err"; then
  printf '%s\n' 'status succeeded despite a project edit failure' >&2
  exit 1
fi
grep -Fq 'project item-edit --id ITEM_7 --project-id PVT_7 ' "$YO_TEST_LOG"
grep -Fq 'Status succeeded in #7; failed in #4' "$TEST_HOME/partial-failure.err"
printf '%s\n' 'yo-gh tests passed'