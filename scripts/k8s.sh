#!/usr/bin/env bash
# kubectl current-context, truncated.

if ! command -v kubectl >/dev/null 2>&1; then exit 0; fi
ctx=$(kubectl config current-context 2>/dev/null)
[ -z "$ctx" ] && exit 0
# truncate long contexts
printf "%.20s" "$ctx"
