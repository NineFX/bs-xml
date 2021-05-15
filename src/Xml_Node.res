open Xml__
open Webapi

type t = Dom.Node.t

let asElement = Dom.Element.ofNode

include NodeLike({
  type t = t
})
