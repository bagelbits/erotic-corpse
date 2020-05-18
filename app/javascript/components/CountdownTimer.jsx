import React, { useState, useEffect } from "react";

const secondsToMinutes = (seconds) => {
  const minutes = Math.floor(seconds / 60);
  const secondString = `${seconds % 60}`.padStart(2, "0");
  return `${minutes}:${secondString}`;
};

const CountdownTimer = (props) => {
  const [seconds, setSeconds] = useState(props.seconds);

  useEffect(() => {
    let interval = null;
    if (props.isActive && seconds !== 0) {
      interval = setInterval(() => {
        setSeconds((seconds) => seconds - 1);
      }, 1000);
    } else if (seconds === 0) {
      clearInterval(interval);
      props.onFinish();
    }
    return () => clearInterval(interval);
  }, [props.isActive, seconds]);

  return <div className="time">{secondsToMinutes(seconds)}</div>;
};

export default CountdownTimer;
