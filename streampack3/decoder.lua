
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

-- read a mark
-- TODO: FEATURE: allow noise inside mark, we can read data, remove noise, stop reading when the mark is completed
-- current: only read a fixed size string as mark
local function readmark(fd, marksize, alphabet)
	local mark = fd:read(marksize)
	if mark == "" then -- end-of-data
		return nil
	end
	if #mark < marksize then
		error("EndOfStream: unable to read a valid mark")
	end
	assert(mark_is_valid(mark, alphabet))
	return mark
end


local function fd_decode_seg(fd, marksize, alphabet)
	local mark = readmark(fd, marksize, alphabet)
	if not mark then return nil end
	local seg, markfound = fd:read_until(mark)
	assert(mark==markfound)
	return seg
end

local function data_decode_seg(data, marksize, alphabet)
	assert(type(marksize)=="number")
	local fd = str2fd(data)
	local function f()
		local seg = fd_decode_seg(fd, marksize, alphabet)
		if not seg then return nil end
		return seg
	end
	return f
end
local function data_decode(data, marksize, alphabet)
	local result = {}
	local f = data_decode_seg(data, marksize, alphabet)
	local append = table.insert
	while true do
		local seg = f()
		if not seg then break end
		append(result, seg)
	end
	return result
end

return {decode=data_decode, decode_seg=data_decode_seg}
