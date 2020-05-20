import React from "react";
import Countdown from "react-countdown";

const CountdownTimerFormat = (props) => {
  const secondsString = `${props.seconds % 60}`.padStart(2, "0");
  return (
    <div className="time">
      {props.minutes}:{secondsString}
    </div>
  );
};

const CountdownTimer = (props) => {
  return (
    <Countdown
      date={props.date}
      renderer={CountdownTimerFormat}
      onComplete={props.onFinish}
    />
  );
};

export default CountdownTimer;
