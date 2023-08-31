---
--- Function for changing properties
---
--- Copyright 2020 Wirepath Home Systems LLC. All Rights Reserved.
---
require "common.c4_driver_declarations"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_property = "2020.09.23"
end



---Function called by Director when a property changes value. The value of the
---property that has changed can be found with: Properties[sName]. Note that
---OnPropertyChanged is not called when the Property has been changed by the
---driver calling the UpdateProperty command, only when the Property is changed
---by the user from the Properties Page. This function is called by Director
---when a property changes value.
---
---@param sProperty string Name of property that has changed.
function OnPropertyChanged(sProperty)
	local propertyValue = Properties[sProperty]

	if (LOG ~= nil and type(LOG) == "table") then
		LogTrace("OnPropertyChanged(" .. sProperty .. ") changed to: " .. Properties[sProperty])
	end

	-- Remove any spaces (trim the property)
	local trimmedProperty = string.gsub(sProperty, " ", "")
	local status = true
	local err = ""

	if (ON_PROPERTY_CHANGED[sProperty] ~= nil and type(ON_PROPERTY_CHANGED[sProperty]) == "function") then
		status, err = pcall(ON_PROPERTY_CHANGED[sProperty], propertyValue)
	elseif (ON_PROPERTY_CHANGED[trimmedProperty] ~= nil and type(ON_PROPERTY_CHANGED[trimmedProperty]) == "function") then
		status, err = pcall(ON_PROPERTY_CHANGED[trimmedProperty], propertyValue)
	end

	if (not status) then
		LogError("LUA_ERROR: " .. err)
	end
end

---Sets the value of the given property in the driver
---
---@param propertyName string The name of the property to change
---@param propertyValue string The value of the property being changed
function UpdateProperty(propertyName, propertyValue)
	if (Properties[propertyName] ~= nil) then
		C4:UpdateProperty(propertyName, propertyValue)
	end
end


---Gets the value of the given property in the driver.
---
---@param propertyName string The name of the property to get
---@return any value The value of the requested property.  Nil if it doesn't exist.
function GetPropertyValue(propertyName)
	return Properties[propertyName]
end


---Sets the property to not be shown on the properties page
---
---@param propertyName string The name of the property to hide
function HideProperty(propertyName)
	if (Properties[propertyName] ~= nil) then
		C4:SetPropertyAttribs(propertyName, 1)	-- hide the property
	end
end


---Sets the property to be shown on the properties page
---
---@param propertyName string The name of the property to show
function ShowProperty(propertyName)
	if (Properties[propertyName] ~= nil) then
		C4:SetPropertyAttribs(propertyName, 0)		-- show the property
	end
end
