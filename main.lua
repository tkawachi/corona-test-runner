-- Main
require("test_main"):suite{
   -- Add test suite here
   "app_main_test",
}:run{
   -- skip = true, -- Skip tests and execute main (For production)
   -- main = "app_main", -- Specify application main
}
