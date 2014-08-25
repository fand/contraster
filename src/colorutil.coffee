###*
 * Get difference omong r, g, b  assuming s = v = 1
 * @param  {number}   hue   - Hue to get the diff of RGB
 * @param  {number[]} color
###
code2rgb = (code) ->
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

bgcolor = (el) ->
    str = getComputedStyle(el)['backgroundColor']
    return str2array str

module.exports =
    str2array: str2array
    bgcolor: bgcolor
