package = "grammarly-lua"
version = "0.1.0-1"
source = {
  url = "https://github.com/michal-h21/grammarly-lua/archive/v0.1.0.tar.gz",
  dir = "grammarly-lua-0.1.0-1"
}
description = {
  summary = "grammarly-local",
  detailed = [[
    Check grammar for local files using Grammarly browser extension
  ]],
  homepage = "https://github.com/michal-h21/grammarly-local/",
  license = "MIT <http://opensource.org/licenses/MIT>"
}
dependencies = {
  "lua >= 5.1",
  "pegasus"
}
build = {
  type = "builtin",
   modules = {
    ["grammarly-lua"] = "src/grammarly-lua.lua"
  }
}
