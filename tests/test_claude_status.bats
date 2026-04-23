#!/usr/bin/env bats

@test "claude-status plugin file exists" {
  [ -f "${BATS_TEST_DIRNAME}/../claude-status.plugin.zsh" ]
}
