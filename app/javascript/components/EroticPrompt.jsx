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
  const [submitted, setSubmitted] = React.useState("false");

  const submitEl = React.useRef(null);
  const inputEl = React.useRef(null);

  const submitClicked = () => {
    submitEl.current.setAttribute("disabled", true);
    const newPrompt = inputEl.current.value.trim();
    if (newPrompt === "") {
      submitEl.current.removeAttribute("disabled");
      return;
    }

    async function postPrompt() {
      try {
        const body = {
          prompt: newPrompt,
          previous_prompt_id: result.id,
        };
        console.log(body);
        const csrf = document
          .querySelector("meta[name='csrf-token']")
          .getAttribute("content");
        const response = await fetch("/prompts", {
          method: "post",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
            "X-CSRF-Token": csrf,
          },
          body: JSON.stringify(body),
        });
      } catch (error) {
        setSubmitted("null");
      }

      setSubmitted("true");
    }

    postPrompt();
  };

  return (
    <div>
      {loading === "false" ? (
        <p>Loading...</p>
      ) : loading === "null" ? (
        <p>Something went terribly wrong.</p>
      ) : submitted === "false" ? (
        <div>
          <h2> Here is your prompt: </h2>
          <p> {result.prompt} </p>
          <textarea
            ref={inputEl}
            placeholder="Give me the next sentence in the story! ;)"
            maxLength="280"
          />
          <br />
          <button id="prompt_submit" ref={submitEl} onClick={submitClicked}>
            Submit!
          </button>
          {/* <button id="prompt_repot">Report!</button> */}
        </div>
      ) : submitted === "null" ? (
        <p>Something went terribly wrong.</p>
      ) : (
        <h2>Thank you for playing~!</h2>
      )}
    </div>
  );
}

export default EroticPrompt;
