-- 
-- Abstract: List View sample app
--  
-- Version: 2.0
-- 
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2013 Corona Labs Inc. All Rights Reserved.

local m = {
   tests = {},
}

require("lunatest")

local list

function showTestResults()
   local backButton
   display.setStatusBar( display.HiddenStatusBar ) 

   -- Import the widget library
   local widget = require( "widget" )

   -- create a constant for the left spacing of the row content
   local LEFT_PADDING = 10

   --Set the background to white
   display.setDefault( "background", 255, 255, 255 )

   --Create a group to hold our widgets & images
   local widgetGroup = display.newGroup()

   -- The gradient used by the title bar
   local titleGradient = graphics.newGradient( 
      { 189, 203, 220, 255 }, 
      { 89, 116, 152, 255 }, "down" )

   -- Create toolbar to go at the top of the screen
   local titleBarHeight = 44
   local titleBar = display.newRect( 0, 0, display.contentWidth, titleBarHeight)
   titleBar.y = display.statusBarHeight + ( titleBar.contentHeight * 0.5 )
   titleBar:setFillColor( titleGradient )
   titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5

   -- create embossed text to go on toolbar
   local titleText = display.newEmbossedText("Unit tests", 0, 0, native.systemFontBold, 20 )
   titleText:setReferencePoint( display.CenterReferencePoint )
   titleText:setTextColor(255)
   titleText.x = display.contentWidth / 2
   titleText.y = titleBar.y

   --Text to show which item we selected
   local itemSelected = display.newText( "You selected item ", 0, 0, 300, 0, "Helvetica", 20)
   itemSelected:setTextColor( 0 )
   itemSelected.x = display.contentWidth + itemSelected.contentWidth * 0.5
   itemSelected.y = display.contentCenterY

   -- Scroll view to show error message
   local scrollView = widget.newScrollView
   {
      left = 0,
      top = 0,
      width = display.contentWidth,
      height = display.contentHeight - 100,
      bottomPadding = 50,
      id = "onBottom",
      horizontalScrollDisabled = true,
      verticalScrollDisabled = false,
      listener = scrollListener,
   }
   scrollView:insert(itemSelected)
   widgetGroup:insert(scrollView)

   -- Forward reference for our back button & tableview

   -- Handle row rendering
   local function onRowRender( event )
      local phase = event.phase
      local row = event.row
      local test = m.tests[row.index]
      local rowTitle = display.newText( row, test.rowName(), 0, 0, native.systemFontBold, 16 )

      rowTitle.x = row.x - ( row.contentWidth * 0.5 ) + ( rowTitle.contentWidth * 0.5 ) + LEFT_PADDING
      rowTitle.y = row.contentHeight * 0.5
      rowTitle:setTextColor(unpack(test.fontColor()))
   end

   -- Hande row touch events
   local function onRowTouch( event )
      local phase = event.phase
      local row = event.target
      local test = m.tests[row.index]
      
      if "press" == phase then
         -- print( "Pressed row: " .. row.index )
      elseif "release" == phase then
         -- Update the item selected text
         if test.succ then
            itemSelected.text = test.testName() .. " succeeded"
         else
            local errMsg = string.format("FAIL: %s: %s",
                                         test.name or "(unknown)",
                                         test.err and tostring(test.err.reason) or "")
            itemSelected.text = errMsg
         end
         itemSelected:setTextColor(unpack(test.fontColor()))
         
         --Transition out the list, transition in the item selected text and the back button
         transition.to( list, { x = - list.contentWidth, time = 400, transition = easing.outExpo } )
         transition.to( itemSelected, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
         transition.to( backButton, { alpha = 1, time = 400, transition = easing.outQuad } )
      end
   end

   -- Create a tableView
   list = widget.newTableView
   {
      top = 38,
      width = 320, 
      height = 448,
      onRowRender = onRowRender,
      onRowTouch = onRowTouch,
   }

   --Insert widgets/images into a group
   widgetGroup:insert( list )
   widgetGroup:insert( titleBar )
   widgetGroup:insert( titleText )


   --Handle the back button release event
   local function onBackRelease()
      --Transition in the list, transition out the item selected text and the back button
      transition.to( list, { x = 0, time = 400, transition = easing.outExpo } )
      transition.to( itemSelected, { x = display.contentWidth + itemSelected.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
      transition.to( backButton, { alpha = 0, time = 400, transition = easing.outQuad } )
   end

   --Create the back button
   backButton = widget.newButton
   {
      width = 298,
      height = 56,
      label = "Back", 
      labelYOffset = - 1,
      onRelease = onBackRelease
   }
   backButton.alpha = 0
   backButton.x = display.contentCenterX
   backButton.y = display.contentHeight - backButton.contentHeight
   widgetGroup:insert( backButton )
end

function m:run(tbl)
   local tbl = tbl or {}
   self.main_mod = tbl["main"] or "_main"
   local skip = tbl["skip"] or false
   if skip then
      m:runMain()
   else
      lunatest.run()
   end
end

function m:runMain()
   require(self.main_mod)
end

function m:suite(test_file)
   if type(test_file) == "table" then
      for i = 1, #test_file do
         lunatest.suite(test_file[i])
      end
   else
      lunatest.suite(test_file)
   end
   return self
end

lunatest.result_cb = function(ok, err, f)
   local test = m:findByFunction(f)
   test.succ = not not ok
   if not ok then
      test.err = err
   end
end

lunatest.all_finished_cb = function()
   if m:anyFail() then
      showTestResults()
      for i = 1, #m.tests do
         list:insertRow {
            height = 72,
         }
      end
   else
      m:runMain()
   end
end

function newTest(name, f, modname)
   local obj = {modname=modname, f=f, name=name,}
   function obj.rowName()
      local name = obj.testName()
      if obj["succ"] == nil then
         return "? " .. name
      elseif obj["succ"] then
         return "o " .. name
      else
         return "x " .. name
      end
   end

   function obj.testName()
      return obj["modname"] .. "/" .. obj["name"]
   end

   function obj.fontColor()
      if obj["succ"] == nil then
         return {0, 0, 0}
      elseif obj["succ"] then
         return {0x1B, 0xA4, 0x66}
      else
         return {0xD0, 0x42, 0x55}
      end
   end
   return obj
end

lunatest.add_suite_cb = function(modname, ok, err)
   if not ok then
      test = newTest(err, nil, modname)
      test.succ = false
      table.insert(m.tests, test)
   end
end

lunatest.add_test_cb = function(name, f, modname)
   table.insert(m.tests, newTest(name, f, modname))
end

function m:findByFunction(f)
   for i = 1, #self.tests do
      if self.tests[i]["f"] == f then
         return self.tests[i]
      end
   end
end

function m:anyFail()
   for i = 1, #self.tests do
      if not self.tests[i].succ then return true end
   end
   return false
end

return m
