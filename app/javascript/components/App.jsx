import React from "react";
import DeliCounter from "./DeliCounter";
import EroticPrompt from "./EroticPrompt";

function getTicket() {
  const [result, setResult] = React.useState({});
  const [loading, setLoading] = React.useState("false");

  React.useEffect(() => {
    async function fetchTicket() {
      try {
        const csrf = document
          .querySelector("meta[name='csrf-token']")
          .getAttribute("content");
        const response = await fetch("/deli_counter/ticket", {
          method: "post",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
            "X-CSRF-Token": csrf,
          },
        });
        const json = await response.json();
        setResult(json);
        setLoading("true");
      } catch (error) {
        setLoading("null");
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
        const csrf = document
          .querySelector("meta[name='csrf-token']")
          .getAttribute("content");
        const body = {
          ticket,
          token,
        };
        const response = await fetch("/deli_counter/now_serving", {
          method: "post",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
            "X-CSRF-Token": csrf,
          },
          body: JSON.stringify(body),
        });
        const json = await response.json();
        setNowServing(json["ticket"]);
      } catch (error) {}
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

  return (
    <div>
      <h1>Welcome to Erotic Corpse</h1>
      {loading === "false" ? (
        <p>Loading...</p>
      ) : loading === "null" ? (
        <p>Something went terribly wrong.</p>
      ) : result.ticket !== nowServing ? (
        <DeliCounter
          ticket={result.ticket}
          token={result.token}
          nowServing={nowServing}
        />
      ) : (
        <EroticPrompt ticket={result.ticket} token={result.token} />
      )}
    </div>
  );
}

App.propTypes = {};
export default App;
