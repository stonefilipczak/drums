// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Tone from "../vendor/tone.min.js"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

if (document.getElementById("allow-audio")) {
    document.getElementById("allow-audio").addEventListener("click", function() {
      Tone.context.resume().then(() => {
        console.log('Playback resumed successfully');
        synth = new Tone.PolySynth({
          maxPolyphony: 64,
          voice: Tone.Synth,
          volume: -6,
          options: {
            envelope : {
              attack : 2,
              decay : 1.8,
              sustain : 1,
              release : 10
            }
          }
        })
  
        reverb = new Tone.Reverb(0.7);
        delay = new Tone.PingPongDelay("3n", 0.5);
        const compressor = new Tone.Compressor(-30, 3);
        
        /**
         * Audio effects chain:
         *
         * [PolySynth] --> [Reverb] --> [Delay] --> [Compressor] --> Output
         */
        synth.connect(reverb);
        reverb.connect(delay);
        delay.connect(compressor);
        compressor.toDestination();
  
        synth.triggerAttackRelease("C4", "8n");
      });
    });
  }
