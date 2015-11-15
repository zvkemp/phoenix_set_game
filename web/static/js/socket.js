// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "deps/phoenix/web/static/js/phoenix"

let socket = new Socket("/socket")

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("games:new_game", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

let container = d3.select('#game_container')

channel.on("game_state", body => {
  if (body.player_id) {
    let player = d3.selectAll('h4.player').data([body.player_id])
    player.enter().append('h3').classed('player', true)
    player.text(d => `Player ${d}`)
  }

  if (body.players) {
    let player_table = d3.select('#scores tbody')
    let players = player_table.selectAll('tr').data(body.players)
    players.enter().append('tr')
    players.html(d => {
      return [
        `<td>${d.name}:</td>`,
        `<td>${d.score}</td>`
      ].join('')
    })
    players.exit().remove()
  }

  let rows = container.selectAll('div.card').data(body.cards, d => d.id)
  rows.enter().append('div').classed('card', true)

  let a = function(foo) {
    foo.html(d => {
      let html = []
      let shapes = []
      for (var i = 0; i < d.count; i++) {
        html.push(`<img src="/images/${d.shape}_${d.fill}_${d.color}.png" />`)
        html.push('<br />')
      }
      return html.join("")
    })
  }

  rows.on('click', function(e) { window.handle_click(this, e) } )

  rows.call(a)
  rows.attr('style', d => `color:${d.color}`)
  rows.exit().remove()
})

window.handle_click = function(row, data) {
  let r = d3.select(row)
  r.classed('selected', !r.classed('selected'))
  let selected = d3.selectAll('.card.selected')
  if ( selected[0].length == 3 ) {
    let name = d3.select('#player_info input')[0][0].value
    channel.push("find_set", { name: name, set: selected.data().map(d => d.id) })
    selected.classed('selected', false)
  }
}

d3.select('#show_more').on('click', function() {
  channel.push("show_more", {})
})

d3.select('#new_game').on('click', function() {
  channel.push("new_game", {})
})

window.channel = channel

export default socket
