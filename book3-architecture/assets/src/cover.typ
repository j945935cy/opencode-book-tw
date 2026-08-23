#let ink = rgb("#E6EDF3")
#let dim = rgb("#9FB0C3")
#let faint = rgb("#66788F")
#let green = rgb("#3DDC97")
#let cyan = rgb("#22D3EE")
#let amber = rgb("#F5D68A")

#set page(width: 16cm, height: 24cm, margin: 0pt)
#set text(lang: "zh", region: "TW", font: "WenQuanYi Micro Hei")

#place(rect(width: 100%, height: 100%, fill: gradient.linear(angle: 180deg, rgb("#0A0E14"), rgb("#0C1320"), rgb("#0A1018"))))
#place(dx: 3.5cm, dy: -5cm, circle(radius: 7cm, fill: gradient.radial(cyan.transparentize(84%), white.transparentize(100%))))
#place(dx: -4cm, dy: 18cm, circle(radius: 7cm, fill: gradient.radial(green.transparentize(87%), white.transparentize(100%))))

#for i in range(1, 15) {
  place(line(start: (i * 1.2cm, 0%), end: (i * 1.2cm, 100%), stroke: 0.4pt + white.transparentize(95%)))
  place(line(start: (0%, i * 1.2cm), end: (100%, i * 1.2cm), stroke: 0.4pt + white.transparentize(95%)))
}

#place(top + left, dx: 1.9cm, dy: 2.2cm)[
  #box(stroke: 1pt + green.transparentize(45%), radius: 999pt, inset: (x: 16pt, y: 7pt), fill: green.transparentize(93%))[
    #text(font: "DejaVu Sans Mono", size: 11pt, tracking: 1pt, fill: green)[OPENCODE 技術叢書 / 03]
  ]
]

#place(top + left, dx: 1.85cm, dy: 5.7cm)[
  #text(font: "DejaVu Sans Mono", weight: 700, size: 58pt, tracking: -1.8pt, fill: white)[
    opencode#h(2pt)#text(fill: green)[\_]#box(width: 8pt, height: 34pt, fill: green, baseline: 9pt)
  ]

  #v(0.45cm)
  #text(weight: 900, stroke: 0.6pt + white, size: 82pt, tracking: 5pt, fill: white)[架構解密]

  #v(0.75cm)
  #line(length: 1.7cm, stroke: 2.5pt + gradient.linear(angle: 90deg, green, cyan))
  #h(0.35cm)
  #text(size: 15.5pt, tracking: 1.5pt, fill: dim)[從代理迴圈到生產級 AI 系統的可觀察設計]
]

#place(bottom + left, dx: 1.85cm, dy: -6.6cm)[
  #block(width: 12.3cm, fill: rgb("#0F172A"), stroke: 0.9pt + rgb("#94A3B8").transparentize(72%), radius: 10pt, clip: true)[
    #box(width: 100%, inset: (x: 14pt, y: 10pt), fill: white.transparentize(92%))[
      #set text(font: "DejaVu Sans Mono", size: 8.5pt, fill: rgb("#7D8CA3"))
      #h(0pt)#box(width: 8pt, height: 8pt, radius: 4pt, fill: rgb("#FF5F57")) #h(5pt)
      #box(width: 8pt, height: 8pt, radius: 4pt, fill: rgb("#FEBC2E")) #h(5pt)
      #box(width: 8pt, height: 8pt, radius: 4pt, fill: rgb("#28C840"))
      #h(10pt)~/my-project — opencode
    ]
    #block(inset: (x: 16pt, y: 12pt))[
      #set text(font: ("DejaVu Sans Mono", "WenQuanYi Micro Hei"), size: 11.5pt, fill: rgb("#C9D6E4"))
      #text(fill: green)[\$] curl localhost:4096/global/health\
      #text(fill: faint)[\{"healthy":true,"version":"1.18.21"\}]\
      #text(fill: green)[\$] sqlite3 opencode.db ".tables"\
      #text(fill: cyan)[session  message  part  event  todo]\
      #text(fill: amber)[19 張資料表。]#text(fill: green)[引擎室，開箱。]
    ]
  ]
]

#place(bottom + left, dy: -1.55cm, dx: 1.85cm)[
  #block(width: 12.3cm)[
  #grid(columns: (auto, 1fr), column-gutter: 0pt,
    align(left)[#text(size: 13pt, weight: 700, tracking: 1pt, stroke: 0.25pt + rgb("#C9D6E4"), fill: rgb("#C9D6E4"))[Happy eBook Authors]],
    align(right)[#text(font: "DejaVu Sans Mono", size: 8.5pt, tracking: 1pt, fill: faint)[OPENCODE v1.X · 2026\ SERVE / QUERY / OBSERVE]]
  )
]
]
