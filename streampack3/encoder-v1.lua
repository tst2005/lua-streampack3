
local function is_in_table(searchitem, items)
	for i,item in ipairs(items) do
		if item == searchitem then return true end
	end
	return false
end
assert(is_in_table("a", {"b", "a", "c"}))
assert(not is_in_table("A", {"b", "a", "c"}))

-- convert a string data to a file descriptor
local function str2fd(data)
	local fd = {pos=1}
	function fd:read(len)
		local pos = self.pos
		local seg = data:sub(pos,pos+len-1)
		self.pos=pos+#seg
		return seg
	end
	function fd:read_until(mark)
--print("find", mark, "in", data, "after", self.pos)
		local b,e = data:find(mark, self.pos, true)
		assert(b, "read_until: mark not found (mark="..mark..")")
		-- XXXXXXX MARK YYYY
		--         b  e
		local seg = data:sub(self.pos, b-1)
		local markfound = data:sub(b, e)
		self.pos = e+1
		return seg, markfound
	end
	function fd:seek(whence, offset)
		if whence == nil and offset == nil then
			return self.pos-1
		end
		if whence == "set" and offset == 0 then
			self.pos = offset+1
			return self.pos-1
		end
		error("unsupported/unimplemented seek request")
	end
	return fd
end

local function mark_is_valid(mark, alphabet)
	if alphabet == true then
		return true
	end
	-- check if substring of mark is present in alphabet
	for c in mark:gmatch(".") do
		if not is_in_table(c, alphabet) then
			return false
		end
	end
	return true
end
assert(mark_is_valid("abab", {"a", "b", "c"}))
assert(not mark_is_valid("aBab", {"a", "b", "c"}))


local function learn_from(seg, alphabet, hash)
	assert(alphabet)
	if not hash then
		hash = {}
	end
	for c in string.gmatch(seg, ".") do
		hash[c] = true
	end
	for c in pairs(hash) do
		table.insert(alphabet, c)
	end
	return
end
do
	local alphabet = {}
	learn_from("aabbab", alphabet, nil)
	assert(#alphabet==2)
	local alphabet = {}
	learn_from("aabbabcabaabb", alphabet, nil) 
	assert(#alphabet==3)
end

local function encode(data, marksize, alphabet)
	if type(data)=="string" then
		data = str2fd(data)
	end
	if alphabet == nil then
		alphabet={}
		local hash={}
		local seg = data:read(1024)
		learn_from(seg, alphabet, hash)
		assert(#alphabet>1)
		data:seek("set", 0)
		assert(data:seek() == 0)
	end

	local function choose_a_mark(alphabet, not_this)
		for _i,c in ipairs(alphabet) do
			if not is_in_table(c, not_this) then
				return c
			end
		end
	end
	local result = {}
	while true do
		local first_c = data:read(1)
		if first_c == "" then break end

--		local seg, markfound
--		local ok = pcall(function()
--			seg, markfound = data:read_until(first_c)
--		end)
--		if not ok then
--			seg = ""
--			print("data:read_until error")
--		else
--			print("data:read_until("..first_c..")", seg, markfound)
--		end

		local mark = choose_a_mark(alphabet, {first_c})
		table.insert(result, mark)
		table.insert(result, first_c) --..seg)

		table.insert(result, mark)
	end
	return result
end

return {encode=encode}
