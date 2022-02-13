import React from 'react';
import PropTypes from 'prop-types';
import Button from 'react-bootstrap/Button';
import ReactHowler from 'react-howler';
import ReportModal from './ReportModal';
import CountdownTimer from './CountdownTimer';

const MAX_CHARACTERS = 280;
const COUNTDOWN_TIME = 180;

function getPrompt(reported, ticket, token) {
  const [result, setResult] = React.useState({});
  const [loading, setLoading] = React.useState('false');

  React.useEffect(() => {
    async function fetchPrompt() {
      try {
        const response = await fetch(`/prompts/last?ticket=${ticket}&token=${token}`);
        const json = await response.json();
        setResult(json);
        setLoading('true');
      } catch (error) {
        setLoading('null');
      }
    }

    fetchPrompt();
  }, [reported]);

  return [result, loading];
}

function checkPulse(ticket, token, submitted) {
  React.useEffect(() => {
    async function postHeartbeat() {
      try {
        const csrf = document.querySelector("meta[name='csrf-token']").getAttribute('content');
        const body = {
          ticket,
          token,
        };
        await fetch('/deli_counter/heartbeat', {
          method: 'post',
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            'X-CSRF-Token': csrf,
          },
          body: JSON.stringify(body),
        });
      } catch (error) {
        console.log(error);
      }
    }

    let interval = null;
    if (ticket && token) {
      if (submitted === true) {
        clearInterval(interval);
      } else {
        interval = setInterval(() => {
          postHeartbeat();
        }, 4000);
      }
    }
    return () => clearInterval(interval);
  }, [ticket, token, submitted]);
}

function getStory(ticket, token, submitted) {
  const [result, setResult] = React.useState({});

  React.useEffect(() => {
    async function fetchStory() {
      try {
        const response = await fetch(`/prompts/story?ticket=${ticket}&token=${token}`);
        const json = await response.json();
        setResult(json);
      } catch (error) {
        console.log(error);
      }
    }

    if (ticket && token && submitted === true) {
      fetchStory();
    }
  }, [ticket, token, submitted]);

  return result;
}

function EroticPrompt({ ticket, token }) {
  const [reported, setReported] = React.useState(false);
  const [charCounter, setCharCounter] = React.useState(MAX_CHARACTERS);
  const [submitted, setSubmitted] = React.useState('false');
  const [reportModalOpen, setReportModalOpen] = React.useState(false);
  const countdownTime = Date.now() + COUNTDOWN_TIME * 1000;
  const [soundPlayed, setSoundPlayed] = React.useState(false);

  const [result, loading] = getPrompt(reported, ticket, token);
  const fullStory = getStory(ticket, token, submitted);
  checkPulse(ticket, token, submitted);

  const submitEl = React.useRef(null);
  const reportEl = React.useRef(null);
  const inputEl = React.useRef(null);

  const submitClicked = () => {
    submitEl.current.setAttribute('disabled', true);
    const newPrompt = inputEl.current.value.trim();
    if (newPrompt === '') {
      submitEl.current.removeAttribute('disabled');
      return;
    }

    async function postPrompt() {
      try {
        const body = {
          prompt: newPrompt,
          previous_prompt_id: result.id,
          ticket,
          token,
        };
        const csrf = document.querySelector("meta[name='csrf-token']").getAttribute('content');
        await fetch('/prompts', {
          method: 'post',
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            'X-CSRF-Token': csrf,
          },
          body: JSON.stringify(body),
        });
      } catch (error) {
        setSubmitted('null');
      }

      setSubmitted(true);
    }

    postPrompt();
  };

  const openReportModal = () => {
    setReportModalOpen(true);
  };
  const closeReportModal = () => {
    setReportModalOpen(false);
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
          ticket,
          token,
        };
        const csrf = document.querySelector("meta[name='csrf-token']").getAttribute('content');
        const response = await fetch(`/prompts/${promptId}/report`, {
          method: 'post',
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            'X-CSRF-Token': csrf,
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

  const updateCharCountdown = () => {
    setCharCounter(MAX_CHARACTERS - inputEl.current.value.length);
  };

  const soundLink = document.querySelector("meta[name='bell-sound']").getAttribute('content');

  const turnOffSound = () => {
    setSoundPlayed(true);
  };

  const printStory = (prompts) => {
    if (!prompts.full_story) {
      return 'Please give a prompt to see the whole story.';
    }
    let story = '';

    prompts.full_story.forEach((item) => {
      story += `${item.prompt} `;
    });
    return story;
  };

  let renderedComponent;
  if (loading === 'false') {
    renderedComponent = <p>Loading...</p>;
  } else if (loading === 'null') {
    renderedComponent = <p>Something went terribly wrong.</p>;
  } else if (submitted === 'false') {
    renderedComponent = (
      <div>
        <p className="instructions">
          Hey all you sexy humans, here&apos;s a place to share and cultivate your fantasies -
          however taboo. Anonymously contribute to this erotic story and fulfill your desires.
          <br />
          <br />
          No hate speech. No racist, misogynistic, homophobic, transphobic, ageist, ableist, etc
          language. Don&apos;t yuck someone&apos;s yum. If you see something that goes against these
          guidelines, report it.
        </p>
        <p className="prompt"> {result.prompt} </p>
        <p className="prompt-question">What happens next?</p>
        <Button variant="danger" id="prompt_report" ref={reportEl} onClick={openReportModal}>
          Report!
        </Button>
        <CountdownTimer
          isActive
          date={countdownTime}
          onFinish={() => {
            setSubmitted(true);
          }}
        />
        <textarea
          className="form-control"
          ref={inputEl}
          placeholder="Give me the next sentence in the story! ;)"
          rows="3"
          maxLength={MAX_CHARACTERS}
          onChange={updateCharCountdown}
        />
        <p className="char-counter">{charCounter}</p>
        <Button variant="primary" id="prompt_submit" ref={submitEl} onClick={submitClicked}>
          Submit!
        </Button>

        <ReportModal
          open={reportModalOpen}
          onClose={closeReportModal}
          onReport={reportPrompt}
          promptId={result.id}
        />
        <ReactHowler src={soundLink} playing={soundPlayed === false} onEnd={turnOffSound} />
      </div>
    );
  } else if (submitted === 'null') {
    renderedComponent = <p>Something went terribly wrong.</p>;
  } else {
    renderedComponent = (
      <div>
        <h2 className="thank-you">Thank you for playing~!</h2>
        <p className="story">{printStory(fullStory)}</p>
      </div>
    );
  }

  return renderedComponent;
}

EroticPrompt.propTypes = {
  token: PropTypes.string.isRequired,
  ticket: PropTypes.number.isRequired,
};

export default EroticPrompt;
