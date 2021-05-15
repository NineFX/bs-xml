open Xml__
open Webapi

type t = Dom.Document.t

include NodeLike({
  type t = t
})

@send @return(nullable)
external querySelector: (t, string) => option<Xml_Element.t> = "querySelector"
