Config = {}

Config.progressbar = {
    show_bar = true, -- true | false
    bar_color = {50, 50, 50, 250}, -- R G B A | 0-255 example: {50, 50, 50, 250} = gray
    progress_bar_color = {255, 0, 0, 255}, -- R G B A | 0-255 | example: {255, 0, 0, 255} = red
    bar_x = 0.5, -- x.y
    bar_y = 0.95, -- x.y
    bar_width = 0.15, -- x.y
    bar_height = 0.015 -- x.y
}

Config.text = {
    show_text = true, -- true | false
    text_color = {255, 255, 255, 255}, -- R G B A | 0-255 | example: {255, 255, 255, 255} = white
    text_x = 0.5, -- x.y
    text_y = 0.9, -- x.y
    text_scale = 0.5 -- x.y
}

Config.repairkit = {
    repair_timer = 5, -- seconds | 30 = 30 seconds
    engine_destroy_percent = 5.0,
    repair_car_visual = true, -- true | false
    blacklist_jobs = {
        "mechanic"
    }
}

Config.engine_check = {
    smoke_start = 700.0, -- x.y | example: After 30% engine health loss, smoke will appear
    speed_reduce_start = 300.0, --x.y | example: After 70% engine health loss, max speed will divided by engine_health_percent_speed_reduce
    speed_reduce = 2.0, --x.y | example: After engine health loss (engine_health_speed_reduce), max speed will be divided by 2
    particle_dict = "core", -- particle dictionary
    particle_effect = "exp_grd_bzgas_smoke",
    particle_size = 0.3,
    damage_modifier = 5.0
}