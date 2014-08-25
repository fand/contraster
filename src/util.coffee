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
    return type + '(' + array.join(',') + ')'

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

module.exports =
    str2array: str2array
    array2str: array2str
    array2code: array2code
    css: css
    getBg: getBg
