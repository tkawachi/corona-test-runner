module(..., package.seeall)
local app_main = require("app_main")

-- Sample test cases. Remove me.
function test_sample1()
   assert_true(not false)
end
function test_sample2()
   assert_equal("hello", string.lower("Hello"))
end
function test_sample3()
   -- This will fail
   assert_equal(3, 1 + 1)
end

-- Write tests about app_main
