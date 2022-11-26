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

const create_sound = (sound) => {
    switch(sound) {
        case "kick":
            kick = new Tone.MembraneSynth({
                volume: 6
              }).toMaster();
            break;

        case "snare":
            const lowPass = new Tone.Filter({
                frequency: 8000,
            }).toMaster();
              
            snare = new Tone.NoiseSynth({
            volume: 2,
            noise: {
                type: 'white',
                playbackRate: 3,
            },
            envelope: {
                attack: 0.001,
                decay: 0.50,
                sustain: 0.15,
                release: 0.4,
            },
            }).connect(lowPass);
            break;    
    }
}

const play_sound = (sound) => {
    switch(sound) {
        case "kick":
            kick.triggerAttackRelease('C1', '8n')
            break;

        case "snare": 
            snare.triggerAttackRelease('8n') 
            break;
    }
}

//init
let parts = Array.from(document.getElementsByClassName("part"));
parts.forEach((part) => {
    create_sound(part.id);
    document.getElementById(part.id + "-demo").addEventListener("click", ()=> {
        play_sound(part.id);
    })
})

const clearIndicators = () => {
    Array.from(document.getElementsByClassName("beat-button")).forEach((button) => {
        button.classList.remove("current-beat")
    })
}

const drums = ["kick", "snare"];
let beat = 0;
const loop = () => {

    clearIndicators();
     
    parts.forEach((part) => {
        current_beat_button = document.getElementById(`${part.id}-beat-${beat}`);
        current_beat_button.classList.add("current-beat");
        if (current_beat_button.classList.contains("active")) {
            play_sound(part.id);
        }
    })

    if (beat < 15) {
        beat++;
    } else {
        beat = 0;
    }

    interval = setTimeout(loop, 150);

}
playButton = document.getElementById("play_button");
playButton.addEventListener("click", (e) => {
    if (e.target.innerHTML == "Play") {
        loop();
        playButton.innerHTML = "Stop";
    } else {
        clearTimeout(interval);
        clearIndicators();
        beat = 0;
        playButton.innerHTML = "Play";
    }
})
