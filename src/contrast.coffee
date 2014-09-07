util = require './util.coffee'


# RGBからrelative luminanceを計算
#
# @param  {number[]} rgb
# @return {number}   luminance
#
rgb2luminance = (rgb) ->
    srgb = rgb.map (x) -> x / 255.0
    [rr, gr, br] = srgb.map relativify
    l = 0.2126 * rr + 0.7152 * gr + 0.0722 * br
    return l


# 人間の知覚に近い値にする？？
#
# @param  {number} v - RGBどれかの値
# @return {number}
#
relativify = (v) ->
    if v <= 0.03928
        return v / 12.92
    else
        return Math.pow((v + 0.055) / 1.055, 2.4)


# 指定したluminanceになるようrgbを変換
#
# @param  {number}   l   - relative luminance
# @param  {number[]} rgb - [0 - 255]
# @return {number[]} rgb
#
luminance2rgb = (l, rgb) ->
    [r, g, b] = (v / 255.0 for v in rgb)
    # 0.2126 * r * x + 0.7152 * g * x + 0.0722 * b * x == l
    x = 255 * l / (0.2126 * r + 0.7152 * g + 0.0722 * b)
    return x if not Number.isFinite x
    result = [r * x, g * x, b * x]
    return result


# Calculate light fromtground color on dark background.
#
# move saturation or lightness.
#
# @param  {number[]} bg    - Color of dark bg
# @param  {number}   ratio - Contrast ratio between bg & fg
# @param  {number}   hue   - Hue of fg
# @param  {string}   parameter - parameter to move, {s|l}.
# @return {number[]} color - Color of fg
#
lightOnDark = (bg, hsl, ratio, parameter) ->
    [hue, s, l] = formatHSL hsl

    # (luminance_fg + 0.05) / (luminance_bg + 0.05) > ratio
    luminance_bg = rgb2luminance bg

    # 気合で探す
    candidates = [0..100]
    hsl_candidates = switch parameter
        when 's' then [hue, c/100.0, l] for c in candidates
        when 'l' then [hue, s, c/100.0] for c in candidates

    readables = candidates.filter (c) ->
        rgb = hsl2rgb [hue, c / 100.0, l]
        luminance = rgb2luminance rgb
        return (luminance  + 0.05) / (luminance_bg + 0.05) > ratio

    # the color cant be readable
    return null if readables.length == 0

    p = if parameter == 's' then s else l
    p_nearest = -1
    diff_min = parseFloat 'inf'
    for r in readables
        diff = Math.abs(r - p)
        if diff < diff_min
            p_nearest = r
            min = diff
    return switch parameter
        when 's' then [hue, p_nearest, l]
        when 'l' then [hue, s, p_nearest]


# Calculate light fromtground color on dark background.
#
# move saturation or lightness.
#
# @param  {number[]} bg    - Color of dark bg
# @param  {number}   ratio - Contrast ratio between bg & fg
# @param  {number}   hue   - Hue of fg
# @param  {string}   parameter - parameter to move, {s|l}.
# @return {number[]} color - Color of fg in hsl
#
darkOnLight = (bg, hsl, ratio, parameter) ->
    [hue, s, l] = formatHSL hsl

    # (luminance_fg + 0.05) / (luminance_bg + 0.05) > ratio
    luminance_bg = rgb2luminance bg

    # 気合で探す
    candidates = (c / 100.0 for c in [0..100])
    readables = candidates.filter (c) ->
        hsl_candidate = switch parameter
            when 's' then [hue, c, l]
            when 'l' then [hue, s, c]
        rgb = hsl2rgb hsl_candidate
        luminance = rgb2luminance rgb
        return (luminance_bg  + 0.05) / (luminance + 0.05) > ratio

    # the color cant be readable
    return null if readables.length == 0

    p = if parameter == 's' then s else l
    p_nearest = -1
    diff_min = 2.0
    for r in readables
        diff = Math.abs(r - p)
        if diff < diff_min
            p_nearest = r
            diff_min = diff

    hsl_new = switch parameter
        when 's' then [hue, p_nearest, l]
        when 'l' then [hue, s, p_nearest]

    rgb_new = hsl2rgb hsl_new
    luminance_new = rgb2luminance rgb_new
    contrast_new = (luminance_bg  + 0.05) / (luminance_new + 0.05)

    return {
        hsl: hsl_new
        rgb: rgb_new
        contrast: contrast_new
    }

formatHSL = (hsl) ->
    [h, s, l] = hsl
    h = h % 360
    s = s / 100.0 if s > 1.0
    l = l / 100.0 if l > 1.0
    return [h, s, l]



# Convert hsl to rgb.
#
# @param  {number}   hsl   - [0-360, 0-1, 0-1]
# @param  {number[]} color - [0-255]
#
hsl2rgb = (hsl) ->
    [hue, s, l] = hsl
    h = hue / 60.0
    c = (1 - Math.abs(2 * l - 1)) * s
    x = c * (1 - Math.abs(h % 2 - 1))
    rgb = switch
        when h < 1.0 then [c, x, 0]
        when h < 2.0 then [x, c, 0]
        when h < 3.0 then [0, c, x]
        when h < 4.0 then [0, x, c]
        when h < 5.0 then [x, 0, c]
        when h < 6.0 then [c, 0, x]
    m = l - 0.5 * c
    return rgb.map (x) -> (x + m) * 255


hs2_l2rgb = (h, s) ->
    (l) -> hsl2rgb [h, s, l]

hl2_s2rgb = (h, l) ->
    (s) -> hsl2rgb [h, s, l]

h2_sl2rgb = (h) ->
    (s, l) -> hsl2rgb [h, s, l]

hhcl2rgb1 = (hh, c, l) ->
    cr = (((hh+5)%6)/4)|0
    xr = (((hh+1)%3)/2)|0
    cg = (((hh+3)%6)/4)|0
    xg = (((hh+2)%3)/2)|0
    cb = (((hh+1)%6)/4)|0
    xb = (((hh+3)%3)/2)|0
    return [cr*c + xr*x, cg*c + xg*x, cb*c + xb*x]

hh2_sl2rgb1 = (hh) ->
    (s, l) ->
        c = sl2c s, l
        hhcl2rgb1 hh, c, l

sl2c = (s, l) ->
    (1 - Math.abs(2*l - 1)) * s

sl2x = (s, l) ->
    c = sl2c s, l
    c * (1 - Math.abs(h % 2 - 1))


module.exports =
    darkOnLight: darkOnLight
    lightOnDark: lightOnDark
