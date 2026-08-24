#!/usr/bin/env bash
#
# Read and update a Scaleway Secret Manager key_value secret, without losing keys.
#
# Scaleway secret versions are immutable, so "add one key" means: read the latest version, layer
# the change on top, write a whole new version. Done by hand in the console, that is exactly where
# an existing key gets dropped. This does it mechanically and checks nothing was lost.
#
# Built for the *-secrets-manual secrets that sysops-tf-modules/monorepo/scw/environment creates
# with prevent_destroy and deliberately never writes a scaleway_secret_version for.
#
# Nothing sensitive reaches argv: the write uses scw's data=@file form, and the token comes from
# the scw config or the environment. Values are never printed, only key names. The get outfile does
# contain values, that being the point of it.

set -euo pipefail
# Both the get outfile and the temp files hold plaintext secrets, and the caller's umask would
# usually leave them world-readable.
umask 077

readonly DEFAULT_REGION="nl-ams"

REGION="${SCW_SECRETS_REGION:-$DEFAULT_REGION}"
PROJECT_ID="${SCW_SECRETS_PROJECT_ID:-}"
PROJECT_NAME="${SCW_SECRETS_PROJECT_NAME:-}"
ORGANIZATION_ID="${SCW_SECRETS_ORGANIZATION_ID:-}"
ASSUME_YES=0
DRY_RUN=0
DESCRIPTION=""

SECRET_ID=""                    # set by resolve_secret
SECRET_VERSION_COUNT=0          # enabled versions, set by resolve_secret
SECRET_TOTAL_VERSION_COUNT=0    # versions in any state, set by resolve_secret
CREATED_REVISION=""             # set by create_version

TMPDIR_RUN=""
cleanup() {
	if [[ -n "$TMPDIR_RUN" ]]; then
		rm -rf -- "$TMPDIR_RUN"
	fi
}
# Not EXIT alone: bash does not run an EXIT trap on SIGTERM, and these files hold plaintext.
trap cleanup EXIT INT TERM HUP

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
warn() { printf 'warning: %s\n' "$*" >&2; }
info() { printf '%s\n' "$*" >&2; }

usage() {
	cat >&2 <<-'EOF'
	Usage:
	  manual_secrets.sh get <secret-name> [outfile]
	  manual_secrets.sh set <secret-name> <patch.json|->  [--dry-run] [--yes]

	  get   Fetch the latest version and write it as pretty JSON. Read-only.
	        outfile defaults to ./<secret-name>_<UTC timestamp>.json

	  set   Merge a JSON object of key/value pairs over the latest version and write a new
	        version. An existing key is overwritten, a new key is appended, nothing else is
	        touched. Pass - to read the patch from stdin.

	Options:
	  --region <r>       Scaleway region (default nl-ams, or $SCW_SECRETS_REGION).
	                     Note: your scw profile may default to fr-par, where these secrets
	                     do not exist, and a wrong region looks like "secret not found".
	  --project-id <id>  Scaleway project (default: the scw profile's default-project-id,
	                     or $SCW_SECRETS_PROJECT_ID)
	  --project-name <n> Scaleway project by name, looked up at run time (or
	                     $SCW_SECRETS_PROJECT_NAME). Terraform names every project
	                     <app>-<env>, so a caller that knows both needs no id.
	                     Mutually exclusive with --project-id.
	  --organization-id <id>  Organization to look --project-name up in (or
	                     $SCW_SECRETS_ORGANIZATION_ID). Defaults to the scw profile's.
	  --description <s>  Description recorded on the new version
	  --dry-run          Show the summary, write nothing
	  --yes              Do not prompt for confirmation

	Requires: scw (authenticated, see scw init), jq, base64.
	EOF
	exit "${1:-2}"
}

require_tools() {
	local t
	for t in scw jq base64; do
		command -v "$t" >/dev/null 2>&1 || die "$t is not installed"
	done
}

