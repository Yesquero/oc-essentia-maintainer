local function sleepMock(time)
	os.execute("sleep " .. tonumber(time) .. "s")
end

os.sleep = sleepMock
