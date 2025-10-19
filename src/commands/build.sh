#!/usr/bin/env bash
# atfile-devel=ignore-build

function atfile.build() {
    # shellcheck disable=SC2154
    [[ $_os != "linux" ]] && atfile.die "Only available on Linux (GNU)\n↳ Detected OS: $_os"

    function atfile.build.get_devel_value() {
        local file="$1"
        local value="$2"
        local found_line

        found_line="$(grep '^# atfile-devel=' "$file" | head -n1)"
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

    function atfile.build.replace_template_var() {
        string="$1"
        key="$2"
        value="$3"

        sed -s "s|{:$key:}|$value|g" <<< "$string"
    }

    function atfile.build.pad_emoji() {
        emoji="$1"
        padding="$2"

        # shellcheck disable=SC2154
        if [[ $_ci == "tangled" ]]; then
            atfile.say.inline "$emoji"
        else
            atfile.say.inline "$emoji$padding"
        fi
    }

    atfile.util.check_prog "git"
    atfile.util.check_prog "grep"
    atfile.util.check_prog "hostname"
    atfile.util.check_prog "md5sum"
    atfile.util.check_prog "sed"
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
    dist_path_relative="$(realpath --relative-to="$(pwd)" "$dist_path" 2>/dev/null)"
    parsed_version="$(atfile.util.parse_version "$_version")"
    version_record_id="atfile-$parsed_version"

    test_error_count=0
    test_info_count=0
    test_style_count=0
    test_warning_count=0
    test_ignore_count=0

    if [[ -z "$dist_path_relative" ]]; then
        dist_path_relative="$dist_path"
    else
        dist_path_relative="./$dist_path_relative"
    fi

    atfile.say "$(atfile.build.pad_emoji "⚒️" " ") Building..."

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
            if [[ $(atfile.build.get_devel_value "$s" "ignore-build" == 1 ) ]]; then
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
                            line="$(atfile.build.replace_template_var "$line" "meta_author" "$ATFILE_FORCE_META_AUTHOR")"
                            line="$(atfile.build.replace_template_var "$line" "meta_did" "$ATFILE_FORCE_META_DID")"
                            line="$(atfile.build.replace_template_var "$line" "meta_repo" "$ATFILE_FORCE_META_REPO")"
                            line="$(atfile.build.replace_template_var "$line" "meta_year" "$ATFILE_FORCE_META_YEAR")"
                            line="$(atfile.build.replace_template_var "$line" "version" "$ATFILE_FORCE_VERSION")"
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
            "error") level="$(atfile.build.pad_emoji "🛑" "") Error"; (( test_error_count++ )) ;;
            "info") level="$(atfile.build.pad_emoji "ℹ️" " ") Info"; (( test_info_count++ )) ;;
            "style") level="$(atfile.build.pad_emoji "🎨" "") Style"; (( test_style_count++ )) ;;
            "warning") level="$(atfile.build.pad_emoji "⚠️" " ") Warning"; (( test_warning_count++ )) ;;
        esac

        echo "↳ $level ($line:$col): [SC$code] $message"
    done <<< "$(echo "$shellcheck_output" | jq -c '.[]')"

    test_total_count=$(( test_error_count + test_info_count + test_style_count + test_warning_count ))

    end_message_suffix_string="↳ Issues: $(atfile.util.fmt_int "$test_total_count")
 ↳ Error:   $(atfile.util.fmt_int "$test_error_count")
 ↳ Warning: $(atfile.util.fmt_int "$test_warning_count")
 ↳ Info:    $(atfile.util.fmt_int "$test_info_count")
 ↳ Style:   $(atfile.util.fmt_int "$test_style_count")
 ↳ Ignored: $(atfile.util.fmt_int "$test_ignore_count")
↳ ID: $id"

    atfile.say "---"

    if [[ $test_error_count -gt 0 ]]; then
        atfile.say "$(atfile.build.pad_emoji "⛔" "") Failed: $_version
$end_message_suffix_string" "" 31 31 1
        rm -f "$dist_path"
        exit 255
    else
        echo -e "$(atfile.build.pad_emoji "✅" "") Built: $_version
↳ Path: $dist_path_relative
 ↳ Check: $checksum
 ↳ Size: $(atfile.util.get_file_size_pretty "$(stat -c %s "$dist_path")")
 ↳ Lines: $(atfile.util.fmt_int "$(wc -l < "$dist_path")")
$end_message_suffix_string"
    fi

    chmod +x "$dist_path"

    # shellcheck disable=SC2154
    if [[ $_devel_enable_publish == 1 ]]; then
        atfile.say "---\n$(atfile.build.pad_emoji "✨" "") Updating..."
        atfile.auth "$_devel_dist_username" "$_devel_dist_password"
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

        atfile.say "---\n$(atfile.build.pad_emoji "⬆️" " ") Bumping..."
        # shellcheck disable=SC2154
        atfile.record update "at://$_devel_dist_username/self.atfile.latest/self" "$latest_release_record"
    fi
}
