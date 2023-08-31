---
--- c4_queue Class
---
--- Copyright 2019 Control4 Corporation. All Rights Reserved.
---

require "lib.c4_object"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_queue = "2019.11.15"
end

---@class c4_queue: c4_object
c4_queue = inheritsFrom(nil)

---@alias queueOverflowBehaviour
---|`c4_queue.OVF_CLEAR` clear the queue, don't add
---|`c4_queue.OVF_IGNORE` do nothing, new element is lost
---|`c4_queue.OVF_RESET` clear the queue and then add the new element
---|`c4_queue.OVF_ROTATE` remove the oldest element fromt the queue and add the new one


--- clear the queue, don't add
c4_queue.OVF_CLEAR	= 1
--- do nothing, new element is lost
c4_queue.OVF_IGNORE	= 2
--- clear the queue and then add the new element
c4_queue.OVF_RESET	= 3
--- remove the oldest element fromt the queue and add the new one
c4_queue.OVF_ROTATE	= 4

---@param QueueName string
function c4_queue:construct(QueueName)
	-- entry table
	self._et = {}
	self._first = 0
	self._last = -1
	self._maxSize = 0	-- no size limit
	self._name = QueueName or ""
	self._overflowBehavior = c4_queue.OVF_ROTATE

	local mt = getmetatable(self)
	if (mt ~= nil) then
		mt.__tostring = self.__tostring
	end
end

---@param QueueName string
---@return c4_queue
function CreateQueue(QueueName)
	return c4_queue:new(QueueName)
end


function c4_queue:__tostring()
	local tOutputString = {}
	table.insert(tOutputString, "--- Queue ---")
	table.insert(tOutputString, "  name = " .. tostring(self._name))
	table.insert(tOutputString, "  first = " .. tostring(self._first))
	table.insert(tOutputString, "  last = " .. tostring(self._last))
	table.insert(tOutputString, "  number in queue = " .. tostring(self:size()))
	table.insert(tOutputString, "  maximum size = " .. tostring(self._maxSize))
	table.insert(tOutputString, "  next value = " .. tostring(self:value()))
	return table.concat(tOutputString, "\n")
end



---Push a value on the queue
---
---@param value any
function c4_queue:push(value)
	local AddIt = true
	if(not self:roomToAdd()) then
		if(self._overflowBehavior == c4_queue.OVF_CLEAR) then
			self:clear()
			AddIt = false

		elseif(self._overflowBehavior == c4_queue.OVF_IGNORE) then
			AddIt = false

		elseif(self._overflowBehavior == c4_queue.OVF_RESET) then
			self:clear()

		elseif(self._overflowBehavior == c4_queue.OVF_ROTATE) then
			self:pop()

		else
			LogError("c4_queue:push  Invalid behavior type: %s", tostring(self._overflowBehavior))
		end
	end

	if(AddIt) then
		self._last = self._last + 1
		self._et[self._last] = value
	end
end

---@return boolean roomToAdd
function c4_queue:roomToAdd()
	return ((self._maxSize == 0) or (self:size() < self:maxSize()))
end

---Pop a value from the queue
---
---@return any value
function c4_queue:pop()
	local RetVal = ""

	if(not self:empty()) then
		RetVal = self._et[self._first]
		self._et[self._first] = nil        -- to allow garbage collection
		self._first = self._first + 1
	end

	return RetVal
end

---Clear queue
function c4_queue:clear()
	self._et = {}
	self._first = 0
	self._last = -1
end

---Return value of first item.
---
---@return any value
function c4_queue:value()
	return self:empty() and "" or self._et[self._first]
end

---Return queue's maximum size.
---
---@return integer maxSize
function c4_queue:maxSize()
	return self._maxSize
end

---Set a queue's maximum size
---
---@param size integer
function c4_queue:setMaxSize(size)
	self._maxSize = size
end


---@param name string
function c4_queue:setName(name)
	self._name = name
end

---Return the queue's current size.
---
---@return integer queueSize
function c4_queue:size()
	return self._last - self._first + 1
end

---Checks if the queue is empty.
---
---@return boolean isEmpty
function c4_queue:empty()
	return (self._first > self._last)
end

---@param NewBehavior queueOverflowBehaviour
function c4_queue:setOverflowBehavior(NewBehavior)
	self._overflowBehavior = NewBehavior
end


--[[================================================================================
    c4_queue unit tests
--]]


