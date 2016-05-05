// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

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

function mountMessage(payload){
  let html = '<div class="message' + (payload.user_id == window.userId ? ' mine' : '') + '" data-id="' + payload.id + '">'
  if(payload.user_id != window.userId){
    html += '<div class="username">' + payload.user_name + '</div><hr>'
  }
  html += '<div class="body">' + payload.message + '</div></div><br>'
  return html;
}

function scrollMessages(payload){
  console.log(messages.scrollTop() + messages.innerHeight())
  console.log(messages[0].scrollHeight - 20)
  if(payload.user_id == window.userId || messages.scrollTop() + messages.innerHeight() >= messages[0].scrollHeight - 88){
    messages.scrollTop(messages[0].scrollHeight);
  }
}

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("rooms:lobby", {token: window.userToken})
let chatInput = $('#chat-input')
let messages = $('#messages')

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("new_message", payload => {
  messages.append(mountMessage(payload))
  scrollMessages(payload)
})

chatInput.on('keypress', event => {
  if(event.keyCode == 13 && chatInput.val() != ''){
    channel.push("new_message", {body: chatInput.val()})
    chatInput.val('')
  }
})

$(document).ready(function(){
  messages.scrollTop(messages[0].scrollHeight);
})

export default socket
