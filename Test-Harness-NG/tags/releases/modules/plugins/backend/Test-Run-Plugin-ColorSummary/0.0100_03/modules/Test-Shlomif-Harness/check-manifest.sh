#!/bin/bash
cat file-list.txt | grep -v '/$' | sort | diff -u MANIFEST - |
    grep -vP '^\+bin/prove$' | grep -vP '^\+check-manifest\.sh$' |
    grep -vF META.yml | grep -v '^ ' | grep -vP '^(\+\+\+|\-\-\-|@@)'
