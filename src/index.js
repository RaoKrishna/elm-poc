import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

var app = Elm.Main.init({
  node: document.getElementById('root')
});

// app.ports.formatTime.subscribe(function(data) {
//   console.log(data);
//   // app.ports.sendFormattedTime.send(data);
// });

registerServiceWorker();

