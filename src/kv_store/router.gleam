import gleam/http
import kv_store/web
import wisp.{type Request, type Response}

/// The HTTP request handler- your application!
/// 
pub fn handle_request(req: Request) -> Response {
  // Apply the middleware stack for this request/response.
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> home_page(req)

    // matches /comments
    ["comments"] -> comments(req)

    // matches /comments/:id
    ["comments", id] -> show_comment(req, id)

    _ -> wisp.not_found()
  }
}

fn home_page(req: Request) -> Response {
  use <- wisp.require_method(req, http.Get)

  wisp.ok()
  |> wisp.html_body("Hello, Joe!")
}

fn comments(req: Request) -> Response {
  case req.method {
    http.Get -> list_comments()
    http.Post -> create_comment(req)
    _ -> wisp.method_not_allowed([http.Get, http.Post])
  }
}

fn list_comments() -> Response {
  wisp.ok()
  |> wisp.html_body("Comments!")
}

fn create_comment(_req: Request) -> Response {
  wisp.created()
  |> wisp.html_body("Created")
}

fn show_comment(req: Request, id: String) -> Response {
  use <- wisp.require_method(req, http.Get)

  wisp.ok()
  |> wisp.html_body("Comment with id " <> id)
}
