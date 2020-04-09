#!/bin/sh

cd "$(dirname "$0")"
exec scss -t compact docs/css/extra.scss > docs/css/extra.css
