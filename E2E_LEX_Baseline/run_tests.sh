#!/usr/bin/env bash
# Expected files are fixed requirements-based fixtures. Never rewrite them here.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
export LC_ALL=C
bash build.sh
mkdir -p tests/observed
{
    printf 'Run date (UTC): '
    date -u '+%Y-%m-%dT%H:%M:%SZ'
    uname -srm
    flex --version
    gcc --version
    printf 'Build: flex -o build/lex.yy.c scanner.l\n'
    printf 'Build: gcc -std=c11 -Wall -Wextra -Werror build/lex.yy.c -o build/quectoc-lexer\n'
} > tests/observed/environment.txt
printf 'test\tresult\texpected_status\tobserved_status\n' > tests/observed/results.tsv
passed=0
failed=0
while IFS=$'\t' read -r test_id input_file purpose; do
    [[ "$test_id" == 'id' || -z "$test_id" ]] && continue
    # The conditional deliberately permits expected non-zero scanner statuses.
    if ./build/quectoc-lexer < "$input_file" \
        > "tests/observed/$test_id.stdout" 2> "tests/observed/$test_id.stderr"; then
        scan_status=0
    else
        scan_status=$?
    fi
    printf '%s\n' "$scan_status" > "tests/observed/$test_id.status"
    result=PASS
    for stream in stdout stderr status; do
        if ! diff -u "tests/expected/$test_id.$stream" "tests/observed/$test_id.$stream"; then
            result=FAIL
        fi
    done
    expected_status=$(<"tests/expected/$test_id.status")
    printf '%s\t%s\t%s\t%s\n' "$test_id" "$result" "$expected_status" "$scan_status" \
        >> tests/observed/results.tsv
    printf '%s  %s\n' "$result" "$test_id"
    if [[ "$result" == PASS ]]; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
done < tests/cases.tsv
printf 'Tests: %s passed, %s failed\n' "$passed" "$failed"
if (( failed != 0 )); then exit 1; fi
