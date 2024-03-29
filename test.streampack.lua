local encode = assert(require"streampack3.encoder-v1".encode)
local decode = assert(require"streampack3.decoder".decode)
local decode_seg = assert(require"streampack3.decoder".decode_seg)

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
	assert(decode_seg)
	local f = decode_seg(encoded, 1, alphabet)
	local seg1 = f()
	local seg2 = f()
	local seg3 = f()
	local seg4 = f()
	local seg5 = f()
	print(seg1, seg2, seg3, seg4, seg5)
end

do
	local data = "abbaaab"
	local raw_encoded = encode(data, 1)
	local function special(x)
		local i = i or 0
		return function(x)
			i = i or 0
			local a = x[i+1]
			local b = x[i+2]
			local c = x[i+3]
			i=i+3
			return a, b, c
		end, x
	end
	print("input:", data)
	for a,b,c in special(raw_encoded) do
		print("open:", a)
		print("", "", b)
		print("close", c)
	end

end
