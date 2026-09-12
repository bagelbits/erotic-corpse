import React from 'react';
import PropTypes from 'prop-types';

function DeliCounter({ ticket, nowServing = null }) {
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
    </div>
  );
}

DeliCounter.propTypes = {
  ticket: PropTypes.number.isRequired,
  nowServing: PropTypes.number,
};

export default DeliCounter;
