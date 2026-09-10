import React from 'react';
import PropTypes from 'prop-types';
import Countdown from 'react-countdown';

function CountdownTimerFormat({ seconds, minutes }) {
  const secondsString = `${seconds % 60}`.padStart(2, '0');
  const timeString = `${minutes}:${secondsString}`;
  return <div className="time">{timeString}</div>;
}

function CountdownTimer({ date, onFinish }) {
  return <Countdown date={date} renderer={CountdownTimerFormat} onComplete={onFinish} />;
}

CountdownTimerFormat.propTypes = {
  seconds: PropTypes.number.isRequired,
  minutes: PropTypes.number.isRequired,
};

CountdownTimer.propTypes = {
  date: PropTypes.number.isRequired,
  onFinish: PropTypes.func.isRequired,
};

export default CountdownTimer;
