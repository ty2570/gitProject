--[[
说明：已淡出效果切换指定源的显示隐藏效果
作者：陶敬义
时间：20180914
--]]

obs         = obslua
--hotkey_id   = obs.OBS_INVALID_HOTKEY_ID
mute_source_name = "图像"

----------------------------------------------------------
--设置指定名称的transition
function set_transition(name)

    local transtions = obs.obs_frontend_get_transitions()

    if transtions ~= nil then
        for _, transtion in ipairs(transtions) do
            local transtion_name = obs.obs_source_get_name(transtion)
            if(transtion_name == name) then
                obs.script_log(obs.LOG_INFO, "设置转场动画'"..name.."'")
                obs.obs_frontend_set_current_transition(transtion)
                break
            end
        end
    else
        obs.script_log(obs.LOG_INFO, "没有转场效果")
    end
    obs.source_list_release(transtions)
end

--切换指定场景指定名称源的显示隐藏状态
function switch_source_show(scene,name)
    local switch_ret = false

    local sources = obs.obs_scene_enum_items(scene)
    if sources ~= nil then    
        for _, source in ipairs(sources) do
            local source_obj = obs.obs_sceneitem_get_source(source)
            local source_name = obs.obs_source_get_name(source_obj)    
            if source_name == name then
                if obs.obs_sceneitem_visible(source) == true then
                    obs.obs_sceneitem_set_visible(source,false)
                else
                    obs.obs_sceneitem_set_visible(source,true)
                end
                switch_ret = true
                break
            end	
            
        end
    else
        obs.script_log(obs.LOG_WARNING, "场景下没有源")
    end
    obs.sceneitem_list_release(sources)

    return switch_ret
end

function switchsource(source_name)

    obs.script_log(obs.LOG_INFO, "切换'"..source_name.."'显示状态")

    local scene = obs.obs_frontend_get_current_scene()
	if scene ~= nil then
        local name = obs.obs_source_get_name(scene)
        local scene_obj = obs.obs_scene_from_source(scene)
        if scene_obj ~= nil then
            if switch_source_show(scene_obj,source_name) == true then
                set_transition("淡出")
                --[[
                -- obs-studio 原生版本用这个
                obs.obs_frontend_set_current_scene(scene)
                --]]
                obs.obs_frontend_set_current_scene_noTransPreview(scene)
                
            else
                obs.script_log(obs.LOG_WARNING, "切换'"..source_name.."'显示状态 失败")
            end
        else
            obs.script_log(obs.LOG_WARNING, "未找到source->scene")
        end			
    else
        obs.script_log(obs.LOG_WARNING, "未找到当前scene->source")
	end
    obs.obs_source_release(scene)
end

function switchscene(pressed,index)
    if not pressed then
		return
    end
    
    switchsource(mute_sources[index].name)
end

function mute_source_fun1(pressed)
    switchscene(pressed,1)
end

function mute_source_fun2(pressed)
    switchscene(pressed,2)
end

--要切换的 源 数组
mute_sources = {
    {name = "图像1", hotkey = obs.OBS_INVALID_HOTKEY_ID, fun = mute_source_fun1},
    {name = "图像2", hotkey = obs.OBS_INVALID_HOTKEY_ID, fun = mute_source_fun2},
}

function sourcesName()
    local name=""
    for _,mute_source in pairs(mute_sources) do
        name = name..mute_source.name..","
    end
    return name
end

----------------------------------------------------------

-- A function named script_update will be called when settings are changed
function script_update(settings)
	
end

-- A function named script_description returns the description shown to
-- the user
function script_description()
	return "切换'"..sourcesName().."'.\n\nMade by taojingyi"
end

-- A function named script_properties defines the properties that the user
-- can change for the entire script module itself
function script_properties()
	props = obs.obs_properties_create()

	return props
end

-- A function named script_load will be called on startup
function script_load(settings)
    for _,mute_source in pairs(mute_sources) do
        mute_source.hotkey = obs.obs_hotkey_register_frontend(mute_source.name, "切换'"..mute_source.name.."'", mute_source.fun)
        local hotkey_save_array = obs.obs_data_get_array(settings, mute_source.name)
        obs.obs_hotkey_load(mute_source.hotkey, hotkey_save_array)
        obs.obs_data_array_release(hotkey_save_array)
    end
	
end

-- A function named script_save will be called when the script is saved
--
-- NOTE: This function is usually used for saving extra data (such as in this
-- case, a hotkey's save data).  Settings set via the properties are saved
-- automatically.
function script_save(settings)
    for _,mute_source in pairs(mute_sources) do
        local hotkey_save_array = obs.obs_hotkey_save(mute_source.hotkey)
        obs.obs_data_set_array(settings, mute_source.name, hotkey_save_array)
        obs.obs_data_array_release(hotkey_save_array)
    end

end