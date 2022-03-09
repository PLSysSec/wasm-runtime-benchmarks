# SQLite

Commands:
* `make speedtest1.wasm`: compiles speedtest1 against wasi
* `make speedtest1`: compiles the binary for `wasm2c-runner`
* `make run-wasmtime`: run speedtest1 with `wasmtime` (assume installed)
* `make run`: run speedtest1 with `wasm2c-runner`

Some links:

https://github.com/WebAssembly/wasi-filesystem/issues/15

https://github.com/WebAssembly/wasi-filesystem/issues/2

Tested with sqlite@4f2006ddec1f119026d87207d799feafe1d29f3a
