#!/usr/bin/env bash
# atfile-release=ignore

function atfile.release() {
    # shellcheck disable=SC2154
    [[ $_os != "linux" ]] && atfile.die "Only available on Linux (GNU)\n↳ Detected OS: $_os"

    function atfile.release.get_devel_value() {
        local file="$1"
        local value="$2"
        local found_line

        found_line="$(grep '^# atfile-release=' "$file" | head -n1)"
        if [[ -n "$found_line" ]]; then
            local devel_values="${found_line#*=}"
            IFS=',' read -ra arr <<< "$devel_values"
            for v in "${arr[@]}"; do
                if [[ "$v" == "$value" ]]; then
                    echo 1
                fi
            done
        fi
    }

    function atfile.release.replace_template_var() {
        string="$1"
        key="$2"
        value="$3"

        sed -s "s|{:$key:}|$value|g" <<< "$string"
    }

    atfile.util.check_prog "git"
    atfile.util.check_prog "md5sum"
    atfile.util.check_prog "shellcheck"

    id="$(atfile.util.get_random 13)"
    commit_author="$(git config user.name) <$(git config user.email)>"
    commit_hash="$(git rev-parse HEAD)"
    commit_date="$(git show --no-patch --format=%ci "$commit_hash")"
    # shellcheck disable=SC2154
    dist_file="$(echo "$_prog" | cut -d "." -f 1)-${_version}.sh"
    # shellcheck disable=SC2154
    dist_dir="$_prog_dir/bin"
    dist_path="$dist_dir/$dist_file"
    dist_path_relative="$(realpath --relative-to="$(pwd)" "$dist_path")"
    parsed_version="$(atfile.util.parse_version "$_version")"
    version_record_id="atfile-$parsed_version"

    test_error_count=0
    test_info_count=0
    test_style_count=0
    test_warning_count=0
    test_ignore_count=0

    atfile.say "⚒️  Building..."

    echo "↳ Creating '$dist_file'..."
    mkdir -p "$dist_dir"
    echo "#!/usr/bin/env bash" > "$dist_path"

    echo "↳ Generating header..."
    echo -e "\n# ATFile <${ATFILE_FORCE_META_REPO}>
# ---
# Version: $_version
# Commit:  $commit_hash
# Author:  $commit_author
# Build:   $id ($(hostname):$(atfile.util.get_os))
# ---
# Psst! You can \`source atfile\` in your own Bash scripts!
" >> "$dist_path"

    for s in "${ATFILE_DEVEL_INCLUDES[@]}"
    do
        if [[ -f "$s" ]]; then
            if [[ $(atfile.release.get_devel_value "$s" "ignore" == 1 ) ]]; then
                echo "↳ Ignoring:  $s"
            else
                echo "↳ Compiling: $s"

                while IFS="" read -r line
                do
                    include_line=1

                    if [[ $line == "#"* ]] ||\
                        [[ $line == *"    #"* ]] ||\
                        [[ $line == "    " ]] ||\
                        [[ $line == "" ]]; then
                        include_line=0
                    fi

                    if [[ $line == *"# shellcheck disable"* ]]; then
                        if [[ $line == *"=SC2154"* ]]; then
                            include_line=0
                        else
                            include_line=1
                            (( test_ignore_count++ ))
                        fi
                    fi

                    if [[ $include_line == 1 ]]; then
                        if [[ $line == *"{:"* && $line == *":}"* ]]; then
                            # NOTE: Not using atfile.util.get_envvar() here, as confusion can arise from config file
                            line="$(atfile.release.replace_template_var "$line" "meta_author" "$ATFILE_FORCE_META_AUTHOR")"
                            line="$(atfile.release.replace_template_var "$line" "meta_did" "$ATFILE_FORCE_META_DID")"
                            line="$(atfile.release.replace_template_var "$line" "meta_repo" "$ATFILE_FORCE_META_REPO")"
                            line="$(atfile.release.replace_template_var "$line" "meta_year" "$ATFILE_FORCE_META_YEAR")"
                            line="$(atfile.release.replace_template_var "$line" "version" "$ATFILE_FORCE_VERSION")"
                        fi

                        echo "$line" >> "$dist_path"
                    fi
                done < "$s"
            fi
        fi
    done
    
    echo -e "\n# \"Four million lines of BASIC\"\n#  - Kif Kroker (3003)" >> "$dist_path"

    checksum="$(atfile.util.get_md5 "$dist_path" | cut -d "|" -f 1)"

    echo "🧪 Testing..."
    shellcheck_output="$(shellcheck --format=json "$dist_path" 2>&1)"

    while read -r item; do
        code="$(echo "$item" | jq -r '.code')"
        col="$(echo "$item" | jq -r '.column')"
        line="$(echo "$item" | jq -r '.line')"
        level="$(echo "$item" | jq -r '.level')"
        message="$(echo "$item" | jq -r '.message')"

        case "$level" in
            "error") level="🛑 Error"; (( test_error_count++ )) ;;
            "info") level="ℹ️  Info"; (( test_info_count++ )) ;;
            "style") level="🎨 Style"; (( test_style_count++ )) ;;
            "warning") level="⚠️  Warning"; (( test_warning_count++ )) ;;
        esac

        echo "↳ $level ($line:$col): [SC$code] $message"
    done <<< "$(echo "$shellcheck_output" | jq -c '.[]')"

    test_total_count=$(( test_error_count + test_info_count + test_style_count + test_warning_count ))

    echo -e "---\n✅ Built: $_version
↳ Path: ./$dist_path_relative
 ↳ Check: $checksum
 ↳ Size: $(atfile.util.get_file_size_pretty "$(stat -c %s "$dist_path")")
 ↳ Lines: $(atfile.util.fmt_int "$(wc -l < "$dist_path")")
↳ Issues: $(atfile.util.fmt_int "$test_total_count")
 ↳ Error:   $(atfile.util.fmt_int "$test_error_count")
 ↳ Warning: $(atfile.util.fmt_int "$test_warning_count")
 ↳ Info:    $(atfile.util.fmt_int "$test_info_count")
 ↳ Style:   $(atfile.util.fmt_int "$test_style_count")
 ↳ Ignored: $(atfile.util.fmt_int "$test_ignore_count")
↳ ID: $id"

    chmod +x "$dist_path"

    # shellcheck disable=SC2154
    if [[ $_devel_publish == 1 ]]; then
        if [[ $test_error_count -gt 0 ]]; then
            atfile.die "Unable to publish ($test_error_count errors detected)"
        fi

        atfile.say "---\n✨ Updating..."
        atfile.auth "$_dist_username" "$_dist_password"
        [[ $_version == *"+"* ]] && atfile.die "Cannot publish a Git version ($_version)"

        atfile.say "↳ Uploading '$dist_path'..."
        atfile.invoke.upload "$dist_path" "" "$version_record_id"
        # shellcheck disable=SC2181
        [[ $? != 0 ]] && atfile.die "Unable to upload '$dist_path'"

        latest_release_record="{
    \"version\": \"$_version\",
    \"releasedAt\": \"$(atfile.util.get_date "$commit_date")\",
    \"commit\": \"$commit_hash\",
    \"id\": \"$id\",
    \"checksum\": \"$checksum\"
}"

        atfile.say "↳ Bumping current version..."
        # shellcheck disable=SC2154
        atfile.invoke.manage_record put "at://$_username/self.atfile.latest/self" "$latest_release_record" &> /dev/null
    fi
}
