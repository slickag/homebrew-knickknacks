#!/bin/bash
# git clone "https://github.com/cloudflare/quiche.git"
# cd quiche/quiche
sed -i '' 's/crate-type = .*/crate-type = ["staticlib"]/' "quiche/Cargo.toml"

cargo build --release --package quiche --features ffi,pkg-config-meta,qlog
