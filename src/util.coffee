###*
 * Get difference omong r, g, b  assuming s = v = 1
 * @param  {number}   hue   - Hue to get the diff of RGB
 * @param  {number[]} color
###
code2array = (code) ->
    s6 = code.match /#?([a-fA-F0-9]{6})/
    if s6
        codes = s6[1].match /(..)/g
        return codes.map (c) -> Number('0x' + c, 16)
    s3 = code.match /#?([a-fA-F0-9]{3})/
    if s3
        codes = s3[1].match /(.)/g
        return codes.map (c) -> Number('0x' + c + c, 16)
    return [0, 0, 0]

str2array = (str) ->
    s = str.match /\((.*)\)/
    nums = s[1].split /,/
    return nums.map (x) -> +x

array2str = (type, array) ->
    if type == 'rgb'
        return 'rgb(' + array.join(',') + ')'
    if type == 'hsl'
        return 'hsl(' + array[0].toString().slice(0,4) + ',' + ((array[1] * 100)|0) + '%,' + ((array[2] * 100)|0) + '%)'

array2code = (array) ->
    str = '#'
    for x in array
        num = Math.floor(x).toString(16)
        num = '0' + num if num.length == 1
        str += num
    return str

css = (el, key, value) ->
    if value?
        el.style[key] = value
    style = getComputedStyle(el)[key]
    if style.match /.+\(.+\)/
        return str2array style
    return style

getBg = (q) ->
    box = document.querySelector q
    return unless box
    bg = getComputedStyle(box).backgroundColor
    return if bg.match /^\s*$/
    return str2array bg

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

# Convert rgb to hsl.
#
# @param  {number[]}   rgb - [0-255]
# @param  {number[]} color - [0-360, 0-1, 0-1]
#
rgb2hsl = (rgb) ->
    [r, g, b] = (x / 255.0 for x in rgb)
    console.log [r, g, b]
    mmax = Math.max(r,g,b)
    mmin = Math.min(r,g,b)
    c = mmax - mmin
    l = 0.5 * (mmax + mmin)

    # h/s undefinable
    return [0, 0, l] if c == 0

    hh = switch
        when mmax == r then ((g - b) / c) % 6
        when mmax == g then ((b - r) / c) + 2
        when mmax == b then ((r - g) / c) + 4
    h = 60.0 * hh
    s = c / (1 - Math.abs(2*l - 1))
    return [h, s, l]

module.exports =
    str2array: str2array
    array2str: array2str
    array2code: array2code
    css: css
    getBg: getBg
    hsl2rgb: hsl2rgb
    rgb2hsl: rgb2hsl
