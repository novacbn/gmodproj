mode = ({...})[1]

-- Make the mock data required for testing
if mode == "mock" then
    require "test/mock"
    return 0, "Successfully generated mock test data"

else
    -- Define all the unit tests
    require "test/commands"

    return test()