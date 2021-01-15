import React from 'react';
import ReactAudioPlayer from 'react-audio-player';
import DeliCounter from './app/DeliCounter';
import EroticPrompt from './app/EroticPrompt';

function getTicket() {
  const [result, setResult] = React.useState({});
  const [loading, setLoading] = React.useState('false');

  React.useEffect(() => {
    async function fetchTicket() {
      try {
        const csrf = document.querySelector("meta[name='csrf-token']").getAttribute('content');
        const response = await fetch('/deli_counter/ticket', {
          method: 'post',
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            'X-CSRF-Token': csrf,
          },
        });
        const json = await response.json();
        setResult(json);
        setLoading('true');
      } catch (error) {
        setLoading('null');
      }
    }

    fetchTicket();
  }, []);

  return [result, loading];
}

function pollNowServing({ ticket, token }) {
  const [nowServing, setNowServing] = React.useState(null);
  React.useEffect(() => {
    async function fetchNowServing() {
      try {
        const csrf = document.querySelector("meta[name='csrf-token']").getAttribute('content');
        const body = {
          ticket,
          token,
        };
        const response = await fetch('/deli_counter/now_serving', {
          method: 'post',
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            'X-CSRF-Token': csrf,
          },
          body: JSON.stringify(body),
        });
        const json = await response.json();
        setNowServing(json.ticket);
      } catch (error) {
        console.log(error);
      }
    }

    let interval = null;
    if (ticket && token) {
      fetchNowServing();
      if (ticket === nowServing) {
        clearInterval(interval);
      } else {
        interval = setInterval(() => {
          fetchNowServing();
        }, 4000);
      }
    }
    return () => clearInterval(interval);
  }, [ticket, token, nowServing]);
  return nowServing;
}

function App() {
  const [result, loading] = getTicket();
  const nowServing = pollNowServing(result);

  let renderedComponent;
  if (loading === 'false') {
    renderedComponent = <p>Loading...</p>;
  } else if (loading === 'null') {
    renderedComponent = <p>Something went terribly wrong.</p>;
  } else if (result.ticket !== nowServing) {
    renderedComponent = (
      <DeliCounter ticket={result.ticket} token={result.token} nowServing={nowServing} />
    );
  } else {
    renderedComponent = <EroticPrompt ticket={result.ticket} token={result.token} />;
  }

  return (
    <div>
      <h1 className="title">Welcome to Erotic Corpse</h1>
      <h2 className="subtitle">a collaborative writing experience</h2>
      {renderedComponent}
      <div className="audio-player">
        <p>Feel free to listen to Radio KTSK while you wait or write!</p>
        <ReactAudioPlayer src="https://kstk.rocks:8443/kstk" autoPlay controls />
      </div>
      <div className="credits">
        <h1 className="credit-title">Credits</h1>
        <p className="credit">Designed by Caitlyn Kilgore and Chris Ward</p>
        <p className="credit">Created by Chris Ward</p>
        <p className="credit">
          &quot;Bell, Counter, A.wav&quot; by InspectorJ (www.jshaw.co.uk) of Freesound.org
        </p>
      </div>
    </div>
  );
}

App.propTypes = {};
export default App;
