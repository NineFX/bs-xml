open Xml__

type t = Webapi.Dom.Element.t

include NodeLike({
  type t = t
})

include ElementLike({
  type t = t
})
