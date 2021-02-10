open Webapi;

type t = Dom.Attr.t;

[@bs.get] external value: t => string = "value";