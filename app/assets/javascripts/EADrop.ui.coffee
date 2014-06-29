$ ->
  background = $ "#background"
  background.css
    "position": "fixed"
    "bottom": "0"
    "left": "50%"
    "width": "1140px"
    "margin-left": "-570px"
    "height": "700px"
    "z-index": "-1"

  MARGIN = 230
  for i in [0..4]
    element = $ "<div>"
    element.css
      "width": 200 + i*MARGIN + "px"
      "height": 200 + i*MARGIN + "px"
      "border-radius": "50%"
      "border": "solid 1px rgba(160,160,160, "+(0.5-0.08*i)+")"
      "position": "absolute"
      "top": 500 - MARGIN/2*i + "px"
      "left": 450 - MARGIN/2*i + "px"


    background.append(element)
#  $("body").append background