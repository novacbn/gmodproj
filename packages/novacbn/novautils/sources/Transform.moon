import unpack from _G

import Signal from "novacbn/novautils/sources/Signal"
import pack from "novacbn/novautils/utilities"

-- Transform::Transform()
-- Represents a generic Transform dispatcher, useful for progressive dispatch returns
-- export
export Transform = Signal\extend {
    -- Transform::dispatch(any ...) -> any ...
    -- Dispatches the varargs to all the currently attached listeners, progressively modifiying the input varargs
    dispatch: (...) =>
        -- Pack the varargs to be transformed
        varRet = pack(...)

        -- Dispatch to each listener function, modifiying the input varargs
        local tempRet
        for node in self\iter()
            tempRet = pack(node.value(unpack(varRet)))
            varRet  = tempRet if #tempRet > 0

        -- Return the unmodified dispatch vararg
        return unpack(varRet)
}