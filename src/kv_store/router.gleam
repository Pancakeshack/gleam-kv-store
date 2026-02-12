import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/result
import kv_store/web
import wisp.{type Request, type Response}

pub type Person {
  Person(name: String, is_cool: Bool)
}

// To decode the type we need a dynamic decoder.
// See the standard library documentation for more information on decoding
// dynamic values [1].
//
// [1]: https://hexdocs.pm/gleam_stdlib/gleam/dynamic.html
fn person_decoder() -> decode.Decoder(Person) {
  use name <- decode.field("name", decode.string)
  use is_cool <- decode.field("is-cool", decode.bool)
  decode.success(Person(name: name, is_cool: is_cool))
}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)
  use <- wisp.require_method(req, http.Post)

  use json <- wisp.require_json(req)

  let result = {
    use person <- result.try(decode.run(json, person_decoder()))

    // JSON response
    let object =
      json.object([
        #("name", json.string(person.name)),
        #("is-cool", json.bool(person.is_cool)),
        #("saved", json.bool(True)),
      ])
    Ok(json.to_string(object))
  }

  case result {
    Ok(json) -> wisp.json_response(json, 201)
    Error(_) -> wisp.unprocessable_content()
  }
}
