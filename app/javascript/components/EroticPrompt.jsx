import React from "react";
import Button from "react-bootstrap/Button";
import ReportModal from "./ReportModal";
import CountdownTimer from "./CountdownTimer";
import ReactHowler from "react-howler";

const MAX_CHARACTERS = 280;

function getPrompt(reported, ticket, token) {
  const [result, setResult] = React.useState({});
  const [loading, setLoading] = React.useState("false");

  React.useEffect(() => {
    async function fetchPrompt() {
      try {
        const response = await fetch(
          `/prompts/last?ticket=${ticket}&token=${token}`
        );
        const json = await response.json();
        setResult(json);
        setLoading("true");
      } catch (error) {
        setLoading("null");
      }
    }

    fetchPrompt();
  }, [reported]);

  return [result, loading];
}

function EroticPrompt(props) {
  const [reported, setReported] = React.useState(false);
  const [result, loading] = getPrompt(reported, props.ticket, props.token);
  const [charCounter, setCharCounter] = React.useState(0);
  const [submitted, setSubmitted] = React.useState("false");
  const [reportModalOpen, setReportModalOpen] = React.useState(false);
  const [countdownTime, setCountdownTime] = React.useState(
    Date.now() + 180 * 1000
  );
  const [soundPlayed, setSoundPlayed] = React.useState(false);

  const submitEl = React.useRef(null);
  const reportEl = React.useRef(null);
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
          ticket: props.ticket,
          token: props.token,
        };
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

  const reportPrompt = (promptId) => {
    async function submitPromptReport() {
      if (reported) {
        closeReportModal();
        alert("Sorry. You aren't able to report anymore!");
        return;
      }

      try {
        const body = {
          ticket: props.ticket,
          token: props.token,
        };
        const csrf = document
          .querySelector("meta[name='csrf-token']")
          .getAttribute("content");
        const response = await fetch(`/prompts/${promptId}/report`, {
          method: "post",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
            "X-CSRF-Token": csrf,
          },
          body: JSON.stringify(body),
        });
        const json = await response.json();
        if (json.success) {
          setReported(true);
        } else {
          alert(json.error);
        }
      } catch (error) {
        console.log(error);
      }
      closeReportModal();
    }

    submitPromptReport();
  };
  const openReportModal = () => {
    setReportModalOpen(true);
  };
  const closeReportModal = () => {
    setReportModalOpen(false);
  };

  const updateCharCounter = () => {
    setCharCounter(inputEl.current.value.length);
  };

  const soundLink = document
    .querySelector("meta[name='bell-sound']")
    .getAttribute("content");

  const turnOffSound = () => {
    setSoundPlayed(true);
  };

  return (
    <div>
      {loading === "false" ? (
        <p>Loading...</p>
      ) : loading === "null" ? (
        <p>Something went terribly wrong.</p>
      ) : submitted === "false" ? (
        <div>
          <h2 class="prompt-title"> Here is your prompt: </h2>
          <p class="prompt"> {result.prompt} </p>
          <p class="instructions">
            Enter your contribution to the erotic story below. No hate speech.
            No racist, misogynist, homophobic, transphobic, ableist, ageist
            contributions permitted. Please don't belittle anyone. Let's make
            sexual expression safe and fun! If you see something that goes
            against these guidelines, report it.
          </p>
          {/* <CountdownTimer
            isActive={true}
            date={countdownTime}
            onFinish={() => {
              setSubmitted(true);
            }}
          /> */}
          {/* Maybe use bootstrap for this? */}
          <textarea
            ref={inputEl}
            placeholder="Give me the next sentence in the story! ;)"
            maxLength={MAX_CHARACTERS}
            onChange={updateCharCounter}
          />
          <br />
          <p>
            {charCounter}/{MAX_CHARACTERS}
          </p>
          <br />
          <Button
            variant="primary"
            id="prompt_submit"
            ref={submitEl}
            onClick={submitClicked}
          >
            Submit!
          </Button>
          <Button
            variant="danger"
            id="prompt_repot"
            ref={reportEl}
            onClick={openReportModal}
          >
            Report!
          </Button>

          <ReportModal
            open={reportModalOpen}
            onClose={closeReportModal}
            onReport={reportPrompt}
            promptId={result.id}
          />
          <ReactHowler
            src={soundLink}
            playing={soundPlayed == false}
            onEnd={turnOffSound}
          />
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
