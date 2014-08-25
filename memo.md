# contrast ratio
contrast ratio =  (L1 + 0.05) / (L2 + 0.05)

- L1: relative luminance of the lighter color
- L2: relative luminance of the darker color


# relative luminance

the relative brightness of any point in a colorspace, normalized to 0 for darkest black and 1 for lightest white
Note 1: For the sRGB colorspace, the relative luminance of a color is defined as L = 0.2126 * R + 0.7152 * G + 0.0722 * B where R, G and B are defined as:

if RsRGB <= 0.03928 then R = RsRGB/12.92 else R = ((RsRGB+0.055)/1.055) ^ 2.4
if GsRGB <= 0.03928 then G = GsRGB/12.92 else G = ((GsRGB+0.055)/1.055) ^ 2.4
if BsRGB <= 0.03928 then B = BsRGB/12.92 else B = ((BsRGB+0.055)/1.055) ^ 2.4
and RsRGB, GsRGB, and BsRGB are defined as:

RsRGB = R8bit/255
GsRGB = G8bit/255
BsRGB = B8bit/255


contrast ratio  = 3
