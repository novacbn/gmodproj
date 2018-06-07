import unpack from _G

import Signal from "novacbn/novautils/sources/Signal"
import pack from "novacbn/novautils/utilities"

-- Event::Event()
-- Represents a generic Event dispatcher, useful for halting dispatch returns
-- export
export Event = Signal\extend {
    -- Event::dispatch(any ...) -> any ...
    -- Dispatches the varargs to all the currently attached listeners, halting on first return
    dispatch: (...) =>
        -- Dispatch to each listener function, returning a listener results if any
        local varRet
        for node in self\iter()
            varRet = pack(node.value(...))
            return unpack(varRet) if #varRet > 0

        -- Return the unmodified dispatch vararg
        return ...
}