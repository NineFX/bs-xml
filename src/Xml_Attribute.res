open Webapi

type t = Dom.Attr.t

@get external value: t => string = "value"
