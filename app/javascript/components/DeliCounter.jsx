import React from 'react';
import PropTypes from 'prop-types';
import ReactAudioPlayer from 'react-audio-player';

const DeliCounter = ({ ticket, nowServing }) => {
  const numOfPeople = ticket - nowServing - 1;
  let lineString;
  if (numOfPeople === 1) {
    lineString = `is ${numOfPeople} person`;
  } else {
    lineString = `are ${numOfPeople} people`;
  }
  return (
    <div className="deli-counter">
      <p>There {lineString} ahead of you in line.</p>
      <p>Please do not refresh the page, or you will lose your place in line.</p>
      <br />
      <p>Feel free to listen to Radio KTSK while you wait!</p>
      <ReactAudioPlayer src="https://kstk.rocks:8443/kstk" autoPlay controls />
    </div>
  );
};

DeliCounter.defaultProps = {
  nowServing: null,
};

DeliCounter.propTypes = {
  ticket: PropTypes.number.isRequired,
  nowServing: PropTypes.number,
};

export default DeliCounter;
