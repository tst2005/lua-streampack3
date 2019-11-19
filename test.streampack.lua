local streampack = require "streampack"
local encode = assert(streampack.encode)
local decode = assert(streampack.decode)

--local src = [[abcaabbccaaabbbccc]]
--local alphabet = {"a","b","c"}

do
	local alphabet = {"a","b"}
	local encoded = ([[aa BBB aa bb AAA bb ab ABAB ab]]):gsub(" ","")
	print(table.concat(decode(encoded, 2, alphabet), "\n"))
end

do
	local alphabet = {"a","b"}
	-- result: aa ab ba bb
	local encoded = ([[bb aaa bb aa bbabb aa]]):gsub(" ","")
	print(table.concat(decode(encoded, 2, alphabet),""))
end

do
	local alphabet = {"a","b"}
	-- result: aa ab ba bb
	local encoded = ([[b aaa b a bb a b a b a bb a]]):gsub(" ","")
	print(table.concat(decode(encoded, 1, alphabet),""))
end

do
        local alphabet = {"a","b"}
	local encoded = ([[b aaa b a bb a b a b a bb a]]):gsub(" ","")
	local decode_seg = assert(streampack.decode_seg)
	local f = decode_seg(encoded, 1, alphabet)
	local seg1 = f()
	local seg2 = f()
	local seg3 = f()
	local seg4 = f()
	local seg5 = f()
	print(seg1, seg2, seg3, seg4, seg5)
end
