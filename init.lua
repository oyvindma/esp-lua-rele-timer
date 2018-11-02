-- Config
local action_button_1 = 7
local action_button_2 = 3

local rele_pin = 2 --4            --> GPIO2

-- init GPIO pin properly
-- some hardware might not need the "gpio.PULLUP" part, mine does
gpio.mode(action_button_1, gpio.INT, gpio.PULLUP)
gpio.mode(action_button_2, gpio.INT, gpio.PULLUP)

tmr.create():alarm(1, tmr.ALARM_SINGLE, function() print(0) end)


function debounce (func)
    local last = 0
    local delay = 1000000 -- 1000ms * 1000 as tmr.now() has μs resolution
    return function (...)
        local now = tmr.now()
        local delta = now - last
        if delta < 0 then delta = delta + 2147483647 end; -- proposed because of delta rolling over, https://github.com/hackhitchin/esp8266-co-uk/issues/2
        if delta < delay then return end;
        last = now
        return func(...)
    end
end

function powerOn()
    gpio.write(rele_pin, gpio.HIGH) 
end

function powerOff()
    gpio.write(rele_pin, gpio.LOW) 
    --print(tmr.now()-start)
end

-- define a callback function named "pin_cb", short for "pin callback"
function pin_cb_short()
    powerOn()
    tmr.create():alarm(2000, tmr.ALARM_SINGLE, powerOff)
end

function pin_cb_long()
    powerOn()
    tmr.create():alarm(3000, tmr.ALARM_SINGLE, powerOff)
end


gpio.mode(rele_pin, gpio.OUTPUT)
gpio.write(rele_pin, gpio.LOW)

-- register a button event
-- that means, what's registered here is executed upon button event "up"
gpio.trig(action_button_1, "down", debounce(pin_cb_short))
gpio.trig(action_button_2, "down", debounce(pin_cb_long))