# Exists so a caller never has to hold an id: Terraform names every project <app_name>-<env_name>
# (sysops-tf-modules monorepo/wrappers/env), so app plus environment is enough to find it.
resolve_project() {
	local name="$1" json count
	local -a args=(account project list name="$name" -o json)
	if [[ -n "$ORGANIZATION_ID" ]]; then
		args+=(organization-id="$ORGANIZATION_ID")
	fi

	json=$(scw "${args[@]}" 2>&1) || die "scw account project list failed: $json"
	jq -e 'type == "array"' >/dev/null 2>&1 <<<"$json" \
		|| die "unexpected response from scw account project list: $json"

	json=$(jq --arg n "$name" '[.[] | select(.name == $n)]' <<<"$json")
	count=$(jq 'length' <<<"$json")

	case "$count" in
		0) die "no project named '$name'${ORGANIZATION_ID:+ in organization $ORGANIZATION_ID}. \
The filter returns an empty list rather than an error, so a project that does not exist and the \
wrong organization look identical here." ;;
		1) ;;
		*) die "$count projects named '$name'; refusing to guess" ;;
	esac

	PROJECT_ID=$(jq -r '.[0].id' <<<"$json")
	[[ -n "$PROJECT_ID" && "$PROJECT_ID" != "null" ]] || die "could not read the id of project '$name'"
}

# Both commands scope their secret lookup to a project, so this runs before resolve_secret in each.
ensure_project() {
	if [[ -z "$PROJECT_ID" && -n "$PROJECT_NAME" ]]; then
		resolve_project "$PROJECT_NAME"
		info "project $PROJECT_NAME -> $PROJECT_ID"
	fi
}

# The API's name filter is not guaranteed to be exact, so check the name ourselves and assert
# exactly one match.
#
# Sets globals rather than echoing: called as $(resolve_secret ...) it would run in a subshell,
# where die() exits only that subshell and the caller carries on with an empty id.
resolve_secret() {
	local name="$1" json count
	local -a args=(secret secret list name="$name" region="$REGION" -o json)
	if [[ -n "$PROJECT_ID" ]]; then
		args+=(project-id="$PROJECT_ID")
	fi

	json=$(scw "${args[@]}" 2>&1) || die "scw secret list failed: $json"
	jq -e 'type == "array"' >/dev/null 2>&1 <<<"$json" \
		|| die "unexpected response from scw secret list: $json"

	json=$(jq --arg n "$name" '[.[] | select(.name == $n)]' <<<"$json")
	count=$(jq 'length' <<<"$json")

	case "$count" in
		0) die "no secret named '$name' in region $REGION${PROJECT_ID:+ project $PROJECT_ID}. \
Wrong region is the usual cause: the filter returns an empty list rather than an error." ;;
		1) ;;
		*) die "$count secrets named '$name'; refusing to guess" ;;
	esac

	jq -e '.[0].type == "key_value"' >/dev/null <<<"$json" \
		|| die "secret '$name' is type $(jq -r '.[0].type' <<<"$json"), not key_value"

	SECRET_ID=$(jq -r '.[0].id' <<<"$json")
	[[ -n "$SECRET_ID" && "$SECRET_ID" != "null" ]] || die "could not read the id of '$name'"

	# Enabled versions rather than the secret's version_count, which also counts versions only
	# scheduled for deletion, so the read would 404 on a count that looks non-zero. Filtered here
	# rather than with status.0=enabled, which the CLI accepts and ignores.
	local versions
	versions=$(scw secret version list "$SECRET_ID" region="$REGION" -o json 2>&1) \
		|| die "scw secret version list failed: $versions"
	SECRET_VERSION_COUNT=$(jq '[.[] | select(.status == "enabled")] | length' <<<"$versions")
	SECRET_TOTAL_VERSION_COUNT=$(jq 'length' <<<"$versions")
}

