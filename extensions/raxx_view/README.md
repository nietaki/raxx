# Raxx.View

**Generate HTML views from `.eex` template files for Raxx web applications.**

[![Hex pm](http://img.shields.io/hexpm/v/raxx_view.svg?style=flat)](https://hex.pm/packages/raxx_view)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

- [Install from hex.pm](https://hex.pm/packages/raxx_view)
- [Documentation available on hexdoc](https://hexdocs.pm/raxx_view)
- [Discuss on slack](https://elixir-lang.slack.com/messages/C56H3TBH8/)

### Defining Views

Common layout to use in multiple views.

*lib/my_app/layout.html.eex*
```ex
<header>
  <h1><% title %></h1>
  <%= __content__ %>
</header>
```
Template to show a list of users.

*lib/my_app/list_users.html.eex*

```eex
<%= for user <- users do %>
<section>
  <a href="/users/<%= user.id %>"><%= user.name %></a>
  <p>
    Joined on <%= Timex.format!(user.registered_at, "{YYYY}-0{M}-0{D}") %>
  </p>
</section>
```

View module that uses our templates.

*lib/my_app/list_users_view.ex*

```elixir
defmodule MyApp.ListUsersView do
  use Raxx.View,
    arguments: [:users],
    optional: [title: "My App"]
    template: "list_users.html.eex",
    layout: "layout.html.eex"
end
```

- variables set in `:optional` have a default value that can be overwritten when using the view.
- If `:template` is left unspecified the view will assume the template is in a file of the same name but with extension `.html.eex` in place of `.ex` or `.exs`.
- An option for `:layout` can be omitted if all the content is in the view.
- The `:arguments` can be set to `[:assigns]` if you prefer to use `@var` in you eex templates.
  This will not give you a compile time waring about unused arguments.

### Using views

The `Raxx.View` macro generates a `render` function for adding a view to a request/response.

```elixir
response = Raxx.response(:ok)
MyApp.ListUsersView.render(response, user, title: "Users Page")
```

To work directly with the generated string an `html` function is also generated.

```elixir
MyApp.ListUsersView.html(user, title: "Users Page")
```

### Views in controllers/actions

For simple usecases it is often more convenient to keep the controller and view code together.

```elixir
defmodule MyApp.ListUsers do
  use Raxx.SimpleServer
  use Raxx.View,
    arguments: [:users],
    optional: [title: "My App"]
    template: "list_users.html.eex",
    layout: "layout.html.eex"

  @impl Raxx.SimpleServer
  def handle_request(_request, _state) do
    users = MyApp.fetch_users()

    response(:ok)
    |> render(users)
  end
end
```

### Helpers

Helpers can be used to limit the amount of code written in a template.
Functions defined in a view module, public or private, can be called in the template.

*lib/my_app/list_users.ex*
```elixir
# ... rest of module

def display_date(datetime = %DateTime{}) do
  Timex.format!(datetime, "{YYYY}-0{M}-0{D}")
end

def user_page_link(user) do
  ~E"""
  <a href="/users/<%= user.id %>"><%= user.name %></a>
  """
end
```

Update the template to use the helpers.

*lib/my_app/list_users.html.eex*

```eex
<%= for user <- users do %>
<section>
  user_page_link(user)
  <p>
    Joined on <%= display_date(user.registered_at) %>
  </p>
</section>
```

### Partials

A partial is like any another helper function, but one that uses an EEx template file.

*lib/my_app/list_users.ex*

```elixir
# ... rest of module

partial(:profile_card, [:user], template: "profile_card.html.eex")
```

- If `:template` is left unspecified the partial will assume the template is in a file with the same name as the partial with extension `.html.eex`.

Update the template to make use of the profile_card helper

*lib/my_app/list_users.html.eex*

```eex
<%= for user <- users do %>
profile_card(user)
<% end %>
```

## Reusable Layouts and Helpers

Layouts can be used to define views that share layouts and possibly helpers.

*lib/my_app/layout.ex*

```elixir
defmodule MyApp.Layout do
  use Raxx.View.Layout,
    layout: "layout.html.eex",
    optional: [title: "My App"]

  def display_date(datetime = %DateTime{}) do
    Timex.format!(datetime, "{YYYY}-0{M}-0{D}")
  end

  def user_page_link(user) do
    ~E"""
    <a href="/users/<%= user.id %>"><%= user.name %></a>
    """
  end

  partial(:profile_card, [:user], template: "profile_card.html.eex")
end
```

- If `:layout` is left unspecified the layout will assume the template is in a file of the same name but with extension `.html.eex` in place of `.ex` or `.exs`.
- All functions defined in a layout will be available in the derived views.

The list users view can be derived from our layout and use the shared helpers.

*lib/my_app/list_users.ex*

```elixir
defmodule MyApp.ListUsersView do
  use MyApp.Layout,
    arguments: [:users],
    optional: [title: "List users - My App"]
    template: "list_users.html.eex",
end
```

- Variables set in `:optionals` for the layout can have there default value overwritten by setting them again when using the layout.
