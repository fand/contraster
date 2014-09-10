util = require './util.coffee'

# Candidates for fgOnBg; [0, 0.01, ... , 0.99, 1.00]
CANDIDATES = (c / 100.0 for c in [0..100])


# RGBからrelative luminanceを計算
#
# @param  {number[]} rgb
# @return {number}   luminance
#
rgb2L = (rgb) ->
    srgb = rgb.map (x) -> x / 255.0
    [rr, gr, br] = srgb.map relativify
    L = 0.2126 * rr + 0.7152 * gr + 0.0722 * br
    return L


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
lightOnDark = (bg, hsl, ratio, param_name) ->
    L2ratio = (L_bg, L_fg) -> (L_fg  + 0.05) / (L_bg + 0.05)
    fgOnBg bg, hsl, ratio, param_name, L2ratio


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
darkOnLight = (bg, hsl, ratio, param_name) ->
    L2ratio = (L_bg, L_fg) -> (L_bg  + 0.05) / (L_fg + 0.05)
    fgOnBg bg, hsl, ratio, param_name, L2ratio


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
fgOnBg = (bg, hsl, ratio, param_name, L2ratio) ->
    hsl = [hue, s, l] = formatHSL hsl
    L_bg = rgb2L bg

    # ratioを満たすパラメータを1-100の範囲で探す
    readables = CANDIDATES.filter (c) ->
        hsl_candidate = param2hsl hsl, c, param_name
        rgb = hsl2rgb hsl_candidate
        L = rgb2L rgb
        return ratio < L2ratio L_bg, L

    # the color cant be readable
    return null if readables.length == 0

    # 現在の値に最も近い候補を探す
    p = if param_name == 's' then s else l
    p_nearest = -1
    diff_min = 2.0
    for r in readables
        diff = Math.abs(r - p)
        if diff < diff_min
            p_nearest = r
            diff_min = diff

    hsl_new = param2hsl hsl, p_nearest, param_name
    rgb_new = hsl2rgb hsl_new
    L_new = rgb2L rgb_new
    contrast_new = L2ratio L_bg, L_new

    return {
        hsl: hsl_new
        rgb: rgb_new
        contrast: contrast_new
    }


# Put in a param into hsl array.
#
# @param {Number[]} hsl        - [0-360, 0-1, 0-1]
# @param {Number}   param      - parameter value
# @param {String}   param_name - 's' or 'l'
# @return {Number[]} - hsl with param
#
param2hsl = (hsl, param, param_name) ->
    switch param_name
        when 's' then [hsl[0], param, hsl[2]]
        when 'l' then [hsl[0], hsl[1], param]


# Format invalid values in HSL array.
#
# @param  {Number[]} hsl - hsl array to format
# @return {Number[]} - [0-360, 0-1, 0-1]
#
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


module.exports =
    darkOnLight: darkOnLight
    lightOnDark: lightOnDark