# Writes to a file rather than stdout so it is never called from a pipeline, where it would run in
# a subshell and die() could not stop the caller. Same reason as resolve_secret.
fetch_latest() {
	local dest="$1" json data

	if [[ "$SECRET_VERSION_COUNT" -eq 0 ]]; then
		# No versions at all is how Terraform leaves *-secrets-manual. Versions that exist but are
		# all disabled is a different state: nothing is readable, so the new version holds only the
		# patch. Warned rather than refused, because the disabled versions survive and can be
		# re-enabled, and refusing would leave a caller with no Scaleway access unable to proceed.
		if [[ "$SECRET_TOTAL_VERSION_COUNT" -gt 0 ]]; then
			warn "all $SECRET_TOTAL_VERSION_COUNT version(s) are disabled, starting from empty; \
every other key in this secret stops being synced"
		else
			info "secret has no versions at all, starting from an empty object"
		fi
		printf '{}' > "$dest"
		return
	fi

	# latest_enabled matches the enabled count above. A rollback disables the newest version, which
	# latest would still point at, and the API refuses to read it.
	json=$(scw secret version access "$SECRET_ID" revision=latest_enabled region="$REGION" -o json 2>&1) \
		|| die "scw secret version access failed: $(head -c 400 <<<"$json")"

	# scw -o json leaves .data base64-encoded; it only decodes for human output.
	data=$(jq -r '.data // empty' <<<"$json")
	[[ -n "$data" ]] || die "latest version of $SECRET_ID has no data"

	base64 -d <<<"$data" > "$dest" || die "latest version of $SECRET_ID is not valid base64"
	# -s, not a bare -e: a stream of objects passes `type == "object"` value by value, and the
	# slurped merge in cmd_set would then read the second object as the patch.
	jq -se 'length == 1 and (.[0] | type == "object")' >/dev/null 2>&1 < "$dest" \
		|| die "latest version of $SECRET_ID is not a single JSON object"
}

# A key_value secret holds flat string values. Asserting that keeps the merge unambiguous and
# catches a malformed payload before it reaches a running pod through External Secrets Operator.
# A non-empty $3 downgrades an invalid key name to a warning, for a payload this run did not write:
# envFrom skips such a key and the pod runs on without it, so refusing would let one key added in the
# console block every later write by everyone.
assert_flat_string_object() {
	local file="$1" what="$2" lenient="${3:-}" bad
	jq -e 'type == "object"' >/dev/null < "$file" \
		|| die "$what is not a JSON object"
	bad=$(jq -r '[to_entries[] | select(.value | type != "string") | .key] | join(", ")' "$file")
	[[ -z "$bad" ]] || die "$what has non-string values for: $bad (key_value secrets hold strings)"

	# Fatal either way: a key holding a newline desyncs the four-line summary read in cmd_set, which
	# would then print a confident, wrong summary.
	bad=$(jq -r '[keys[] | select(test("[\\n\\r]")) | @json] | join(", ")' "$file")
	[[ -z "$bad" ]] || die "$what has key(s) containing a newline: $bad"

	# Keys become env var names in the pod through envFrom.
	bad=$(jq -r '[keys[] | select(test("^[A-Za-z_][A-Za-z0-9_]*$") | not) | @json] | join(", ")' "$file")
	if [[ -n "$bad" ]] && [[ -n "$lenient" ]]; then
		warn "$what has key(s) that are not valid env var names: $bad. envFrom skips them, so the \
pod never sees them. Not written by this run; fix them where they were added."
	elif [[ -n "$bad" ]]; then
		die "$what has key(s) that are not valid env var names: $bad"
	fi
}

cmd_get() {
	local name="${1:-}" outfile="${2:-}"
	[[ -n "$name" ]] || usage

	ensure_project
	resolve_secret "$name"
	info "secret $name -> $SECRET_ID ($SECRET_VERSION_COUNT version(s), region $REGION)"

	[[ -n "$outfile" ]] || outfile="./${name}_$(date -u +%Y%m%dT%H%M%SZ).json"

	# Global, not local, so the EXIT trap can remove it whichever way we leave.
	TMPDIR_RUN=$(mktemp -d)
	fetch_latest "$TMPDIR_RUN/latest.json"
	# -S sorts the keys, so two dumps of the same secret diff cleanly.
	jq -S . < "$TMPDIR_RUN/latest.json" > "$outfile"

	info ""
	info "wrote $(jq 'length' "$outfile") key(s) to $outfile:"
	jq -r 'keys[] | "  " + .' "$outfile" >&2
}

