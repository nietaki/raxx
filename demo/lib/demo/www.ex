defmodule Demo.WWW do
  use Ace.HTTP.Service, port: 8080, cleartext: true

  use Raxx.Router, [
    {%{path: []}, Demo.WWW.HomePage},
    {_, Demo.WWW.NotFoundPage}
  ]

  @external_resource "lib/demo/public/main.css"
  @external_resource "lib/demo/public/main.js"
  # use Raxx.Static, "./public"
  use Raxx.Logger, level: :info
end
