#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
export LC_ALL=C
mkdir -p build
flex -o build/lex.yy.c scanner.l
gcc -std=c11 -Wall -Wextra -Werror build/lex.yy.c -o build/quectoc-lexer
printf 'Built build/quectoc-lexer\n'
