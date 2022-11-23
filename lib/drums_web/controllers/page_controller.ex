defmodule DrumsWeb.PageController do
  use DrumsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
