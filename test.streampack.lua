local streampack = require "streampack"
local encode = assert(streampack.encode)
local decode = assert(streampack.decode)

--local src = [[abcaabbccaaabbbccc]]
--local alphabet = {"a","b","c"}

do
	local alphabet = {"a","b"}
	local encoded = [[aaBBBaabbAAAbbabABABab]]
	print(table.concat(decode(encoded, 2, alphabet), "\n"))
end

do
	local alphabet = {"a","b"}
	-- result: aa ab ba bb
	local encoded = [[bbaaabbaabbabbaa]]
	print(table.concat(decode(encoded, 2, alphabet),""))
end

do
	local alphabet = {"a","b"}
	-- result: aa ab ba bb
	local encoded = ([[b aaa b a bb a b a b a bb a]]):gsub(" ","")
	print(table.concat(decode(encoded, 1, alphabet),""))
end


