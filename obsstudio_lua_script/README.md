switchSourceShowFade.lua 
该脚本 通过快捷键 以淡出效果显示隐藏指定源。mute_sources数组里面是源，name是源的名称，fun 是切换回调，由于 快捷键的回调，没有userdata，所以只能定义多个回调函数。obs 支持的切换场景会交换预览场景和输出场景，该脚本里用的是修改过的切换场景方法，不会交换场景。
