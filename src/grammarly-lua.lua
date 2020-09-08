--
-- grammarly-lua-0.1.0
--
-- The MIT License (MIT)
--
-- Copyright (c) 2020, Michal Hoftich
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
-- the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
-- FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
-- COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
-- IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--

local PKG_AUTHOR = 'Michal Hoftich'
local PKG_EMAIL = 'michal.h21@gmail.com'
local PKG_VERSION = '0.1.0-1'

local pegasus = require "pegasus"

-- 
local template = [[<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
</head>
<body>
  <form action="/send" method="post">
  <textarea name="text" cols="80" rows="40">%s</textarea><br />
  <input type="submit" /> <a href="/end"><button type="button">Close</button></a>
  </form>
  </body>
  </html>
]]

local redirect_template = [[
<html><head><meta http-equiv="Refresh" content="3; URL=%s"></head>
<body>Content updated</body>
</html>
]]


-- from https://gist.github.com/cgwxyz/6053d51e8d7134dd2e30
local function decodeURI(s)
  if(s) then
    s = string.gsub(s, "+", " ")
    s = string.gsub(s, '%%(%x%x)', 
       function (hex) return string.char(tonumber(hex,16)) end 
    )
  end
  return s
end

local function get_port()
  -- it should be configurable and detect which port is free
  return 9000
end

local function load_file(filename)
  local f = io.open(filename, "r")
  if not f then return nil, "Cannot open file" end
  local text = f:read("*all")
  f:close()
  return text
end

local function save_file(filename, text)
  local f = io.open(filename, "w")
  if not f then return nil, "cannot write file" end
  f:write(text)
  f:close()
  return true
end

local grammarly_lua = {
    _VERSION = '0.1.0-1',
}

---
-- load input file


local filename = arg[1]
if not filename then
  print("No filename")
  os.exit()
end

local text = load_file(filename)

if not text then
  print("Cannot load input file: " .. filename)
  os.exit()
end

-- declare server
local port = get_port()

local server = pegasus:new({
    port=port,
}) 

server:start(function(request, response)
  local headers = request:headers()
  local method = request:method()
  local path = request:path()
  if path == "/send" then
    local data = request:post()
    if data and data.text then
      text = decodeURI(data.text)
      print "------------------------"
      print "Saving text:"
      print( text)
      local status, err = save_file(filename, text)
      if not status then
        print(err, filename)
      end
    else
      print("Error: no text data send")
    end
    response:write(string.format(redirect_template, "http://localhost:" ..  port .."/"))
  elseif path == "/end" then
    response:write("Bye")
    os.exit()
  else
    response:write(string.format(template,text))
  end

end)



return grammarly_lua
