import React from "react";
import PropTypes, { func } from "prop-types";

function getPrompt() {
  const [result, setResult] = React.useState({});
  const [loading, setLoading] = React.useState("false");

  React.useEffect(() => {
    async function fetchPrompt() {
      try {
        setLoading("true");
        const response = await fetch("/prompts/last");
        const json = await response.json();
        setResult(json);
      } catch (error) {
        setLoading("null");
      }
    }

    fetchPrompt();
  }, []);

  return [result, loading];
}

function EroticPrompt(props) {
  const [result, loading] = getPrompt();

  return (
    <div>
      {loading === "false" ? (
        <p>Loading...</p>
      ) : loading === "null" ? (
        <p>Something went terribly wrong.</p>
      ) : (
        <p> {result.prompt}</p>
      )}
    </div>
  );
}

export default EroticPrompt;
