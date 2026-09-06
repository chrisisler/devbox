local function default_sink()
    local result = mp.command_native({
        name = "subprocess",
        args = {"pactl", "get-default-sink"},
        capture_stdout = true,
        capture_stderr = true,
    })

    if result.status ~= 0 then
        return nil
    end

    local sink = (result.stdout or ""):match("^%s*(.-)%s*$")
    if sink == "" then
        return nil
    end
    return sink
end

local function sync_audio_device()
    local sink = default_sink()
    if not sink then
        return
    end

    local device = "pulse/" .. sink
    if mp.get_property("audio-device") ~= device then
        mp.set_property("audio-device", device)
    end
end

mp.register_event("file-loaded", sync_audio_device)
mp.add_periodic_timer(1, sync_audio_device)
