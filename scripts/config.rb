#!/usr/bin/env ruby
require 'gollum/app'

# Per https://github.com/gollum/gollum-lib/issues/12
Gollum::Hook.register(:post_commit, :hook_id) do |committer, sha1|
  print("Running post-commit hook!\n")
  system('/var/share/gollum/post-commit')
end