cmd_set() {
	local name="${1:-}" patch_arg="${2:-}"
	[[ -n "$name" && -n "$patch_arg" ]] || usage

	# Three files: what is stored now, what the caller wants changed, and the result. Keeping them
	# separate is what makes the summary and the safety check possible.
	TMPDIR_RUN=$(mktemp -d)
	local old="$TMPDIR_RUN/old.json"
	local patch="$TMPDIR_RUN/patch.json"
	local merged="$TMPDIR_RUN/merged.json"

	if [[ "$patch_arg" == "-" ]]; then
		cat > "$patch"
	else
		[[ -f "$patch_arg" ]] || die "patch file not found: $patch_arg"
		cat -- "$patch_arg" > "$patch"
	fi
	# -s rejects a stream of values here, where the message is accurate. Plain `jq -e .` accepts
	# `{"a":"1"}{"b":"2"}` and the failure surfaces later with the wrong diagnosis.
	jq -se 'length == 1' >/dev/null 2>&1 < "$patch" || die "patch must be a single JSON object"
	assert_flat_string_object "$patch" "patch"
	[[ "$(jq 'length' "$patch")" -gt 0 ]] || die "patch is empty, nothing to do"

	ensure_project
	resolve_secret "$name"
	info "secret $name -> $SECRET_ID ($SECRET_VERSION_COUNT version(s), region $REGION)"

	fetch_latest "$old"
	assert_flat_string_object "$old" "current version of $name" lenient

	# `+` is a shallow, right-wins merge: existing key overwritten, new key appended, every other
	# key carried over. Deliberately not `*`, which merges recursively.
	jq -sS '.[0] + .[1]' "$old" "$patch" > "$merged"

	# Nothing already stored may be lost. Checking only for missing keys can never fail, since `+`
	# cannot drop one, so check the values of the keys this call does not touch: that is what breaks
	# if the merge operator above is ever changed.
	local harmed
	harmed=$(jq -rn --slurpfile o "$old" --slurpfile p "$patch" --slurpfile m "$merged" '
		$o[0] as $old | $p[0] as $patch | $m[0] as $merged
		| [ $old | keys[] | . as $k
		    | select(($patch | has($k)) | not)
		    | select((($merged | has($k)) | not) or ($merged[$k] != $old[$k])) ]
		| join(", ")')
	[[ -z "$harmed" ]] || die "merge would drop or alter untouched key(s): $harmed. Refusing to write."

	# Computed from old versus patch, not from merged, so the summary shows the intent of this
	# call: what is new, what changes, what was sent but changes nothing, and how much this call
	# does not touch. Names only, never values.
	local added changed identical untouched summary
	summary=$(jq -rn --slurpfile o "$old" --slurpfile p "$patch" '
		$o[0] as $old | $p[0] as $new
		| ($new | keys) as $new_keys
		| [ ($new_keys - ($old | keys) | join(", ")),
		    ([$new_keys[] | . as $k | select(($old | has($k)) and $old[$k] != $new[$k])] | join(", ")),
		    ([$new_keys[] | . as $k | select(($old | has($k)) and $old[$k] == $new[$k])] | length),
		    (($old | keys) - $new_keys | length) ]
		| .[]') || die "could not compute the change summary"
	# Four lines, in order. Fewer means the jq above changed shape, and carrying on would print a
	# confident summary built from empty variables.
	{
		read -r added
		read -r changed
		read -r identical
		read -r untouched
	} <<<"$summary" || die "change summary was incomplete, refusing to write"

	info ""
	info "added:              ${added:-(none)}"
	info "overwritten:        ${changed:-(none)}"
	info "already identical:  $identical"
	info "carried over:       $untouched"
	info "result:             $(jq 'length' "$merged") key(s), was $(jq 'length' "$old")"
	info ""

	# Versions are immutable and accumulate, and a run of identical revisions makes the console
	# history useless for working out when a value actually changed.
	if [[ -z "$added" && -z "$changed" ]]; then
		info "nothing would change, not writing a new version"
		return 0
	fi

	if [[ "$DRY_RUN" -eq 1 ]]; then
		info "dry run, not writing"
		return 0
	fi

	if [[ "$ASSUME_YES" -eq 0 ]]; then
		local reply
		# A runner has no controlling terminal, and the bare redirect below fails with "No such
		# device or address", which does not say what to do about it.
		( exec < /dev/tty ) 2>/dev/null \
			|| die "no terminal for the confirmation prompt; pass --yes"
		# From the terminal, not stdin: with `set <name> -` the patch came from stdin, which is now
		# at EOF, and the prompt would answer itself with an empty line.
		read -r -p "Write a new version of $name? [y/N] " reply < /dev/tty
		[[ "$reply" == "y" || "$reply" == "Y" ]] || die "aborted"
	fi

	create_version "$merged" "$name"

	if [[ -n "$CREATED_REVISION" ]]; then
		info "wrote revision $CREATED_REVISION of $name"
	else
		info "wrote a new version of $name"
	fi
	info "the previous revision stays enabled, so rollback in the console remains possible"
}

# data=@file is scw's file-loading form: the CLI reads the file itself, so the payload never reaches
# argv, and it base64-encodes it for the API on its own.
#
# Sets CREATED_REVISION rather than echoing it, for the same subshell reason as resolve_secret.
create_version() {
	local merged="$1" name="$2" json

	# disable-previous omitted deliberately, so the previous version stays enabled.
	json=$(scw secret version create "$SECRET_ID" \
		"data=@$merged" \
		"description=${DESCRIPTION:-updated by manual_secrets.sh}" \
		region="$REGION" -o json 2>&1) \
		|| die "creating a version of $name failed: $(head -c 400 <<<"$json")"

	# Left empty rather than fatal if it cannot be read: the version has been written by this
	# point, and failing here would report a successful write as an error.
	CREATED_REVISION=$(jq -r '.revision // empty' <<<"$json" 2>/dev/null) || CREATED_REVISION=""
}

main() {
	local -a positional=()
	while [[ $# -gt 0 ]]; do
		case "$1" in
			--region)      REGION="${2:?--region needs a value}"; shift 2 ;;
			--project-id)  PROJECT_ID="${2:?--project-id needs a value}"; shift 2 ;;
			--project-name) PROJECT_NAME="${2:?--project-name needs a value}"; shift 2 ;;
			--organization-id)
			               ORGANIZATION_ID="${2:?--organization-id needs a value}"; shift 2 ;;
			--description) DESCRIPTION="${2:?--description needs a value}"; shift 2 ;;
			--dry-run)     DRY_RUN=1; shift ;;
			--yes|-y)      ASSUME_YES=1; shift ;;
			-h|--help)     usage 0 ;;
			--)            shift; positional+=("$@"); break ;;
			-)             positional+=("$1"); shift ;;  # the stdin marker, not an option
			-*)            die "unknown option: $1" ;;
			*)             positional+=("$1"); shift ;;
		esac
	done

	# Either can also arrive through the environment, so name both sources: a precedence rule here
	# would resolve to one project while the caller believes it asked for the other.
	if [[ -n "$PROJECT_ID" && -n "$PROJECT_NAME" ]]; then
		die "--project-id and --project-name are mutually exclusive (also settable as \
SCW_SECRETS_PROJECT_ID and SCW_SECRETS_PROJECT_NAME)"
	fi

	# After parsing, so --help works on a machine without the tools installed.
	require_tools

	[[ ${#positional[@]} -ge 1 ]] || usage
	# Both subcommands take at most two operands. Silently ignoring a third hides a typo.
	[[ ${#positional[@]} -le 3 ]] || die "too many arguments: ${positional[*]:3}"

	case "${positional[0]}" in
		get) cmd_get "${positional[@]:1}" ;;
		set) cmd_set "${positional[@]:1}" ;;
		*)   usage ;;
	esac
}

main "$@"
