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

function App() {
  const [result, loading] = getTicket();

  return (
    <div>
      <h1>Welcome to Erotic Corpse</h1>
      {loading === "false" ? (
        <p>Loading...</p>
      ) : loading === "null" ? (
        <p>Something went terribly wrong.</p>
      ) : (
        <div>
          <DeliCounter ticket={result.ticket} token={result.token} />
          {/* TODO: Only show when ticket matches now_serving. */}
          <EroticPrompt ticket={result.ticket} token={result.token} />
        </div>
      )}
    </div>
  );
}

App.propTypes = {};
export default App;
