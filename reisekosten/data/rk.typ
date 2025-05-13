#let TEST = false  // displays all possible costs

#set page("a4")
#set text(lang: "de")
#set text(font: "vipnagorgialla")
#show raw: set text(7pt)

#show heading: it => text(font: "Cyberfall", 31pt)[
  #it.body
]

#show heading.where(level: 2): it => text(font: "Cyberfall", 22pt)[
  #it.body
]

// replace € with credit symbol
#show "€": box(
  image("credit.svg", height: 0.7em)
)

// load data from file
#let data = json(sys.inputs.file)
#let cost_layout = json("template_costs_layout.json")

= Reisekostenabröchnung
= Flugreport Tantal-3

== Schiffsdaten

#box(
  height: 7.5em,
  clip: true,
//  stroke: black,
  table(
    columns: 2,
    stroke: none,
    [Schiffsname:], data.registration.name,
    [Schiffstyp:], data.registration.type,
    [Rufzeichen:], data.registration.callsign,
    [Notiz:], data.registration.note , // auf zwei Zeilen limitiert.
  )
)

== Flugdatenauswertung
#table(
  columns: (1fr, 1fr),
  stroke: none,
  image(sys.inputs.plot),
  box(
    stroke: (
      paint: rgb("#cccccc"),
      thickness: 2pt,
      cap: "round",
    //  dash: "dashed"
    ),
    radius: (
      top-right: 10%,
      bottom-left: 10%
    ),
    width: 1fr,
    height: 21.7%,
    inset: 10pt,
	outset: -3.75pt,
    clip: true,
    raw(data.damagetext)
  )
)

== Kostenaufstellung\
#if data.costs.Gewinn < 0 [
  Von der Hafenmeisterei auszuzahlender Betrag: #h(1fr) #text(18pt, str(data.costs.Gewinn) +" €")
] else [
  Von der Hafenmeisterei einzuziehender Betrag: #h(1fr) #text(18pt, str(data.costs.payment) +" €")
]

#let cost(description, amount: none) = {
  if data.costconfig.at(description, default:4) != 0 {
    if amount != none {
      if data.costconfig.at(description, default:4) == 2 [
        #strike([#description #h(1fr) #amount €])\
      ] else [
        #description #h(1fr) #amount €\
      ]
    } else [
      #description\
    ]
  }
}

#let cost_indented(description, amount: none) = {
  h(1em); cost(description, amount:amount)
}

#let cost_topic(topic_values) = {
  let topic_text = [] 
  let n = 0
  for key in topic_values {
    let amount = data.costs.at(key, default:none)
    if amount != none or TEST or key.first() == "(" {
      if data.costconfig.at(key, default: 4) != 0 {
        topic_text += cost_indented(key, amount: amount)
        n += 1
      }
    }
  }
  return (topic_text, n)
}

#let cost_column(template_column) = {
  for (topic_key, topic_values) in template_column {
    if topic_values.len() == 0 {
      let amount = data.costs.at(topic_key, default:none)
      if amount != none or TEST {
        cost(topic_key, amount: amount)
      }
    } else {
      let (topic_text, number_of_elements) = cost_topic(topic_values)
      if number_of_elements > 0 or TEST {
        cost(topic_key)
        topic_text
      }
    }
    v(0.3em)
  }
}

Detailaufstellung:\
#set text(6pt)
#box(
  place(
    top,
    table(
      columns: (1fr, 1fr),
      stroke: none,
      cost_column(cost_layout.column_left),
      cost_column(cost_layout.column_right),
    )
  )
)



