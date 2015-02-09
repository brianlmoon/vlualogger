#!/usr/bin/lua

-- vlualogger version 1.1

-- Copyright (c) 2010, Brian Moon
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
--  * Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
--  * Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
--  * Neither the name of  nor the names of its contributors may be used to
--    endorse or promote products derived from this software without specific
--    prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.

--[[

Example Apache configuration:

LogFormat "%v %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" vlualogger
CustomLog "|/usr/local/bin/vlualogger.lua /www/logs/%v/%Y%m%d-access.log" vlualogger

--]]


if arg[2] then
    FILE_CACHE_COUNT = tonumber(arg[2])
else
    FILE_CACHE_COUNT = 5
end

file_handles = {}

--
-- Returns the direcoty name for the given path
--
-- @param   string  path    The file path
-- @return  string
--

function dirname(path)
    return string.sub(path, 0, string.len(path) - string.find(string.reverse(path), "/"))
end


--
-- Returns a file handle to write for the given filename
--
-- @param   string  filename    The file to be opened for writing
-- @return  mixed
--

function open_file(filename)

    local myHandle = nil

    for k,handleInfo in pairs(file_handles) do


        if handleInfo.filename == filename then

            myHandle = handleInfo

            table.remove(file_handles, k)
            table.insert(file_handles, myHandle)

            print("Reusing file handle for " .. filename)

            return myHandle.handle
        end
    end

    print("Open new file for " .. filename)

    -- we didn't find an existing file handle
    os.execute("mkdir -p " .. dirname(filename))

    local newHandle = { filename=filename, handle=io.open(filename, "a") }
    table.insert(file_handles, newHandle)

    if #file_handles > FILE_CACHE_COUNT then
        table.remove(file_handles, 1)
    end

    return newHandle.handle

end

--
--
--  MAIN
--
--

picture = arg[1]

-- read the lines in table 'lines'
for line in io.lines() do

    line_picture = picture

    -- handle %v virtual host name substitution
    -- it should be the first part of the line
    if string.find(line_picture, "%v") then

        pos = string.find(line, " ")
        if pos then
            vhost = string.sub(line, 0, pos-1)
            line_picture = string.gsub(line_picture, "%%v", vhost)
            -- remove the vhost from the front of the line
            line = string.sub(line, string.len(vhost)+2)
        end
    end

    filename = os.date(line_picture)

    handle = open_file(filename)

    handle:write(line .. "\n")
    handle:flush()

end