function __test_c4_queue_basic()
	print("TEST:: c4_queue_basic")

	-- create an instance of the queue
	local c4Queue = CreateQueue("TestQBasic")

	c4Queue:push("Item #1 in Queue")
	c4Queue:push("Item #2 in Queue")
	c4Queue:push("Item #3 in Queue")
	c4Queue:push("Item #4 in Queue")

	assert(c4Queue:size() == 4, "TestQBasic Queue Wrong Size: " .. tostring(c4Queue:size()))
	assert(c4Queue:value() == "Item #1 in Queue", "TestQBasic Wrong value: " .. tostring(c4Queue:value()))

	print(c4Queue)
end


function __test_c4_queue_overflow_clear()
	print("TEST:: c4_queue_clear")

	-- create an instance of the queue
	local c4Queue = CreateQueue("TestQClear")
	c4Queue:setOverflowBehavior(c4_queue.OVF_CLEAR)
	c4Queue:setMaxSize(3)
	assert(c4Queue:maxSize() == 3, "_maxSize is not equal to '3' it is: " .. c4Queue:maxSize())

	c4Queue:push("Item #1 in Queue")
	c4Queue:push("Item #2 in Queue")
	c4Queue:push("Item #3 in Queue")
	c4Queue:push("Item #4 in Queue")

	assert(c4Queue:size() == 0, "TestQBasic Queue Wrong Size: " .. tostring(c4Queue:size()))

	print(c4Queue)
end

function __test_c4_queue_overflow_reset()
	print("TEST:: c4_queue_reset")

	-- create an instance of the queue
	local c4Queue = CreateQueue("TestQReset")
	c4Queue:setOverflowBehavior(c4_queue.OVF_RESET)
	c4Queue:setMaxSize(3)
	assert(c4Queue:maxSize() == 3, "_maxSize is not equal to '3' it is: " .. c4Queue:maxSize())

	c4Queue:push("Item #1 in Queue")
	c4Queue:push("Item #2 in Queue")
	c4Queue:push("Item #3 in Queue")
	c4Queue:push("Item #4 in Queue")

	assert(c4Queue:size() == 1, "TestQReset Queue Wrong Size: " .. tostring(c4Queue:size()))
	assert(c4Queue:value() == "Item #4 in Queue", "TestQReset Wrong value: " .. tostring(c4Queue:value()))

	print(tostring(c4Queue))
end

function __test_c4_queue_overflow_rotate()
	print("TEST:: c4_queue_rotate")

	-- create an instance of the queue
	local c4Queue = CreateQueue("TestQRotate")
	c4Queue:setOverflowBehavior(c4_queue.OVF_ROTATE)
	c4Queue:setMaxSize(3)
	assert(c4Queue:maxSize() == 3, "_maxSize is not equal to '3' it is: " .. c4Queue:maxSize())

	c4Queue:push("Item #1 in Queue")
	c4Queue:push("Item #2 in Queue")
	c4Queue:push("Item #3 in Queue")
	c4Queue:push("Item #4 in Queue")

	assert(c4Queue:size() == 3, "TestQRotate Queue Wrong Size: " .. tostring(c4Queue:size()))
	assert(c4Queue:value() == "Item #2 in Queue", "TestQRotate Wrong value: " .. tostring(c4Queue:value()))

	print(c4Queue)
end

function __test_c4_queue_overflow_ignore()
	print("TEST:: c4_queue_ignore")

	-- create an instance of the queue
	local c4Queue = CreateQueue("TestQIgnore")
	c4Queue:setOverflowBehavior(c4_queue.OVF_IGNORE)
	c4Queue:setMaxSize(3)
	assert(c4Queue:maxSize() == 3, "_maxSize is not equal to '3' it is: " .. c4Queue:maxSize())

	c4Queue:push("Item #1 in Queue")
	c4Queue:push("Item #2 in Queue")
	c4Queue:push("Item #3 in Queue")
	c4Queue:push("Item #4 in Queue")

	assert(c4Queue:size() == 3, "TestQIgnore Queue Wrong Size: %s", tostring(c4Queue:size()))
	assert(c4Queue:value() == "Item #1 in Queue", "TestQIgnore Wrong value: " .. tostring(c4Queue:value()))

	print(c4Queue)
end


function __test_c4_queue_all()
	local SuccessCount = 0

	local function QueueSubTest(TestTarg)
		print("")
		local testsuccess, err = pcall(TestTarg)
		if(testsuccess) then
			SuccessCount = SuccessCount + 1
		else
			print(err)
		end
	end

	print("test_c4_queue_all...")

	QueueSubTest(__test_c4_queue_basic)
	QueueSubTest(__test_c4_queue_overflow_clear)
	QueueSubTest(__test_c4_queue_overflow_reset)
	QueueSubTest(__test_c4_queue_overflow_rotate)
	QueueSubTest(__test_c4_queue_overflow_ignore)

	print("")
	print(string.format("...done %d tests succeeded", SuccessCount))
end


