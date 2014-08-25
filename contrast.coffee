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


# Get fg color on dark bg
#
# @param  {number[]} bg    - Color of dark bg
# @param  {number}   ratio - Contrast ratio between bg & fg
# @param  {number}   hue   - Hue of fg
# @return {number[]} color - Color of fg
#
readableLight = (bg, hsl, ratio) ->
    hsl = formatHSL hsl

    # (l_fg + 0.05) / (l_bg + 0.05) == ratio
    l_bg = rgb2luminance bg
    l_fg = (l_bg + 0.05) * ratio - 0.05

    # rgb を計算
    rgb = hsl2rgb hsl
    result = luminance2rgb l_fg, rgb
    return result


# Get fg color on light bg
#
# @param  {number[]} bg    - Color of light bg
# @param  {number}   ratio - Contrast ratio between bg & fg
# @param  {number}   hue   - Hue of fg
# @return {number[]} color - Color of fg
#
readableDark = (bg, hsl, ratio) ->
    hsl = formatHSL hsl

    # (l_bg + 0.05) / (l_fg + 0.05) == ratio
    l_bg = rgb2luminance bg
    l_fg = (l_bg + 0.05) / ratio - 0.05

    # rgb を計算
    rgb = hsl2rgb hsl
    result = luminance2rgb l_fg, rgb
    return result



formatHSL = (hsl) ->
    [h, s, l] = hsl
    h = h % 360
    s = s / 100.0 if s > 1.0
    l = l / 100.0 if l > 1.0
    return [h, s, l]



# Get difference omong r, g, b  assuming s = v = 1
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
    readableDark: readableDark
    readableLight: readableLight
