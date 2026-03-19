# Changelog

## [0.5.0](https://github.com/claude-contrib/claude-status/compare/v0.4.1...v0.5.0) (2026-03-19)


### Features

* add nix segment to status line ([c0409d2](https://github.com/claude-contrib/claude-status/commit/c0409d2764420908c61e4f724009f8081083e38a))
* **nix:** detect flake and pure shell environments ([b2ae725](https://github.com/claude-contrib/claude-status/commit/b2ae7252f81b9deb4dee7a22b3b7d609d5034e10))

## [0.4.1](https://github.com/claude-contrib/claude-status/compare/v0.4.0...v0.4.1) (2026-03-17)


### Bug Fixes

* **nix:** read version from version.txt instead of hardcoding it ([c3601e8](https://github.com/claude-contrib/claude-status/commit/c3601e8d34a9258b924011322a2b7cb95ad7754a))

## [0.4.0](https://github.com/claude-contrib/claude-status/compare/v0.3.1...v0.4.0) (2026-03-16)


### Features

* add docker container detection segment ([40bfd29](https://github.com/claude-contrib/claude-status/commit/40bfd29ca565eb981dffbb97b116b0187e2f822f))

## [0.3.1](https://github.com/claude-contrib/claude-status/compare/v0.3.0...v0.3.1) (2026-03-15)


### Bug Fixes

* replace tr with bash loops for locale-independent braille bar ([afb3a3e](https://github.com/claude-contrib/claude-status/commit/afb3a3e6bf54121757724b9f63044e3a0cef96a9))

## [0.3.0](https://github.com/claude-contrib/claude-status/compare/v0.2.0...v0.3.0) (2026-03-13)


### Features

* add Catppuccin theme system with external JSON theme files ([350208b](https://github.com/claude-contrib/claude-status/commit/350208bfba00a10a776b066dfc4e16fd6c37a2c2))
* detect git worktree when not started with --worktree flag ([386150a](https://github.com/claude-contrib/claude-status/commit/386150a7aa22b94a11d0b18e86fe13b500115d24))

## [0.2.0](https://github.com/claude-contrib/claude-status/compare/v0.1.0...v0.2.0) (2026-03-11)


### Features

* add Nix flake package and multi-install README ([e266356](https://github.com/claude-contrib/claude-status/commit/e2663564ba29de39179db8a7ca5ac15d670e1060))


### Bug Fixes

* adjust cost and branch color indices for dark theme ([6ab8b3d](https://github.com/claude-contrib/claude-status/commit/6ab8b3dcd8577a7302a0067147256c8fa8df97b7))
* adjust cost and branch colors to match preview (208 orange, 207 magenta) ([94b8341](https://github.com/claude-contrib/claude-status/commit/94b8341efa8a1b5f946a4dc321403fa856304384))
* force 256-color mode and revert cost/branch color indices ([e5b6b15](https://github.com/claude-contrib/claude-status/commit/e5b6b15df499d75dae7f56b1ef86eb49df6330a0))
* restore correct Nerd Font icons for dir, branch, worktree, and time segments ([889d60b](https://github.com/claude-contrib/claude-status/commit/889d60b91aa3c219e2e5f7d8df7c689b9b5cdf65))
* restore cost=208 and branch=207 to match preview ([597430b](https://github.com/claude-contrib/claude-status/commit/597430b8c4dbb4baa80c762b7f1bee829fbd1291))
* update context bar green to R136 G216 B138 ([7b9c91d](https://github.com/claude-contrib/claude-status/commit/7b9c91da1dd83e443f8dc1882181b8207ffc37c0))
* update worktree color to R254 G176 B92 ([289da19](https://github.com/claude-contrib/claude-status/commit/289da19e2d2e513368f1ff9dbc4ab38c4316fd16))
* use TrueColor RGB values for all color segments ([2d91223](https://github.com/claude-contrib/claude-status/commit/2d91223450ecbaefe7c8a2fea45704003c546da7))

## [0.1.0](https://github.com/claude-contrib/claude-status/compare/v0.0.1...v0.1.0) (2026-03-11)


### Features

* add CLAUDE_STATUS_THEME env var for dark/light palette switching ([3428588](https://github.com/claude-contrib/claude-status/commit/3428588cf70056eef442383f6d9dfd80e76c82d2))
* initial Claude Code statusline zinit plugin ([c12b282](https://github.com/claude-contrib/claude-status/commit/c12b282feda2da5fd7eae196e95164e597849f55))


### Bug Fixes

* rename CLAUDE_STATUS_THEME to CLAUDE_CODE_THEME ([5f1a7a9](https://github.com/claude-contrib/claude-status/commit/5f1a7a92d9b11fbcf98b74ddc2f6b013b6e8fa8d))
* use cool gray for context percentage and time segments ([71adc4e](https://github.com/claude-contrib/claude-status/commit/71adc4e250e212e817476001bff75e4817005585))

## [0.0.1](https://github.com/claude-contrib/claude-status/releases/tag/v0.0.1) (2026-03-11)


### Features

* initial Claude Code statusline zinit plugin ([c12b282](https://github.com/claude-contrib/claude-status/commit/c12b282feda2da5fd7eae196e95164e597849f55))
